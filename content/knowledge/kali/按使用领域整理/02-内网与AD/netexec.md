---
title: "netexec"
lastmod: 2026-04-24T14:56:06+08:00
draft: false
---
# NetExec

- 原始文档：[netexec.md](../../netexec/)
- 原文使用领域：AD / 内网
- 核心用途：NetExec（CME 后继）用于 SMB/LDAP/WinRM/MSSQL/SSH 等服务枚举、认证验证和横向。
- 位置/入口：`/usr/bin/netexec`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
netexec 的核心价值是：NetExec（CME 后继）用于 SMB/LDAP/WinRM/MSSQL/SSH 等服务枚举、认证验证和横向。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
netexec smb 10.0.0.0/24 -u user -p pass --shares
```
```bash
netexec winrm 10.0.0.5 -u user -p pass -x whoami
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

