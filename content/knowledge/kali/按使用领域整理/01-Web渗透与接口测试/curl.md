---
title: "curl"
lastmod: 2026-04-27T15:10:35+08:00
draft: false
---
# curl

- 原始文档：[curl.md](../../curl/)
- 原文使用领域：Web / 网络
- 核心用途：命令行 HTTP/TCP 客户端，适合复现请求、带 Cookie/Header、上传下载和调接口。
- 位置/入口：`/usr/bin/curl`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
curl 的核心价值是：命令行 HTTP/TCP 客户端，适合复现请求、带 Cookie/Header、上传下载和调接口。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
curl -i http://target/
```
```bash
curl -X POST http://target/login -H "Content-Type: application/json" -d "{\"u\":\"admin\"}"
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

