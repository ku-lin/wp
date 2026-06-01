---
title: "impacket-scripts"
draft: false
---
- 平台：Kali Linux（SSH: 192.168.70.145）
- 使用领域：AD / 内网 / 协议
- 主要用途：Impacket 协议脚本套件，常用于 SMB/Kerberos/NTLM/MSSQL/远程执行/凭证导出。
- 工具位置：`/usr/bin/impacket-smbserver`
- 当前状态：已在 Kali SSH 环境中确认
- 来源线索：`比赛环境手册/tool/impacket-scripts.md`

## 比赛中怎么用

impacket-scripts 的核心价值是：Impacket 协议脚本套件，常用于 SMB/Kerberos/NTLM/MSSQL/远程执行/凭证导出。 比赛时先确认输入文件、目标地址、凭据和权限，再逐步增加参数。

## 常用命令

```bash
impacket-smbserver share . -smb2support
```
```bash
impacket-secretsdump DOMAIN/user:pass@10.0.0.5
```

## 参数说明

- 脚本命名通常是 `impacket-功能名`。
- 认证常见格式：`domain/user:pass@target`。
- Kerberos 常配合 `-k`、`-no-pass`、`-dc-ip`、`-hashes`、`-aesKey`。
完整命令行参数以本节下方“完整参数帮助输出”为准；参数名保留工具原始写法，中文说明用于快速判断比赛场景。GUI 工具如果没有命令行帮助，会在这里标注入口和使用方式。

## 补充说明

- Impacket 是脚本套件，不是单一命令；下方列出了常用脚本及其帮助。

## 完整参数帮助输出

### ls -1 /usr/bin/impacket-* 2>/dev/null | sed 's#.*/##'

```text
impacket-addcomputer
impacket-atexec
impacket-changepasswd
impacket-dacledit
impacket-dcomexec
impacket-describeTicket
impacket-dpapi
impacket-DumpNTLMInfo
impacket-esentutl
impacket-exchanger
impacket-findDelegation
impacket-GetADComputers
impacket-GetADUsers
impacket-getArch
impacket-Get-GPPPassword
impacket-GetLAPSPassword
impacket-GetNPUsers
impacket-getPac
impacket-getST
impacket-getTGT
impacket-GetUserSPNs
impacket-goldenPac
impacket-karmaSMB
impacket-keylistattack
impacket-lookupsid
impacket-machine_role
impacket-mimikatz
impacket-mqtt_check
impacket-mssqlclient
impacket-mssqlinstance
impacket-net
impacket-netview
impacket-ntfs-read
impacket-ntlmrelayx
impacket-owneredit
impacket-ping
impacket-ping6
impacket-psexec
impacket-raiseChild
impacket-rbcd
impacket-rdp_check
impacket-reg
impacket-registry-read
impacket-rpcdump
impacket-rpcmap
impacket-sambaPipe
impacket-samrdump
impacket-secretsdump
impacket-services
impacket-smbclient
impacket-smbexec
impacket-smbserver
impacket-sniff
impacket-sniffer
impacket-split
impacket-ticketConverter
impacket-ticketer
impacket-tstool
impacket-wmiexec
impacket-wmipersist
impacket-wmiquery
```

### impacket-smbserver -h

```text
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

usage: smbserver.py [-h] [-comment COMMENT] [-username USERNAME] [-password PASSWORD] [-hashes LMHASH:NTHASH] [-ts] [-debug] [-ip INTERFACE_ADDRESS] [-port PORT] [-dropssp] [-6]
                    [-smb2support] [-outputfile OUTPUTFILE]
                    shareName sharePath

This script will launch a SMB Server and add a share specified as an argument. Usually, you need to be root in order to bind to port 445. For optional authentication, it is
possible to specify username and password or the NTLM hash. Example: smbserver.py -comment 'My share' TMP /tmp

positional arguments:
  shareName             name of the share to add
  sharePath             path of the share to add

options:
  -h, --help            show this help message and exit
  -comment COMMENT      share's comment to display when asked for shares
  -username USERNAME    Username to authenticate clients
  -password PASSWORD    Password for the Username
  -hashes LMHASH:NTHASH
                        NTLM hashes for the Username, format is LMHASH:NTHASH
  -ts                   Adds timestamp to every logging output
  -debug                Turn DEBUG output ON
  -ip, --interface-address INTERFACE_ADDRESS
                        ip address of listening interface ("0.0.0.0" or "::" if omitted)
  -port PORT            TCP port for listening incoming connections (default 445)
  -dropssp              Disable NTLM ESS/SSP during negotiation
  -6, --ipv6            Listen on IPv6
  -smb2support          SMB2 Support (experimental!)
  -outputfile OUTPUTFILE
                        Output file to log smbserver output messages
```

