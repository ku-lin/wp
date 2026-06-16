---
title: "apktool"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
# apktool

- 原始文档：[apktool.md](../../apktool/)
- 原文使用领域：Mobile / Reverse
- 核心用途：APK 资源与 smali 反编译、修改、重打包，常用于 Android 逆向和移动题。
- 位置/入口：`/usr/bin/apktool`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
apktool 的核心价值是：APK 资源与 smali 反编译、修改、重打包，常用于 Android 逆向和移动题。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
apktool d app.apk -o app_src
```
```bash
apktool b app_src -o rebuilt.apk
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

