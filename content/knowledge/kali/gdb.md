---
title: "gdb"
lastmod: 2026-04-12T00:36:56+08:00
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：Pwn / Reverse
- 主要用途：GNU 调试器，用于断点、单步、查看寄存器/内存、调试漏洞利用。
- 工具位置：`/usr/bin/gdb`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/gdb.md`

## 比赛中怎么用

gdb 的核心价值是：GNU 调试器，用于断点、单步、查看寄存器/内存、调试漏洞利用。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
gdb ./chall
```
```bash
gdb -q --args ./chall arg1 arg2
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### gdb --help

```text
This is the GNU debugger.  Usage:

    gdb [options] [executable-file [core-file or process-id]]
    gdb [options] --args executable-file [inferior-arguments ...]

Selection of debuggee and its files:

  --args             Arguments after executable-file are passed to inferior.
  --core=COREFILE    Analyze the core dump COREFILE.
  --exec=EXECFILE    Use EXECFILE as the executable.
  --pid=PID          Attach to running process PID.
  --directory=DIR    Search for source files in DIR.
  --se=FILE          Use FILE as symbol file and executable file.
  --symbols=SYMFILE  Read symbols from SYMFILE.
  --readnow          Fully read symbol files on first access.
  --readnever        Do not read symbol files.
  --write            Set writing into executable and core files.

Initial commands and command files:

  --command=FILE, -x Execute GDB commands from FILE.
  --init-command=FILE, -ix
		     Like -x but execute commands before loading inferior.
  --eval-command=COMMAND, -ex
		     Execute a single GDB command.
		     May be used multiple times and in conjunction
		     with --command.
  --init-eval-command=COMMAND, -iex
		     Like -ex but before loading inferior.
  --nh               Do not read ~/.gdbinit.
  --nx               Do not read any .gdbinit files in any directory.

Output and user interface control:

  --fullname         Output information used by emacs-GDB interface.
  --interpreter=INTERP
		     Select a specific interpreter / user interface.
  --tty=TTY          Use TTY for input/output by the program being debugged.
  -w                 Use the GUI interface.
  --nw               Do not use the GUI interface.
  --tui              Use a terminal user interface.
  -q, --quiet, --silent
		     Do not print version number on startup.

Operating modes:

  --batch            Exit after processing options.
  --batch-silent     Like --batch, but suppress all gdb stdout output.
  --return-child-result
		     GDB exit code will be the child's exit code.
  --configuration    Print details about GDB configuration and then exit.
  --help             Print this message and then exit.
  --version          Print version information and then exit.

Remote debugging options:

  -b BAUDRATE        Set serial port baud rate used for remote debugging.
  -l TIMEOUT         Set timeout in seconds for remote debugging.

Other options:

  --cd=DIR           Change current directory to DIR.
  --data-directory=DIR, -D
		     Set GDB's data-directory to DIR.

At startup, GDB reads the following early init files and executes their
commands:
   None found.

At startup, GDB reads the following init files and executes their commands:
   * system-wide init files: /etc/gdb/gdbinit
   * user-specific init file: /home/kali/.gdbinit

For more information, type "stream" from within GDB, or consult the
GDB manual (available as on-line info or a printed manual).

Report bugs to <https://www.gnu.org/software/gdb/bugs/>.

You can ask GDB-related questions on the GDB users mailing list
(gdb@sourceware.org) or on GDB's IRC channel (#gdb on Libera.Chat).
```

