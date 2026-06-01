---
title: "netexec"
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：AD / 内网
- 主要用途：NetExec（CME 后继）用于 SMB/LDAP/WinRM/MSSQL/SSH 等服务枚举、认证验证和横向。
- 工具位置：`/usr/bin/netexec`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/netexec.md`

## 比赛中怎么用

netexec 的核心价值是：NetExec（CME 后继）用于 SMB/LDAP/WinRM/MSSQL/SSH 等服务枚举、认证验证和横向。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
netexec smb 10.0.0.0/24 -u user -p pass --shares
```
```bash
netexec winrm 10.0.0.5 -u user -p pass -x whoami
```

## 参数说明

- 全局参数负责目标、认证、线程、超时；协议子命令如 `smb`、`ldap`、`winrm` 有各自参数。
- SMB 常用：`--shares`、`--users`、`--groups`、`--rid-brute`、`--sam`、`--lsa`。
- 执行：`-x`、`-X`、`--exec-method`。
完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 完整参数帮助输出

### netexec --help

```text
usage: netexec [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER] [--dns-tcp]
               [--dns-timeout DNS_TIMEOUT]
               {ftp,ssh,nfs,vnc,mssql,rdp,ldap,smb,wmi,winrm} ...

     .   .
    .|   |.     _   _          _     _____
    ||   ||    | \ | |   ___  | |_  | ____| __  __   ___    ___
    \\( )//    |  \| |  / _ \ | __| |  _|   \ \/ /  / _ \  / __|
    .=[ ]=.    | |\  | |  __/ | |_  | |___   >  <  |  __/ | (__
   / /˙-˙\ \   |_| \_|  \___|  \__| |_____| /_/\_\  \___|  \___|
   ˙ \   / ˙
     ˙   ˙

    The network execution tool
    Maintained as an open source project by @NeffIsBack, @MJHallenbeck, @_zblurx

    For documentation and usage examples, visit: https://www.netexec.wiki/

    Version : 1.5.1
    Codename: Yippie-Ki-Yay
    Commit  : Kali Linux
    

options:
  -h, --help            show this help message and exit

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds

Available Protocols:
  {ftp,ssh,nfs,vnc,mssql,rdp,ldap,smb,wmi,winrm}
    ftp                 own stuff using FTP
    ssh                 own stuff using SSH
    nfs                 own stuff using NFS
    vnc                 own stuff using VNC
    mssql               own stuff using MSSQL
    rdp                 own stuff using RDP
    ldap                own stuff using LDAP
    smb                 own stuff using SMB
    wmi                 own stuff using WMI
    winrm               own stuff using WINRM
```

### netexec smb --help

