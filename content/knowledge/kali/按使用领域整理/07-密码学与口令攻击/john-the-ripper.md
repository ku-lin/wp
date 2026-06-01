---
title: "John the Ripper"
draft: false
---
- 原始文档：[john.md](../../john/)
- 原文使用领域：Crypto / 密码爆破
- 核心用途：John the Ripper，CPU 哈希破解、格式转换、规则爆破。
- 位置/入口：`/usr/sbin/john`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
john 的核心价值是：John the Ripper，CPU 哈希破解、格式转换、规则爆破。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```
```bash
john --show hash.txt
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

