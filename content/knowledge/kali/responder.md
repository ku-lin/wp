---
title: "responder"
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：AD / 内网
- 主要用途：LLMNR/NBT-NS/MDNS 投毒与 NTLM 捕获工具，常用于内网凭证获取。
- 工具位置：`/usr/sbin/responder`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/responder.md`

## 比赛中怎么用

responder 的核心价值是：LLMNR/NBT-NS/MDNS 投毒与 NTLM 捕获工具，常用于内网凭证获取。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 参数说明

完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### responder -h

```text
                                         __
  .----.-----.-----.-----.-----.-----.--|  |.-----.----.
  |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
  |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                   |__|

Usage: python3 Responder.py -I eth0 -v

══════════════════════════════════════════════════════════════════════════════
  Responder - LLMNR/NBT-NS/mDNS Poisoner and Rogue Authentication Servers
══════════════════════════════════════════════════════════════════════════════
Captures credentials by responding to broadcast/multicast name resolution,
DHCP, DHCPv6 requests
══════════════════════════════════════════════════════════════════════════════

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit

  Required Options:
These options must be specified

    -I eth0, --interface=eth0
                        Network interface to use. Use 'ALL' for all interfaces.

  Poisoning Options:
Control how Responder poisons name resolution requests

    -A, --analyze       Analyze mode. See requests without poisoning. (passive)
    -e IP, --externalip=IP
                        Poison with a different IPv4 address than Responder's.
    -6 IPv6, --externalip6=IPv6
                        Poison with a different IPv6 address than Responder's.
    --rdnss             Poison via Router Advertisements with RDNSS. Sets attacker as IPv6 DNS.
    --dnssl=DOMAIN      Poison via Router Advertisements with DNSSL. Injects DNS search suffix.
    -t HEX, --ttl=HEX   Set TTL for poisoned answers. Hex value (30s = 1e) or 'random'.
    -N NAME, --AnswerName=NAME
                        Canonical name in LLMNR answers. (for Kerberos relay over HTTP)

  DHCP Options:
DHCP and DHCPv6 poisoning attacks

    -d, --DHCP          Enable DHCPv4 poisoning. Injects WPAD in DHCP responses.
    -D, --DHCP-DNS      Inject DNS server (not WPAD) in DHCPv4 responses.
    --dhcpv6            Enable DHCPv6 poisoning. WARNING: May disrupt network.

  WPAD / Proxy Options:
Web Proxy Auto-Discovery attacks

    -w, --wpad          Start WPAD rogue proxy server.
    -F, --ForceWpadAuth
                        Force NTLM/Basic auth on wpad.dat retrieval. (may show prompt)
    -P, --ProxyAuth     Force proxy authentication. Highly effective. (can't use with -w)
    -u HOST:PORT, --upstream-proxy=HOST:PORT
                        Upstream proxy for rogue WPAD proxy outgoing requests.

  Authentication Options:
Control authentication methods and downgrades

    -b, --basic         Return HTTP Basic auth instead of NTLM. (cleartext passwords)
    --lm                Force LM hashing downgrade. (for Windows XP/2003)
    --disable-ess       Disable Extended Session Security. (NTLMv1 downgrade)
    -E, --ErrorCode     Return STATUS_LOGON_FAILURE. (enables WebDAV auth capture)

  Output Options:
Control verbosity and logging

    -v, --verbose       Increase verbosity. (recommended)
    -Q, --quiet         Quiet mode. Minimal output from poisoners.

  Platform Options:
OS-specific settings

    -i IP, --ip=IP      Local IP to use. (OSX only)

══════════════════════════════════════════════════════════════════════════════
  Examples:
══════════════════════════════════════════════════════════════════════════════
  Basic poisoning:            python3 Responder.py -I eth0 -v

  ##Watch what's going on:
  Analyze mode (passive):     python3 Responder.py -I eth0 -Av

  ##Working on old networks:
  WPAD with forced auth:      python3 Responder.py -I eth0 -wFv

  ##Great module:
  Proxy auth:                 python3 Responder.py -I eth0 -Pv

  ##DHCPv6 + Proxy authentication:
  DHCPv6 attack:              python3 Responder.py -I eth0 --dhcpv6 -vP

  ##DHCP -> WPAD injection -> Proxy authentication:
  DHCP + WPAD injection:      python3 Responder.py -I eth0 -Pvd

  ##Poison requests to an arbitrary IP:
  Poison with external IP:    python3 Responder.py -I eth0 -e 10.0.0.100

  ##Poison requests to an arbitrary IPv6 IP:
  Poison with external IPv6:  python3 Responder.py -I eth0 -6 2800:ac:4000:8f9e:c5eb:2193:71:1d12
══════════════════════════════════════════════════════════════════════════════
  For more info: https://github.com/lgandx/Responder/blob/master/README.md
══════════════════════════════════════════════════════════════════════════════
```

