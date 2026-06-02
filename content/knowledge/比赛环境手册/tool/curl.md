---
title: "curl"
lastmod: 2026-04-02T23:54:26+08:00
draft: false
---
这份文档按本机 `curl.exe --help all` 输出整理。curl 选项非常多，这里按功能分类做中文归纳，尽量贴近完整帮助页。

## 工具定位
curl 是通用网络传输工具，支持 HTTP、HTTPS、FTP、SFTP、SMTP、LDAP、SMB、IPFS 等多种协议，适合复现请求、下载上传、调试 TLS、走代理和输出调试信息。

## 基本语法

```bash
curl [选项] <URL>
```

## 配置与基本控制
- `-K, --config <文件>`：从配置文件读取参数
- `-q, --disable`：禁用 `.curlrc`
- `-:, --next`：对下一个 URL 使用一组新的选项
- `-h, --help <主题>`：显示帮助
- `-M, --manual`：显示完整手册
- `-V, --version`：显示版本

## 请求方法与请求体
- `-X, --request <方法>`：指定请求方法
- `-G, --get`：把 `--data` 放到 URL 查询串中，并使用 GET
- `-d, --data <数据>`：发送 POST 数据
- `--data-ascii <数据>`：发送 ASCII 数据
- `--data-binary <数据>`：发送二进制数据
- `--data-raw <数据>`：发送原始数据
- `--data-urlencode <数据>`：自动 URL 编码
- `--json <数据>`：发送 JSON 请求体
- `-F, --form <name=content>`：发送 multipart 表单
- `--form-string <name=string>`：发送 multipart 字符串
- `--form-escape`：表单字段用反斜杠转义
- `--url-query <数据>`：附加 URL 查询参数
- `--request-target <path>`：指定请求目标

## Header、Cookie、会话
- `-H, --header <header/@file>`：自定义请求头
- `-i, --show-headers`：在输出中显示响应头
- `-D, --dump-header <文件>`：把响应头写入文件
- `-b, --cookie <数据或文件>`：发送 Cookie
- `-c, --cookie-jar <文件>`：保存 Cookie
- `-j, --junk-session-cookies`：忽略会话 Cookie
- `-e, --referer <URL>`：设置 Referer
- `-A, --user-agent <名称>`：设置 User-Agent
- `--etag-compare <文件>`：从文件读取 ETag 对比
- `--etag-save <文件>`：保存接收到的 ETag
- `--hsts <文件>`：启用 HSTS 缓存
- `--alt-svc <文件>`：启用 alt-svc 缓存

## 认证
- `--anyauth`：自动选择认证方式
- `--basic`：HTTP Basic
- `--digest`：HTTP Digest
- `--negotiate`：HTTP Negotiate/SPNEGO
- `--ntlm`：HTTP NTLM
- `--ntlm-wb`：winbind NTLM
- `--oauth2-bearer <token>`：OAuth2 Bearer
- `-u, --user <user:password>`：服务器用户名密码
- `-U, --proxy-user <user:password>`：代理用户名密码
- `--proxy-anyauth`、`--proxy-basic`、`--proxy-digest`、`--proxy-negotiate`、`--proxy-ntlm`：代理认证
- `--delegation <level>`：GSS-API delegation
- `--krb <level>`：Kerberos 安全级别
- `--service-name <name>`：SPNEGO 服务名
- `--proxy-service-name <name>`：代理 SPNEGO 服务名
- `--sasl-authzid <identity>`：SASL 授权标识
- `--sasl-ir`：SASL 初始响应

## TLS、证书与密钥
- `--ca-native`：使用系统 CA
- `--cacert <文件>`：指定 CA 证书
- `--capath <目录>`：指定 CA 目录
- `-E, --cert <证书[:密码]>`：客户端证书
- `--cert-type <类型>`：证书类型
- `--cert-status`：校验证书状态
- `--key <文件>`：私钥文件
- `--key-type <类型>`：私钥类型
- `--pass <短语>`：私钥口令
- `-k, --insecure`：忽略服务端证书校验
- `--crlfile <文件>`：证书吊销列表
- `--curves <列表>`：椭圆曲线列表
- `--ciphers <列表>`：TLS 1.2 及以下密码套件
- `--tls13-ciphers <列表>`：TLS 1.3 密码套件
- `--sigalgs <列表>`：签名算法
- `--tls-max <版本>`：最大 TLS 版本
- `-1, --tlsv1` / `--tlsv1.0/1.1/1.2/1.3`：指定最低 TLS 版本
- `--tls-earlydata`：允许 TLS 1.3 早期数据
- `--tlsauthtype <类型>`、`--tlsuser <名称>`、`--tlspassword <字符串>`：TLS 认证参数
- `--ssl`：尝试启用 TLS
- `--ssl-reqd`：强制 TLS
- `--ssl-allow-beast`：允许弱兼容模式
- `--ssl-auto-client-cert`：自动客户端证书
- `--ssl-no-revoke`：禁用吊销检查
- `--ssl-revoke-best-effort`：忽略缺失的 CRL 分发点
- `--ssl-sessions <文件>`：加载或保存 TLS session ticket
- `--false-start`：启用 TLS False Start
- `--ech <配置>`：配置 ECH
- `--doh-url <URL>`：使用 DoH 解析
- `--doh-insecure`：忽略 DoH 服务器证书
- `--doh-cert-status`：校验 DoH 服务器证书状态

