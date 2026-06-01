---
title: "readelf"
draft: false
---
- 原始文档：[readelf.md](../../readelf/)
- 原文使用领域：Pwn / Reverse
- 核心用途：查看 ELF 头、段、节、符号、重定位、动态链接信息。
- 位置/入口：`/usr/bin/readelf`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
readelf 的核心价值是：查看 ELF 头、段、节、符号、重定位、动态链接信息。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
readelf -h ./chall
```
```bash
readelf -Ws ./chall | grep system
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

