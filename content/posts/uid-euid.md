---
author: "kingtuo123"
title: "UID EUID SUID"
date: "2023-03-29"
description: ""
summary: "进程的三个 UID 的关系"
categories: [ "linux" ]
tags: [ "linux" ]
---


- 参考文章：
  - [Linux系统的UID和EUID](https://zhuanlan.zhihu.com/p/567686889)
  - [Linux SetUID](http://c.biancheng.net/view/868.html)
  - [ruid, euid, suid usage in Linux](https://mudongliang.github.io/2020/09/17/ruid-euid-suid-usage-in-linux.html)
  - [Difference between owner/root and RUID/EUID](https://unix.stackexchange.com/questions/191940/difference-between-owner-root-and-ruid-euid)
  - [SUID, GUID and Sticky Bit](https://linuxhandbook.com/suid-sgid-sticky-bit/)
  - [setuid()与seteuid()的区别](https://blog.csdn.net/nyist327/article/details/38945797)

## 概述

内核为每个进程维护的三个UID值：
 - RUID (Real User ID) 进程的实际拥有者
 - EUID (Effective User ID) 用于系统决定用户对系统资源的访问权限，通常情况下等于RUID
 - SUID (Saved set-user-ID) 仅适用于可执行文件，若文件设置了 SUID，那么当用户执行此文件时，会以文件所有者的身份去执行此文件



## 示例

`test.c`，以普通用户打印 `/etc/shadow` 文件内容

```c
#define _GNU_SOURCE
#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>

int main(void){
    uid_t ruid, euid, suid;
    getresuid(&ruid, &euid, &suid);
    printf("RUID: %d, EUID: %d, SUID: %d\n", ruid, euid, suid);
    execlp("cat", "cat", "/etc/shadow", (char *)0);
    exit(0);
}
```

编译 `make test`，执行 `./test`

```
$ ls -l test
-rwxr-xr-x 1 king king 15528 Mar 29 17:11 test

$ ./test
RUID: 1000, EUID: 1000, SUID: 1000
cat: /etc/shadow: Permission denied
```


修改 `owner` 及 `suid` 后再执行

```
# chown root test && chmod u+s test

$ ls -l test
-rwsr-xr-x 1 root king 15528 Mar 29 17:11 test

$ ./test
RUID: 1000, EUID: 0, SUID: 0
成功打印,略...
```

当可执行文件有 `SUID` 位时，其他用户执行时 `EUID` 为文件 `owner` 的 `id`，与 `owner` 有相同的权限
