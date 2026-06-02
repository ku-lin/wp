---
title: "Nmap"
lastmod: 2026-04-02T23:54:26+08:00
draft: false
---
这份文档按本机 `nmap -h` 输出和官方手册结构整理，目标是接近帮助页粒度，而不是简介版速查。

## 工具定位
Nmap 是网络发现、端口扫描、服务识别、脚本探测和基础指纹识别的综合工具。比赛里它通常用于起手梳理资产、确认入口、补充协议细节。

## 基本语法

```bash
nmap [扫描类型] [选项] {目标说明}
```

目标可以是主机名、单个 IP、CIDR 网段、IP 范围、输入文件或随机目标。

## 目标说明
- 直接写主机名或 IP，例如 `scanme.nmap.org`、`192.168.0.10`
- 写网段，例如 `192.168.0.0/24`
- 写 IP 范围，例如 `10.0.0-255.1-254`
- `-iL <文件>`：从文件读取目标列表
- `-iR <数量>`：随机生成目标
- `--exclude <目标>`：排除指定主机或网段
- `--excludefile <文件>`：从文件读取排除列表

## 主机发现
- `-sL`：仅列出目标，不真正扫描
- `-sn`：只做存活探测，不做端口扫描
- `-Pn`：把所有目标都当成在线，跳过主机发现
- `-PS/PA/PU/PY[端口列表]`：对指定端口发送 TCP SYN、TCP ACK、UDP 或 SCTP 探测
- `-PE/PP/PM`：使用 ICMP Echo、时间戳或子网掩码探测
- `-PO[协议列表]`：使用 IP 协议探测
- `-n`：不做 DNS 解析
- `-R`：总是进行 DNS 解析
- `--dns-servers <服务器列表>`：指定自定义 DNS 服务器
- `--system-dns`：强制使用系统 DNS 解析器
- `--traceroute`：对每个目标做路由追踪

## 扫描技术
- `-sS`：TCP SYN 扫描，最常用的半开扫描
- `-sT`：TCP Connect 扫描，无法使用原始套接字时常见
- `-sA`：TCP ACK 扫描，常用于防火墙状态判断
- `-sW`：TCP Window 扫描
- `-sM`：Maimon 扫描
- `-sU`：UDP 扫描
- `-sN`：TCP Null 扫描
- `-sF`：TCP FIN 扫描
- `-sX`：TCP Xmas 扫描
- `--scanflags <标志>`：自定义 TCP 标志位
- `-sI <僵尸主机[:探测端口]>`：Idle Scan
- `-sY`：SCTP INIT 扫描
- `-sZ`：SCTP COOKIE-ECHO 扫描
- `-sO`：IP 协议扫描
- `-b <FTP 中继主机>`：FTP bounce 扫描

## 端口范围与扫描顺序
- `-p <端口范围>`：只扫指定端口
- `--exclude-ports <端口范围>`：排除指定端口
- `-F`：快速模式，只扫较少的常见端口
- `-r`：按顺序扫描端口，不随机化
- `--top-ports <数量>`：扫描最常见的前 N 个端口
- `--port-ratio <比率>`：扫描出现频率高于给定比率的端口

端口语法支持按协议区分，例如：

```bash
-p U:53,111,137,T:21-25,80,139,8080,S:9
```

## 服务与版本识别
- `-sV`：探测开放端口上的服务和版本
- `--version-intensity <0-9>`：控制探测强度
- `--version-light`：轻量探测，相当于强度 2
- `--version-all`：尝试全部探针，相当于强度 9
- `--version-trace`：输出详细版本探测过程，便于调试

## NSE 脚本
- `-sC`：等价于 `--script=default`
- `--script=<脚本或分类>`：运行指定脚本、目录或分类
- `--script-args=<k=v,...>`：给脚本传参
- `--script-args-file=<文件>`：从文件加载脚本参数
- `--script-trace`：显示发送和接收的所有脚本数据
- `--script-updatedb`：更新脚本数据库
- `--script-help=<脚本或分类>`：查看脚本帮助

