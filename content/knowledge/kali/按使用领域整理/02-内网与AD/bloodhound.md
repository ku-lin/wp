---
title: "BloodHound"
draft: false
---
- 原始文档：[bloodhound.md](../../bloodhound/)
- 原文使用领域：AD / 内网
- 核心用途：Active Directory 权限关系图谱分析，配合 SharpHound / BloodHound.py 找攻击路径。
- 位置/入口：`/usr/bin/bloodhound`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
bloodhound 的核心价值是：Active Directory 权限关系图谱分析，配合 SharpHound / BloodHound.py 找攻击路径。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
bloodhound
```
```bash
sudo: a terminal is required to read the password; either use ssh's -t option or configure an askpass helper
sudo: a password is required
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

