---
title: "Docker ArchLinux"
date: "2024-04-18"
description: ""
summary: "快速安装并配置可用的 archlinux"
categories: [ "docker" ]
tags: [ "archlinux" ]
---



## dockerfile

```dockerfile
FROM archlinux:latest

LABEL author="king"

ARG NAME="arch"
ARG PASSWD="linux"
ARG UID="1000"
ARG MAKEFLAGS="-j16"
ARG INSTALL_YAY_SH="/home/${NAME}/install-yay.sh"
ARG INSTALL_APP_SH="/home/${NAME}/install-app.sh"

RUN set -ex && \
    sed -i '1 i Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist && \
    pacman -Syyu --noconfirm && \
    pacman -S --noconfirm vim git base-devel && \
    useradd -m -s /bin/bash -u ${UID} ${NAME} && \
    echo ${PASSWD} | passwd -s ${NAME} && \
    echo "${NAME}	ALL=(ALL)	ALL" >> /etc/sudoers && \
    echo "MAKEFLAGS=${MAKEFLAGS}" >> /etc/makepkg.conf && \
    chown ${NAME}:${NAME} /home/${NAME} && \
    echo "git clone https://aur.archlinux.org/yay-git.git && cd yay-git && makepkg -si && cd ~" >> ${INSTALL_YAY_SH} && \
    chmod u+x ${INSTALL_YAY_SH} && chown ${NAME}:${NAME} ${INSTALL_YAY_SH} && \
    echo "sudo pacman -S hugo" >> ${INSTALL_APP_SH} && \
    chmod u+x ${INSTALL_APP_SH} && chown ${NAME}:${NAME} ${INSTALL_APP_SH}
CMD /bin/bash
```

## 构建镜像

```bash-session
$ docker build -t myarch:latest .
```

## 创建容器

```text
$ name="arch" && docker create \
    -it \
    --name archlinux \
    -u arch \
    --privileged \
    --network host \
    -w /home/$name \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /home/king/.bashrc:/home/$name/.bashrc:ro \
    -v /home/king/.fonts:/home/$name/.fonts:ro \
    -v /home/king/.icons:/home/$name/.icons:ro \
    -v /home/king/.themes:/home/$name/.themes:ro \
    -v /home/king/.gtkrc-2.0:/home/$name/.gtkrc-2.0:ro \
    -v /home/king/.config/gtk-3.0:/home/$name/.config/gtk-3.0:ro \
    -v /home/king/.config/gtk-2.0:/home/$name/.config/gtk-2.0:ro \
    -v /home/king/Github:/home/$name/Github:rw \
    -v /home/king/Downloads:/home/$name/Downloads:rw \
    -v /home/king/Shared:/home/$name/Shared:rw \
    -v /home/king/Work:/home/$name/Work:rw \
    myarch
```

## 启动容器

```bash-session
$ docker container start archlinux
```

## 进入容器

```bash-session
$ docker exec -it archlinux bash
```

定义别名，快速进入：

```bash
alias al="docker exec -it archlinux bash"
```

## 安装 YAY 和其他软件

```bash-session
$ ./install-yay.sh
$ ./install-app.sh
```

## 其他

### 容器中切换 root 用户

```bash-session
$ sudo su
```

### 常用软件包列表

```text
hugo cmake 
```

### pacman 常用命令

参考：[Arch Linux 的 pacman 命令入门](https://linux.cn/article-13099-1.html)

|命令|说明|
|:--|:--|
|pacman -Syu|同步仓库并升级软件包|
|pacman -Ss|在数据库中搜索包|
|pacman -S|安装软件包|
|pacman -R|卸载包及其依赖|
|pacman -Qdtq \| pacman -Rs -|删除系统中无用依赖项|

- S 代表同步
- y 代表更新本地仓库
- u 代表升级软件包

### yay 常用命令

|命令|说明|
|:--|:--|
|yay|同步并更新仓库和 AUR 的包|
|yay <包名>|搜索 AUR 并安装包|
|yay -S|搜索仓库和 AUR 并安装包|
|yay -Ss|搜索包|
|yay -R|卸载包|
|yay -Rns|卸载包及其依赖|
