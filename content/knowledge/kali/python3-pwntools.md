---
title: "python3-pwntools"
lastmod: 2026-04-12T00:37:32+08:00
draft: false
---
# python3-pwntools

- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Pwn
- 主要用途：pwntools 命令行入口和 Python 库，用于 exploit 交互、ROP、shellcode、ELF 分析。
- 工具位置：`/usr/bin/pwn`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/python3-pwntools.md`

## 比赛中怎么用

python3-pwntools 的核心价值是：pwntools 命令行入口和 Python 库，用于 exploit 交互、ROP、shellcode、ELF 分析。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
pwn checksec ./chall
```
```bash
pwn cyclic 200
```
```bash
python3 exploit.py
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### pwn -h

```text
usage: pwn [-h] {asm,checksec,constgrep,cyclic,debug,disasm,disablenx,elfdiff,elfpatch,errno,hex,libcdb,phd,pwnstrip,scramble,shellcraft,template,unhex,update,version} ...

Pwntools Command-line Interface

positional arguments:
  {asm,checksec,constgrep,cyclic,debug,disasm,disablenx,elfdiff,elfpatch,errno,hex,libcdb,phd,pwnstrip,scramble,shellcraft,template,unhex,update,version}
    asm                 Assemble shellcode into bytes
    checksec            Check binary security settings
    constgrep           Looking up constants from header files. Example: constgrep -c freebsd -m ^PROT_ '3 + 4'
    cyclic              Cyclic pattern creator/finder
    debug               Debug a binary in GDB
    disasm              Disassemble bytes into text format
    disablenx           Disable NX for an ELF binary
    elfdiff             Compare two ELF files
    elfpatch            Patch an ELF file
    errno               Prints out error messages
    hex                 Hex-encodes data provided on the command line or stdin
    libcdb              Print various information about a libc binary
    phd                 Pretty hex dump
    pwnstrip            Strip binaries for CTF usage
    scramble            Shellcode encoder
    shellcraft          Microwave shellcode -- Easy, fast and delicious
    template            Generate an exploit template
    unhex               Decodes hex-encoded data provided on the command line or via stdin.
    update              Check for pwntools updates
    version             Pwntools version

options:
  -h, --help            show this help message and exit
```

### pwn checksec -h

```text
usage: pwn checksec [-h] [--file [elf ...]] [elf ...]

Check binary security settings

positional arguments:
  elf               Files to check

options:
  -h, --help        show this help message and exit
  --file [elf ...]  File to check (for compatibility with checksec.sh)
```

### pwn cyclic -h

```text
usage: pwn cyclic [-h] [-a alphabet] [-n length] [-c context] [-l lookup_value | count]

Cyclic pattern creator/finder

positional arguments:
  count                 Number of characters to print

options:
  -h, --help            show this help message and exit
  -a, --alphabet alphabet
                        The alphabet to use in the cyclic pattern (defaults to all lower case letters)
  -n, --length length   Size of the unique subsequences (defaults to 4).
  -c, --context context
                        The os/architecture/endianness/bits the shellcode will run in (default: linux/i386), choose from: ['16', '32', '64', 'baremetal', 'freebsd', 'windows',
                        'android', 'darwin', 'linux', 'cgc', 'powerpc64', 'aarch64', 'powerpc', 'riscv32', 'riscv64', 'sparc64', 'mips64', 'msp430', 'alpha', 'amd64', 'sparc',
                        'thumb', 'cris', 'i386', 'ia64', 'm68k', 'mips', 's390', 'none', 'avr', 'arm', 'vax', 'little', 'big', 'be', 'eb', 'le', 'el']
  -l, -o, --offset, --lookup lookup_value
                        Do a lookup instead printing the alphabet
```

### pwn asm -h

```text
usage: pwn asm [-h] [-f {raw,hex,string,elf}] [-o file] [-c context] [-v AVOID] [-n] [-z] [-d] [-e ENCODER] [-i INFILE] [-r] [line ...]

Assemble shellcode into bytes

positional arguments:
  line                  Lines to assemble. If none are supplied, use stdin

