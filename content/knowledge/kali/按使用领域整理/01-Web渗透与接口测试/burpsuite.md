---
title: "BurpSuite"
lastmod: 2026-04-27T15:10:34+08:00
draft: false
---
- 原始文档：[burpsuite.md](../../burpsuite/)
- 原文使用领域：CTF Web / Web 渗透
- 核心用途：HTTP/HTTPS 代理、抓包、改包、Repeater/Intruder 测试 Web 漏洞。
- 位置/入口：`/usr/bin/burpsuite`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
burpsuite 的核心价值是：HTTP/HTTPS 代理、抓包、改包、Repeater/Intruder 测试 Web 漏洞。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
burpsuite
```
```bash
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

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

