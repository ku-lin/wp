---
title: "seclists"
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：字典 / Web / 内网
- 主要用途：SecLists 字典集合，目录、参数、用户名、密码、payload 都常用。
- 工具位置：`/usr/share/seclists`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/seclists.md`

## 比赛中怎么用

seclists 的核心价值是：SecLists 字典集合，目录、参数、用户名、密码、payload 都常用。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### find /usr/share/seclists -maxdepth 2 -type d | sort | head -n 160

```text
/usr/share/seclists
/usr/share/seclists/Discovery
/usr/share/seclists/Discovery/DNS
/usr/share/seclists/Discovery/File-System
/usr/share/seclists/Discovery/Infrastructure
/usr/share/seclists/Discovery/Mainframe
/usr/share/seclists/Discovery/SNMP
/usr/share/seclists/Discovery/Variables
/usr/share/seclists/Discovery/Web-Content
/usr/share/seclists/Fuzzing
/usr/share/seclists/Fuzzing/403
/usr/share/seclists/Fuzzing/Amounts
/usr/share/seclists/Fuzzing/Databases
/usr/share/seclists/Fuzzing/Dates
/usr/share/seclists/Fuzzing/LFI
/usr/share/seclists/Fuzzing/User-Agents
/usr/share/seclists/Fuzzing/XSS
/usr/share/seclists/Miscellaneous
/usr/share/seclists/Miscellaneous/Danish-Wordlists-n0kovo
/usr/share/seclists/Miscellaneous/List-Of-Swear-Words
/usr/share/seclists/Miscellaneous/Security-Question-Answers
/usr/share/seclists/Miscellaneous/Source-Code
/usr/share/seclists/Miscellaneous/Web
/usr/share/seclists/Miscellaneous/Words
/usr/share/seclists/Passwords
/usr/share/seclists/Passwords/Books
/usr/share/seclists/Passwords/Common-Credentials
/usr/share/seclists/Passwords/Cracked-Hashes
/usr/share/seclists/Passwords/Default-Credentials
/usr/share/seclists/Passwords/Honeypot-Captures
/usr/share/seclists/Passwords/Keyboard-Walks
/usr/share/seclists/Passwords/Leaked-Databases
/usr/share/seclists/Passwords/Malware
/usr/share/seclists/Passwords/Permutations
/usr/share/seclists/Passwords/PHP-Hashes
/usr/share/seclists/Passwords/Software
/usr/share/seclists/Passwords/WiFi-WPA
/usr/share/seclists/Passwords/Wikipedia
/usr/share/seclists/Pattern-Matching
/usr/share/seclists/Pattern-Matching/Source-Code-(PHP)
/usr/share/seclists/Payloads
/usr/share/seclists/Payloads/Anti-Virus
/usr/share/seclists/Payloads/File-Names
/usr/share/seclists/Payloads/Flash
/usr/share/seclists/Payloads/Images
/usr/share/seclists/Payloads/Zip-Bombs
/usr/share/seclists/Payloads/Zip-Traversal
/usr/share/seclists/Usernames
/usr/share/seclists/Usernames/Honeypot-Captures
/usr/share/seclists/Usernames/Names
/usr/share/seclists/Web-Shells
/usr/share/seclists/Web-Shells/CFM
/usr/share/seclists/Web-Shells/FuzzDB
/usr/share/seclists/Web-Shells/JSP
/usr/share/seclists/Web-Shells/laudanum-1.0
/usr/share/seclists/Web-Shells/Magento
/usr/share/seclists/Web-Shells/PHP
/usr/share/seclists/Web-Shells/Vtiger
/usr/share/seclists/Web-Shells/WordPress
```

