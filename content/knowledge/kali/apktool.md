---
title: "apktool"
lastmod: 2026-04-12T00:36:54+08:00
draft: false
---
# apktool

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Mobile / Reverse
- 主要用途：APK 资源与 smali 反编译、修改、重打包，常用于 Android 逆向和移动题。
- 工具位置：`/usr/bin/apktool`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/apktool.md`

## 比赛中怎么用

apktool 的核心价值是：APK 资源与 smali 反编译、修改、重打包，常用于 Android 逆向和移动题。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
apktool d app.apk -o app_src
```
```bash
apktool b app_src -o rebuilt.apk
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### apktool --help

```text
Unrecognized option: --help
Apktool v2.7.0-dirty - a tool for reengineering Android apk files
with smali v2.5.2.git2771eae-debian and baksmali v2.5.2.git2771eae-debian
Copyright 2010 Ryszard Wiśniewski <brut.alll@gmail.com>
Copyright 2010 Connor Tumbleson <connor.tumbleson@gmail.com>

usage: apktool
 -advance,--advanced   prints advance information.
 -version,--version    prints the version then exits
usage: apktool if|install-framework [options] <framework.apk>
 -p,--frame-path <dir>   Stores framework files into <dir>.
 -t,--tag <tag>          Tag frameworks using <tag>.
usage: apktool d[ecode] [options] <file_apk>
 -f,--force              Force delete destination directory.
 -o,--output <dir>       The name of folder that gets written. Default is apk.out
 -p,--frame-path <dir>   Uses framework files located in <dir>.
 -r,--no-res             Do not decode resources.
 -s,--no-src             Do not decode sources.
 -t,--frame-tag <tag>    Uses framework files tagged by <tag>.
usage: apktool b[uild] [options] <app_path>
 -f,--force-all          Skip changes detection and build all files.
 -o,--output <dir>       The name of apk that gets written. Default is dist/name.apk
 -p,--frame-path <dir>   Uses framework files located in <dir>.

For additional info, see: https://ibotpeaches.github.io/Apktool/ 
For smali/baksmali info, see: https://github.com/JesusFreke/smali
```

