---
title: "TestDisk"
draft: false
---
- 原始文档：[testdisk.md](../../testdisk/)
- 原文使用领域：Forensics / 数据恢复
- 核心用途：分区表恢复、文件系统恢复、磁盘修复的交互式工具。
- 位置/入口：`/usr/bin/testdisk`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
testdisk 的核心价值是：分区表恢复、文件系统恢复、磁盘修复的交互式工具。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
testdisk image.dd
```
```bash
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

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