```text
usage: netexec smb [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                   [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                   [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                   [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                   [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [-H HASH [HASH ...]] [--delegate DELEGATE] [--delegate-spn DELEGATE_SPN]
                   [--generate-st GENERATE_ST] [--self] [-d DOMAIN | --local-auth] [--port PORT] [--share SHARE] [--smb-server-port SMB_SERVER_PORT] [--no-smbv1]
                   [--no-admin-check] [--gen-relay-list OUTPUT_FILE] [--smb-timeout SMB_TIMEOUT] [--laps [LAPS]] [--generate-hosts-file GENERATE_HOSTS_FILE]
                   [--generate-krb5-file GENERATE_KRB5_FILE] [--generate-tgt GENERATE_TGT] [--sam [{regdump,secdump}]] [--lsa [{regdump,secdump}]] [--ntds [{drsuapi,vss}]]
                   [--kerberos-keys] [--history | --enabled] [--user USERNTDS] [--dpapi [{nosystem,cookies} ...]] [--sccm [{disk,wmi}]] [--mkfile MKFILE] [--pvk PVK]
                   [--list-snapshots [LIST_SNAPSHOTS]] [--shares [SHARES]] [--exclude-shares EXCLUDE_SHARES [EXCLUDE_SHARES ...]] [--dir [DIR]] [--interfaces] [--no-write-check]
                   [--filter-shares FILTER_SHARES [FILTER_SHARES ...]] [--disks] [--users [USER ...]] [--users-export USERS_EXPORT] [--groups [GROUP]] [--local-groups [GROUP]]
                   [--computers [COMPUTER]] [--pass-pol] [--rid-brute [MAX_RID]] [--smb-sessions] [--reg-sessions [REG_SESSIONS]] [--loggedon-users [LOGGEDON_USERS]]
                   [--loggedon-users-filter LOGGEDON_USERS_FILTER] [--qwinsta [QWINSTA]] [--tasklist [TASKLIST]] [--taskkill TASKKILL] [--wmi-query QUERY]
                   [--wmi-namespace NAMESPACE] [--spider SHARE] [--spider-folder FOLDER] [--content] [--exclude-dirs DIR_LIST] [--depth DEPTH] [--only-files] [--silent]
                   [--pattern PATTERN [PATTERN ...] | --regex REGEX [REGEX ...]] [--put-file FILE FILE] [--get-file FILE FILE] [--append-host]
                   [--exec-method {smbexec,mmcexec,wmiexec,atexec}] [--dcom-timeout DCOM_TIMEOUT] [--get-output-tries GET_OUTPUT_TRIES] [--codec CODEC] [--no-output]
                   [-x COMMAND | -X PS_COMMAND] [--obfs] [--amsi-bypass FILE] [--clear-obfscripts] [--force-ps32] [--no-encode]
                   target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  -H, --hash HASH [HASH ...]
                        NTLM hash(es) or file(s) containing NTLM hashes
  --delegate DELEGATE   Impersonate user with S4U2Self + S4U2Proxy
  --delegate-spn DELEGATE_SPN
                        SPN to use for S4U2Proxy, if not specified the SPN used will be cifs/<target>
  --generate-st GENERATE_ST
                        Store the S4U Service Ticket in the specified file
  --self                Only do S4U2Self, no S4U2Proxy (use with delegate)
  -d, --domain DOMAIN   domain to authenticate to
  --local-auth          authenticate locally to each target
  --port PORT           SMB port (default: 445)
  --share SHARE         specify a share (default: C$)
  --smb-server-port SMB_SERVER_PORT
                        specify a server port for SMB (default: 445)
  --no-smbv1            Force to disable SMBv1 in connection
  --no-admin-check      Avoid checking admin which queries the Service Control Manager
  --gen-relay-list OUTPUT_FILE
                        outputs all hosts that don't require SMB signing to the specified file
  --smb-timeout SMB_TIMEOUT
                        SMB connection timeout (default: 2)
  --laps [LAPS]         LAPS authentification
  --generate-hosts-file GENERATE_HOSTS_FILE
                        Generate a hosts file like from a range of IP
  --generate-krb5-file GENERATE_KRB5_FILE
                        Generate a krb5 file like from a range of IP
  --generate-tgt GENERATE_TGT
                        Generate a tgt ticket

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use (default: 256)
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds (default: 3)

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

Credential Gathering:
  --sam [{regdump,secdump}]
                        dump SAM hashes from target systems
  --lsa [{regdump,secdump}]
                        dump LSA secrets from target systems
  --ntds [{drsuapi,vss}]
                        dump the NTDS.dit from target DCs using the specifed method
  --kerberos-keys       Also dump Kerberos AES and DES keys from target DC (NTDS.dit)
  --history             Also retrieve password history from target DC (NTDS.dit)
  --enabled             Only dump enabled targets from DC (NTDS.dit)
  --user USERNTDS       Dump selected user from DC (NTDS.dit)
  --dpapi [{nosystem,cookies} ...]
                        dump DPAPI secrets from target systems, can dump cookies if you add 'cookies', will not dump SYSTEM dpapi if you add nosystem
  --sccm [{disk,wmi}]   dump SCCM secrets from target systems
  --mkfile MKFILE       DPAPI option. File with masterkeys in form of {GUID}:SHA1
  --pvk PVK             DPAPI option. File with domain backupkey
  --list-snapshots [LIST_SNAPSHOTS]
                        Lists the VSS snapshots (default: ADMIN$)

Mapping/Enumeration:
  --shares [SHARES]     Enumerate shares and access, filter on specified argument (read ; write ; read,write)
  --exclude-shares EXCLUDE_SHARES [EXCLUDE_SHARES ...]
                        List of shares to exclude from enumeration (e.g., C$ Admin$ IPC$)
  --dir [DIR]           List the content of a path (default path: '')
  --interfaces          Enumerate network interfaces
  --no-write-check      Skip write check on shares (avoid leaving traces when missing delete permissions)
  --filter-shares FILTER_SHARES [FILTER_SHARES ...]
                        Filter share by access, option 'READ' 'WRITE' or 'READ,WRITE'
  --disks               Enumerate disks
  --users [USER ...]    Enumerate domain users, if a user is specified than only its information is queried.
  --users-export USERS_EXPORT
                        Enumerate domain users and export them to the specified file
  --groups [GROUP]      Enumerate domain groups, if a group is specified than its members are Enumerated
  --local-groups [GROUP]
                        Enumerate local groups, if a group is specified then its members are Enumerated
  --computers [COMPUTER]
                        Enumerate computer users
  --pass-pol            dump password policy
  --rid-brute [MAX_RID]
                        Enumerate users by bruteforcing RIDs
  --smb-sessions        Enumerate active smb sessions
  --reg-sessions [REG_SESSIONS]
                        Enumerate users sessions using the Remote Registry. If a username is given, filter for it. If a file is given, filter for listed usernames. If no value is
                        given, list all.
  --loggedon-users [LOGGEDON_USERS]
                        Enumerate logged on users, if a user is specified than a regex filter is applied.
  --loggedon-users-filter LOGGEDON_USERS_FILTER
                        only search for specific user, works with regex
  --qwinsta [QWINSTA]   Enumerate user sessions. If a username is given, filter for it; if a file is given, filter for listed usernames. If no value is given, list all.
  --tasklist [TASKLIST]
                        Enumerate running processes and filter for the specified one if specified
  --taskkill TASKKILL   Kills a specific PID or a proces name's PID's

WMI Queries:
  --wmi-query QUERY     Issues the specified WMI query
  --wmi-namespace NAMESPACE
                        WMI Namespace (default: root\cimv2)

Spidering Shares:
  --spider SHARE        share to spider
  --spider-folder FOLDER
                        folder to spider (default: .)
  --content             enable file content searching
  --exclude-dirs DIR_LIST
                        directories to exclude from spidering
  --depth DEPTH         max spider recursion depth
  --only-files          only spider files
  --silent              Do not print found files/directories
  --pattern PATTERN [PATTERN ...]
                        pattern(s) to search for in folders, filenames and file content
  --regex REGEX [REGEX ...]
                        regex(s) to search for in folders, filenames and file content

File Operations:
  --put-file FILE FILE  Put a local file into remote target, ex: whoami.txt \\Windows\\Temp\\whoami.txt
  --get-file FILE FILE  Get a remote file, ex: \\Windows\\Temp\\whoami.txt whoami.txt
  --append-host         append the host to the get-file filename

Command Execution:
  --exec-method {smbexec,mmcexec,wmiexec,atexec}
                        method to execute the command. Ignored if in MSSQL mode (default: wmiexec)
  --dcom-timeout DCOM_TIMEOUT
                        DCOM connection timeout (default: 5)
  --get-output-tries GET_OUTPUT_TRIES
                        Number of times atexec/smbexec/mmcexec tries to get results (default: 10)
  --codec CODEC         Set encoding used (codec) from the target's output. If errors are detected, run chcp.com at the target & map the result with
                        https://docs.python.org/3/library/codecs.html#standard-encodings and then execute again with --codec and the corresponding codec (default: utf-8)
  --no-output           do not retrieve command output
  -x COMMAND            execute the specified CMD command
  -X PS_COMMAND         execute the specified PowerShell command

Powershell Script Obfuscation:
  --obfs                Obfuscate PowerShell scripts
  --amsi-bypass FILE    File with a custom AMSI bypass
  --clear-obfscripts    Clear all cached obfuscated PowerShell scripts
  --force-ps32          force PowerShell commands to run in a 32-bit process (may not apply to modules)
  --no-encode           Do not encode the PowerShell command ran on target
```

