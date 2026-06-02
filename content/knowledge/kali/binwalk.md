---
title: "binwalk"
lastmod: 2026-04-24T14:59:50+08:00
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Forensics / Misc / Firmware
- 主要用途：固件与二进制 blob 扫描、识别内嵌文件、自动提取压缩包和文件系统。
- 工具位置：`/usr/bin/binwalk`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/binwalk.md`

## binwalk 是什么

`binwalk` 可以把一个“看起来像一坨二进制”的文件快速拆开看结构。它的核心不是直接帮你完整还原固件，而是先通过特征库、压缩流识别、熵分析等方式告诉你：

- 文件里大概藏了哪些内容
- 哪些偏移位置可能有压缩包、文件系统、证书、脚本、镜像头
- 哪些区域像加密数据、压缩数据或随机数据
- 是否值得进一步提取、雕复、逆向

它特别适合下面几类题：

- 固件分析：路由器、摄像头、IoT 升级包、`firmware.bin`
- 杂项取证：从大文件里找压缩流、嵌套文件、PNG/ZIP/PDF/ELF
- 恶意样本初筛：先看样本里是否嵌了脚本、配置、压缩载荷
- CTF/Misc：题目给一个奇怪 blob，先判断里面到底有什么

## 比赛里怎么用

binwalk 最适合放在“第一轮结构侦察”阶段。推荐顺序通常是：

1. 先判断文件类型

```bash
file firmware.bin
strings -a firmware.bin | less
binwalk firmware.bin
```

先用 `file` 看粗类型，用 `strings` 看是否有明显文本、路径、版本号、口令线索，再用 `binwalk` 看内部有没有嵌套结构。

2. 看到压缩流或文件系统后再提取

```bash
binwalk -e firmware.bin
```

如果扫描结果里已经出现 `gzip`、`lzma`、`squashfs`、`cpio`、`uImage` 之类的特征，再开提取通常最稳。

3. 固件或容器很多层时递归处理

```bash
binwalk -eM firmware.bin
```

`-M` 会对提取出来的内容继续扫描，非常适合“固件里套文件系统，文件系统里再套压缩包”的情况。

4. 不确定有没有隐藏压缩流时看熵

```bash
binwalk -E firmware.bin
```

高熵区域往往意味着压缩、加密、打包或混淆，能帮助你判断下一步是切片、提取，还是转向密码学/逆向分析。

## 常见工作流

### 1. 基础扫描

```bash
binwalk firmware.bin
```

用途：

- 快速列出可识别特征
- 看到偏移位置和命中描述
- 决定后续要不要提取、切片、递归分析

### 2. 自动提取

```bash
binwalk -e firmware.bin
```

用途：

- 自动提取可识别类型
- 常见于 `gzip`、`lzma`、`zip`、文件系统、镜像结构

说明：

- 默认会在当前工作目录下创建提取结果
- 提取过程中可能调用外部解包工具

### 3. 递归提取

```bash
binwalk -eM firmware.bin
```

用途：

- 一层层继续扫描提取后的文件
- 对嵌套很多层的升级包最有用

适用场景：

- 路由器/摄像头固件
- 多层压缩包
- 镜像里嵌 `cpio`、`squashfs`、`ubifs` 等文件系统

### 4. 只雕数据不调用外部解包

```bash
binwalk -ez firmware.bin
```

用途：

- 只按偏移把数据 carve 出来
- 不执行外部 extractor

适用场景：

- 环境不完整，外部解包器缺失
- 想先保守地把数据切下来自己分析

### 5. 指定提取目录

```bash
binwalk -eM -C output firmware.bin
```

用途：

- 把提取结果统一放到 `output`
- 比赛中更方便整理目录，避免当前路径被一堆结果刷满

### 6. 只看某类结果

```bash
binwalk -y 'filesystem|lzma|gzip' firmware.bin
```

用途：

- 只保留你关心的结果
- 扫描结果很多时很好用

### 7. 排除噪声结果

```bash
binwalk -x 'certificate|copyright' firmware.bin
```

用途：

- 去掉明显低价值命中
- 提高阅读效率

### 8. 查原始 deflate / lzma 流

```bash
binwalk -X sample.bin
binwalk -Z sample.bin
```

用途：

- 常规签名没有命中时，补扫原始压缩流
- 适合某些没有标准头的压缩数据

### 9. 熵分析

```bash
binwalk -E firmware.bin
binwalk -EJ firmware.bin
```

用途：

- 看文件哪些区域更像压缩或加密数据
- `-J` 会把图保存为 PNG，便于对照偏移

判断思路：

- 熵很高：更像压缩、加密、打包、随机数据
- 熵很低：更像文本、空洞、规则结构

### 10. 指定偏移或范围扫描

```bash
binwalk -o 0x1000 -l 0x400000 firmware.bin
```

用途：

- 只扫某一段区域
- 文件很大时减少噪声和耗时

### 11. 搜特定字节序列

```bash
binwalk -R '\x50\x4b\x03\x04' sample.bin
```

用途：

- 手动找 ZIP 头、PNG 头、ELF 头等
- 配合十六进制查看定位嵌入对象

常见头：

- ZIP：`50 4b 03 04`
- PNG：`89 50 4e 47`
- ELF：`7f 45 4c 46`
- PDF：`25 50 44 46`

### 12. 二进制差异对比

```bash
binwalk -W old.bin new.bin
```

用途：

- 对比两个样本差异
- 分析升级包改了哪些区域

## 输出怎么看

最常见输出通常类似这样：

```text
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             uImage header, header size: 64 bytes, ...
64            0x40            LZMA compressed data, properties: 0x5D, ...
1048576       0x100000        Squashfs filesystem, little endian, ...
```

重点看三列：

- `DECIMAL`：十进制偏移
- `HEXADECIMAL`：十六进制偏移，比赛里更常用
- `DESCRIPTION`：命中的签名说明

看结果时的经验：

- 先关注文件系统、压缩流、镜像头、脚本语言、证书、ELF、配置格式
- 偏移相邻的多个命中，往往描述的是同一块数据的不同特征
- 命中不等于绝对正确，尤其是自定义格式或随机数据里可能有误报

## 常用参数说明

### 扫描类

- `-B, --signature`：按常见特征库扫描
- `-R, --raw=<str>`：按指定字节序列扫描
- `-A, --opcodes`：扫常见可执行 opcode 特征
- `-Y, --disasm`：尝试识别 CPU 架构
- `-k, --continue`：遇到一个命中后继续扫，不提前停
- `-x, --exclude=<str>`：排除某类结果
- `-y, --include=<str>`：只保留某类结果

### 提取类

- `-e, --extract`：自动提取已识别数据
- `-M, --matryoshka`：递归扫描提取结果
- `-d, --depth=<int>`：限制递归层数
- `-C, --directory=<str>`：指定提取目录
- `-z, --carve`：只切数据，不调用外部 extractor
- `-D, --dd=<type[:ext[:cmd]]>`：按指定匹配规则提取
- `-V, --subdirs`：按偏移分子目录保存
- `-n, --count=<int>`：限制提取文件数量
- `-j, --size=<int>`：限制单个提取文件大小

### 熵分析类

- `-E, --entropy`：计算熵
- `-F, --fast`：更快但更粗糙
- `-J, --save`：保存熵图
- `-N, --nplot`：不生成熵图
- `-H, --high=<float>`：高熵触发阈值
- `-L, --low=<float>`：低熵回落阈值

### 范围与输出控制

- `-o, --offset=<int>`：从某偏移开始扫
- `-l, --length=<int>`：只扫指定长度
- `-O, --base=<int>`：显示结果时附加基址
- `-f, --log=<file>`：写日志
- `-c, --csv`：CSV 输出
- `-q, --quiet`：静默
- `-v, --verbose`：详细输出

## 实战场景举例

### 场景 1：拿到路由器固件

推荐命令：

```bash
file firmware.bin
binwalk firmware.bin
binwalk -eM firmware.bin
```

重点关注：

- 是否有 `uImage`、`TRX`、`Squashfs`、`cramfs`、`cpio`
- 是否能提取出 `/etc/passwd`、脚本、配置文件、证书、Web 目录

### 场景 2：拿到一个大 blob，不知道里面是什么

推荐命令：

```bash
file blob.bin
strings -a blob.bin | less
binwalk blob.bin
binwalk -EJ blob.bin
```

重点关注：

- 是否有明显分段
- 高熵区前后是否有文件头
- 是否值得按偏移切片再单独分析

### 场景 3：怀疑样本里藏了压缩包

推荐命令：

```bash
binwalk sample.bin
binwalk -X sample.bin
binwalk -Z sample.bin
binwalk -ez sample.bin
```

重点关注：

- 常规签名是否漏掉了裸压缩流
- carve 出来的段是否能继续用 `file`、`7z`、`strings` 打开

### 场景 4：比较两个版本差异

推荐命令：

```bash
binwalk -W old.bin new.bin
```

适用场景：

- 升级前后固件差异
- 恶意样本不同变种比对

## 常见坑

- `binwalk` 命中的是“特征”，不是绝对真相。
- `-e` 提取依赖外部工具，环境缺少时可能扫描能命中，但解不出来。
- `-M` 很容易递归出大量文件，比赛时建议配合目录管理一起用。
- 高熵不一定就是加密，也可能只是压缩包。
- 某些自定义头或厂商私有格式不会被直接识别，这时要结合 `xxd`、`strings`、`file` 自己判断。
- 大文件上来就 `-eM` 可能很慢，先普通扫描通常更稳。

## 常见配合工具

- `file`：先判断整体文件类型
- `strings`：找文本线索、路径、口令、版本号
- `xxd`：按偏移看十六进制细节
- `foremost`：按头尾特征额外雕复
- `7z` / `tar` / `unsquashfs`：针对提取出来的内容继续解包
- `yara`：对提取结果做规则匹配

## 比赛里的简短口诀

可以把 binwalk 记成下面这个流程：

```text
先扫结构 -> 看偏移 -> 再提取 -> 递归挖 -> 配合 file/strings/xxd 验证
```

如果只记 4 条最常用命令，通常就是：

```bash
binwalk firmware.bin
binwalk -e firmware.bin
binwalk -eM firmware.bin
binwalk -EJ firmware.bin
```

## 完整参数帮助输出

### binwalk --help

```text
Binwalk v2.4.3
Original author: Craig Heffner, ReFirmLabs
https://github.com/OSPG/binwalk