## TLS 代理专用选项
- `--proxy-ca-native`
- `--proxy-cacert <文件>`
- `--proxy-capath <目录>`
- `--proxy-cert <证书[:密码]>`
- `--proxy-cert-type <类型>`
- `--proxy-ciphers <列表>`
- `--proxy-crlfile <文件>`
- `--proxy-http2`
- `--proxy-insecure`
- `--proxy-key <文件>`
- `--proxy-key-type <类型>`
- `--proxy-pass <短语>`
- `--proxy-pinnedpubkey <哈希>`
- `--proxy-ssl-allow-beast`
- `--proxy-ssl-auto-client-cert`
- `--proxy-tls13-ciphers <列表>`
- `--proxy-tlsauthtype <类型>`
- `--proxy-tlspassword <字符串>`
- `--proxy-tlsuser <名称>`
- `--proxy-tlsv1`

## 重定向与错误处理
- `-L, --location`：跟随重定向
- `--follow`：按规范跟随重定向
- `--location-trusted`：跟随时把敏感信息也发给新主机
- `--max-redirs <数量>`：最大重定向次数
- `--post301`、`--post302`、`--post303`：重定向后保持 POST
- `-f, --fail`：HTTP 错误时直接失败且不输出正文
- `--fail-with-body`：HTTP 错误时保留正文
- `--fail-early`：多传输时遇到第一个错误就停
- `--remove-on-error`：出错时删除输出文件

## 输出控制
- `-o, --output <文件>`：写入文件
- `-O, --remote-name`：按远端文件名保存
- `-J, --remote-header-name`：使用响应头提供的文件名
- `--remote-name-all`：所有 URL 都用远端文件名
- `--output-dir <目录>`：输出目录
- `-a, --append`：上传时追加到目标文件
- `--no-clobber`：不要覆盖已有文件
- `--skip-existing`：已有本地文件时跳过下载
- `--create-dirs`：自动创建目录
- `--create-file-mode <mode>`：创建文件权限
- `--out-null`：丢弃响应数据
- `-w, --write-out <格式>`：传输完成后输出变量
- `--styled-output`：样式化 HTTP 头输出
- `--stderr <文件>`：重定向 stderr

## 传输控制
- `-m, --max-time <秒>`：最大传输时间
- `--connect-timeout <秒>`：最大连接时间
- `--expect100-timeout <秒>`：等待 `100-continue` 的时间
- `--max-filesize <字节>`：最大下载文件大小
- `--limit-rate <速度>`：限速
- `--rate <最大请求速率>`：串行传输请求速率
- `-Y, --speed-limit <速度>`：低于该速度时认为过慢
- `-y, --speed-time <秒>`：过慢判断所需持续时间
- `--retry <次数>`：重试
- `--retry-delay <秒>`：重试间隔
- `--retry-max-time <秒>`：最大重试总时长
- `--retry-connrefused`：连接被拒也重试
- `--retry-all-errors`：所有错误都重试
- `-C, --continue-at <偏移>`：断点续传
- `-r, --range <范围>`：按字节范围请求
- `-R, --remote-time`：保留远端时间

## 并行与多路传输
- `-Z, --parallel`：并行传输
- `--parallel-immediate`：不等待复用
- `--parallel-max <数量>`：最大并发数
- `--parallel-max-host <数量>`：单主机最大连接数

## 协议与版本控制
- `--proto <协议列表>`：允许或禁用协议
- `--proto-default <协议>`：默认协议
- `--proto-redir <协议列表>`：重定向时允许的协议
- `--http0.9`：允许 HTTP/0.9
- `-0, --http1.0`：使用 HTTP/1.0
- `--http1.1`：使用 HTTP/1.1
- `--http2`：使用 HTTP/2
- `--http2-prior-knowledge`：直接使用 HTTP/2
- `--http3`：使用 HTTP/3
- `--http3-only`：只用 HTTP/3
- `--proxy1.0 <host[:port]>`：HTTP/1.0 代理

## 代理
- `-x, --proxy <代理>`：指定代理
- `--preproxy <代理>`：先经过一个前置代理
- `-p, --proxytunnel`：HTTP CONNECT 隧道
- `--noproxy <列表>`：不走代理的主机列表
- `--socks4`、`--socks4a`、`--socks5`、`--socks5-hostname`：SOCKS 代理
- `--socks5-basic`：SOCKS5 用户名密码认证
- `--socks5-gssapi`：SOCKS5 GSS-API
- `--socks5-gssapi-nec`：NEC 兼容模式
- `--socks5-gssapi-service <名称>`：SOCKS5 GSS-API 服务名
- `--haproxy-protocol`：发送 HAProxy PROXY v1 头
- `--haproxy-clientip <IP>`：设置 HAProxy PROXY 中的客户端 IP

