---
title: "25fic决赛"
draft: false
---
## 检材2-陈某电脑
### 电脑

#### 请分析检材2，该检材系统中设备名称为neo4chen的系统分区的sha256值为

**参考格式：** 参考格式:

**答案：** `E2219548F5A8E61F373258EB658625ADDA7BF858A83AD8D6E4213BCD8ECEB423`


#### 请分析检材2，上题系统中，曾被远程控制的ip为

**参考格式：** 参考格式:1.1.1.1

**答案：** `192.168.3.14`


#### 请分析检材2加密系统，陈某通过物理方式保存助记词的东西名为

**参考格式：** 参考格式:存钱罐

**答案：** `时光密钥`


#### 请分析检材2加密系统，陈某保存记录完整助记词的文件的md5值为

**答案：** `c2a8300c87f86bd04b4aea42e7d6b83c`


#### 请分析检材2加密系统，陈某交代XI位为2^1，上题文件对应中文助记词不包含一下哪一项

**参考格式：** 参考格式:

**选项：**

- A. 摇

- B. 选

- C. 的

- D. 以

**答案：** `C`


#### 请分析检材2加密系统，该检材加密系统中陈某自白的录音最后修改时间为

**参考格式：** 参考格式:2000-00-00 00:00:00

**答案：** `2025-05-14 20:59:20`


#### 请分析检材2加密系统，陈某和李某共同出行的户外活动为

**参考格式：** 参考格式:摄影

**答案：** `钓鱼`


#### 请分析检材2加密系统，陈某自白中的隐藏的“学习资料”所在服务器ip地址为

**答案：** `114.51.41.91`


#### 请分析检材2加密系统，存放欠条的加密容器文件名为

**参考格式：** 参考格式:蜂蜜锅底

**答案：** `我的手机号`


#### 请分析检材2加密系统，该容器欠条中赵某欠陈某多少虚拟币

**参考格式：** 参考格式:0.524ETH

**答案：** `0.079BTC`


#### 请分析检材2加密系统，该检材中ubuntu光盘文件的系统内核版本号为

**参考格式：** 参考格式:6.6.6

**答案：** `4.15.0`


### linux虚拟机

#### 仿真

这个系统是相当于一个计算机里安装了两个系统，所以需要分离出来
这个直接使用ufs就能检测出来有两个系统，直接分离就行
![[Pasted image 20260430205740.png]]
保存为vmdk
直接启动是打不开的，需要火眼仿真
但是火眼仿真其实还是起不来，因为uuid分配错误
#### *uuid*
guid是整个gpt磁盘的唯一id
uuid指的是文本系统的id，像ntfs，ext4等都有uuid
在linux内输入命令`blkid`能看到类似
```
/dev/sda2: UUID="a13f1b2e-..." TYPE="ext4"
```
这个是文件系统的uuid

#### *RAIN*
在实际使用中，数据可以不存在同一块硬盘中，这样有效提升速度
正常情况下能看到一个RAID规则重组，这个可以将各个系统盘中的信息重组
它是由多个硬盘组合在一起的，比如：
```
/dev/sda
/dev/sdb2
```
他们共同组成了系统盘
```
/dev/md0
```
如果只挂载一个盘，经常挂载失败，就是因为只有组合起来才能读取到完整的内容
RAID也有自己的uuid，例如
```
mdadm --examine /dev/sda3
```
会看到
```
Array UUID : xxxx:xxxx:xxxx:xxxx
```
仿真的时候因为我们直接根据raid重组了硬盘，所以这时候RAID想要根据规则找盘根本找不到，已经被平坦成了一个盘
仿真的时候uuid名字也可能发生变化，这种时候就需要重新指定boot
这个时候需要找到boot在哪里，然后把root和prefix指定到这里
root：告诉 GRUB **当前要从哪个磁盘/分区读文件**。
prefix：告诉 GRUB **它自己的配置文件和模块目录在哪里**。
输入下列命令来重新确定这些东西在哪里
```
ls
ls (hd0,gpt2)/boot/grub
set root=(hd0,gpt2)
set prefix=(hd0,gpt2)/boot/grub
insmod normal
normal
```
之后就能启动了，可能需要等一会

