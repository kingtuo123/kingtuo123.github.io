---
title: "Docker 常用命令"
date: "2022-03-11"
description: ""
summary: "Docker 镜像/容器常用的一些命令及说明"
categories: [ "linux" ]
tags: [ "docker" ]
---


## Docker 镜像

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

```bash-session
$ docker image pull <repository>:<tag>
```

### 查看镜像

```bash-session
$ docker image ls -a
$ docker images
```

### 构建镜像

在 `dockerfile` 同目录下执行：

```bash-session
$ docker build -t myimage:latest .
```

### 删除镜像

```bash-session
$ docker image rm <name>
$ docker rmi <name>
```

`id` 不用补全，比如 `ba6acccedd29` ，只需输入 `ba` ，只要 `id` 前几位没和其他镜像重复。

当镜像已有创建的容器时，无法删除。可以使用 `-f` 参数强制删除。

### 提交镜像

首先你在基础镜像生成的容器中做了修改后，使用 `commit` 命令可以生成一个新的镜像，这个镜像相较于基础镜像多了一层 Layer（你在容器内做的所有修改都打包成了 Layer）

```bash-session
$ docker commit -m "some info"
```

生成的镜像可以用 `image` 命令查看到，`commit` 之后你可以使用 `push` 命令推送到远端仓库

## Docker 容器

### 创建容器

以下命令会自动创建一个容器并运行 bash，也可以用 `create` 命令创建容器。

```bash-session
$ docker container run --name <name> -it --rm <repository>:<tag> bash
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

```bash-session
$ docker container start <name|id>
```

`start` 后面可跟多个 `id` 

### 进入容器

```bash-session
$ docker container attach <name|id>
$ docker container exec -it <name|id> bash
```

- `attach` 在退出后 **容器会停止**，相当于进入当前终端
- `exec` 在退出后 **容器不会停止**，相当于新开了一个终端

### 停止容器

```bash-session
$ docker container stop <name|id>
$ docker container kill <name|id>
```

- `stop` 先发送 SIGTERM 信号，容器内程序可以做退出前的准备工作，一段时间之后再发送 SIGKILL 信号。
- `kill` 发送 SIGKILL 信号，应用程序直接退出。

立即停止所有容器：

```bash-session
$ docker kill `docker ps -q`
```

### 查看容器

```bash-session
$ docker container ls -a
```

### 删除容器

```bash-session
$ docker container rm <name|id>
```

使用 `prune` 可以删除所有已停止的容器：

```bash-session
$ docker container prune
```

### 文件拷贝

拷贝无需容器运行，只要该容器存在即可，以下命令从容器拷贝至主机：

```bash-session
$ docker container cp <container_name>:<container_path> <host_path>
```



## Docker 数据卷

### 创建数据卷

```bash-session
$ docker volume create my-vol
```

### 挂载数据卷
指定路径挂载：

```bash-session
$ docker run -it -v <宿主机路径>:<容器内路径> nginx
```

具名挂载，主机路径 `/var/lib/docker/volumes/<卷名>/_data`，没有该卷则自动创建：

```bash-session
$ docker run -it -v <卷名>:<容器内路径> nginx
```

匿名挂载，主机路径 `/var/lib/docker/volumes/<一串随机字符>/_data`，自动创建卷，名称是随机字符：

```bash-session
$ docker run -it -v <容器内路径> nginx
```

### 查看数据卷

列出数据卷：

```bash-session
$ docker volume ls
DRIVER    VOLUME NAME
local     0b60738f27c8adc38559981ad727d36a722b70b1736b20d8f3020ffc88d202b2
local     21f61aa404a0fe9c15a6a6ad4a6a056a0ee009a98af593c2092a14062fa7c02e
local     test

前两个是匿名挂载，卷名是随机字符
test 是具名挂载
```

查看卷详情：

```shell-session
$ docker volume inspect <卷名>
```

### 读写权限

`ro` 只读，容器对该数据卷只读：

```shell-session
$ docker run -d -v /home/nginx:/etc/nginx:ro nginx
```

`rw` 读写，容器对该数据卷可读写：

```shell-session
$ docker run -d -v /home/nginx:/etc/nginx:rw nginx
```

### 数据卷共享

```shell-session
$ docker run -it --name docker01 -v volume01 ubuntu bash
$ docker run -it --name docker02 --volume-from docker01 ubuntu bash
```

上面的命令中 `docker02` 与 `docker01` 共享 `volume01` ，用到参数 `--volume-from` 

我们来查看下两个容器数据卷的关系：

```shell-session
$ docker inspect docker01 docker02 | grep volume
"Type": "volume",
"Source": "/var/lib/docker/volumes/505a478d050df91857b156119a9d83626614ffb3962d1ac3459d14756c5544dc/_data",
"Destination": "volume01",
"volume01": {}
"Type": "volume",
"Source": "/var/lib/docker/volumes/505a478d050df91857b156119a9d83626614ffb3962d1ac3459d14756c5544dc/_data",
"Destination": "volume01",
"volume01": {}
```

可以看到两个容器匿名挂载的宿主机路径是一样的










## Docker 缓存清理

查看磁盘占用情况：

```bash-session
$ docker system df
```

清理所有停止的容器、网络、废弃镜像、数据卷、构建缓存：

```bash-session
$ docker system prune
```

只清理构建缓存：

```bash-session
$ docker buildx prune
$ docker builder prune
```
