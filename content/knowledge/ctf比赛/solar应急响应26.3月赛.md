---
title: "solar应急响应26.3月赛"
lastmod: 2026-03-28T17:53:15+08:00
draft: false
---
# WP

## 题目信息

- 题目：Tunnel Traffic
- 附件：`file.pcapng`、`memdump.lime`
- 目标：从流量与内存中还原被隧道隐藏的 flag

---


在流量中可以看到一条非常显眼的 UDP 会话：

- `203.0.113.50:36186 -> 198.51.100.10:443`
- 对端也有对应返回包

继续看 UDP 负载首字节，会发现：

- `0x01`：WireGuard Handshake Initiation
- `0x02`：WireGuard Handshake Response
- `0x04`：WireGuard Transport Data

也就是说，这不是普通的 QUIC/DTLS，而是WireGuard 伪装在 UDP/443 上的流量。

对 `memdump.lime` 做字符串提取，可以直接看到非常关键的信息：

- `wireguard: WireGuard 1.0.0 loaded`
- `wg0 created`
- `wg1 created`
- `/usr/bin/wg-quick`
- `/etc/wireguard/wg0.conf`
- `/etc/wireguard/wg1.conf`
- `Endpoint = 198.51.100.10:443`

仅有配置路径和 endpoint 还不够。真正能解 transport data 的，是 握手后生成的会话密钥，通常要从内核中的 WireGuard peer/keypair 结构里提取。

已知特征包括：

- peer 的 `remote_index`
- transport 包中明文可见的 receiver index
- WireGuard keypair 邻接布局

可以结合已抓到的 transport 包，去内存里匹配对应 keypair 结构，拿到发送/接收方向的会话密钥。

本题最终就是通过内存中的 WireGuard keypair，把外部这条会话成功解开。

外部会话：

- `203.0.113.50:36186 <-> 198.51.100.10:443`

这条流里：

- 前两个包完成握手；
- 后面大量 `type=4` 包是 transport data；
- 其中包含真正的内层 IP 数据。

把 transport data 按照：

- receiver index
n- counter
- 对应方向的 session key
- ChaCha20-Poly1305

逐包解密后，可以还原出内层数据流。重组后发现，里面是一段 HTTP 上传请求：

```http
POST /upload HTTP/1.1
```

上传的文件名是：

```text
backup.tar.gz
```

把解密出来的 HTTP body 提取后，对上传文件进行还原，得到压缩包：

```text
backup.tar.gz
```

解压后可以看到类似结构：

```text
backup/
├── .config/
│   └── credentials.json
└── README.md
```

在：

```text
backup/.config/credentials.json
```

里可以找到 token：

```text
flag{ba00e1df-c9f3-4ac7-8cf5-a61b5936ce18}
```

这就是本题 flag。

## 提取 bash dump 中的命令痕迹


```bash
strings dumped_4053_[23d1000-253e000].bin | grep -i ransomware
```
可以得到几组可疑命令：
```
./my_ransomware_23333 cae77ea5367e8d40bfa607179104 1155513bd65ceeeba70af9f06372
./my_ransomware_666666666 c2e77ea5367e8d40bfa607179104 1155513bd65ceeeba70af9f06372
./my_r@nsomw4re_lollollollol 0ae7dea53e7e8d40bfa907179104 1155513bd65ceeeba70af9f06a72
./my_r@nsomw4re_hahahahaha cae7dea53e7e8d40bfa607179104 1155513bd65ceeeba70af9f06a72
```
这两列十六进制数据明显像是加密参数，后续结合样本验证。

2. 分析勒索样本

逆向样本后发现，该勒索程序不是常规 AES，而是自定义的：

ECC 椭圆曲线
KDF2(SHA1)
XOR 加密
HMAC-SHA1 校验

文件格式为：

"LOCKED" | 原文长度(8字节小端) | R(29字节) | 密文 | HMAC-SHA1(20字节)

其中 R 是临时公钥，格式为：

0x04 | Rx(14字节) | Ry(14字节)
3. 验证 dump 中恢复出的参数

将 bash dump 中提取出的几组参数代入样本中的曲线方程检查，发现只有最后一组是合法点：
```
Qx = 0xcae7dea53e7e8d40bfa607179104
Qy = 0x1155513bd65ceeeba70af9f06a72
```
继续利用题目中的弱曲线求离散对数，恢复私钥：
```
d = 0x5b96532c6bfecfd273cbf3977834
```
解密流程

从 flag.solarsec.locked 中取出临时公钥 R，计算共享秘密：

`S = d * R`

然后取 S.x 作为 KDF2 输入，生成密钥流：

前半部分用于 XOR 解密
后 16 字节用于 HMAC 校验

解密并校验通过后即可得到明文。

解密脚本

```python
from pathlib import Path
from hashlib import sha1
import hmac, struct

p = int('e2e20e64347abef0fef83d1a5901', 16)
a = int('592a5290d72d5d58c73266dc96b2', 16)
d = int('5b96532c6bfecfd273cbf3977834', 16)

def add(P, Q):
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and (y1 + y2) % p == 0:
        return None
    if P != Q:
        lam = ((y2 - y1) * pow((x2 - x1) % p, -1, p)) % p
    else:
        lam = ((3 * x1 * x1 + a) * pow((2 * y1) % p, -1, p)) % p
    x3 = (lam * lam - x1 - x2) % p
    y3 = (lam * (x1 - x3) - y1) % p
    return x3, y3

def mul(k, P):
    R = None
    Q = P
    while k:
        if k & 1:
            R = add(R, Q)
        Q = add(Q, Q)
        k >>= 1
    return R

def kdf2_sha1(z: bytes, outlen: int):
    out = b''
    counter = 1
    while len(out) < outlen:
        out += sha1(z + struct.pack(">I", counter)).digest()
        counter += 1
    return out[:outlen]

enc = Path("flag.solarsec.locked").read_bytes()
orig_len = int.from_bytes(enc[6:14], "little")
blob = enc[14:]

Rx = int.from_bytes(blob[1:15], "big")
Ry = int.from_bytes(blob[15:29], "big")
R = (Rx, Ry)

cipher = blob[29:-20]
tag = blob[-20:]

S = mul(d, R)
z = S[0].to_bytes(14, "big")

derived = kdf2_sha1(z, len(cipher) + 16)
plain_padded = bytes(c ^ k for c, k in zip(cipher, derived[:len(cipher)]))
calc_tag = hmac.new(derived[len(cipher):len(cipher)+16], cipher, sha1).digest()

print(calc_tag == tag)
print(plain_padded[:orig_len].decode())
```

flag{bash_history_is_important_in_emergency_response@solarsec_202603}
