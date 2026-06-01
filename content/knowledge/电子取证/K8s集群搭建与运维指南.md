---
title: "K8s 集群搭建与运维指南"
draft: false
---
> 基于 2025 数证杯服务器取证真题环境编写

## 一、什么是 Kubernetes（K8s）？

K8s 是一个**容器编排平台**。把 Docker 容器想象成一个个集装箱，K8s 就是管理这些集装箱的码头系统——决定集装箱放在哪台机器上、网络怎么通、挂了怎么重启。

### 核心概念速览

| 概念 | 通俗理解 | 对应文件 |
|------|---------|---------|
| **Node** | 一台物理机/虚拟机 | `/etc/hosts` 里定义 |
| **Pod** | 最小的调度单位（1个Pod = 1个或多个容器） | Deployment 里的 template |
| **Deployment** | 定义"跑什么镜像、跑几个副本、挂什么存储" | `*-d.yaml` |
| **Service** | 给 Pod 提供一个固定的访问入口（IP/端口） | `*-sv.yaml` |
| **ConfigMap** | 配置文件，注入到容器里 | `*-c.yaml` |
| **PVC** | 申请一块持久化磁盘 | `*-pvc.yaml` |
| **Namespace** | 逻辑上的"文件夹"，用来隔离资源 | 默认在 `default` |

### 集群角色

```
master (控制节点)     ← 集群的大脑
  ├── API Server       ← 所有操作的入口
  ├── Scheduler        ← 决定 Pod 放哪台机器
  ├── Controller Manager ← 维护集群期望状态
  └── etcd             ← 存储所有配置的数据库

node (工作节点)        ← 干活的
  ├── kubelet          ← 管理本机上的 Pod
  ├── kube-proxy       ← 网络代理
  └── Docker/containerd ← 容器运行时
```

---

## 二、集群搭建完整流程

### 2.1 环境准备（所有节点）

```bash
# 设置主机名
hostnamectl set-hostname master   # 或 node1 / node2

# 配置 /etc/hosts（所有节点互相能解析）
cat >> /etc/hosts << EOF
192.168.50.80 master
192.168.50.81 node1
192.168.50.82 node2
EOF

# 关闭 swap（K8s 要求）
swapoff -a
sed -i '/swap/d' /etc/fstab

# 关闭防火墙（简化环境）
systemctl disable firewalld --now
```

### 2.2 安装 Docker + cri-dockerd + kubeadm（所有节点）

```bash
# 安装 Docker
yum install -y docker-ce
systemctl enable docker --now

# 安装 cri-dockerd（让 Docker 对接 K8s 的 CRI 接口）
# cri-dockerd 提供 unix:///var/run/cri-dockerd.sock

# 安装 kubeadm / kubelet / kubectl
yum install -y kubeadm kubelet kubectl
systemctl enable kubelet   # 先 enable，但此时还起不来
```

### 2.3 初始化 master 节点

```bash
# 在 master 上执行
kubeadm init \
  --apiserver-advertise-address=192.168.50.80 \
  --pod-network-cidr=10.224.0.0/16 \
  --cri-socket unix:///var/run/cri-dockerd.sock

# 初始化成功后会输出加入命令，类似：
# kubeadm join 192.168.50.80:6443 --token xxx --discovery-token-ca-cert-hash sha256:xxx
# 记下这行！worker 节点加入需要用到

# 配置 kubectl（让管理员能操作集群）
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config

# 安装网络插件 Calico
kubectl apply -f calico.yaml
```

### 2.4 加入 worker 节点

```bash
# 在 node1、node2 上执行 master 输出的 join 命令
kubeadm join 192.168.50.80:6443 \
  --token xxx \
  --discovery-token-ca-cert-hash sha256:xxx \
  --cri-socket unix:///var/run/cri-dockerd.sock
```

### 2.5 验证集群

```bash
kubectl get nodes
# 等待所有节点变成 Ready
# NAME     STATUS   ROLES           AGE   VERSION
# master   Ready    control-plane   1m    v1.28.15
# node1    Ready    <none>          30s   v1.28.15
# node2    Ready    <none>          30s   v1.28.15
```

---

## 三、部署应用

### 3.1 准备 YAML 文件

K8s 用 YAML 文件描述"期望状态"。有 5 种常见资源：

**Deployment（部署）** — 定义应用怎么跑：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql80
spec:
  replicas: 1                  # 跑 1 个副本
  selector:
    matchLabels:
      app: mysql
  template:                    # Pod 模板
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0        # 用的镜像
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "密码"
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-pv-storage
          mountPath: /var/lib/mysql   # 数据目录挂载
      volumes:
      - name: mysql-pv-storage
        persistentVolumeClaim:
          claimName: mysql80         # 引用 PVC
