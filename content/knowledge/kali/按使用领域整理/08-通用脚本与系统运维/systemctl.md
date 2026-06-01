---
title: "systemctl"
draft: false
---
- 原始文档：[systemctl.md](../../systemctl/)
- 原文使用领域：Linux 运维 / 应急响应
- 核心用途：systemd 服务管理，查看服务状态、启动/停止、分析失败原因。
- 位置/入口：`/usr/bin/systemctl`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
systemctl 的核心价值是：systemd 服务管理，查看服务状态、启动/停止、分析失败原因。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
systemctl status nginx
```
```bash
sudo systemctl restart nginx
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