之后是登录
用户是haobi，密码在linux里面能找到hash值
```
echo '$y$j9T$id1nhJJvfJc4uBcOiJFnR1$OHyZdzZVkOZtgYyF7y66xIgVb8FkYySmgrSQEhDUBO1*$y$j9T$id1nhJJvfJc4uBcOiJFnR1$' > yescrypt.hash
hashcat -m 73000 -a 0 yescrypt.hash rockyou.txt
```
通过这两行爆破出来密码之后才能登录

等会，我是唐比
相信火眼，密码甚至直接帮你换成了123456
好样的火眼
#### 请分析检材2Linux系统，该系统的当前状态为

**选项：**

- A. Poweroff(S5)

- B. Sleep(S2)

- C. Hibernate(S4)

- D. Poweron(G0)

**答案：** `C`

A. Poweroff (S5)     关机
B. Sleep (S2)        睡眠
C. Hibernate (S4)    休眠
D. Poweron (G0)      正常开机运行

其实火眼里面能看到他没有关机，但是看不到他是睡眠还是休眠

这个需要去系统日志里找，用火眼打开能看到/var/log里有了文件
找到journal里面，就能看到系统日志，在系统文件system.journal里
使用strings搜索
```
strings -a system.journal | grep -iE 'hibernate|suspend|sleep|poweroff|shutdown'
```
![[Pasted image 20260506103751.png]]
直接按照顺序看，最后面试hibernate，所以答案选c
#### 请分析检材2Linux系统，该系统使用了什么阵列

**参考格式：** 参考格式:zfs1

**答案：** `raid0`

从之前的解密能看出来是raid0,或者是在ufs里面看出来
![[Pasted image 20260506104107.png]]
#### 请分析检材2Linux系统，系统自带记事本软件中记录的密码的未知位数有几位

**参考格式：** 参考格式:1

**答案：** `4`

在记事本里面可以看到一个可以恢复的文档
![[Pasted image 20260506105101.png]]
直接打开就是
#### 请分析检材2Linux系统，系统自带记事本内容缓存在重组后逻辑分区中的起始偏移地址为

**参考格式：** 参考格式:0x0123456789

**选项：**

- A. 296d9000

**答案：** `0x00296d9000`

![[Pasted image 20260506110445.png]]
已经能看到使用的系统默认软件是mousepad
直接在火眼里面搜索这个文件夹，能找到在/home/haobei/.local/share/Mousepad文件夹下有一个文件autosave-0
打开能开到这个确实是这个文档显示的内容
然后再ufs里面打开这个文件
选择show on-desk fragments能打开这个的视图
![[Pasted image 20260506111704.png]]
能看到左边有偏移值
#### 请分析检材2Linux系统，chrome浏览器插件的保护密码为

**参考格式：** 参考格式:a@1

**答案：** `chewhaoN@6087`

直接打开会看见一个密码，直接跳过，不输入
然后在目录下看见这个插件的配置
![[Pasted image 20260506112529.png]]

直接在google里面打开插件，选择inspect
直接打开这个界面，按ctrl + shift + F进行全局搜索
搜索Password does not match搜索不出来结果，直接搜索password
能搜出来一堆AES，那么就直接搜索AES.decrypt
找到两个地址，打上断点，开始调试
能找到两个字符串
```
U2FsdGVkX18Tb9IA8UF4TbpMQjOs4IqZBTIkldDlgn9vw1gIF9ltOirI/lf1SCGh9hAskbnb7cIsoJL6mNii7pQ1SDSt9R7vzF3Y+/d/fPtKXHMisjbQK/U6t+3wREAuoKQ4yZ24iuw+KZ6CW9bl6ULp3nVx0B8QpueW95sw0KOtmOMpmD19nO6gkFvMohcB

$argon2id$v=19$m=16384,t=1,p=1$k6EZEDdQYyn+/0GlJtZGpg$hicAuwJorE73Moj+Po2Txda8hyoPPGYa
```
可以看出来这两个分别是加密后的密文和加密的参数
然后可以开始爆破了
```javascript
const CryptoJS = require('crypto-js');

const argon2 = require('argon2');

  

const encrypted = 'U2FsdGVkX18Tb9IA8UF4TbpMQjOs4IqZBTIkldDlgn9vw1gIF9ltOirI/lf1SCGh9hAskbnb7cIsoJL6mNii7pQ1SDSt9R7vzF3Y+/d/fPtKXHMisjbQK/U6t+3wREAuoKQ4yZ24iuw+KZ6CW9bl6ULp3nVx0B8QpueW95sw0KOtmOMpmD19nO6gkFvMohcB';

  

const hash = '$argon2id$v=19$m=16384,t=1,p=1$k6EZEDdQYyn+/0GlJtZGpg$hicAuwJorE73Moj+Po2Txda8hyoPPGYa';

  

const prefix = 'chewhaoN@';

  

(async () => {

  for (let i = 0; i <= 9999; i++) {

    const password = prefix + String(i).padStart(4, '0');

  

    try {

      const bytes = CryptoJS.AES.decrypt(encrypted, password);

      // 解密结果是二进制数据，用 Hex 编码，不能用 Utf8

      const plaintext = bytes.toString(CryptoJS.enc.Hex);

  

      if (!plaintext) continue;

  

      const ok = await argon2.verify(hash, plaintext);

      console.log("try password =", password);

      if (ok) {

        console.log('[+] password =', password);

        console.log('[+] plaintext =', plaintext);

        return; c

      }

    } catch (e) { }

  }

  

  console.log('[-] not found');

})();
```

