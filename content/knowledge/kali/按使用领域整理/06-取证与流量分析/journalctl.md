---
title: "journalctl"
draft: false
---
- 原始文档：[journalctl.md](../../journalctl/)
- 原文使用领域：Linux 取证 / 应急响应
- 核心用途：systemd 日志查询工具，适合查服务启动、登录、异常报错时间线。
- 位置/入口：`/usr/bin/journalctl`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
journalctl 的核心价值是：systemd 日志查询工具，适合查服务启动、登录、异常报错时间线。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
journalctl -u ssh --since "2026-04-01"
```
```bash
journalctl -xe
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

