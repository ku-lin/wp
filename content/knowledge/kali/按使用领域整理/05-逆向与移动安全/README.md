---
title: "README"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
# 逆向与移动安全

面向 APK 分析、反编译、静态分析、调试与基础二进制观察。

## 包含工具
- [radare2](radare2/)：命令行逆向框架，可做反汇编、调试、patch、脚本分析。
- [jadx](jadx/)：Dex/APK 到 Java 伪源码的反编译工具，适合 Android 静态分析。
- [xxd](xxd/)：十六进制查看/转换工具，可生成 hexdump 或从 hexdump 还原二进制。
- [strings](strings/)：从二进制中提取可打印字符串，快速找 flag、URL、密钥、调试信息。
- [apktool](apktool/)：APK 资源与 smali 反编译、修改、重打包，常用于 Android 逆向和移动题。
- [adb](adb/)：Android Debug Bridge，用于连接手机/模拟器、传文件、装包、查看日志、执行 shell。
- [Ghidra](ghidra/)：NSA 开源逆向平台，反编译、反汇编、函数/结构体恢复。
- [file](file/)：根据 magic bytes 判断文件类型、架构、是否 stripped、脚本/压缩格式等。