```
[+] password = chewhaoN@6087
[+] plaintext = 1428444b93c31c069502e96b36e65d4de5556e4f3839bc68a7d47f905ec5faddc9b33f9399998ac5926335a5af653a455d4489d9ded8bc5441cf260bba5c3ab8a210f4b9a1f47555a653ae86ceab695598578c1a3ddd86719f708d58961629db7346465b748ae4ae20f9baa125cc38e4abcae296c7ff1fdb
```
能解密，解密出来
![[Pasted image 20260506203556.png]]
#### 请分析检材2Linux系统，chrome浏览器插件存放的令牌的名称为

**参考格式：** 参考格式:abc

**答案：** `chenhaoren`

如上图
#### 请分析检材2Linux系统，该检材Linux系统浏览器插件存放的令牌在2022-05-12 00:54:10时的令牌为

**参考格式：** 参考格式:123456

**答案：** `080000`


## 检材3-陈某服务器

### linux

#### 仿真
找到用户king，直接爆破
hashcat模式选择1800，因为是sha512
找出来密码就是123456


#### 请分析检材3，该操作系统版本号为

**参考格式：** 参考格式:22.01.1

**答案：** `24.04.1`


#### 请分析检材3，该主机名为

**参考格式：** 参考格式:app-server-2025

**答案：** `api-server-2`


#### 请分析检材3，该ens33网卡IP地址为

**参考格式：** 参考格式:192.168.1.1

**答案：** `172.16.10.254`


#### 请分析检材3，操作系统登录使用了第三方身份验证，该技术为

**选项：**

- A. pam_pwdfile

- B. pam_ldap

- C. Google Auth

- D. pam_krb5

**答案：** `A`


#### 请分析检材3，该身份验证的加密算法为？

**选项：**

- A. Bcrypt

- B. MD5

- C. DES

- D. AES

**答案：** `A`


#### 请分析检材3，该保存king用户密码的文件名为？

**参考格式：** 参考格式:shadow

**答案：** `my_two_factor_pwdfile`


#### 请分析检材3，尝试爆破king用户，其密码为(king字母加3个数字)？

**参考格式：** 参考格式:king123

**答案：** `king110`


#### 请分析检材3，该WEB-API配置的 MySQL 数据库服务器地址为

**参考格式：** 参考格式:192.168.1.1

**答案：** `172.16.10.200`


#### 请分析检材3，其中用于 WEB-API 测试的流量包文件名为

**参考格式：** 参考格式:abc.txt

**答案：** `test.pcap`


#### 请分析检材3流量包，统计其中 admin 用户成功登录的次数为

**参考格式：** 参考格式:1

**答案：** `3`


#### 请分析检材3流量包，找出用户最后一次查看的商品型号为

**参考格式：** 参考格式:kk-123

**答案：** `hx-101`


#### 请分析检材3WEB-API，该容器镜像ID为(前六位)

**参考格式：** 参考格式:abc123

**答案：** `996a32`


#### 请分析检材3WEB-API，该容器的核心服务编程语言为

