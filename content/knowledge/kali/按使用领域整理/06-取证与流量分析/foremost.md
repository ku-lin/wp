---
title: "foremost"
draft: false
---
- 原始文档：[foremost.md](../../foremost/)
- 原文使用领域：Forensics
- 核心用途：基于文件头尾特征的数据雕复工具，常用于磁盘镜像或混合文件恢复。
- 位置/入口：`/usr/bin/foremost`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
foremost 的核心价值是：基于文件头尾特征的数据雕复工具，常用于磁盘镜像或混合文件恢复。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
foremost -i disk.dd -o output_dir
```
```bash
foremost version 1.5.7 by Jesse Kornblum, Kris Kendall, and Nick Mikus.
$ foremost [-v|-V|-h|-T|-Q|-q|-a|-w-d] [-t <type>] [-s <blocks>] [-k <size>] 
	[-b <size>] [-c <file>] [-o <dir>] [-i <file] 

-V  - display copyright information and exit
-t  - specify file type.  (-t jpeg,pdf ...) 
-d  - turn on indirect block detection (for UNIX file-systems) 
-i  - specify input file (default is stdin) 
-a  - Write all headers, perform no error detection (corrupted files) 
-w  - Only write the audit file, do not write any detected files to the disk 
-o  - set output directory (defaults to output)
-c  - set configuration file to use (defaults to foremost.conf)
-q  - enables quick mode. Search are performed on 512 byte boundaries.
-Q  - enables quiet mode. Suppress output messages. 
-v  - verbose mode. Logs all messages to screen
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

