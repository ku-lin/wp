---
title: "ROPgadget 中文 README"
draft: false
---
这是一份面向 CTF/Pwn 初学者和进阶选手的 `ROPgadget` 中文说明文档，兼顾命令参考与实战思路。

本文基于本机已安装的 `ROPgadget 7.7` 帮助输出整理，同时参考官方项目页与 PyPI 页面。适合用来快速上手：

- 在二进制中搜索 `ret`、`pop rdi ; ret`、`syscall ; ret` 等 gadget
- 过滤坏字节地址
- 为 ROP、JOP、SROP、ret2syscall、ret2libc 利用链找材料
- 在 ELF / PE / Mach-O / Raw 文件中做 gadget 检索

## 1. ROPgadget 是什么

`ROPgadget` 是一个用来在可执行文件里搜索可利用指令片段的工具。它会在程序的可执行段中寻找能够以 `ret`、`jmp`、`call`、`syscall` 等方式结束或转移控制流的短指令序列，这些序列通常被称为 gadget。

在 Pwn 里，常见用途包括：

- 找 `pop rdi ; ret`、`pop rsi ; pop r15 ; ret` 之类的参数控制 gadget
- 找 `syscall ; ret`、`int 0x80` 一类系统调用 gadget
- 找 `jmp rsp`、`call rsp`、`jmp esp` 一类栈跳转 gadget
- 找字符串如 `"/bin/sh"` 或某些内存中的关键字
- 在 libc、程序本体、动态链接器中构建 ret2libc / ret2syscall / ORW 链

一句话理解：

`ROPgadget` 不是替你自动利用，而是帮你从二进制里挖出可拼装利用链的“零件”。

## 2. 支持情况

根据官方帮助和项目说明，`ROPgadget` 支持：

### 文件格式

- ELF
- PE
- Mach-O
- Raw

### 架构

- x86
- x86-64
- ARM
- ARM64
- MIPS
- PowerPC
- Sparc
- RISC-V 64
- RISC-V Compressed

## 3. 安装

最常见的安装方式是通过 `pip`：

```bash
pip install ROPGadget
```

如果你已经安装了 `pwntools`，通常也会顺带安装 `ROPGadget` 依赖。

查看版本：

```bash
ROPgadget --version
```

如果是在某些 Windows 环境下，直接敲 `ROPgadget` 可能找不到可执行入口，可以这样调用：

```powershell
python path\to\Scripts\ROPgadget --help
```

例如本机环境中：

```powershell
C:\Users\zuziyi\venvs\pwn311\Scripts\python.exe C:\Users\zuziyi\venvs\pwn311\Scripts\ROPgadget --help
```

## 4. 最基本的用法

分析一个二进制最基本的命令：

```bash
ROPgadget --binary ./pwn
```

它会扫描程序的可执行区域，并输出找到的 gadget 列表。

最常见的工作流通常是：

1. 先用 `checksec` 看保护
2. 再用 `ROPgadget --binary` 大致扫一遍
3. 用 `--only`、`--filter`、`--range` 缩小范围
4. 把候选 gadget 带回 `gdb` 或 `pwntools` 里验证

## 5. 常用参数详解

下面这部分以本机 `ROPgadget 7.7` 的帮助输出为准。

### 5.1 `--binary <binary>`

指定要分析的二进制文件。

```bash
ROPgadget --binary ./pwn
ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6
```

这是最核心的参数，几乎所有场景都会配合它使用。

### 5.2 `--depth <nbyte>`

设置搜索深度，默认是 `10`。一般可以理解为允许工具向前回溯更多字节去组合更长的 gadget。

```bash
ROPgadget --binary ./pwn --depth 5
ROPgadget --binary ./pwn --depth 15
```

经验上：

- 深度小：结果更少，更干净
- 深度大：能挖出更长 gadget，但噪声更多

常见范围：

- `5` 到 `8`：适合快速找短 gadget
- `10` 到 `15`：适合找复杂寄存器控制链

### 5.3 `--only <key>`

只显示包含特定指令类别的 gadget。多个关键字通常用 `|` 分隔。

```bash
ROPgadget --binary ./pwn --only "pop|ret"
ROPgadget --binary ./pwn --only "mov|pop|xor|ret"
ROPgadget --binary ./pwn --only "syscall|ret"
```

这是实战里最常用的过滤方式之一，适合快速找：

- 参数控制：`pop|ret`
- 系统调用：`syscall|ret`
- 栈迁移：`leave|ret`

### 5.4 `--filter <key>`

过滤掉包含某些不想要指令的 gadget。

```bash
ROPgadget --binary ./pwn --filter "xchg|add|sub|cmov.*"
```

