---
author: "kingtuo123"
title: "Docker 运行 GUI 应用"
date: "2023-08-06"
description: ""
summary: "Note"
tags: [ "docker" ]
categories: [ "docker" ]
---


```
docker run -it --name arch \
    --privileged \
    --network host \
    -v /etc/localtime:/etc/localtime:ro \
    -v /dev/shm:/dev/shm \
    -v /etc/machine-id:/etc/machine-id \
    -v /run/user/$uid/pulse:/run/user/$uid/pulse \
    -v /var/lib/dbus:/var/lib/dbus \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    -e GDK_SCALE=2 \
    -e GDK_DPI_SCALE=1 \
    -e XMODIFIERS="@im=fcitx" \
    -e QT_IM_MODULE="fcitx" \
    -e GTK_IM_MODULE="fcitx" \
    archlinux /bin/bash




```

```
useradd -u 1000 king
passwd king
sed -i '1i Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
pacman -Syyu
pacman -S sudo
visudo
%king ALL=(ALL) NOPASSWD:ALL

pacman -S base-devel
pacman -S git
cd /opt
git clone https://aur.archlinux.org/yay.git
chown -R king:king ./yay
cd yay
makepkg -si
```
