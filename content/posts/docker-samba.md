---
title: "Docker Samba"
date: "2023-04-18"
description: ""
summary: "在 docker 中运行 samba"
tags: [ "samba" ]
categories: [ "docker" ]
---

## dockerfile

```dockerfile
FROM ubuntu:latest

LABEL author="king"

EXPOSE 445 139

RUN set -ex && \
    sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list && \
    apt clean && \
    apt update && \
    apt -y install samba && \
    echo "useradd -r -s /usr/sbin/nologin -u \$UID \$NAME &> /dev/null" >> /root/start.sh && \
    echo 'echo "$PASSWD\n$PASSWD" | smbpasswd -a $NAME' >> /root/start.sh && \
    echo "/etc/init.d/smbd start" >> /root/start.sh && \
    echo "/bin/bash" >> /root/start.sh && \
    chmod u+x /root/start.sh

CMD /root/start.sh
```

> 末尾 `/bin/bash` 防止容器直接退出

## 构建镜像

```bash-session
$ docker build -t mysamba:latest .
```

## 配置 Samba

本地创建 `smb.conf` 配置文件，参考 [Samba 安装及配置](../samba-config/)

```text
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
[Shared]
path = /home/king/Shared
security = share
public = yes
writable = yes
write list = king
available = yes
browseable = yes

# 需要用户登录，可读写
[Private]
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

```text
$ docker run -it --rm -d \
    --name samba \
    -e UID=1000 \
    -e NAME=king \
    -e PASSWD=abcd12345 \
    -p 445:445 \
    -p 139:139 \
    -v /home/king/Docker/samba/:/etc/samba:ro \
    -v /home/king:/home/king:rw \
    -v /home/king/Shared:/home/king/Shared:rw \
    mysamba
```

`/home/king/Docker/samba` 为 `smb.conf` 文件所在目录

`/home/king` 和 `/home/king/Public` 这两个目录是在 `smb.conf` 中配置的共享目录。
