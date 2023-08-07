---
author: "kingtuo123"
title: "wpa_supplicant"
date: "2023-03-26"
description: ""
summary: "使用 wpa_supplicant 连接无线网络，及开机启动"
tags: [ "gentoo" ]
categories: [ "gentoo" ]
---


- 参考文章：
  - [Gentoo wiki / wpa-supplicant](https://wiki.gentoo.org/wiki/Wpa_supplicant)


## 配置

编辑 `/etc/wpa_supplicant/wpa_supplicant.conf`

```bash
# 允许 wheel 组的用户控制 wpa_supplicant
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel

# 允许 wpa_gui / wpa_cli 可写该文件
update_config=1
```

添加无线网络：

```
# wpa_passphrase 网络名称 密码 >> /etc/wpa_supplicant/wpa_supplicant.conf
```


## 使用 OpenRC

编辑 `/etc/conf.d/net`， 替换 `wlp2s0` 为你的无线网卡名称：

```
modules_wlp2s0="wpa_supplicant"
config_wlp2s0="dhcp"
```


添加开机启动：

```
# cd /etc/init.d
# ln -s net.lo net.wlp2s0
# rc-update add net.wlp2s0 default
# rc-update add dhcpd default
```
