---
title: "xHiDPI"
date: "2023-03-22"
description: ""
summary: "Linux 非桌面环境在 4k 分辨率下配置 200% 缩放"
tags: [ "linux" ]
categories: [ "linux" ]
---

- 参考文章
  - [Archwiki HiDPI](https://wiki.archlinux.org/title/HiDPI)

编辑 `.xinitrc`，添加：

```
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5

xrdb -merge .Xresources
```


编辑 `.Xresources`

```
Xft.dpi: 192
Xcursor.size: 48
!Xcursor.theme: DMZ-Black
Xcursor.theme: Bibata-Modern-Ice

Xft.autohint: 0
Xft.lcdfilter:  lcddefault
Xft.hintstyle:  hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
```

> `Xcursor.theme` 用的鼠标主题需要支持 HIDPI
