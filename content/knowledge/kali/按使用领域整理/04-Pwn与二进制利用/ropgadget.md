---
title: "ROPgadget"
draft: false
---
- 原始文档：[ROPgadget 1.md](../../ROPgadget 1/)
- 原文使用领域：Pwn / ROP
- 核心用途：在 ELF/PE/Mach-O/Raw 中搜索 ret、syscall、jmp 等 gadget，为 ROP 链拼装零件。
- 位置/入口：/usr/bin/ROPgadget
- 当前状态：文档为中文速查版

## 速查总结
重点是搜索参数控制 gadget、系统调用 gadget 和关键字符串地址。

## 常用示例
```bash
pip install ROPGadget
```
```bash
ROPgadget --version
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

