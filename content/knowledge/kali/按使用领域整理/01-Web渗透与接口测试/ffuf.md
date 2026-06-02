---
title: "ffuf"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
- 原始文档：[ffuf.md](../../ffuf/)
- 原文使用领域：CTF Web / Fuzz
- 核心用途：高性能 Web Fuzzer，可做目录、参数、虚拟主机、POST 字段爆破。
- 位置/入口：`/usr/bin/ffuf`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
ffuf 的核心价值是：高性能 Web Fuzzer，可做目录、参数、虚拟主机、POST 字段爆破。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
ffuf -u http://target/FUZZ -w wordlist.txt
```
```bash
ffuf -u http://target/ -H "Host: FUZZ.target" -w vhosts.txt
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

