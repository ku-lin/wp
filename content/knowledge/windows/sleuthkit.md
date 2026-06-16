---
title: "sleuthkit"
lastmod: 2026-04-12T00:37:38+08:00
draft: false
---
# sleuthkit

- 平台：Windows（D:\tool）
- 使用领域：Forensics / 磁盘镜像
- 主要用途：文件系统取证命令套件，fls/icat/mmls/istat/tsk_recover 等。
- 工具位置：`D:\tool\取证\sleuthkit-4.14.0-win32\sleuthkit-4.14.0-win32\bin`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

sleuthkit 的核心价值是：文件系统取证命令套件，fls/icat/mmls/istat/tsk_recover 等。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
mmls.exe disk.dd
```
```bash
fls.exe -r -o 2048 disk.dd
```
```bash
icat.exe -o 2048 disk.dd 12345 > recovered.bin
```

## 参数说明

- 先用 `mmls` 找分区起始扇区，再给 `fls`、`icat`、`tsk_recover` 传 `-o`。
- `fls` 列文件，`icat` 按 inode 导出，`istat` 看 inode 元数据，`tsk_recover` 批量恢复。
完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### mmls -h

```text
Unknown argument
usage: D:\tool\??\sleuthkit-4.14.0-win32\sleuthkit-4.14.0-win32\bin\mmls.exe [-i imgtype] [-b dev_sector_size] [-o imgoffset] [-BrvV] [-aAmM] [-t vstype] image [images]
	-t vstype: The type of volume system (use '-t list' for list of supported types)
	-i imgtype: The format of the image file (use '-i list' for list supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-o imgoffset: Offset to the start of the volume that contains the partition system (in sectors)
	-B: print the rounded length in bytes
	-r: recurse and look for other partition tables in partitions (DOS Only)
	-v: verbose output
	-V: print the version
Unless any of these are specified, all volume types are shown
	-a: Show allocated volumes
	-A: Show unallocated volumes
	-m: Show metadata volumes
	-M: Hide metadata volumes
```

### fls -h

```text
Missing image name
usage: D:\tool\取证\sleuthkit-4.14.0-win32\sleuthkit-4.14.0-win32\bin\fls.exe [-adDFlhpruvV] [-f fstype] [-i imgtype] [-b dev_sector_size] [-m dir/] [-o imgoffset] [-z ZONE] [-s seconds] image [images] [inode]
	If [inode] is not given, the root directory is used
	-a: Display "." and ".." entries
	-d: Display deleted entries only
	-D: Display only directories
	-F: Display only files
	-l: Display long version (like ls -l)
	-i imgtype: Format of image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-f fstype: File system type (use '-f list' for supported types)
	-m: Display output in mactime input format with
	      dir/ as the actual mount point of the image
	-h: Include MD5 checksum hash in mactime output
	-o imgoffset: Offset into image file (in sectors)
	-P pooltype: Pool container type (use '-P list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-S snap_id: Snapshot ID (for APFS only)
	-p: Display full path for each file
	-r: Recurse on directory entries
	-u: Display undeleted entries only
	-v: verbose output to stderr
	-V: Print version
	-z: Time zone of original machine (i.e. EST5EDT or GMT) (only useful with -l)
	-s seconds: Time skew of original machine (in seconds) (only useful with -l & -m)
	-k password: Decryption password for encrypted volumes
```

### icat -h

```text
Missing image name and/or address
usage: D:\tool\取证\sleuthkit-4.14.0-win32\sleuthkit-4.14.0-win32\bin\icat.exe [-hrRsvV] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] image [images] inum[-typ[-id]]
	-h: Do not display holes in sparse files
	-r: Recover deleted file
	-R: Recover deleted file and suppress recovery errors
	-s: Display slack space at end of file
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-f fstype: File system type (use '-f list' for supported types)
	-o imgoffset: The offset of the file system in the image (in sectors)
	-P pooltype: Pool container type (use '-P list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-S snap_id: Snapshot ID (for APFS only)
	-v: verbose to stderr
	-V: Print version
	-k password: Decryption password for encrypted volumes
```

### tsk_recover -h

```text
Invalid argument: (null)
usage: D:\tool\取证\sleuthkit-4.14.0-win32\sleuthkit-4.14.0-win32\bin\tsk_recover.exe [-vVae] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o sector_offset] [-P pooltype] [-B pool_volume_block] [-d dir_inum] image [image] output_dir
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-f fstype: The file system type (use '-f list' for supported types)
	-v: verbose output to stderr
	-V: Print version
	-a: Recover allocated files only
	-e: Recover all files (allocated and unallocated)
	-o sector_offset: sector offset for a volume to recover (recovers only that volume)
	-P pooltype: Pool container type (use '-P list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-d dir_inum: Directory inum to recover from (must also specify a specific partition using -o or there must not be a volume system)
```

