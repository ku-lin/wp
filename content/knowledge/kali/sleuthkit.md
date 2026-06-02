---
title: "sleuthkit"
lastmod: 2026-04-12T00:37:35+08:00
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Forensics / 磁盘镜像
- 主要用途：文件系统取证命令套件，fls/icat/mmls/istat/tsk_recover 等。
- 工具位置：`/usr/bin/fls`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/sleuthkit.md`

## 比赛中怎么用

sleuthkit 的核心价值是：文件系统取证命令套件，fls/icat/mmls/istat/tsk_recover 等。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
mmls disk.dd
```
```bash
fls -r -o 2048 disk.dd
```
```bash
icat -o 2048 disk.dd 12345 > recovered.bin
```

## 参数说明

- 先用 `mmls` 找分区起始扇区，再给 `fls`、`icat`、`tsk_recover` 传 `-o`。
- `fls` 列文件，`icat` 按 inode 导出，`istat` 看 inode 元数据，`tsk_recover` 批量恢复。
完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 补充说明

- Sleuth Kit 是命令套件；`fls`、`icat`、`mmls`、`tsk_recover` 是 CTF 取证最常用入口。

## 完整参数帮助输出

### for c in fls icat mmls fsstat istat ils ifind ffind blkls blkcat blkstat img_stat tsk_recover tsk_imageinfo; do echo "===== $c ====="; command -v $c; $c -h 2>&1 | head -n 140; done

