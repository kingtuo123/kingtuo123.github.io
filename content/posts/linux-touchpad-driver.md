---
title: "Gentoo touchpad 驱动"
date: "2022-06-07"
description: ""
summary: "Gentoo touchpad driver installation and configure"
categories: [  "gentoo","linux" ]
tags: [ "gentoo","linux" ]
---


## 安装
```shell
$ emerge -av xf86-input-mtrack
```
添加用户到 `input` 组

```shell
$ gpasswd -a <user> input
```

## 配置
添加文件 **/etc/X11/xorg.conf.d/40-touchpad.conf**
```bash
Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Option "Tapping" "True"
    Option "TappingDrag" "True"
    Option "NaturalScrolling" "False"
    Option "ScrollUpButton" "5"
    Option "ScrollDownButton" "4"
    Driver "mtrack"
    Option "TransformationMatrix" "0.4 0 0 0 0.4 0 0 0 1"
EndSection
```
各项参数参考[这里](https://github.com/p2rkw/xf86-input-mtrack/)

## 启用/禁用触摸板
获取设备 id
```bash
# 这里id是14
$ xinput list | grep -i touchpad
⎜   ↳ SynPS/2 Synaptics TouchPad                id=14   [slave  pointer  (2)]
```
查看设备属性
```bash
$ xinput list-props 14
Device 'SynPS/2 Synaptics TouchPad':
    # 这里可以用 Device Enabled (186) 来启用或禁用触摸板
    Device Enabled (186):   0
    Device Accel Profile (318):     0
    Device Accel Constant Deceleration (319):       1.000000
    Device Accel Adaptive Deceleration (320):       1.000000
    Device Accel Velocity Scaling (321):    10.000000
    Trackpad Disable Input (356):   0
    Trackpad Sensitivity (357):     1.000000
    Trackpad Touch Pressure (358):  5, 5
    Trackpad Button Settings (359): 1, 1
    Trackpad Button Emulation Settings (360):       0, 1, 100
    ......
```
启用触摸板
```bash
$ input set-prop 14 "Device Enabled" 1
# 或者使用属性id
$ xinput set-prop 14 186 1
```
禁用触摸板
```bash
$ input set-prop 14 "Device Enabled" 0
$ xinput set-prop 14 186 0
```
其他参数参照上面方法修改
