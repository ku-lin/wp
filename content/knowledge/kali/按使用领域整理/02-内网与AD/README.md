---
title: "README"
lastmod: 2026-04-24T14:56:16+08:00
draft: false
---
# 内网与 AD

面向域环境枚举、凭证获取、协议利用与横向移动。

## 包含工具
- [NetExec](netexec/)：NetExec（CME 后继）用于 SMB/LDAP/WinRM/MSSQL/SSH 等服务枚举、认证验证和横向。
- [Responder](responder/)：LLMNR/NBT-NS/MDNS 投毒与 NTLM 捕获工具，常用于内网凭证获取。
- [smbclient](smbclient/)：SMB/CIFS 命令行客户端，用于列共享、传文件、验证凭据。
- [BloodHound](bloodhound/)：Active Directory 权限关系图谱分析，配合 SharpHound / BloodHound.py 找攻击路径。
- [Impacket Scripts](impacket-scripts/)：Impacket 协议脚本套件，常用于 SMB/Kerberos/NTLM/MSSQL/远程执行/凭证导出。
- [ldapsearch](ldapsearch/)：LDAP 查询工具，枚举域用户、组、OU、SPN、策略等目录信息。

