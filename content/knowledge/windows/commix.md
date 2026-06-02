---
title: "commix"
lastmod: 2026-04-12T00:37:38+08:00
draft: false
---
- 平台：Windows（D:\tool）
- 使用领域：CTF Web / 命令注入
- 主要用途：自动化命令注入检测与利用工具。
- 工具位置：`D:\tool\CTF\Web\commix\commix.py`
- 当前状态：已在 D:\tool 中确认位置
- 来源线索：`D:\tool`

## 比赛中怎么用

commix 的核心价值是：自动化命令注入检测与利用工具。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
python commix.py -u "http://target/?q=test" --batch
```

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### commix --help

```text
Usage: python commix.py [option(s)]

Options:
  -h, --help            Show help and exit.

  General:
    These options relate to general matters.

    -v VERBOSE          Verbosity level (0-4, Default: 0).
    --install           Install commix to your system.
    --version           Show version number and exit.
    --update            Check for updates (apply if any) and exit.
    --output-dir=OUT..  Set custom output directory path.
    -s SESSION_FILE     Load session from a stored (.sqlite) file.
    --flush-session     Flush session files for current target.
    --ignore-session    Ignore results stored in session file.
    -t TRAFFIC_FILE     Log all HTTP traffic into a textual file.
    --time-limit=TIM..  Run with a time limit in seconds (e.g. 3600).
    --batch             Never ask for user input, use the default behaviour.
    --skip-heuristics   Skip heuristic detection for code injection.
    --codec=CODEC       Force codec for character encoding (e.g. 'ascii').
    --charset=CHARSET   Time-related injection charset (e.g.
                        '0123456789abcdef').
    --check-internet    Check internet connection before assessing the target.
    --answers=ANSWERS   Set predefined answers (e.g. 'quit=N,follow=N').

  Target:
    This options has to be provided, to define the target URL.

    -u URL, --url=URL   Target URL.
    --url-reload        Reload target URL after command execution.
    -l LOGFILE          Parse target from HTTP proxy log file.
    -m BULKFILE         Scan multiple targets given in a textual file.
    -r REQUESTFILE      Load HTTP request from a file.
    --crawl=CRAWLDEPTH  Crawl the website starting from the target URL
                        (Default: 1).
    --crawl-exclude=..  Regexp to exclude pages from crawling (e.g. 'logout').
    -x SITEMAP_URL      Parse target(s) from remote sitemap(.xml) file.
    --method=METHOD     Force usage of given HTTP method (e.g. 'PUT').

  Request:
    These options can be used to specify how to connect to the target URL.

    -d DATA, --data=..  Data string to be sent through POST.
    --host=HOST         HTTP Host header.
    --referer=REFERER   HTTP Referer header.
    --user-agent=AGENT  HTTP User-Agent header.
    --random-agent      Use a randomly selected HTTP User-Agent header.
    --param-del=PDEL    Set character for splitting parameter values.
    --cookie=COOKIE     HTTP Cookie header.
    --cookie-del=CDEL   Set character for splitting cookie values.
    --http1.0           Force requests to use the HTTP/1.0 protocol.
    -H HEADER, --hea..  Extra header (e.g. 'X-Forwarded-For: 127.0.0.1').
    --headers=HEADERS   Extra headers (e.g. 'Accept-Language: fr\nETag: 123').
    --proxy=PROXY       Use a proxy to connect to the target URL.
    --tor               Use the Tor network.
    --tor-port=TOR_P..  Set Tor proxy port (Default: 8118).
    --tor-check         Check to see if Tor is used properly.
    --auth-url=AUTH_..  Login panel URL.
    --auth-data=AUTH..  Login parameters and data.
    --auth-type=AUTH..  HTTP authentication type (Basic, Digest, Bearer).
    --auth-cred=AUTH..  HTTP authentication credentials (e.g. 'admin:admin').
    --abort-code=ABO..  Abort on (problematic) HTTP error code(s) (e.g. 401).
    --ignore-code=IG..  Ignore (problematic) HTTP error code(s) (e.g. 401).
    --force-ssl         Force usage of SSL/HTTPS.
    --ignore-proxy      Ignore system default proxy settings.
    --ignore-redirects  Ignore redirection attempts.
    --timeout=TIMEOUT   Seconds to wait before timeout connection (Default:
                        30).
    --retries=RETRIES   Retries when the connection timeouts (Default: 3).
    --drop-set-cookie   Ignore Set-Cookie header from response.

  Enumeration:
    These options can be used to enumerate the target host.

    --all               Retrieve everything.
    --current-user      Retrieve current user name.
    --hostname          Retrieve current hostname.
    --is-root           Check if the current user have root privileges.
    --is-admin          Check if the current user have admin privileges.
    --sys-info          Retrieve system information.
    --users             Retrieve system users.
    --passwords         Retrieve system users password hashes.
    --privileges        Retrieve system users privileges.
    --ps-version        Retrieve PowerShell's version number.

  File access:
    These options can be used to access files on the target host.

    --file-read=FILE..  Read a file from the target host.
    --file-write=FIL..  Write to a file on the target host.
    --file-upload=FI..  Upload a file on the target host.
    --file-dest=FILE..  Host's absolute filepath to write and/or upload to.

  Modules:
    These options can be used increase the detection and/or injection
    capabilities.

    --shellshock        The 'shellshock' injection module.

  Injection:
    These options can be used to specify which parameters to inject and to
    provide custom injection payloads.

    -p TEST_PARAMETER   Testable parameter(s).
    --skip=SKIP_PARA..  Skip testing for given parameter(s).
    --suffix=SUFFIX     Injection payload suffix string.
    --prefix=PREFIX     Injection payload prefix string.
    --technique=TECH    Specify injection technique(s) to use.
    --skip-technique..  Specify injection technique(s) to skip.
    --maxlen=MAXLEN     Set the max length of output for time-related
                        injection techniques (Default: 10000 chars).
    --delay=DELAY       Seconds to delay between each HTTP request.
    --time-sec=TIMESEC  Seconds to delay the OS response.
    --tmp-path=TMP_P..  Set the absolute path of web server's temp directory.
    --web-root=WEB_R..  Set the web server document root directory (e.g.
                        '/var/www').
    --alter-shell=AL..  Use an alternative os-shell (e.g. 'Python').
    --os-cmd=OS_CMD     Execute a single operating system command.
    --os=OS             Force back-end operating system (e.g. 'Windows' or
                        'Unix').
    --tamper=TAMPER     Use given script(s) for tampering injection data.
    --msf-path=MSF_P..  Set a local path where metasploit is installed.

  Detection:
    These options can be used to customize the detection phase.

    --level=LEVEL       Level of tests to perform (1-3, Default: 1).
    --skip-calc         Skip the mathematic calculation during the detection
                        phase.
    --skip-empty        Skip testing the parameter(s) with empty value(s).
    --failed-tries=F..  Set a number of failed injection tries, in file-based
                        technique.
    --smart             Perform thorough tests only if positive heuristic(s).

  Miscellaneous:
    --ignore-depende..  Ignore all required third-party library dependencies.
    --list-tampers      Display list of available tamper scripts.
    --alert=ALERT       Run host OS command(s) when injection point is found.
    --no-logging        Disable logging to a file.
    --purge             Safely remove all content from commix data directory.
    --skip-waf          Skip heuristic detection of WAF/IPS protection.
    --mobile            Imitate smartphone through HTTP User-Agent header.
    --offline           Work in offline mode.
    --wizard            Simple wizard interface for beginner users.
    --disable-coloring  Disable console output coloring.
```

