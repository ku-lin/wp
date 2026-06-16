---
title: "foremost"
lastmod: 2026-04-12T00:36:55+08:00
draft: false
---
# foremost

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Forensics
- 主要用途：基于文件头尾特征的数据雕复工具，常用于磁盘镜像或混合文件恢复。
- 工具位置：`/usr/bin/foremost`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/foremost.md`

## 比赛中怎么用

foremost 的核心价值是：基于文件头尾特征的数据雕复工具，常用于磁盘镜像或混合文件恢复。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
foremost -i disk.dd -o output_dir
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### foremost -h

```text
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

