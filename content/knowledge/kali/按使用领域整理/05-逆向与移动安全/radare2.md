---
title: "radare2"
draft: false
---
- 原始文档：[radare2.md](../../radare2/)
- 原文使用领域：Reverse / Pwn
- 核心用途：命令行逆向框架，可做反汇编、调试、patch、脚本分析。
- 位置/入口：`/usr/bin/radare2`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
radare2 的核心价值是：命令行逆向框架，可做反汇编、调试、patch、脚本分析。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
r2 -A ./chall
```
```bash
r2 -d ./chall
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

