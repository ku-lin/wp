---
title: "patchelf"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
- 原始文档：[patchelf.md](../../patchelf/)
- 原文使用领域：Pwn
- 核心用途：修改 ELF interpreter、RPATH/RUNPATH、依赖库等，常用于指定题目 libc。
- 位置/入口：`/usr/bin/patchelf`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
patchelf 的核心价值是：修改 ELF interpreter、RPATH/RUNPATH、依赖库等，常用于指定题目 libc。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
patchelf --print-interpreter ./chall
```
```bash
patchelf --set-interpreter ./ld-linux-x86-64.so.2 ./chall
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

