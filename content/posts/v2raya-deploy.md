---
author: "kingtuo123"
title: "V2rayA 安装配置"
date: "2022-06-13"
description: ""
summary: "Linux下V2rayA安装配置"
categories: [ "linux" ]
tags: [ "linux" ]
---

参考资料：

- [V2rayA 文档](https://v2raya.org/) 有完整的安装教程
- [V2rayA 仓库](https://github.com/v2rayA/v2rayA)
- [v2ray-core 仓库](https://github.com/v2fly/v2ray-core)



## 安装 v2ray-core

V2rayA 是 Linux 的 V2Ray 客户端，依赖 v2ray-core 运行。

从这里下载 [v2ray-core release](https://github.com/v2fly/v2ray-core/releases) 。

解压后文件夹内有 `v2ctl` 和 `v2ray`， `ln` 链接一下即可。

## 安装 V2rayA

从这里下载 [v2raya release](https://github.com/v2rayA/v2rayA/releases)。

解压后文件夹内有 `v2raya`，链接一下。

## 客户端设置

root 运行 `sudo v2raya` 。

非 root 运行 `v2raya --lite` ，但没有透明代理等功能。

浏览器打开 `127.0.0.1:2017`，首次需要设置用户名密码。

忘记密码执行 `sudo v2raya --reset-password` 重置。