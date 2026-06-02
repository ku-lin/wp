---
title: "AWDP、流量与加固"
lastmod: 2026-03-30T19:44:12+08:00
draft: false
---
## 常用工具

- `wireshark`
- `tshark`
- `tcpdump`
- `openvpn`
- `wireguard-tools`
- `ss`
- `journalctl`
- `systemctl`

## 抓包与分析

```bash
tcpdump -i any -nn
tshark -i any
wireshark
```

### 过滤示例

```bash
tcpdump -i any port 80
tshark -r capture.pcap -Y http
tshark -r capture.pcap -Y 'ip.addr==1.2.3.4'
```

## 服务排障

```bash
ss -antlp
systemctl status nginx
journalctl -u nginx -n 100 --no-pager
```

## 比赛时加固思路

1. 先确保服务存活。
2. 先封明显入口，再修业务漏洞。
3. 优先保留日志、样本、流量，别先删现场。
4. 配置改动要有回滚方案。

## 常看位置

- `/var/log/`
- `journalctl`
- Web 根目录与上传目录
- 定时任务、启动项、systemd 服务
- 反向代理与 WAF 配置

