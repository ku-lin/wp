---
title: "feroxbuster"
draft: false
---
- 原始文档：[feroxbuster.md](../../feroxbuster/)
- 原文使用领域：CTF Web
- 核心用途：高速递归目录扫描器，适合目录爆破、状态码过滤、扩展名探测。
- 位置/入口：`/usr/bin/feroxbuster`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
feroxbuster 的核心价值是：高速递归目录扫描器，适合目录爆破、状态码过滤、扩展名探测。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
feroxbuster -u http://target/ -w wordlist.txt
```
```bash
feroxbuster -u http://target/ -x php,txt,zip -k
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