### netexec ldap --help

```text
usage: netexec ldap [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                    [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                    [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                    [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                    [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [-H HASH [HASH ...] | --simple-bind] [--port PORT] [-d DOMAIN]
                    [--asreproast ASREPROAST] [--kerberoasting KERBEROASTING] [--kerberoast-account KERBEROAST_ACCOUNT [KERBEROAST_ACCOUNT ...]]
                    [--no-preauth-targets NO_PREAUTH_TARGETS] [--base-dn BASE_DN] [--query QUERY QUERY] [--find-delegation] [--trusted-for-delegation] [--password-not-required]
                    [--admin-count] [--users [USERS ...]] [--users-export USERS_EXPORT] [--groups [GROUPS]] [--computers] [--dc-list] [--get-sid]
                    [--active-users [ACTIVE_USERS ...]] [--pso] [--pass-pol] [--gmsa] [--gmsa-convert-id GMSA_CONVERT_ID] [--gmsa-decrypt-lsa GMSA_DECRYPT_LSA] [--bloodhound]
                    [-c COLLECTION]
                    target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  -H, --hash HASH [HASH ...]
                        NTLM hash(es) or file(s) containing NTLM hashes
  --simple-bind         Use simple bind authentication (no signing/sealing)
  --port PORT           LDAP port (default: 389)
  -d DOMAIN             domain to authenticate to

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use (default: 256)
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds (default: 3)

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

Retrieve hash on the remote DC:
  Options to get hashes from Kerberos

  --asreproast ASREPROAST
                        Output AS_REP response to crack with hashcat to file
  --kerberoasting, --kerberoast KERBEROASTING
                        Output TGS ticket to crack with hashcat to file
  --kerberoast-account KERBEROAST_ACCOUNT [KERBEROAST_ACCOUNT ...]
                        Target specific accounts for kerberoasting (sAMAccountNames or file containing sAMAccountNames)
  --no-preauth-targets NO_PREAUTH_TARGETS
                        Targeted kerberoastable users

Retrieve useful information on the domain:
  --base-dn BASE_DN     base DN for search queries
  --query QUERY QUERY   Query LDAP with a custom filter and attributes
  --find-delegation     Finds delegation relationships within an Active Directory domain. (Enabled Accounts only)
  --trusted-for-delegation
                        Get the list of users and computers with flag TRUSTED_FOR_DELEGATION
  --password-not-required
                        Get the list of users with flag PASSWD_NOTREQD
  --admin-count         Get user that had the value adminCount=1
  --users [USERS ...]   Enumerate domain users
  --users-export USERS_EXPORT
                        Enumerate domain users and export them to the specified file
  --groups [GROUPS]     Enumerate domain groups, if a group is specified than its members are enumerated
  --computers           Enumerate domain computers
  --dc-list             Enumerate Domain Controllers
  --get-sid             Get domain sid
  --active-users [ACTIVE_USERS ...]
                        Get Active Domain Users Accounts
  --pso                 Get Fine Grained Password Policy/PSOs
  --pass-pol            Dump password policy

Retrieve gmsa on the remote DC:
  Options to play with gmsa

  --gmsa                Enumerate GMSA passwords
  --gmsa-convert-id GMSA_CONVERT_ID
                        Get the secret name of specific gmsa or all gmsa if no gmsa provided
  --gmsa-decrypt-lsa GMSA_DECRYPT_LSA
                        Decrypt the gmsa encrypted value from LSA

Bloodhound Scan:
  Options to play with Bloodhoud

  --bloodhound          Perform a Bloodhound scan
  -c, --collection COLLECTION
                        Which information to collect. Supported: Group, LocalAdmin, Session, Trusts, Default, DCOnly, DCOM, RDP, PSRemote, LoggedOn, Container, ObjectProps, ACL,
                        All. You can specify more than one by separating them with a comma (default: Default)
```

