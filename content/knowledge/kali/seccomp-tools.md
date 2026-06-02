---
title: "seccomp-tools"
lastmod: 2026-04-12T00:37:34+08:00
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Pwn / 沙箱
- 主要用途：分析、反汇编、模拟 seccomp-bpf 规则，判断系统调用限制。
- 工具位置：`/usr/local/bin/seccomp-tools`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/seccomp-tools.md`

## 比赛中怎么用

seccomp-tools 的核心价值是：分析、反汇编、模拟 seccomp-bpf 规则，判断系统调用限制。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
seccomp-tools dump ./chall
```
```bash
seccomp-tools disasm filter.bpf
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### seccomp-tools --help

```text
Usage: seccomp-tools [--version] [--help] <command> [<options>]

List of commands:

	asm	Seccomp bpf assembler.
	disasm	Disassemble seccomp bpf.
	dump	Automatically dump seccomp bpf from execution file(s).
	emu	Emulate seccomp rules.

See 'seccomp-tools <command> --help' to read about a specific subcommand.
```

### seccomp-tools dump --help

```text
dump - Automatically dump seccomp bpf from execution file(s).
NOTE : This function is only available on Linux.

Usage: seccomp-tools dump [exec] [options]
    -c, --sh-exec <command>          Executes the given command (via sh).
                                     Use this option if want to pass arguments or do pipe things to the execution file.
                                     e.g. use `-c "./bin > /dev/null"` to dump seccomp without being mixed with stdout.
    -f, --format FORMAT              Output format. FORMAT can only be one of <disasm|raw|inspect>.
                                     Default: disasm
    -l, --limit LIMIT                Limit the number of calling "prctl(PR_SET_SECCOMP)".
                                     The target process will be killed whenever its calling times reaches LIMIT.
                                     Default: 1
    -o, --output FILE                Output result into FILE instead of stdout.
                                     If multiple seccomp syscalls have been invoked (see --limit),
                                     results will be written to FILE, FILE_1, FILE_2.. etc.
                                     For example, "--output out.bpf" and the output files are out.bpf, out_1.bpf, ...
    -p, --pid PID                    Dump installed seccomp filters of the existing process.
                                     You must have CAP_SYS_ADMIN (e.g. be root) in order to use this option.
```

### seccomp-tools asm --help

```text
asm - Seccomp bpf assembler.

Usage: seccomp-tools asm IN_FILE [options]
    -o, --output FILE                Output result into FILE instead of stdout.
    -f, --format FORMAT              Output format. FORMAT can only be one of <inspect|raw|c_array|c_source|assembly>.
                                     Default: inspect
    -a, --arch ARCH                  Specify architecture.
                                     Supported architectures are <aarch64|amd64|i386|s390x>.
                                     Default: amd64
```

### seccomp-tools disasm --help

```text
disasm - Disassemble seccomp bpf.

Usage: seccomp-tools disasm BPF_FILE [options]
    -o, --output FILE                Output result into FILE instead of stdout.
    -a, --arch ARCH                  Specify architecture.
                                     Supported architectures are <aarch64|amd64|i386|s390x>.
                                     Default: amd64
        --[no-]bpf                   Display BPF bytes (code, jt, etc.).
                                     Default: true
        --[no-]arg-infer             Display syscall arguments with parameter names when possible.
                                     Default: true
        --asm-able                   Output with this flag is a valid input of "seccomp-tools asm".
                                     By default, "seccomp-tools disasm" is in a human-readable format that easy for analysis.
                                     Passing this flag can have the output be simplified to a valid input for "seccomp-tools asm".
                                     This flag implies "--no-bpf --no-arg-infer".
                                     Default: false
```

### seccomp-tools emu --help

```text
emu - Emulate seccomp rules.

Usage: seccomp-tools emu [options] BPF_FILE [sys_nr [arg0 [arg1 ... arg5]]]
    -a, --arch ARCH                  Specify architecture.
                                     Supported architectures are <aarch64|amd64|i386|s390x>.
                                     Default: amd64
    -q, --[no-]quiet                 Run quietly, only show emulation result.
    -i, --ip=VAL                     Set instruction pointer.
```

