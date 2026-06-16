---
title: "pwntools"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
# pwntools

- 原始文档：[python3-pwntools.md](../../python3-pwntools/)
- 原文使用领域：Pwn
- 核心用途：pwntools 命令行入口和 Python 库，用于 exploit 交互、ROP、shellcode、ELF 分析。
- 位置/入口：`/usr/bin/pwn`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
python3-pwntools 的核心价值是：pwntools 命令行入口和 Python 库，用于 exploit 交互、ROP、shellcode、ELF 分析。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
pwn checksec ./chall
```
```bash
pwn cyclic 200
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

