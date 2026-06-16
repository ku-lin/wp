---
title: "readelf"
lastmod: 2026-04-02T23:54:26+08:00
draft: false
---
# readelf

这份文档按本机 `readelf --help` 输出整理，目标是覆盖帮助页列出的主要能力和参数分类。

## 工具定位
readelf 用于读取 ELF 文件结构，适合查看 ELF 头、段、节、符号、重定位、动态段、版本信息和调试节。对 Linux 二进制分析来说，它通常比 `file` 更细，比 `objdump` 更结构化。

## 基本语法

```bash
readelf [选项] <elf 文件>
```

## 主要显示选项
- `-a, --all`：等价于 `-h -l -S -s -r -d -V -A -I --got-contents`
- `-h, --file-header`：显示 ELF 文件头
- `-l, --program-headers`：显示程序头
- `--segments`：`--program-headers` 的别名
- `-S, --section-headers`：显示节头
- `--sections`：`--section-headers` 的别名
- `-g, --section-groups`：显示节组
- `-t, --section-details`：显示节细节
- `-e, --headers`：等价于 `-h -l -S`
- `-s, --syms`：显示符号表
- `--symbols`：`--syms` 的别名
- `--dyn-syms`：显示动态符号表
- `--lto-syms`：显示 LTO 符号表
- `-n, --notes`：显示 note 节
- `-r, --relocs`：显示重定位
- `-u, --unwind`：显示 unwind 信息
- `-d, --dynamic`：显示动态段
- `-V, --version-info`：显示版本节
- `-A, --arch-specific`：显示架构相关信息
- `-c, --archive-index`：显示归档中的符号/文件索引
- `-D, --use-dynamic`：显示符号时使用动态段信息
- `-L, --lint` 或 `--enable-checks`：显示可能问题的告警

## 符号显示相关选项
- `--sym-base=[0|8|10|16]`：控制符号大小的显示进制
- `-C, --demangle[=STYLE]`：反修饰符号名
- `--no-demangle`：不反修饰
- `--recurse-limit`：启用反修饰递归限制
- `--no-recurse-limit`：关闭反修饰递归限制
- `-X, --extra-sym-info`：显示更多符号信息
- `--no-extra-sym-info`：不显示额外符号信息
- `-U[...]` 或 `--unicode=...`：控制 Unicode 显示模式

## 节内容导出
- `-x, --hex-dump=<编号|名称>`：按字节转储节内容
- `-p, --string-dump=<编号|名称>`：把节内容按字符串显示
- `-R, --relocated-dump=<编号|名称>`：转储应用重定位后的节内容
- `-z, --decompress`：转储前先解压
- `-j, --display-section=<名称|编号>`：显示指定节，可重复使用

## 调试信息与扩展格式
- `-w, --debug-dump[...]`：显示 DWARF 调试节
- `-wk, --debug-dump=links`：显示链接到独立 debuginfo 的节
- `-P, --process-links`：处理独立 debuginfo 文件中的非调试节
- `-wK, --debug-dump=follow-links`：跟随调试链接
- `-wN, --debug-dump=no-follow-links`：不跟随调试链接
- `--dwarf-depth=N`：限制显示的 DIE 深度
- `--dwarf-start=N`：从指定偏移开始显示 DIE
- `--ctf=<编号|名称>`：显示 CTF 信息
- `--ctf-parent=<名称>`：指定 CTF 父对象
- `--ctf-symbols=<编号|名称>`：指定 CTF 外部符号表
- `--ctf-strings=<编号|名称>`：指定 CTF 外部字符串表
- `--sframe[=NAME]`：显示 SFrame 信息，默认 `.sframe`

## 其他结构信息
- `-I, --histogram`：显示哈希桶分布直方图
- `--got-contents`：显示 GOT 节内容
- `-W, --wide`：允许输出宽度超过 80 字符
- `-T, --silent-truncation`：符号名截断时不追加 `[...]`

## `-w/--debug-dump` 细分项
- `a`：abbrev
- `A`：addr
- `r`：aranges
- `c`：cu_index
- `L`：decodedline
- `f`：frames
- `F`：frames-interp
- `g`：gdb_index
- `i`：info
- `o`：loc
- `m`：macro
- `p`：pubnames
- `t`：pubtypes
- `R`：Ranges
- `l`：rawline
- `s`：str
- `O`：str-offsets
- `u`：trace_abbrev
- `T`：trace_aranges
- `U`：trace_info

## 通用选项
- `@<文件>`：从文件中读取参数
- `-H, --help`：显示帮助
- `-v, --version`：显示版本

## 常见组合

```bash
readelf -h ./pwn
readelf -l ./pwn
readelf -S ./pwn
readelf -s ./pwn
readelf -d ./pwn
readelf -r ./pwn
```

## 比赛提示
- Pwn 题最常见的高频组合是 `-h`、`-l`、`-s`、`-d`
- 想确认动态链接器、依赖库、GOT/PLT 相关信息时，优先看 `-l` 和 `-d`
- 想确认节布局、壳或奇怪打包方式时，先看 `-S` 和 `-x`

## 上游项目
- GNU Binutils 文档：https://www.gnu.org/software/binutils/

