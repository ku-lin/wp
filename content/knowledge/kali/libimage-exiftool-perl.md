---
title: "libimage-exiftool-perl"
lastmod: 2026-04-12T00:37:25+08:00
draft: false
---
# libimage-exiftool-perl

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Forensics / Misc
- 主要用途：ExifTool 元数据读取/修改工具，常用于图片、PDF、Office、音视频元信息分析。
- 工具位置：`/usr/bin/exiftool`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/libimage-exiftool-perl.md`

## 比赛中怎么用

libimage-exiftool-perl 的核心价值是：ExifTool 元数据读取/修改工具，常用于图片、PDF、Office、音视频元信息分析。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
exiftool image.jpg
```
```bash
exiftool -a -u -g1 file.pdf
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### exiftool -h

```text
Syntax:  exiftool [OPTIONS] FILE

Consult the exiftool documentation for a full list of options.
```

