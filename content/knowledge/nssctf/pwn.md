---
title: "pwn"
lastmod: 2026-03-26T18:13:24+08:00
draft: false
---
- [P391 [SWPUCTF 2021 新生赛]whitegive_pwn](#p391-swpuctf-2021-%E6%96%B0%E7%94%9F%E8%B5%9Bwhitegive_pwn)

---

# P391 [SWPUCTF 2021 新生赛]whitegive_pwn
给了附件，下载看看

地址看起来是64位的系统

直接反编译一下，发现一个vuln函数存在注入点

shift+F12什么也找不着，这就说明是一个正经的libc偏移

找一个代码写一下就行

```plain

```

我只能说正常题目已经跑通了，但是这道题目不正常

没有rdi pop这个东西，什么鬼东西

所以Stage1 用 ret2csu 泄露 puts@got；Stage2 用 libc 里的 pop rdi  


