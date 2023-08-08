---
title: "netstat"
date: "2022-09-26"
summary: "打印网络连接、路由表、接口统计信息 ..."
description: ""
categories: [ "cmd" ]
tags: [ "cmd" ]
math: false
---

- 参考文章：
  - [netstat(8) - Linux man page](https://linux.die.net/man/8/netstat)
  - [netstat 命令详解](https://zhuanlan.zhihu.com/p/367635200)

> 注意：该命令已过时， `netstat` 的替代品是 `ss` 命令。

- `netstat -r` 的替换是 `ip route`
- `netstat -i` 的替换是 `ip -s link`
- `netstat -g` 的替换是 `ip maddr`

## 常用参数

```
-r：--route，显示路由表
-l：--listening，显示所有监听的端口
-a：--all，显示所有链接和监听端口
-t：显示所有的 tcp 协议的端口
-x：显示所有的 unix 协议的端口
-u：显示所有的 udp 协议的端口
-n：--numeric，用数字显示主机名/IP/端口，例如localhost用127.0.0.1
-p：--programs，显示进程名和PID

-v：--verbose，显示指令执行过程
-W：--wide，不截断IP地址
-s：--statistics，显示各协议统计信息
-i：--interface，显示接口信息
-N：--symbolic，解析硬件名称
-e：--extend，显示额外信息
-o：--timers，显示计时器
-c：--continuous，每隔一个固定时间，执行netstat命令
-g：--group，显示多重广播功能群组组员名单
-M：--masquerade，显示伪装的网络连接

-F：--fib，显示转发信息库(默认)
-C：--cache，显示路由缓存而不是FIB
-Z：--context，显示套接字的SELinux安全上下文
```