### impacket-psexec -h

```text
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

usage: psexec.py [-h] [-c pathname] [-path PATH] [-file FILE] [-ts] [-debug] [-codec CODEC] [-hashes LMHASH:NTHASH] [-no-pass] [-k] [-aesKey hex key] [-keytab KEYTAB]
                 [-dc-ip ip address] [-target-ip ip address] [-port [destination port]] [-service-name service_name] [-remote-binary-name remote_binary_name]
                 target [command ...]

PSEXEC like functionality example using RemComSvc.

positional arguments:
  target                [[domain/]username[:password]@]<targetName or address>
  command               command (or arguments if -c is used) to execute at the target (w/o path) - (default:cmd.exe)

options:
  -h, --help            show this help message and exit
  -c pathname           copy the filename for later execution, arguments are passed in the command option
  -path PATH            path of the command to execute
  -file FILE            alternative RemCom binary (be sure it doesn't require CRT)
  -ts                   adds timestamp to every logging output
  -debug                Turn DEBUG output ON
  -codec CODEC          Sets encoding used (codec) from the target's output (default "utf-8"). If errors are detected, run chcp.com at the target, map the result with
                        https://docs.python.org/3/library/codecs.html#standard-encodings and then execute smbexec.py again with -codec and the corresponding codec

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH
  -no-pass              don't ask for password (useful for -k)
  -k                    Use Kerberos authentication. Grabs credentials from ccache file (KRB5CCNAME) based on target parameters. If valid credentials cannot be found, it will use
                        the ones specified in the command line
  -aesKey hex key       AES key to use for Kerberos Authentication (128 or 256 bits)
  -keytab KEYTAB        Read keys for SPN from keytab file

connection:
  -dc-ip ip address     IP Address of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter
  -target-ip ip address
                        IP Address of the target machine. If omitted it will use whatever was specified as target. This is useful when target is the NetBIOS name and you cannot
                        resolve it
  -port [destination port]
                        Destination port to connect to SMB Server
  -service-name service_name
                        The name of the service used to trigger the payload
  -remote-binary-name remote_binary_name
                        This will be the name of the executable uploaded on the target
```

### impacket-wmiexec -h

```text
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

usage: wmiexec.py [-h] [-share SHARE] [-nooutput] [-ts] [-silentcommand] [-debug] [-codec CODEC] [-shell-type {cmd,powershell}] [-com-version MAJOR_VERSION:MINOR_VERSION]
                  [-hashes LMHASH:NTHASH] [-no-pass] [-k] [-aesKey hex key] [-dc-ip ip address] [-target-ip ip address] [-A authfile] [-keytab KEYTAB]
                  target [command ...]

Executes a semi-interactive shell using Windows Management Instrumentation.

positional arguments:
  target                [[domain/]username[:password]@]<targetName or address>
  command               command to execute at the target. If empty it will launch a semi-interactive shell

options:
  -h, --help            show this help message and exit
  -share SHARE          share where the output will be grabbed from (default ADMIN$)
  -nooutput             whether or not to print the output (no SMB connection created)
  -ts                   Adds timestamp to every logging output
  -silentcommand        does not execute cmd.exe to run given command (no output)
  -debug                Turn DEBUG output ON
  -codec CODEC          Sets encoding used (codec) from the target's output (default "utf-8"). If errors are detected, run chcp.com at the target, map the result with
                        https://docs.python.org/3/library/codecs.html#standard-encodings and then execute wmiexec.py again with -codec and the corresponding codec
  -shell-type {cmd,powershell}
                        choose a command processor for the semi-interactive shell
  -com-version MAJOR_VERSION:MINOR_VERSION
                        DCOM version, format is MAJOR_VERSION:MINOR_VERSION e.g. 5.7

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH
  -no-pass              don't ask for password (useful for -k)
  -k                    Use Kerberos authentication. Grabs credentials from ccache file (KRB5CCNAME) based on target parameters. If valid credentials cannot be found, it will use
                        the ones specified in the command line
  -aesKey hex key       AES key to use for Kerberos Authentication (128 or 256 bits)
  -dc-ip ip address     IP Address of the domain controller. If ommited it use the domain part (FQDN) specified in the target parameter
  -target-ip ip address
                        IP Address of the target machine. If omitted it will use whatever was specified as target. This is useful when target is the NetBIOS name and you cannot
                        resolve it
  -A authfile           smbclient/mount.cifs-style authentication file. See smbclient man page's -A option.
  -keytab KEYTAB        Read keys for SPN from keytab file
```

