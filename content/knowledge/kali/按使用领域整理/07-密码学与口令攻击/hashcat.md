---
title: "hashcat"
draft: false
---
- 原始文档：[hashcat.md](../../hashcat/)
- 原文使用领域：Crypto / 密码爆破 / Forensics
- 核心用途：GPU/CPU 哈希破解工具，支持字典、规则、掩码、组合、混合等攻击模式。
- 位置/入口：`/usr/bin/hashcat`
- 当前状态：已在 Kali SSH 环境中确认

## 这工具到底用来干什么

`hashcat` 不是“自动出密码”的黑盒，而是一个高性能候选口令生成器 + 哈希校验器。比赛里常见用途有三类：

1. 已拿到哈希，想恢复明文口令。
2. 已知口令规则比较明显，想快速跑字典、规则、生日、手机号、弱口令组合。
3. 已知系统类型，想针对特定哈希格式下手，比如 Linux `shadow`、Windows NTLM、ZIP、Office、数据库哈希等。

最重要的思路不是先跑，而是先判断三件事：

1. 哈希类型是什么。
2. 候选密码长什么样。
3. 用字典、规则还是掩码更划算。

## 比赛里怎么快速判断

常见工作流：

1. 先看原始来源。
   例如 Linux 的 `/etc/shadow`、Web 数据库、SAM、浏览器导出、压缩包头、配置文件等。
2. 再看哈希长相。
   例如 `$6$...` 很像 Linux `sha512crypt`，`$1$...` 很像 `md5crypt`，`32` 位十六进制常见于 `MD5`，`32` 位大写十六进制常见于 `NTLM`。
3. 不确定时先识别。
   用 `hashcat --identify hash.txt` 或 `hashid`、`name-that-hash` 先确认。
4. 根据场景选攻击模式。
   人工设置弱口令时，优先字典 + 规则。
   明显是生日、手机号、短数字时，优先掩码。
   明显是“单词+数字”“年份+符号”时，优先混合模式。

## 最常用的几个参数

- `-m`：哈希类型。
- `-a`：攻击模式。
- `-o`：输出已破解结果。
- `--show`：显示已破解结果。
- `--username`：输入哈希文件前面带用户名时使用。
- `-r`：规则文件。
- `-O`：启用优化内核，通常更快，但会限制支持的最大密码长度。
- `-w`：工作负载，`1-4`，越大越激进。
- `--session` / `--restore`：断点恢复。
- `--status`：实时状态。
- `--force`：强制运行，不建议默认加，除非确认只是环境误报。

## 最常用的攻击模式

- `-a 0`：字典模式。
- `-a 1`：组合模式，两个字典互相拼接。
- `-a 3`：掩码爆破。
- `-a 6`：字典 + 掩码，例如 `password2025`。
- `-a 7`：掩码 + 字典，例如 `2025admin`。

## 比赛里最常见的几种打法

### 1. 纯字典

```bash
hashcat -m 0 -a 0 hashes.txt rockyou.txt
```

适合明显弱口令、常见口令、泄露字典复用场景。

### 2. 字典 + 规则

```bash
hashcat -m 0 -a 0 hashes.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule
```

适合口令在字典基础上做了少量变形，比如：

- 首字母大写
- 末尾加 `123`
- 末尾加 `!`
- 单词变复数

### 3. 掩码爆破

```bash
hashcat -m 0 -a 3 hashes.txt ?d?d?d?d?d?d
```

适合纯数字、固定长度、格式很明显的场景，比如：

- 6 位验证码
- 8 位数字口令
- `Aa123456`

### 4. 混合模式

```bash
hashcat -m 0 -a 6 hashes.txt rockyou.txt ?d?d?d
```

表示“字典词 + 3 位数字”，适合：

- `admin123`
- `qwerty666`
- `summer2024`

## 这题最相关的场景：Linux shadow

你现在这个题里，哈希来自 `E:\config\shadow`，格式类似：

```text
root:$6$xeMY8O4VOHMbbNqA$XEUOl1pPRwgud/rKwDbIeH9f7khOTmuUQwND3P9T35p14j9I0/Et4R9KdvwhW4AD1xKMve6K7Fwrab4MuPCPp.
```

这里的关键点：