```

**Service（服务）** — 给应用一个固定的访问入口：
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  type: NodePort              # 通过节点端口暴露
  ports:
  - port: 3306                 # 集群内端口
  selector:
    app: mysql                 # 转发到带这个标签的 Pod
```

**PVC（持久化存储声明）** — 申请磁盘空间：
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mysql80
spec:
  storageClassName: nfs-client   # 存储类型
  accessModes:
  - ReadWriteMany                # 多节点读写
  resources:
    requests:
      storage: 5Gi               # 申请 5GB
```

### 3.2 部署顺序

```bash
# 1. 先部署存储相关（PVC 需要 provisioner 在运行）
kubectl apply -f mysql80-pvc.yaml
kubectl apply -f redis-pvc.yaml
kubectl apply -f captcha-bot-pvc.yaml
kubectl apply -f dujiaoka-pvc.yaml

# 2. 再部署配置
kubectl apply -f mysql-c.yaml
kubectl apply -f dujiaoka-c.yaml
kubectl apply -f dujiaoka-sv.yaml
kubectl apply -f captcha-bot-c.yaml

# 3. 最后部署应用
kubectl apply -f mysql-d.yaml
kubectl apply -f mysql-services.yaml
kubectl apply -f redis-d.yaml
kubectl apply -f redis-service.yaml
kubectl apply -f php-nginx-deployment.yaml
kubectl apply -f captcha-bot-d.yaml
```

**为什么是这个顺序？** 应用（Deployment）启动时需要挂载 PVC 和 ConfigMap，这些必须先存在，否则 Pod 会卡在 Pending。

---

## 四、TLS 证书管理

### 4.1 证书体系

K8s 有一个**证书树**：

```
CA 证书（ca.crt + ca.key）
  ├── apiserver 证书
  ├── apiserver-kubelet-client 证书
  ├── kubelet 客户端证书（每节点独立）
  ├── etcd 证书
  ├── front-proxy-client 证书
  └── admin.conf / kubelet.conf / controller-manager.conf（内嵌证书的 kubeconfig）
```

**CA 是根**（有效期 10 年），其他证书由 CA 签发（有效期 1 年）。

### 4.2 证书位置

```
/etc/kubernetes/pki/
├── ca.crt / ca.key                    # CA 根证书（10年）
├── apiserver.crt / apiserver.key      # API Server 证书
├── apiserver-kubelet-client.crt/key   # API Server 连 kubelet 的证书
├── front-proxy-ca.crt/key             # 前端代理 CA
├── front-proxy-client.crt/key         # 前端代理客户端证书
├── sa.pub / sa.key                    # ServiceAccount 密钥
└── etcd/
    ├── ca.crt / ca.key                # etcd CA
    ├── server.crt / server.key        # etcd 服务端证书
    ├── peer.crt / peer.key            # etcd 节点间证书
    └── healthcheck-client.crt/key     # etcd 健康检查客户端证书

/etc/kubernetes/
├── admin.conf              # kubectl 管理员 kubeconfig
├── kubelet.conf            # kubelet 连 API Server 的 kubeconfig
├── controller-manager.conf
├── scheduler.conf
└── bootstrap-kubelet.conf  # kubelet 初次启动用的引导配置

/var/lib/kubelet/pki/
├── kubelet.crt / kubelet.key                     # kubelet 服务端证书
└── kubelet-client-current.pem -> kubelet-client-2026-xx-xx.pem  # 当前客户端证书
```

### 4.3 诊断命令

```bash
# 全部证书过期情况
kubeadm certs check-expiration

# 单个证书
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates -subject

# 看 kubelet 日志中的证书报错
journalctl -u kubelet --no-pager | grep -i "expir\|certif\|bootstrap"
```

### 4.4 修复方法

**方法一：CA 没过期（最常见）**
```bash
kubeadm certs renew all      # 一键续期
systemctl restart kubelet    # 重启生效
```

**方法二：kubelet 配置文件损坏**
```bash
# master 节点
rm -f /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf
kubeadm init phase kubeconfig kubelet --node-name master
cp /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf
systemctl restart kubelet

# worker 节点（没有完整 PKI，需要重新加入）
kubeadm reset -f --cri-socket unix:///var/run/cri-dockerd.sock
kubeadm join ... --cri-socket unix:///var/run/cri-dockerd.sock
```

**方法三：bootstrap token 过期**
```bash
# 在 master 上生成新 token
kubeadm token create --print-join-command
# 在 worker 上用输出的命令重新加入
```

### 4.5 取证题中遇到证书问题的套路

```bash
# Step 1: 连上后先看服务状态
systemctl status kubelet docker