### impacket-secretsdump -h

```text
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

usage: secretsdump.py [-h] [-ts] [-debug] [-system SYSTEM] [-bootkey BOOTKEY] [-security SECURITY] [-sam SAM] [-ntds NTDS] [-resumefile RESUMEFILE] [-skip-sam] [-skip-security]
                      [-outputfile OUTPUTFILE] [-use-vss] [-rodcNo RODCNO] [-rodcKey RODCKEY] [-use-keylist] [-exec-method [{smbexec,wmiexec,mmcexec}]] [-use-remoteSSWMI]
                      [-use-remoteSSWMI-NTDS] [-remoteSSWMI-remote-volume REMOTESSWMI_REMOTE_VOLUME] [-remoteSSWMI-local-path REMOTESSWMI_LOCAL_PATH] [-just-dc-user USERNAME]
                      [-ldapfilter LDAPFILTER] [-just-dc] [-just-dc-ntlm] [-skip-user SKIP_USER] [-pwd-last-set] [-user-status] [-history] [-hashes LMHASH:NTHASH] [-no-pass] [-k]
                      [-aesKey hex key] [-keytab KEYTAB] [-dc-ip ip address] [-target-ip ip address]
                      target

Performs various techniques to dump secrets from the remote machine without executing any agent there.

positional arguments:
  target                [[domain/]username[:password]@]<targetName or address> or LOCAL (if you want to parse local files)

options:
  -h, --help            show this help message and exit
  -ts                   Adds timestamp to every logging output
  -debug                Turn DEBUG output ON
  -system SYSTEM        SYSTEM hive to parse (only binary REGF, as .reg text file lacks the metadata to compute the bootkey)
  -bootkey BOOTKEY      bootkey for SYSTEM hive
  -security SECURITY    SECURITY hive to parse
  -sam SAM              SAM hive to parse
  -ntds NTDS            NTDS.DIT file to parse
  -resumefile RESUMEFILE
                        resume file name to resume NTDS.DIT session dump (only available to DRSUAPI approach). This file will also be used to keep updating the session's state
  -skip-sam             Do NOT parse the SAM hive on remote system
  -skip-security        Do NOT parse the SECURITY hive on remote system
  -outputfile OUTPUTFILE
                        base output filename. Extensions will be added for sam, secrets, cached and ntds
  -use-vss              Use the NTDSUTIL VSS method instead of default DRSUAPI
  -rodcNo RODCNO        Number of the RODC krbtgt account (only avaiable for Kerb-Key-List approach)
  -rodcKey RODCKEY      AES key of the Read Only Domain Controller (only avaiable for Kerb-Key-List approach)
  -use-keylist          Use the Kerb-Key-List method instead of default DRSUAPI
  -exec-method [{smbexec,wmiexec,mmcexec}]
                        Remote exec method to use at target (only when using -use-vss). Default: smbexec
  -use-remoteSSWMI      Remotely create Shadow Snapshot via WMI and download SAM, SYSTEM and SECURITY from it, the parse locally
  -use-remoteSSWMI-NTDS
                        Dump NTDS.DIT also when using the Remote Shadow Snapshot Method via WMI. Use it with dumping from a DC. IMPORTANT: this flag only works when also using
                        -use-remoteSSWMI
  -remoteSSWMI-remote-volume REMOTESSWMI_REMOTE_VOLUME
                        Remote Volume to perform the Shadow Snapshot and download SAM, SYSTEM and SECURITY. It defaults to C:\
  -remoteSSWMI-local-path REMOTESSWMI_LOCAL_PATH
                        Path where download SAM, SYSTEM and SECURITY from Shadow Snapshot. It defaults to current path

display options:
  -just-dc-user USERNAME
                        Extract only NTDS.DIT data for the user specified. Only available for DRSUAPI approach. Implies also -just-dc switch
  -ldapfilter LDAPFILTER
                        Extract only NTDS.DIT data for specific users based on an LDAP filter. Only available for DRSUAPI approach. Implies also -just-dc switch
  -just-dc              Extract only NTDS.DIT data (NTLM hashes and Kerberos keys)
  -just-dc-ntlm         Extract only NTDS.DIT data (NTLM hashes only)
  -skip-user SKIP_USER  Do NOT extract NTDS.DIT data for the user specified. Can provide comma-separated list of users to skip, or text file with one user per line
  -pwd-last-set         Shows pwdLastSet attribute for each NTDS.DIT account. Doesn't apply to -outputfile data
  -user-status          Display whether or not the user is disabled
  -history              Dump password history, and LSA secrets OldVal

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH
  -no-pass              don't ask for password (useful for -k)
  -k                    Use Kerberos authentication. Grabs credentials from ccache file (KRB5CCNAME) based on target parameters. If valid credentials cannot be found, it will use
                        the ones specified in the command line
  -aesKey hex key       AES key to use for Kerberos Authentication (128 or 256 bits)
  -keytab KEYTAB        Read keys for SPN from keytab file

connection:
  -dc-ip ip address     IP Address of the domain controller. If ommited it use the domain part (FQDN) specified in the target parameter
  -target-ip ip address
                        IP Address of the target machine. If omitted it will use whatever was specified as target. This is useful when target is the NetBIOS name and you cannot
                        resolve it
```

