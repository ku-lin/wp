---
title: "exe取证总结"
lastmod: 2026-04-24T14:21:39+08:00
draft: false
---
# EXE 取证总结

来源：<https://forensics.xidian.edu.cn/wiki/writeups/Pinghang2026/>

说明：这里把“exe取证”按“Windows 可执行样本/恶意脚本/宏病毒/.NET 木马/内存联动取证”来整理，主要覆盖 `宏病毒分析`、`WinPE 逆向 (.NET)`、`倩倩的 PC`、`倩倩的 PC 内存`，并吸收少量样本恢复相关内容。

## 1. 这套题里涉及到的 EXE/恶意样本取证知识点

### 1.1 从磁盘镜像中恢复恶意样本

- 恶意样本不一定明文存在，可能位于加密容器里，甚至已经被删除。
- 本题先通过 VeraCrypt 外层/内层密码挂载容器，再对容器内数据恢复，最后按 MD5 校验确认目标文件。
- 这说明样本取证的前置步骤往往是：
  - 找到容器
  - 解密容器
  - 恢复被删文件
  - 校验哈希

### 1.2 Office 宏病毒分析

- 先用 Hex 判断是否为 OLE Office 文档。
- 用 `oledump` 看文档里有哪些流（streams）含宏。
- 用 `OfficeMalScanner` 或同类工具 dump VBA 代码。
- 重点函数通常是 `AutoOpen` 之类自动执行宏。
- 这题里的 VBA 先从文档本体读取字节，再按固定算法做 XOR 解密。
- 宏里不是直接放最终 payload，而是：
  - 先找 marker
  - 再从 marker 后固定偏移处截取密文块
  - 最后解密并释放下一阶段脚本

### 1.3 VBA 到 JScript 的多阶段释放

- 解密后的释放物是 `maintools.js`。
- 落地目录优先是 `%APPDATA%\\Microsoft\\Windows`，不存在则退到 `%APPDATA%`。
- 宏通过 Windows 脚本宿主执行 JScript，命令行场景对应 `cscript.exe`。
- 命令行参数会作为下一阶段解密密钥传入。

### 1.4 JScript 第二阶段分析

- 第二阶段脚本使用了 `Base64 + RC4`。
- 如果一眼看不出混淆逻辑，可以直接把 `eval(...)` 改成写文件，把解密后的下一阶段代码落地出来。
- 这类“改一行让恶意代码自吐明文”的方法很适合处理脚本木马。
- 通过解密后的 JScript 可以继续提取：
  - 硬编码 C2 域名
  - `work` 指令下载执行逻辑
  - 失败后的自毁/清理函数

### 1.5 钓鱼链路取证

- 恶意样本往往能从邮件客户端直接找到投递源头。
- 本题在网易邮箱大师里可以看到伪造的 VPN 部署通知邮件。
- 邮件正文里直接给了压缩包密码，说明“正文内容”本身就是关键证据。
- 附件解压后即可进入样本静态分析流程。

### 1.6 .NET 木马逆向

- 用 `Detect It Easy (DIE)` 可快速识别是 .NET 程序并得到运行时版本。
- 用 `dnSpyEx` 跟入口点、重命名类和方法，是读懂混淆 .NET 木马的高效方式。
- 本题的字符串解密逻辑是：
  - 取硬编码字符串
  - 做 MD5
  - 按特定方式拼成 32 字节 key
  - 用 `AES-ECB` 解密配置/字符串
- 拿到解密函数后，建议批量解密全部字符串，再统一重命名，分析会快很多。

### 1.7 反沙箱与反调试识别

- 通过 `ManagementObjectSearcher` 取机器型号，识别 `VIRTUAL`/`qemu`/`VirtualBox`。
- 调用 `CheckRemoteDebuggerPresent` 检测远程调试器。
- 通过 `SbieDll.dll` 判断 Sandboxie。
- 判断是否为 XP。
- 调 `ip-api.com` 判断当前 IP 是否为 hosting。
- 这类逻辑不一定都属于“严格意义上的反调试”，但都属于恶意样本的环境感知能力。

### 1.8 持久化、权限维持与防御绕过

- 判断管理员权限后，样本会做提权执行准备。
- 将自身复制到 `%AppData%\\WmiPrvSE.exe`。
- 创建高权限计划任务 `WmiPrvSE`。
- 通过 PowerShell 设置临时执行策略绕过，并把恶意程序加入 Defender 白名单。
- 同时写注册表自启动和 Startup 目录，实现多重持久化。

### 1.9 功能行为取证

- 键盘记录：
  - `SetWindowsHookEx`
- 关键进程保护：
  - `RtlSetProcessIsCritical`
