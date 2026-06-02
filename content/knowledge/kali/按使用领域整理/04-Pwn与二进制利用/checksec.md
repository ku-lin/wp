---
title: "checksec"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
- 原始文档：[checksec.md](../../checksec/)
- 原文使用领域：Pwn
- 核心用途：查看 ELF 的 NX、Canary、PIE、RELRO、Fortify 等保护状态。
- 位置/入口：`/usr/bin/checksec`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
checksec 的核心价值是：查看 ELF 的 NX、Canary、PIE、RELRO、Fortify 等保护状态。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
checksec --file=./chall
```
```bash
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

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

