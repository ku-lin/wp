---
title: "Docker使用速查"
lastmod: 2026-04-27T23:21:55+08:00
draft: false
---
# Docker 使用速查

适用场景：服务器取证、CTF/电子取证比赛、临时跑 MySQL/Redis/Web 服务、分析 `docker.img`、查看容器配置和日志。

## 基础概念

```text
image      镜像，容器运行模板
container  容器，由镜像启动出来的实例
volume     数据卷，用来持久化数据库、网站文件等
network    Docker 网络，决定容器之间和宿主机如何通信
port       端口映射，如 8080:80 表示宿主机 8080 -> 容器 80
```

## 查看状态

```bash
docker version
docker info
docker ps
docker ps -a
docker images
docker volume ls
docker network ls
```

只看容器 ID：

```bash
docker ps -aq
```

## 启动 Docker 服务

先区分两个概念：

- 启动 Docker 服务：让 `dockerd` 后台守护进程跑起来。
- 启动容器：Docker 服务已经运行后，再 `docker start` 或 `docker run` 容器。

### Linux systemd

Ubuntu、Debian、CentOS、Rocky、Kali 等大多数发行版：

```bash
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker
```

重启 Docker：

```bash
sudo systemctl restart docker
```

停止 Docker：

```bash
sudo systemctl stop docker
```

查看 Docker 服务日志：

```bash
journalctl -u docker --no-pager -n 200
journalctl -u docker -f
```

如果提示没有权限访问 Docker：

```bash
sudo docker ps
sudo usermod -aG docker $USER
```

执行 `usermod` 后需要重新登录终端，或者重启系统。

### Linux service 命令

老系统或没有 systemd 的环境：

```bash
sudo service docker status
sudo service docker start
sudo service docker restart
sudo service docker stop
```

### 手动启动 dockerd

临时测试环境可直接启动守护进程：

```bash
sudo dockerd
```

后台运行：

```bash
sudo nohup dockerd > /tmp/dockerd.log 2>&1 &
docker ps
```

### Windows Docker Desktop

Windows 上一般启动 Docker Desktop：

```powershell
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
docker version
docker ps
```

如果 Docker Desktop 服务没起来：

```powershell
Get-Service *docker*
Start-Service com.docker.service
```

检查 WSL：

```powershell
wsl -l -v
wsl --status
```

### WSL 中使用 Docker

如果装了 Docker Desktop，并开启 WSL integration：

```bash
docker version
docker ps
```

如果是在 WSL 里自己装 Docker：

```bash
sudo service docker start
docker ps
```

或：

```bash
sudo dockerd
```

### Unraid 中启动 Docker

Unraid 的 Docker 服务通常由 rc 脚本管理：

```bash
/etc/rc.d/rc.docker status
/etc/rc.d/rc.docker start
/etc/rc.d/rc.docker restart
/etc/rc.d/rc.docker stop
```

启动前先确认阵列和 Docker 镜像路径已经可用：

```bash
df -h
mount | grep -E 'disk1|zfs|docker'
cat /boot/config/docker.cfg
```

启动后检查：

```bash
docker info
docker ps -a
docker images
```

如果 Docker 服务启动了，但容器没启动：

```bash
docker start $(docker ps -aq)
docker ps
```

### Docker Compose 启动

进入有 `compose.yaml` 或 `docker-compose.yml` 的目录：

```bash
docker compose up -d
docker compose ps
docker compose logs -f
```

老版本命令：

```bash
docker-compose up -d
docker-compose ps
docker-compose logs -f
```

## 启动和停止容器

启动已有容器：

```bash
docker start <container>
docker start $(docker ps -aq)
```

停止容器：

```bash
docker stop <container>
docker stop $(docker ps -aq)
```

重启容器：

```bash
docker restart <container>
```

删除容器：

```bash
docker rm <container>
docker rm -f <container>
```

## 创建新容器

后台运行：

```bash
docker run --name test-nginx -p 8080:80 -d nginx
```

交互运行：

```bash
docker run --rm -it ubuntu bash
```

挂载目录：

```bash
docker run --name web -p 8080:80 -v /host/www:/usr/share/nginx/html:ro -d nginx
```

环境变量：

```bash
docker run --name app -e KEY=value -d image_name
```

## 查看日志和配置

日志：

```bash
docker logs <container>
docker logs --tail 200 <container>
docker logs -f <container>
```

端口：

```bash
docker port <container>
docker ps
```

详细配置：

```bash
docker inspect <container>
docker inspect <image>
```

常用过滤：

```bash
docker inspect <container> | grep -i "IPAddress\\|Gateway\\|Ports\\|Mounts\\|Env"
```

有 `jq` 时：

```bash
docker inspect <container> | jq '.[0].Name, .[0].Config.Image, .[0].Config.Env, .[0].Mounts, .[0].NetworkSettings.Ports'
```

## 进入容器

```bash
docker exec -it <container> bash
docker exec -it <container> sh
```

在容器里执行一条命令：

```bash
docker exec <container> ls -lah /
docker exec <container> env
```

拷贝文件：

```bash
docker cp <container>:/path/in/container ./local_path
docker cp ./local_file <container>:/path/in/container
```

## MySQL 临时环境

