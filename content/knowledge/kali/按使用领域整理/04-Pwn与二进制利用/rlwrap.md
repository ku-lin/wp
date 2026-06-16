---
title: "rlwrap"
lastmod: 2026-04-24T14:52:30+08:00
draft: false
---
# rlwrap

- 原始文档：[rlwrap.md](../../rlwrap/)
- 原文使用领域：Shell / Pwn
- 核心用途：给 nc、python shell 等交互程序补 readline、历史记录和方向键。
- 位置/入口：`/usr/bin/rlwrap`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
rlwrap 的核心价值是：给 nc、python shell 等交互程序补 readline、历史记录和方向键。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
rlwrap nc -lvnp 4444
```
```bash
Usage: rlwrap [options] command ...

Options:
  -a[password prompt]        --always-readline[=password prompt]
  -A                         --ansi-colour-aware
  -b  <chars>                --break-chars=<chars>
  -c                         --complete-filenames
  -C  <name|N>               --command-name=<name|N>
  -D  <0|1|2>                --history-no-dupes=<0|1|2>
  -e  <char|''>              --extra-char-after-completion=<char|''>
  -f  <completion list>      --file=<completion list>
  -g  <regexp>               --forget-matching=<regexp>
  -h                         --help
  -H  <file>                 --history-filename=<file>
  -i                         --case-insensitive
  -I                         --pass-sigint-as-sigterm
  -l  <file>                 --logfile=<file>
  -m[newline substitute]     --multi-line[=newline substitute]
  -M  <.ext>                 --multi-line-ext=<.ext>
  -n                         --no-warnings
  -N                         --no-children
  -o                         --one-shot
  -O  <regexp>               --only-cook=<regexp>
  -p[colour]                 --prompt-colour[=colour]
  -P  <input>                --pre-given=<input>
  -q  <chars>                --quote-characters=<chars>
  -r                         --remember
  -R                         --renice
  -s  <N>                    --histsize=<N> (negative: readonly)
  -S  <prompt>               --substitute-prompt=<prompt>
  -t  <name>                 --set-term-name=<name>
  -U                         --mirror-arguments
  -v                         --version
  -w  <N>                    --wait-before-prompt=<N> (msec, <0  : patient mode)
  -W                         --polling
  -X                         --skip-setctty
  -z  <filter command>       --filter=<filter command> ('rlwrap -z listing' writes a list of installed filters)

bug reports, suggestions, updates:
https://github.com/hanslub42/rlwrap
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

