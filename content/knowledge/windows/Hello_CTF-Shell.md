---
title: "Hello_CTF-Shell"
lastmod: 2026-04-12T00:37:40+08:00
draft: false
---
# Hello_CTF-Shell

- 平台：Windows（D:\tool）
- 使用领域：Pwn / Shellcode 学习
- 主要用途：CTF shellcode 练习/生成相关项目。
- 工具位置：`D:\tool\CTF\Pwn\Hello_CTF-Shell\main.py`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

Hello_CTF-Shell 的核心价值是：CTF shellcode 练习/生成相关项目。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
python main.py --help
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### Hello_CTF-Shell --help

```text
********** CTF，启动！！！ **********
——反弹shell最廉价解决方案 By 探姬_Official

了解你的捍卫者：
>1 VPS，启动！(默认使用模块2)
>2 到底要选哪个呢？(自定义启动模块)
>3 全都烧光！(退还所有实例)
>>> Traceback (most recent call last):
  File "D:\tool\CTF\Pwn\Hello_CTF-Shell\main.py", line 267, in <module>
    choice = input(">>> ")
EOFError: EOF when reading a line
```

