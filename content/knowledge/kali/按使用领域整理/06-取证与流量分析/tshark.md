---
title: "tshark"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
- 原始文档：[tshark.md](../../tshark/)
- 原文使用领域：流量分析 / Forensics
- 核心用途：Wireshark 的命令行版，用于过滤、统计、批量解析 pcap。
- 位置/入口：`/usr/bin/tshark`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
tshark 的核心价值是：Wireshark 的命令行版，用于过滤、统计、批量解析 pcap。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
tshark -r traffic.pcap -Y "http"
```
```bash
tshark -r traffic.pcap -T fields -e ip.src -e http.host -e http.request.uri
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

