---
title: "openssl"
lastmod: 2026-04-02T23:54:26+08:00
draft: false
---
# OpenSSL

这份文档按本机 `openssl help` 输出整理。OpenSSL 的命令体系非常大，所以这里按帮助页列出的命令族和常见用途做中文归档。

## 工具定位
OpenSSL 是密码学库与命令行工具集合，覆盖摘要、加密、证书、密钥、TLS 调试、签名与验证等能力。

## 基本语法

```bash
openssl <命令> [命令参数]
```

## 标准命令
- `asn1parse`：解析 ASN.1 结构
- `ca`：证书颁发机构管理
- `ciphers`：列出和筛选密码套件
- `cmp`：证书管理协议
- `cms`：CMS/PKCS#7 相关操作
- `configutl`：配置相关工具
- `crl`：处理证书吊销列表
- `crl2pkcs7`：CRL 转 PKCS#7
- `dgst`：摘要、签名、验签
- `dhparam`：生成或检查 DH 参数
- `dsa`：处理 DSA 密钥
- `dsaparam`：生成 DSA 参数
- `ec`：处理 EC 密钥
- `ecparam`：处理椭圆曲线参数
- `enc`：对称加密/解密
- `engine`：列出或控制加密引擎
- `errstr`：把错误码转成可读字符串
- `fipsinstall`：FIPS 安装相关
- `gendsa`：生成 DSA 私钥
- `genpkey`：生成私钥
- `genrsa`：生成 RSA 私钥
- `help`：显示帮助
- `info`：显示构建信息
- `kdf`：密钥派生
- `list`：列出算法、命令、选项等
- `mac`：消息认证码
- `nseq`：处理 Netscape 证书序列
- `ocsp`：OCSP 查询和响应
- `passwd`：生成密码哈希
- `pkcs12`：处理 PKCS#12 文件
- `pkcs7`：处理 PKCS#7 文件
- `pkcs8`：处理 PKCS#8 密钥
- `pkey`：通用私钥/公钥处理
- `pkeyparam`：处理公钥参数
- `pkeyutl`：公钥加解密、签名、验签
- `prime`：素数相关操作
- `rand`：生成随机数据
- `rehash`：重建证书哈希链接
- `req`：生成和处理 CSR/证书请求
- `rsa`：处理 RSA 密钥
- `rsautl`：RSA 低层工具
- `s_client`：TLS 客户端调试
- `s_server`：TLS 测试服务器
- `s_time`：TLS 性能测试
- `sess_id`：处理会话 ID
- `skeyutl`：对称密钥工具
- `smime`：S/MIME 处理
- `speed`：性能测试
- `spkac`：处理 SPKAC
- `srp`：SRP 相关操作
- `storeutl`：STORE 统一接口工具
- `ts`：时间戳服务
- `verify`：验证证书链
- `version`：显示版本
- `x509`：处理 X.509 证书

## 摘要命令
帮助页列出的摘要算法包括：
- `blake2b512`
- `blake2s256`
- `md4`
- `md5`
- `mdc2`
- `rmd160`
- `sha1`
- `sha224`
- `sha256`
- `sha3-224`
- `sha3-256`
- `sha3-384`
- `sha3-512`
- `sha384`
- `sha512`
- `sha512-224`
- `sha512-256`
- `shake128`
- `shake256`
- `sm3`

这些通常通过 `dgst` 或专用别名命令使用。

## 对称加密命令
帮助页列出的部分常见算法包括：
- AES：`aes-128-cbc`、`aes-128-ecb`、`aes-192-cbc`、`aes-192-ecb`、`aes-256-cbc`、`aes-256-ecb`
- ARIA：`aria-128/192/256` 的 `cbc`、`cfb`、`cfb1`、`cfb8`、`ctr`、`ecb`、`ofb`
- Base64：`base64`
- Blowfish：`bf`、`bf-cbc`、`bf-cfb`、`bf-ecb`、`bf-ofb`
- Camellia：`camellia-128/192/256-cbc/ecb`
- CAST：`cast`、`cast-cbc`、`cast5-cbc`、`cast5-cfb`、`cast5-ecb`、`cast5-ofb`
- DES：`des`、`des-cbc`、`des-cfb`、`des-ecb`、`des-ede`、`des-ede-cbc`、`des-ede-cfb`、`des-ede-ofb`
- 3DES：`des-ede3`、`des-ede3-cbc`、`des-ede3-cfb`、`des-ede3-ofb`、`des3`
- `desx`
- IDEA：`idea`、`idea-cbc`、`idea-cfb`、`idea-ecb`、`idea-ofb`
- RC2：`rc2`、`rc2-40-cbc`、`rc2-64-cbc`、`rc2-cbc`、`rc2-cfb`、`rc2-ecb`、`rc2-ofb`
- RC4：`rc4`、`rc4-40`
- SEED：`seed`、`seed-cbc`、`seed-cfb`、`seed-ecb`、`seed-ofb`
- SM4：`sm4-cbc`、`sm4-cfb`、`sm4-ctr`、`sm4-ecb`、`sm4-ofb`

## 最常用命令速记
- `openssl dgst -sha256 file`：计算摘要
- `openssl enc -aes-256-cbc -in in -out out`：对称加解密
- `openssl x509 -in cert.pem -text -noout`：看证书详情
- `openssl req -new -key key.pem -out req.csr`：生成 CSR
- `openssl s_client -connect host:443`：排查 TLS
- `openssl verify cert.pem`：验证证书链

## 比赛提示
- 做题最常用的通常只有 `dgst`、`enc`、`x509`、`req`、`s_client`
- 遇到 PEM、DER、P12、PKCS#7、PKCS#8 时，先确认对象类型，再选命令
- `openssl list` 很适合补查当前版本支持的算法和命令

## 上游项目
- 官方站点：https://www.openssl.org/

