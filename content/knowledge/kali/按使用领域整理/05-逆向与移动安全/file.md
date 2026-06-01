---
title: "file"
draft: false
---
- 原始文档：[file.md](../../file/)
- 原文使用领域：Forensics / Reverse / Misc
- 核心用途：根据 magic bytes 判断文件类型、架构、是否 stripped、脚本/压缩格式等。
- 位置/入口：`/usr/bin/file`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结
file 的核心价值是：根据 magic bytes 判断文件类型、架构、是否 stripped、脚本/压缩格式等。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用示例
```bash
file sample.bin
```
```bash
file -k sample.bin
```

## 备注
需要完整参数、更多截图或更长的实战流程时，直接回看上面的原始文档。