- 回连：
  - 多个 C2 IP
  - 固定端口 `7000`
- 横向传播/介质传播：
  - 复制到可移动设备，副本名为 `USB.exe`
- 伪装与界面：
  - 伪装安装包
  - 显示勒索窗口

### 1.10 受害主机联动取证

- 服务器投毒产生的命令，在受害主机本地配置里也可能留痕。
- 本题可在 `.claude/settings.local.json` 中看到执行许可的恶意命令。
- 内存镜像能进一步验证：
  - 当前恶意进程 PID
  - 创建时间
  - 正在连接的 C2 真实 IP
- 这说明恶意样本取证不能只做静态逆向，最好结合主机镜像和内存镜像一起做。

### 1.11 微信数据库密钥内存取证

- 本题额外展示了一个非常实用的思路：在内存里找持有微信数据库密钥的 `Weixin.exe` 进程。
- 通过 Volatility3 自定义插件可以直接提取微信数据库解密钥。
- 这类能力适合做“正在运行应用的密钥提取”，也是内存取证的典型应用场景。

## 2. 这类题怎么取证

### 2.1 样本落地前，先找投递链

1. 查邮件客户端、浏览器下载记录、聊天软件传输记录。
2. 找到附件、压缩包、解压密码、伪装主题。
3. 先对原始样本做哈希，再进入静态分析。

### 2.2 如果是 Office 文档样本

1. 用 Hex 或文件头判断是否 OLE。
2. 用 `oledump` 看 streams。
3. 用 `OfficeMalScanner` 导出 VBA。
4. 找自动执行入口：
   - `AutoOpen`
   - `Document_Open`
5. 识别解密算法、marker、payload 偏移和长度。
6. 自己写脚本还原释放过程。
7. 拿到下一阶段脚本后继续逆向。

### 2.3 如果下一阶段是 JScript/脚本木马

1. 先确认执行方式和参数来源。
2. 看是否存在：
   - Base64
   - RC4
   - XOR
   - `eval`
3. 优先考虑把 `eval` 改为“写文件输出”。
4. 对明文脚本提取：
   - C2
   - 下载执行逻辑
   - 自毁函数
   - 落地路径
   - 最终执行扩展名

### 2.4 如果是 .NET 木马

1. 先用 `DIE` 看运行时版本。
2. 用 `dnSpyEx` 看入口点。
3. 找字符串解密函数和配置解密函数。
4. 写还原脚本，把所有字符串先解出来。
5. 给类、方法、字段做语义化重命名。
6. 重点分析：
   - 反沙箱
   - 反调试
   - 持久化
   - 提权
   - 防御绕过
   - C2 通信
   - 键盘记录/勒索/传播

### 2.5 受害主机与内存联动

1. 在磁盘镜像中搜：
   - 邮件
   - 命令历史
   - 客户端配置
   - 持久化痕迹
2. 在内存镜像中用 Volatility3 查：
   - `windows.pslist`
   - `windows.netscan`
   - 自定义插件（如 `windows.wechatkeys.WeChatKeys`）
3. 用主机侧实际运行结果，反证静态逆向得到的 C2、端口、进程名、启动方式。

## 3. 本题可直接复用的工具与证据点

### 3.1 工具

- Hex 编辑器
- `oledump`
- `OfficeMalScanner`
- Python
- CyberChef
- `cscript.exe`
- Detect It Easy (DIE)
- dnSpyEx
- Volatility3
- 火眼证据分析

### 3.2 关键能力点

- 恢复 VeraCrypt 内层卷中的被删样本
- 提取 VBA 宏
- 手工复现 XOR 解密
- 修改 `eval` 输出下一阶段代码
- 还原 AES-ECB 配置解密
- 提取 C2 / 端口 / 持久化名称
- 从内存取回微信数据库密钥
- 用 `pslist` / `netscan` 锁定在跑的木马和其网络连接

## 4. 题里出现的典型命令/方法

- 恶意脚本命令行执行：
  - `cscript.exe`
- 计划任务持久化：
  - `schtasks.exe /create /f /RL HIGHEST /sc minute /mo 1 /tn "WmiPrvSE" /tr "%AppData%/WmiPrvSE.exe"`
- Volatility3 提取微信密钥：
  - `python vol.py -f <mem> windows.wechatkeys.WeChatKeys`
- 指定 PID + DB 目录验证微信密钥：
  - `python vol.py -f <mem> windows.wechatkeys.WeChatKeys --pid <pid> --db-dir <dir>`
- 内存里查木马进程：
  - `python vol.py -f <mem> --filters "ImageFileName,Haimuniu" windows.pslist`
