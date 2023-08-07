---
title: "Linux 下搭建 stm32 开发环境"
date: "2022-06-30"
summary: "安装 gcc 工具链，isp / stlink 下载工具"
description: ""
tags: [ "stm32","linux" ]
math: false
categories: [ "stm32","linux"]
---

## 下载 arm gcc 工具链

- [下载地址](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads)

<div align="center">
    <img src="1.png" style="max-height:150px"></img>
</div>


解压

```bash
tar xvf gcc-arm-*-arm-none-eabi.tar.xz
```

安装

```bash
sudo mv gcc-arm-*-arm-none-eabi /opt/arm-none-eabi-gcc
```

添加 `PATH` 到 `/etc/profile`

```
export PATH=${PATH}:/opt/arm-none-eabi-gcc/bin
```

## ISP 串口下载工具

- [下载地址](https://sourceforge.net/projects/stm32flash/)

<div align="center">
    <img src="2.png" style="max-height:190px"></img>
</div>

解压

```bash
tar xvf stm32flash-0.7.tar.gz
```

编译，成功后目录下有 `stm32flash`

```bash
cd stm32flash-0.7/
make
```

安装，路径 `/usr/local/bin`
```bash
sudo make install
```

- 使用方法详见：[ISP 一键下载](https://kingtuo123.com/posts/stm32-isp-flash/)

- 串口驱动安装：[CH340 驱动](https://kingtuo123.com/posts/gentoo-ch340-driver/)

## ST-LINK 下载工具

- 下载地址：[stlink release](https://github.com/stlink-org/stlink/releases)

下载 `Source code` 
<div align="center">
    <img src="3.png" style="max-height:190px"></img>
</div>

解压

```bash
tar xvf stlink-1.7.0.tar.gz
```

安装依赖

```
sudo emerge -av virtual/libusb
```

编译安装
```bash
cd stlink-1.7.0/
make release
make debug
sudo make install
```

运行 `st-info  --version`，如果提示

```text
libstlink.so.1: cannot open shared object file: No such file or directory
```

执行以下命令

```bash
sudo ldconfig
```

> `ldconfig` 命令的作用主要是在默认搜寻目录 `/lib` 和 `/usr/lib` 以及动态库配置文件 `/etc/ld.so.conf` 内所列的目录下，搜索出可共享的动态链接库,进而创建出动态装入程序(ld.so)所需的连接和缓存文件。

> `ldconfig` 通常在系统启动时运行，而当用户安装了一个新的动态链接库时，就需要手工运行这个命令。

> `libstlink.so.1` 的安装路径是 `/usr/local/lib64` ，检查 `/etc/ld.so.conf` 内是否有这个路径。


- 使用方法详见：[STLINK](https://kingtuo123.com/posts/stlink-linux/)
