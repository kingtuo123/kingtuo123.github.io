---
title: "ldconfig 命令"
date: "2022-07-01"
summary: "ldconfig ，LIBRARY_PATH ，LD_LIBRARY_PATH"
description: ""
tags: [ "linux" , "cmd"]
math: false
categories: [ "linux" , "cmd" ]
---

## ldconfig

`ldconfig` 命令的作用主要是在默认目录 `/lib` 和 `/usr/lib` 以及动态库配置文件 **`/etc/ld.so.conf` 内所列的目录下**，搜索出可共享的动态链接库，进而创建出动态装入程序 `(ld.so)` 所需的连接和缓存文件。

**缓存文件默认为 `/etc/ld.so.cache`，此文件保存已排好序的动态链接库名字列表**，为了让动态链接库为系统所共享，需运行动态链接库的管理命令 `ldconfig` 。

`ldconfig` 通常在系统启动时运行，而当用户安装了一个新的动态链接库时，就需要手动运行这个命令。

- 语法格式：`ldconfig [参数]`

| 参数 | 说明 |
|:--|:--|
|-v		|显示正在扫描的目录及搜索到的动态链接库以及所创建的连接的名字|
|-n		|仅扫描命令行指定的目录，不扫描默认目录，也不扫描配置文件所列的目录|
|-N		|不重建缓存文件|
|-X		|不更新文件的连接|
|-f CONF|指定动态链接库的配置文件为CONF，系统默认为/etc/ld.so.conf|
|-C CACHE|指定生成的缓存文件为CACHE，系统默认的是/etc/ld.so.cache|
|-r ROOT|改变应用程序的根目录为ROOT|
|-l|进入专家模式手工设置连接|
|-p|打印出当前缓存文件所保存的所有共享库的名字|
|-c FORMAT|指定缓存文件所使用的格式|
|-V|打印出ldconfig的版本信息，而后退出|
|--help|打印出其帮助信息，而后退出|


## 示例


将 `libfoo.so` 共享库添加到系统标准库路径

```bash
$ cp /home/username/foo/libfoo.so /usr/lib
$ chmod 0755 /usr/lib/libfoo.so
```

更新共享库缓存列表
```bash
$ sudo ldconfig
```

更新完成后检查（从当前缓存文件的中搜索 libfoo.so 库）
```bash
$ ldconfig -p | grep foo
    libfoo.so (libc6) => /usr/lib/libfoo.so
```


## LIBRARY_PATH 和 LD_LIBRARY_PATH 区别

`LIBRARY_PATH` ：编译程序时用到

`LD_LIBRARY_PATH` ：程序运行时用到

`/etc/ld.so.conf` 和 `LD_LIBRARY_PATH` 具有同等的作用，程序运行时链接库的时候，优先链接后者，即环境变量 `LD_LIBRARY_PATH` 目录下的库。如果不能满足一些共享库相关性要求，则转回到 `/etc/ld.so.conf` 中指定的库。

`/etc/ld.so.conf` 由 `env-update` 生成，这些路径来自 `/etc/env.d/` 下的文件，如下：

```bash
$ grep LDPATH /etc/env.d/ -r

/etc/env.d/60llvm-9985:LDPATH="/usr/lib/llvm/14/lib64"
/etc/env.d/50baselayout:LDPATH='/lib64:/usr/lib64:/usr/local/lib64:/lib:/usr/lib:/usr/local/lib'
/etc/env.d/00glibc:LDPATH="include ld.so.conf.d/*.conf"
/etc/env.d/50rust-bin-1.60.0:LDPATH="/usr/lib/rust/lib"
/etc/env.d/gcc/x86_64-pc-linux-gnu-11.3.0:LDPATH="/usr/lib/gcc/x86_64-pc-linux-gnu/11.3.0:/usr/lib/gcc/x86_64-pc-linux-gnu/11.3.0/32"
```

如果修改了 `/etc/env.d/` 下的文件，执行以下命令

```bash
sudo env-update
sudo ldconfig
```
