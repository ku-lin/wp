---
title: "objdump"
lastmod: 2026-04-02T23:54:26+08:00
draft: false
---
这份文档按本机 `objdump --help` 输出整理，目标是尽量覆盖帮助页里出现的主要开关，而不是只给几条常用命令。

## 工具定位
objdump 是 GNU Binutils 中的目标文件分析工具，用于查看头部、节区、符号、重定位、反汇编、调试信息等内容。它是逆向和 Pwn 起手分析的重要基础命令。

## 基本语法

```bash
objdump [选项] <文件>
```

至少要指定一个主要显示开关，否则只会输出帮助。

## 主要显示开关
- `-a, --archive-headers`：显示归档文件头信息
- `-f, --file-headers`：显示整体文件头
- `-p, --private-headers`：显示格式私有头部
- `-P, --private=OPT,...`：显示对象格式私有内容
- `-h, --section-headers`：显示节头
- `-x, --all-headers`：显示所有头部
- `-d, --disassemble`：反汇编可执行节
- `-D, --disassemble-all`：反汇编所有节
- `--disassemble=<符号>`：从指定符号开始反汇编
- `-S, --source`：把源代码和反汇编交织显示
- `--source-comment[=<文本>]`：给源代码行加前缀
- `-s, --full-contents`：显示请求节的完整内容
- `-Z, --decompress`：显示前先解压节
- `-g, --debugging`：显示调试信息
- `-e, --debugging-tags`：以 ctags 风格显示调试信息
- `-G, --stabs`：显示 STABS 信息
- `-W, --dwarf[...]`：显示 DWARF 调试节
- `-Wk, --dwarf=links`：显示链接到独立 debuginfo 的节
- `-WK, --dwarf=follow-links`：跟随独立调试信息链接
- `-WN, --dwarf=no-follow-links`：不跟随独立调试信息链接
- `-L, --process-links`：处理独立调试文件中的非调试节
- `--ctf[=SECTION]`：显示 CTF 信息
- `--sframe[=SECTION]`：显示 SFrame 信息
- `-t, --syms`：显示符号表
- `-T, --dynamic-syms`：显示动态符号表
- `-r, --reloc`：显示重定位表
- `-R, --dynamic-reloc`：显示动态重定位表

## 常用辅助选项
- `-b, --target=BFDNAME`：指定输入目标格式
- `-m, --architecture=MACHINE`：指定架构
- `-j, --section=NAME`：只显示某个节
- `-M, --disassembler-options=OPT`：给反汇编器传选项
- `-EB, --endian=big`：按大端解释
- `-EL, --endian=little`：按小端解释
- `--file-start-context`：配合 `-S` 从文件开始补上下文
- `-I, --include=DIR`：增加源代码搜索目录
- `-l, --line-numbers`：显示行号和文件名
- `-F, --file-offsets`：显示文件偏移
- `-C, --demangle[=STYLE]`：反修饰符号名
- `--recurse-limit`：限制 demangle 递归
- `--no-recurse-limit`：关闭 demangle 递归限制
- `-w, --wide`：宽输出
- `-U[...]` 或 `--unicode=...`：控制 UTF-8 显示方式
- `-z, --disassemble-zeroes`：反汇编时不跳过全零块
- `--start-address=ADDR`：只处理地址大于等于该值的内容
- `--stop-address=ADDR`：只处理地址小于该值的内容
- `--no-addresses`：不显示地址
- `--prefix-addresses`：显示完整地址
- `--show-raw-insn / --no-show-raw-insn`：是否显示原始机器码
- `--insn-width=WIDTH`：每行显示多少字节
- `--adjust-vma=OFFSET`：为显示地址统一加偏移
- `--show-all-symbols`：反汇编时显示同地址所有符号
- `--special-syms`：在符号转储中包含特殊符号
- `--inlines`：显示源代码内联展开
- `--prefix=PREFIX`：给 `-S` 的绝对路径加前缀
- `--prefix-strip=LEVEL`：截断 `-S` 路径前缀层级
- `--dwarf-depth=N`：限制 DIE 深度
- `--dwarf-start=N`：从指定偏移开始显示 DIE
- `--dwarf-check`：做额外 DWARF 一致性检查
- `--ctf-parent=NAME`：设置 CTF 父对象
- `--visualize-jumps`：用 ASCII 线显示跳转
- `--visualize-jumps=color`：彩色显示跳转
- `--visualize-jumps=extended-color`：扩展色显示跳转
- `--visualize-jumps=off`：关闭跳转可视化
- `--disassembler-color=off|terminal|on|extended`：控制反汇编颜色输出

## `-W/--dwarf` 细分项
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

## x86/x86-64 常见反汇编选项
这些通常通过 `-M` 传入，多个值用逗号分隔。

- `x86-64`：按 64 位模式反汇编
- `i386`：按 32 位模式反汇编
- `i8086`：按 16 位模式反汇编
- `att`：AT&T 语法
- `intel`：Intel 语法
- `att-mnemonic`：AT&T 助记符
- `intel-mnemonic`：Intel 助记符
- `addr64`、`addr32`、`addr16`：地址宽度
- `data32`、`data16`：数据宽度
- `suffix`：总是显示 AT&T 后缀
- `amd64`：AMD64 ISA
- `intel64`：Intel64 ISA

## 私有格式选项
帮助页里明确给出了 PE 文件的私有选项：
- `header`：显示文件头
- `sections`：显示节头

## 常见组合

```bash
objdump -Mintel -d ./pwn
objdump -x ./pwn
objdump -t ./pwn
objdump -R ./pwn
objdump -j .plt -d ./pwn
```

## 比赛提示
- 只想看结构时先 `-x`，只想看代码时再 `-d`
- Pwn 题里 `-Mintel -d` 和 `-R`、`-t` 组合最实用
- 如果反汇编看着不对，先检查架构、端序和节区选择是否正确

## 上游项目
- GNU Binutils 文档：https://www.gnu.org/software/binutils/