options:
  -h, --help            show this help message and exit
  -f, --format {raw,hex,string,elf}
                        Output format (defaults to hex for ttys, otherwise raw)
  -o, --output file     Output file (defaults to stdout)
  -c, --context context
                        The os/architecture/endianness/bits the shellcode will run in (default: linux/i386), choose from: ['16', '32', '64', 'baremetal', 'freebsd', 'windows',
                        'android', 'darwin', 'linux', 'cgc', 'powerpc64', 'aarch64', 'powerpc', 'riscv32', 'riscv64', 'sparc64', 'mips64', 'msp430', 'alpha', 'amd64', 'sparc',
                        'thumb', 'cris', 'i386', 'ia64', 'm68k', 'mips', 's390', 'none', 'avr', 'arm', 'vax', 'little', 'big', 'be', 'eb', 'le', 'el']
  -v, --avoid AVOID     Encode the shellcode to avoid the listed bytes (provided as hex)
  -n, --newline         Encode the shellcode to avoid newlines
  -z, --zero            Encode the shellcode to avoid NULL bytes
  -d, --debug           Debug the shellcode with GDB
  -e, --encoder ENCODER
                        Specific encoder to use
  -i, --infile INFILE   Specify input file
  -r, --run             Run output
```

### pwn disasm -h

```text
usage: pwn disasm [-h] [-c arch_or_os] [-a address] [--color] [--no-color] [hex ...]

Disassemble bytes into text format

positional arguments:
  hex                   Hex-string to disassemble. If none are supplied, then it uses stdin in non-hex mode.

options:
  -h, --help            show this help message and exit
  -c, --context arch_or_os
                        The os/architecture/endianness/bits the shellcode will run in (default: linux/i386), choose from: ['16', '32', '64', 'baremetal', 'freebsd', 'windows',
                        'android', 'darwin', 'linux', 'cgc', 'powerpc64', 'aarch64', 'powerpc', 'riscv32', 'riscv64', 'sparc64', 'mips64', 'msp430', 'alpha', 'amd64', 'sparc',
                        'thumb', 'cris', 'i386', 'ia64', 'm68k', 'mips', 's390', 'none', 'avr', 'arm', 'vax', 'little', 'big', 'be', 'eb', 'le', 'el']
  -a, --address address
                        Base address
  --color               Color output
  --no-color            Disable color output
```

### pwn constgrep -h

```text
usage: pwn constgrep [-h] [-e] [-i] [-m] [-c arch_or_os] regex [constant]

Looking up constants from header files.

Example: constgrep -c freebsd -m  ^PROT_ '3 + 4'

positional arguments:
  regex                 The regex matching constant you want to find
  constant              The constant to find

options:
  -h, --help            show this help message and exit
  -e, --exact           Do an exact match for a constant instead of searching for a regex
  -i, --case-insensitive
                        Search case insensitive
  -m, --mask-mode       Instead of searching for a specific constant value, search for values not containing strictly less bits that the given value.
  -c, --context arch_or_os
                        The os/architecture/endianness/bits the shellcode will run in (default: linux/i386), choose from: ['16', '32', '64', 'baremetal', 'freebsd', 'windows',
                        'android', 'darwin', 'linux', 'cgc', 'powerpc64', 'aarch64', 'powerpc', 'riscv32', 'riscv64', 'sparc64', 'mips64', 'msp430', 'alpha', 'amd64', 'sparc',
                        'thumb', 'cris', 'i386', 'ia64', 'm68k', 'mips', 's390', 'none', 'avr', 'arm', 'vax', 'little', 'big', 'be', 'eb', 'le', 'el']
```

### pwn template -h

```text
usage: pwn template [-h] [--host HOST] [--port PORT] [--user USER] [--pass PASSWORD] [--libc LIBC] [--path PATH] [--quiet] [--color {never,always,auto}] [--template TEMPLATE]
                    [--no-auto]
                    [exe]

Generate an exploit template. If no arguments are given, the current directory is searched for an executable binary and libc. If only one binary is found, it is assumed to be the
challenge binary.

positional arguments:
  exe                   Target binary. If not given, the current directory is searched for an executable binary.

options:
  -h, --help            show this help message and exit
  --host HOST           Remote host / SSH server
  --port PORT           Remote port / SSH port
  --user USER           SSH Username
  --pass, --password PASSWORD
                        SSH Password
  --libc LIBC           Path to libc binary to use. If not given, the current directory is searched for a libc binary.
  --path PATH           Remote path of file on SSH server
  --quiet               Less verbose template comments
  --color {never,always,auto}
                        Print the output in color
  --template TEMPLATE   Path to a custom template. Tries to use '~/.config/pwntools/templates/pwnup.mako', if it exists. Check '/usr/lib/python3/dist-
                        packages/pwnlib/data/templates/pwnup.mako' for the default template shipped with pwntools.
  --no-auto             Do not automatically detect missing binaries
```

