---
title: "Pwn"
draft: false
---
## 常用工具

- `gdb`
- `gdb-multiarch`
- `python3-pwntools`
- `checksec`
- `patchelf`
- `socat`
- `rlwrap`
- `strings` / `objdump` / `readelf`

## 起手检查

```bash
file ./pwn
checksec --file=./pwn
ldd ./pwn
readelf -h ./pwn
readelf -s ./pwn | head
```

## 调试常用

```bash
gdb ./pwn
gdb-multiarch ./pwn
```

```bash
python3 exploit.py
python3 -c "from pwn import *; print(cyclic(200))"
python3 -c "from pwn import *; print(cyclic_find(0x6161616c))"
```

## 常见思路

- 栈溢出：偏移、返回地址、ROP、ret2libc
- 堆题：chunk 布局、unlink、tcache、largebin
- 沙箱：syscall 过滤、文件描述符、ORW
- 格式化字符串：泄露地址、任意写
- glibc 题：libc 版本确认、符号与 gadgets 对齐

## 赛前建议

- 本地留一份 `glibc-all-in-one` 或常用 libc 索引
- 远程题优先确认是否需要 `socat`/`nc` 中转
- 题目给附件时把 `libc.so`、`ld.so`、`exp.py` 放同目录

