---
title: "OpenOCD"
date: "2023-08-13"
description: ""
summary: "Open On-Chip Debugger 开源片上调试器" 
categories: [ "linux", "stm32" ]
tags: [ "" ]
---

## 启动 OpenOCD

OpenOCD 需要读取配置文件启动，通常安装目录下自带了配置文件

调试器配置文件路径：`/usr/share/openocd/scripts/interface/`

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

```bash-session {hl_lines=[4,5,12]}
$ openocd -f stlink.cfg -f stm32f1x.cfg
Open On-Chip Debugger 0.12.0
Licensed under GNU GPL v2
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Info : clock speed 1000 kHz
Info : STLINK V2J38S7 (API v2) VID:PID 0483:3748
Info : Target voltage: 3.178506
Info : [stm32f1x.cpu] Cortex-M3 r1p1 processor detected
Info : [stm32f1x.cpu] target has 6 breakpoints, 4 watchpoints
Info : starting gdb server for stm32f1x.cpu on 3333
Info : Listening on port 3333 for gdb connections
```

> OpenOCD 启动后默认会打开 3 个端口：`3333`，`4444`，`6666`

> 可以使用 `netstat -ltpn | grep openocd` 命令查看端口

### 方法二

OpenOCD 默认读取当前目录下的配置文件 `openocd.cfg`，写入下面内容：

```tcl
source [find interface/stlink.cfg]
source [find target/stm32f1x.cfg]
```

然后在当前目录下运行 `openocd`  即可



## 使用 telnet 连接

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

> 更多指令参考：[General Commands](https://openocd.org/doc/html/General-Commands.html)




## 使用 gdb 连接

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

### gdb 常用指令

```bash-session
$ gdb

> load               # 下载程序 
> run                # 从头运行程序
> break main         # main 函数设置断点
> break 14           # 第14行设置断点
> break 14 if a = 2  # 当变量a=2在14行打断
> delete breakpoints # 删除所有断点
> step               # 执行一条C语句，进入函数
> next               # 执行一条C语句，不进入函数
> stepi              # 执行一条汇编语句，进入函数
> nexti              # 执行一条汇编语句，不进入函数
> continue           # 继续执行
> print a            # 打印变量a
> until              # 跳出循环
> finish             # 跳出当前函数
> call func(1,2)     # 直接调用func函数

> tui enable         # 打开字符图形窗口
> tui disable        # 关闭字符图形窗口
> tui reg all        # 在窗口中显示所有寄存器
> info win           # 查看有哪些窗口
> focus cmd          # 聚焦到cmd窗口
> winheight src -2   # 调整源码窗口高度-2
> layout next        # 显示下一个窗口
```

