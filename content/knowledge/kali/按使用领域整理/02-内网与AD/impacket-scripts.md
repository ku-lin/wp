---
title: "impacket-scripts"
lastmod: 2026-04-24T14:56:06+08:00
draft: false
---
# Impacket Scripts

- 原始文档：[impacket-scripts.md](../../impacket-scripts/)
- 原文使用领域：AD / 内网 / 协议
- 核心用途：Impacket 协议脚本套件，常用于 SMB/Kerberos/NTLM/MSSQL/远程执行/凭证导出。
- 位置/入口：`/usr/bin/impacket-smbserver`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
impacket-scripts 的核心价值是：Impacket 协议脚本套件，常用于 SMB/Kerberos/NTLM/MSSQL/远程执行/凭证导出。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
impacket-smbserver share . -smb2support
```
```bash
impacket-secretsdump DOMAIN/user:pass@10.0.0.5
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

