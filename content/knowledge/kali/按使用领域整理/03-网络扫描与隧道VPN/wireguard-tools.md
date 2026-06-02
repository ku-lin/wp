---
title: "WireGuard Tools"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
- 原始文档：[wireguard-tools.md](../../wireguard-tools/)
- 原文使用领域：比赛环境 / 网络
- 核心用途：WireGuard VPN 工具，包括 wg 和 wg-quick。
- 位置/入口：`/usr/bin/wg`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
wireguard-tools 的核心价值是：WireGuard VPN 工具，包括 wg 和 wg-quick。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
sudo wg show
```
```bash
sudo wg-quick up wg0
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

