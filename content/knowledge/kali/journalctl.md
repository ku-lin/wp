---
title: "journalctl"
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Linux 取证 / 应急响应
- 主要用途：systemd 日志查询工具，适合查服务启动、登录、异常报错时间线。
- 工具位置：`/usr/bin/journalctl`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/journalctl.md`

## 比赛中怎么用

journalctl 的核心价值是：systemd 日志查询工具，适合查服务启动、登录、异常报错时间线。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
journalctl -u ssh --since "2026-04-01"
```
```bash
journalctl -xe
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### journalctl --help

```text
journalctl [OPTIONS...] [MATCHES...]

Query the journal.

Source Options:
     --system                Show the system journal
     --user                  Show the user journal for the current user
  -M --machine=CONTAINER     Operate on local container
  -m --merge                 Show entries from all available journals
  -D --directory=PATH        Show journal files from directory
  -i --file=PATH             Show journal file
     --root=PATH             Operate on an alternate filesystem root
     --image=PATH            Operate on disk image as filesystem root
     --image-policy=POLICY   Specify disk image dissection policy
     --namespace=NAMESPACE   Show journal data from specified journal namespace

Filtering Options:
  -S --since=DATE            Show entries not older than the specified date
  -U --until=DATE            Show entries not newer than the specified date
  -c --cursor=CURSOR         Show entries starting at the specified cursor
     --after-cursor=CURSOR   Show entries after the specified cursor
     --cursor-file=FILE      Show entries after cursor in FILE and update FILE
  -b --boot[=ID]             Show current boot or the specified boot
  -u --unit=UNIT             Show logs from the specified unit
     --user-unit=UNIT        Show logs from the specified user unit
     --invocation=ID         Show logs from the matching invocation ID
  -I                         Show logs from the latest invocation of unit
  -t --identifier=STRING     Show entries with the specified syslog identifier
  -T --exclude-identifier=STRING
                             Hide entries with the specified syslog identifier
  -p --priority=RANGE        Show entries within the specified priority range
     --facility=FACILITY...  Show entries with the specified facilities
  -g --grep=PATTERN          Show entries with MESSAGE matching PATTERN
     --case-sensitive[=BOOL] Force case sensitive or insensitive matching
  -k --dmesg                 Show kernel message log from the current boot

Output Control Options:
  -o --output=STRING         Change journal output mode (short, short-precise,
                               short-iso, short-iso-precise, short-full,
                               short-monotonic, short-unix, verbose, export,
                               json, json-pretty, json-sse, json-seq, cat,
                               with-unit)
     --output-fields=LIST    Select fields to print in verbose/export/json modes
  -n --lines[=[+]INTEGER]    Number of journal entries to show
  -r --reverse               Show the newest entries first
     --show-cursor           Print the cursor after all the entries
     --utc                   Express time in Coordinated Universal Time (UTC)
  -x --catalog               Add message explanations where available
  -W --no-hostname           Suppress output of hostname field
     --no-full               Ellipsize fields
  -a --all                   Show all fields, including long and unprintable
  -f --follow                Follow the journal
     --no-tail               Show all lines, even in follow mode
     --truncate-newline      Truncate entries by first newline character
  -q --quiet                 Do not show info messages and privilege warning
     --synchronize-on-exit=BOOL
                             Wait for Journal synchronization before exiting

Pager Control Options:
     --no-pager              Do not pipe output into a pager
  -e --pager-end             Immediately jump to the end in the pager

Forward Secure Sealing (FSS) Options:
     --interval=TIME         Time interval for changing the FSS sealing key
     --verify-key=KEY        Specify FSS verification key
     --force                 Override of the FSS key pair with --setup-keys

Commands:
  -h --help                  Show this help text
     --version               Show package version
  -N --fields                List all field names currently used
  -F --field=FIELD           List all values that a specified field takes
     --list-boots            Show terse information about recorded boots
     --list-invocations      Show invocation IDs of specified unit
     --list-namespaces       Show list of journal namespaces
     --disk-usage            Show total disk usage of all journal files
     --vacuum-size=BYTES     Reduce disk usage below specified size
     --vacuum-files=INT      Leave only the specified number of journal files
     --vacuum-time=TIME      Remove journal files older than specified time
     --verify                Verify journal file consistency
     --sync                  Synchronize unwritten journal messages to disk
     --relinquish-var        Stop logging to disk, log to temporary file system
     --smart-relinquish-var  Similar, but NOP if log directory is on root mount
     --flush                 Flush all journal data from /run into /var
     --rotate                Request immediate rotation of the journal files
     --header                Show journal header information
     --list-catalog          Show all message IDs in the catalog
     --dump-catalog          Show entries in the message catalog
     --update-catalog        Update the message catalog database
     --setup-keys            Generate a new FSS key pair

See the journalctl(1) man page for details.
```

