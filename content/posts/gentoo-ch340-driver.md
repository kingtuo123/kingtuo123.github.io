---
author: "kingtuo123"
title: "Gentoo ch340 驱动"
date: "2021-05-24"
description: ""
summary: "gentoo 配置 ch340 串口驱动"
categories: [ "linux","gentoo" ]
tags: [ "gentoo","linux" ]
---

> 参考 [Gentoo Wiki/Arduino](https://wiki.gentoo.org/wiki/Arduino)

## 启用内核选项

```text
Device Drivers  --->
    [*] USB support ---> 
      <*> USB Serial Converter support --->
        <*> USB Winchiphead CH341 Single Port Serial Driver
```

重新编译内核。

重启后连接设备，设备名为 **/dev/ttyUSB0** 

## 非ROOT用户访问权限

添加用户到 **dialout** 组

```text
gpasswd -a larry dialout
```
