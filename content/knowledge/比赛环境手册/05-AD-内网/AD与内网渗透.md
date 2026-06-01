---
title: "AD 与内网"
draft: false
---
## 常用工具

- `impacket-scripts`
- `netexec`
- `bloodhound`
- `responder`
- `nmap`
- `smbclient`
- `ldapsearch`

## 常见起手式

### 基础探测

```bash
nmap -sV -Pn target
netexec smb target
netexec ldap target
```

### 凭证验证

```bash
netexec smb target -u user -p pass
netexec winrm target -u user -p pass
```

### Impacket 常用

```bash
GetUserSPNs.py domain/user:pass -dc-ip dc_ip
secretsdump.py domain/user:pass@target
psexec.py domain/user:pass@target
wmiexec.py domain/user:pass@target
```

### BloodHound

```bash
bloodhound
```

## 比赛重点

- 先识别域环境、DC、命名规则和凭证形态
- 先收集，后利用，避免乱打把题面打坏
- NTLM、Kerberos、SMB、WinRM、LDAP 是高频入口

## AWDP/应急视角

- 看异常登录来源
- 看新增账号、提权痕迹、计划任务、服务
- 看共享目录、启动项、凭证残留

