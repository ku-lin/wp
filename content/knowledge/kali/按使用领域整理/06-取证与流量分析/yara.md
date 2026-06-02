---
title: "YARA"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
- 原始文档：[yara.md](../../yara/)
- 原文使用领域：Forensics / Malware
- 核心用途：规则匹配工具，按字符串/十六进制/条件扫描文件和样本。
- 位置/入口：`/usr/bin/yara`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
yara 的核心价值是：规则匹配工具，按字符串/十六进制/条件扫描文件和样本。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
yara rule.yar sample.bin
```
```bash
yara -r rules/ samples/
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