# Step 2: 看 kubelet 日志找错误
journalctl -u kubelet -n 50 --no-pager

# Step 3: 如果日志里有 expired / certificate / bootstrap 关键词
#          → 证书问题，按上面方法修复

# Step 4: 修好后验证
kubectl get nodes
kubectl get pods -A
```

---

## 五、日常运维命令速查

### 节点管理
```bash
kubectl get nodes -o wide           # 节点列表（含 IP、版本）
kubectl describe node <节点名>       # 节点详情（含 Taint、条件）
kubectl taint nodes master key:NoSchedule-  # 去掉污点，允许调度
kubectl cordon node1                # 标记节点不可调度
kubectl drain node1 --ignore-daemonsets  # 驱逐节点上所有 Pod
```

### Pod 管理
```bash
kubectl get pods -A                          # 所有命名空间的 Pod
kubectl get pods -o wide                     # 含 IP 和所在节点
kubectl describe pod <pod名>                 # 查看详情（事件列表很重要）
kubectl logs <pod名>                         # 看日志
kubectl logs <pod名> --previous              # 看上次崩溃的日志
kubectl exec -it <pod名> -- /bin/bash        # 进入容器 shell
kubectl delete pod <pod名> --force --grace-period=0  # 强制删除
```

### 部署管理
```bash
kubectl get deploy                           # 列出部署
kubectl scale deploy <名称> --replicas=3     # 扩缩容
kubectl rollout restart deploy/<名称>        # 重启（重建所有 Pod）
kubectl rollout history deploy/<名称>        # 查看部署历史
kubectl rollout undo deploy/<名称>           # 回滚
```

### 存储
```bash
kubectl get pvc                              # 持久化存储声明
kubectl get pv                               # 持久化卷
kubectl get sc                               # 存储类
```

### 网络
```bash
kubectl get svc -A                           # 所有服务
kubectl get endpoints                        # 服务端点
```

### 事件排查
```bash
# 事件是排查问题的第一入口
kubectl get events --sort-by=.lastTimestamp | tail -20
kubectl get events -A --sort-by=.lastTimestamp
```

---

## 六、常见故障排查

| 症状 | 可能原因 | 排查命令 |
|------|---------|---------|
| 节点 NotReady | kubelet 没跑/证书过期 | `systemctl status kubelet` / `journalctl -u kubelet` |
| Pod 一直 Pending | PVC 不存在 / 节点不可调度 / 资源不足 | `kubectl describe pod` 看 Events |
| Pod ImagePullBackOff | 镜像拉不下来（内网不通） | `docker pull <镜像名>` 直接试 |
| Pod CrashLoopBackOff | 容器启动后立刻崩溃 | `kubectl logs <pod>` 看报错 |
| Pod ContainerCreating 很久 | 挂载卷失败 / ConfigMap 不存在 | `kubectl describe pod` 看 Events |
| NFS provisioner 报错 | NFS 服务没开 / 地址配错 | `showmount -e <NFS服务器>` / `kubectl logs <provisioner>`

---

## 七、本比赛环境的完整网络拓扑

```
┌─────────────────────────────────────────────────────┐
│               192.168.50.0/24 网络                    │
│                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐│
│  │ master (80)  │  │  node1 (81)  │  │  node2 (82)  ││
│  │              │  │              │  │              ││
│  │ API Server   │  │ kubelet      │  │ kubelet      ││
│  │ Scheduler    │  │ kube-proxy   │  │ kube-proxy   ││
│  │ Controller   │  │ calico-node  │  │ calico-node  ││
│  │ etcd         │  │              │  │              ││
│  │ kubelet      │  │ 运行:        │  │ 运行:        ││
│  │ kube-proxy   │  │   Pod 们     │  │   Pod 们     ││
│  │ calico-node  │  │              │  │              ││
│  │ NFS Server   │  │              │  │              ││
│  └──────────────┘  └──────────────┘  └──────────────┘│
│                                                       │
│  ┌──────────────┐                                    │
│  │ 存储 (83)   │ ← 原 NFS 服务器（当前未启动）       │
│  └──────────────┘                                    │
└─────────────────────────────────────────────────────┘

应用访问方式（NodePort）：
  curl http://192.168.50.80:31669    # 独角数卡 Web
  curl http://192.168.50.81:31669    # 同上（任意节点）
  mysql -h 192.168.50.80 -P 30627 -u root -p'LKKD23mjakl213dmmm'
  redis-cli -h 192.168.50.80 -p 31678
  https://192.168.50.80:30001       # K8s Dashboard
```

