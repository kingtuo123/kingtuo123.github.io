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
  - [/etc/portage/make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf)
  - [Grub](https://wiki.gentoo.org/wiki/GRUB)
  - [Power management/Processor](https://wiki.gentoo.org/wiki/Power_management/Processor)

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

# 设置分区1 flag  boot, esp 命令后面按 tab 可以查看 flag
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

```shell
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
COMMON_FLAGS="-march=native -O2 -pipe -flto"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# NOTE: This stage was built with the bindist Use flag enabled

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C.utf8

GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo"


MAKEOPTS="-j8"

USE="-kde -systemd -gnome -wayland -ipv6 -qt5 -gtk pulseaudio dbus elogind"


EMERGE_DEFAULT_OPTS="--with-bdeps=y --quiet-build"
PORTAGE_TMPDIR="/tmp"
VIDEO_CARDS="nvidia"
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

```text
# mount --types proc /proc /mnt/gentoo/proc
# mount --rbind /sys /mnt/gentoo/sys
# mount --make-rslave /mnt/gentoo/sys
# mount --rbind /dev /mnt/gentoo/dev
# mount --make-rslave /mnt/gentoo/dev
# mount --bind /run /mnt/gentoo/run
# mount --make-slave /mnt/gentoo/run
```
### 进入新环境

```text
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

```shell-session {hl_lines=[7]}
# eselect profile list
Available profile symlink targets:
  [1]   default/linux/amd64/17.1 (stable)
  [2]   default/linux/amd64/17.1/selinux (stable)
  [3]   default/linux/amd64/17.1/hardened (stable)
  [4]   default/linux/amd64/17.1/hardened/selinux (stable)
  [5]   default/linux/amd64/17.1/desktop (stable) *
  [6]   default/linux/amd64/17.1/desktop/gnome (stable)
  [7]   default/linux/amd64/17.1/desktop/gnome/systemd (stable)
  ...
# eselect profile set 5
```

### 更新 world

``` 
# emerge --ask --verbose --update --deep --newuse @world
```

### 预安装一些软件

```text
# emerge -av \
  neovim \
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
```

然后执行：

``` 
# locale-gen
```

设置语言：

```bash-session {hl_lines=[6]}
# eselect locale list
Available targets for the LANG variable:
  [1]   C
  [2]   C.utf8
  [3]   POSIX
  [4]   en_US.utf8
  [5]   zh_CN.gbk
  [6]   zh_CN.utf8
  [7]   C.UTF8 *
  [ ]   (free form)
# eselect locale set 4
# env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

## 配置内核

### 可选：下载固件和CPU微代码

``` 
# emerge --ask sys-kernel/linux-firmware sys-firmware/intel-microcode
```

### 下载内核源码

``` 
# emerge --ask sys-kernel/zen-sources
```

官方手册使用的内核是 `gentoo-sources`，更多其它内核的介绍查看 [Kernel/Overview](https://wiki.gentoo.org/wiki/Kernel/Overview)

### 选择内核版本

```bash-session
# eselect kernel list
Available kernel symlink targets:
  [1]   linux-5.15.41-zen
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
# dracut --kver=5.15.41-zen
```

## 系统配置

### 配置 fstab

```bash-session
# vim /etc/fstab
/dev/nvme0n1p1		/boot/EFI	vfat		defaults,noatime	0 2
/dev/nvme0n1p2		/		ext4		noatime			0 1
```

### 主机和域信息

```bash-session
# vim /etc/conf.d/hostname
hostname="gentoo"

# vim /etc/conf.d/net
dns_domain_lo="localhost"

# vim /etc/host
127.0.0.1       gentoo.localhost gentoo localhost
```

### OpenRC 并行启动

似乎能略微提高启动速度

```bash-session
# vim /etc/rc.conf
rc_parallel="YES"
```

### 本地时钟

默认是 `UTC` ，如果是 windows 和 linux 双系统，设置为 `local` ，否则会有 8 小时时差

```bash-session
# vim /etc/conf.d/hwclock
clock="local"
```

## 安装系统工具

### 日志系统

```text
# emerge --ask app-admin/sysklogd
# rc-update add sysklogd default
```

### 可选：时钟同步

```text
# emerge --ask net-misc/chrony
# rc-update add chronyd default
```


## 配置引导加载程序

```text
# emerge --ask sys-boot/grub
# grub-install --target=x86_64-efi --efi-directory=/boot/EFI --removable
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


## wpa_supplicant 无线网配置

添加网络：

```text
# wpa_passphrase 网络名称 密码 >> /etc/wpa_supplicant/wpa_supplicant.conf
```

编辑 `/etc/wpa_supplicant/wpa_supplicant.conf`，添加：

```text
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel
update_config=1
```

编辑 `/etc/conf.d/net`，添加：

```text
modules_wlp2s0="wpa_supplicant"
config_wlp2s0="dhcp"
```

添加开机启动：

```
# cd /etc/init.d
# ln -s net.lo net.wlp2s0
# rc-update add net.wlp2s0 default
```



## HiDPI displays

### 终端界面字体

使高分屏显示更大的文字，内核支持 16x32 字体：

```
Library routines  --->
      [*] Select compiled-in fonts
      [*] Terminus 16x32 font (not supported by all drivers)
```


### grub 引导界面字体

安装 terminus-font：

```
# emerge --ask media-fonts/terminus-font
```

生成 grub 字体：

```
# grub-mkfont -s 32 -o /boot/grub/fonts/terminus32b.pf2 /usr/share/fonts/terminus/ter-u32b.otb
```

编辑 `/etc/default/grub`，添加：

```
GRUB_FONT="/boot/grub/fonts/terminus32b.pf2"
```

然后

```
# grub-mkconfig -o /boot/grub/grub.cfg
```


## xorg

```
# emerge --ask x11-base/xorg-server
```

至此基本系统就已安装完毕，剩下的就是桌面环境安装配置。


## 开机启动项

- sysklogd
- elogind
- dbus
- net.wlp2s0
- gpm


## 常用的程序

- app-admin/sudo
- doas
- app-portage/pfl
- elogind
- flameshot
- bash-completion
- xrandr
- udisks
- acpilight
- alacritty
- feh
- terminus-font
- soruce-code-pro
- lxapperance
- nerd-font


## 常用的配置

### Udisks

- 参考：
  - [gentoo wiki/udisks](https://wiki.gentoo.org/wiki/Udisks)
  - [gentoo wiki/polkit](https://wiki.gentoo.org/wiki/Polkit)

使用 udisks 可以方便挂载设备，udisks 依赖 polkit 和 dubs

配置 polkit 规则，允许用户挂载设备：

```bash-session
# vim /etc/polkit-1/rules.d/10-udisks.rules

polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.udisks2.filesystem-mount-system" &&
        subject.user == "king") {
        return polkit.Result.YES;
    }
});
```

### 添加 gentoo-zh 仓库（overlay）

```bash-session
# emerge -av eselect-repository
# eselect repository list
  ...
  [130] gentoo-unity7 (https://github.com/c4pp4/gentoo-unity7)
  [131] gentoo-zh * (https://github.com/microcai/gentoo-zh)
  [132] gerislay (https://cgit.gentoo.org/repo/user/gerislay.git)
  ...
# eselect repository enable gentoo-zh
# emerge --sync -r gentoo-zh
```

### xHiDPI

- 参考：[Archwiki HiDPI](https://wiki.archlinux.org/title/HiDPI)

4k 屏 scale 配置：

```bash-session
$ vim ~/.xinitrc
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
xrdb -merge .Xresources

$ vim ~/.Xresources
Xft.dpi: 192
Xcursor.size: 48
!Xcursor.theme: DMZ-Black
Xcursor.theme: Bibata-Modern-Ice

Xft.autohint: 0
Xft.lcdfilter: lcddefault
Xft.hintstyle: hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
```

`Xcursor.theme` 用的鼠标主题需要支持 HIDPI
