import * as params from '@params';

const resList = document.getElementById('searchResults');
const sInput = document.getElementById('searchInput');
const searchBox = document.getElementById('searchbox');

let fuse;
let currentElement = null;
let firstResult = null;
let lastResult = null;

const defaultFuseOptions = {
    distance: 120,
    threshold: 0.34,
    ignoreLocation: true,
    includeMatches: true,
    minMatchCharLength: 1,
    keys: [
        { name: 'title', weight: 0.35 },
        { name: 'path', weight: 0.25 },
        { name: 'summary', weight: 0.2 },
        { name: 'content', weight: 0.2 }
    ]
};

const buildFuseOptions = () => ({
    ...defaultFuseOptions,
    ...(params.fuseOpts || {}),
    includeMatches: true
});

const debounce = (fn, delay) => {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = window.setTimeout(() => fn(...args), delay);
    };
};

const reset = () => {
    currentElement = null;
    firstResult = null;
    lastResult = null;
    resList.innerHTML = '';
    sInput.value = '';
    sInput.focus();
};

const setActiveResult = (element) => {
    document.querySelectorAll('.focus').forEach((item) => item.classList.remove('focus'));
    if (!element) return;
    element.focus();
    element.parentElement?.classList.add('focus');
    currentElement = element;
};

const escapeHtml = (value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

const normalizeSpace = (value = '') => value.replace(/\s+/g, ' ').trim();

const getSnippet = (result, query) => {
    const summary = normalizeSpace(result.item.summary || '');
    const content = normalizeSpace(result.item.content || '');
    const fallback = summary || content;
    const contentMatch = result.matches?.find((match) => match.key === 'content' || match.key === 'summary');

    if (!contentMatch || !contentMatch.indices?.length) {
        return fallback.slice(0, 120);
    }

    const source = contentMatch.value || fallback;
    const [startIndex] = contentMatch.indices[0];
    const snippetStart = Math.max(0, startIndex - 28);
    const snippetEnd = Math.min(source.length, startIndex + 72);
    const prefix = snippetStart > 0 ? '...' : '';
    const suffix = snippetEnd < source.length ? '...' : '';
    return `${prefix}${source.slice(snippetStart, snippetEnd).trim()}${suffix}`;
};

const renderResults = (results, query) => {
    if (!Array.isArray(results) || results.length === 0) {
        resList.innerHTML = '';
        firstResult = lastResult = currentElement = null;
        return;
    }

    const fragment = document.createDocumentFragment();

    for (const result of results) {
        const li = document.createElement('li');
        li.className = 'search-result-item';

        const location = document.createElement('div');
        location.className = 'search-result-meta';
        location.textContent = `${result.item.path || result.item.section || '文章'} / ${result.item.title}`;

        const preview = document.createElement('div');
        preview.className = 'search-result-preview';
        preview.innerHTML = escapeHtml(getSnippet(result)).replace(
            new RegExp(`(${query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'ig'),
            '<mark>$1</mark>'
        );

        const link = document.createElement('a');
        link.className = 'entry-link';
        link.href = result.item.permalink;
        link.setAttribute('aria-label', result.item.title);

        li.appendChild(location);
        li.appendChild(preview);
        li.appendChild(link);        
        fragment.appendChild(li);
    }

    resList.innerHTML = '';
    resList.appendChild(fragment);
    firstResult = resList.firstElementChild;
    lastResult = resList.lastElementChild;
};

const performSearch = () => {
    if (!fuse) return;

    const query = sInput.value.trim();
    if (!query) {
        renderResults([], '');
        return;
    }

    const searchOptions = params.fuseOpts?.limit ? { limit: params.fuseOpts.limit } : { limit: 18 };
    const results = fuse.search(query, searchOptions);
    renderResults(results, query);
};

const initSearch = async () => {
    if (!sInput || !resList) return;

    sInput.disabled = false;
    sInput.focus();

    try {
        const response = await fetch('../index.json');
        if (!response.ok) throw new Error(`Search index load failed: ${response.status}`);
        const data = await response.json();
        if (data) fuse = new Fuse(data, buildFuseOptions());
    } catch (error) {
        console.error(error);
    }
};

window.addEventListener('load', initSearch);
sInput?.addEventListener('input', debounce(performSearch, 120));
sInput?.addEventListener('search', () => {
    if (!sInput.value) reset();
});

document.addEventListener('keydown', (event) => {
    const { key } = event;
    const active = document.activeElement;
    const isInSearchBox = searchBox?.contains(active);

    if (key === 'Escape') {
        reset();
        return;
    }

    if (!firstResult || !isInSearchBox) return;

    if (key === 'ArrowDown') {
        event.preventDefault();
        if (active === sInput) {
            setActiveResult(firstResult.querySelector('.entry-link'));
        } else if (active?.parentElement !== lastResult) {
            setActiveResult(active?.parentElement?.nextElementSibling?.querySelector('.entry-link'));
        }
    } else if (key === 'ArrowUp') {
        event.preventDefault();
        if (active?.parentElement === firstResult) {
            setActiveResult(sInput);
        } else if (active !== sInput) {
            setActiveResult(active?.parentElement?.previousElementSibling?.querySelector('.entry-link'));
        }
    } else if (key === 'ArrowRight' || key === 'Enter') {
        if (active?.matches?.('.entry-link')) {
            active.click();
        }
    }
});