## DNS、地址与网络
- `--dns-servers <地址列表>`：指定 DNS 服务器
- `--dns-interface <接口>`：DNS 请求使用的接口
- `--dns-ipv4-addr <地址>`：DNS 请求使用的 IPv4 地址
- `--dns-ipv6-addr <地址>`：DNS 请求使用的 IPv6 地址
- `--resolve <host:port:addr>`：手工指定解析结果
- `--connect-to <h1:p1:h2:p2>`：把一个目标映射到另一个目标
- `--interface <名称>`：指定网络接口
- `--local-port <范围>`：指定本地端口
- `--unix-socket <路径>`：Unix 域套接字
- `--abstract-unix-socket <路径>`：抽象 Unix 域套接字
- `--ip-tos <值>`：设置 ToS 或 Traffic Class
- `--ipfs-gateway <URL>`：指定 IPFS 网关
- `-4, --ipv4`：只解析 IPv4
- `-6, --ipv6`：只解析 IPv6
- `--happy-eyeballs-timeout-ms <毫秒>`：Happy Eyeballs 超时
- `--keepalive-time <秒>`：Keepalive 时间
- `--keepalive-cnt <整数>`：Keepalive 次数
- `--no-keepalive`：禁用 Keepalive
- `--tcp-fastopen`：启用 TCP Fast Open
- `--tcp-nodelay`：设置 TCP_NODELAY
- `--vlan-priority <优先级>`：设置 VLAN 优先级

## 上传、FTP、邮件和特殊协议
- `-T, --upload-file <文件>`：上传本地文件
- `-B, --use-ascii`：使用 ASCII 文本传输
- `--crlf`：上传时把 LF 转成 CRLF
- `-l, --list-only`：仅列目录
- `-Q, --quote <命令>`：传输前向服务器发送命令
- `--ftp-account <数据>`
- `--ftp-alternative-to-user <命令>`
- `--ftp-create-dirs`
- `--ftp-method <方法>`
- `--ftp-pasv`
- `-P, --ftp-port <地址>`
- `--ftp-pret`
- `--ftp-skip-pasv-ip`
- `--ftp-ssl-ccc`
- `--ftp-ssl-ccc-mode <active/passive>`
- `--ftp-ssl-control`
- `--mail-auth <地址>`
- `--mail-from <地址>`
- `--mail-rcpt <地址>`
- `--mail-rcpt-allowfails`
- `--upload-flags <标志>`：IMAP 上传行为
- `-t, --telnet-option <opt=val>`：设置 telnet 选项
- `--tftp-blksize <值>`
- `--tftp-no-options`

## SSH/SFTP/SCP 相关
- `--knownhosts <文件>`：指定 known_hosts
- `--hostpubmd5 <md5>`：主机公钥 MD5
- `--hostpubsha256 <sha256>`：主机公钥 SHA256
- `--pubkey <文件>`：SSH 公钥

## 调试、追踪与显示
- `-v, --verbose`：更详细
- `-s, --silent`：静默
- `-S, --show-error`：静默时也显示错误
- `-# , --progress-bar`：进度条
- `--no-progress-meter`：不显示进度条
- `-N, --no-buffer`：禁用 stdout 缓冲
- `--raw`：HTTP 原始模式，不做传输解码
- `--tr-encoding`：请求压缩传输编码
- `--trace <文件>`：写调试 trace
- `--trace-ascii <文件>`：ASCII trace
- `--trace-config <字符串>`：配置 trace 细节
- `--trace-ids`：trace 中带连接与传输 ID
- `--trace-time`：trace 中带时间戳
- `--libcurl <文件>`：把当前命令转换成 libcurl C 代码
- `--dump-ca-embed`：把内嵌 CA bundle 输出到 stdout

## 其他选项
- `--compressed`：请求压缩响应
- `--compressed-ssh`：启用 SSH 压缩
- `--path-as-is`：保留 URL 中的 `..`
- `--pinnedpubkey <哈希>`：固定公钥
- `--disallow-username-in-url`：禁止 URL 中包含用户名
- `--ignore-content-length`：忽略远端 Content-Length
- `--metalink`：把输入按 metalink 处理
- `--mptcp`：启用 Multipath TCP
- `--engine <名称>`：加密引擎
- `--egd-file <文件>`：EGD 随机源
- `--random-file <文件>`：随机源文件
- `--variable <[%]name=text/@file>`：定义变量
- `--xattr`：保存元数据到扩展属性

## 常见组合

```bash
curl -i http://target
curl -X POST -H "Content-Type: application/json" --json "{\"a\":1}" http://target/api
curl -L -o out.bin http://target/file
curl -x http://127.0.0.1:8080 -k https://target
curl --trace-ascii trace.txt http://target
```

## 比赛提示
- 只要你想把浏览器里的一个请求缩成一条命令，curl 基本都能承接
- 复杂登录态优先配 `-H`、`-b`、`-c`、`-L` 一起用
- 排查网络问题时，`-v`、`--trace-ascii`、`--connect-timeout`、`-k` 非常常用

## 上游项目
- 官方手册：https://curl.se/docs/manpage.html