用途：

- 去掉副作用太多的 gadget
- 去掉会破坏关键寄存器的 gadget
- 保留更“干净”的候选项

很适合配合 `--only` 一起用。

### 5.5 `--range <start-end>`

只在指定地址区间内搜索 gadget。

```bash
ROPgadget --binary ./pwn --range 0x400000-0x401000
```

适合以下场景：

- 只搜 `.text` 某一段
- 只搜主程序，不搜其它段
- 已知某些区间更稳定，优先在那里找 gadget

### 5.6 `--badbytes <byte>`

排除地址中包含坏字节的 gadget。

```bash
ROPgadget --binary ./pwn --badbytes "00"
ROPgadget --binary ./pwn --badbytes "00|0a|0d"
ROPgadget --binary ./pwn --badbytes "00|01-1f|7f"
```

这在以下题型很重要：

- 字符串读入会被 `\x00` 截断
- `gets` / `scanf("%s")` / 行输入不接受 `\x0a`
- 网络协议过滤某些字节

注意：

这里过滤的是 gadget 的“地址字节”，不是 gadget 指令本身的机器码。

### 5.7 `--opcode <opcodes>`

按机器码搜索指令片段。

```bash
ROPgadget --binary ./pwn --opcode c3
ROPgadget --binary ./pwn --opcode 0f05
```

典型用途：

- 搜索 `ret` 的机器码 `c3`
- 搜索 `syscall` 的机器码 `0f05`
- 搜索某些手工确认过的字节模式

### 5.8 `--string <string>`

在可读段中搜索字符串。

```bash
ROPgadget --binary ./pwn --string "/bin/sh"
ROPgadget --binary ./pwn --string "flag"
```

常见用途：

- 找 `"/bin/sh"`
- 找错误提示、格式化字符串、敏感路径
- 为 ret2libc 或 ORW 提供参数地址

### 5.9 `--memstr <string>`

按字节在可读段中检索字符串内容。

```bash
ROPgadget --binary ./pwn --memstr "/bin/sh"
```

通常比 `--string` 更偏“按原始内存内容匹配”，适合补充搜索。

### 5.10 `--re <re>`

用正则表达式过滤 gadget。

```bash
ROPgadget --binary ./pwn --re "pop (rdi|rsi)"
```

适合更精细的筛选，但上手门槛比 `--only` 高一些。

### 5.11 `--offset <hexaddr>`

给输出地址整体加一个偏移。

```bash
ROPgadget --binary ./libc.so.6 --offset 0x7ffff7d00000
```

很适合 ASLR / libc 基址已知的情况。比如你已经泄露出了 libc 基址，可以直接让工具输出“运行时地址”，减少手算。

### 5.12 `--ropchain`

尝试自动生成一条 ROP 利用链。

```bash
ROPgadget --binary ./pwn --ropchain
```

注意：

- 它更像“辅助生成器”，不是万能 exp 生成器
- 对简单场景有参考价值
- 对复杂题目、栈对齐、寄存器副作用、沙箱限制等情况往往仍需手工调整

建议把它当作“灵感来源”，不要当作最终答案。

### 5.13 `--console`

进入交互式控制台。

```bash
ROPgadget --binary ./pwn --console
```

适合在一轮扫描后，边看边筛。

### 5.14 `--norop`、`--nojop`、`--nosys`

分别关闭某一类搜索引擎：

- `--norop`：不找 ROP gadget
- `--nojop`：不找 JOP gadget
- `--nosys`：不找 syscall gadget

例如：

```bash
ROPgadget --binary ./pwn --norop --nosys
```

这能减少无关结果，加快定位。

### 5.15 `--callPreceded`

只显示前面紧邻 `call` 的 gadget。

这个选项在一些更讲究控制流上下文的利用场景里会有用，但日常 CTF 中使用频率没有 `--only`、`--filter` 那么高。

### 5.16 `--multibr`

启用多分支 gadget 搜索。

一般只有在做更复杂的控制流利用时才会特别关注。

### 5.17 `--all`

关闭重复 gadget 去重。

```bash
ROPgadget --binary ./pwn --all
```

默认情况下工具会去掉重复结果。加上这个选项后，能看到所有命中项，适合确认某个 gadget 在不同位置是否都存在。

### 5.18 `--dump`

输出 gadget 对应的字节。

```bash
ROPgadget --binary ./pwn --only "syscall|ret" --dump
```

适合做二次确认，尤其是你怀疑反汇编结果和实际编码不一致的时候。

### 5.19 `--silent`

扫描时尽量减少中间输出，只保留必要信息。

