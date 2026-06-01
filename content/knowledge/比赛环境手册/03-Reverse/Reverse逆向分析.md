---
title: "Reverse"
draft: false
---
## 常用工具

- `ghidra`
- `radare2`
- `jadx`
- `apktool`
- `binwalk`
- `strings` / `file` / `xxd`
- `gdb`

## 起手命令

```bash
file sample
strings -a sample | less
binwalk sample
r2 -A sample
```

### Android

```bash
apktool d app.apk
jadx -d jadx_out app.apk
```

## 常见工作流

1. `file` 和 `strings` 先确认格式、架构、语言和可疑字符串。
2. 静态优先：`ghidra` 看主流程，`radare2` 补细节。
3. 动态再跟：断关键函数、看分支、观察输入输出。
4. Android 题先拆资源，再看 Java 层，再考虑 native 层。

## 重点关注

- 密钥、IV、URL、token、magic number
- 自定义编码、异或、移位、查表
- 壳、反调试、环境检测
- JNI、SO、签名校验、证书 pinning

