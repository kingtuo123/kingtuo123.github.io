---
title: "ldconfig"
date: "2022-07-01"
summary: "动态链接库管理命令"
description: ""
math: false
categories: [ "cmd" ]
tags: [ ""]
---

- 参考文章：
  - [ldconfig](https://linux.die.net/man/8/ldconfig)
  - [ldconfig 命令](https://www.cnblogs.com/my-show-time/p/15250435.html)


## 概述

- ldconfig 搜索 `/lib`，`/usr/lib` 和 `/etc/ld.so.conf` 文件内所列的目录，找到可共享的动态链接库，为动态装载程序 `ld.so` 创建所需的链接和缓存。

- 缓存文件默认为 `/etc/ld.so.cache`，此文件保存已排好序的动态链接库名字列表。

- ldconfig 通常在系统启动时运行，当用户安装了一个新的动态链接库时，就需要手动运行这个命令。

## 参数

| 参数 | 说明 |
|:--|:--|
|-v		|显示正在扫描的目录及搜索到的动态链接库以及所创建的链接的名字|
|-n		|仅扫描命令行指定的目录，不扫描默认目录，也不扫描配置文件所列的目录|
|-N		|不重建缓存文件|
|-X		|不更新文件的链接|
|-f conf|指定动态链接库的配置文件为 conf，系统默认是 /etc/ld.so.conf|
|-C cache|指定生成的缓存文件为 cache，系统默认是 /etc/ld.so.cache|
|-r root|改变应用程序的根目录为 root|
|-l|进入专家模式手动设置链接|
|-p|打印当前缓存文件|
|-c format|指定缓存文件的格式|
|-V|打印 ldconfig 版本信息|
|\-\-help|打印帮助信息|


## 示例


将 `libfoo.so` 添加到系统共享库中：

```
# cp libfoo.so /usr/lib
# chmod 0755 /usr/lib/libfoo.so
```

更新共享库缓存列表：
```
# ldconfig
```

更新完成后检查（从当前缓存文件的中搜索 libfoo.so 库）：
```
# ldconfig -p | grep foo
    libfoo.so (libc6) => /usr/lib/libfoo.so
```


## LIBRARY_PATH 和 LD_LIBRARY_PATH 区别

- **LIBRARY_PATH**：编译程序时用到

- **LD_LIBRARY_PATH**：程序运行时用到

`/etc/ld.so.conf` 和 `LD_LIBRARY_PATH` 具有同等的作用，程序运行时链接库的时候，优先链接后者，即环境变量 `LD_LIBRARY_PATH` 目录下的库。如果不能满足一些共享库相关性要求，则转回到 `/etc/ld.so.conf` 中指定的库。

`/etc/ld.so.conf` 由 `env-update` 生成，这些路径来自 `/etc/env.d/` 下的文件，如下：

```
$ grep LDPATH /etc/env.d/ -r
/etc/env.d/60llvm-9985:LDPATH="/usr/lib/llvm/14/lib64"
/etc/env.d/50baselayout:LDPATH='/lib64:/usr/lib64:/usr/local/lib64:/lib:/usr/lib:/usr/local/lib'
/etc/env.d/00glibc:LDPATH="include ld.so.conf.d/*.conf"
/etc/env.d/50rust-bin-1.60.0:LDPATH="/usr/lib/rust/lib"
/etc/env.d/gcc/x86_64-pc-linux-gnu-11.3.0:LDPATH="/usr/lib/gcc/x86_64-pc-linux-gnu/11.3.0:/usr/lib/gcc/x86_64-pc-linux-gnu/11.3.0/32"
```

如果修改了 `/etc/env.d/` 下的文件，执行以下命令

```
# env-update
# ldconfig
```
