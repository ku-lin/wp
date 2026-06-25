from __future__ import annotations

import re
import shutil
from pathlib import Path
from urllib.parse import quote

from PIL import Image


CONTENT_ROOT = Path(r"S:\wp\blog\content")
STATIC_ROOT = Path(r"S:\wp\blog\static\knowledge\obsidian-img")
SOURCE_IMG_ROOT = Path(r"D:\wp\img")
SITE_IMAGE_PREFIX = "/wp/knowledge/obsidian-img"

EMBED_PATTERN = re.compile(r"!\[\[([^\]|]+)(?:\|([^\]]+))?\]\]")
MARKDOWN_IMAGE_PATTERN = re.compile(
    r"!\[([^\]]*)\]\(/wp/knowledge/obsidian-img/([^)]+)\)"
)
HTML_IMAGE_PATTERN = re.compile(
    r'<img\s+src="/wp/knowledge/obsidian-img/([^"]+)"\s+alt="([^"]*)"(?:\s+width="([^"]+)")?\s+loading="lazy">'
)


def compress_and_copy_image(source: Path, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)

    suffix = source.suffix.lower()
    if suffix not in {".png", ".jpg", ".jpeg", ".webp"}:
        shutil.copy2(source, target)
        return

    with Image.open(source) as image:
        image.load()

        if suffix == ".png":
            image.save(target, format="PNG", optimize=True, compress_level=9)
        elif suffix in {".jpg", ".jpeg"}:
            if image.mode not in {"RGB", "L"}:
                image = image.convert("RGB")
            image.save(target, format="JPEG", optimize=True, quality=82, progressive=True)
        elif suffix == ".webp":
            image.save(target, format="WEBP", quality=80, method=6)

    shutil.copystat(source, target)


def render_image_markup(filename: str, width: str | None) -> str:
    image_url = f"{SITE_IMAGE_PREFIX}/{quote(filename)}"
    alt = Path(filename).stem

    if width and width.strip().isdigit():
        return f'\n\n<img src="{image_url}" alt="{alt}" width="{width.strip()}" loading="lazy">\n\n'

    return f"![{alt}]({image_url})"


def normalize_existing_markup(content: str) -> str:
    def markdown_replacer(match: re.Match[str]) -> str:
        alt = match.group(1)
        filename = quote(match.group(2), safe="%")
        return f"![{alt}]({SITE_IMAGE_PREFIX}/{filename})"

    def html_replacer(match: re.Match[str]) -> str:
        filename = quote(match.group(1), safe="%")
        alt = match.group(2)
        width = match.group(3)
        width_attr = f' width="{width}"' if width else ""
        return f'<img src="{SITE_IMAGE_PREFIX}/{filename}" alt="{alt}"{width_attr} loading="lazy">'

    content = MARKDOWN_IMAGE_PATTERN.sub(markdown_replacer, content)
    content = HTML_IMAGE_PATTERN.sub(html_replacer, content)
    return content


def sync_embeds_in_file(markdown_path: Path, copied: set[str], missing: set[str]) -> bool:
    original = markdown_path.read_text(encoding="utf-8")
    normalized = normalize_existing_markup(original)
    changed = False

    def replacer(match: re.Match[str]) -> str:
        nonlocal changed

        filename = match.group(1).strip()
        width = match.group(2)
        source = SOURCE_IMG_ROOT / filename

        if not source.exists():
            missing.add(filename)
            return match.group(0)

        target = STATIC_ROOT / filename
        if filename not in copied:
            compress_and_copy_image(source, target)
            copied.add(filename)

        changed = True
        return render_image_markup(filename, width)

    updated = EMBED_PATTERN.sub(replacer, normalized)
    if changed or updated != original:
        markdown_path.write_text(updated, encoding="utf-8")
        return True

    return False


def main() -> None:
    copied: set[str] = set()
    missing: set[str] = set()
    updated_files: list[Path] = []

    for markdown_path in sorted(CONTENT_ROOT.rglob("*.md")):
        if sync_embeds_in_file(markdown_path, copied, missing):
            updated_files.append(markdown_path)

    print(f"updated_files={len(updated_files)}")
    print(f"copied_images={len(copied)}")
    if missing:
        print(f"missing_images={len(missing)}")
        for name in sorted(missing):
            print(f"MISSING: {name}")


if __name__ == "__main__":
    main()
