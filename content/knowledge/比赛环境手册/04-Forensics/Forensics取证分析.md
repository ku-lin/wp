---
title: "Forensics取证分析"
lastmod: 2026-03-30T19:44:12+08:00
draft: false
---
# Forensics

## 常用工具

- `foremost`
- `sleuthkit`
- `testdisk`
- `binwalk`
- `yara`
- `libimage-exiftool-perl`
- `strings`

## 常用命令

### 文件恢复

```bash
foremost -i disk.img -o out
testdisk
```

### 镜像/文件系统

```bash
fls -r disk.img | head
fsstat disk.img | head
icat disk.img <inode>
```

### 元数据

```bash
exiftool sample.jpg
file sample
strings -a sample | less
```

### 特征匹配

```bash
yara -r rules.yar samples/
binwalk -e firmware.bin
```

## 做题思路

1. 先判断对象：磁盘、内存、日志、流量、图片、压缩包、固件。
2. 再做元数据与结构确认。
3. 最后做恢复、提取、关联和时间线还原。

## 容易出题的点

- 隐写
- 删除文件恢复
- 图片/Office/PDF 元数据
- 固件拆包
- 日志时间线还原