### netexec winrm --help

```text
usage: netexec winrm [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                     [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                     [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                     [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                     [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [-H HASH [HASH ...]] [--port PORT [PORT ...]]
                     [--check-proto CHECK_PROTO [CHECK_PROTO ...]] [--laps [LAPS]] [--http-timeout HTTP_TIMEOUT] [-d DOMAIN | --local-auth] [--dump-method {powershell,cmd}]
                     [--sam] [--lsa] [--dpapi] [--codec CODEC] [--no-output] [-x COMMAND] [-X PS_COMMAND]
                     target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  -H, --hash HASH [HASH ...]
                        NTLM hash(es) or file(s) containing NTLM hashes
  --port PORT [PORT ...]
                        WinRM port - format: 'http-port https-port' (with space separated) or 'single-port' (http & https will use same port when given single port) (default:
                        ['5985', '5986'])
  --check-proto CHECK_PROTO [CHECK_PROTO ...]
                        Choose what protocol you want to check - format: 'http https' (with space separated) or 'single-protocol' (default: ['http', 'https'])
  --laps [LAPS]         LAPS authentication
  --http-timeout HTTP_TIMEOUT
                        HTTP timeout for WinRM connections (default: 10)
  -d DOMAIN             domain to authenticate to
  --local-auth          authenticate locally to each target

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use (default: 256)
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds (default: 3)

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

Credential Gathering:
  --dump-method {powershell,cmd}
                        Select shell type in hashes dump for sam or lsa (default: cmd)
  --sam                 dump SAM hashes from target systems
  --lsa                 dump LSA secrets from target systems
  --dpapi               dump user's Credential Manager secrets from target systems

Command Execution:
  --codec CODEC         Set encoding used (codec) from the target's output. If errors are detected, run chcp.com at the target & map the result with
                        https://docs.python.org/3/library/codecs.html#standard-encodings and then execute again with --codec and the corresponding codec (default: utf-8)
  --no-output           do not retrieve command output
  -x COMMAND            execute the specified command
  -X PS_COMMAND         execute the specified PowerShell command
```

