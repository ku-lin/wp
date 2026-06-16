---
title: "patchelf"
lastmod: 2026-04-12T00:37:30+08:00
draft: false
---
# patchelf

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Pwn
- 主要用途：修改 ELF interpreter、RPATH/RUNPATH、依赖库等，常用于指定题目 libc。
- 工具位置：`/usr/bin/patchelf`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/patchelf.md`

## 比赛中怎么用

patchelf 的核心价值是：修改 ELF interpreter、RPATH/RUNPATH、依赖库等，常用于指定题目 libc。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
patchelf --print-interpreter ./chall
```
```bash
patchelf --set-interpreter ./ld-linux-x86-64.so.2 ./chall
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### patchelf --help

```text
syntax: patchelf
  [--set-interpreter FILENAME]
  [--page-size SIZE]
  [--print-interpreter]
  [--print-os-abi]		Prints 'EI_OSABI' field of ELF header
  [--set-os-abi ABI]		Sets 'EI_OSABI' field of ELF header to ABI.
  [--print-soname]		Prints 'DT_SONAME' entry of .dynamic section. Raises an error if DT_SONAME doesn't exist
  [--set-soname SONAME]		Sets 'DT_SONAME' entry to SONAME.
  [--set-rpath RPATH]
  [--add-rpath RPATH]
  [--remove-rpath]
  [--shrink-rpath]
  [--allowed-rpath-prefixes PREFIXES]		With '--shrink-rpath', reject rpath entries not starting with the allowed prefix
  [--print-rpath]
  [--force-rpath]
  [--add-needed LIBRARY]
  [--remove-needed LIBRARY]
  [--replace-needed LIBRARY NEW_LIBRARY]
  [--print-needed]
  [--no-default-lib]
  [--no-sort]		Do not sort program+section headers; useful for debugging patchelf.
  [--clear-symbol-version SYMBOL]
  [--add-debug-tag]
  [--print-execstack]		Prints whether the object requests an executable stack
  [--clear-execstack]
  [--set-execstack]
  [--rename-dynamic-symbols NAME_MAP_FILE]	Renames dynamic symbols. The map file should contain two symbols (old_name new_name) per line
  [--output FILE]
  [--debug]
  [--version]
  FILENAME...
```

