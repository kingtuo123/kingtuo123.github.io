---
author: "kingtuo123"
title: "Dockerfile"
date: "2022-06-16"
description: ""
summary: "dockerfile 常用指令"
categories: [  "docker" ]
tags: [ "docker" ]
---

参考文档

- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker 从入门到实践](https://vuepress.mirror.docker-practice.com/)


##  常用指令

### FROM

设置基础镜像：

```dockerfile
FROM <image name>
```

### ~~MAINTAINER~~

**已弃用，用 LABEL 替代**

设置镜像作者：

```dockerfile
MAINTAINER <author name>
```

### LABLE

设置元数据（键值对）：

```dockerfile
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```

可替代 MATINTAINER 设置作者：

```dockerfile
LABEL author=king
```

其他常用的设置还有：version、description、other 等任意参数。

### RUN

编译镜像时运行的脚本：

```dockerfile
RUN <command>
RUN [ "<command>" , "[param1]" , "[param2]" ]
```

如：

```dockerfile
RUN set -ex; apt update && \
	apt install -y vim
```

> 注意：尽量减少 RUN 命令的个数，一个 RUN 就会创建一层 layer
> 使用 `set -x` 或 `set -ex` 开头，查看 `man set`。

### COPY

复制文件：

```dockerfile
COPY <src> <image dest>
```

如：

```dockerfile
COPY package.json /usr/src/app/
COPY hom* /mydir/
COPY hom?.txt /mydir/
```

### ADD

复制文件（比 COPY 更高级）：

```dockerfile
ADD <src> <image dest>
```

`<src>` 可以是一般文件、目录，压缩文件（自动解压）、URL（自动下载，不解压），如：

```dockerfile
ADD test.txt /mydir
ADD bin /mydir
ADD nginx.tar.gz /usr
ADD http://example.com/nginx.tar.gz /mydir
```

### WORKDIR

指定工作目录：

```dockerfile
WORKDIR <image path>
```

如下 a.txt 会被拷贝到 /mydir ：

```dockerfile
WORKDIR /mydir
COPY a.txt .
```

### USER

指定当前用户，`USER` 指令和 `WORKDIR` 相似，都是改变环境状态并影响以后的层。`WORKDIR` 是改变工作目录，`USER` 则是改变之后层的执行 `RUN`、`CMD` 以及 `ENTRYPOINT` 这类命令的身份。

```dockerfile
RUN groupadd -r redis && useradd -r -g redis redis
USER redis
RUN [ "redis-server" ]
```

### VOLUME

设置容器匿名挂载卷：

```dockerfile
VOLUME [ "<dir>" , "<dir>" , "..." ]
VOLUME <dir>
```

### EXPOSE

声明运行时容器提供服务的端口：

```dockerfile
EXPOSE <port>[/protocol]
```

如：

```dockerfile
EXPOSE 80/tcp
EXPOSE 80/udp
```

> EXPOSE 指令是声明运行时容器提供服务端口，这只是一个声明，在运行时并不会因为这个声明应用就会开启这个端口的服务。
>
> 在 Dockerfile 中写入这样的声明有两个好处，一个是帮助镜像使用者理解这个镜像服务的守护端口，以方便配置映射；另一个用处则是在运行时使用随机端口映射时，也就是 docker run -P 时，会自动随机映射 EXPOSE 的端口。
>
> 如果指定了 --net=host 宿主机网络模式，容器中 EXPOSE 指令暴露的端口会直接使用宿主机对应的端口，不存在映射关系

### CMD

设置容器启动命令：

```dockerfiel
CMD <command>
CMD [ "<command>" , ["param1"] , ["param2"] ... ]
```

如：

```dockerfile
CMD ["zsh"]
```

- `docker run -it ubuntu` 后面不跟命令，启动后会默认打开 `zsh` 。

- `docker run -it ubuntu /bin/bash` 中的 `/bin/bash` 会替换 `dockerfile` 中定义的 `CMD`，启动后会打开 `bash` 。

### ENTRTPOINT

设置容器入口程序：

```dockerfile
# exec 格式
ENTRYPOINT ["executable", "param1", "param2"]
# shell 格式
ENTRYPOINT command param1 param2
```

`ENTRYPOINT` 和 `CMD` 一样，都是在指定容器启动程序及参数。当指定了 `ENTRYPOINT` 后，`CMD` 的含义就发生了改变，不再是直接的运行其命令，**而是将 `CMD` 的内容作为参数传给 `ENTRYPOINT` 指令**，换句话说实际执行时，将变为：

```
<ENTRYPOINT> "<CMD>"
```

如：

```dockerfile
ENTRYPOINT [ "ls" ]
```

`docker run -it ubuntu -al` 中的 `-al` 为 `<CMD>`，作为参数传递给 `ENTRYPOINT` ，相当于启动时执行了 `ls-al` 。

### ENV

设置环境变量：

```dockerfile
ENV <key1>=<value1> <key2>=<value2> ...
```

如：

```dockerfile
ENV VERSION=1.0 DEBUG=on \
    NAME="Happy Feet”
```

### ARG

构建参数和 `ENV` 的效果一样，都是设置环境变量。

```dockerfile
ARG <name>[=<default value>] 
```

所不同的是，`ARG` 所设置的是 **构建环境 的环境变量**，在将来容器运行时是不会存在这些环境变量的。但是不要因此就使用 `ARG` 保存密码之类的信息，因为 `docker history` 还是可以看到所有值的。

`Dockerfile` 中的 `ARG` 指令是定义参数名称，以及定义其默认值。该默认值可以在构建命令 `docker build` 中用 `--build-arg <参数名>=<值>` 来覆盖。


ARG 指令有生效范围，如果在 FROM 指令之前指定，那么只能用于 FROM 指令中。

```dockerfile
ARG DOCKER_USERNAME=library

FROM ${DOCKER_USERNAME}/alpine

RUN set -x ; echo ${DOCKER_USERNAME}

```


### ONBUILD

`ONBUILD` 是一个特殊的指令，它后面跟的是其它指令，比如 `RUN`、`COPY` 等，而这些指令，在当前镜像构建时并不会被执行。**只有以当前镜像为基础镜像，去构建下一级镜像的时候才会被执行**。

```dockerfile
ONBUILD RUN echo "--- i am onbuild ---"
```

