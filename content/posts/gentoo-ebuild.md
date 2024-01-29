---
title: "Gentoo ebuild"
date: "2024-01-29"
summary: "学习编写简单的 ebuild 及建立本地仓库"
description: ""
categories: [ "linux" ]
tags: [ "gentoo" ]
---


参考文章

- [Gentoo Devmanual](https://devmanual.gentoo.org/)
- [Ebuild Writing](https://devmanual.gentoo.org/ebuild-writing/index.html)


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

### 变量

`EAPI`：

`DESCRIPTION`：对包及其用途的描述文字

`HOMEPAGE`：包主页的链接，如 `https://`


## 编写 Ebuild

### 文件命名规则

文件名格式：`name-version.ebuild`

version 由一个或多个数字组成，可以用小数点分隔，如 1.2.3，20050108

最后一个数字后面可能有一个字母


## 未完待续.......