**选项：**

- A. JAVA

- B. PHP

- C. NODEJS

- D. C#

**答案：** `C`


#### 请分析检材3WEB-API，该容器所用域名为

**参考格式：** 参考格式:qq.com

**答案：** `api-server.com`


#### 请分析检材3WEB-API，该容器日志文件名(access_log)为

**参考格式：** 参考格式:abc.txt

**答案：** `api-server-access.log`


#### 请分析检材3WEB-API，该容器的FLAG2的接口URL为

**参考格式：** 参考格式:/aaa/bbb/ccc

**答案：** `/api/auth/flag2`


#### 请分析检材3WEB-API，该容器的服务运行状态的接口URL为

**参考格式：** 参考格式:/aaa/bbb

**答案：** `/api/health`


#### 请分析检材3WEB-API，该容器中访问FLAG2接口后，会提示需要在什么调试器下运行

**选项：**

- A. GDB

- B. Frida

- C. rr

- D. Treace

**答案：** `A`


#### 请分析检材3WEB-API，该容器的admin用户的登录密码为

**参考格式：** 参考格式:abc123

**答案：** `zhaohong666`


#### 请分析检材3WEB-API，该容器的数据库内容被SO所加密，该SO文件名为

**参考格式：** 参考格式:abc.txt

**答案：** `libJiami.so`


#### 请继续分析上题SO文件，该文件的编译器类型为

**选项：**

- A. VC

- B. DELPHI

- C. GCC

- D. VB

**答案：** `C`


#### 请继续分析上题SO文件，在SO文件的encrypt函数中，该加密算法为

**选项：**

- A. DES

- B. AES-128

- C. AES-192

- D. AES-256

**答案：** `D`


#### 请继续分析上题SO文件，尝试分析getAeskey函数，该KEY值为

**参考格式：** 参考格式:abasdcdefghijgasdsdfsdfqwesazada

**答案：** `zhaohongzhaohongzhaohongzhaohong`


#### 请继续分析上题SO文件，尝试分析get_flag1函数，该返回值为

**参考格式：** 参考格式:abc123

**答案：** `hong112233`


#### 请继续分析上题SO文件，尝试分析get_flag2函数，该返回值为

**参考格式：** 参考格式:qiang

**答案：** `hong`


#### 请继续分析上题SO文件，尝试分析decrypt函数，该密文dnJXwBR4qc+1Y4WB6ZxR0A==的明文为

**参考格式：** 参考格式:abc123

**答案：** `FICerisgood`


#### 请分析检材3数据库，在 products 表中，统计商品型号的种类数量（例如以 ZK、CW 等为前缀的型号）

**参考格式：** 参考格式:1

**答案：** `5`


#### 请分析检材3数据库，在 products 表中，统计型号为 “ZK” 且颜色为灰色的商品的数量

**参考格式：** 参考格式:10

**答案：** `29`


#### 请分析检材3数据库，在 products 表中，统计型号为 "ZK" 的总销售额（金额只保留整数部分，不进行四舍五入）

**参考格式：** 参考格式:10000

**答案：** `106450`


## 检材4-陈某路由器

#### 请分析检材4，该检材的系统版本号为

**参考格式：** 参考格式:1.1.1

**答案：** `24.10.0`


#### 请分析检材4，该检材的lan口ip为

**答案：** `192.168.3.1`


#### 请分析检材4，该检材Overlayfs分区的大小为多少KB

**参考格式：** 参考格式:123

**答案：** `8292024`


#### 请分析检材4，该检材中VPN网络私钥为

**参考格式：** 参考格式:Abc@123

**答案：** `SLkCLyRhrkWIFgJWfEd0B7s99FYWJf9PUV+scj3Vw3U=`


#### 请分析检材4，嫌疑人交代其开发了一款专门用于收集其售出摄像头信息的服务程序。请问该摄像头信息收集服务程序编译器版本为？

**参考格式：** 参考格式:1.1.1

**答案：** `13.3.0`


#### 请分析检材4，该摄像头信息收集程序支持的运行参数（命令行参数）数量为多少

**参考格式：** 参考格式:1

**答案：** `2`


#### 请分析检材4，该摄像头信息收集程序使用了什么算法进行加密

**选项：**

- A. MD5