### netexec mssql --help

```text
usage: netexec mssql [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                     [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                     [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                     [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                     [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [-H HASH [HASH ...]] [--port PORT] [--mssql-timeout MSSQL_TIMEOUT] [-q QUERY]
                     [--database [NAME]] [-d DOMAIN | --local-auth] [--sam] [--lsa] [--no-output] [-x COMMAND | -X PS_COMMAND] [--force-ps32] [--obfs] [--amsi-bypass FILE]
                     [--clear-obfscripts] [--no-encode] [--put-file SRC_FILE DEST_FILE] [--get-file SRC_FILE DEST_FILE] [--rid-brute [MAX_RID]]
                     target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  -H, --hash HASH [HASH ...]
                        NTLM hash(es) or file(s) containing NTLM hashes
  --port PORT           MSSQL port (default: 1433)
  --mssql-timeout MSSQL_TIMEOUT
                        SQL server connection timeout (default: 5)
  -q, --query QUERY     execute the specified query against the mssql db
  --database [NAME]     list databases or list tables for NAME
  -d DOMAIN             domain name
  --local-auth          authenticate locally to each target

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use (default: 256)
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds (default: 3)

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

Credential Gathering:
  --sam                 dump SAM hashes from target systems
  --lsa                 dump LSA secrets from target systems

Command Execution:
  --no-output           do not retrieve command output
  -x COMMAND            execute the specified command
  -X PS_COMMAND         execute the specified PowerShell command

Powershell Options:
  --force-ps32          Force the PowerShell command to run in a 32-bit process via a job; WARNING: depends on the job completing quickly, so you may have to increase the timeout
  --obfs                Obfuscate PowerShell ran on target; WARNING: Defender will almost certainly trigger on this
  --amsi-bypass FILE    File with a custom AMSI bypass
  --clear-obfscripts    Clear all cached obfuscated PowerShell scripts
  --no-encode           Do not encode the PowerShell command ran on target

File Operations:
  --put-file SRC_FILE DEST_FILE
                        Put a local file into remote target, ex: whoami.txt C:\\Windows\\Temp\\whoami.txt
  --get-file SRC_FILE DEST_FILE
                        Get a remote file, ex: C:\\Windows\\Temp\\whoami.txt whoami.txt

Mapping/Enumeration:
  --rid-brute [MAX_RID]
                        enumerate users by bruteforcing RIDs
```