Usage: binwalk [OPTIONS] [FILE1] [FILE2] [FILE3] ...

Disassembly Scan Options:
    -Y, --disasm                 Identify the CPU architecture of a file using the capstone disassembler
    -T, --minsn=<int>            Minimum number of consecutive instructions to be considered valid (default: 500)
    -k, --continue               Don't stop at the first match

Signature Scan Options:
    -B, --signature              Scan target file(s) for common file signatures
    -R, --raw=<str>              Scan target file(s) for the specified sequence of bytes
    -A, --opcodes                Scan target file(s) for common executable opcode signatures
    -m, --magic=<file>           Specify a custom magic file to use
    -b, --dumb                   Disable smart signature keywords
    -I, --invalid                Show results marked as invalid
    -x, --exclude=<str>          Exclude results that match <str>
    -y, --include=<str>          Only show results that match <str>

Extraction Options:
    -e, --extract                Automatically extract known file types
    -D, --dd=<type[:ext[:cmd]]>  Extract <type> signatures (regular expression), give the files an extension of <ext>, and execute <cmd>
    -M, --matryoshka             Recursively scan extracted files
    -d, --depth=<int>            Limit matryoshka recursion depth (default: 8 levels deep)
    -C, --directory=<str>        Extract files/folders to a custom directory (default: current working directory)
    -j, --size=<int>             Limit the size of each extracted file
    -n, --count=<int>            Limit the number of extracted files
    -0, --run-as=<str>           Execute external extraction utilities with the specified user's privileges
    -1, --preserve-symlinks      Do not sanitize extracted symlinks that point outside the extraction directory (dangerous)
    -r, --rm                     Delete carved files after extraction
    -z, --carve                  Carve data from files, but don't execute extraction utilities
    -V, --subdirs                Extract into sub-directories named by the offset

