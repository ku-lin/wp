---
title: "xxd"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
# xxd

- 原始文档：[xxd.md](../../xxd/)
- 原文使用领域：Misc / Reverse
- 核心用途：十六进制查看/转换工具，可生成 hexdump 或从 hexdump 还原二进制。
- 位置/入口：`未确认到可执行入口`
- 当前状态：未在 Kali PATH/常见目录中找到；文档保留用途和替代建议

## 速查总结
xxd 的核心价值是：十六进制查看/转换工具，可生成 hexdump 或从 hexdump 还原二进制。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
xxd sample.bin | less
```
```bash
xxd -r dump.hex restored.bin
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

