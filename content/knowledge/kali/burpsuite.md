---
title: "burpsuite"
lastmod: 2026-04-12T00:36:54+08:00
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：CTF Web / Web 渗透
- 主要用途：HTTP/HTTPS 代理、抓包、改包、Repeater/Intruder 测试 Web 漏洞。
- 工具位置：`/usr/bin/burpsuite`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/burpsuite.md`

## 比赛中怎么用

burpsuite 的核心价值是：HTTP/HTTPS 代理、抓包、改包、Repeater/Intruder 测试 Web 漏洞。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
burpsuite
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### burpsuite --help

```text
[warning] /usr/bin/burpsuite: No JAVA_CMD set for run_java, falling back to JAVA_CMD = java
Usage:
--help                            Print this message
--version                         Print version details
--disable-extensions              Prevent loading of extensions on startup
--diagnostics                     Print diagnostic information
--use-defaults                    Start with default settings
--collaborator-server             Run in Collaborator server mode
--collaborator-config             Specify Collaborator server configuration file; defaults to collaborator.config
--data-dir                        Specify data directory
--project-file                    Open the specified project file; this will be created as a new project if the file does not exist
--developer-extension-class-name  Fully qualified name of locally-developed extension class; extension will be loaded from the classpath
--config-file                     Load the specified project configuration file(s); this option may be repeated to load multiple files
--user-config-file                Load the specified user configuration file(s); this option may be repeated to load multiple files
--auto-repair                     Automatically repair a corrupted project file specified by the --project-file option
--unpause-spider-and-scanner      Do not pause the Spider and Scanner when opening an existing project
--disable-auto-update             Suppress auto update behavior
```

