---
title: "testdisk"
lastmod: 2026-04-12T00:37:36+08:00
draft: false
---
# testdisk

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Forensics / 数据恢复
- 主要用途：分区表恢复、文件系统恢复、磁盘修复的交互式工具。
- 工具位置：`/usr/bin/testdisk`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/testdisk.md`

## 比赛中怎么用

testdisk 的核心价值是：分区表恢复、文件系统恢复、磁盘修复的交互式工具。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
testdisk image.dd
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### testdisk --help

```text
TestDisk 7.2, Data Recovery Utility, February 2024
Christophe GRENIER <grenier@cgsecurity.org>
https://www.cgsecurity.org

Usage: testdisk [/log] [/debug] [file.dd|file.e01|device]
       testdisk /list  [/log]   [file.dd|file.e01|device]
       testdisk /version

/log          : create a testdisk.log file
/debug        : add debug information
/list         : display current partitions

TestDisk checks and recovers lost partitions
It works with :
- BeFS (BeOS)                           - BSD disklabel (Free/Open/Net BSD)
- CramFS, Compressed File System        - DOS/Windows FAT12, FAT16 and FAT32
- XBox FATX                             - Windows exFAT
- HFS, HFS+, Hierarchical File System   - JFS, IBM's Journaled File System
- Linux btrfs                           - Linux ext2, ext3 and ext4
- Linux GFS2                            - Linux LUKS
- Linux Raid                            - Linux Swap
- LVM, LVM2, Logical Volume Manager     - Netware NSS
- Windows NTFS                          - ReiserFS 3.5, 3.6 and 4
- Sun Solaris i386 disklabel            - UFS and UFS2 (Sun/BSD/...)
- XFS, SGI's Journaled File System      - Wii WBFS
- Sun ZFS
```

