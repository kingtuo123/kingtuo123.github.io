---
title: "Udev Rules 设备管理"
date: "2024-11-07"
summary: "udev (user /dev) 是 systemd 的 Linux 内核设备管理器"
description: ""
categories: [ "linux" ]
tags: [ "udev" ]
---

参考文章

- [Writing udev rules](https://www.reactivated.net/writing_udev_rules.html)
- [Udev / ArchWiki](https://wiki.archlinux.org/title/Udev)
- [Udev / GentooWiki](https://wiki.gentoo.org/wiki/Udev)
- [man udev](https://man.archlinux.org/man/udev.7)


## 概述
`udev` (user /dev) 是 `systemd` 的 Linux 内核设备管理器

`udev` 用于管理 `/dev` 目录下的设备节点，`udev` 依赖于 `sysfs` 提供的信息与用户提供的规则的匹配信息。

`sysfs` 文件系统由内核管理，挂载在 `/sys` 目录下，用于导出系统中设备的基本信息。

`udev` 使用此信息创建与硬件对应的 `/dev` 目录下的设备节点。

## 目录

规则文件保存在以下目录，以 `.rules` 结尾： 

- `/etc/udev/rules.d`，管理员编写的规则文件，高优先级，同名则覆盖 `/lib` 中的规则

- `/lib/udev/rules.d` 或 `/usr/lib/udev/rules.d`，各种软件包附带的规则，用户通常不应更改它们

要禁用规则文件，可以在 `/etc` 中创建一个与 `/lib` 中的 `rules` 文件同名的符号链接，指向 `/dev/null`

## 规则语法

- 每个规则都由一系列**键值对**构成，键值对之间用逗号分隔。

- 每个规则应包含至少一个**匹配键**和至少一个**分配键**。

- **匹配键**是用于标识规则所作用于的设备的条件。

- 当规则中的所有**匹配键**都与正在处理的设备相**对应**时，将**应用**该规则并调用**分配键**的操作。


```bash
KERNEL=="hdb", NAME="my_spare_disk"
```

上述规则包含一个匹配键 `KERNEL` 和一个分配键 `NAME`。
匹配键通过比较相等运算符 `==` 与其值相关，而分配键通过赋值运算符 `=` 与其值相关。

> 注意：udev 不支持任何形式的换行。
> 不要在规则中插入任何换行符，因为这会导致 udev 将你的一个规则视为多个规则，并且不会按预期工作。

## 操作符

<div class="table-container">

|||
|:--|:--|
|`==`|比较相等|
|`!=`|比较不相等|
|`=` |为键分配值，表示列表的键将被重置，并且仅分配此单个值|
|`+=`|将值添加到包含条目列表的键中|
|`-=`|从包含条目列表的键中删除该值|
|`:=`|为键赋值，并禁止之后对键的改动|

</div>

## 基本规则

常用的匹配键：

- **ACTION**：匹配设备事件，如设备连接/断开（add/remove）
- **KERNEL**：与设备的 KERNEL 名称匹配
- **SUBSYSTEM**：与设备的 SUBSYSTEM 名称匹配
- **DRIVER**：与支持设备的 DRIVER 名称匹配

常用的分配键：

- **NAME**：应用于设备节点的名称
- **SYMLINK**：用作设备节点的替代名称的符号链接列表


```bash
KERNEL=="hdb", NAME="my_spare_disk"
```

上面的规则是：匹配一个被内核命名为 `hdb` 的设备，
并将设备节点重命名为 `my_spare_disk`。设备节点显示在 `/dev/my_spare_disk` 中。

```bash
KERNEL=="hdb", DRIVER=="ide-disk", SYMLINK+="sparedisk"
```

上面的规则是：匹配一个被内核命名为 `hdb` 且驱动程序为 `ide-disk` 的设备。
使用默认名称命名设备节点，并创建一个名为 `/dev/sparedisk` 的符号链接。

```bash
KERNEL=="hdc", SYMLINK+="cdrom cdrom0"
```

上面的规则是：在 `/dev/cdrom` 和 `/dev/cdrom0` 处创建两个符号链接，这两个链接都指向 `/dev/hdc`

## 匹配 sysfs 属性

驱动程序会将设备的高级属性信息（如供应商代码、编号、序列号等）导出到 `sysfs` 中，
`udev` 通过 `ATTR` 键匹配这些属性以实现更精细的控制，如下：

```bash
SUBSYSTEM=="block", ATTR{size}=="234441648", SYMLINK+="my_disk"
```

## 查看设备属性

如果你知道设备的名称，如 `/dev/sda`：

```bash-session
# udevadm info --attribute-walk --name=/dev/sda
looking at device '/devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0/block/sda':
    KERNEL=="sda"
    SUBSYSTEM=="block"
    DRIVER==""
    ATTR{alignment_offset}=="0"
    ATTR{capability}=="0"
    ...
```

如果不知道设备名称，使用以下命令监听，并插入设备，获取 sys 路径（即 DEVPATH）：

```bash-session
# udevadm monitor
UDEV  [44538.479869] add      /devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0/block/sda (block)
UDEV  [44538.501998] add      /devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0/block/sda/sda1 (block)
UDEV  [44538.502199] add      /devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0/block/sda/sda2 (block)
...
# udevadm info --attribute-walk --path=/devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0/block/sda
```

其中 `add` 表示设备连接事件，可以用 `ACTION` 匹配这个事件

更多方法参考：[List the attributes of a device](https://wiki.archlinux.org/title/Udev#List_the_attributes_of_a_device)


## 查看设备信息

```bash-session
# udevadm info --query=all --name=/dev/sda
P: /devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0/block/sda
M: sda
U: block
T: disk
D: b 8:0
N: sda
L: 0
S: disk/by-diskseq/6
S: disk/by-path/pci-0000:c6:00.3-usb-0:1.2:1.0-scsi-0:0:0:0
S: disk/by-id/usb-Kingston_HyperX_Fury_3.0_60A44C426695BF513B4E6EBC-0:0
S: my_disk
S: disk/by-path/pci-0000:c6:00.3-usbv3-0:1.2:1.0-scsi-0:0:0:0
Q: 6
E: DEVPATH=/devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0/block/sda
E: DEVNAME=/dev/sda
E: DEVTYPE=disk
E: DISKSEQ=6
E: MAJOR=8
...
```

## 设备层次结构

Linux 内核以树状结构表示设备，这些信息通过 `sysfs` 公开，在 `/sys` 目录下可以找到对应的设备文件。

例如下面命令可以看出 `sda` 有许多 `parent device`：

```bash-session
# udevadm info --attribute-walk --name=/dev/sda
looking at device '/devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0/block/sda':
    KERNEL=="sda"
    SUBSYSTEM=="block"
    DRIVERS==""
    ...
looking at parent device '/devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0':
    KERNELS=="0:0:0:0"
    SUBSYSTEMS=="scsi"
    DRIVERS=="sd"
    ...
looking at parent device '/devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0':
    KERNELS=="target0:0:0"
    SUBSYSTEMS=="scsi"
    DRIVERS==""
    ...
# ls /sys/devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb2/2-1/2-1.2/2-1.2:1.0/host0/target0:0:0/0:0:0:0/block/sda
alignment_offset  discard_alignment  ext_range  partscan   ro      stat
bdi               diskseq            hidden     power      sda1    subsystem
...
```

以下匹配键可以在设备树中向上搜索，匹配设备或其任何父设备：

- **KERNELS**：与设备的内核名称或任何父设备的内核名称匹配
- **SUBSYSTEMS**：与设备的 subsystem 或任何父设备的 subsystem 匹配
- **DRIVERS**：与支持设备的驱动程序的名称或支持任何父设备的驱动程序的名称匹配
- **ATTRS**：匹配设备的 sysfs 属性或任何父设备的 sysfs 属性


## 字符串替换

类似 `printf` 的字符串格式化输出：

```bash
KERNEL=="mice", NAME="input/%k"
KERNEL=="loop0", NAME="loop/%n", SYMLINK+="%k"
```

- **$kernel, %k**：此设备的内核名称
- **$number, %n**：此设备的内核编号；例如 sda3 的内核编号为 3
- **$devpath, %p**：设备的 devpath
- **$result, %c**：使用 PROGRAM 请求的外部程序返回的字符串

更多参考：[man udev](https://man.archlinux.org/man/udev.7)

## 字符串匹配

- `*`：匹配任何字符，零次或多次
- `?`：匹配一个任何字符
- `[]`：匹配括号中指定的任何单个字符，也允许范围

```bash
KERNEL=="fd[0-9]*", NAME="floppy/%n", SYMLINK+="%k"
KERNEL=="hiddev*", NAME="usb/%k"
```

第一条规则匹配所有软盘驱动器，并确保设备节点位于 `/dev/floppy` 目录中，并从默认名称创建符号链接。

第二条规则确保 hiddev 设备仅存在于 `/dev/usb` 目录中。


## 控制权限与所有权

`GROUP` 定义设备属组：

```bash
KERNEL=="fb[0-9]*", NAME="fb/%n", SYMLINK+="%k", GROUP="video"
```

`OWNER` 定义设备所有者：

```bash
KERNEL=="fd[0-9]*", OWNER="john"
```

`MODE` 定义设备权限：

```bash
KERNEL=="inotify", NAME="misc/%k", SYMLINK+="%k", MODE="0666"
```

## 使用外部程序命名设备

`%c` 是 `PROGRAM` 请求的外部程序返回的字符串：

```bash
KERNEL=="hda", PROGRAM="/bin/device_namer %k", SYMLINK+="%c"
```

假定 `device_namer` 输出两个部分，第一个部分是设备名称，第二个部分是其他符号链接的名称。
可以使用 `%c{N}` 替换，表示输出的第 N 部分：

```bash
KERNEL=="hda", PROGRAM="/bin/device_namer %k", NAME="%c{1}", SYMLINK+="%c{2}"
```

假设 `device_namer` 输出 `device name` 的 `%c{1}` 部分，后跟任意数量的部分，使用 `%c{N+}` 替换：

```bash
KERNEL=="hda", PROGRAM="/bin/device_namer %k", NAME="%c{1}", SYMLINK+="%c{2+}"
```

## 在某些事件上运行外部程序

当 `KERNEL` 匹配成功则执行 `my_program`，设备连接或断开都会触发：

```bash
KERNEL=="sdb", RUN+="/usr/bin/my_program"
```

仅当设备连接时触发：

```bash
ACTION=="add", KERNEL=="sdb", RUN+="/usr/bin/my_program"
```

仅当设备断开时触发：

```bash
ACTION=="remove", KERNEL=="sdb", RUN+="/usr/bin/my_program"
```
> 不要将 RUN 与 PROGRAM 功能混淆。
> PROGRAM 用于运行生成设备名称的程序（它们不应该做任何其他事情）。 PROGRAM 执行时，尚未创建设备节点，因此无法以任何方式对设备执行操作。


## 环境变量

为环境变量 `some_var` 赋值 `value`：

```bash
KERNEL=="fd0", SYMLINK+="floppy", ENV{some_var}="value"
```

匹配环境变量 `an_env_var` 等于 `yes`：

```bash
KERNEL=="fd0", ENV{an_env_var}=="yes", SYMLINK+="floppy"
```

## 测试规则

指定设备的路径：

```bash-session
# udevadm test /sys/class/backlight/acpi_video0/
```

## 加载规则

重新加载 udev 规则：

```bash-session
# udevadm control --reload
```

手动触发规则：

```bash-session
# udevadm trigger
```

## 实例

当 `u盘` 插入时以 larry 用户身份执行程序，`/etc/udev/rules.d/10-usb.rules`：

```bash
ACTION=="add", KERNEL=="sd*", SUBSYSTEM=="block", RUN+="/usr/bin/su larry -c /usr/local/bin/my_program"
```
