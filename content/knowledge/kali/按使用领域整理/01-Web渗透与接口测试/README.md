---
title: "Web 渗透与接口测试"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
面向站点探测、接口调试、目录爆破、SQL 注入与 Web Fuzz。

## 包含工具
- [gobuster](gobuster/)：目录、DNS、虚拟主机、S3/GCS bucket 等枚举爆破。
- [ffuf](ffuf/)：高性能 Web Fuzzer，可做目录、参数、虚拟主机、POST 字段爆破。
- [nikto](nikto/)：Web 服务器配置与常见漏洞扫描器，适合快速发现危险文件/配置。
- [wfuzz](wfuzz/)：Web 参数、目录、Header、认证等 Fuzz 工具。
- [sqlmap](sqlmap/)：自动化 SQL 注入检测与利用工具，可枚举库表、dump 数据、读写文件。
- [curl](curl/)：命令行 HTTP/TCP 客户端，适合复现请求、带 Cookie/Header、上传下载和调接口。
- [BurpSuite](burpsuite/)：HTTP/HTTPS 代理、抓包、改包、Repeater/Intruder 测试 Web 漏洞。
- [HTTPie](httpie/)：更易读的 HTTP 命令行客户端，适合调 API、构造 JSON 请求。
- [feroxbuster](feroxbuster/)：高速递归目录扫描器，适合目录爆破、状态码过滤、扩展名探测。
- [dirsearch](dirsearch/)：Web 目录与文件爆破工具，适合快速发现后台、备份文件、接口路径。

