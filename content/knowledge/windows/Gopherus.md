---
title: "Gopherus"
lastmod: 2026-04-12T00:37:38+08:00
draft: false
---
- 平台：Windows（D:\tool）
- 使用领域：CTF Web / SSRF / Gopher
- 主要用途：生成 gopher payload，常用于 SSRF 打 Redis/MySQL/FastCGI 等协议。
- 工具位置：`D:\tool\CTF\Web\Gopherus-master\gopherus.py`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

Gopherus 的核心价值是：生成 gopher payload，常用于 SSRF 打 Redis/MySQL/FastCGI 等协议。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
python gopherus.py --exploit redis
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### gopherus --help

```text
D:\tool\CTF\Web\Gopherus-master\gopherus.py:32: SyntaxWarning: invalid escape sequence '\ '
  /   \  ___ /  _ \\\\____ \|  |  \_/ __ \_  __ \  |  \/  ___/
  File "D:\tool\CTF\Web\Gopherus-master\gopherus.py", line 28
    print colors.green + """
    ^^^^^^^^^^^^^^^^^^^^^^^^
SyntaxError: Missing parentheses in call to 'print'. Did you mean print(...)?
```

