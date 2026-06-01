---
title: "SSH-Terrapin-Attack"
draft: false
---
- 平台：Windows（D:\tool）
- 使用领域：Misc / SSH 安全检测
- 主要用途：Terrapin SSH 漏洞检测 PoC，用于判断 SSH 服务是否受相关降级攻击影响。
- 工具位置：`D:\tool\CTF\Misc\SSH-Terrapin-Attack-main\terrapin.py`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

SSH-Terrapin-Attack 的核心价值是：Terrapin SSH 漏洞检测 PoC，用于判断 SSH 服务是否受相关降级攻击影响。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
python terrapin.py 127.0.0.1 22
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### terrapin --help

```text
usage: terrapin.py [-h] -url URL [-v VERSION] [-t]

Simulate an SSH handshake with potential Terrapin manipulation.

options:
  -h, --help            show this help message and exit
  -url URL              URL of the SSH server.
  -v, --version VERSION
                        Client version (default: 2.0)
  -t, --truncated       Simulate a truncated server response.
```