- 内存里查指定 PID 网络连接：
  - `python vol.py -f <mem> --filters "pid,7348" windows.netscan`

## 5. 详细命令

说明：以下命令按“样本发现 -> 文档宏 -> 第二阶段脚本 -> .NET 木马 -> 主机联动 -> 内存联动”的顺序整理。

### 5.1 哈希与基础识别

Windows PowerShell：

```powershell
Get-FileHash .\sample.zip -Algorithm MD5
Get-FileHash .\sample.exe -Algorithm MD5
Get-FileHash .\sample.exe -Algorithm SHA1
Get-FileHash .\sample.exe -Algorithm SHA256
```

Linux：

```bash
md5sum sample.zip
sha1sum sample.exe
sha256sum sample.exe
file sample.doc
file sample.exe
strings -n 6 sample.exe | head
```

### 5.2 VeraCrypt 容器挂载与恢复

命令行挂载示例：

```powershell
veracrypt.exe /v "D:\container.hc" /l X /p "qq520250520250520250" /q /s
```

如果有内层卷：

```powershell
veracrypt.exe /v "D:\container.hc" /l X /p "woaizaoqiwoshenqingzhuanyi" /q /s
```

挂载后恢复被删文件可用你手头的数据恢复工具；恢复完成后立即校验哈希：

```powershell
Get-FileHash X:\recovered.bin -Algorithm MD5
```

### 5.3 Office 文档是否含宏

先看文件头和 OLE 特征：

```bash
xxd -l 64 sample.doc
file sample.doc
strings -n 6 sample.doc | head -50
```

### 5.4 oledump 查看 streams

```bash
python oledump.py sample.doc
python oledump.py sample.doc -s 8
python oledump.py sample.doc -v
```

如果你已经知道含宏的 stream 编号：

```bash
python oledump.py sample.doc -s 8 -v
```

### 5.5 OfficeMalScanner 导出 VBA

```powershell
.\OfficeMalScanner.exe sample.doc dump
```

如果要把结果单独落目录：

```powershell
.\OfficeMalScanner.exe sample.doc dump output
```

### 5.6 从 VBA 还原释放的 payload

把题解里的 XOR 还原脚本保存成 `decode_stage1.py`：

```python
def decode(data):
    key = 45
    out = bytearray(data)
    for i in range(len(out)):
        out[i] ^= key
        key = ((key ^ 99) ^ (i % 254)) & 0xff
    return bytes(out)

marker = b"MxOH8pcrlepD3SRfF5ffVTy86Xe41L2qLnqTd5d5R7Iq87mWGES55fswgG84hIRdX74dlb1SiFOkR1Hh"

with open("49b367ac261a722a7c2bbbc328c32545", "rb") as f:
    blob = f.read()

idx = blob.find(marker)
if idx == -1:
    print("marker not found")
else:
    start = idx + 80
    enc = blob[start:start + 16828]
    dec = decode(enc)
    with open("maintools.js", "wb") as f:
        f.write(dec)
    print("done")
```

运行：

```bash
python decode_stage1.py
```

### 5.7 第二阶段 JScript 落明文

如果脚本里有 `eval(ES3c);`，改成输出文件：

```javascript
var fso = new ActiveXObject("Scripting.FileSystemObject");
var file = fso.CreateTextFile("output.txt", true);
file.WriteLine(ES3c);
file.Close();
```

命令行执行：

```powershell
cscript.exe .\maintools.js EzZETcSXyKAdF_e5I2i1
```

### 5.8 快速搜 JScript 里的 C2 / 下载逻辑

```powershell
Select-String -Path .\output.txt -Pattern "http","https","work","pif","delete","quit","TaskManager"
```

Linux：

```bash
grep -nE "http|https|work|pif|delete|quit|TaskManager" output.txt
```

### 5.9 .NET 样本识别

Detect It Easy 通常走图形界面；命令行环境下可以先用 strings 做预判：

```bash
strings -n 8 sample.exe | grep -i -E "mscoree|\.net|RtlSetProcessIsCritical|SetWindowsHookEx|CheckRemoteDebuggerPresent|SbieDll"
```

### 5.10 dnSpyEx 逆向重点

这部分主要走图形界面，但建议你按下面顺序看：

1. 入口点
2. 字符串解密函数
3. 配置解密函数
4. 持久化函数
5. 网络通信函数
6. 键盘记录函数

如果你想先用文本搜索缩小范围：

```bash
strings -n 8 sample.exe | grep -i -E "schtasks|WmiPrvSE|ShowSuperHidden|SbieDll|CheckRemoteDebuggerPresent|SetWindowsHookEx|RtlSetProcessIsCritical|7000"
```