适合脚本化或重定向输出时使用。

### 5.20 `--align ALIGN`

限制 gadget 地址按某个字节数对齐。

这个参数在某些严格对齐的平台或手工筛选场景下有帮助，但在常规 x86_64 CTF 里使用频率不高。

### 5.21 `--rawArch`、`--rawMode`、`--rawEndian`

分析裸二进制时使用。

例如：

```bash
ROPgadget --binary ./firmware.bin --rawArch arm --rawMode thumb --rawEndian little
```

如果文件不是标准 ELF/PE/Mach-O，而是原始固件片段或内存 dump，这组参数就很重要。

### 5.22 `--thumb`

ARM 专用，启用 Thumb 模式搜索。

### 5.23 `--mipsrop <rtype>`

MIPS 相关的实用 gadget 搜索器。帮助输出里给出的类型包括：

- `stackfinder`
- `system`
- `tails`
- `lia0`
- `registers`

如果你不打 MIPS，这个选项可以先忽略。

## 6. 输出怎么看

典型输出大致长这样：

```text
0x00000000004012ab : pop rdi ; ret
0x0000000000401016 : ret
0x00000000004011f3 : syscall ; ret
```

含义分别是：

- 左边：gadget 地址
- 右边：该地址开始反汇编出来的短指令序列

在利用里你关心的通常是：

- 地址是否可达
- 地址是否包含坏字节
- 指令副作用是否可接受
- 是否满足当前调用约定
- 是否需要额外的栈对齐

## 7. CTF 中最常见的检索套路

### 7.1 找参数控制 gadget

64 位 Linux 下常找：

```bash
ROPgadget --binary ./pwn --only "pop|ret"
```

重点关注：

- `pop rdi ; ret`
- `pop rsi ; ret`
- `pop rdx ; ret`
- `pop rax ; ret`

如果没有非常理想的 gadget，也可以接受：

- `pop rsi ; pop r15 ; ret`
- `pop rdx ; pop rbx ; ret`

这种就需要多补几个占位值。

### 7.2 找 `syscall ; ret`

```bash
ROPgadget --binary ./pwn --only "syscall|ret"
```

适合：

- ret2syscall
- seccomp 题
- ORW
- SROP 辅助

### 7.3 找栈迁移 gadget

```bash
ROPgadget --binary ./pwn --only "leave|ret"
ROPgadget --binary ./pwn --re "xchg rsp,.*"
```

常见场景：

- 栈空间不够
- 想把栈 pivot 到 `.bss`、堆、`mmap` 区
- 程序读入点和最终利用空间分离

### 7.4 找跳栈 gadget

```bash
ROPgadget --binary ./pwn --re "jmp rsp"
ROPgadget --binary ./pwn --re "call rsp"
```

32 位时则常见：

```bash
ROPgadget --binary ./pwn --re "jmp esp"
```

这类 gadget 常用于：

- shellcode 落在栈上
- 已知 `rsp/esp` 可控
- 需要快速把执行流转到当前栈顶

### 7.5 找 `"/bin/sh"`

```bash
ROPgadget --binary ./pwn --string "/bin/sh"
ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 --string "/bin/sh"
```

ret2libc 中非常常见。

## 8. 实战示例

### 示例 1：找 `pop rdi ; ret`

```bash
ROPgadget --binary ./pwn --only "pop|ret" | grep "pop rdi"
```

Windows PowerShell 下可以换成：

```powershell
python path\to\ROPgadget --binary .\pwn --only "pop|ret" | Select-String "pop rdi"
```

### 示例 2：找 `syscall ; ret`

```bash
ROPgadget --binary ./pwn --only "syscall|ret"
```

### 示例 3：排除坏字节

```bash
ROPgadget --binary ./pwn --only "pop|ret" --badbytes "00|0a"
```

### 示例 4：已知 libc 基址后直接输出真实地址

```bash
ROPgadget --binary ./libc.so.6 --only "pop|ret" --offset 0x7ffff7dcf000
```

### 示例 5：缩小搜索范围

```bash
ROPgadget --binary ./pwn --range 0x400000-0x401000 --only "pop|ret"
```

## 9. 和 pwntools 配合怎么用

常见搭配流程：

1. 用 `ELF()` 拿程序符号、GOT、PLT
2. 用 `ROPgadget` 找手工需要的 gadget
3. 在 `pwntools` 里把地址拼成 payload

例如：

```python
from pwn import *

elf = ELF("./pwn")

pop_rdi = 0x4012ab
ret = 0x401016
bin_sh = next(elf.search(b"/bin/sh"))
system = elf.plt["system"]

payload = flat(
    b"A" * offset,
    ret,
    pop_rdi,
    bin_sh,
    system,
)
```

