---
title: "电子取证"
lastmod: 2026-03-26T18:12:29+08:00
draft: false
---
- [手动仿真取证](#%E6%89%8B%E5%8A%A8%E4%BB%BF%E7%9C%9F%E5%8F%96%E8%AF%81)
- [Volatility](#volatility)
  * [一、通用命令（所有系统通用）](#%E4%B8%80%E9%80%9A%E7%94%A8%E5%91%BD%E4%BB%A4%E6%89%80%E6%9C%89%E7%B3%BB%E7%BB%9F%E9%80%9A%E7%94%A8)
  * [二、Windows 系统命令（重点常用）](#%E4%BA%8Cwindows-%E7%B3%BB%E7%BB%9F%E5%91%BD%E4%BB%A4%E9%87%8D%E7%82%B9%E5%B8%B8%E7%94%A8)
    + [1. 系统/进程分析](#1-%E7%B3%BB%E7%BB%9F%E8%BF%9B%E7%A8%8B%E5%88%86%E6%9E%90)
    + [2. 进程详情/模块分析](#2-%E8%BF%9B%E7%A8%8B%E8%AF%A6%E6%83%85%E6%A8%A1%E5%9D%97%E5%88%86%E6%9E%90)
    + [3. 网络分析](#3-%E7%BD%91%E7%BB%9C%E5%88%86%E6%9E%90)
    + [4. 注册表分析](#4-%E6%B3%A8%E5%86%8C%E8%A1%A8%E5%88%86%E6%9E%90)
    + [5. 密码/凭证提取](#5-%E5%AF%86%E7%A0%81%E5%87%AD%E8%AF%81%E6%8F%90%E5%8F%96)
    + [6. 恶意代码检测/分析](#6-%E6%81%B6%E6%84%8F%E4%BB%A3%E7%A0%81%E6%A3%80%E6%B5%8B%E5%88%86%E6%9E%90)
    + [7. 文件/数据提取](#7-%E6%96%87%E4%BB%B6%E6%95%B0%E6%8D%AE%E6%8F%90%E5%8F%96)
    + [8. 系统配置/设备分析](#8-%E7%B3%BB%E7%BB%9F%E9%85%8D%E7%BD%AE%E8%AE%BE%E5%A4%87%E5%88%86%E6%9E%90)
  * [三、Linux 系统命令](#%E4%B8%89linux-%E7%B3%BB%E7%BB%9F%E5%91%BD%E4%BB%A4)
  * [四、macOS 系统命令](#%E5%9B%9Bmacos-%E7%B3%BB%E7%BB%9F%E5%91%BD%E4%BB%A4)
  * [五、Volatility 3.x 核心使用规则（必记）](#%E4%BA%94volatility-3x-%E6%A0%B8%E5%BF%83%E4%BD%BF%E7%94%A8%E8%A7%84%E5%88%99%E5%BF%85%E8%AE%B0)
  * [六、高频命令速查（日常取证优先用）](#%E5%85%AD%E9%AB%98%E9%A2%91%E5%91%BD%E4%BB%A4%E9%80%9F%E6%9F%A5%E6%97%A5%E5%B8%B8%E5%8F%96%E8%AF%81%E4%BC%98%E5%85%88%E7%94%A8)
- [命令](#%E5%91%BD%E4%BB%A4)
- [各文件夹含义](#%E5%90%84%E6%96%87%E4%BB%B6%E5%A4%B9%E5%90%AB%E4%B9%89)

---

# 手动仿真取证

通过![]()

服务器配置

有些服务器没有网卡，这个时候进入虚拟机设置添加一个给他

![1761483964578-af94e752-d806-4d31-805e-56fbb4867a2c.png](./img/CfeWCFfqu9pIllWn/1761483964578-af94e752-d806-4d31-805e-56fbb4867a2c-257756.png)

添加的网卡可以自定义一个网段加进去

之后动态网络设置注意要求分配的IP地址一定是3-254之间

![1761484059867-7262f1a8-4d3f-403d-8653-8e5c86836204.png](./img/CfeWCFfqu9pIllWn/1761484059867-7262f1a8-4d3f-403d-8653-8e5c86836204-255137.png)

之后查看玩端口就可以直接通过ssh连接，其中的网站也可以直接通过网址连接查看相应内容

注意设置的网站的端口是什么，之后直接打开虚拟机命令ip a查看端口，之后通过这个端口和ss出来的连接远程连接。![1761564409158-8c7e7fd7-b2e0-4dcc-852f-612f5db3e407.png](./img/CfeWCFfqu9pIllWn/1761564409158-8c7e7fd7-b2e0-4dcc-852f-612f5db3e407-221218.png)

![1761564417765-d39a8231-3c9a-46f2-96b9-a233945c24ae.png](./img/CfeWCFfqu9pIllWn/1761564417765-d39a8231-3c9a-46f2-96b9-a233945c24ae-907674.png)

打开宝塔面板的命令是`bt`

![1761564558083-6a59d0e4-f263-435a-83ed-41bbf9761acd.png](./img/CfeWCFfqu9pIllWn/1761564558083-6a59d0e4-f263-435a-83ed-41bbf9761acd-914363.png)

看出来端口是13273

![1761564689099-a199894c-2245-404a-8579-686e95772404.png](./img/CfeWCFfqu9pIllWn/1761564689099-a199894c-2245-404a-8579-686e95772404-598410.png)

注意网址要加上https://与端口，界面号

![1761564769153-93452148-080e-4a47-a898-903be6cbc0dc.png](./img/CfeWCFfqu9pIllWn/1761564769153-93452148-080e-4a47-a898-903be6cbc0dc-616582.png)

重新设置密码以后登录宝塔界面

![1761564789902-0648961b-00d8-4b8d-8c5a-ee2478ccf509.png](./img/CfeWCFfqu9pIllWn/1761564789902-0648961b-00d8-4b8d-8c5a-ee2478ccf509-517334.png)

# Volatility

Volatility 3.x 的核心特点是 **按“系统+模块”分类命令**（无需手动指定 Profile，自动识别镜像），所有命令均遵循 `vol.exe -f [镜像路径] 系统.模块.命令 [可选参数]` 格式。以下是 **全量命令汇总**，按「通用命令」「Windows 系统」「Linux 系统」「macOS 系统」分类，附带功能说明和关键参数，方便直接查阅使用：

## 一、通用命令（所有系统通用）

适用于任意镜像，用于框架配置、基础信息查询、数据导出等。

| 命令格式 | 功能说明 | 关键参数 |
| --- | --- | --- |
| `vol.exe -h` | 查看全局帮助信息（所有参数和基础用法） | - |
| `vol.exe --list-plugins` | 列出框架支持的所有插件（命令） | `--list-plugins` |
| `vol.exe -f [镜像路径] --list-plugins` | 列出当前镜像适配的所有插件（过滤不支持的命令） | - |
| `vol.exe -f [镜像路径] frameworkinfo.FrameworkInfo` | 查看 Volatility 框架版本、依赖、配置信息 | - |
| `vol.exe -f [镜像路径] banners.Banners` | 提取镜像中的各类标识（如系统 Banner、软件版本标识） | - |
| `vol.exe -f [镜像路径] timeliner.Timeliner` | 生成时间线日志（汇总所有事件的时间戳，便于时序分析） | `-o [输出文件]`（保存为 CSV/JSON） |
| `vol.exe -f [镜像路径] layerwriter.LayerWriter` | 导出内存层数据（原始内存镜像切片） | `--layer [层名称] --output [输出文件]` |
| `vol.exe -f [镜像路径] configwriter.ConfigWriter` | 生成当前框架的配置文件（可用于自定义参数） | `--save-config [保存路径]` |
| `vol.exe -f [镜像路径] isfinfo.IsfInfo` | 查看 ISF 格式镜像的元信息（仅适用于 ISF 格式镜像） | - |
| `vol.exe -f [镜像路径] yarascan.YaraScan` | 用 Yara 规则扫描内存中的恶意代码/特征字符串 | `--yara-rules [规则文件] --dump-dir [导出目录]` |

## 二、Windows 系统命令（重点常用）

针对 Windows 内存镜像（如 raw、vmem、vmdk），覆盖取证核心场景（进程、网络、注册表、密码、恶意代码检测等）。

| 命令格式 | 功能说明 | 关键参数 |
| --- | --- | --- |

### 1. 系统/进程分析

| `windows.info.Info`                       | 查看系统基础信息（版本、架构、内核基址、系统时间，替代 2.x 的 imageinfo） | -                                         |\
| `windows.pslist.PsList`                   | 列出活跃进程（基于内核 PsActiveProcessHead，类似 2.x 的 pslist）           | `-v`（详细信息）、`--pid [PID]`（指定进程）|\
| `windows.pstree.PsTree`                   | 树形显示进程父子关系（便于追溯进程来源）                                 | `-v`（显示进程路径、启动时间）             |\
| `windows.psscan.PsScan`                   | 扫描所有进程（包括已终止/隐藏进程，对抗进程隐藏）                         | `-v`（显示进程退出时间）                   |\
| `windows.sessions.Sessions`               | 列出 Windows 登录会话（包括交互式/非交互式会话，识别登录用户）             | -                                         |

### 2. 进程详情/模块分析

| `windows.cmdline.CmdLine`                 | 提取进程命令行参数（判断进程启动方式，如恶意软件带参启动）               | `--pid [PID]`（指定进程）、`-v`            |\
| `windows.envars.Envars`                   | 提取进程环境变量（如 PATH、TEMP 路径，辅助分析进程运行环境）              | `--pid [PID]`                              |\
| `windows.dlllist.DllList`                 | 列出进程加载的 DLL 模块（检测异常加载的恶意 DLL）                         | `--pid [PID]`、`-v`（显示 DLL 路径/基址）  |\
| `windows.ldrmodules.LdrModules`           | 检测隐藏模块（对比 3 个模块列表，识别未链接的恶意模块）                   | `-v`（显示模块不一致信息）                 |\
| `windows.modules.Modules`                 | 列出系统内核模块（驱动/内核组件，检测恶意内核模块）                       | `-v`（显示模块路径/加载时间）              |\
| `windows.modscan.ModScan`                 | 扫描内核模块（包括未注册的隐藏模块）                                     | `-v`                                       |

### 3. 网络分析

| `windows.netstat.NetStat`                 | 查看网络连接（本地IP:端口、远程IP:端口、连接状态、对应PID，替代 2.x 的 netstat） | `-v`（显示协议/连接创建时间） |\
| `windows.netscan.NetScan`                 | 扫描网络套接字（包括已关闭的连接，补充 NetStat 遗漏的信息）               | `-v`                                       |

### 4. 注册表分析

| `windows.registry.hivelist.HiveList`      | 列出注册表 hive 文件（如 SYSTEM、SOFTWARE，替代 2.x 的 hivelist）           | `-v`（显示 hive 路径/大小）                |\
| `windows.registry.hivescan.HiveScan`      | 扫描注册表 hive（包括未挂载的隐藏 hive）                                 | `-v`                                       |\
| `windows.registry.printkey.PrintKey`      | 读取指定注册表键值（如开机自启项、软件配置）                             | `--key [键路径]`（如 "Microsoft\Windows\CurrentVersion\Run"） |\
| `windows.registry.userassist.UserAssist`  | 提取 UserAssist 注册表项（记录用户打开的程序/文件，用于行为分析）         | `-v`（显示最后访问时间/次数）              |\
| `windows.registry.certificates.Certificates` | 提取系统证书（检测恶意证书/伪造证书）                                   | `--dump-dir [导出目录]`（保存证书文件）    |

### 5. 密码/凭证提取

| `windows.hashdump.Hashdump`               | 提取 Windows 账户 NTLM 哈希（替代 2.x 的 hashdump）                        | `-o [输出文件]`（保存哈希）                |\
| `windows.lsadump.Lsadump`                 | 提取 LSA 数据库中的凭证（包括域凭证、缓存密码）                           | `--dump-dir [导出目录]`（保存 LSA 数据）   |\
| `windows.cachedump.Cachedump`             | 提取域控制器缓存的用户哈希（仅适用于域控镜像）                           | `--dump-dir [导出目录]`                    |\
| `windows.getsids.GetSIDs`                 | 提取进程的安全标识符（SID），关联用户权限                                 | `--pid [PID]`                              |

### 6. 恶意代码检测/分析

| `windows.malfind.Malfind`                 | 检测内存中的恶意代码（基于 PAGE\_EXECUTE\_READWRITE 权限+异常特征）          | `--pid [PID]`、`--dump-dir [导出目录]`（保存恶意代码） |\
| `windows.vadyarascan.VadYaraScan`         | 基于 VAD（虚拟地址描述符）扫描恶意代码（精准定位进程内存中的可疑区域）    | `--yara-rules [规则文件]`、`--pid [PID]`    |\
| `windows.skeleton_key_check.Skeleton_Key_Check` | 检测“骨架钥匙”恶意软件（篡改 LSA 认证的后门）                           | -                                         |\
| `windows.ssdt.SSDT`                       | 查看系统服务描述符表（检测被 Hook 的系统调用，恶意软件常用手段）          | `-v`（显示原始/修改后的函数地址）          |

### 7. 文件/数据提取

| `windows.dumpfiles.DumpFiles`             | 提取进程内存/文件（替代 2.x 的 procdump，支持导出进程镜像、内存中的文件） | `--pid [PID]`、`--dump-dir [导出目录]`     |\
| `windows.filescan.FileScan`               | 扫描内存中的文件对象（包括已删除/未关闭的文件，恢复关键文件）             | `-v`（显示文件路径/大小/创建时间）         |\
| `windows.mftscan.MFTScan`                 | 扫描 MFT（主文件表）记录（恢复文件元信息、删除文件痕迹）                  | `-v`                                       |\
| `windows.mbrscan.MBRScan`                 | 扫描主引导记录（MBR），检测引导区病毒/恶意篡改                           | `--dump-dir [导出目录]`（保存 MBR 镜像）   |

### 8. 系统配置/设备分析

| `windows.bigpools.BigPools`               | 查看大内存池（检测内存泄漏、恶意软件占用的大内存区域）                   | `-v`                                       |\
| `windows.devicetree.DeviceTree`           | 列出设备树（查看系统硬件设备、驱动关联，检测恶意驱动）                   | `-v`（显示设备驱动名称）                   |\
| `windows.driverscan.DriverScan`           | 扫描内核驱动（包括未注册的恶意驱动）                                     | `-v`（显示驱动路径/基址）                  |\
| `windows.drivermodule.DriverModule`       | 列出已加载的驱动模块（关联驱动与进程，定位恶意驱动）                     | `-v`                                       |\
| `windows.svcscan.SvcScan`                 | 扫描 Windows 服务（检测恶意服务、篡改的系统服务）                         | `-v`（显示服务状态/启动类型/路径）         |

## 三、Linux 系统命令

针对 Linux 内存镜像，核心功能覆盖进程、网络、模块、文件等分析。

| 命令格式 | 功能说明 | 关键参数 |
| --- | --- | --- |
| `linux.pslist.PsList` | 列出活跃进程 | `-v`、`--pid [PID]` |
| `linux.pstree.PsTree` | 树形显示进程父子关系 | `-v` |
| `linux.psscan.PsScan` | 扫描所有进程（包括已终止） | `-v` |
| `linux.bash.Bash` | 提取 bash 历史命令（恢复用户操作记录） | `-v`（显示命令执行时间） |
| `linux.envars.Envars` | 提取进程环境变量 | `--pid [PID]` |
| `linux.lsmod.Lsmod` | 列出已加载的内核模块 | `-v` |
| `linux.check_modules.Check_modules` | 检测隐藏内核模块 | `-v` |
| `linux.netstat.Netstat`（3.2+版本） | 查看网络连接 | `-v` |
| `linux.sockstat.Sockstat` | 查看套接字状态 | `-v` |
| `linux.malfind.Malfind` | 检测恶意代码 | `--pid [PID]`、`--dump-dir [导出目录]` |
| `linux.elfs.Elfs` | 提取内存中的 ELF 文件（可执行程序/库） | `--pid [PID]`、`--dump-dir [导出目录]` |
| `linux.mountinfo.MountInfo` | 查看挂载点信息 | `-v` |
| `linux.iomem.IOMem` | 查看内存映射（硬件/内核内存分布） | `-v` |
| `linux.check_syscall.Check_syscall` | 检测系统调用表篡改 | `-v` |

## 四、macOS 系统命令

针对 macOS 内存镜像，功能覆盖进程、网络、内核模块、系统配置等。

| 命令格式 | 功能说明 | 关键参数 |
| --- | --- | --- |
| `mac.pslist.PsList` | 列出活跃进程 | `-v`、`--pid [PID]` |
| `mac.pstree.PsTree` | 树形显示进程父子关系 | `-v` |
| `mac.psscan.PsScan` | 扫描所有进程（包括已终止） | `-v` |
| `mac.bash.Bash` | 提取 bash 历史命令 | `-v` |
| `mac.lsmod.Lsmod` | 列出内核模块 | `-v` |
| `mac.netstat.Netstat` | 查看网络连接 | `-v` |
| `mac.malfind.Malfind` | 检测恶意代码 | `--pid [PID]`、`--dump-dir [导出目录]` |
| `mac.mount.Mount` | 查看挂载点信息 | `-v` |
| `mac.ifconfig.Ifconfig` | 查看网络接口配置（IP、MAC 地址） | `-v` |
| `mac.list_files.List_Files` | 扫描文件对象 | `-v`（显示文件路径/创建时间） |
| `mac.check_syscall.Check_syscall` | 检测系统调用表篡改 | `-v` |

## 五、Volatility 3.x 核心使用规则（必记）

1. **命令格式固定**：所有命令均为 `vol.exe -f [镜像路径] 系统.模块.命令 [参数]`，缺一不可（如 Windows 进程列表必须写 `windows.pslist.PsList`，不能简写 `pslist`）。
2. **无需指定 Profile**：框架自动识别镜像的系统（Windows/Linux/macOS）和架构（32/64位），无需加 `--profile` 参数。
3. **路径空格处理**：镜像路径/输出目录含空格时，必须用双引号包裹（如 `-f "Y:\xxx xxx.mem"`）。
4. **导出目录提前创建**：使用 `--dump-dir` 导出文件时，需手动创建目录（如 `./dump/`），否则报错。
5. **查询适配命令**：不确定当前镜像支持哪些命令时，运行 `vol.exe -f [镜像路径] --list-plugins` 过滤显示。

## 六、高频命令速查（日常取证优先用）

| 场景需求 | 推荐命令（Windows 示例） |
| --- | --- |
| 确认系统信息 | `vol.exe -f [镜像] windows.info.Info` |
| 列出进程（树形） | `vol.exe -f [镜像] windows.pstree.PsTree -v` |
| 提取进程内存 | `vol.exe -f [镜像] windows.dumpfiles.DumpFiles --pid 1234 --dump-dir ./dump/` |
| 查看网络连接 | `vol.exe -f [镜像] windows.netstat.NetStat` |
| 提取密码哈希 | `vol.exe -f [镜像] windows.hashdump.Hashdump -o hash.txt` |
| 检测恶意代码 | `vol.exe -f [镜像] windows.malfind.Malfind --dump-dir ./malware/` |
| 查看开机自启项 | `vol.exe -f [镜像] windows.registry.printkey.PrintKey --key "Microsoft\Windows\CurrentVersion\Run"` |

按以上分类和规则使用，即可覆盖 99% 的内存取证场景。如果需要针对某个系统（如 Linux）或具体功能（如提取 macOS 凭证）的深度用法，可以进一步说明～

# 命令

`ip addr`查看当前IP地址

`bt start`启动宝塔面板

`bt status`查看宝塔面板状态

`bt 14`查看登录状态

`bt 5`更改密码

`docker load -i ***`加载镜像文件

`ss -lntp`查看网络连接状态

`mysql -h 127.0.0.1 -P 3060 -uroot -p`主机直接连接mysql

`docker tag 34178bdaefd0 mysql:8.0`docker命名一个image ID为34178bdaefd0的镜像使得repository为mysql，tag为8.0

`docker run -d --name mysql8 -e MYSQL_ROOT_PASSWORD=123456 -p 3306:3306 mysql:8.0`跑用mysql:8.0镜像创建一个名叫mysql8的容器，-p是把我的电脑的3306端口和mysql内部的3306端口连接起来

`docker ps`查看运行中的容器

`docker exec -it {你的容器名称} mysql -uroot -p{你的密码} -e "{你的指令}"`打开你的容器，执行这行命令但是不进入容器

`docker exec -it 容器名 mysql -uroot -p密码`直接进入容器

`create database text default charset utf8mb4;`mysql创建一个utf-8的库

# 各文件夹含义

