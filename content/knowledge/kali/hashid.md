---
title: "hashid"
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Crypto / 密码爆破
- 主要用途：命令行哈希类型识别工具，可辅助选择 john/hashcat 模式。
- 工具位置：`/usr/bin/hashid`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/hashid.md`

## 比赛中怎么用

hashid 的核心价值是：命令行哈希类型识别工具，可辅助选择 john/hashcat 模式。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
hashid hash.txt
```
```bash
hashid -m hash.txt
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### hashid --help

```text
usage: hashid.py [-h] [-e] [-m] [-j] [-o FILE] [--version] INPUT

Identify the different types of hashes used to encrypt data

positional arguments:
  INPUT               input to analyze (default: STDIN)

options:
  -e, --extended      list all possible hash algorithms including salted passwords
  -m, --mode          show corresponding Hashcat mode in output
  -j, --john          show corresponding JohnTheRipper format in output
  -o, --outfile FILE  write output to file
  -h, --help          show this help message and exit
  --version           show program's version number and exit

License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
```

