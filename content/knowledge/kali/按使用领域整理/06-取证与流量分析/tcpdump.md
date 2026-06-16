---
title: "tcpdump"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
# tcpdump

- 原始文档：[tcpdump.md](../../tcpdump/)
- 原文使用领域：流量分析 / Forensics
- 核心用途：命令行抓包工具，适合服务器端快速抓取 pcap。
- 位置/入口：`/usr/bin/tcpdump`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
tcpdump 的核心价值是：命令行抓包工具，适合服务器端快速抓取 pcap。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
sudo tcpdump -i eth0 -w out.pcap
```
```bash
sudo tcpdump -nn -r out.pcap host 10.0.0.5
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

