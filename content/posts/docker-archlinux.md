---
title: "Docker ArchLinux"
date: "2024-04-18"
description: ""
summary: "快速配置可用的 archlinux 容器"
categories: [ "docker" ]
tags: [ "archlinux" ]
---



## dockerfile

```dockerfile
FROM archlinux:latest as base

ARG NAME="arch"
ARG UID="1000"
ARG MAKEFLAGS="-j16"

RUN useradd -m -s /bin/bash -u ${UID} ${NAME} && \
    mkdir -p /home/${NAME}/.config && \
    chown -R ${NAME}:${NAME} /home/${NAME} && \
    echo "Server = https://mirror.sjtu.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist && \
    pacman -Syu --noconfirm base-devel git && \
    pacman -Scc --noconfirm && \
    echo "${NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "MAKEFLAGS=${MAKEFLAGS}" >> /etc/makepkg.conf

USER ${NAME}
WORKDIR /home/${NAME}


FROM base as yay

RUN git clone "https://aur.archlinux.org/yay-git.git" /tmp/yay && \
    cd /tmp/yay && \
    makepkg -s --noconfirm


FROM base as minimal

COPY --from=yay /tmp/yay /tmp/yay
USER root
RUN pacman -U --noconfirm /tmp/yay/*.pkg.tar.zst && \
    rm /tmp/yay -rf


FROM minimal as regular

RUN pacman -S --noconfirm xorg vim bash-completion


USER ${NAME}
CMD /bin/bash
```

## 构建镜像

```bash-session
$ docker build -t myarch:latest .
```

采用多阶段构建，例如不需要 yay，使用 `--target` 指定阶段：

```bash-session
$ docker build -t myarch:latest . --target base
```

另外 yay 的安装需要从 github 拉取源码，可能需要配置代理，例如：

```
$ docker build -t myarch:latest . \
    --network host \
    --build-arg "HTTP_PROXY=http://127.0.0.1:1080" \
    --build-arg "HTTPS_PROXY=http://127.0.0.1:1080" \
    --build-arg "NO_PROXY=localhost,127.0.0.1"
```

## 创建容器

创建 `setup.sh` ：

```bash
#!/bin/bash

name="arch"
host="king"

docker create \
    -it \
    --name archlinux \
    --privileged \
    --network host \
    -e DISPLAY=$DISPLAY \
    -e GDK_SCALE=2 \
    -e GDK_DPI_SCALE=0.5 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /home/$host/.bashrc:/home/$name/.bashrc:ro \
    -v /home/$host/.fonts:/home/$name/.fonts:ro \
    -v /home/$host/.icons:/home/$name/.icons:ro \
    -v /home/$host/.themes:/home/$name/.themes:ro \
    -v /home/$host/.gtkrc-2.0:/home/$name/.gtkrc-2.0:ro \
    -v /home/$host/.config/gtk-3.0:/home/$name/.config/gtk-3.0:ro \
    -v /home/$host/.config/gtk-2.0:/home/$name/.config/gtk-2.0:ro \
    -v /home/$host/.config/awesome/icons/:/home/$name/.config/awesome/icons/:rw \
    -v /home/$host/Pictures:/home/$name/Pictures:rw \
    -v /home/$host/Github:/home/$name/Github:rw \
    -v /home/$host/Downloads:/home/$name/Downloads:rw \
    -v /home/$host/Shared:/home/$name/Shared:rw \
    -v /home/$host/Work:/home/$name/Work:rw \
    myarch
```

然后执行 `./setup.sh`

## 启动容器

```bash-session
$ docker container start archlinux
```

## 进入容器

```bash-session
$ docker exec -it archlinux bash
```

`.bashrc` 添加如下，终端输入 `al` 即可进入容器：

```shell
function al(){
    if [[ `docker container ls -f "name=archlinux" | grep Up` ]];then
        docker exec -it archlinux bash
    else
        docker container start archlinux
        docker exec -it archlinux bash
    fi
}
```

## 其他

### 容器中切换 root 用户

```bash-session
$ sudo su
```

###  启动图形应用

需要在主机执行：

```bash-session
$ xhost +
```

### 常用软件

仓库：

```text
arm-none-eabi-gcc
arm-none-eabi-newlib
arm-none-eabi-binutils
stlink
bash-completion
```

aur：

```text
gdb-multiarch
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
|pacman -Scc|清除所有缓存|

### yay 常用命令

|命令|说明|
|:--|:--|
|yay|同步并更新仓库和 AUR 的包|
|yay <包名>|搜索 AUR 并安装包|
|yay -S|搜索仓库和 AUR 并安装包|
|yay -Ss|搜索包|
|yay -R|卸载包|
|yay -Rns|卸载包及其依赖|
