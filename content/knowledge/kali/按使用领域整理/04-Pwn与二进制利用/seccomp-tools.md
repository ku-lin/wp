---
title: "seccomp-tools"
draft: false
---
- 原始文档：[seccomp-tools.md](../../seccomp-tools/)
- 原文使用领域：Pwn / 沙箱
- 核心用途：分析、反汇编、模拟 seccomp-bpf 规则，判断系统调用限制。
- 位置/入口：`/usr/local/bin/seccomp-tools`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
seccomp-tools 的核心价值是：分析、反汇编、模拟 seccomp-bpf 规则，判断系统调用限制。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
seccomp-tools dump ./chall
```
```bash
seccomp-tools disasm filter.bpf
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