- B. AES

- C. BASE64

- D. DES

**答案：** `BC`


#### 请分析检材4，该摄像头信息收集程序所使用的数据库文件名为

**参考格式：** 参考格式:abc.txt

**答案：** `collected.txt`


#### 请分析检材4，该摄像头信息收集程序收集了以下哪些摄像头信息？

**选项：**

- A. IP 地址

- B. 摄像头密码

- C. 备注信息

- D. 电话号码

**答案：** `ABC`


## 检材5-APP

#### 请分析检材5，该检材的包名为

**参考格式：** 参考格式:aaa.bbb.ccc

**答案：** `com.forensix.cam`


#### 请分析检材5，该检材的签名证书 MD5 值为

**参考格式：** 参考格式:202cb962ac59075b964b07152d234b70

**答案：** `7b1963b70fbac57a50836e9a044d0029`


#### 请分析检材5，在尝试抓包登录 APP 时，登录请求中提交的参数包括：（请使用比武U盘中提供的智能家居账号密码进行登录抓包）

**选项：**

- A. devicename

- B. password

- C. id

- D. flag

**答案：** `BCD`


#### 请分析检材5，通过抓包分析登录请求，获取到的 flag 参数的值为

**参考格式：** 参考格式:abc123asd56

**答案：** `05d8cccb5f`


#### 请分析检材5，该 APK 登录请求中携带了一个远程调证 ID，分析该请求并提取该 ID，统计其长度为（请提取该 ID 并在比武平台中进行调证，准备进入下一阶段分析，可参考比武 U 盘中的手册）

**参考格式：** 参考格式:1

**答案：** `6`


#### 请分析检材5，在登录成功后，应用会跳转至 “欢迎使用 forensix” 界面。该界面对应的 Activity 类的完整类名为

**参考格式：** 参考格式:com.bb.cc.ee.ff

**答案：** `com.forensix.cam.activity.c75e3a8b2d`


#### 请分析检材5，分析上述 Activity 类后，发现其内部定义的 TAG 常量值为：

**参考格式：** 参考格式:999

**答案：** `222`


#### 请结合互联网分析APP调证检材，该检材系统版本号为(完成调证后，可参考比武 U 盘中的手册，在云实验室中继续完成取证任务)

**参考格式：** 参考格式:1.1

**答案：** `11.11`


#### 请结合互联网分析APP调证检材，该检材系统内FLAG值为(完成调证后，可参考比武 U 盘中的手册，在云实验室中继续完成取证任务)

**参考格式：** 参考格式:123456

**答案：** `778899`


## 综合分析

#### 请综合分析，陈某进行了那些操作

**选项：**

- A. VC加密Linux系统

- B. VC加密Windows系统

- C. VC加密文件

- D. VC加密系统容器

**答案：** `BC`


#### 请综合分析，陈某没有使用过以下那种方式安装数据库

**选项：**

- A. 编译安装

- B. 包管理器安装

- C. 容器安装

- D. 单文件

**答案：** `A`


#### 请综合分析，陈某使用过以下那些系统

**选项：**

- A. Windows

- B. MacOS

- C. Debian

- D. CentOS

- E. Fedora

**答案：** `AC`


#### 请综合分析，以下说法正确的是
1.陈某将正确的助记词藏在了Linux中
2.陈某将正确的助记词藏在了windows中
3.陈某电子数据中保留了孙某的欠条
4.陈某电子数据中保留了王某的欠条
5.陈某使用JAVA搭建后台接口
6.陈某和“香格里拉大酒店”有关

**选项：**

- A. 1245

- B. 2356

- C. 146

- D. 246

- E. 1235

**答案：** `C`


#### 请综合分析，陈某现有电子数据没有以下那个Linux内核版本

**选项：**

- A. 4.14-arm

- B. 6.6-arm

- C. 4.15-x64

- D. 6.8-x64

**答案：** `C`


#### 请综合分析，陈某做为壁纸的邪影芳灵原图的sm3值为

**答案：** `0300A48E6ACEFEF6EBC6FF64B957B42880FEBB66B5C807C7E3D7D3C3CCAD2661`


#### 请结合分析，陈某的真实GitHub密码为

**参考格式：** 参考格式:Abc123

**答案：** `Forensix666`


