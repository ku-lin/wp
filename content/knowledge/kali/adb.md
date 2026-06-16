---
title: "adb"
lastmod: 2026-04-12T00:36:54+08:00
draft: false
---
# adb

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Mobile / Android
- 主要用途：Android Debug Bridge，用于连接手机/模拟器、传文件、装包、查看日志、执行 shell。
- 工具位置：`未确认到可执行入口`
- 当前状态：未在 Kali PATH/常见目录中找到；文档保留用途和替代建议
- 来源线索：`比赛环境手册/tool/adb.md`

## 比赛中怎么用

adb 的核心价值是：Android Debug Bridge，用于连接手机/模拟器、传文件、装包、查看日志、执行 shell。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
adb devices
```
```bash
adb shell
```
```bash
adb install app.apk
```
```bash
adb logcat
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 补充说明

- 本机 Kali 未发现 `adb` 命令；移动题可在 Windows/Android SDK 中使用或安装 android-tools-adb。

## 完整参数帮助输出

此工具未发现可直接抓取的命令行帮助。请按“工具位置”打开 GUI/资料目录，或在安装可执行文件后执行 `工具名 --help` / `工具名 -h` 查看参数。

