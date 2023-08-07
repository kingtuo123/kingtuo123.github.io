---
title: "Gentoo 安装配置"
date: "2022-06-08"
summary: "Note"
description: ""
categories: [ "linux","gentoo" ]
tags: [ "gentoo","linux" ]
---

- 参考文章：
  - [Gentoo AMD64 Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)
  - [Gentoo安装流程分享](https://zhuanlan.zhihu.com/p/122222365)
  - [内核总体设置和性能调优](https://zhuanlan.zhihu.com/p/164910411)

## 连接无线网

``` 
# wpa_passphrase <wifi> <passwd> > /etc/wpa_supplicant/wpa_supplicant.conf
# wpa_supplicant -i <dev> -c /etc/wpa_supplicant/wpa_supplicant.conf -B
# dhcpd
```

### 可选：使用 SSH 连接

``` 
# rc-service sshd start
# passwd root
```

这里注意记得修改 root 密码，因为不知道 livecd 的 root 密码。

## 准备磁盘

### 分区

``` 
# parted /dev/nvme0n1
```
```bash
# 创建 gpt 分区
(parted) mklabel gpt

# 创建引导分区，注意这里从2048个扇区开始，对齐分区
(parted) mkpart EFI fat32 2048s 512MB

# 创建根分区
(parted) mkpart root ext4 512MB 100%

# 设置分区1 flag  boot, esp
(parted) set 1                                                            

# 打印分区信息
(parted) p                                                                
Model: PM981 NVMe Samsung 512GB (nvme)
Disk /dev/nvme0n1: 512GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End    Size   File system  Name  Flags
 1      1049kB  512MB  511MB  fat32        EFI   boot, esp
 2      512MB   512GB  512GB  ext4         root
```

### 格式化分区

``` 
# mkfs.fat -F 32 /dev/nvme0n1p1
# mkfs.ext4 /dev/nvme0n1p2
```

### 挂载 root 分区

``` 
# mount /dev/nvme0n1p2 /mnt/gentoo
```

## 安装 stage3

### 设置日期和时间

格式：月日时分年，如 060504032022 ，表示 2022 年 06 月 05 日 04 时 03 分。

``` 
# date 060504032022
```

### 下载 stage3

这里使用 links 访问清华开源镜像站下载：

``` 
# cd /mnt/gentoo/
# links https://mirrors.tuna.tsinghua.edu.cn/gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/
```

### 解压 stage3

``` 
# tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

## 配置 make.conf

``` 
# vi /mnt/gentoo/etc/portage/make.conf
```

修改如下：

```text
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
COMMON_FLAGS="-march=native -O3 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# NOTE: This stage was built with the bindist Use flag enabled
PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C

# 核心数*2
MAKEOPTS="-j8"

# 清华源
GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo"
# 阿里源
#GENTOO_MIRRORS="https://mirrors.aliyun.com/gentoo/"

USE="-kde -systemd -gnome -wayland -bluetooth efi-64 pulseaudio dbus caps"
VIDEO_CARDS="i965 intel"
INPUT_DEVICES="libinput synaptics"

GRUB_PLATFORMS="efi-64"

ACCEPT_LICENSE="*"
```

## 安装基本系统

### 拷贝 DNS 信息

``` 
# cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

### 挂载文件系统

``` 
# mount --types proc /proc /mnt/gentoo/proc
# mount --rbind /sys /mnt/gentoo/sys
# mount --make-rslave /mnt/gentoo/sys
# mount --rbind /dev /mnt/gentoo/dev
# mount --make-rslave /mnt/gentoo/dev
# mount --bind /run /mnt/gentoo/run
# mount --make-slave /mnt/gentoo/run
```
### 进入新环境

``` 
# chroot /mnt/gentoo /bin/bash
# source /etc/profile
# export PS1="(chroot) ${PS1}"
```
### 挂载 EFI 分区

``` 
# mkdir -p /boot/EFI
# mount /dev/nvme0n1p1 /boot/EFI/
```

## 配置 Portage

### 更新 ebuild 仓库

``` 
# emerge-webrsync
```

### 选择配置文件

``` 
# eselect profile list
```
输出如下：

```text
Available profile symlink targets:
  [1]   default/linux/amd64/17.1 (stable)
  [2]   default/linux/amd64/17.1/selinux (stable)
  [3]   default/linux/amd64/17.1/hardened (stable)
  [4]   default/linux/amd64/17.1/hardened/selinux (stable)
  [5]   default/linux/amd64/17.1/desktop (stable) *
  [6]   default/linux/amd64/17.1/desktop/gnome (stable)
  [7]   default/linux/amd64/17.1/desktop/gnome/systemd (stable)
  ...
```

``` 
# eselect profile set 5
```

### 更新 world

``` 
# emerge --ask --verbose --update --deep --newuse @world
```

### 预安装一些软件

``` 
# emerge -av vim \
  wpa_supplicant \
  net-misc/dhcp \
  app-text/tree \
  mlocate \
  linux-firmware \
  gentoolkit \
  net-wireless/iw \
  pciutils
```

### 时区设置

``` 
# echo "Asia/Shanghai" > /etc/timezone
# emerge --config sys-libs/timezone-data
```

### 配置语言环境

编辑 `/etc/locale.gen` 添加如下：

```text
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
zh_CN.GBK GBK
```

然后执行

``` 
# locale-gen
```

语言选择：

``` 
# eselect locale list
```

```text
Available targets for the LANG variable:
  [1]   C
  [2]   C.utf8
  [3]   POSIX
  [4]   en_US.utf8
  [5]   zh_CN.gbk
  [6]   zh_CN.utf8
  [7]   C.UTF8 *
  [ ]   (free form)
```

设置 en_US.utf8 ：

``` 
# eselect locale set 4
# env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

## 配置内核

### 下载固件和CPU微代码

``` 
# emerge --ask sys-kernel/linux-firmware sys-firmware/intel-microcode
```

### 下载内核源码

``` 
# emerge --ask sys-kernel/gentoo-sources
```

### 选择内核版本

``` 
# eselect kernel list
```

```text
Available kernel symlink targets:
  [1]   linux-5.15.41-gentoo
```

``` 
# eselect kernel set 1
```

### 配置内核

``` 
# cd /usr/src/linux
# make menuconfig
```

内核参数配置因人、机器而异，这里不详述。

### 编译安装

```
# make -j8
# make install
# make modules_install
```

### 可选：构建 initramfs

```
# emerge --ask sys-kernel/dracut
# dracut --kver=5.15.41-gentoo
```

## 系统配置

### 配置 /etc/fstab

```fstab
/dev/nvme0n1p1		/boot		vfat		defaults,noatime	0 2
/dev/nvme0n1p2		/		ext4		noatime			0 1
```

### 主机和域信息

```text
# vim /etc/conf.d/hostname

hostname="gentoo"
```

```text
# vim /etc/conf.d/net

dns_domain_lo="localhost"
```

```text
# vim /etc/host

127.0.0.1       gentoo.localhost gentoo localhost
```

```
# vim /etc/rc.conf

rc_parallel="YES"
```

```
# vim /etc/conf.d/hwclock

clock="local"
```

## 安装系统工具

### 日志系统

```text
# emerge --ask app-admin/sysklogd
# rc-update add sysklogd default
```

### 时钟同步

```text
# emerge --ask net-misc/chrony
# rc-update add chronyd default
```


## 配置引导加载程序

```text
# emerge --ask sys-boot/grub
# grub-install --target=x86_64-efi --efi-directory=/boot/EFI --removable
```

### grub 内核启动参数

编辑 `/etc/default/grub` ，添加下面一行

```bash
GRUB_CMDLINE_LINUX="root=/dev/nvme0n1p2"
```
生成 grub  配置文件：

```
# grub-mkconfig -o /boot/grub/grub.cfg
```

## 收尾工作

### 添加用户

```
# useradd -m -G users,wheel,audio,usb -s /bin/bash king
```

修改用户和 root 密码

```
# passwd king
# passwd root
```

默认密码强度需要数字大小写字母，你可以修改 `/etc/security/passwdqc.conf` 配置。


## wpa_supplicant 配置

编辑 `/etc/wpa_supplicant/wpa_supplicant.conf`

```
update_config=1
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel
```

添加开机启动，编辑 `/etc/local.d/boot.start`

```
wpa_supplicant -i wlp2s0 -c /etc/wpa_supplicant/wpa_supplicant.conf -B && dhclient wlp2s0 &
```

执行：

```
# chmod +x /etc/local.d/boot.start
# rc-update add local default
# rc-update del netmount default
```

> 也可以用 rc-update add wpa_supplicant default 添加开机启动，但是启动时连接 wifi 会阻塞十来秒。暂时只想到上面的方法。

## network

启动时提示 `service 'netmount' needs non existent 'net'` ，解决办法：

```
# ln -s /etc/init.d/net.lo /etc/init.d/net.wlp2s0
```


## hidpi tty&grub font

安装字体：

```
# emerge -av terminus-font
```

编辑 `/etc/conf.d/consolefont`，添加如下：

```
consolefont="ter-d32n"
```

添加开机启动：

```
# rc-update add consolefont default
```

生成 grub 字体：

```
# grub-mkfont -s 32 -o /boot/grub/fonts/terminus32b.pf2 /usr/share/fonts/terminus/ter-u32b.otb
```

编辑 `/etc/default/grub`，如下：

```
GRUB_FONT="/boot/grub/fonts/terminus32b.pf2"
```

然后

```
# grub-mkconfig -o /boot/grub/grub.cfg
```

## 其他常用程序

```
app-admin/sudo
app-portage/pfl
```

## xorg

```
#emerge --ask x11-base/xorg-server
#emerge --ask x11-base/xorg-x11
```

至此基本系统就已安装完毕，剩下的就是桌面环境安装配置。

**未完待续...**