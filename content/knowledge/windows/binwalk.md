---
title: "binwalk"
lastmod: 2026-04-12T00:37:37+08:00
draft: false
---
# binwalk

- 平台：Windows（D:\tool）
- 使用领域：Forensics / Misc / Firmware
- 主要用途：固件与二进制 blob 扫描、识别内嵌文件、自动提取压缩包和文件系统。
- 工具位置：`D:\tool\取证\binwalk\target\release\binwalk.exe`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

binwalk 的核心价值是：固件与二进制 blob 扫描、识别内嵌文件、自动提取压缩包和文件系统。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
binwalk.exe firmware.bin
```
```bash
binwalk.exe -eM firmware.bin
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### binwalk --help

```text
Analyzes data for embedded file types

Usage: binwalk.exe [OPTIONS] [FILE_NAME]

Arguments:
  [FILE_NAME]  Path to the file to analyze

Options:
  -L, --list                   List supported signatures and extractors
  -s, --stdin                  Read data from standard input
  -q, --quiet                  Supress normal stdout output
  -v, --verbose                During recursive extraction display *all* results
  -e, --extract                Automatically extract known file types
  -c, --carve                  Carve both known and unknown file contents to disk
  -M, --matryoshka             Recursively scan extracted files
  -a, --search-all             Search for all signatures at all offsets
  -E, --entropy                Generate an entropy graph with Plotly
  -p, --png <PNG>              Save entropy graph as a PNG file
  -l, --log <LOG>              Log JSON results to a file ('-' for stdout)
  -t, --threads <THREADS>      Manually specify the number of threads to use
  -x, --exclude <EXCLUDE>...   Do no scan for these signatures
  -y, --include <INCLUDE>...   Only scan for these signatures
  -d, --directory <DIRECTORY>  Extract files/folders to a custom directory [default: extractions]
  -h, --help                   Print help
  -V, --version                Print version
```

