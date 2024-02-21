---
title: "V2rayA 安装配置"
date: "2022-06-13"
description: "V2rayA 是 V2ray-core 的客户端"
summary: "V2rayA 是 V2ray-core 的客户端"
categories: [ "linux" ]
tags: [ "linux" ]
---

参考文章

- [V2rayA 主页](https://v2raya.org/)
- [V2rayA Github 仓库](https://github.com/v2rayA/v2rayA)
- [v2ray-core Github 仓库](https://github.com/v2fly/v2ray-core)


## 安装 V2ray-core

下载：[v2ray-core release](https://github.com/v2fly/v2ray-core/releases)

解压后有 `v2ctl` 和 `v2ray`

## 安装 V2rayA

下载：[v2raya release](https://github.com/v2rayA/v2rayA/releases)

解压后有 `v2raya`

## 运行 V2rayA

完整功能需要 root 运行 `sudo v2raya`

非 root 运行 `v2raya --lite` ，但没有透明代理等功能

浏览器打开 `127.0.0.1:2017`，首次需要设置用户名密码

忘记密码执行 `sudo v2raya --reset-password` 重置
