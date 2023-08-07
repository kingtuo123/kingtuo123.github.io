---
author: "kingtuo123"
title: "Linux 下使用 adb 工具"
date: "2022-08-15"
summary: "常用 ADB 命令及使用"
description: ""
tags: [ "linux" ]
math: false
categories: [ "linux"  ]
---

- 参考 [Android/adb](https://wiki.gentoo.org/wiki/Android/adb)

## 安装

### 安装 ADB

```text
# emerge --ask dev-util/android-tools
```
### 检测设备

首先确保手机开启 USB 调试功能，然后执行下面命令，检测成功后会列出设备：

```text
$ adb devices

List of devices attached 
8NH7N17B0XX9898        device
```

非 ROOT 用户使用 ADB：

```text
# gpasswd -a <username> plugdev 
```

### 进入 shell

```text
$ adb shell
```

## 连接多个设备

使用 `-s` 参数指定设备

```text
$ adb devices

List of devices attached
9QZ7N11B0ZX8999        device
8NH7N17B0XX9898        device
```

```text
$ adb -s <device̠-number> shell
```

## 常用命令

|命令|说明|
|:--|:--|
|adb device|查看连接设备|
|adb install \< apk name \>|安装应用|
|adb uninstall \< pak name \>|卸载应用|
|adb shell pm list packages|列出手机装的所有 app 的包名|
|adb shell pm list packages -3|列出除了系统应用的第三方应用包名|
|adb shell pm clear \< pak name \>|清除应用数据与缓存|
|adb shell pm disable-user \< pak name \>|禁用应用|
|adb shell pm enable \< pak name \>|启用应用|
