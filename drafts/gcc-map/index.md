---
title: "GCC Map 文件"
date: "2023-09-01"
description: ""
summary: "--"
categories: [ "linux" ]
tags: [ "" ]
---

- 参考文章：
  - [充分理解Linux GCC 链接生成的Map文件](https://zhuanlan.zhihu.com/p/502051758)
  - [Linux map 文件解析](https://blog.csdn.net/dreamDay2016_11_11/article/details/130605574)


## 如何生成 map 文件

map 文件由链接器生成

### 方法一

通过 gcc 将参数传递给链接器：

```
gcc -o target target.c -Wl,-Map=target.map
```

`-Wl`：表示后面跟的参数传递给链接器，用逗号分隔

`-Map=<filename>`：生成 map 文件


### 方法二

使用链接器 ld ：

```
ld -Map target.map target.o -o target
```
