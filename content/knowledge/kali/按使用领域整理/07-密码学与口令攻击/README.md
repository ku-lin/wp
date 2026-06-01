---
title: "密码学与口令攻击"
draft: false
---
面向哈希识别、离线破解、在线爆破、TLS/编码与证书处理。

## 包含工具
- [hydra](hydra/)：在线口令爆破工具，支持 SSH/FTP/HTTP/SMB/RDP 等协议。
- [John the Ripper](john-the-ripper/)：John the Ripper，CPU 哈希破解、格式转换、规则爆破。
- [OpenSSL](openssl/)：加解密、证书、TLS 调试、哈希、base64、随机数等密码学工具箱。
- [hash-identifier](hash-identifier/)：交互式哈希类型识别工具，用于爆破前判断 hash 模式。
- [hashcat](hashcat/)：GPU/CPU 哈希破解工具，支持字典、掩码、规则、组合等攻击模式。
- [hashid](hashid/)：命令行哈希类型识别工具，可辅助选择 john/hashcat 模式。

