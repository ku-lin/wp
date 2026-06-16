---
title: "one-gadget"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
# one_gadget

- 原始文档：[one_gadget.md](../../one_gadget/)
- 原文使用领域：Pwn / libc 利用
- 核心用途：结合泄露的 libc 版本快速搜索可触发 execve("/bin/sh") 的 gadget，并整理常用 Pwn 命令流。
- 位置/入口：通常通过 gem 或仓库脚本安装
- 当前状态：文档同时包含 Pwn 常用命令速查

## 速查总结
适合 ret2libc 已经拿到 libc 基址后，快速筛选满足约束条件的 one_gadget。

## 常用示例
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
```bash
chmod +x ./pwn
./pwn
nc host port
socat - TCP:host:port
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

