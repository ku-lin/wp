---
title: "gobuster"
draft: false
---
- 原始文档：[gobuster.md](../../gobuster/)
- 原文使用领域：CTF Web / 网络
- 核心用途：目录、DNS、虚拟主机、S3/GCS bucket 等枚举爆破。
- 位置/入口：`/usr/bin/gobuster`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
gobuster 的核心价值是：目录、DNS、虚拟主机、S3/GCS bucket 等枚举爆破。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
gobuster dir -u http://target/ -w wordlist.txt -x php,txt
```
```bash
gobuster vhost -u http://target/ -w subdomains.txt --append-domain
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

