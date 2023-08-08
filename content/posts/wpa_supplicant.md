---
title: "wpa_supplicant"
date: "2023-03-26"
description: ""
summary: "使用 wpa_supplicant 管理无线网络"
categories: [ "linux", "cmd" ]
tags: [ "" ]
---


- 参考文章：
  - [Gentoo wiki / wpa-supplicant](https://wiki.gentoo.org/wiki/Wpa_supplicant)
  - [Arch wiki / wpa-supplicant](https://wiki.archlinux.org/title/Wpa_supplicant)
  - [wpa_supplicant.conf(5)](https://www.daemon-systems.org/man/wpa_supplicant.conf.5.html)


## 配置

编辑 `/etc/wpa_supplicant/wpa_supplicant.conf`

```bash
# 允许 wheel 组的用户控制 wpa_supplicant
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel

# 允许 wpa_gui / wpa_cli 可写该文件
update_config=1
```

添加无线网络，名称不能包含中文字符或其它特殊字符，只能是 `ascii` 字符：

```
# wpa_passphrase 网络名称 密码 >> /etc/wpa_supplicant/wpa_supplicant.conf
```

上面命令会在 `wpa_supplicant.conf` 中添加如下内容：

```
network={
        ssid="wifi1"
        psk=6ad077ee70b4541967ee9c0bf0dc902
}
```

如果你添加了多个网络，可以使用 `priority` 变量设置连接优先级，数字越小，优先级越高：

```
network={
        ssid="wifi1"
        psk=6ad077ee70b4541967ee9c0bf0dc90
        priority=1
}
```

> 其它可用的变量见 [wpa_supplicant.conf(5)](https://www.daemon-systems.org/man/wpa_supplicant.conf.5.html) 中的 `NETWORK BLOCKS` 一节。

最后，连接网络 + 获取IP：

```
# wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
# dhclient -i wlan0 -v
```

 

## 开机启动（OpenRC）

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

## wpa_cli 交互式命令行工具

直接在终端执行 `wpa_cli` 命令，即可进入交互模式：

```bash-session
$ wpa_cli -i wlan0
Interactive mode
> help           # 列出所有指令，及其用法
略...
> list_networks  # 打印已添加的网络
network id / ssid / bssid / flags
0       wifi1    any
1       wifi2    any     [CURRENT]
> scan           # 扫描网络
OK
<3>CTRL-EVENT-SCAN-STARTED
<3>CTRL-EVENT-SCAN-RESULTS
> scan_results   # 查看扫描结果
1c:16:a1:12:1d:a8       5765    -27     [WPA-PSK-CCMP][WPA2-PSK-CCMP][ESS]      wifi1
10:1b:13:d4:14:6c       5200    -62     [WPA-PSK-CCMP][WPA2-PSK-CCMP][ESS]      wifi2
1c:16:a7:12:4d:a6       2412    -23     [WPA-PSK-CCMP][WPA2-PSK-CCMP][ESS]      wifi3
> add_network    # 添加网络
2
<3>CTRL-EVENT-NETWORK-ADDED 2
> set_network 2 ssid "wifi3"       # 设置网络2的ssid (配置文件中 network 的 ssid 变量)
> set_network 2 psk "passphrase"   # 设置网络2的密码
> enable_network 2                 # 使能网络2
> save_config                      # 保存到配置文件
> select_network 2                 # 连接到网络2
```

非交互模式，直接在命令后面跟指令，例如：

```console
$ wpa_cli -i wlan0 list_networks
```

## ssid 中文字符无法显示

用下面两行命令其中一个就行：

```
$ wpa_cli -i wlan0 scan_result | sed "s/\\\/\\\\\\\/g" | xargs -L1 echo -e
# iw dev wlan0 scan | grep -i ssid |sed "s/\\\/\\\\\\\/g" | xargs -L1 echo -e
```

找到对应的中文 `ssid` 后，在 `wpa_cli` 中按上面的步骤操作。

> 注意：不能直接在 `wpa_supplicant.conf` 中添加中文字符的 `ssid`。
