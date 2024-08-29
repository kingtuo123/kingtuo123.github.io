---
title: "使用 wpa_supplicant 连接无线网络"
date: "2023-03-26"
description: ""
summary: ""
categories: [ "linux" ]
tags: [ "wpa" ]
---


参考文章：

- [Gentoo wiki / wpa-supplicant](https://wiki.gentoo.org/wiki/Wpa_supplicant)
- [Arch wiki / wpa-supplicant](https://wiki.archlinux.org/title/Wpa_supplicant)
- [wpa\_supplicant.conf(5)](https://www.daemon-systems.org/man/wpa_supplicant.conf.5.html)


## 配置及连接

编辑 `/etc/wpa_supplicant/wpa_supplicant.conf`

```bash
# 允许 wheel 组的用户控制 wpa_supplicant
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel

# 允许 wpa_gui / wpa_cli 可写该文件
update_config=1
```

添加无线网络，名称不能包含中文字符或其它特殊字符，只能是 `ascii` 字符：

```bash-session
# wpa_passphrase 网络名称 密码 >> /etc/wpa_supplicant/wpa_supplicant.conf
```

上面命令会在 `wpa_supplicant.conf` 中添加如下内容：

```bash
network={
        ssid="wifi1"
        psk=6ad077ee70b4541967ee9c0bf0dc902
}
```

如果你添加了多个网络，可以使用 `priority` 变量设置连接优先级，数字越大，优先级越高：

```bash
network={
        ssid="wifi1"
        psk=6ad077ee70b4541967ee9c0bf0dc90
        priority=10
}
```

> 其它可用的变量见 [wpa\_supplicant.conf(5)](https://www.daemon-systems.org/man/wpa_supplicant.conf.5.html) 中的 `NETWORK BLOCKS` 一节。

最后，连接网络 + 获取IP：

```bash-session
# wpa_supplicant -B -i wlp4s0 -c /etc/wpa_supplicant/wpa_supplicant.conf
# dhclient -i wlp4s0 -v
```

 

## 开机启动 - OpenRC

编辑 `/etc/conf.d/net`， 替换 `wlp4s0` 为你的无线网卡名称：

```bash
modules_wlp4s0="wpa_supplicant"
config_wlp4s0="dhcp"
```


添加开机启动：

```bash-session
# cd /etc/init.d
# ln -s net.lo net.wlp4s0
# rc-update add net.wlp4s0 default
```

`dhcpd` 不用添加，由 `wpa_supplicant` 启动

## wpa\_cli 交互式命令行工具

直接在终端执行 `wpa_cli` 命令，即可进入交互模式：

```bash-session
$ wpa_cli -i wlp4s0
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

```bash-session
$ wpa_cli -i wlp4s0 list_networks
```

## ssid 中文字符无法显示

```bash-session
$ wpa_cli -i wlp4s0 scan
$ wpa_cli -i wlp4s0 scan_result | sed 's@\\@\\\\@g' | xargs -L1 echo -e
```

或者使用 `iw` 命令扫描：

```bash-session
# iw dev wlp4s0 scan | grep -i ssid | sed 's@\\@\\\\@g' | xargs -L1 echo -e
```

找到对应的中文 `ssid` 后，在 `wpa_cli` 中按之前的步骤操作。

> 注意：不能直接在 `wpa_supplicant.conf` 中添加中文字符的 `ssid`。
