---
title: "Arsenal-Image-Mounter"
lastmod: 2026-04-12T00:37:37+08:00
draft: false
---
- 平台：Windows（D:\tool）
- 使用领域：Forensics / 磁盘镜像
- 主要用途：挂载 E01/VHD/VMDK/RAW 等镜像，便于只读分析和文件提取。
- 工具位置：`D:\tool\取证\Arsenal-Image-Mounter-v3.12.344\Arsenal-Image-Mounter-v3.12.344`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

Arsenal-Image-Mounter 的核心价值是：挂载 E01/VHD/VMDK/RAW 等镜像，便于只读分析和文件提取。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
aim_cli.exe --help
```
```bash
ArsenalImageMounter.exe
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 补充说明

- GUI 入口是 ArsenalImageMounter.exe；命令行入口是 aim_cli.exe。

## 完整参数帮助输出

### aim_cli --help

```text
aim_cli

Arsenal Image Mounter CLI (AIM CLI) - an integrated command line interface to
     the Arsenal Image Mounter virtual SCSI miniport driver.

Before using AIM CLI, please see readme_cli.txt and "Arsenal Recon - End User
     License Agreement.txt" for detailed usage and license information.

Please note: AIM CLI should be run with administrative privileges. If you would
     like to use AIM CLI to interact with EnCase (E01, Ex01, S01 and AFF), AFF4
     forensic disk images or QEMU Qcow images, you must make the Libewf
     (libewf.dll), LibAFF4 (libaff4.dll) and Libqcow (libqcow.dll) libraries
     available in the expected (/lib/x64) or same folder as aim_cli.exe. AIM
     CLI now mounts disk images in read-only mode by default.

Syntax to mount a raw/forensic/virtual machine disk image as a "real" disk
aim_cli --mount[=removable|cdrom] [--buffersize=size] [--readonly|--writable]
     [--fakesig] [--fakembr] [--online] --filename=imagefilename
     [--provider=DiscUtils|None|LibEwf|LibAFF4|LibQcow|MultiPartRaw]
     [--writeoverlay=differencingimagefile] [--autodelete]] [--background]

Syntax to calculate MD5, SHA1, or SHA256 checksum over disk image contents
     without mounting (all three calculated if a specific checksum is not
     specified)
aim_cli --filename=imagefilename
     [--provider=DiscUtils|None|LibEwf|LibAFF4|LibQcow|MultiPartRaw]
     --checksum[=MD5|SHA1|SHA256]

Syntax to mount a RAM disk:
aim_cli --ramdisk --disksize=size
Size in bytes, can be suffixed with for example M or G for MB or GB.

Syntax to mount a RAM disk from a VHD template image file:
aim_cli --ramdisk --filename=imagefilename

Syntax to create a new disk image file:
aim_cli --create --filename=imagefilename --disksize=size
     [--variant=fixed|dynamic] [--mount]
Size in bytes, can be suffixed with for example M or G for MB or GB.

Syntax to start service mode, for mounting from other applications:
aim_cli --name=objectname [--buffersize=size] [--readonly|--writable]
     [--fakembr] --filename=imagefilename
     [--provider=DiscUtils|None|LibEwf|LibAFF4|LibQcow|MultiPartRaw]
     [--background]
Size in bytes, can be suffixed with for example K or M for KB or MB.

Syntax to start TCP/IP service mode, for mounting from other computers:
aim_cli [--ipaddress=listenaddress] --port=tcpport [--readonly|--writable]
     [--fakembr] --filename=imagefilename
     [--provider=DiscUtils|None|LibEwf|LibAFF4|LibQcow|MultiPartRaw]
     [--background]

Syntax to convert a disk image without mounting:
aim_cli --filename=imagefilename [--fakembr]
     [--provider=DiscUtils|None|LibEwf|LibAFF4|LibQcow|MultiPartRaw]
     --convert=outputimagefilename [--variant=fixed|dynamic] [--background]

Syntax to restore a disk image to an actual physical disk:
aim_cli --filename=imagefilename [--fakembr]
     [--provider=DiscUtils|None|LibEwf|LibAFF4|LibQcow|MultiPartRaw]
     --convert=\\?\PhysicalDriveN [--background]

Syntax to save as a new disk image after mounting:
aim_cli --device=sixdigitdevicenumber --saveas=outputimagefilename
     [--variant=fixed|dynamic] [--background]

Syntax to save a physical disk as an image file:
aim_cli --device=\\?\PhysicalDriveN --convert=outputimagefilename
     [--variant=fixed|dynamic] [--background]

Syntax to dismount a mounted device:
aim_cli --dismount[=sixdigitdevicenumber|\\?\PhysicalDriveN] [--force]

Syntax to mount a disk at remote machine:
aim_cli --mount [--buffersize=bytes] [--readonly|--writable] [--fakesig]
     [--fakembr] [--online] --connnect=ipaddress[:port]
     [--writeoverlay=differencingimagefile [--autodelete]]

Syntax to display a list of mounted devices:
aim_cli --list

Syntax to rescan SCSI adapter:
aim_cli --rescan
Useful when there is a dead mounted disk left behind after it has lost
     connection to storage backend, such as after issues with underlying image
     file device or loss of network connection.
```

