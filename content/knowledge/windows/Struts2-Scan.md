---
title: "Struts2-Scan"
lastmod: 2026-04-12T00:37:39+08:00
draft: false
---
# Struts2-Scan

- 平台：Windows（D:\tool）
- 使用领域：CTF Web / Java / Struts2
- 主要用途：Struts2 漏洞扫描/利用脚本，适合 Java Web 靶场中验证历史 S2 漏洞。
- 工具位置：`D:\tool\CTF\Web\Struts2-Scan\Struts2Scan.py`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

Struts2-Scan 的核心价值是：Struts2 漏洞扫描/利用脚本，适合 Java Web 靶场中验证历史 S2 漏洞。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
python Struts2Scan.py -u http://target/
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### Struts2Scan -h

```text
D:\tool\CTF\Web\Struts2-Scan\Struts2Scan.py:1403: SyntaxWarning: invalid escape sequence '\ '
  / ___|| |_ _ __ _   _| |_ ___|___ \  / ___|  ___ __ _ _ __
Usage: Struts2Scan.py [OPTIONS]

  Struts2批量扫描利用工具

Options:
  -i, --info          漏洞信息介绍
  -v, --version       显示工具版本
  -u, --url TEXT      URL地址
  -n, --name TEXT     指定漏洞名称, 漏洞名称详见info
  -f, --file TEXT     批量扫描URL文件, 一行一个URL
  -d, --data TEXT     POST参数, 需要使用的payload使用{exp}填充, 如: name=test&passwd={exp}
  -c, --encode TEXT   页面编码, 默认UTF-8编码
  -p, --proxy TEXT    HTTP代理. 格式为http://ip:port
  -t, --timeout TEXT  HTTP超时时间, 默认10s
  -w, --workers TEXT  批量扫描进程数, 默认为10个进程
  --header TEXT       HTTP请求头, 格式为: key1=value1&key2=value2
  -e, --exec          进入命令执行shell
  --webpath           获取WEB路径
  -r, --reverse TEXT  反弹shell地址, 格式为ip:port
  --upfile TEXT       需要上传的文件路径和名称
  --uppath TEXT       上传的目录和名称, 如: /usr/local/tomcat/webapps/ROOT/shell.jsp
  -q, --quiet         关闭打印不存在漏洞的输出，只保留存在漏洞的输出
  -h, --help          Show this message and exit.
```

