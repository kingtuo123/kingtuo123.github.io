---
title: "MAC 与 IP 地址在传输时的变化"
date: "2022-09-20"
summary: "NOTE"
description: ""
categories: [ "network" ]
tags: [ "" ]
math: false
---

- 参考文章：
  - [Communication through Multiple Switches](http://www.practicalnetworking.net/stand-alone/communication-through-multiple-switches/)
  - [源/目标MAC地址的变化释疑](https://blog.csdn.net/qq_36501981/article/details/81038641)
  - [ip数据包经由路由转发的时候源ip，目的ip是否改变](https://www.cnblogs.com/my_life/articles/6100830.html)
  - [关于在传输过程中MAC地址和IP地址，变与不变！](https://blog.51cto.com/nanjingfm/1179368)

结论：源mac地址在同一个广播域传输过程中是不变的，在跨越广播域的时候会发生改变的；而源IP地址在传输过程中是不会改变的（除NAT的时候）。
