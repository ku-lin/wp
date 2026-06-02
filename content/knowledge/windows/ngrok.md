---
title: "ngrok"
lastmod: 2026-04-12T00:37:38+08:00
draft: false
---
- 平台：Windows（D:\tool）
- 使用领域：网络 / 隧道 / 回连
- 主要用途：内网穿透与公网回连隧道工具，比赛中可用于临时回连/调试服务。
- 工具位置：`D:\tool\CTF\Web\ngrok-v3-stable-windows-amd64\ngrok.exe`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

ngrok 的核心价值是：内网穿透与公网回连隧道工具，比赛中可用于临时回连/调试服务。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
ngrok.exe http 8000
```
```bash
ngrok.exe tcp 4444
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### ngrok help

```text
NAME:
  ngrok - tunnel local ports to public URLs and inspect traffic

USAGE:
  ngrok [command] [flags]

DESCRIPTION: 
  ngrok puts network services, apps and APIs online.

  ngrok exposes local networked services behinds NATs and firewalls to the
  public internet over a secure tunnel. Share local websites, build/test
  webhook consumers and self-host personal services.
  Detailed help for each command is available by adding '--help' to any command or with
  the 'ngrok help' command.

  Open https://dashboard.ngrok.com/obs/traffic-inspector to inspect traffic through your endpoints.


EXAMPLES: 
  # forward http traffic from assigned public URL to local port 80
  ngrok http 80

  # choose a URL instead of random assignment
  ngrok http 8080 --url https://baz.ngrok.dev

  # manipulate traffic to your endpoint with a traffic policy file
  ngrok http 8080 --url https://baz.ngrok.dev --traffic-policy-file tp.yml

  # forward to another address on the network instead of a local port
  ngrok http foo.local:3000

  # forward to a local https server
  ngrok http https://localhost:8443

  # forward TCP traffic (e.g. ssh) with an assigned public address
  ngrok tcp 22

  # load balance (in two terminals)
  ngrok http 80 --url https://api.example.com --pooling-enabled
  ngrok http 80 --url https://api.example.com --pooling-enabled

  # privately connect a service to the ngrok cloud.
  # then forward traffic from other endpoints in your account to it
  ngrok http 80 --url https://svc.internal
  ngrok tcp 5432 --url tcp://postgres.internal:5432

  # make your endpoint url addressable only from k8s clusters
  # where you've installed the ngrok k8s operator
  ngrok http 80 --url https://example.namespace --binding kubernetes

  # start multiple endpoints defined in the config file
  ngrok start foo bar baz

COMMANDS:
  api                            use ngrok agent as an api client
  completion                     generates shell completion code for bash or zsh
  config                         update or migrate ngrok's configuration file
  credits                        prints author and licensing information
  diagnose                       diagnose connection issues
  help                           Help about any command
  http                           start an HTTP tunnel
  service                        run and control an ngrok service on a target operating system
  start                          start endpoints or tunnels by name from the configuration file
  tcp                            start a TCP tunnel
  tls                            start a TLS tunnel
  update                         update ngrok to the latest version
  version                        print the version string

OPTIONS:
      --config strings    path to config files; they are merged if multiple
  -h, --help              help for ngrok
      --metadata string   opaque user-defined metadata for the tunnel session
  -v, --version           version for ngrok
```

