---
title: "Gentoo CH340 串口驱动"
date: "2021-05-24"
description: ""
summary: "内核驱动及权限配置"
categories: [ "linux","gentoo" ]
tags: [ "gentoo","linux" ]
---

- 参考文章：[Gentoo Wiki/Arduino](https://wiki.gentoo.org/wiki/Arduino)

## 启用内核选项

```
Device Drivers  --->
    [*] USB support ---> 
      <*> USB Serial Converter support --->
        <*> USB Winchiphead CH341 Single Port Serial Driver
```

> 串口设备一般是 `/dev/ttyUSB0`

## 非 ROOT 用户访问权限

添加用户到 `dialout` 组：

```
# gpasswd -a <username> dialout
```