## 操作系统识别
- `-O`：启用操作系统识别
- `--osscan-limit`：只对更有希望识别的目标做 OS 探测
- `--osscan-guess`：更激进地猜测操作系统

## 性能与时序
- `-T<0-5>`：时序模板，数值越大通常越快
- `--min-hostgroup / --max-hostgroup <大小>`：并行主机扫描分组大小
- `--min-parallelism / --max-parallelism <数量>`：并行探针数量
- `--min-rtt-timeout / --max-rtt-timeout / --initial-rtt-timeout <时间>`：控制 RTT 超时
- `--max-retries <次数>`：限制探针重传次数
- `--host-timeout <时间>`：目标超时放弃时间
- `--scan-delay / --max-scan-delay <时间>`：调整探针间隔
- `--min-rate <每秒数量>`：限制最低发包速率
- `--max-rate <每秒数量>`：限制最高发包速率

## 规避、防火墙与伪装
- `-f`：分片发送数据包
- `--mtu <值>`：指定分片 MTU
- `-D <诱饵列表>`：使用诱饵地址混淆真实来源
- `-S <IP>`：伪造源地址
- `-e <接口>`：指定网卡
- `-g` 或 `--source-port <端口>`：指定源端口
- `--proxies <URL 列表>`：通过 HTTP/SOCKS4 代理中继连接
- `--data <十六进制>`：附加自定义负载
- `--data-string <字符串>`：附加 ASCII 字符串负载
- `--data-length <字节数>`：附加随机数据
- `--ip-options <选项>`：设置 IP 选项
- `--ttl <值>`：设置 TTL
- `--spoof-mac <MAC/前缀/厂商>`：伪造 MAC 地址
- `--badsum`：使用错误校验和

## 输出控制
- `-oN <文件>`：普通文本输出
- `-oX <文件>`：XML 输出
- `-oS <文件>`：Script Kiddie 风格输出
- `-oG <文件>`：Grepable 输出
- `-oA <前缀>`：一次写出三种主要格式
- `-v`：提高详细程度，可重复使用
- `-d`：提高调试级别，可重复使用
- `--reason`：显示端口状态判断原因
- `--open`：只显示开放或可能开放的端口
- `--packet-trace`：显示收发的每一个数据包
- `--iflist`：显示本机接口和路由
- `--append-output`：追加写入输出文件
- `--resume <文件>`：恢复中断的扫描
- `--noninteractive`：禁用键盘交互
- `--stylesheet <路径或 URL>`：给 XML 指定 XSL 样式表
- `--webxml`：引用 Nmap 官方 XML 样式
- `--no-stylesheet`：不为 XML 关联样式表

## 其他全局选项
- `-6`：启用 IPv6 扫描
- `-A`：启用 OS 识别、版本识别、脚本扫描和 traceroute
- `--datadir <目录>`：指定 Nmap 数据目录
- `--send-eth`：使用原始以太网帧发送
- `--send-ip`：使用原始 IP 包发送
- `--privileged`：假定具有高权限
- `--unprivileged`：假定没有原始套接字权限
- `-V`：显示版本
- `-h`：显示帮助

## 输出内容怎么读
- `open`：端口开放，可以建立连接
- `closed`：端口可达但当前未开放服务
- `filtered`：被防火墙或 ACL 过滤，无法可靠判断
- `unfiltered`：主机可达，但当前扫描方式无法判断开放状态
- `open|filtered`：可能开放，也可能被过滤
- `closed|filtered`：可能关闭，也可能被过滤

## 常见组合

```bash
nmap -sV -Pn target
nmap -p- -T4 target
nmap -A -T4 target
nmap --script smb* target
nmap -sn 192.168.0.0/24
```

## 比赛提示
- 外网题起手通常先 `-sV -Pn`，确认入口后再决定是否全端口
- 内网环境更要控制节奏，`-A` 和大范围 NSE 很容易制造噪声
- 扫描结果最好同时保留文本和 XML，后续好复盘也好给别的脚本继续处理

## 上游项目
- 官方手册：https://nmap.org/book/man.html

