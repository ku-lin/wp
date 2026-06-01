---
title: "libc-database"
draft: false
---
- 原始文档：[libc-database使用说明.md](../../libc-database使用说明/)
- 原文使用领域：Pwn / libc 匹配
- 核心用途：根据泄露函数地址反查 libc 版本，配合 one_gadget、pwntools 做 ret2libc 利用。
- 位置/入口：/home/kali/tools/libc-database
- 当前状态：已安装，并提供 libcdb 别名

## 速查总结
适合题目只给函数泄露、不提供 libc 文件时快速定位版本。

## 常用示例
```bash
/home/kali/tools/libc-database
```
```bash
libcdb
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

