---
title: "strings"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
# strings

- 原始文档：[strings.md](../../strings/)
- 原文使用领域：Reverse / Forensics / Misc
- 核心用途：从二进制中提取可打印字符串，快速找 flag、URL、密钥、调试信息。
- 位置/入口：`/usr/bin/strings`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
strings 的核心价值是：从二进制中提取可打印字符串，快速找 flag、URL、密钥、调试信息。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
strings -a sample.bin | less
```
```bash
strings -tx ./chall | grep flag
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

