---
title: "GRUB说明"
lastmod: 2026-05-05T20:17:54+08:00
draft: false
---
# GRUB 与 grub rescue 说明

## 1. GRUB 是什么

GRUB 全称是 GNU GRUB，是 Linux 系统常用的启动加载器。

电脑开机后，系统并不是直接进入 Linux，而是先经历一个启动链路：

```text
固件 BIOS/UEFI -> GRUB -> Linux 内核 -> systemd/init -> 用户空间
```

GRUB 的作用是：

- 找到 Linux 内核文件
- 找到 initramfs/initrd 文件
- 读取启动配置
- 把内核加载进内存
- 把启动参数传给内核
- 最后把控制权交给 Linux 内核

常见的 GRUB 文件目录是：

```text
/boot/grub
```

里面通常会有：

```text
grub.cfg
grubenv
fonts/
locale/
themes/
x86_64-efi/
```

其中 `grub.cfg` 是 GRUB 的主要配置文件，里面记录了启动菜单、内核路径、initrd 路径、root 设备等信息。

## 2. 为什么会进入 grub rescue

`grub rescue>` 是 GRUB 的救援模式。

当 GRUB 找不到自己的配置文件、模块目录、启动分区，或者原来的磁盘设备路径变化时，就可能进入这个模式。

常见原因包括：

- 磁盘分区顺序变了
- 系统迁移到了虚拟机
- RAID/LVM 被重组后设备名变化
- `/boot/grub` 路径找不到
- `grub.cfg` 里记录的 UUID 不存在
- VMDK/镜像挂载方式改变
- EFI/BIOS 启动方式和原系统不一致

这题里的报错类似：

```text
error: disk `md/uuid/...' not found.
grub rescue>
```

这里的 `md/uuid/...` 表示 Linux MD RAID 设备。

原系统启动时，GRUB 认为启动文件在 MD RAID 阵列上。你重组 RAID0 后，把系统导出成普通虚拟磁盘，原来的 `md/uuid/...` 设备不存在了，所以 GRUB 找不到原来的启动位置，进入 rescue 模式。

## 3. GRUB 里的磁盘表示方法

GRUB 不使用 Linux 里的 `/dev/sda1` 这种路径。

它有自己的表示方式：

```text
(hd0)
(hd0,gpt1)
(hd0,gpt2)
(cd0)
```

含义如下：

```text
(hd0)       第一块硬盘
(hd1)       第二块硬盘
(hd0,gpt1) 第一块硬盘的 GPT 第 1 分区
(hd0,gpt2) 第一块硬盘的 GPT 第 2 分区
(cd0)       光驱或 ISO
```

如果是 MBR 分区表，可能会看到：

```text
(hd0,msdos1)
(hd0,msdos2)
```

如果是 GPT 分区表，通常会看到：

```text
(hd0,gpt1)
(hd0,gpt2)
```

## 4. GRUB 的 ls 和 Linux 的 ls 不一样

在 Linux shell 中：

```bash
ls /boot/grub
```

这是 Linux 内核启动之后，由 Linux 文件系统驱动读取目录。

但在 `grub rescue>` 中：

```text
ls
```

这是 GRUB 自己的命令。此时 Linux 还没有启动，只有 GRUB 自带的一小套磁盘和文件系统识别能力。

GRUB 的 `ls` 主要用于探路：

### 4.1 列出 GRUB 能看到的磁盘和分区

```text
grub rescue> ls
```

示例输出：

```text
(hd0) (hd0,gpt2) (hd0,gpt1) (cd0)
```

这说明 GRUB 目前能看到一块硬盘、两个 GPT 分区和一个光驱。

### 4.2 查看某个分区的文件系统

```text
grub rescue> ls (hd0,gpt2)
```

示例输出：

```text
(hd0,gpt2): Filesystem is ext2.
```

这里显示 `ext2` 不一定说明分区真的是 ext2。

GRUB 经常用 `ext2` 模块支持 ext2/ext3/ext4，所以 ext4 在 GRUB 里也可能显示为 `ext2`。

### 4.3 查看某个目录

```text
grub rescue> ls (hd0,gpt2)/boot/grub
```

示例输出：

```text
./ ../ themes/ unicode.pf2 x86_64-efi/ locale/ fonts/ grubenv grub.cfg
```

如果能看到 `grub.cfg`，说明这个分区里存在 GRUB 配置目录。

## 5. root 是什么

`root` 是 GRUB 的变量，用来告诉 GRUB 当前默认从哪个磁盘/分区读文件。

例如：

```text
set root=(hd0,gpt2)
```

意思是：

```text
后续默认从 (hd0,gpt2) 这个分区读取文件
```

如果之后执行：

```text
linux /boot/vmlinuz
```

GRUB 会理解为：

```text
(hd0,gpt2)/boot/vmlinuz
```

所以可以简单理解为：

```text
root = 启动文件所在的分区
```

## 6. prefix 是什么

`prefix` 也是 GRUB 的变量，用来告诉 GRUB 自己的工作目录在哪里。

例如：

```text
set prefix=(hd0,gpt2)/boot/grub
```

意思是：

```text
GRUB 的模块、配置、字体、语言文件在 (hd0,gpt2)/boot/grub
```

`prefix` 指向的目录里通常可以看到：

```text
grub.cfg
x86_64-efi/
fonts/
locale/
themes/
grubenv
```

可以简单理解为：

```text
prefix = GRUB 自己的配置和模块目录
```

## 7. insmod normal 和 normal 是什么

在 rescue 模式中，GRUB 功能很少。

要回到正常启动菜单，需要加载 GRUB 的 normal 模块：

```text
insmod normal
```

含义是：

```text
加载 normal 模块
```

加载成功后，再执行：

```text
normal
```

含义是：

```text
进入 GRUB 正常模式
```

正常模式下通常会读取 `grub.cfg`，显示熟悉的启动菜单。

所以这两句经常一起出现：

```text
insmod normal
normal
```

## 8. 这题里的操作逻辑

题中进入了：

```text
grub rescue>
```

首先列出 GRUB 能看到的设备：

```text
ls
```

输出：

```text
(hd0) (hd0,gpt2) (hd0,gpt1) (cd0)
```

说明当前有：

- 第一块硬盘 `(hd0)`
- 第一块硬盘的第 1 个 GPT 分区 `(hd0,gpt1)`
- 第一块硬盘的第 2 个 GPT 分区 `(hd0,gpt2)`
- 光驱或 ISO `(cd0)`

然后尝试查看分区：

```text
ls (hd0,gpt1)
ls (hd0,gpt2)
```

如果 `(hd0,gpt1)` 显示：

```text
Filesystem is unknown.
```

说明它不是 GRUB 当前能识别的 Linux 启动分区。

如果 `(hd0,gpt2)` 显示：

```text
Filesystem is ext2.
```

说明 GRUB 可以识别该分区，可能是 Linux 的 ext4 分区。

继续查看 GRUB 目录：

```text
ls (hd0,gpt2)/boot/grub
```

如果能看到：

```text
grub.cfg
x86_64-efi/
fonts/
locale/
grubenv
```

就能确认：

```text
GRUB 配置目录在 (hd0,gpt2)/boot/grub
```

所以设置：

```text
set root=(hd0,gpt2)
set prefix=(hd0,gpt2)/boot/grub
```

再加载 normal 模块：

```text
insmod normal
normal
```

如果成功，就会进入正常 GRUB 菜单。

## 9. 通用排查套路

进入 `grub rescue>` 后，可以按这个思路来：

```text
ls
ls (hd0,gpt1)/
ls (hd0,gpt2)/
ls (hd0,gpt3)/
```

找到能识别的 Linux 分区后，继续找 `/boot/grub`：

```text
ls (hd0,gpt1)/boot/grub
ls (hd0,gpt2)/boot/grub
ls (hd0,gpt3)/boot/grub
```

哪个分区能列出 `grub.cfg`，就用哪个分区：

```text
set root=(hd0,gptX)
set prefix=(hd0,gptX)/boot/grub
insmod normal
normal
```

其中 `gptX` 要替换成实际找到的分区号。

## 10. 和 RAID 重组的关系

这题和 RAID 重组有关。

原 Kali 系统位于 Linux MD RAID 阵列中。GRUB 原本记录的启动设备是：

```text
md/uuid/...
```

这表示一个 MD RAID 设备。

你在取证过程中重组 RAID0 后，可能把结果导出成了普通虚拟磁盘，比如 VMDK。这样一来，虚拟机启动时看到的是普通硬盘分区：

```text
(hd0,gpt1)
(hd0,gpt2)
```

而不是原来的：

```text
md/uuid/...
```

因此 GRUB 根据旧配置找不到原 RAID 设备，就进入 rescue 模式。

这时手动设置 `root` 和 `prefix`，就是告诉 GRUB：

```text
不要再找原来的 md/uuid 设备了
现在 /boot/grub 在 (hd0,gpt2)/boot/grub
```

## 11. WP 写法示例

可以在 WP 中这样描述：

```text
重组 Kali 的 RAID0 后，将系统导出为普通虚拟磁盘进行仿真。启动时 GRUB 报错 disk `md/uuid/...` not found，说明原 GRUB 配置仍引用 Linux MD RAID 设备，而当前虚拟化环境中该 RAID 设备路径已经变化，导致 GRUB 无法定位启动分区并进入 rescue 模式。

