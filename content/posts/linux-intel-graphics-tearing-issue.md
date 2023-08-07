---
author: "kingtuo123"
title: "Linux下intel核显驱动问题"
date: "2022-06-06"
description: ""
summary: "intel驱动导致的画面撕裂和冻结"
categories: [  "gentoo","linux" ]
tags: [ "gentoo","linux" ]
---


-  [参考文档1](https://github.com/yshui/picom/wiki/Vsync-Situation)
-  [参考文档2](https://wiki.archlinux.org/title/intel_graphics#Tearing "Intel graphics")

问题描述:
-  使用xf86-video-intel驱动和启用硬件加速会导致画面概率性冻结
-  使用modesetting驱动会导致画面撕裂

## 解决方法
不使用 xf86-video-intel 驱动。

使用 picom 渲染器解决 modesetting 驱动下画面撕裂的问题

修改 `/etc/X11/xorg.conf.d/20-intel.conf`

```X11
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "modesetting"
    Option      "AccelMethod"    "glamor"
    Option      "DRI"            "3"
EndSection 
```

在 picom 配置文件 `~/.config/picom/picom.conf` 中添加

```
vsync = true;
```

在 `~/.xinitrc` 中添加

```bash
picom --experimental-backend &

# 新的版本没有了上面的参数
picom &
```
