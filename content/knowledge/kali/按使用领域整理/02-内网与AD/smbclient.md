---
title: "smbclient"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
- 原始文档：[smbclient.md](../../smbclient/)
- 原文使用领域：AD / 内网 / SMB
- 核心用途：SMB/CIFS 命令行客户端，用于列共享、传文件、验证凭据。
- 位置/入口：`未确认到可执行入口`
- 当前状态：未在 Kali PATH/常见目录中找到；文档保留用途和替代建议

## 速查总结
smbclient 的核心价值是：SMB/CIFS 命令行客户端，用于列共享、传文件、验证凭据。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
smbclient -L //10.0.0.5 -U user
```
```bash
smbclient //10.0.0.5/share -U user
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

