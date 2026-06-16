---
title: "strings"
lastmod: 2026-04-02T23:54:26+08:00
draft: false
---
# strings

这份文档按本机 `strings --help` 输出整理，目标是覆盖帮助页里列出的主要选项和行为。

## 工具定位
strings 用于从文件中提取可打印字符串，适合对二进制、镜像、文档和样本做低成本信息收集。

## 基本语法

```bash
strings [选项] [文件]
```

不提供文件时默认从标准输入读取。

## 基本行为
- 默认扫描整个文件
- 默认提取长度至少为 4 的可显示字符串
- 结果通常按原始文件顺序输出

## 主要选项
- `-a` 或 `--all`：扫描整个文件，这是默认行为
- `-d` 或 `--data`：只扫描数据节
- `-f` 或 `--print-file-name`：每条字符串前打印文件名
- `-n <数字>`：最小字符串长度
- `--bytes=<数字>`：同 `-n`
- `-t --radix={o,d,x}`：打印字符串偏移，进制为八进制、十进制或十六进制
- `-w` 或 `--include-all-whitespace`：把所有空白字符都视为合法字符串字符
- `-o`：`--radix=o` 的别名
- `-T --target=<BFDNAME>`：指定二进制格式
- `-e --encoding={s,S,b,l,B,L}`：选择字符编码/宽度/端序
- `--unicode={default|locale|invalid|hex|escape|highlight}`：控制 UTF-8 Unicode 字符显示
- `-U {d|l|i|x|e|h}`：Unicode 显示模式的短参数形式
- `-s --output-separator=<字符串>`：设置字符串之间的分隔符
- `@<文件>`：从文件读取参数
- `-h --help`：显示帮助
- `-v` 或 `-V`：显示版本

## `-e` 编码参数含义
- `s`：7 位字符
- `S`：8 位字符
- `b`：16 位大端
- `l`：16 位小端
- `B`：32 位大端
- `L`：32 位小端

## 常见组合

```bash
strings -a sample.bin
strings -a sample.bin | grep -i flag
strings -t x sample.bin
strings -n 8 sample.bin
strings -e l sample.bin
```

## 输出怎么读
- 默认每行一条字符串
- 如果用了 `-t`，行首会出现偏移，方便回到十六进制工具里定位
- 如果用了 `-f`，适合批量样本同时处理

## 比赛提示
- 逆向题优先搜 `flag`、`http`、`token`、`error`、`admin` 之类的关键词
- 若怀疑宽字符或 UTF-16，别忘了切换 `-e l` 或 `-e b`
- 提取不到有用字符串时，不代表没有价值，可能只是被压缩、加壳或加密了

## 上游项目
- GNU Binutils 文档：https://www.gnu.org/software/binutils/

