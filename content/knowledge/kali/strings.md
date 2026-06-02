---
title: "strings"
lastmod: 2026-04-12T00:37:35+08:00
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Reverse / Forensics / Misc
- 主要用途：从二进制中提取可打印字符串，快速找 flag、URL、密钥、调试信息。
- 工具位置：`/usr/bin/strings`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/strings.md`

## 比赛中怎么用

strings 的核心价值是：从二进制中提取可打印字符串，快速找 flag、URL、密钥、调试信息。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
strings -a sample.bin | less
```
```bash
strings -tx ./chall | grep flag
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### strings --help

```text
Usage: strings [option(s)] [file(s)]
 Display printable strings in [file(s)] (stdin by default)
 The options are:
  -a - --all                Scan the entire file, not just the data section [default]
  -d --data                 Only scan the data sections in the file
  -f --print-file-name      Print the name of the file before each string
  -n <number>               Locate & print any sequence of at least <number>
    --bytes=<number>         displayable characters.  (The default is 4).
  -t --radix={o,d,x}        Print the location of the string in base 8, 10 or 16
  -w --include-all-whitespace Include all whitespace as valid string characters
  -o                        An alias for --radix=o
  -T --target=<BFDNAME>     Specify the binary file format
  -e --encoding={s,S,b,l,B,L} Select character size and endianness:
                            s = 7-bit, S = 8-bit, {b,l} = 16-bit, {B,L} = 32-bit
  --unicode={default|locale|invalid|hex|escape|highlight}
  -U {d|l|i|x|e|h}          Specify how to treat UTF-8 encoded unicode characters
  -s --output-separator=<string> String used to separate strings in output.
  @<file>                   Read options from <file>
  -h --help                 Display this information
  -v -V --version           Print the program's version number
strings: supported targets: elf64-x86-64 elf32-i386 elf32-iamcu elf32-x86-64 pei-i386 pe-x86-64 pei-x86-64 elf64-little elf64-big elf32-little elf32-big pe-bigobj-x86-64 pe-i386 pe-bigobj-i386 pdb srec symbolsrec verilog tekhex binary ihex plugin
Report bugs to <https://sourceware.org/bugzilla/>
```

