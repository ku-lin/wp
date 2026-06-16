---
title: "yara"
lastmod: 2026-04-12T00:37:37+08:00
draft: false
---
# yara

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Forensics / Malware
- 主要用途：规则匹配工具，按字符串/十六进制/条件扫描文件和样本。
- 工具位置：`/usr/bin/yara`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/yara.md`

## 比赛中怎么用

yara 的核心价值是：规则匹配工具，按字符串/十六进制/条件扫描文件和样本。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
yara rule.yar sample.bin
```
```bash
yara -r rules/ samples/
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### yara --help

```text
YARA 4.5.5, the pattern matching swiss army knife.
Usage: yara [OPTION]... [NAMESPACE:]RULES_FILE... FILE | DIR | PID

Mandatory arguments to long options are mandatory for short options too.

       --atom-quality-table=FILE           path to a file with the atom quality table
  -C,  --compiled-rules                    load compiled rules
  -c,  --count                             print only number of matches
  -E,  --strict-escape                     warn on unknown escape sequences
  -d,  --define=VAR=VALUE                  define external variable
  -q,  --disable-console-logs              disable printing console log messages
       --fail-on-warnings                  fail on warnings
  -f,  --fast-scan                         fast matching mode
  -h,  --help                              show this help and exit
  -i,  --identifier=IDENTIFIER             print only rules named IDENTIFIER
       --max-process-memory-chunk=NUMBER   set maximum chunk size while reading process memory (default=1073741824)
  -l,  --max-rules=NUMBER                  abort scanning after matching a NUMBER of rules
       --max-strings-per-rule=NUMBER       set maximum number of strings per rule (default=10000)
  -x,  --module-data=MODULE=FILE           pass FILE's content as extra data to MODULE
  -n,  --negate                            print only not satisfied rules (negate)
  -N,  --no-follow-symlinks                do not follow symlinks when scanning
  -w,  --no-warnings                       disable warnings
  -m,  --print-meta                        print metadata
  -D,  --print-module-data                 print module data
  -M,  --module-names                      show module names
  -e,  --print-namespace                   print rules' namespace
  -S,  --print-stats                       print rules' statistics
  -s,  --print-strings                     print matching strings
  -L,  --print-string-length               print length of matched strings
  -X,  --print-xor-key                     print xor key and plaintext of matched strings
  -g,  --print-tags                        print tags
  -r,  --recursive                         recursively search directories
       --scan-list                         scan files listed in FILE, one per line
  -z,  --skip-larger=NUMBER                skip files larger than the given size when scanning a directory
  -k,  --stack-size=SLOTS                  set maximum stack size (default=16384)
  -t,  --tag=TAG                           print only rules tagged as TAG
  -p,  --threads=NUMBER                    use the specified NUMBER of threads to scan a directory
  -a,  --timeout=SECONDS                   abort scanning after the given number of SECONDS
  -v,  --version                           show version information

Send bug reports and suggestions to: vmalvarez@virustotal.com.
```