### impacket-GetUserSPNs -h

```text
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

usage: GetUserSPNs.py [-h] [-target-domain TARGET_DOMAIN] [-no-preauth NO_PREAUTH] [-stealth] [-machine-only] [-usersfile USERSFILE] [-request] [-request-user username |
                      -request-machine machinename] [-save] [-outputfile OUTPUTFILE] [-ts] [-debug] [-hashes LMHASH:NTHASH] [-no-pass] [-k] [-aesKey hex key] [-dc-ip ip address]
                      [-dc-host hostname]
                      target

Queries target domain for SPNs that are running under a user account

positional arguments:
  target                domain[/username[:password]]

options:
  -h, --help            show this help message and exit
  -target-domain TARGET_DOMAIN
                        Domain to query/request if different than the domain of the user. Allows for Kerberoasting across trusts.
  -no-preauth NO_PREAUTH
                        account that does not require preauth, to obtain Service Ticket through the AS
  -stealth              Removes the (servicePrincipalName=*) filter from the LDAP query for added stealth. May cause huge memory consumption / errors on large domains.
  -machine-only         Queries for machine accounts only, by adjusting `objectCategory=person` to `objectCategory=computer`. Active Directory may limit results to 1,000 objects
                        by default. LDAP paging is required to retrieve more.
  -usersfile USERSFILE  File with user per line to test
  -request              Requests TGS for users and output them in JtR/hashcat format (default False)
  -request-user username
                        Requests TGS for the SPN associated to the user specified (just the username, no domain needed)
  -request-machine machinename
                        Requests TGS for the SPN associated to the machine specified. Example: `workstation01$`
  -save                 Saves TGS requested to disk. Format is <username>.ccache. Auto selects -request
  -outputfile OUTPUTFILE
                        Output filename to write ciphers in JtR/hashcat format. Auto selects -request
  -ts                   Adds timestamp to every logging output.
  -debug                Turn DEBUG output ON

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH
  -no-pass              don't ask for password (useful for -k)
  -k                    Use Kerberos authentication. Grabs credentials from ccache file (KRB5CCNAME) based on target parameters. If valid credentials cannot be found, it will use
                        the ones specified in the command line
  -aesKey hex key       AES key to use for Kerberos Authentication (128 or 256 bits)

connection:
  -dc-ip ip address     IP Address of the domain controller. If ommited it use the domain part (FQDN) specified in the target parameter. Ignoredif -target-domain is specified.
  -dc-host hostname     Hostname of the domain controller to use. If ommited, the domain part (FQDN) specified in the account parameter will be used
```

