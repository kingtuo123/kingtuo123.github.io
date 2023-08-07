---
author: "kingtuo123"
title: "Gentoo qemu 安装记录"
date: "2022-06-26"
description: ""
summary: "Gentoo qemu virt-manager 安装配置"
categories: [  "gentoo","linux" ]
tags: [ "gentoo","linux","kvm"]
---

参考 gentoo wiki：

- [QEMU](https://wiki.gentoo.org/wiki/QEMU)
- [Virt-manager](https://wiki.gentoo.org/wiki/Virt-manager)

## QEMU 内核配置

参考 [QEMU#Kernel](https://wiki.gentoo.org/wiki/QEMU#Kernel)

## USE 标记

> QEMU 是一款开源的模拟器，提供两种使用模式：`user mode` 和 `system mode`。`user mode` 可在 Host 主机下直接执行目标架构程序。`system mode` 可以在Host主机下启动目标架构的操作系统并执行应用程序。

下面的 `softmmu` 对应 `system mode`，`user` 对应 `user mode`

在 `/etc/portage/make.conf` 中添加全局的标记

```
QEMU_SOFTMMU_TARGETS="arm x86_64 sparc"
QEMU_USER_TARGETS="x86_64"
```
 
或者在 `/etc/portage/package.use` 中添加

```text
app-emulation/qemu qemu_softmmu_targets_arm qemu_softmmu_targets_x86_64 qemu_softmmu_targets_sparc
app-emulation/qemu qemu_user_targets_x86_64
```

> 按需添加，使用 `equery u app-emulation/qemu` 查看 `use` 标记。

> 如果要使用 `virt-manager` ，`usbredir` 和 `spice` 也要添加进去。


## 安装

```
emerge --ask app-emulation/qemu
```

添加用户到 `kvm` 组：

```
gpasswd -a <username> kvm
```

## 用法

参考 [QEMU#Command_line](https://wiki.gentoo.org/wiki/QEMU#Command_line)

## 安装 virt-manager

`qemu` 只提供命令行，`virt-manager` 是它的前端应用。

内核配置，参考 [Virt-manager#Kernel](https://wiki.gentoo.org/wiki/Virt-manager#Kernel)

```
[*] Networking support
    Networking Options  --->
        [*] Network packet filtering framework (Netfilter)  --->
            [*] Advanced netfilter configuration
            Core Netfilter Configuration  --->
                <*> "conntrack" connection tracking match support
                <*> CHECKSUM target support
            IPv6: Netfilter Configuration  --->
                <*> ip6tables NAT support

            <*> Ethernet Bridge tables (ebtables) support  --->
                <*> ebt: nat table support
                <*> ebt: mark filter support
        [*] QoS and/or fair queueing  --->
            <*> Hierarchical Token Bucket (HTB)
            <*> Stochastic Fairness Queueing (SFQ)
            <*> Ingress/classifier-action Qdisc
            <*> Netfilter mark (FW)
            <*> Universal 32bit comparisons w/ hashing (U32)
            [*] Actions
            <*>    Traffic Policing
```

安装

```
emerge --ask app-emulation/virt-manager
```

添加用户到组

```
usermod -a -G libvirt <user>
```

取消文件 `/etc/libvirt/libvirtd.conf` 下面几行的注释

```
auth_unix_ro = "none"
auth_unix_rw = "none"
unix_sock_group = "libvirt"
unix_sock_ro_perms = "0777"
unix_sock_rw_perms = "0770"
```

添加开机启动

```shell
rc-update add libvirtd default
```

## 遇到的问题

### libvirtd 启动服务失败

```text
net.wlp2s0                |wlp2s0: CTRL-EVENT-DSCP-POLICY clear_all
net.wlp2s0                |wlp2s0: CTRL-EVENT-DSCP-POLICY clear_all
net.wlp2s0                |nl80211: deinit ifname=wlp2s0 disabled_11b_rates=0
net.wlp2s0                | *   start-stop-daemon: failed to start `/usr/sbin/wpa_supplicant'
net.wlp2s0                | * ERROR: net.wlp2s0 failed to start
```

`libvirtd` 需要 `net` 服务，由于我是直接用 `wpa_supplicant` 联网，并未启用 `net.wlp2s0`。

故在 `/etc/conf.d/libvirtd` 中注释掉下面一行

```bash
#rc_need="net"
```

### Couldn't load target 'REJECT'

`virt-manager` 启用 `NAT` 时报错

```text
Couldn't load target `REJECT':No such file or directory
```

解决: 启用 `REJECT` 相关的内核参数，参考 wiki [iptables](https://wiki.gentoo.org/wiki/Iptables) 。

