---
title: "checksec"
lastmod: 2026-04-12T00:36:55+08:00
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Pwn
- 主要用途：查看 ELF 的 NX、Canary、PIE、RELRO、Fortify 等保护状态。
- 工具位置：`/usr/bin/checksec`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/checksec.md`

## 比赛中怎么用

checksec 的核心价值是：查看 ELF 的 NX、Canary、PIE、RELRO、Fortify 等保护状态。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
checksec --file=./chall
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### checksec --help

```text
Usage: checksec [--format={cli,csv,xml,json}] [OPTION]


Options:

 ## Checksec Options
  --file={file}
  --dir={directory}
  --listfile={text file with one file per line}
  --proc={process name}
  --proc-all
  --proc-libs={process ID}
  --kernel[=kconfig]
  --fortify-file={executable-file}
  --fortify-proc={process ID}
  --version
  --help
  --update or --upgrade

 ## Modifiers
  --debug
  --verbose
  --format={cli,csv,xml,json}
  --output={cli,csv,xml,json}
  --extended

For more information, see:
  http://github.com/slimm609/checksec.sh
```

