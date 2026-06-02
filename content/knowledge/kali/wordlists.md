---
title: "wordlists"
lastmod: 2026-04-12T00:37:37+08:00
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：字典 / 密码爆破 / Web
- 主要用途：Kali 自带字典目录，常用于目录扫描和密码爆破。
- 工具位置：`/usr/share/wordlists`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/wordlists.md`

## 比赛中怎么用

wordlists 的核心价值是：Kali 自带字典目录，常用于目录扫描和密码爆破。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### find /usr/share/wordlists -maxdepth 2 \( -type f -o -type l \) | sort | head -n 180

```text
/usr/share/wordlists/dirb
/usr/share/wordlists/dirbuster
/usr/share/wordlists/fern-wifi
/usr/share/wordlists/john.lst
/usr/share/wordlists/metasploit
/usr/share/wordlists/nmap.lst
/usr/share/wordlists/rockyou.txt.gz
/usr/share/wordlists/seclists
/usr/share/wordlists/sqlmap.txt
/usr/share/wordlists/wfuzz
/usr/share/wordlists/wifite.txt
```

