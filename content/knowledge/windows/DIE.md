---
title: "DIE"
lastmod: 2026-04-12T00:37:37+08:00
draft: false
---
- 平台：Windows（D:\tool）
- 使用领域：Reverse / Forensics
- 主要用途：Detect It Easy 便携版，die.exe 是 GUI，diec.exe 是命令行检测入口。
- 工具位置：`D:\tool\取证\DIE`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

DIE 的核心价值是：Detect It Easy 便携版，die.exe 是 GUI，diec.exe 是命令行检测入口。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
diec.exe sample.exe
```
```bash
die.exe
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### diec --help

```text
Usage: D:\tool\取证\DIE\diec.exe [options] target
Detect It Easy v3.10
Copyright(C) 2006-2008 Hellsp@wn 2012-2024 hors<horsicq@gmail.com> Web: http://ntinfo.biz


Options:
  -?, -h, --help               Displays help on commandline options.
  --help-all                   Displays help including Qt specific options.
  -v, --version                Displays version information.
  -r, --recursivescan          Recursive scan.
  -d, --deepscan               Deep scan.
  -u, --heuristicscan          Heuristic scan.
  -b, --verbose                Verbose.
  -g, --aggressivecscan        Aggressive scan.
  -a, --alltypes               Scan all types.
  -l, --profiling              Profiling signatures.
  -U, --hideunknown            Hide unknown.
  -e, --entropy                Show entropy.
  -i, --info                   Show file info.
  -S, --special <method>       Special file info for <method>. For example -S
                               "Hash" or -S "Hash#MD5".
  -x, --xml                    Result as XML.
  -j, --json                   Result as JSON.
  -c, --csv                    Result as CSV.
  -t, --tsv                    Result as TSV.
  -p, --plaintext              Result as Plain Text.
  -D, --database <path>        Set database<path>.
  -E, --extradatabase <path>   Set extra database<path>.
  -C, --customdatabase <path>  Set custom database<path>.
  -s, --showdatabase           Show database.
  -m, --showmethods            Show all special methods for the file.

Arguments:
  target                       The file or directory to open.
```