### impacket-GetNPUsers -h

```text
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

usage: GetNPUsers.py [-h] [-request] [-outputfile OUTPUTFILE] [-format {hashcat,john}] [-usersfile USERSFILE] [-ts] [-debug] [-hashes LMHASH:NTHASH] [-no-pass] [-k]
                     [-aesKey hex key] [-dc-ip ip address] [-dc-host hostname]
                     target

Queries target domain for users with 'Do not require Kerberos preauthentication' set and export their TGTs for cracking

positional arguments:
  target                [[domain/]username[:password]]

options:
  -h, --help            show this help message and exit
  -request              Requests TGT for users and output them in JtR/hashcat format (default False)
  -outputfile OUTPUTFILE
                        Output filename to write ciphers in JtR/hashcat format
  -format {hashcat,john}
                        format to save the AS_REQ of users without pre-authentication. Default is hashcat
  -usersfile USERSFILE  File with user per line to test
  -ts                   Adds timestamp to every logging output
  -debug                Turn DEBUG output ON

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH
  -no-pass              don't ask for password (useful for -k)
  -k                    Use Kerberos authentication. Grabs credentials from ccache file (KRB5CCNAME) based on target parameters. If valid credentials cannot be found, it will use
                        the ones specified in the command line
  -aesKey hex key       AES key to use for Kerberos Authentication (128 or 256 bits)

connection:
  -dc-ip ip address     IP Address of the domain controller. If ommited it use the domain part (FQDN) specified in the target parameter
  -dc-host hostname     Hostname of the domain controller to use. If ommited, the domain part (FQDN) specified in the account parameter will be used
```

### impacket-ntlmrelayx -h

