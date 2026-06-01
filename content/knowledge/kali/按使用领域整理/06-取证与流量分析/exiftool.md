---
title: "ExifTool"
draft: false
---
- 原始文档：[libimage-exiftool-perl.md](../../libimage-exiftool-perl/)
- 原文使用领域：Forensics / Misc
- 核心用途：ExifTool 元数据读取/修改工具，常用于图片、PDF、Office、音视频元信息分析。
- 位置/入口：`/usr/bin/exiftool`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
libimage-exiftool-perl 的核心价值是：ExifTool 元数据读取/修改工具，常用于图片、PDF、Office、音视频元信息分析。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
exiftool image.jpg
```
```bash
exiftool -a -u -g1 file.pdf
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

