---
title: "Curlftpfs 挂载 FTP 到本地"
date: "2021-03-09"
description: ""
summary: ""
categories: [ "linux" ]
tags: [ "gentoo" ]
---

参考文章

- [Gentoo Wiki / CurlFtpFS](https://wiki.gentoo.org/wiki/CurlFtpFS)

## 内核配置

```text
File systems --->
   <*> FUSE (Filesystem in Userspace) support
```

## 安装

```shell-session
$ emerge -av net-fs/curlftpfs
```

## 挂载

创建挂载点

```shell-session
$ mkdir ./ftp
```

挂载，如果没有用户名和密码则留空，保留冒号

```shell-session
$ curlftpfs ftp://server/catalog/ ./ftp/ -o user=username:password,utf8,ssl
```

参数说明：

`ssl` ：使用 SSL/TLS 传输数据

`utf8` ：使用 utf8 编码

## 卸载

```shell-session
$ fusermount -u ~/example
```

或者

```shell-session
$ umount ~/example
```