### 5.11 还原 .NET AES-ECB 字符串解密

保存为 `decrypt_config.py`：

```python
import base64
import hashlib
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

def decrypt(secret: str, ciphertext_b64: str) -> str:
    md5 = hashlib.md5(secret.encode("utf-8")).digest()
    key = bytearray(32)
    key[0:16] = md5
    key[15:31] = md5
    cipher = AES.new(bytes(key), AES.MODE_ECB)
    ciphertext = base64.b64decode(ciphertext_b64)
    plaintext = unpad(cipher.decrypt(ciphertext), 16)
    return plaintext.decode("utf-8")

print(decrypt("8xTJ0EKPuiQsJVaT", "在这里替换密文"))
```

运行：

```bash
python decrypt_config.py
```

安装依赖：

```bash
pip install pycryptodome
```

### 5.12 主机侧排查投毒命令

```powershell
Get-Content "C:\Users\admin\.claude\settings.local.json"
Select-String -Path "C:\Users\admin\.claude\settings.local.json" -Pattern "ncat","powershell","156.238.239.253","1314"
```

### 5.13 主机侧排查持久化

```powershell
schtasks /query /fo LIST /v | Select-String "WmiPrvSE"
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
dir "$env:APPDATA\Microsoft\Windows"
dir "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
```

### 5.14 Volatility3 查微信密钥

```powershell
python vol.py -f "D:\倩倩的PC内存\DESKTOP-3943OKD-20260403-014746.dmp" windows.wechatkeys.WeChatKeys
```

指定 PID 和数据库目录验证：

```powershell
python vol.py -f "D:\倩倩的PC内存\DESKTOP-3943OKD-20260403-014746.dmp" windows.wechatkeys.WeChatKeys --pid 10892 --db-dir "C:\hlnet\7-1776228097\倩倩的PC镜像.E01\分区3\Users\admin\Documents\xwechat_files\wxid_zuaa9igqlro22_eef8\db_storage\"
```

### 5.15 Volatility3 查木马进程

```powershell
python vol.py -f "D:\倩倩的PC内存\DESKTOP-3943OKD-20260403-014746.dmp" --filters "ImageFileName,Haimuniu" windows.pslist
```

也可以正则搜：

```powershell
python vol.py -f "D:\mem.dmp" --filters "Process,^Haimuniu.*\.exe$!" windows.pslist
```

### 5.16 Volatility3 查网络连接

```powershell
python vol.py -f "D:\倩倩的PC内存\DESKTOP-3943OKD-20260403-014746.dmp" --filters "pid,7348" windows.netscan
```

### 5.17 Volatility3 常用辅助命令

```powershell
python vol.py -f "D:\mem.dmp" windows.pslist
python vol.py -f "D:\mem.dmp" windows.pstree
python vol.py -f "D:\mem.dmp" windows.cmdline
python vol.py -f "D:\mem.dmp" windows.handles
python vol.py -f "D:\mem.dmp" windows.dlllist --pid 7348
```

### 5.18 快速搜反沙箱/反调试 API

如果你已经把字符串解出来了，可以直接搜：

```bash
grep -nE "CheckRemoteDebuggerPresent|SbieDll|VirtualBox|qemu|RtlSetProcessIsCritical|SetWindowsHookEx|ip-api.com|hosting" output.txt
```

或者对样本本体：

```bash
strings -n 8 sample.exe | grep -i -E "CheckRemoteDebuggerPresent|SbieDll|VirtualBox|qemu|RtlSetProcessIsCritical|SetWindowsHookEx|ip-api.com|hosting"
```

## 6. 这套题暴露出的取证思路

- 先找投递链，再做样本逆向，最后回到主机/内存验证，链路会更完整。
- 宏文档最重要的是找到“自动执行入口 + payload 提取逻辑”。
- 对脚本型样本，不一定要完全手工逆混淆，很多时候把 `eval` 改掉就能拿到明文。
- .NET 木马最省时间的方法通常是“先批量解密字符串，再重命名”。
- 静态结果必须回到受害主机和内存做交叉印证，否则容易只看到“理论功能”，看不到“实际执行”。

## 7. 易错点

- 题面里的样本 MD5 有明显字符混淆，恢复样本时应以实际计算结果为准。
- 宏样本分析不能只看 VBA 文本，要结合“文档本体里嵌 payload”的情况。
- `wscript.exe` 和 `cscript.exe` 容易混淆，命令行模式下应优先想到 `cscript.exe`。
- 反沙箱/反调试逻辑的统计口径可能存在争议，分析时要把每一项检测逻辑单独列出来。

