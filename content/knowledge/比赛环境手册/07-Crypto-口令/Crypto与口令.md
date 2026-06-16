---
title: "Crypto与口令"
lastmod: 2026-03-30T19:44:12+08:00
draft: false
---
# Crypto 与口令

## 常用工具

- `hashcat`
- `john`
- `hydra`
- `python3`
- `openssl`
- `hash-identifier` / `hashid`

## 起手式

### 识别哈希

```bash
hashid '5f4dcc3b5aa765d61d8327deb882cf99'
hash-identifier
```

### John

```bash
john hashes.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt
```

### Hashcat

```bash
hashcat -m 0 -a 0 hashes.txt /usr/share/wordlists/rockyou.txt
hashcat -m 1000 -a 0 ntlm.txt /usr/share/wordlists/rockyou.txt
```

### Hydra

```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://target
hydra -L users.txt -P pass.txt http-post-form "/login:user=^USER^&pass=^PASS^:F=login failed"
```

## 密码学题常见方向

- Base 系列、Hex、URL、Unicode
- XOR、移位、置换、查表
- RSA、AES、DES、RC4
- 哈希、签名、伪随机、填充

## 比赛建议

- 所有脚本先用 `python3` 快速复现
- 不确定算法时先从编码、异或、块长入手
- 暴力前先确认哈希类型、盐值和规则