启动 MySQL 5.7：

```bash
docker run --name mysql57 -e MYSQL_ROOT_PASSWORD=rootpass -p 3306:3306 -d mysql:5.7
docker logs -f mysql57
```

启动 MySQL 8：

```bash
docker run --name mysql8 -e MYSQL_ROOT_PASSWORD=rootpass -p 3306:3306 -d mysql:8
```

进入 MySQL：

```bash
docker exec -it mysql57 mysql -uroot -prootpass
```

创建库：

```bash
docker exec -i mysql57 mysql -uroot -prootpass -e "CREATE DATABASE IF NOT EXISTS test DEFAULT CHARSET utf8mb4;"
```

导入 SQL：

```bash
docker exec -i mysql57 mysql -uroot -prootpass test < ./data.sql
```

导出 SQL：

```bash
docker exec mysql57 mysqldump -uroot -prootpass test > test.sql
```

常用查询：

```bash
docker exec -i mysql57 mysql -uroot -prootpass test -e "SHOW TABLES;"
docker exec -i mysql57 mysql -uroot -prootpass test -e "SELECT * FROM user LIMIT 10;"
```

停止清理：

```bash
docker stop mysql57
docker rm mysql57
```

## Redis 临时环境

启动 Redis：

```bash
docker run --name redis -p 6379:6379 -d redis
```

带密码：

```bash
docker run --name redis-pass -p 6379:6379 -d redis redis-server --requirepass password123
```

连接：

```bash
docker exec -it redis redis-cli
docker exec -it redis-pass redis-cli -a password123
```

常用命令：

```bash
KEYS *
GET key
HGETALL key
ZRANGE key 0 -1 WITHSCORES
```

## Web 服务临时环境

Nginx 挂网站目录：

```bash
docker run --name nginx-web -p 8080:80 -v /host/www:/usr/share/nginx/html:ro -d nginx
```

PHP Apache：

```bash
docker run --name php-web -p 8080:80 -v /host/www:/var/www/html -d php:7.4-apache
```

查看访问日志：

```bash
docker logs -f nginx-web
docker logs -f php-web
```

## Docker Compose

启动：

```bash
docker compose up -d
```

查看：

```bash
docker compose ps
docker compose logs
docker compose logs -f
```

停止：

```bash
docker compose down
```

重建：

```bash
docker compose up -d --build
```

## Unraid 中 Docker

Unraid 里 Docker 通常由 rc 脚本管理：

```bash
/etc/rc.d/rc.docker start
/etc/rc.d/rc.docker stop
/etc/rc.d/rc.docker restart
```

查看容器：

```bash
docker ps -a
docker images
docker volume ls
```

启动所有容器：

```bash
docker start $(docker ps -aq)
```

查看容器端口和日志：

```bash
docker port <container>
docker logs --tail 200 <container>
```

## 离线分析 docker.img

`docker.img` 需要作为磁盘镜像挂载，里面通常是 BTRFS。

```bash
file docker.img
sudo losetup --find --partscan --show docker.img
lsblk -f
```

如果镜像本身就是文件系统：

```bash
sudo mkdir -p /mnt/docker
sudo mount -o ro,loop docker.img /mnt/docker
```

如果识别出分区：

```bash
sudo mount -o ro /dev/loop2p1 /mnt/docker
```

BTRFS 异常时可试：

```bash
sudo mount -t btrfs -o ro,loop,recovery docker.img /mnt/docker
sudo mount -t btrfs -o ro,degraded /dev/loop2p1 /mnt/docker
```

卸载：

```bash
sudo umount /mnt/docker
sudo losetup -d /dev/loop2
```

## 离线取证重点路径

```text
/mnt/docker/containers/<container_id>/config.v2.json
/mnt/docker/containers/<container_id>/hostconfig.json
/mnt/docker/containers/<container_id>/<container_id>-json.log
/mnt/docker/image/btrfs/imagedb/content/sha256
/mnt/docker/volumes/<volume_name>/_data
```

用途：

- `config.v2.json`：容器名、镜像、环境变量、启动命令、挂载点。
- `hostconfig.json`：端口映射、绑定目录、网络模式。
- `*-json.log`：容器输出日志，Web 访问记录有时也在这里。
- `imagedb/content/sha256`：镜像元数据。
- `volumes/*/_data`：数据库、网站、应用持久化数据。

搜索容器配置：

```bash
find /mnt/docker/containers -maxdepth 2 -name "config.v2.json" -o -name "hostconfig.json"
grep -RIn '"Name"\\|"Image"\\|"Env"\\|"PortBindings"\\|"Binds"' /mnt/docker/containers
```

有 `jq`：

```bash
jq '.Name,.Config.Image,.Config.Env,.MountPoints' /mnt/docker/containers/*/config.v2.json
jq '.PortBindings,.Binds' /mnt/docker/containers/*/hostconfig.json
```

## 清理命令

清理停止的容器：

```bash
docker container prune
```

清理不用的镜像：

```bash
docker image prune
```

清理不用的卷：

```bash
docker volume prune
```

清理全部未使用资源：

```bash
docker system prune
```

注意：取证环境里不要随便对原始检材或仿真环境运行清理命令，除非你确认这是临时测试环境。

