---
title: "objdump"
draft: false
---
- 原始文档：[objdump.md](../../objdump/)
- 原文使用领域：Pwn / Reverse
- 核心用途：二进制反汇编、节表/符号/重定位查看。
- 位置/入口：`/usr/bin/objdump`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
objdump 的核心价值是：二进制反汇编、节表/符号/重定位查看。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
objdump -d ./chall | less
```
```bash
objdump -R ./chall
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

