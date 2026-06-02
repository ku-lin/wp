---
title: "堆利用命令"
lastmod: 2026-05-26T22:20:53+08:00
draft: false
---
## 1. GDB 基础命令

### 启动

```plain
gdb ./pwn
gdb ./pwn -q
gdb -p PID
```

### 运行

```plain
r                # run
r < input.txt    # 带输入运行
start            # 在 main 前停下
starti           # 从第一条指令开始
```

### 断点

```plain
b main           # 在 main 下断
b *0x4011f6      # 在指定地址下断
info b           # 查看断点
delete 1         # 删除编号1的断点
disable 1        # 禁用断点
enable 1         # 启用断点
```

### 单步

```plain
n                # 单步，不进函数
s                # 单步，进函数
ni               # 汇编级单步，不进调用
si               # 汇编级单步，进调用
c                # continue
finish           # 跑到当前函数返回
```

### 查看寄存器

```plain
info registers
i r
p $rax
p/x $rax
```

### 查看内存

```plain
x/10gx 0x404000      # 按8字节十六进制看10个
x/20wx 0x404000      # 按4字节十六进制看20个
x/16bx 0x404000      # 按字节看
x/s 0x404000         # 按字符串看
x/i $rip             # 看当前指令
x/10i $rip           # 看后面10条指令
```

### 打印变量

```plain
p a
p/x a
p &a
ptype a
```

### 栈相关

```plain
bt               # backtrace
f 0              # 切到第0层栈帧
info frame
x/20gx $rsp
```

### 修改数据

```plain
set $rax=0
set {int}0x404040 = 123
set {char[6]}0x404050 = "hello"
```

### 反汇编

```plain
disas main
disas 0x4011a0
```

### 附加/退出

```plain
attach PID
detach
q
```

***

## 2. pwndbg 常用命令

如果你装了 pwndbg，这些特别好用。

### 上下文

```plain
context
ctx
```

会直接显示：

* 寄存器
* 栈
* 汇编
* 回溯

### 堆

```plain
heap
bins
fastbins
tcachebins
unsortedbin
vis
```

常见用途：

* 看 chunk
* 看 tcache / fastbin / unsorted bin
* 看堆布局

### 内存搜索

```plain
search "/bin/sh"
search 0xdeadbeef
```

### 地址辅助

```plain
vmmap
telescope $rsp
tel $rsp
```

`telescope` 看栈特别方便。

### 检查保护

```plain
checksec
```

### libc / got / plt

```plain
got
plt
elfheader
```

### 格式化显示

```plain
hexdump 0x404000 0x100
```

p main\_arena.fastbinsY

set environment GLIBC\_TUNABLES glibc.malloc.tcache\_count=0

只有一个 `libc.so.6` 也可以用，最简单两种方式：

### 方式 1：只让 gdb 找符号

```
set solib-search-path /放libc的目录file ./pwnrun
```

查看是否用了它：

```
info sharedlibrary
```

---

### 方式 2：用环境变量让程序优先加载它

```
LD_PRELOAD=./libc.so.6 gdb ./pwn
```

进 gdb 后：

```
run
```

或：

```
set environment LD_PRELOAD=./libc.so.6run
```

# 堆利用命令
启动时更改启动命令
```
GLIBC_TUNABLES=glibc.malloc.tcache_count=0 gdb -p pwn
```
启动程序，但是没有进入任何程序
```
starti
```
## tcache关闭出错
**1. 判断**

这条命令：

`set environment GLIBC_TUNABLES glibc.malloc.tcache_count=0`

本质是在程序启动前加一个环境变量，作用是：

- 关闭 tcache
- 让小块 free 更可能走 fastbin
- 同时改变程序启动时的 envp 内容和内存布局

所以它适合正常堆题，不适合所有程序。

**2. 关键线索**

常见会出错的情况有这几类：

- 程序依赖启动时的栈/环境布局
- 程序或题目存在反调试/反环境变更逻辑
- 程序在 main 前的初始化代码写得不规范
- 目标 glibc 版本不支持或不完全支持这个 tunable
- 你当前调试的对象已经不是原程序，而是 exec 后的新程序
- 题目本身不是在考 free 路径，你却强行改 allocator 行为
