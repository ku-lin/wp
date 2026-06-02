---
title: "seccomp-tools 使用说明"
lastmod: 2026-04-05T17:04:49+08:00
draft: false
---
这份 README 介绍的是 `seccomp-tools` 这个工具本身，和当前目录下的题目无关。

`seccomp-tools` 是一个专门用来分析 Linux `seccomp-bpf` 过滤器的命令行工具，常用于：

- 分析程序实际安装了什么 seccomp 规则
- 把原始 BPF 过滤器反汇编成人类可读格式
- 自己编写 seccomp 规则并组装成 BPF
- 模拟某个 syscall 在过滤器下会返回什么结果

这个工具对 CTF pwn、沙箱分析、Linux 安全研究都很实用。

当前文档基于：

- 官方仓库 `david942j/seccomp-tools`
- 实机验证的 `seccomp-tools 1.6.2`
- Kali GNU/Linux Rolling 2026.1

## 1. 功能概览

`seccomp-tools` 主要有 4 个子命令：

- `dump`：从正在执行的程序或现有进程里提取 seccomp 过滤器
- `disasm`：把 BPF 规则反汇编成可读形式
- `asm`：把文本形式的 seccomp 规则组装成 BPF
- `emu`：模拟指定 syscall 在规则下的执行结果

一句话理解：

- `dump` 负责“拿到规则”
- `disasm` 负责“看懂规则”
- `asm` 负责“写出规则”
- `emu` 负责“验证规则”

## 2. 安装

### 2.1 RubyGems 安装

官方最常见的安装方式是：

```bash
gem install seccomp-tools
```

如果你是普通用户，也可以安装到用户目录：

```bash
gem install --user-install seccomp-tools
```

### 2.2 Kali / Debian 常见依赖

如果安装时编译原生扩展失败，可以先补齐依赖：

```bash
sudo apt update
sudo apt install -y gcc ruby ruby-dev make
```

然后重新安装：

```bash
gem install seccomp-tools
```

### 2.3 验证是否安装成功

```bash
seccomp-tools --version
seccomp-tools --help
```

实机验证的版本输出为：

```text
SeccompTools Version 1.6.2
```

## 3. 命令总览

```bash
seccomp-tools --help
```

常见输出结构是：

```text
asm     Seccomp bpf assembler.
disasm  Disassemble seccomp bpf.
dump    Automatically dump seccomp bpf from execution file(s).
emu     Emulate seccomp rules.
```

## 4. dump：提取 seccomp 规则

### 4.1 最常用的场景

如果一个二进制在运行时调用了 `prctl(PR_SET_SECCOMP, ...)` 或 `seccomp(...)` 安装过滤器，就可以这样直接提取：

```bash
seccomp-tools dump ./pwn
```

这条命令会启动程序，并在它安装 seccomp 规则时把 BPF 过滤器抓出来，然后以可读形式打印。

### 4.2 带参数运行目标程序

如果目标程序需要参数、重定向、管道，使用 `-c` 更方便：

```bash
seccomp-tools dump -c "./server arg1 arg2"
seccomp-tools dump -c "./pwn < input.txt > /dev/null"
```

`-c` 的本质是通过 `sh` 执行一条完整命令，所以适合复杂启动方式。

### 4.3 指定输出格式

```bash
seccomp-tools dump ./pwn -f disasm
seccomp-tools dump ./pwn -f raw
seccomp-tools dump ./pwn -f inspect
```

常见理解：

- `disasm`：最适合人直接阅读
- `raw`：原始 BPF 数据，更适合后续保存和再处理
- `inspect`：介于原始数据和可读展示之间，适合观察结构

### 4.4 输出到文件

```bash
seccomp-tools dump ./pwn -f raw -o filter.bpf
```

如果程序安装了多次 seccomp 规则，输出文件会自动变成：

- `filter.bpf`
- `filter_1.bpf`
- `filter_2.bpf`

### 4.5 从现有进程提取

```bash
sudo seccomp-tools dump -p 1234
```

这个模式用于分析已经在运行的进程。

注意：

- 一般需要足够权限
- 官方帮助里明确说明通常需要 `CAP_SYS_ADMIN`
- 也就是最常见情况要 `root` 或 `sudo`

### 4.6 dump 的几个重点参数

```bash
seccomp-tools dump --help
```

