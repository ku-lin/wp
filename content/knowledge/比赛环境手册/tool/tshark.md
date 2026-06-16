---
title: "tshark"
lastmod: 2026-04-02T23:54:26+08:00
draft: false
---
# TShark

这份文档按本机 `tshark -h` 输出整理，目标是贴近帮助页结构，覆盖抓包、读取、过滤、输出和统计相关选项。

## 工具定位
TShark 是 Wireshark 的命令行版本，适合在无图形环境下抓包、过滤、批量提取字段、导出对象和跑统计。

## 基本语法

```bash
tshark [选项]
```

## 抓包接口
- `-i <接口>`：指定抓包接口
- `-f <捕获过滤器>`：libpcap 语法的捕获过滤器
- `-s <snaplen>`：抓包截断长度
- `-p`：不启用混杂模式
- `-I`：启用 monitor 模式
- `-B <MiB>`：内核缓冲区大小
- `-y <链路类型>`：指定链路层类型
- `--time-stamp-type <类型>`：指定时间戳类型
- `-D`：列出接口
- `-L`：列出接口支持的链路层类型
- `--list-time-stamp-types`：列出时间戳类型

## 抓包显示与停止条件
- `--update-interval <毫秒>`：更新间隔
- `-c <数量>`：抓到指定数量后停止
- `-a <自动停止条件>`：自动停止

`-a` 支持的条件有：
- `duration:NUM`
- `filesize:NUM`
- `files:NUM`
- `packets:NUM`

## 环形缓冲区输出
- `-b <选项>`：环形缓冲区写文件

`-b` 支持的条件有：
- `duration:NUM`
- `filesize:NUM`
- `files:NUM`
- `packets:NUM`
- `interval:NUM`
- `printname:FILE`

## 远程抓包认证
- `-A <user>:<password>`：RPCAP 认证

## 输入文件
- `-r <文件>`：读取 pcap/pcapng 文件

## 处理与过滤
- `-2`：双遍分析
- `-M <数量>`：会话自动重置
- `-R <读过滤器>`：Read filter，需要配合 `-2`
- `-Y <显示过滤器>`：Display filter
- `-n`：关闭名称解析
- `-N <标志>`：启用指定名称解析
- `-d <layer_type>==<selector>,<protocol>`：Decode As
- `-H <hosts 文件>`：读取 hosts 条目并写入捕获文件
- `--enable-protocol <协议>`：启用某个协议解析器
- `--disable-protocol <协议>`：禁用某个协议解析器
- `--only-protocols <协议列表>`：只启用指定协议解析
- `--disable-all-protocols`：禁用全部协议解析
- `--enable-heuristic <名称>`：启用启发式协议解析
- `--disable-heuristic <名称>`：禁用启发式协议解析

## 输出到文件
- `-w <文件>`：写到 pcapng 文件
- `--capture-comment <注释>`：写入抓包注释
- `-C <配置文件>`：指定配置 profile
- `--global-profile`：使用全局 profile
- `-F <输出文件类型>`：指定输出格式

## 终端输出控制
- `-V`：输出完整协议树
- `-O <协议列表>`：仅输出指定协议的详细信息
- `-P`：写文件时也打印摘要
- `-S <分隔符>`：设置包之间的分隔符
- `-x`：输出十六进制和 ASCII
- `--hexdump <选项>`：细化 hexdump 行为
- `-T pdml|ps|psml|json|jsonraw|ek|tabs|text|fields|?`：指定文本输出格式
- `-j <协议过滤>`：限制 `ek|pdml|json` 输出的协议层
- `-J <协议过滤>`：设置顶层协议过滤
- `-e <字段>`：当 `-T fields` 时输出某字段，可重复使用
- `-E<option>=<value>`：设置 fields 输出风格
- `-t ...`：时间戳显示格式
- `-u s|hms`：秒显示格式
- `-l`：每个包后刷新 stdout
- `-q`：更安静
- `-Q`：只记录真正错误
- `-g`：输出文件允许组读
- `-W n`：写入额外网络地址解析信息

## `-E` 字段输出选项
- `bom=y|n`
- `header=y|n`
- `separator=/t|/s|<char>`
- `occurrence=f|l|a`
- `aggregator=,|/s|<char>`
- `quote=d|s|n`

## 扩展与统计
- `-X <key>:<value>`：扩展选项
- `-U <tap_name>`：PDU 导出模式
- `-z <统计项>`：运行统计
- `--export-objects <协议>,<目录>`：导出对象
- `--export-tls-session-keys <文件>`：导出 TLS 会话密钥
- `--color`：彩色输出
- `--no-duplicate-keys`：JSON 合并重复键
- `--elastic-mapping-filter <协议列表>`：限制 Elastic mapping
- `--temp-dir <目录>`：临时目录
- `--compress <类型>`：压缩输出文件

## 诊断日志
- `--log-level <级别>`
- `--log-fatal <级别>`
- `--log-domains <列表>`
- `--log-fatal-domains <列表>`
- `--log-debug <列表>`
- `--log-noisy <列表>`
- `--log-file <路径>`

## 其他通用选项
- `-h`：显示帮助
- `-v`：显示版本
- `-o <name>:<value>`：覆盖偏好设置
- `-K <keytab>`：Kerberos 解密使用的 keytab
- `-G [report]`：输出报告

## 常见组合

```bash
tshark -i any
tshark -r capture.pcap -Y http
tshark -r capture.pcap -T fields -e ip.src -e http.host
tshark -r capture.pcap -z io,phs
tshark -r capture.pcap --export-objects http,outdir
```

## 比赛提示
- 先用 `-Y` 缩小协议和主机范围，再谈字段提取
- 做批量取值时优先 `-T fields -e ...`
- 想把 Wireshark GUI 里的分析流程落成脚本，TShark 是第一选择

## 上游项目
- 官方手册：https://www.wireshark.org/docs/man-pages/tshark.html

