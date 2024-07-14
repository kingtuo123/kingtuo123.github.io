---
title: "GNU Autotools 入门"
date: "2024-07-14"
description: ""
summary: "GNU 构建系统"
categories: [ "linux" ]
tags: [ "linux", "autotools" ]
---

<div align="left">
    <img src="autotools.svg" style="max-height:900px"></img>
</div>

## 概述

构建基于 Autotools 的软件包通常有以下步骤：

```bash-session
$ ./configure --prefix=/usr
$ make
$ make install
```

### Configure 目的

`configure` 会检查构建时所需的函数、库和工具，生成 config.h 、Makefile 等文件

### Configure 流程

<div align="left">
    <img src="configure.svg" style="max-height:300px"></img>
</div>

`configure` 先生成 `config.status`，再运行 `config.status` 将配置模版输出为对应的配置文件

- `*.in` 文件是配置模板，可以手动创建，也可以由 `autoheader`、`automake` 工具生成

- `config.log` 文件记录了 `configure` 和 `config.status` 执行过程中的日志及各种变量，多用于排错

- `config.cache` 文件是由 `configure -C` 参数生成的缓存文件，提升重复 `configure` 的速度


### Makefile 目标

参考：[Standard Targets for Users](https://www.gnu.org/prep/standards/html_node/Standard-Targets.html)

```text
all               默认目标，构建程序、库、文档
install           安装需要安装的内容
install-strip     与 install 相同，但随后剥离调试符号
uninstall         与 install 相反
clean             删除已构建的内容
distclean         与 clean 相同，但也会删除 AutoTools 生成的文件
check             运行测试套件（如果有）
installcheck      检查已安装的程序或库（如果支持）
dist              创建 PACKAGE-VERSION.tar.gz
```

### 目录变量


目录变量指定了各类文件的安装位置，参考：[Variables for Installation Directories](https://www.gnu.org/prep/standards/html_node/Directory-Variables.html)

```shell
# 目录变量         # 默认值
prefix        =   /usr/local
exec_prefix   =   ${prefix}
bindir        =   ${exec_prefix}/bin
libdir        =   ${exec_prefix}/lib
includedir    =   ${prefix}/include
datarootdir   =   ${prefix}/share
datadir       =   ${datarootdir}
mandir        =   ${datarootdir}/man
infodir       =   ${datarootdir}/info
```



### prefix 参数

该参数指定文件的安装位置，默认路径是 `/usr/local`：

```bash-session
$ ./configure --prefix=/usr
```

执行 `./configure` 后会生成 `config.log`，`prefix` 的值可以在 `config.log` 文件中确认：

```bash-session
$ grep "^prefix" config.log
prefix='/usr'
```

其它目录变量也可以参照上面设置，执行 `./configure --help` 查看更多可配置的参数


### DESTDIR 参数

该参数用于安装到一个临时目录，比如我们想打包构建好的程序或库，而不是在本地运行：

```bash-session
$ make install DESTDIR=/tmp/app
```
`DESTDIR` 类似虚拟根目录，当 `prefix=/usr` ，则安装目录就是 `/tmp/app/usr`，即 `DESTDIR/prefix`


### 缓存变量

此类变量及其值的列表在 `config.log` 中可见：

```bash
## ---------------- ##
## Cache variables. ##
## ---------------- ##
ac_cv_build=x86_64-unknown-linux-gnu
ac_cv_c_compiler_gnu=yes
[...]
ac_cv_path_SED=/bin/sed
```

如果自动检测的值由于某种原因不正确，可以通过环境变量来覆盖：

```bash-session
$ ac_cv_path_SED=/path/to/sed ./configure
```



## Autoconf

<div align="left">
    <img src="autoconf.svg" style="max-height:180px"></img>
</div>

`configure.ac` 是一个包含宏指令的 shell 脚本

`autoconf` 的工作就是将 `configure.ac` 中的宏展开，转换为完整的 shell 脚本，即 `configure`

`autoconf` 的宏指令大多以 `AC_` 开头，参考：[Autoconf Macro Index](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/Autoconf-Macro-Index.html)

`autoconf` 的宏指令定义在 `/usr/share/autoconf/*.m4`

创建一个最小化配置的 `configure.ac` ：

```bash
# 初始化 autoconf，指定软件包名称、版本号和错误报告地址
AC_INIT([hello], [1.0], [bug-report@address])
# 输出文件
AC_OUTPUT
```

```bash-session
$ ls
configure.ac
$ autoconf && ls
autom4te.cache  configure  configure.ac
```

`autom4te.cache` 文件夹由 `autom4te` 创建，其中存储了一些额外信息以提高运行速度，
autoconf、autoheader、automake 等工具都会调用 `autom4te` 处理宏指令，
参考：[What is autom4te.cache](https://www.gnu.org/software/autoconf/manual/autoconf-2.67/html_node/Autom4te-Cache.html)

## Aclocal

<div align="left">
    <img src="aclocal.svg" style="max-height:250px"></img>
</div>

`configure.ac` 如果包含 `autoconf` 以外的宏指令（如 `automake` 和用户自定义的宏指令），`aclocal` 会查找相关路径
，找到这些宏指令的定义并将其放入 `aclocal.m4` 中

创建 `configure.ac`：

```bash
AC_INIT([hello], [1.0], [bug-report@address])
# 初始化 automake
AM_INIT_AUTOMAKE
AC_OUTPUT
```

直接执行 `autoconf` 就会报错如下：

```bash-session
$ autoconf
configure.ac:2: error: possibly undefined macro: AM_INIT_AUTOMAKE
      If this token and others are legitimate, please use m4_pattern_allow.
      See the Autoconf documentation.
```

应该先执行 `aclocal`：

```bash-session
$ aclocal && ls
aclocal.m4  autom4te.cache  configure.ac
$ autoconf && ls
aclocal.m4  autom4te.cache  configure  configure.ac
```

## Autoheader

<div align="left">
    <img src="autoheader.svg" style="max-height:390px"></img>
</div>

下面使用 `AC_DEFINE` 在 `configure.ac` 中创建 C 语言宏定义：

```bash
AC_INIT([hello], [1.0], [bug-report@address])
# 创建 C 宏定义，参数：[宏名]，[值]，[注释]
AC_DEFINE([FOOBAR], [42], [This is the foobar value])
# 声明 config.h 为输出头文件
AC_CONFIG_HEADERS([config.h])
# 输出所有已声明的文件
AC_OUTPUT
```

```bash-session
$ ls
configure.ac
$ autoheader && ls
autom4te.cache  config.h.in  configure.ac
$ autoconf && ls
autom4te.cache  config.h.in  configure  configure.ac
$ ./configure
configure: creating ./config.status
config.status: creating config.h
$ ls
autom4te.cache  config.h.in  config.status  configure.ac
config.h        config.log   configure
```

最终生成的 `config.h` 内容如下：

```c
/* This is the foobar value */
#define FOOBAR 42
/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "bug-report@address"
/* Define to the full name of this package. */
#define PACKAGE_NAME "hello"
/* Define to the full name and version of this package. */
#define PACKAGE_STRING "hello 1.0"
/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "hello"
/* Define to the home page for this package. */
#define PACKAGE_URL ""
/* Define to the version of this package. */
#define PACKAGE_VERSION "1.0"
```


`config.h` 包含了软件包的名称、版本等大量的宏定义，用户程序可以直接使用这些宏，实现条件编译、对不同平台的移植适配等

## Automake

创建下列文件：

```text
.
├── configure.ac
├── Makefile.am
└── src
    ├── main.c
    └── Makefile.am
```

`src/main.c` ：

```c
#include "config.h"
#include <stdio.h>

int main(void){
    #ifdef ENABLE_CHINESE
        printf("你好，世界！\n");
    #else
        printf("Hello World!\n");
    #endif
    return 0;
}
```


`configure.ac`：

```bash
AC_INIT([hello], [1.0], [bug-report@address])
# 初始化 automake，foreign 告诉 automake 不需要所有 GNU 编码风格文件，-Wall -Werror 打开所有警告并报告为错误
AM_INIT_AUTOMAKE([foreign -Wall -Werror])
# 检查 C 编译器
AC_PROG_CC
# 添加 ./configure 命令行参数 --enable-chinese
AC_ARG_ENABLE(chinese, AS_HELP_STRING([--enable-chinese], [print in chinese]), opt_chinese=$enableval)

if test $opt_chinese = yes; then
    # 定义宏 ENABLE_CHINESE
    AC_DEFINE([ENABLE_CHINESE], [], [print in chinese])
fi

BUILD_DIR=`pwd`
# 输出 BUILD_DIR 这个 shell 变量
AC_SUBST([BUILD_DIR])

# 声明 config.h 为输出头文件
AC_CONFIG_HEADERS([config.h])
# 声明 Makefile 和 src/Makefile 为输出文件
AC_CONFIG_FILES([Makefile src/Makefile])
# 输出所有已声明的文件
AC_OUTPUT
```

> `AM_INIT_AUTOMAKE` 参数说明：[List of Automake options](https://www.gnu.org/software/automake/manual/html_node/List-of-Automake-options.html)
>
> `AC_ARG_ENABLE` 用法说明：[Choosing Package Options](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/Package-Options.html)
>
> `AC_SUBST` 用法说明：[Setting Output Variables](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/Setting-Output-Variables.html)
>
> `SUBDIRS` 详细解释：[Recursing subdirectories](https://www.gnu.org/software/automake/manual/html_node/Subdirectories.html)

`Makefile.am`：

```makefile
# SUBDIRS 表示需递归构建的子目录
SUBDIRS = src
```



`src/Makefile.am` ：

```makefile
# 构建 hello 这个可执行文件
bin_PROGRAMS = hello
# 构建 hello 这个目标所需的源文件，BUILD_DIR 变量在 configure.ac 中定义输出，所以这里能用到
hello_SOURCES = main.c $(BUILD_DIR)/config.h
```


`bin_PROGRAMS` 命名规则如下，详见 [The Uniform Naming Scheme](https://www.gnu.org/software/automake/manual/html_node/Uniform.html)：

```text
bin_PROGRAMS  ==>  prefix_PRIMARY  ==>  由 prefix 和 PRIMARY 两部分组成

prefix   :  匹配 *dir 的目录变量，例如 bindir，libdir，datadir 等
            这里我们构建的是 hello 这个可执行文件，安装在 bin 目录下，所以是 bindir

PRIMARY  :  PROGRAMS    ->  可执行文件
            LIBRARIES   ->  库文件
            HEADERS     ->  公共头文件
            DATA        ->  任意数据文件
            MANS        ->  文档
            SCRIPTS     ->  脚本
```

接下来我们开始构建：

<div align="left">
    <img src="automake.svg" style="max-height:700px"></img>
</div>


```bash-session
$ aclocal                           # 生成 aclocal.m4
$ autoconf                          # 生成 configure
$ autoheader                        # 生成 config.h.in
$ automake --add-missing --copy     # 生成 Makefile.in src/Makefile.in
configure.ac:6: installing './compile'
configure.ac:4: installing './install-sh'
configure.ac:4: installing './missing'
src/Makefile.am: installing './depcomp'

$ ./configure --prefix=/tmp/app1    # 生成 config.h Makefile src/Makefile
$ make && make install              # 编译并安装
$ /tmp/app1/bin/hello               # 运行安装的程序
Hello World!

$ ./configure --prefix=/tmp/app2 --enable-chinese   # 使能中文打印，这会在 config.h 中定义 ENABLE_CHINESE 宏
$ make && make install              # 编译并安装
$ /tmp/app2/bin/hello               # 运行安装的程序
你好，世界！
```

`automake` 的 `--add-missing --copy` 参数用来复制缺失的辅助文件（compile，install-sh 等），这是必须的，记住就行

## Autoreconf

上面的例子中，我们手动执行：`aclocal` -> `autoconf` -> `autoheader` -> `automake`，十分繁琐

可以使用 `autoreconf` 自动完成这一过程，通常搭配 `-i` 或 `--install` 参数使用（复制缺失的标准辅助文件）

```bash-session
$ autoreconf -i
$ ./configure --prefix=/tmp/app2 --enable-chinese
$ make && make install
$ /tmp/app2/bin/hello
你好，世界！
```

## Autoscan

`configure.ac` 文件可以手动创建，也可以使用 `autoscan` 命令生成 `configure.scan` 模板文件，修改后再重命名为 `configure.ac` 即可

## 打包源码

使用 `make dist` 命令：

```bash-session
$ make dist
$ ls *.tar.*
hello-1.0.tar.gz
```

指定 tar 包压缩格式，修改 `configure.ac` 中 `AM_INIT_AUTOMAKE` 的参数即可，如 `dist-xz`：

```bash
AM_INIT_AUTOMAKE([foreign -Wall -Werror dist-xz])
```

`AM_INIT_AUTOMAKE` 参数说明：[List of Automake options](https://www.gnu.org/software/automake/manual/html_node/List-of-Automake-options.html)


## 发布软件

当软件作为 tar 包发布时，`configure` 和 `Makefile.in` 应该包含在内，用户解压后只需执行 `./configure`、`make`、`make install`

当通过版本控制系统发布时，应该只包含 `configure.ac` 和 `Makefile.am`，不应包含 Autotools 生成的辅助文件



## 备注

Autotools 涉及的的东西实在庞杂，至此也只是简述了大致的流程，还有交叉编译、动态库、libtool、自定义宏等等，以后有机会再研究吧！




## 参考文章

- [Autotools Tutorial](https://www.lrde.epita.fr/~adl/autotools.html)
- [Autotools Tutorial [PDF]\*](https://www.lrde.epita.fr/~adl/dl/autotools.pdf)
- [GNU Autotools (Embedded Linux Conference 2016) [PDF]](https://bootlin.com/pub/conferences/2016/elc/petazzoni-autotools-tutorial/petazzoni-autotools-tutorial.pdf)
- [Autotools 使用详细解读](https://blog.csdn.net/initphp/article/details/43705765)
- [GNU Autotools Ultimate Tutorial for Beginners ](https://terminalroot.com/gnu-autotools-ultimate-tutorial-for-beginners/)


## 官方文档

- [automake](https://www.gnu.org/software/automake/manual/html_node/)
  - [Macro Index](https://www.gnu.org/software/automake/manual/html_node/Macro-Index.html)
  - [Variable Index](https://www.gnu.org/software/automake/manual/html_node/Variable-Index.html)
  - [General Index](https://www.gnu.org/software/automake/manual/html_node/General-Index.html)

- [Autoconf](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/index.html)
  - [Autoconf Macro Index](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/Autoconf-Macro-Index.html)
  - [Concept Index](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/Concept-Index.html)

- [GNU Coding Standards](https://www.gnu.org/prep/standards/html_node/)
  - [Variables for Installation Directories](https://www.gnu.org/prep/standards/html_node/Directory-Variables.html)
  - [Standard Targets for Users](https://www.gnu.org/prep/standards/html_node/Standard-Targets.html)
  - [DESTDIR: Support for Staged Installs](https://www.gnu.org/prep/standards/html_node/DESTDIR.html)

这里只列出一部分索引，方便查找，更多索引在官方文档总目录最下方
