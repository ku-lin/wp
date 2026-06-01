---
title: "Wireshark"
draft: false
---
这份文档按本机 `wireshark -h` 输出整理，并补充了 GUI 场景下最关键的模块说明。

## 工具定位
Wireshark 是图形化抓包与协议分析工具，适合实时抓包、离线 pcap 分析、会话还原、协议细节查看、对象导出和统计。

## 基本语法

```bash
wireshark [选项] [输入文件]
```

## 抓包接口参数
- `-i <接口>`：指定抓包接口
- `-f <捕获过滤器>`：libpcap 语法捕获过滤器
- `-s <snaplen>`：抓包截断长度
- `-p`：禁用混杂模式
- `-I`：启用 monitor 模式
- `-B <MiB>`：设置内核缓冲区
- `-y <链路类型>`：指定链路层类型
- `--time-stamp-type <类型>`：指定时间戳类型
- `-D`：列出接口
- `-L`：列出链路层类型
- `--list-time-stamp-types`：列出时间戳类型

## 抓包显示与控制
- `-k`：启动后立刻开始抓包
- `-S`：抓包过程中实时刷新显示
- `-l`：配合 `-S` 自动滚动
- `--update-interval <毫秒>`：更新间隔

## 抓包停止条件
- `-c <数量>`：抓到指定数量后停止
- `-a <自动停止条件>`：自动停止

支持：
- `duration:NUM`
- `filesize:NUM`
- `files:NUM`
- `packets:NUM`

## 输出与环形缓冲区
- `-b <选项>`：环形缓冲区写文件
- `-w <文件>`：指定输出文件
- `-F <格式>`：指定抓包文件格式
- `--capture-comment <注释>`：写入抓包注释
- `--temp-dir <目录>`：临时目录

## RPCAP
- `-A <user>:<password>`：RPCAP 认证

## 输入文件与离线分析
- `-r <文件>`：打开输入文件
- `-R <读取过滤器>`：读入时过滤
- `-Y <显示过滤器>`：启动时直接应用显示过滤器
- `-g <编号>`：打开后跳到指定条目
- `-J <过滤器>`：跳到第一个命中的条目
- `-j`：与 `-J` 配合，反向搜索

## 解析与名称解析
- `-n`：关闭名称解析
- `-N <标志>`：启用指定名称解析
- `-d <layer_type>==<selector>,<protocol>`：Decode As
- `--enable-protocol <协议>`：启用指定协议
- `--disable-protocol <协议>`：禁用指定协议
- `--only-protocols <协议列表>`：仅启用指定协议
- `--disable-all-protocols`：禁用全部协议
- `--enable-heuristic <名称>`：启用启发式协议
- `--disable-heuristic <名称>`：禁用启发式协议

## 用户界面控制
- `-C <profile>`：使用指定配置 profile
- `-H`：抓包时隐藏 capture info 对话框
- `-t ...`：时间戳显示格式
- `-u s|hms`：秒显示格式
- `-X <key>:<value>`：扩展参数
- `-z <统计项>`：打开统计视图或统计功能
- `--fullscreen`：全屏启动
- `-P <key>:<path>`：设置个人配置或数据路径
- `-o <name>:<value>`：覆盖偏好或 recent 设置
- `-K <keytab>`：提供 Kerberos 解密 keytab

## 诊断日志
- `--log-level <级别>`
- `--log-fatal <级别>`
- `--log-domains <列表>`
- `--log-fatal-domains <列表>`
- `--log-debug <列表>`
- `--log-noisy <列表>`
- `--log-file <路径>`

## GUI 里最重要的功能模块
- Packet List：包列表，先按时间、源目地址、协议做筛选
- Packet Details：协议树，适合查看字段和逐层解析结果
- Packet Bytes：原始十六进制与 ASCII 区域
- Display Filter：显示过滤器，是 Wireshark 分析效率的核心
- Follow Stream：还原 TCP/UDP/WebSocket 等会话内容
- Statistics：协议层级、端点、会话、IO 图表、HTTP 统计等
- Export Objects：导出 HTTP、SMB、DICOM、TFTP 等对象
- Conversations / Endpoints：看谁和谁在通信、通信量多大

## 常见组合

```bash
wireshark capture.pcap
wireshark -k -i 1
wireshark -Y http capture.pcap
wireshark -n capture.pcap
```

## 比赛提示
- 先用显示过滤器把范围压到最小，再看协议树
- 找题解线索时，HTTP、DNS、SMB、TLS、FTP、邮件协议通常最值得优先看
- 导出对象和 Follow Stream 经常能直接给出 flag、样本或口令

## 上游项目
- 官方手册：https://www.wireshark.org/docs/man-pages/wireshark.html

