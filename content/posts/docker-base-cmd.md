---
title: "Docker基本命令"
date: "2022-03-11"
description: ""
summary: "Docker 镜像/容器常用的一些命令及说明"
tags: [ "docker" ]
categories: [ "docker" ]
---


## docker镜像

### 拉取镜像

```bash
docker image pull <repository>:<tag>
```

### 查看镜像

```bash
docker image ls -a
docker images
```

### 删除镜像

```bash
docker image rm <repository>:<tag>
docker image rm <image id>
```

id不用补全，比如 `ba6acccedd29` ，只需输入 `ba` ，只要id前几位没和其他镜像重复。\
当镜像已有创建的容器时，无法删除。可以使用-f参数强制删除。

### 提交镜像
首先你在基础镜像生成的容器中做了修改后，使用 `commit` 命令可以生成一个新的镜像，这个镜像相较于基础镜像多了一层Layer（你在容器内做的所有修改都打包成了Layer）

```bash
docker commit -m "some info"
```

生成的镜像可以用 `image` 命令查看到，`commit` 之后你可以使用 `push` 命令推送到远端仓库

## docker容器

### 创建容器

以下命令会自动创建一个容器并运行bash，也可以用 `create` 命令创建容器。

```bash
docker container run --name <name> -it --rm <repository>:<tag> bash
```

`run` 常用参数：
- \-\-name：指定容器名称
- -i：开启标准输入
- -t：分配伪终端
- \-\-rm：退出容器后自动删除容器，多用于一次性测试
- -v：挂载路径，格式 -v \<host path>:\<container path>
- -p：指定端口映射，格式 -p \<host port>:\<container port>
- -P：随机端口映射，docker会随机映射一个端口到内部容器的网络端口
- -d：后台运行容器，并返回容器ID，类似命令后加&
- -e：设置环境变量，格式 -e \<variables1>=\<variables2>
- \-\-privileged：扩大容器权限，在容器内可以看到host的更多设备、可mount挂载设备
- \-\-network：连接指定网络，系统预定义的有bridge(默认)、host、container、none四种

|网络|说明|
|:--|:--|
|bridge|虚拟网卡、网桥，独立IP与端口|
|host|使用宿主机网卡、IP与端口|
|container|与指定容器共享IP与端口|
|none|关闭网络功能|

### 启动容器

```bash
docker container start <name|container id>
```

`start` 后面可跟多个 `id` 

### 进入容器

```bash
docker container attach <name|container id>
docker container exec -it <name|container id> bash
```

`attach` 在退出容器后会停止容器，`exec` 不会

`attach` 相当于进入当前终端，`exec` 相当于新开了一个终端

### 停止容器

```bash
docker container stop <name|container id>
docker container kill <name|container id>
```

`stop` 先发送SIGTERM信号，容器内程序可以做退出前的准备工作，一段时间之后再发送SIGKILL信号。

`kill` 发送SIGKILL信号，应用程序直接退出。

### 查看容器
列出所有容器

```bash
docker container ls -a
```

### 删除容器

```bash
docker container rm <name|container id>
```

使用 `prune` 可以删除所有已停止的容器

```bash
docker container prune
```

### 文件拷贝
拷贝无需容器运行，只要该容器存在即可，以下命令从容器拷贝至主机

```bash
docker container cp <container id|name>:<container path> <host path>
```
