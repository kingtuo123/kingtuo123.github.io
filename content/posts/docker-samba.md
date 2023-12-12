---
title: "Docker Samba"
date: "2023-04-18"
description: ""
summary: "在 docker 中运行 samba"
tags: [ "samba" ]
categories: [ "docker" ]
---

## Dockerfile 

```dockerfile
FROM ubuntu:latest

LABEL author="king"

EXPOSE 445 139

RUN set -ex && \
        sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list && \
        apt clean && \
        apt update && \
        apt -y install samba

CMD /etc/init.d/smbd start && /bin/bash
```

> `&& /bin/bash` 防止容器直接退出

## 构建镜像

```
$ docker build -t mysamba:latest .
```

## 添加 Samba 用户

进入容器：

```
$ docker run -it --rm \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    -v /var/lib/samba/private/:/var/lib/samba/private/:rw \
    mysamba /bin/bash
```



> 注意：添加的 samba 用户是要已存在的 linux 用户，所以要映射`passwd` 和 `group` 两个文件。
当然也可以不映射直接在容器内新增用户/组。

> `/var/lib/samba/private/` 目录存储了 samba 的用户信息及密码等数据，如果使用一次性的容器（\-\-rm）需要映射该目录。

添加 samba 用户：

```
# smbpasswd -a king
```

打印用户列表：

```
# pdbedit -L
king:1000:
```


## 配置 Samba

本地创建 `/etc/samba/smb.conf` 配置文件，参考 [Samba 安装及配置](../samba-config/)

```
[global]
workgroup = Home
netbios name = king's laptop
server string = king's SambaServer
display charset = UTF8
#interfaces = wlp2s0
#hosts allow = 192.168.1.
deadtime = 10
log file = /var/log/samba/log.%m
max log size = 50
map to guest = Bad User
max connections = 0

# 可guest登录，可读，指定用户可写
[public]
path = /home/king/Public
security = share
public = yes
writable = yes
write list = king
available = yes
browseable = yes

# 需要用户登录，可读写
[private]
path = /home/king
public = no
valid users = king
create mask = 0664
directory mask = 0775
available = yes
browseable = yes
writable = yes
write list = king
```

## 运行容器

```
$ docker run -it --rm -d \
    --name samba \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    -v /etc/samba:/etc/samba:ro \
    -v /var/lib/samba/private/:/var/lib/samba/private/:rw \
    -p 445:445 \
    -p 139:139 \
    -v /home/king:/home/king:rw \
    -v /home/king/Public:/home/king/Public:rw \
    mysamba
```

`/home/king` 和 `/home/king/Public` 这两个目录是在 `smb.conf` 中配置的共享目录。