```text
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

usage: ntlmrelayx.py [-h] [-ts] [-debug] [-t TARGET] [-tf TARGETSFILE] [-w] [-i] [-ip INTERFACE_IP] [--no-smb-server] [--no-http-server] [--no-wcf-server] [--no-raw-server]
                     [--no-rpc-server] [--no-winrm-server] [--smb-port SMB_PORT] [--http-port HTTP_PORT] [--wcf-port WCF_PORT] [--raw-port RAW_PORT] [--rpc-port RPC_PORT]
                     [--no-multirelay] [--keep-relaying] [-ra] [-r SMBSERVER] [-l LOOTDIR] [-of OUTPUT_FILE] [-dh] [-codec CODEC] [-smb2support] [-ntlmchallenge NTLMCHALLENGE]
                     [-socks] [-socks-address SOCKS_ADDRESS] [-socks-port SOCKS_PORT] [-http-api-port HTTP_API_PORT] [-wh WPAD_HOST] [-wa WPAD_AUTH_NUM] [-6] [--remove-mic]
                     [--serve-image SERVE_IMAGE] [-c COMMAND] [-e FILE] [--enum-local-admins] [--rpc-attack {None,TSCH,ICPR}] [-rpc-mode {TSCH,ICPR}] [-rpc-use-smb]
                     [-auth-smb [domain/]username[:password]] [-hashes-smb LMHASH:NTHASH] [-rpc-smb-port {139,445}] [-icpr-ca-name ICPR_CA_NAME] [-q QUERY]
                     [-machine-account MACHINE_ACCOUNT] [-machine-hashes LMHASH:NTHASH] [-domain DOMAIN] [-remove-target] [--no-dump] [--no-da] [--no-acl] [--no-validate-privs]
                     [--escalate-user ESCALATE_USER] [--delegate-access] [--sid] [--dump-laps] [--dump-gmsa] [--dump-adcs] [--add-dns-record NAME IPADDR]
                     [--add-computer [COMPUTERNAME [PASSWORD ...]]] [-k KEYWORD] [-m MAILBOX] [-a] [-im IMAP_MAX] [--adcs] [--template TEMPLATE] [--altname ALTNAME]
                     [--shadow-credentials] [--shadow-target SHADOW_TARGET] [--pfx-password PFX_PASSWORD] [--export-type {PEM,PFX}] [--cert-outfile-path CERT_OUTFILE_PATH]
                     [--sccm-policies] [--sccm-policies-clientname SCCM_POLICIES_CLIENTNAME] [--sccm-policies-sleep SCCM_POLICIES_SLEEP] [--sccm-dp]
                     [--sccm-dp-extensions SCCM_DP_EXTENSIONS] [--sccm-dp-files SCCM_DP_FILES]

For every connection received, this module will try to relay that connection to specified target(s) system or the original client

Main options:
  -h, --help            show this help message and exit
  -ts                   Adds timestamp to every logging output
  -debug                Turn DEBUG output ON
  -t, --target TARGET   Target to relay the credentials to, can be an IP, hostname or URL like domain\username@host:port (domain\username and port are optional, and don't forget
                        to escape the '\'). If unspecified, it will relay back to the client')
  -tf TARGETSFILE       File that contains targets by hostname or full URL, one per line
  -w                    Watch the target file for changes and update target list automatically (only valid with -tf)
  -i, --interactive     Launch an smbclient, LDAP console or SQL shell insteadof executing a command after a successful relay. This console will listen locally on a tcp port and
                        can be reached with for example netcat.
  -ip, --interface-ip INTERFACE_IP
                        IP address of interface to bind relay servers ("0.0.0.0" or "::" if omitted)
  --smb-port SMB_PORT   Port to listen on smb server
  --http-port HTTP_PORT
                        Port(s) to listen on HTTP server. Can specify multiple ports by separating them with `,`, and ranges with `-`. Ex: `80,8000-8010`
  --wcf-port WCF_PORT   Port to listen on wcf server
  --raw-port RAW_PORT   Port to listen on raw server
  --rpc-port RPC_PORT   Port to listen on rpc server
  --no-multirelay       If set, disable multi-host relay (SMB and HTTP servers)
  --keep-relaying       If set, keeps relaying to a target even after a successful connection on it
  -ra, --random         Randomize target selection
  -r SMBSERVER          Redirect HTTP requests to a file:// path on SMBSERVER
  -l, --lootdir LOOTDIR
                        Loot directory in which gathered loot such as SAM dumps will be stored (default: current directory).
  -of, --output-file OUTPUT_FILE
                        base output filename for encrypted hashes. Suffixes will be added for ntlm and ntlmv2
  -dh, --dump-hashes    show encrypted hashes in the console
  -codec CODEC          Sets encoding used (codec) from the target's output (default "utf-8"). If errors are detected, run chcp.com at the target, map the result with
                        https://docs.python.org/3/library/codecs.html#standard-encodings and then execute ntlmrelayx.py again with -codec and the corresponding codec
  -smb2support          SMB2 Support
  -ntlmchallenge NTLMCHALLENGE
                        Specifies the NTLM server challenge used by the SMB Server (16 hex bytes long. eg: 1122334455667788)
  -socks                Launch a SOCKS proxy for the connection relayed
  -socks-address SOCKS_ADDRESS
                        SOCKS5 server address (also used for HTTP API)
  -socks-port SOCKS_PORT
                        SOCKS5 server port
  -http-api-port HTTP_API_PORT
                        SOCKS5 HTTP API port
  -wh, --wpad-host WPAD_HOST
                        Enable serving a WPAD file for Proxy Authentication attack, setting the proxy host to the one supplied.
  -wa, --wpad-auth-num WPAD_AUTH_NUM
                        Prompt for authentication N times for clients without MS16-077 installed before serving a WPAD file. (default=1)
  -6, --ipv6            Listen on IPv6
  --remove-mic          Remove MIC (exploit CVE-2019-1040)
  --serve-image SERVE_IMAGE
                        local path of the image that will we returned to clients
  -c COMMAND            Command to execute on target system (for SMB and RPC). If not specified for SMB, hashes will be dumped (secretsdump.py must be in the same directory). For
                        RPC no output will be provided.

  --no-smb-server       Disables the SMB server
  --no-http-server      Disables the HTTP server
  --no-wcf-server       Disables the WCF server
  --no-raw-server       Disables the RAW server
  --no-rpc-server       Disables the RPC server
  --no-winrm-server     Disables the WinRM server

SMB client options:
  -e FILE               File to execute on the target system. If not specified, hashes will be dumped (secretsdump.py must be in the same directory)
  --enum-local-admins   If relayed user is not admin, attempt SAMR lookup to see who is (only works pre Win 10 Anniversary)
  --rpc-attack {None,TSCH,ICPR}
                        Select the attack to perform over RPC over named pipes.

RPC client options:
  -rpc-mode {TSCH,ICPR}
                        Protocol to attack
  -rpc-use-smb          Relay DCE/RPC to SMB pipes
  -auth-smb [domain/]username[:password]
                        Use this credential to authenticate to SMB (low-privilege account)
  -hashes-smb LMHASH:NTHASH
  -rpc-smb-port {139,445}
                        Destination port to connect to SMB
  -icpr-ca-name ICPR_CA_NAME
                        Name of the CA for ICPR attack

MSSQL client options:
  -q, --query QUERY     MSSQL query to execute(can specify multiple)

HTTP options:
  -machine-account MACHINE_ACCOUNT
                        Domain machine account to use when interacting with the domain to grab a session key for signing, format is domain/machine_name
  -machine-hashes LMHASH:NTHASH
                        Domain machine hashes, format is LMHASH:NTHASH
  -domain DOMAIN        Domain FQDN or IP to connect using NETLOGON
  -remove-target        Try to remove the target in the challenge message (in case CVE-2019-1019 patch is not installed)

LDAP client options:
  --no-dump             Do not attempt to dump LDAP information
  --no-da               Do not attempt to add a Domain Admin
  --no-acl              Disable ACL attacks
  --no-validate-privs   Do not attempt to enumerate privileges, assume permissions are granted to escalate a user via ACL attacks
  --escalate-user ESCALATE_USER
                        Escalate privileges of this user instead of creating a new one
  --delegate-access     Delegate access on relayed computer account to the specified account
  --sid                 Use a SID to delegate access rather than an account name
  --dump-laps           Attempt to dump any LAPS passwords readable by the user
  --dump-gmsa           Attempt to dump any gMSA passwords readable by the user
  --dump-adcs           Attempt to dump ADCS enrollment services and certificate templates info
  --add-dns-record NAME IPADDR
                        Add the <NAME> record to DNS via LDAP pointing to <IPADDR>

Common options for SMB and LDAP:
  --add-computer [COMPUTERNAME [PASSWORD ...]]
                        Attempt to add a new computer account via SMB or LDAP, depending on the specified target. This argument can be used either with the LDAP or the SMB
                        service, as long as the target is a domain controller.

IMAP client options:
  -k, --keyword KEYWORD
                        IMAP keyword to search for. If not specified, will search for mails containing "password"
  -m, --mailbox MAILBOX
                        Mailbox name to dump. Default: INBOX
  -a, --all             Instead of searching for keywords, dump all emails
  -im, --imap-max IMAP_MAX
                        Max number of emails to dump (0 = unlimited, default: no limit)

AD CS attack options:
  --adcs                Enable AD CS relay attack
  --template TEMPLATE   AD CS template. Defaults to Machine or User whether relayed account name ends with `$`. Relaying a DC should require specifying `DomainController`
  --altname ALTNAME     Subject Alternative Name to use when performing ESC1 or ESC6 attacks.

Shadow Credentials attack options:
  --shadow-credentials  Enable Shadow Credentials relay attack (msDS-KeyCredentialLink manipulation for PKINIT pre-authentication)
  --shadow-target SHADOW_TARGET
                        target account (user or computer$) to populate msDS-KeyCredentialLink from
  --pfx-password PFX_PASSWORD
                        password for the PFX stored self-signed certificate (will be random if not set, not needed when exporting to PEM)
  --export-type {PEM,PFX}
                        choose to export cert+private key in PEM or PFX (i.e. #PKCS12) (default: PFX))
  --cert-outfile-path CERT_OUTFILE_PATH
                        filename to store the generated self-signed PEM or PFX certificate and key

SCCM Policies attack options:
  --sccm-policies       Enable SCCM policies attack. Performs SCCM secret policies dump from a Management Point by registering a device. Works best when relaying a machine
                        account. Expects as target 'http://<MP>/ccm_system_windowsauth/request'
  --sccm-policies-clientname SCCM_POLICIES_CLIENTNAME
                        The name of the client that will be registered in order to dump secret policies. Defaults to the relayed account's name
  --sccm-policies-sleep SCCM_POLICIES_SLEEP
                        The number of seconds to sleep after the client registration before requesting secret policies

SCCM Distribution Point attack options:
  --sccm-dp             Enable SCCM Distribution Point attack. Perform package file dump from an SCCM Distribution Point. Expects as target 'http://<DP>/sms_dp_smspkg$/Datalib'
  --sccm-dp-extensions SCCM_DP_EXTENSIONS
                        A custom list of extensions to look for when downloading files from the SCCM Distribution Point. If not provided, defaults to .ps1,.bat,.xml,.txt,.pfx
  --sccm-dp-files SCCM_DP_FILES
                        The path to a file containing a list of specific URLs to download from the Distribution Point, instead of downloading by extensions. Providing this
                        argument will skip file indexing
```