Entropy Options:
    -E, --entropy                Calculate file entropy
    -F, --fast                   Use faster, but less detailed, entropy analysis
    -J, --save                   Save plot as a PNG
    -Q, --nlegend                Omit the legend from the entropy plot graph
    -N, --nplot                  Do not generate an entropy plot graph
    -H, --high=<float>           Set the rising edge entropy trigger threshold (default: 0.95)
    -L, --low=<float>            Set the falling edge entropy trigger threshold (default: 0.85)

Binary Diffing Options:
    -W, --hexdump                Perform a hexdump / diff of a file or files
    -G, --green                  Only show lines containing bytes that are the same among all files
    -i, --red                    Only show lines containing bytes that are different among all files
    -U, --blue                   Only show lines containing bytes that are different among some files
    -u, --similar                Only display lines that are the same between all files
    -w, --terse                  Diff all files, but only display a hex dump of the first file

Raw Compression Options:
    -X, --deflate                Scan for raw deflate compression streams
    -Z, --lzma                   Scan for raw LZMA compression streams
    -P, --partial                Perform a superficial, but faster, scan
    -S, --stop                   Stop after the first result

General Options:
    -l, --length=<int>           Number of bytes to scan
    -o, --offset=<int>           Start scan at this file offset
    -O, --base=<int>             Add a base address to all printed offsets
    -K, --block=<int>            Set file block size
    -g, --swap=<int>             Reverse every n bytes before scanning
    -f, --log=<file>             Log results to file
    -c, --csv                    Log results to file in CSV format
    -t, --term                   Format output to fit the terminal window
    -q, --quiet                  Suppress output to stdout
    -v, --verbose                Enable verbose output
    -h, --help                   Show help output
    -a, --finclude=<str>         Only scan files whose names match this regex
    -p, --fexclude=<str>         Do not scan files whose names match this regex
    -s, --status=<int>           Enable the status server on the specified port

[NOTICE] Binwalk v2.x will reach EOL in 12/12/2025. Please migrate to binwalk v3.x
```

