---
title: "bloodhound"
lastmod: 2026-04-12T00:36:54+08:00
draft: false
---
# bloodhound

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：AD / 内网
- 主要用途：Active Directory 权限关系图谱分析，配合 SharpHound / BloodHound.py 找攻击路径。
- 工具位置：`/usr/bin/bloodhound`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/bloodhound.md`

## 比赛中怎么用

bloodhound 的核心价值是：Active Directory 权限关系图谱分析，配合 SharpHound / BloodHound.py 找攻击路径。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
bloodhound
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### bloodhound --help

```text
sudo: a terminal is required to read the password; either use ssh's -t option or configure an askpass helper
sudo: a password is required
```