### impacket-mssqlclient -h

```text
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

usage: mssqlclient.py [-h] [-db DB] [-windows-auth] [-debug] [-ts] [-show] [-command [COMMAND ...]] [-file FILE] [--host-name HOST_NAME] [--app-name APP_NAME]
                      [-hashes LMHASH:NTHASH] [-no-pass] [-k] [-aesKey hex key] [-dc-ip ip address] [-target-ip ip address] [-port PORT]
                      target

TDS client implementation (SSL supported).

positional arguments:
  target                [[domain/]username[:password]@]<targetName or address>

options:
  -h, --help            show this help message and exit
  -db DB                MSSQL database instance (default None)
  -windows-auth         whether or not to use Windows Authentication (default False)
  -debug                Turn DEBUG output ON
  -ts                   Adds timestamp to every logging output
  -show                 show the queries
  -command [COMMAND ...]
                        Commands to execute in the SQL shell. Multiple commands can be passed.
  -file FILE            input file with commands to execute in the SQL shell
  --host-name HOST_NAME
                        HostName property to use when connecting to the MSSQLServer
  --app-name APP_NAME   AppName property to use when connecting to the MSSQLServer

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH
  -no-pass              don't ask for password (useful for -k)
  -k                    Use Kerberos authentication. Grabs credentials from ccache file (KRB5CCNAME) based on target parameters. If valid credentials cannot be found, it will use
                        the ones specified in the command line
  -aesKey hex key       AES key to use for Kerberos Authentication (128 or 256 bits)

connection:
  -dc-ip ip address     IP Address of the domain controller. If ommited it use the domain part (FQDN) specified in the target parameter
  -target-ip ip address
                        IP Address of the target machine. If omitted it will use whatever was specified as target. This is useful when target is the NetBIOS name and you cannot
                        resolve it
  -port PORT            target MSSQL port (default 1433)
```

### impacket-lookupsid -h

```text
Impacket v0.14.0.dev0 - Copyright Fortra, LLC and its affiliated companies 

usage: lookupsid.py [-h] [-debug] [-ts] [-target-ip ip address] [-port [destination port]] [-domain-sids] [-hashes LMHASH:NTHASH] [-no-pass] [-k] target [maxRid]

positional arguments:
  target                [[domain/]username[:password]@]<targetName or address>
  maxRid                max Rid to check (default 4000)

options:
  -h, --help            show this help message and exit
  -debug                Turn DEBUG output ON
  -ts                   Adds timestamp to every logging output

connection:
  -target-ip ip address
                        IP Address of the target machine. If omitted it will use whatever was specified as target. This is useful when target is the NetBIOS name and you cannot
                        resolve it
  -port [destination port]
                        Destination port to connect to SMB Server
  -domain-sids          Enumerate Domain SIDs (will likely forward requests to the DC)

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH
  -no-pass              don't ask for password (useful when proxying through smbrelayx)
  -k                    Use Kerberos authentication. Grabs credentials from ccache file (KRB5CCNAME) based on target parameters. If valid credentials cannot be found, it will use
                        the ones specified in the command line
```

