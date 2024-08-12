---
title: "OpenOCD + GDB 调试"
date: "2023-08-13"
description: ""
summary: "Open On-Chip Debugger 开源片上调试器" 
categories: [ "embedded" ]
tags: [ "stm32", "openocd", "gdb" ]
---

## 启动 OpenOCD

OpenOCD 需要读取配置文件启动，通常安装目录下自带了配置文件

接口配置文件路径：`/usr/share/openocd/scripts/interface/`

```bash-session
$ ls /usr/share/openocd/scripts/interface/ | grep stlink
stlink.cfg
stlink-dap.cfg
stlink-v1.cfg
stlink-v2-1.cfg
stlink-v2.cfg
```

芯片配置文件的路径：`/usr/share/openocd/scripts/target/`

```bash-session
$ ls /usr/share/openocd/scripts/target/ | grep stm32f
stm32f0x.cfg
stm32f1x.cfg
stm32f2x.cfg
stm32f3x.cfg
stm32f4x.cfg
stm32f7x.cfg
```

### 方法一

将需要的配置文件拷贝到当前目录下，使用 `-f` 参数指定配置文件启动：

```bash-session
$ openocd -f stlink.cfg -f stm32f1x.cfg
```

- OpenOCD 启动后默认会打开 3 个端口：`3333`（gdb），`4444`（telnet），`6666`（tcl）

- 可以使用 `netstat -ltpn | grep openocd` 命令查看端口

### 方法二

OpenOCD 默认读取当前目录下的配置文件 `openocd.cfg`，写入下面内容：

```tcl
source [find interface/stlink.cfg]
source [find target/stm32f1x.cfg]
```

然后在当前目录下运行 `openocd`  即可



## 使用 Telnet 连接

```console
$ telnet localhost 4444
Open On-Chip Debugger
> reset    # 复位
> init     # 初始化设备
> halt     # 停止运行
> step     # 单步执行
> resume   # 恢复运行
> step 0x08000648 # 运行到地址0x08000648处后单步执行

> reset run  # 复位并立即运行
> reset halt # 复位并立即停止
> reset init # 复位并立即初始化

> halt                                            # 写入程序前要先停止设备
> program ./target.hex                            # 写入 hex
> program ./target.bin 0x08000000                 # 写入 bin
> flash write_image erase ./target.hex            # 擦除后写入 hex 文件
> flash write_image erase ./target.bin 0x08000000 # 擦除后写入 bin 文件

> reg                      # 列出所有寄存器
> halt                     # 停止设备
> set_reg {pc 0 sp 0x1000} # 写PC,SP寄存器
> get_reg {pc sp}          # 读PC,SP寄存器
pc 0x00000000 sp 0x00001000

> write_memory 0x20000000 32 {0xdeadbeef 0x00230500}  # 向内存写入两个32位数据
> read_memory 0x20000000 32 2                         # 读取两个32位数据
0xdeadbeef 0x230500

> mdd 0x08000000 1 # 读1个64位的数据
> mdw 0x08000000 1 # 读1个32位的数据
> mdh 0x08000000 1 # 读1个16位的数据
> mdb 0x08000000 1 # 读1个 8位的数据

> mwd 0x20000000 0xaaaabbbbccccdddd # 写1个64位的数据
> mww 0x20000000 0xaaaabbbb         # 写1个32位的数据
> mwh 0x20000000 0xaaaa             # 写1个16位的数据
> mwb 0x20000000 0xaa               # 写1个 8位的数据

> bp                 # 查看所有断点
> bp 0x08000648 2 hw # 在地址0x08000648处设置硬件断点
> rbp 0x08000648     # 删除该地址的断点
> rbp all            # 删除所有断点

> exit # 退出
```

更多指令参考：[General Commands](https://openocd.org/doc/html/General-Commands.html)




## 使用 GDB 连接

### 方法一

```bash-session
$ gdb ./target.elf
GNU gdb (Gentoo 13.2 vanilla) 13.2
Copyright (C) 2023 Free Software Foundation, Inc.
...
> target extended-remote localhost:3333
> target extended-remote :3333
本地连接可省略 localhost
```

### 方法二

修改 gdb 配置文件 `/home/user/.config/gdb/gdbinit`：

```bash
# 允许 gdb 加载任意路径下的 .gdbinit 文件
set auto-load safe-path /
```

切换到你的工程目录下，创建 `.gdbinit` 文件：

```bash
file "./target.elf"
target extended-remote :3333
# 下载程序
load
# main 函数设置断点
break main
# 运行程序
continue
```

然后当前目录下运行 `gdb` 即可


## GDB 常用指令

<div class="table-container">

|指令|简写|说明|
|:--|:--|:--|
|`help`|`h`|打印帮助信息|
|||`h next` ：打印 next 指令的用法说明|
|`file`||指定程序文件|
|`load`||加载 file 指定的程序文件|
|`break`|`b`|设置断点|
|||`b main` ：在 main 函数处设置断点|
|||`b 10` ：在第 10 行设置断点|
|||`b test.c:10` ： 在 test.c 的第 10 行设置断点|
|||`b if a == 1` ： 当 a 等于 1 时打断|
|`tbreak`|`tb`|设置临时断点，只作用一次|
|`info`|`i`|显示调试信息|
|||`i b` ：显示所有断点|
|||`i display` ：显示所有表达式|
|`delete`|`d`|删除断点等|
|||`d` ：删除所有断点|
|||`d 2` ：删除 2 号断点|
|`run`|`r`|从头开始执行程序|
|`next`|`n`|执行一条 C 语句，不进入函数|
|`step`|`s`|执行一条 C 语句，进入函数|
|`nexti`|`ni`|执行一条汇编语句，不进入函数|
|`stepi`|`si`|执行一条汇编语句，进入函数|
|`continue`|`c`|继续执行|
|`finish`|`fin`|跳出当前函数|
|`until`|`u`|跳出当前循环|
|`backtrace`|`bt`|打印所有栈帧|
|`frame`|`f`|打印当前栈帧|
|`print`|`p`|打印变量或表达式的值|
|`display`||增加要显示值的表达式|
|`call`||调用函数|
|||`call func(1, 2)` ：调用 func 函数|
|`tui enable`|`-`|启用字符图形窗口|
|||`focus cmd` ：聚焦到 cmd 窗口|
|||`layout asm` ：显示汇编窗口，其他还有 src、regs、split|
|||`winheight src -2` ：调整源码窗口高度-2|

</div>
