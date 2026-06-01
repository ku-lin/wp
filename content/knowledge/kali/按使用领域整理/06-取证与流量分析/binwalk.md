---
title: "binwalk"
draft: false
---
- 原始文档：[binwalk.md](../../binwalk/)
- 原文使用领域：Forensics / Misc / Firmware
- 核心用途：固件与二进制 blob 扫描、识别内嵌文件、自动提取压缩包和文件系统。
- 位置/入口：`/usr/bin/binwalk`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
binwalk 的核心价值是：固件与二进制 blob 扫描、识别内嵌文件、自动提取压缩包和文件系统。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
binwalk firmware.bin
```
```bash
binwalk -eM firmware.bin
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