- `root:` 是用户名。
- `$6$` 表示 `sha512crypt`。
- 对应的 hashcat 模式通常是 `-m 1800`。

如果你把整行直接保存成文件，比如 `shadow.hash`，推荐这样跑：

```bash
hashcat -m 1800 -a 0 --username shadow.hash rockyou.txt
```

如果你只保存哈希本体，不带 `root:`，则可直接：

```bash
hashcat -m 1800 -a 0 hash.txt rockyou.txt
```

查看结果：

```bash
hashcat -m 1800 --show --username shadow.hash
```

## 针对 shadow 的实战建议

不要一上来就全字符暴力。`sha512crypt` 比 `MD5/NTLM` 慢得多，盲跑很亏。更合理的顺序通常是：

1. 小字典直跑。
2. 字典 + `best64.rule`。
3. 结合题目环境自建字典。
4. 再考虑掩码。

针对这类服务器题，自建字典时优先放这些内容：

- 用户名：`root`、主机名、项目名、公司名、人名。
- 年份：`2024`、`2025`、`2026`。
- 常见后缀：`123`、`123456`、`@123`、`!`。
- 服务用途：`server`、`media`、`nas`、`docker`、`tower`。
- 中文拼音转英文。

例如：

```bash
hashcat -m 1800 -a 0 --username shadow.hash custom.txt -r /usr/share/hashcat/rules/best64.rule
```

## 常见字符集

- `?l`：小写字母
- `?u`：大写字母
- `?d`：数字
- `?s`：符号
- `?a`：大小写 + 数字 + 符号

例如：

```bash
hashcat -m 1800 -a 3 hash.txt ?u?l?l?l?l?l?d?d?d
```

表示“1 位大写 + 5 位小写 + 3 位数字”。

## 断点恢复和状态查看

长时间跑题时，建议从一开始就带会话名：

```bash
hashcat -m 1800 -a 0 --username shadow.hash rockyou.txt --session unraid_root --status
```

中断后恢复：

```bash
hashcat --restore --session unraid_root
```

只看已经破解出来的内容：

```bash
hashcat -m 1800 --show --username shadow.hash
```

只看还没破解的：

```bash
hashcat -m 1800 --left --username shadow.hash
```

## 比赛里很有用的几个排错点

### 1. `Token length exception`

通常说明：

- 哈希类型选错了
- 输入文件格式不对
- 多复制了空格、引号、换行或用户名分隔符

### 2. `Separator unmatched`

通常是：

- `username:hash` 这种格式忘了加 `--username`
- 哈希中原本自带分隔符，结果又手工处理坏了

### 3. 速度非常慢

先确认：

- 哈希类型是不是慢哈希
- 是否在 CPU 上跑
- 是否能开 `-O`
- 是否没必要直接暴力

### 4. 跑了很久没有结果

优先反思候选策略，不要只盯着算力。很多比赛不是靠暴力，而是靠：

- 环境线索
- 主机名
- 人名
- 时间点
- 业务关键词
- 弱口令习惯

## 推荐的最小实战模板

### 模板 1：先识别

```bash
hashcat --identify shadow.hash
```

### 模板 2：Linux shadow 先跑字典

```bash
hashcat -m 1800 -a 0 --username shadow.hash rockyou.txt --session shadow1 --status
```

### 模板 3：字典 + 规则

```bash
hashcat -m 1800 -a 0 --username shadow.hash rockyou.txt -r /usr/share/hashcat/rules/best64.rule --session shadow2 --status
```

### 模板 4：自定义字典 + 规则

```bash
hashcat -m 1800 -a 0 --username shadow.hash custom.txt -r /usr/share/hashcat/rules/best64.rule --session shadow3 --status
```

### 模板 5：查看结果

```bash
hashcat -m 1800 --show --username shadow.hash
```

## 备注

这份分领域笔记建议作为“比赛速用版”看，重点记住：

1. 先判断哈希类型。
2. 先设计候选口令来源。
3. 先字典和规则，再掩码和暴力。
4. 对 Linux `shadow` 中的 `$6$`，优先想到 `sha512crypt` 和 `-m 1800`。

需要完整参数或原始帮助输出时，再回看上面的原始文档：[hashcat.md](../../hashcat/)。

