---
title: "OpenSSL"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
- 原始文档：[openssl.md](../../openssl/)
- 原文使用领域：Crypto / TLS / 编码
- 核心用途：加解密、证书、TLS 调试、哈希、base64、随机数等密码学工具箱。
- 位置/入口：`/usr/bin/openssl`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
openssl 的核心价值是：加解密、证书、TLS 调试、哈希、base64、随机数等密码学工具箱。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
openssl x509 -in cert.pem -text -noout
```
```bash
openssl s_client -connect target:443 -servername target
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