在 grub rescue 中执行 ls 枚举当前可见设备，发现存在 (hd0,gpt1)、(hd0,gpt2)。继续使用 ls 分别查看分区，发现 (hd0,gpt2) 可被 GRUB 识别，并且 (hd0,gpt2)/boot/grub 下存在 grub.cfg、x86_64-efi、fonts、locale 等文件，因此确认 GRUB 配置目录位于该分区。

随后设置 root 和 prefix：

set root=(hd0,gpt2)
set prefix=(hd0,gpt2)/boot/grub

再加载 normal 模块并进入正常模式：

insmod normal
normal

成功进入 GRUB 正常启动菜单。
```

## 12. 常见错误

### 12.1 ls 后面漏空格

错误：

```text
ls(hd0)
```

正确：

```text
ls (hd0)
```

GRUB 会把 `ls(hd0)` 当成一个完整命令名，所以报：

```text
Unknown command `ls(hd0)'.
```

### 12.2 直接查看整块磁盘

```text
ls (hd0)
```

有时会报错，因为 `(hd0)` 是整块磁盘，不是具体文件系统分区。

更常见的做法是查看具体分区：

```text
ls (hd0,gpt1)
ls (hd0,gpt2)
```

### 12.3 prefix 写错

如果 `prefix` 写错，执行：

```text
insmod normal
```

可能会失败，因为 GRUB 找不到 normal 模块。

需要重新确认：

```text
ls (hd0,gptX)/boot/grub
```

确保该目录下确实存在：

```text
x86_64-efi/
grub.cfg
```

## 13. 一句话总结

`grub rescue>` 不是 Linux shell，而是 GRUB 的救援环境。

在这个环境中，核心思路是：

```text
用 ls 找到包含 /boot/grub/grub.cfg 的分区
用 set root 指定启动分区
用 set prefix 指定 GRUB 目录
用 insmod normal 和 normal 回到正常启动菜单
```


