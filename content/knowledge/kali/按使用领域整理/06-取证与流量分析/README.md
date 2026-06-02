---
title: "取证与流量分析"
lastmod: 2026-04-24T14:53:41+08:00
draft: false
---
面向文件恢复、镜像取证、日志排查、流量抓取与样本检测。

## 包含工具
- [TestDisk](testdisk/)：分区表恢复、文件系统恢复、磁盘修复的交互式工具。
- [tcpdump](tcpdump/)：命令行抓包工具，适合服务器端快速抓取 pcap。
- [tshark](tshark/)：Wireshark 的命令行版，用于过滤、统计、批量解析 pcap。
- [YARA](yara/)：规则匹配工具，按字符串/十六进制/条件扫描文件和样本。
- [Wireshark](wireshark/)：图形化抓包与 pcap 分析工具。
- [foremost](foremost/)：基于文件头尾特征的数据雕复工具，常用于磁盘镜像或混合文件恢复。
- [binwalk](binwalk/)：固件与二进制 blob 扫描、识别内嵌文件、自动提取压缩包和文件系统。
- [journalctl](journalctl/)：systemd 日志查询工具，适合查服务启动、登录、异常报错时间线。
- [PDFiD](pdfid/)：PDF 快速静态筛查工具，适合做恶意文档排查、取证和应急响应中的首轮判断。
- [The Sleuth Kit](the-sleuth-kit/)：文件系统取证命令套件，fls/icat/mmls/istat/tsk_recover 等。
- [ExifTool](exiftool/)：ExifTool 元数据读取/修改工具，常用于图片、PDF、Office、音视频元信息分析。

