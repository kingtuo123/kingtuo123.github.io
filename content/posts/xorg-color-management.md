---
title: "Xorg 色彩管理"
date: "2024-06-04"
description: ""
summary: "xorg color management"
categories: [ "linux" ]
---

参考文章

- [Color management / Gentoo wiki](https://wiki.gentoo.org/wiki/Color_management)
- [ICC profiles / Arch wiki](https://wiki.archlinux.org/title/ICC_profiles)

## 安装

- `colord`：色彩管理服务。
- `xiccd`：LXDE、Xfce 或 i3 等桌面环境不具备与 colord 通信的功能，使用 xiccd 与之通信。

```bash-session
# emerge -av x11-misc/colord x11-misc/xiccd
```


## 配置

拷贝校色文件（ICC Profile）至 `/usr/share/color/icc/colord` 目录下：

```bash-session
# cp Sharp_L24.icm /usr/share/color/icc/colord
```

获取校色文件 `Profile ID`：

```bash-session
# colormgr get-profiles | grep -A1 "Sharp_L24.icm" | grep -i "Profile ID"
Profile ID:    icc-11c20aabd70f8e49dbef2ec0e028e0eb
```

获取显示器 `Device ID`：

```bash-session
# colormgr get-devices | grep "Device ID"
Device ID:     xrandr-DO NOT USE - RTK-Type_C-demoset-1
```

添加校色文件至显示器：

```bash-session
# colormgr device-add-profile "xrandr-DO NOT USE - RTK-Type_C-demoset-1" icc-11c20aabd70f8e49dbef2ec0e028e0eb
```

将校色文件设为显示器的默认：

```bash-session
# colormgr device-make-profile-default "xrandr-DO NOT USE - RTK-Type_C-demoset-1" icc-11c20aabd70f8e49dbef2ec0e028e0eb
```


查看配置是否应用成功：

```bash-session
# colormgr device-get-default-profile "xrandr-DO NOT USE - RTK-Type_C-demoset-1"
Object Path:   /org/freedesktop/ColorManager/profiles/icc_11c20aabd70f8e49dbef2ec0e028e0eb
Owner:         root
Format:        ColorSpace..
Title:         Sharp LQ170 06-04-2024
Qualifier:     RGB..
Type:          display-device
Colorspace:    rgb
Gamma Table:   Yes
System Wide:   Yes
Filename:      /usr/share/color/icc/colord/Sharp_L24.icm
Profile ID:    icc-11c20aabd70f8e49dbef2ec0e028e0eb
Metadata:      FILE_checksum=11c20aabd70f8e49dbef2ec0e028e0eb
```

最后，确保 `colord` 和 `xiccd` 都设置为自动启动。编辑 `.xinitrc`，添加：

```
xiccd &
```

`xiccd` 会自动启动 `colord`，所以上面没有添加 `colord`。

## 支持 ICC 配置文件的应用程序

使能 USE 标志 `lcms`：Add lcms support (color management engine)

### GIMP

`Edit` -> `Preferences` -> `Color Management` -> `Monitor profile`

### MPV

命令行参数：

```bash-session
# mpv --icc-profile=/usr/share/color/icc/colord/Sharp_L24.icm
```

配置文件 `~/.config/mpv/mpv.conf`：

```
icc-profile=/usr/share/color/icc/colord/Sharp_L24.icm
```

或者使用 `--icc-profile-auto=yes` 参数

### FIREFOX

打开 `about:config` 配置如下：

- `gfx.color_management.display_profile` = /usr/share/color/icc/colord/Sharp_L24.icm
- `gfx.color_management.enablev4` = true
- `gfx.color_management.mode` = 1


