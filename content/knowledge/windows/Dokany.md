---
title: "Dokany"
lastmod: 2026-04-12T00:37:37+08:00
draft: false
---
- 平台：Windows（D:\tool）
- 使用领域：Forensics / 文件系统挂载
- 主要用途：Windows 用户态文件系统驱动，常作为 MemProcFS 等挂载工具依赖。
- 工具位置：`D:\tool\取证\Dokany`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

Dokany 的核心价值是：Windows 用户态文件系统驱动，常作为 MemProcFS 等挂载工具依赖。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 补充说明

- 通常不单独解题，更多是挂载类工具的依赖。

## 完整参数帮助输出

### dokanctl /?

```text
dokanctl /u MountPoint
dokanctl /u M
dokanctl /i [d|n|a]
dokanctl /r [d|n|a]
dokanctl /v

Example:
  /u M                : Unmount M: drive
  /u C:\mount\dokan   : Unmount mount point C:\mount\dokan
  /i d                : Install driver
  /i n                : Install network provider
  /r d                : Remove driver
  /r n                : Remove network provider
  /l a                : List current mount points
  /d [0-7]            : Enable Kernel Debug output
  /v                  : Print Dokan version
Driver path: 'C:\Windows\system32\drivers\dokan2.sys'
```

