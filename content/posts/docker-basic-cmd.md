---
title: "Docker 基本命令"
date: "2022-03-11"
description: ""
summary: "Docker 镜像/容器常用的一些命令及说明"
categories: [ "docker" ]
tags: [ "docker" ]
---


## docker镜像

### 镜像仓库源

编辑文件 `/etc/docker/daemon.json`：

```
{
    "registry-mirrors": [
        "https://docker.nju.edu.cn",
        "https://dockerproxy.com"
    ]
}
```

修改后需要重启 docker

### 拉取镜像

```
docker image pull <repository>:<tag>
```

### 查看镜像

```
docker image ls -a
docker images
```

### 构建镜像

在 `dockerfile` 同目录下执行：

```
docker build -t myimage:latest .
```

### 删除镜像

```
docker image rm <name>:<tag>
docker image rm <name|id>
docker rmi <name|id>
```

`id` 不用补全，比如 `ba6acccedd29` ，只需输入 `ba` ，只要 `id` 前几位没和其他镜像重复。

当镜像已有创建的容器时，无法删除。可以使用 `-f` 参数强制删除。

### 提交镜像

首先你在基础镜像生成的容器中做了修改后，使用 `commit` 命令可以生成一个新的镜像，这个镜像相较于基础镜像多了一层 Layer（你在容器内做的所有修改都打包成了 Layer）

```
docker commit -m "some info"
```

生成的镜像可以用 `image` 命令查看到，`commit` 之后你可以使用 `push` 命令推送到远端仓库

## docker容器

### 创建容器

以下命令会自动创建一个容器并运行 bash，也可以用 `create` 命令创建容器。

```
docker container run --name <name> -it --rm <repository>:<tag> bash
```

`run` 常用参数：
- \-\-name：指定容器名称
- -i：开启标准输入
- -t：分配伪终端
- \-\-rm：退出容器后自动删除容器，多用于一次性测试
- -u：指定用户，\<name\|uid\>
- -w：指定工作目录
- -v：挂载路径，格式 -v \<host path>:\<container path>
- -p：指定端口映射，格式 -p \<host port>:\<container port>
- -P：随机端口映射，docker 会随机映射一个端口到内部容器的网络端口
- -d：后台运行容器，并返回容器 ID，类似命令后加 &
- -e：设置环境变量，格式 -e \<variables1>=\<variables2>
- \-\-privileged：扩大容器权限，在容器内可以看到 host 的更多设备、可 mount 挂载设备
- \-\-network：连接指定网络，系统预定义的有 bridge（默认）、host、container、none 四种

|网络|说明|
|:--|:--|
|bridge|虚拟网卡、网桥，独立IP与端口|
|host|使用宿主机网卡、IP与端口|
|container|与指定容器共享IP与端口|
|none|关闭网络功能|

### 启动容器

```
docker container start <name|container id>
```

`start` 后面可跟多个 `id` 

### 进入容器

```
docker container attach <name|container id>
docker container exec -it <name|container id> bash
```

`attach` 在退出后 **容器会停止**，相当于进入当前终端

`exec` 在退出后 **容器不会停止**，相当于新开了一个终端

### 停止容器

```
docker container stop <name|container id>
docker container kill <name|container id>
```

> `stop` 先发送 SIGTERM 信号，容器内程序可以做退出前的准备工作，一段时间之后再发送 SIGKILL 信号。
>
> `kill` 发送 SIGKILL 信号，应用程序直接退出。

立即停止所有容器

```
docker kill `docker ps -q`
```

### 查看容器

列出所有容器

```
docker container ls -a
```

### 删除容器

```
docker container rm <name|container id>
```

使用 `prune` 可以删除所有已停止的容器

```
docker container prune
```

### 文件拷贝

拷贝无需容器运行，只要该容器存在即可，以下命令从容器拷贝至主机

```
docker container cp <container id|name>:<container path> <host path>
```
