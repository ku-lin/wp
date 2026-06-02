---
title: "tcpdump"
lastmod: 2026-04-12T00:37:36+08:00
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：流量分析 / Forensics
- 主要用途：命令行抓包工具，适合服务器端快速抓取 pcap。
- 工具位置：`/usr/bin/tcpdump`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/tcpdump.md`

## 比赛中怎么用

tcpdump 的核心价值是：命令行抓包工具，适合服务器端快速抓取 pcap。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
sudo tcpdump -i eth0 -w out.pcap
```
```bash
sudo tcpdump -nn -r out.pcap host 10.0.0.5
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### tcpdump -h

```text
tcpdump version 4.99.6
libpcap version 1.10.6 (64-bit time_t, with TPACKET_V3)
OpenSSL 3.5.5 27 Jan 2026
64-bit build, 64-bit time_t
Usage: tcpdump [-AbdDefghHIJKlLnNOpqStuUvxX#] [ -B size ] [ -c count ] [--count]
		[ -C file_size ] [ -E algo:secret ] [ -F file ] [ -G seconds ]
		[ -i interface ] [ --immediate-mode ] [ -j tstamptype ]
		[ -M secret ] [ --number ] [ --print ] [ -Q in|out|inout ]
		[ -r file ] [ -s snaplen ] [ -T type ] [ --version ]
		[ -V file ] [ -w file ] [ -W filecount ] [ -y datalinktype ]
		[ --time-stamp-precision precision ] [ --micro ] [ --nano ]
		[ -z postrotate-command ] [ -Z user ] [ expression ]
```

