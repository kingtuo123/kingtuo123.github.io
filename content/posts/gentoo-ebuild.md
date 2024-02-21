---
title: "[ unfinished ] Gentoo ebuild"
date: "2024-01-29"
summary: "学习编写简单的 ebuild 及建立本地仓库"
description: ""
categories: [ "linux" ]
tags: [ "gentoo", "unfinished" ]
---


参考文章

- [Gentoo Devmanual](https://devmanual.gentoo.org/)
- [Ebuild Writing](https://devmanual.gentoo.org/ebuild-writing/index.html)

> Gentoo 默认 ebuild 仓库路径 `/var/db/repos/gentoo`

## 概览

### 第一个 Ebuild

下面是一个简化后的 ctag 的 ebuild 文件 `dev-util/ctags/ctags-5.5.4.ebuild`

```bash
# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Exuberant ctags generates tags files for quick source navigation"
HOMEPAGE="https://ctags.io/ https://github.com/universal-ctags/ctags"
SRC_URI="mirror://sourceforge/ctags/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~mips ~sparc ~x86"

src_configure() {
    econf --with-posix-regex
}

src_install() {
    emake DESTDIR="${D}" install

    dodoc FAQ NEWS README
}
```

### 基本格式

ebuild 是在特殊环境中执行的 bash 脚本

ebuild 文件都包含头部信息变量

ebuild 文件使用四个空格长度的 Tab 缩进

### 信息变量

`EAPI`：

`DESCRIPTION`：对包及其用途的描述文字

`HOMEPAGE`：主页地址

`SRC_URI`：源码地址

`LICENSE`：许可证

`SLOT`：插槽

`KEYWORDS`：已经通过测试的版本。一般对于新编写的 ebuild 使用 `~关键字`，不会直接提交到稳定版

> 软件包支持同时安装多个版本，这种特性成为插槽


### 构建函数

`src_configure`：Portage 需要配置软件包时会调用该函数

`econf`：`./configure` 的封装函数，如果 `econf` 出错，Portage 会停止安装

`src_install`：Portage 安装软件包时会调用该函数

`dodoc`：将文件安装到 `/usr/share/doc` 的函数

## 未完待续 ...