说明：

- `ROPgadget` 负责找 gadget 地址
- `pwntools` 负责生成利用载荷

这两个工具往往是配套使用的。

## 10. 和 gdb 配合怎么验证

不要因为 `ROPgadget` 找到了某个结果，就直接默认它一定能用。实战中最好验证以下几点：

- 地址是否真的落在可执行段
- 反汇编是否与你预期一致
- 前置指令是否带来副作用
- gadget 执行后栈顶是否还可控
- 栈对齐是否满足 16 字节要求

可以在 `gdb` 里这样确认：

```gdb
x/10i 0x4012ab
```

或者：

```gdb
disas 0x4012ab, 0x4012c0
```

## 11. 常见误区

### 误区 1：找到 `pop rdi ; ret` 就一定能利用

不一定。你还需要确认：

- `rdi` 是不是这个调用的第一个参数
- 后续函数是否受栈对齐影响
- 其它寄存器是否也要控制

### 误区 2：工具自动生成的 `--ropchain` 一定可用

不一定。自动生成结果通常需要你自己根据：

- libc 版本
- 保护机制
- 输入限制
- 栈对齐
- one_gadget 约束

去手工修正。

### 误区 3：gadget 越长越好

不一定。长 gadget 往往副作用更多。大多数时候越短越干净越好。

### 误区 4：只看指令，不看地址

如果地址中有 `\x00`、`\x0a` 等坏字节，payload 可能根本发不进去。

### 误区 5：忽略栈对齐

很多 64 位题里需要额外补一个单独的 `ret`，不然调用某些 libc 函数会崩。

## 12. Windows 下的注意事项

如果你在 Windows 上做 Linux Pwn，有几个现实问题要注意：

- `ROPgadget` 本身是 Python 工具，通常能跑
- 但配套的 `gdb`、`patchelf`、`one_gadget`、`checksec`、`pwndbg` 往往更适合在 WSL / Linux 下使用
- 某些脚本入口在 PowerShell、`cmd`、虚拟环境之间的行为不完全一致

实战建议：

- 纯搜索 gadget：Windows 上可用
- 完整 Pwn 工作流：优先用 WSL / Ubuntu

## 13. 一组够用的速查命令

### 全量扫

```bash
ROPgadget --binary ./pwn
```

### 找 `pop` 链

```bash
ROPgadget --binary ./pwn --only "pop|ret"
```

### 找 `syscall ; ret`

```bash
ROPgadget --binary ./pwn --only "syscall|ret"
```

### 找 `leave ; ret`

```bash
ROPgadget --binary ./pwn --only "leave|ret"
```

### 找 `jmp rsp`

```bash
ROPgadget --binary ./pwn --re "jmp rsp"
```

### 找 `"/bin/sh"`

```bash
ROPgadget --binary ./pwn --string "/bin/sh"
```

### 过滤坏字节

```bash
ROPgadget --binary ./pwn --only "pop|ret" --badbytes "00|0a"
```

### libc 基址已知后输出真实地址

```bash
ROPgadget --binary ./libc.so.6 --only "pop|ret" --offset 0x7ffff7dcf000
```

## 14. 什么时候该用 ROPgadget，什么时候不该过度依赖

适合用 `ROPgadget` 的时候：

- 你明确知道自己要找什么 gadget
- 你在构造 ret2libc / ret2syscall / ORW / stack pivot
- 你需要快速枚举某类候选项

不该过度依赖的时候：

- 你完全没理解调用约定和漏洞点
- 你只想“自动生成 payload”
- 你没有在调试器里验证 gadget 副作用

更稳妥的思路是：

`先理解漏洞 -> 再明确目标寄存器/控制流 -> 最后用 ROPgadget 找零件`

## 15. 参考链接

- 官方项目：<https://github.com/JonathanSalwan/ROPgadget>
- PyPI：<https://pypi.org/project/ROPGadget/>

## 16. 本文核对信息

本文整理时核对到的信息如下：

- 本机安装版本：`ROPGadget 7.7`
- PyPI 页面显示的 `7.7` 发布时间：`2025-10-15`
- 本机帮助输出中支持的格式：`ELF / PE / Mach-O / Raw`
- 本机帮助输出中支持的架构：`x86 / x86-64 / ARM / ARM64 / MIPS / PowerPC / Sparc / RISC-V 64 / RISC-V Compressed`

如果你之后想继续扩展，我建议把下一份文档写成：

- `ROPgadget + pwntools 联动实战`
- `ret2libc 常见 gadget 模板`
- `栈迁移 gadget 专题`


