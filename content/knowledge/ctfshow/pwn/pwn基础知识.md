---
title: "X64栈帧对齐"
lastmod: 2026-04-14T19:49:17+08:00
draft: false
---
## 1) ROP 链为什么不靠“栈帧正确”

ROP 的基本运行机制是：

* 你覆盖返回地址 → `ret` 取栈顶 8 字节到 `RIP`
* 每个 gadget 结束通常也是 `ret` → 再取下一个 8 字节到 `RIP`
* gadget 里如果有 `pop rdi` / `pop rsi` 等，就会“吃掉”栈上的若干个 8 字节

所以只要你栈上摆的顺序和 gadget 的 `pop` 数量匹配，就能一直走下去。这里不依赖 `rbp`、也不依赖“函数栈帧结构”。

***

## 2) 那为什么有时“必须 ret 一下”

真正常见的原因是 **SysV ABI 的栈对齐要求**：

* 在 x86\_64 System V ABI 下，**函数被调用时**通常要求栈在某个时刻满足 **16 字节对齐**（更准确地说：调用点附近有对齐约定，很多 libc 代码/编译器假设它成立）。
* 如果对齐不对，某些函数内部可能使用 `movaps` 这类**要求对齐**的指令，导致崩溃（典型现象：调用 libc 函数时莫名其妙 SIGSEGV）。

在 ROP 中，因为你不是用 `call` 正常进入函数，而是一路 `ret` 跳过去，**栈指针 **<code>**rsp**</code>** 的对齐状态会随着你 pop 了多少个 8 字节而改变**（每 pop 一次，`rsp += 8`，对齐状态会在 0/8 之间切换）。

这时加一个“纯 `ret`”的意义就是：

* 让 `rsp`**再额外 +8**，把对齐从“不合适”切到“合适”，从而避免某些 libc 路径崩。

所以：**“ret 一下”是为了对齐，不是为了栈帧。**

***

## 3) 你这条链里“调用 write@plt”通常不需要额外 ret 的原因

`write@plt` 本质上是一个跳板（plt stub），它最终还是会走到真实 `write`。很多情况下它对栈对齐没那么敏感（或者恰好你当时的 `rsp` 对齐已经是对的），所以看起来“无需再 ret”。

但当你把链改成调用 `system`、或调用某些 libc 内部路径时，就更容易遇到“必须垫 ret”的情况。

***

## 4) 怎么判断自己需不需要“垫 ret”

不讲具体利用操作，只给你判断思路：

* **现象判断**：ROP 能跑到某个 libc 函数入口附近就崩、换不同机器/不同 libc 崩溃位置变动——常见就是对齐问题。
* **原理判断**：看你在跳到目标函数前，链里一共“额外 pop/ret”了多少次（每次 8 字节），它会影响 `rsp % 16`。

ida下载安装地址：<https://www.52pojie.cn/thread-2006802-1-1.html>

## A. 必学底层概念（先把“机制”补齐）

1. **CPU 状态**

* 寄存器：`RIP/RSP/RBP`，通用寄存器 `RAX..R15`（32 位对应 `EIP/ESP/EBP/EAX..`）
* 标志寄存器：`ZF/CF/SF/OF`（影响条件跳转）

1. **内存与地址**

* 小端序（little-endian）
* 指针/地址宽度：32 位 4 字节 vs 64 位 8 字节
* 栈增长方向：向低地址增长

1. **函数调用约定（超级核心）**

* Linux x86-64 SysV：参数 `RDI, RSI, RDX, RCX, R8, R9`；返回 `RAX`
* x86-32 cdecl：参数全在栈上；返回 `EAX`
* 栈对齐（x86-64 常见 16-byte 对齐敏感）

***

## B. 栈与控制流（pwn 的核心骨架）

1. **栈帧长什么样**

* 函数序言/尾声：`push rbp; mov rbp,rsp; sub rsp,xx` / `leave; ret`
* 局部变量、保存寄存器、返回地址分别在哪里

1. **call / ret 的真实动作**

* `call target`：压入返回地址 → 跳转
* `ret`：弹出返回地址到 `RIP`
* 为什么覆盖返回地址能劫持控制流

1. **ROP 的基础思维**

* gadget 是什么（短指令片段以 `ret` 收尾）
* `pop rdi; ret` 的效果：从栈喂参数到寄存器 + 链式跳转
* “链子”就是一连串被 `ret` 弹出来执行的地址

***

## C. 必会的指令类别（见到就要秒懂）

1. **数据搬运**

* `mov`, `lea`（`lea`是算地址/算术，不是内存读取）
* `push/pop`（对栈和寄存器的影响）
* `xchg`（交换）

1. **算术与位运算**

* `add/sub`, `imul`, `idiv`
* `and/or/xor`, `shl/shr`, `rol/ror`
* 常见模式：`xor eax,eax` 清零

1. **比较与跳转**

* `cmp/test`
* 条件跳转：`je/jne/jg/jl/ja/jb`（区分有符号/无符号）
* `jmp`、间接跳转 `jmp rax` / `call [mem]`

1. **字符串/内存操作（了解即可）**

* `rep movsb/stosb` 这类（偶尔在 libc/优化代码里出现）

***

## D. ELF 动态链接（你前面问 puts/system 地址的根源）

1. **ELF 段/节基础**

* `.text/.rodata/.data/.bss`
* 程序基址、PIE、ASLR 的影响

1. **PLT / GOT（必会）**

* `puts@plt` 是“跳板”
* `puts@got` 是“真实地址槽位”
* 第一次调用解析，之后直接跳真实 libc
* RELRO 的意义（GOT 能否改写）

***

## E. 漏洞利用相关的“环境知识”（理解题目为什么这样出）

