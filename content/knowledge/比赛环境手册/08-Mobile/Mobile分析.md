---
title: "Mobile分析"
lastmod: 2026-03-30T19:44:12+08:00
draft: false
---
# Mobile

## 常用工具

- `jadx`
- `apktool`
- `ghidra`
- `burpsuite`
- `adb`

## 常用命令

```bash
apktool d app.apk
jadx -d jadx_out app.apk
adb devices
adb shell
adb pull /sdcard/file .
```

## 分析顺序

1. 反编译 APK，先看 `AndroidManifest.xml`
2. 找接口、域名、证书、密钥、调试开关
3. 看登录、签名校验、root 检测、代理检测
4. 如果有 SO，再转 `ghidra` 或 `gdb`

## 常见点

- 明文接口和测试环境地址
- 证书校验与抓包绕过
- 本地存储、SharedPreferences、SQLite
- JNI、加壳、反调试

