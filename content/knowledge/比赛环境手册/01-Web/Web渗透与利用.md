---
title: "Web渗透与利用"
lastmod: 2026-03-30T19:44:12+08:00
draft: false
---
# Web

## 常用工具

- `burpsuite`：抓包、重放、爆破、宏、插件
- `sqlmap`：注入验证与自动化利用
- `ffuf`：目录、参数、虚拟主机爆破
- `gobuster`：目录、DNS、vhost 枚举
- `wfuzz`：参数模糊测试
- `feroxbuster`：递归目录爆破
- `dirsearch`：路径与备份文件探测
- `nikto`：基础弱点扫描
- `curl` / `httpie`：接口复现

## 常用起手式

### 目录探测

```bash
ffuf -u http://target/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt
gobuster dir -u http://target -w /usr/share/wordlists/dirb/common.txt
feroxbuster -u http://target -x php,txt,bak,zip
```

### 参数探测

```bash
ffuf -u "http://target/index.php?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -fs 0
wfuzz -c -z file,/usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt "http://target/index.php?FUZZ=test"
```

### 虚拟主机探测

```bash
ffuf -u http://target -H "Host: FUZZ.target.com" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
gobuster vhost -u http://target -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
```

## 做题顺序

1. 先确认入口：路径、参数、上传点、鉴权点、框架特征。
2. 再做信息收集：目录、响应头、JS、接口、子域名。
3. 最后才做利用：SQLi、SSTI、反序列化、文件上传、认证绕过、RCE。

## 比赛时重点别漏

- JS 里隐藏接口和路由
- 备份文件：`.bak`、`.swp`、`.zip`、`.tar.gz`
- 鉴权绕过：`X-Forwarded-For`、伪造 header、越权 ID
- 文件上传：MIME、后缀、解析链、图片马
- 数据库：联合注入、报错注入、布尔盲注、时间盲注