### netexec ssh --help

```text
usage: netexec ssh [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                   [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                   [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                   [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                   [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [--key-file KEY_FILE] [--port PORT] [--ssh-timeout SSH_TIMEOUT] [--sudo-check]
                   [--sudo-check-method {mkfifo,sudo-stdin}] [--get-output-tries GET_OUTPUT_TRIES] [--put-file FILE FILE] [--get-file FILE FILE] [--codec CODEC] [--no-output]
                   [-x COMMAND]
                   target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  --key-file KEY_FILE   Authenticate using the specified private key. Treats the password parameter as the key's passphrase.
  --port PORT           SSH port (default: 22)
  --ssh-timeout SSH_TIMEOUT
                        SSH connection timeout (default: 15)
  --sudo-check          Check user privilege with sudo
  --sudo-check-method {mkfifo,sudo-stdin}
                        method to do with sudo check (mkfifo is non-stable, probably you need to execute once again if it failed)' (default: sudo-stdin)
  --get-output-tries GET_OUTPUT_TRIES
                        Number of times with sudo command tries to get results (default: 5)

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use (default: 256)
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds (default: 3)

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

File Operations:
  --put-file FILE FILE  Put a local file into remote target, ex: whoami.txt /tmp/whoami.txt
  --get-file FILE FILE  Get a remote file, ex: /tmp/whoami.txt whoami.txt

Command Execution:
  --codec CODEC         Set encoding used (codec) from the target's output. If errors are detected, run chcp.com at the target, map the result with
                        https://docs.python.org/3/library/codecs.html#standard-encodings and then execute again with --codec and the corresponding codec (default: utf-8)
  --no-output           do not retrieve command output
  -x COMMAND            execute the specified command
```

### netexec ftp --help

```text
usage: netexec ftp [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                   [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                   [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                   [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                   [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [--port PORT] [--ls [DIRECTORY]] [--get FILE] [--put LOCAL_FILE REMOTE_FILE]
                   target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  --port PORT           FTP port (default: 21)

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use (default: 256)
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds (default: 3)

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

File Operations:
  --ls [DIRECTORY]      List all files (including hidden) in the directory
  --get FILE            Download a file
  --put LOCAL_FILE REMOTE_FILE
                        Upload a file
```

### netexec rdp --help

```text
usage: netexec rdp [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                   [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                   [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                   [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                   [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [-H HASH [HASH ...]] [--port PORT] [--rdp-timeout RDP_TIMEOUT] [--nla-screenshot]
                   [-d DOMAIN | --local-auth] [--screenshot] [--screentime SCREENTIME] [--res RES] [-x COMMAND] [-X PS_COMMAND] [--cmd-delay CMD_DELAY]
                   [--clipboard-delay CLIPBOARD_DELAY] [--no-output]
                   target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  -H, --hash HASH [HASH ...]
                        NTLM hash(es) or file(s) containing NTLM hashes
  --port PORT           RDP port (default: 3389)
  --rdp-timeout RDP_TIMEOUT
                        RDP timeout on socket connection (default: 5)
  --nla-screenshot      Screenshot RDP login prompt if NLA is disabled
  -d DOMAIN             domain to authenticate to
  --local-auth          authenticate locally to each target

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use (default: 256)
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds (default: 3)

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

Screenshot:
  Remote Desktop Screenshot

  --screenshot          Screenshot RDP if connection success
  --screentime SCREENTIME
                        Time to wait for desktop image (default: 10)
  --res RES             Resolution in WIDTHxHEIGHT format (default: 1024x768)

Command Execution:
  -x COMMAND            execute the specified command
  -X PS_COMMAND         execute the specified PowerShell command
  --cmd-delay CMD_DELAY
                        Sleep time before executing command (default: 5)
  --clipboard-delay CLIPBOARD_DELAY
                        Maximum time to wait for clipboard initialization (seconds) (default: 30)
  --no-output           do not retrieve command output
```

