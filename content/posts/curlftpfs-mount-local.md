---
author:  "kingtuo123"
title: "Curlftpfs挂载ftp到本地"
date: "2021-03-09"
description: ""
categories: [ "linux" ]
tags: [ "gentoo","linux","ftp"]
---

- 参考 [CurlFtpFS](https://wiki.gentoo.org/wiki/CurlFtpFS)

## 内核选项

```text
File systems --->
   <*> FUSE (Filesystem in Userspace) support
```

## 安装

```bash
emerge -av net-fs/curlftpfs
```

## 以普通用户挂载

首先，创建挂载点

```text
mkdir ./ftp
```

挂载

```bash
curlftpfs ftp://server/catalog/ ./ftp/ -o user=username:password,utf8,ssl
```

`ssl` ：使用 SSL/TLS 传输数据

`utf8` ： 使用 utf8 编码

## 卸载

```bash
fusermount -u ~/example
```

或者

```bash
umount ~/example
```
