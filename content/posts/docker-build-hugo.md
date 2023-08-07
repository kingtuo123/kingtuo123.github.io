---
title: "Docker hugo"
date: "2023-05-05"
description: ""
summary: "dockerfile 构建 hugo 镜像"
categories: [ "docker" ]
tags: [ "docker" ]
---


## Dockerfile

创建 `Dockerfile` ：

```dockerfile
FROM ubuntu:latest

LABEL author="king"

EXPOSE 1313

RUN set -ex && \
        sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list && \
        apt clean && \
        apt update && \
        apt -y install hugo

WORKDIR /src/hugo

CMD hugo server --bind 0.0.0.0
```

> hugo 必须 `--bind` 绑定 `0.0.0.0`。
> `0.0.0.0` 代表的是本机所有ip地址，不管你有多少个网口，多少个ip，如果监听本机的 `0.0.0.0` 上的端口，就等于监听机器上的所有 ip 端口。

> `127.0.0.1` 是一个环回地址。并不表示“本机”。`0.0.0.0` 才是真正表示“本网络中的本机”。

## 构建

```bash
$ docker build -t myhugo:latest .
```

## 运行容器

`cd` 到你的网站根目录

```bash
$ docker run -it --rm -p 1313:1313 -v $PWD:/src/hugo myhugo
```



查看绑定的端口

```bash
$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS             PORTS                    NAMES
45c23e0f5112   myhugo          "hugo server -D --bi…"   8 minutes ago   Up 8 minutes       0.0.0.0:1313->1313/tcp   jolly_morse
```