### netexec vnc --help

```text
usage: netexec vnc [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                   [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                   [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                   [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                   [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [--port PORT] [--vnc-sleep VNC_SLEEP] [--screenshot] [--screentime SCREENTIME]
                   target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  --port PORT           VNC port (default: 5900)
  --vnc-sleep VNC_SLEEP
                        VNC Sleep on socket connection to avoid rate limit (default: 5)

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use (default: 256)
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds (default: 3)

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

Screenshot:
  VNC Server

  --screenshot          Screenshot VNC if connection success
  --screentime SCREENTIME
                        Time to wait for desktop image (default: 5)
```

### netexec nfs --help

```text
usage: netexec nfs [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                   [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                   [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                   [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                   [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [--port PORT] [--nfs-timeout NFS_TIMEOUT] [--share SHARE] [--shares]
                   [--enum-shares [ENUM_SHARES]] [--ls [PATH]] [--get-file FILE FILE] [--put-file FILE FILE]
                   target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  --port PORT           NFS portmapper port (default: 111)
  --nfs-timeout NFS_TIMEOUT
                        NFS connection timeout (default: 5s)

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

NFS Mapping/Enumeration:
  --share SHARE         Specify a share, e.g. for --ls, --get-file, --put-file
  --shares              List NFS shares
  --enum-shares [ENUM_SHARES]
                        Authenticate and enumerate exposed shares recursively (default depth: 3)
  --ls [PATH]           List files in the specified NFS share. Example: --ls /
  --get-file FILE FILE  Download remote NFS file. Example: --get-file remote_file local_file
  --put-file FILE FILE  Upload remote NFS file with chmod 777 permissions to the specified folder. Example: --put-file local_file remote_file
```

### netexec wmi --help