1. **保护机制**

* NX：栈不可执行 → 更常 ROP
* Canary：栈溢出检测
* PIE/ASLR：地址随机化
* RELRO：GOT 保护强弱

1. **常见信息泄露思路（只理解概念）**

* 为什么要泄露 libc 地址
* 有了泄露如何推算基址（概念层面即可）

***

## F. 你应该达到的“可操作能力”标准

学完上面，你至少要能做到：

* 看到一段函数反汇编，画出**栈布局**（返回地址在哪、局部变量在哪）
* 知道某个调用点：**参数从哪里来、返回到哪里**
* 在 gdb 里能验证：
  * 断在 `system@plt`：`x/s $rdi` 看参数
  * `finish` 后看 `$rax` 知道返回值
* 看到 `lea rax, [rip+...]` 就知道它在取全局/字符串地址（64 位常见 RIP-relative）

***

## 推荐学习路径（最省时间的顺序）

1. **先学栈帧 + call/ret（1 天）**
2. **再学 SysV 调用约定 + 寄存器参数（1 天）**
3. **再学 gadget/ROP 的“寄存器喂参”思想（1 天）**
4. **最后补 PLT/GOT + PIE/ASLR（1–2 天）**

# dbg使用

## 1）最常用的 gdb 启动方式

### 方式 A：直接调可执行文件

```plain
gdb ./a.out
(gdb) run
```

带参数：

```plain
gdb --args ./a.out arg1 arg2
(gdb) run
```

### 方式 B：附加到正在运行的进程

```plain
gdb -p <pid>
```

### 方式 C：调 core dump

```plain
ulimit -c unlimited
./a.out   # 崩了会出 core
gdb ./a.out core
```

***

## 2）断点、单步、查看当前位置（调试基本功）

### 断点

```plain
break main              # 在 main 下断
break *0x40123a         # 在地址下断（逆向常用）
break func_name         # 在函数名下断
info break              # 看断点列表
delete 1                # 删编号为1的断点
disable 1 / enable 1    # 禁用/启用断点
```

### 运行/继续/单步

```plain
run                     # 开始跑
continue (c)            # 继续跑到下个断点
next (n)                # 源码级单步（不进函数）
step (s)                # 源码级单步（进函数）
ni / si                 # 指令级 next/step（逆向常用）
finish                  # 跑完当前函数返回
```

### 看当前在哪

```plain
where / bt              # 调用栈
frame 0 / up / down     # 切换栈帧
list                    # 看源码附近（有符号时）
```

***

## 3）如何“看内存”（你问的重点）

查看内存权限：

```python
vmmap
```

### 3.1 先搞清楚：哪些地址“存在”（映射表）

这是**判断可访问内存**的最关键一步：

```plain
info proc mappings
```

你会看到类似：

* `.text`：r-x
* `.data/.bss`：rw-
* `heap`：rw-
* `stack`：rw-
* `libc.so` 等共享库映射段

只要你的地址落在某一段映射区间里，就“存在”；至于能不能读写执行，看权限位 r/w/x。

（如果你装了 pwndbg/gef，还能用 `vmmap` 更直观。）

***

### 3.2 查看寄存器（找地址来源）

```plain
info registers
p/x $rip
p/x $rsp
p/x $rbp
```

常见：

* **x64**：`$rip` 指令位置，`$rsp` 栈顶
* **x86**：`$eip/$esp/$ebp`

***

### 3.3 用 `x` 命令读内存（最常用）

语法：`x/<数量><格式><单位> 地址`

例子：

```plain
x/16gx $rsp      # 从栈顶开始，看16个8字节(giant word)的十六进制
x/32wx $esp      # 32个4字节（32位常用）
x/64bx 0x404000  # 64个字节
x/s 0x404080     # 按 C 字符串显示
x/i $rip         # 反汇编当前指令
x/20i $rip       # 反汇编20条指令
```

单位速记：

* `b`=1字节，`h`=2字节，`w`=4字节，`g`=8字节\
  格式速记：
* `x`=十六进制，`d`=十进制，`c`=字符，`s`=字符串，`i`=指令

***

### 3.4 看栈、看返回地址、看参数（逆向/漏洞常用）

```plain
x/40gx $rsp      # 看栈内容
bt               # 看函数调用链
info frame       # 看当前栈帧结构
```

你通常会在栈里看到：

* 返回地址（ret）
* 保存的 rbp
* 局部变量
* 传参/临时值

***

### 3.5 监视“谁改了某个内存”（强力）

```plain
watch *(int*)0x404050        # 写监视点：谁写它会停
rwatch *(char*)0x404050      # 读监视点：谁读它会停
awatch *(int*)0x404050       # 读/写都停
```

***

## 4）看反汇编与函数信息（rec2text/逆向很常用）

```plain
disassemble main
disassemble /r main          # 带机器码
info functions               # 列函数（有符号时）
info files                   # 看加载信息
```

如果没符号，你就：

* 断在入口 `_start` 或某个地址
* `x/i $rip` 一路看
* 配合 `info proc mappings` 判断属于哪个段/哪个库

***

## 5）调试时常见“坑”与应对

### ASLR 导致地址变

临时关 ASLR（仅调试）：

```plain
set disable-randomization on
run
```

### PIE 程序地址整体偏移

你看到的静态地址和运行时不一致很正常：要以 `info proc mappings` 的基址为准。

***

## 6）给你一套“最实用的调试模板”

进 gdb 后按这个流程走：

```plain
set disassemble-next-line on
break main
run
info proc mappings
info registers
x/16i $rip
x/32gx $rsp
bt
```

然后你想追某个地址：

* 先确认它在 mappings 里
* 再用 `x/..` 看内容