```text
===== fls =====
/usr/bin/fls
Missing image name
usage: fls [-adDFlhpruvV] [-f fstype] [-i imgtype] [-b dev_sector_size] [-m dir/] [-o imgoffset] [-z ZONE] [-s seconds] image [images] [inode]
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
===== icat =====
/usr/bin/icat
Missing image name and/or address
usage: icat [-hrRsvV] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] image [images] inum[-typ[-id]]
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
===== mmls =====
/usr/bin/mmls
mmls: invalid option -- 'h'
Unknown argument
usage: mmls [-i imgtype] [-b dev_sector_size] [-o imgoffset] [-BrvV] [-aAmM] [-t vstype] image [images]
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
===== fsstat =====
/usr/bin/fsstat
fsstat: invalid option -- 'h'
Invalid argument: (null)
usage: fsstat [-tvV] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] image
	-t: display type only
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-f fstype: File system type (use '-f list' for supported types)
	-o imgoffset: The offset of the file system in the image (in sectors)
	-P pooltype: Pool container type (use '-P list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-v: verbose output to stderr
	-V: Print version
	-k password: Decryption password for encrypted volumes
===== istat =====
/usr/bin/istat
istat: invalid option -- 'h'
Invalid argument: (null)
usage: istat [-N num] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] [-P pooltype] [-B pool_volume_block] [-z zone] [-s seconds] [-rvV] image inum
	-N num: force the display of NUM address of block pointers
	-r: display run list instead of list of block addresses
	-z zone: time zone of original machine (i.e. EST5EDT or GMT)
	-s seconds: Time skew of original machine (in seconds)
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-f fstype: File system type (use '-f list' for supported types)
	-o imgoffset: The offset of the file system in the image (in sectors)
	-P pooltype: Pool container type (use '-p list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-S snap_id: Snapshot ID (for APFS only)
	-v: verbose output to stderr
	-V: print version
	-k password: Decryption password for encrypted volumes
===== ils =====
/usr/bin/ils
ils: invalid option -- 'h'
Invalid argument: (null)
usage: ils [-emOpvV] [-aAlLzZ] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] [-P pooltype] [-B pool_volume_block] [-s seconds] image [images] [inum[-end]]
	-e: Display all inodes
	-m: Display output in the mactime format
	-O: Display inodes that are unallocated, but were sill open (UFS/ExtX only)
	-p: Display orphan inodes (unallocated with no file name)
	-s seconds: Time skew of original machine (in seconds)
	-a: Allocated inodes
	-A: Unallocated inodes
	-l: Linked inodes
	-L: Unlinked inodes
	-z: Unused inodes
	-Z: Used inodes
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-f fstype: File system type (use '-f list' for supported types)
	-o imgoffset: The offset of the file system in the image (in sectors)
	-P pooltype: Pool container type (use '-p list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-v: verbose output to stderr
	-V: Display version number
===== ifind =====
/usr/bin/ifind
ifind: invalid option -- 'h'
Invalid argument: (null)
usage: ifind [-alvV] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] [-P pooltype] [-B pool_volume_block] [-d unit_addr] [-n file] [-p par_addr] [-z ZONE] image [images]
	-a: find all inodes
	-d unit_addr: Find the meta data given the data unit
	-l: long format when -p is given
	-n file: Find the meta data given the file name
	-p par_addr: Find UNALLOCATED MFT entries given the parent's meta address (NTFS only)
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-f fstype: File system type (use '-f list' for supported types)
	-o imgoffset: The offset of the file system in the image (in sectors)
	-P pooltype: Pool container type (use '-p list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-v: Verbose output to stderr
	-V: Print version
	-z ZONE: Time zone setting when -l -p is given
===== ffind =====
/usr/bin/ffind
ffind: invalid option -- 'h'
Invalid argument: (null)
usage: ffind [-aduvV] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] [-P pooltype] [-B pool_volume_block] image [images] inode
	-a: Find all occurrences
	-d: Find deleted entries ONLY
	-u: Find undeleted entries ONLY
	-f fstype: Image file system type (use '-f list' for supported types)
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-o imgoffset: The offset of the file system in the image (in sectors)
	-P pooltype: Pool container type (use '-p list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-v: Verbose output to stderr
	-V: Print version
===== blkls =====
/usr/bin/blkls
blkls: invalid option -- 'h'
Invalid argument: (null)
usage: blkls [-aAelvV] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] [-P pooltype] [-B pool_volume_block] image [images] [start-stop]
	-e: every block (including file system metadata blocks)
	-l: print details in time machine list format
	-a: Display allocated blocks
	-A: Display unallocated blocks
	-f fstype: File system type (use '-f list' for supported types)
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-o imgoffset: The offset of the file system in the image (in sectors)
	-P pooltype: Pool container type (use '-P list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-s: print slack space only (other flags are ignored
	-v: verbose to stderr
	-V: print version
===== blkcat =====
/usr/bin/blkcat
Missing image name and/or address
usage: blkcat [-ahsvVw] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] [-P pooltype] [-B pool_volume_block] [-k password] [-u usize] image [images] unit_addr [num]
	-a: displays in all ASCII 
	-h: displays in hexdump-like fashion
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-o imgoffset: The offset of the file system in the image (in sectors)
	-P pooltype: Pool container type (use '-p list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-f fstype: File system type (use '-f list' for supported types)
	-k password: Decryption password for encrypted volumes
	-s: display basic block stats such as unit size, fragments, etc.
	-v: verbose output to stderr
	-V: display version
	-w: displays in web-like (html) fashion
	-u usize: size of each data unit in image (for raw, blkls, swap)
	[num] is the number of data units to display (default is 1)
===== blkstat =====
/usr/bin/blkstat
blkstat: invalid option -- 'h'
Invalid argument: (null)
usage: blkstat [-vV] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o imgoffset] [-P pooltype] [-B pool_volume_block] image [images] addr
	-f fstype: File system type (use '-f list' for supported types)
	-k password: Decryption password for encrypted volumes
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-o imgoffset: The offset of the file system in the image (in sectors)
	-P pooltype: Pool container type (use '-P list' for supported types)
	-B pool_volume_block: Starting block (for pool volumes only)
	-v: Verbose output to stderr
	-V: Print version
===== img_stat =====
/usr/bin/img_stat
img_stat: invalid option -- 'h'
Invalid argument: (null)
usage: img_stat [-tvV] [-i imgtype] [-b dev_sector_size] image
	-t: display type only
	-i imgtype: The format of the image file (use '-i list' for list of supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-v: verbose output to stderr
	-V: Print version
===== tsk_recover =====
/usr/bin/tsk_recover
tsk_recover: invalid option -- 'h'
Invalid argument: (null)
usage: tsk_recover [-vVae] [-f fstype] [-i imgtype] [-b dev_sector_size] [-o sector_offset] [-P pooltype] [-B pool_volume_block] [-d dir_inum] image [image] output_dir
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
===== tsk_imageinfo =====
/usr/bin/tsk_imageinfo
tsk_imageinfo: invalid option -- 'h'
Invalid argument: (null)
usage: tsk_imageinfo [-vV] [-i imgtype] [-b dev_sector_size] image
	-i imgtype: The format of the image file (use '-i list' for supported types)
	-b dev_sector_size: The size (in bytes) of the device sectors
	-v: verbose output to stderr
	-V: Print version
```

