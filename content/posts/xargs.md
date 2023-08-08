---
title: "xargs"
date: "2023-08-08"
description: ""
summary: "eXtended ARGuments 参数扩展"
categories: [ "cmd" ]
tags: [ "" ]
---

- 参考文章：
  - [Linux xargs 命令](https://www.runoob.com/linux/linux-comm-xargs.html)

## 概述

xargs（eXtended ARGuments）

xargs 可以将管道或标准输入（stdin）数据转换成命令行参数，也能够从文件的输出中读取数据。

之所以能用到这个命令，关键是由于很多命令不支持管道来传递参数。

## xargs 与管道的区别

xargs 将上一条命令的标准输出，作为后一条命令的参数

```
$ echo "--help" | xargs cat
Usage: cat [OPTION]... [FILE]...
...
```

管道  将上一条命令的标准输出，作为后一条命令的标准输入

```
$ echo "--help" | cat
--help
```

