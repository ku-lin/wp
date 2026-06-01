---
title: "Pwn 与二进制利用"
draft: false
---
面向 ELF 分析、漏洞利用、libc 匹配、ROP 构造与 exploit 开发。

## 包含工具
- [readelf](readelf/)：查看 ELF 头、段、节、符号、重定位、动态链接信息。
- [pwntools](pwntools/)：pwntools 命令行入口和 Python 库，用于 exploit 交互、ROP、shellcode、ELF 分析。
- [patchelf](patchelf/)：修改 ELF interpreter、RPATH/RUNPATH、依赖库等，常用于指定题目 libc。
- [seccomp-tools](seccomp-tools/)：分析、反汇编、模拟 seccomp-bpf 规则，判断系统调用限制。
- [ROPgadget](ropgadget/)：在 ELF/PE/Mach-O/Raw 中搜索 ret、syscall、jmp 等 gadget，为 ROP 链拼装零件。
- [rlwrap](rlwrap/)：给 nc、python shell 等交互程序补 readline、历史记录和方向键。
- [one_gadget](one-gadget/)：结合泄露的 libc 版本快速搜索可触发 execve("/bin/sh") 的 gadget，并整理常用 Pwn 命令流。
- [gdb-multiarch](gdb-multiarch/)：支持多架构目标的 GDB，常用于 ARM/MIPS 等交叉架构调试。
- [gdb](gdb/)：GNU 调试器，用于断点、单步、查看寄存器/内存、调试漏洞利用。
- [checksec](checksec/)：查看 ELF 的 NX、Canary、PIE、RELRO、Fortify 等保护状态。
- [objdump](objdump/)：二进制反汇编、节表/符号/重定位查看。
- [libc-database](libc-database/)：根据泄露函数地址反查 libc 版本，配合 one_gadget、pwntools 做 ret2libc 利用。
- [glibc-all-in-one](glibc-all-in-one/)：glibc/libc 收集与切换辅助项目，用于匹配远端 libc、下载调试符号。

