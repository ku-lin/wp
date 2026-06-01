---
title: "hashid"
draft: false
---
- 原始文档：[hashid.md](../../hashid/)
- 原文使用领域：Crypto / 密码爆破
- 核心用途：命令行哈希类型识别工具，可辅助选择 john/hashcat 模式。
- 位置/入口：`/usr/bin/hashid`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
hashid 的核心价值是：命令行哈希类型识别工具，可辅助选择 john/hashcat 模式。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
hashid hash.txt
```
```bash
hashid -m hash.txt
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