重点参数如下：

- `-c, --sh-exec <command>`：通过 `sh` 执行命令
- `-f, --format FORMAT`：输出格式，支持 `disasm`、`raw`、`inspect`
- `-l, --limit LIMIT`：限制抓取第几次 seccomp 安装
- `-o, --output FILE`：输出到文件
- `-p, --pid PID`：从现有进程提取

### 4.7 `-l` 的实际意义

有些程序会多次调用 seccomp 安装规则，这时：

```bash
seccomp-tools dump ./target -l 2
```

表示允许目标进程安装到第 2 次 seccomp 时再停止并导出结果。分析复杂沙箱时这个参数很有用。

### 4.8 重要限制

`dump` 只能在 Linux 上使用。

如果你现在是在 Windows 主机上做题，最稳妥的方法通常是：

- 在 Kali / Ubuntu / Debian 上直接运行
- 用 WSL 运行
- 连到远端 Linux 机器执行

## 5. disasm：反汇编 BPF 规则

如果你已经拿到了 `.bpf` 文件，可以直接反汇编：

```bash
seccomp-tools disasm filter.bpf
```

也可以从标准输入读取：

```bash
cat filter.bpf | seccomp-tools disasm -
```

### 5.1 典型输出长什么样

你会看到类似：

```text
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000004  A = arch
 0001: 0x15 0x00 0x08 0xc000003e  if (A != ARCH_X86_64) goto 0010
 0002: 0x20 0x00 0x00 0x00000000  A = sys_number
 ...
```

可以这样理解：

- 左边是原始 BPF 指令字段
- 右边是工具帮你翻译后的语义
- `A = arch`、`A = sys_number` 这些属于 seccomp 过滤器常见读取动作
- `return ALLOW`、`return KILL`、`return ERRNO(x)` 是最终动作

### 5.2 常用参数

```bash
seccomp-tools disasm --help
```

常用参数：

- `-o, --output FILE`：写入文件
- `-a, --arch ARCH`：指定架构
- `--no-bpf`：不显示左侧原始 BPF 字节
- `--no-arg-infer`：不自动推断 syscall 参数含义
- `--asm-able`：输出可直接喂给 `seccomp-tools asm` 的格式

### 5.3 `--asm-able` 很实用

```bash
seccomp-tools disasm filter.bpf --asm-able
```

这个模式适合做“反汇编 -> 修改 -> 再组装”的工作流。常见组合如下：

```bash
seccomp-tools disasm filter.bpf --asm-able > filter.asm
seccomp-tools asm filter.asm -f raw > new_filter.bpf
seccomp-tools disasm new_filter.bpf
```

## 6. asm：编写并组装 seccomp 规则

`asm` 可以把文本形式的 seccomp 规则转换成 BPF。

最简单的用法：

```bash
seccomp-tools asm policy.asm
```

### 6.1 输出格式

```bash
seccomp-tools asm policy.asm -f inspect
seccomp-tools asm policy.asm -f raw
seccomp-tools asm policy.asm -f c_array
seccomp-tools asm policy.asm -f c_source
seccomp-tools asm policy.asm -f assembly
```

含义可以这么记：

- `inspect`：适合看
- `raw`：适合保存原始 BPF
- `c_array`：生成 C 数组
- `c_source`：直接生成可嵌入程序的 C 代码
- `assembly`：输出规范化后的汇编形式

### 6.2 一个最小示例

下面这段规则表示：只允许 `read` 和 `write`，其余全部 `KILL`。

```text
A = arch
if (A != ARCH_X86_64) goto kill
A = sys_number
if (A == read) goto allow
if (A == write) goto allow
kill:
return KILL
allow:
return ALLOW
```

保存为 `policy.asm` 后可以这样处理：

```bash
seccomp-tools asm policy.asm -f raw > policy.bpf
seccomp-tools disasm policy.bpf
```

### 6.3 常用场景

- 自己手写一个 seccomp 过滤器
- 把 `disasm --asm-able` 的结果改一改再编回去
- 导出 `c_source` 给测试程序直接嵌入

## 7. emu：模拟 syscall 是否会被放行

`emu` 可以模拟某个 syscall 在指定 seccomp 规则下的结果。

比如：

```bash
seccomp-tools emu filter.bpf write
```