```text
usage: netexec wmi [-h] [--version] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--no-progress] [--log LOG] [--verbose | --debug] [-6] [--dns-server DNS_SERVER]
                   [--dns-tcp] [--dns-timeout DNS_TIMEOUT] [-u USERNAME [USERNAME ...]] [-p PASSWORD [PASSWORD ...]] [-id CRED_ID [CRED_ID ...]] [--ignore-pw-decoding]
                   [--no-bruteforce] [--continue-on-success] [--gfail-limit LIMIT] [--ufail-limit LIMIT] [--fail-limit LIMIT] [-k] [--use-kcache] [--aesKey AESKEY [AESKEY ...]]
                   [--kdcHost KDCHOST] [--pfx-cert PFXCERT] [--pfx-base64 PFXB64] [--pfx-pass PFXPASS] [--pem-cert PEMCERT] [--pem-key PEMKEY] [-M MODULE]
                   [-o MODULE_OPTION [MODULE_OPTION ...]] [-L [LIST_MODULES]] [--options] [-H HASH [HASH ...]] [--port {135}] [--rpc-timeout RPC_TIMEOUT] [-d DOMAIN |
                   --local-auth] [--list-snapshots [LIST_SNAPSHOTS]] [--wmi-query QUERY] [--wmi-namespace NAMESPACE] [--no-output] [-x COMMAND] [-X COMMAND]
                   [--exec-method {wmiexec-event,wmiexec}] [--exec-timeout exec_timeout] [--codec CODEC]
                   target [target ...]

positional arguments:
  target                the target IP(s), range(s), CIDR(s), hostname(s), FQDN(s), file(s) containing a list of targets, NMap XML or .Nessus file(s)

options:
  -h, --help            show this help message and exit
  -H, --hash HASH [HASH ...]
                        NTLM hash(es) or file(s) containing NTLM hashes
  --port {135}          WMI port (default: 135)
  --rpc-timeout RPC_TIMEOUT
                        RPC/DCOM(WMI) connection timeout, default is 2 seconds
  -d DOMAIN             Domain to authenticate to
  --local-auth          Authenticate locally to each target

Generic Options:
  --version             Display nxc version
  -t, --threads THREADS
                        set how many concurrent threads to use
  --timeout TIMEOUT     max timeout in seconds of each thread
  --jitter INTERVAL     sets a random delay between each authentication

Output Options:
  --no-progress         do not displaying progress bar during scan
  --log LOG             export result into a custom file
  --verbose             enable verbose output
  --debug               enable debug level information

DNS:
  -6                    Enable force IPv6
  --dns-server DNS_SERVER
                        Specify DNS server (default: Use hosts file & System DNS)
  --dns-tcp             Use TCP instead of UDP for DNS queries
  --dns-timeout DNS_TIMEOUT
                        DNS query timeout in seconds

Authentication:
  -u, --username USERNAME [USERNAME ...]
                        username(s) or file(s) containing usernames
  -p, --password PASSWORD [PASSWORD ...]
                        password(s) or file(s) containing passwords
  -id CRED_ID [CRED_ID ...]
                        database credential ID(s) to use for authentication
  --ignore-pw-decoding  Ignore non UTF-8 characters when decoding the password file
  --no-bruteforce       No spray when using file for username and password (user1 => password1, user2 => password2)
  --continue-on-success
                        continues authentication attempts even after successes
  --gfail-limit LIMIT   max number of global failed login attempts
  --ufail-limit LIMIT   max number of failed login attempts per username
  --fail-limit LIMIT    max number of failed login attempts per host

Kerberos Authentication:
  -k, --kerberos        Use Kerberos authentication
  --use-kcache          Use Kerberos authentication from ccache file (KRB5CCNAME)
  --aesKey AESKEY [AESKEY ...]
                        AES key to use for Kerberos Authentication (128 or 256 bits)
  --kdcHost KDCHOST     FQDN of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter

Certificate Authentication:
  --pfx-cert PFXCERT    Use certificate authentication from pfx file .pfx
  --pfx-base64 PFXB64   Use certificate authentication from pfx file encoded in base64
  --pfx-pass PFXPASS    Password of the pfx certificate
  --pem-cert PEMCERT    Use certificate authentication from PEM file
  --pem-key PEMKEY      Private key for the PEM format

Modules:
  -M, --module MODULE   module to use
  -o MODULE_OPTION [MODULE_OPTION ...]
                        module options
  -L, --list-modules [LIST_MODULES]
                        list available modules
  --options             display module options

Credential Gathering:
  --list-snapshots [LIST_SNAPSHOTS]
                        Lists the VSS snapshots (default: ADMIN$)

Mapping/Enumeration:
  --wmi-query QUERY     Issues the specified WMI query
  --wmi-namespace NAMESPACE
                        WMI Namespace (default: root\cimv2)

Command Execution:
  --no-output           do not retrieve command output
  -x COMMAND            Creates a new cmd process and executes the specified command with output
  -X COMMAND            Creates a new PowerShell process and executes the specified command with output
  --exec-method {wmiexec-event,wmiexec}
                        method to execute the command. (default: wmiexec). [wmiexec (win32_process + StdRegProv)]: get command results over registry instead of using smb
                        connection. [wmiexec-event (T1546.003)]: this method is not very stable, highly recommend use this method in single host, using on multiple hosts may
                        crash (just try again if it crashed).
  --exec-timeout exec_timeout
                        Set timeout (in seconds) when executing a command, minimum 5 seconds is recommended. Default: 2
  --codec CODEC         Set encoding used (codec) from the target's output (default: utf-8). If errors are detected, run chcp.com at the target & map the result with
                        https://docs.python.org/3/library/codecs.html#standard-encodings and then execute again with --codec and the corresponding codec
```

