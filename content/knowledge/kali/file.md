---
title: "file"
lastmod: 2026-04-12T00:36:55+08:00
draft: false
---
# file

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Forensics / Reverse / Misc
- 主要用途：根据 magic bytes 判断文件类型、架构、是否 stripped、脚本/压缩格式等。
- 工具位置：`/usr/bin/file`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/file.md`

## 比赛中怎么用

file 的核心价值是：根据 magic bytes 判断文件类型、架构、是否 stripped、脚本/压缩格式等。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
file sample.bin
```
```bash
file -k sample.bin
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### file --help

```text
Usage: file [OPTION...] [FILE...]
Determine type of FILEs.

      --help                 display this help and exit
  -v, --version              output version information and exit
  -m, --magic-file LIST      use LIST as a colon-separated list of magic
                               number files
  -z, --uncompress           try to look inside compressed files
  -Z, --uncompress-noreport  only print the contents of compressed files
  -b, --brief                do not prepend filenames to output lines
  -c, --checking-printout    print the parsed form of the magic file, use in
                               conjunction with -m to debug a new magic file
                               before installing it
  -e, --exclude TEST         exclude TEST from the list of test to be
                               performed for file. Valid tests are:
                               apptype, ascii, cdf, compress, csv, elf,
                               encoding, soft, tar, json, simh,
                               text, tokens
      --exclude-quiet TEST   like exclude, but ignore unknown tests
  -f, --files-from FILE      read the filenames to be examined from FILE
  -F, --separator STRING     use string as separator instead of `:'
  -i, --mime                 output MIME type strings (--mime-type and
                               --mime-encoding)
      --apple                output the Apple CREATOR/TYPE
      --extension            output a slash-separated list of extensions
      --mime-type            output the MIME type
      --mime-encoding        output the MIME encoding
  -k, --keep-going           don't stop at the first match
  -l, --list                 list magic strength
  -L, --dereference          follow symlinks (default if POSIXLY_CORRECT is set)
  -h, --no-dereference       don't follow symlinks (default if POSIXLY_CORRECT is not set) (default)
  -n, --no-buffer            do not buffer output
  -N, --no-pad               do not pad output
  -0, --print0               terminate filenames with ASCII NUL
  -p, --preserve-date        preserve access times on files
  -P, --parameter            set file engine parameter limits
                                   bytes 7340032 max bytes to look inside file
                               elf_notes     256 max ELF notes processed
                               elf_phnum    2048 max ELF prog sections processed
                               elf_shnum   32768 max ELF sections processed
                               elf_shsize 134217728 max ELF section size
                                encoding   65536 max bytes to scan for encoding
                                   indir      50 recursion limit for indirection
                                    name     100 use limit for name/use magic
                                   regex    8192 length limit for REGEX searches
                                 magwarn      64 maximum number of magic warnings
  -r, --raw                  don't translate unprintable chars to \ooo
  -s, --special-files        treat special (block/char devices) files as
                             ordinary ones
  -S, --no-sandbox           disable system call sandboxing
  -C, --compile              compile file specified by -m
  -d, --debug                print debugging messages

Report bugs to https://bugs.astron.com/
```