或者指定参数：

```bash
seccomp-tools emu filter.bpf open 0x123000 0 0 0 0 0
```

### 7.1 常用参数

```bash
seccomp-tools emu --help
```

常用项：

- `-a, --arch ARCH`：指定架构
- `-q, --quiet`：安静模式，只看结果
- `-i, --ip=VAL`：指定 instruction pointer

### 7.2 为什么 emu 有用

很多 seccomp 规则不是简单地按 syscall 名放行，而是还会判断：

- 参数值
- 架构
- 指令指针
- x32 syscall 编号

这时只看 `disasm` 还不够，`emu` 可以快速验证某个 syscall 调用到底会不会过。

## 8. 常见分析流程

### 8.1 分析一个二进制的 seccomp

```bash
seccomp-tools dump ./target
```

如果需要保存原始规则：

```bash
seccomp-tools dump ./target -f raw -o filter.bpf
seccomp-tools disasm filter.bpf
```

### 8.2 反汇编后修改规则

```bash
seccomp-tools disasm filter.bpf --asm-able > filter.asm
```

编辑 `filter.asm` 后：

```bash
seccomp-tools asm filter.asm -f raw > new_filter.bpf
seccomp-tools disasm new_filter.bpf
```

### 8.3 验证某个 syscall 会不会被拦

```bash
seccomp-tools emu new_filter.bpf execve
seccomp-tools emu new_filter.bpf openat
seccomp-tools emu new_filter.bpf read
```

## 9. 常见问题

### 9.1 `seccomp-tools: command not found`

先确认 RubyGems 可执行目录是否在 `PATH` 里：

```bash
gem env
```

用户级安装时，常见需要把类似目录加进 `PATH`：

```bash
export PATH="$HOME/.local/share/gem/ruby/bin:$PATH"
```

不同发行版和 Ruby 版本路径可能不同，以 `gem env` 输出为准。

### 9.2 安装时报原生扩展编译失败

先补这些依赖再重装：

```bash
sudo apt install -y gcc ruby-dev make
gem install seccomp-tools
```

### 9.3 `dump` 在 Windows 上不能直接用

这是正常的，因为 `dump` 依赖 Linux 环境。

解决方式：

- 在 Kali / Ubuntu 上执行
- 用 WSL
- 远程连到 Linux 主机执行

### 9.4 目标程序一下就退出，抓不到规则

优先尝试：

- 用 `-c` 包装完整启动命令
- 调整 `-l` 捕获第 2 次或更多次 seccomp 安装
- 改用 `-p` 对已经跑起来的进程抓取

### 9.5 输出里出现 x32 或架构不对

手动指定架构：

```bash
seccomp-tools disasm filter.bpf -a amd64
seccomp-tools disasm filter.bpf -a i386
seccomp-tools emu filter.bpf -a amd64 read
```

## 10. 适合什么场景

这个工具尤其适合下面几类工作：

- CTF pwn 题里的 seccomp 沙箱分析
- 逆向程序时快速确认允许哪些 syscall
- 学习 seccomp-bpf 的执行模型
- 自己构造和测试 seccomp 规则
- 把规则导出成更容易理解和复用的格式

## 11. 一个最实用的最小备忘单

安装：

```bash
gem install seccomp-tools
```

看帮助：

```bash
seccomp-tools --help
```

提取规则：

```bash
seccomp-tools dump ./pwn
```

导出原始 BPF：

```bash
seccomp-tools dump ./pwn -f raw -o filter.bpf
```

反汇编：

```bash
seccomp-tools disasm filter.bpf
```

导出成可重新组装的格式：

```bash
seccomp-tools disasm filter.bpf --asm-able > filter.asm
```

重新组装：

```bash
seccomp-tools asm filter.asm -f raw > new_filter.bpf
```

模拟 syscall：

```bash
seccomp-tools emu new_filter.bpf read
seccomp-tools emu new_filter.bpf execve
```

## 12. 参考链接

- 官方仓库：https://github.com/david942j/seccomp-tools
- RubyGems：https://rubygems.org/gems/seccomp-tools
- libseccomp：https://github.com/seccomp/libseccomp

如果你后面想要，我也可以继续把这个 README 改成更偏：

- CTF 选手速查版
- 逆向分析版
- Kali 环境安装版
- 中英双语版

