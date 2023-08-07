---
author: "kingtuo123"
title: "Samba 安装及配置"
date: "2022-09-03"
summary: "Samba 安装及配置，配置文件常用参数及用法"
description: ""
categories: [ "linux" ]
tags: [ "samba" ]
math: false
---

- 参考文章
  - [Samba](https://wiki.gentoo.org/wiki/Samba)
  - [Samba.conf](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html)
  - [linux网络共享服务Samba服务器配置和应用](https://zhuanlan.zhihu.com/p/375925918)
  - [Linux Samba服务主配文件smb.conf中文详解](https://www.cnblogs.com/fatt/p/5856892.html)
  - [Samba配置文件常用参数详解](https://blog.51cto.com/yuanbin/115761)
  - [如何添加Samba用户](https://www.cnblogs.com/liulipeng/p/3406352.html)
## 安装

### 内核配置

```
File Systems --->
    [*] Network File Systems --->
        [*] CIFS support (advanced network filesystem, SMBFS successor)--->
            [*] CIFS Statistics
                [*] Extended Statistics
            [*] CIFS Extended Attributes
                [*] CIFS POSIX Extentions
            [*] SMB2 and SMB3 network file system support
```

### Emerge

安装 Samba：

```
# emerge --ask --noreplace net-fs/samba
```

## 用法


### OpenRc

添加开机启动：

```
# rc-update add samba default
```

启动服务：

```
# eselect rc start samba
```

### 列出局域网内工作组

```
# nmblookup -S __SAMBA__
# smbtree -D
```

### 查看工作组内可用主机

```
# nmblookup -T <WORKGROUP>
# nmblookup -S <WORKGROUP>
# smbtree -S
```

### 挂载共享的文件夹

手动挂载：

```
# mount.cifs //O2-Foobar/Shared /mnt/My-Disk/Shared -o guest
```

开机自动挂载，编辑 `/etc/fstab`：

```
//O2-Foobar/Shared /mnt/My-Disk/Shared cifs guest
```

### 添加Samba用户

**添加的Samba用户首先必须是Linux用户**

- 用户密码管理工具：`smbpasswd`
  - -a：向smbpasswd文件中添加用户
  - -c：指定samba的配置文件
  - -x：删除用户
  - -d：禁用用户，无法登录
  - -e：激活用户
  - -n：将指定用户密码置空，要在 [global] 中写入 null passwords = yes

## 配置文件

**主配置文件 `/etc/samba/smb.conf`**

### 示例配置

```
[global]
workgroup = Home
netbios name = king's laptop
server string = king's SambaServer
display charset = UTF8
interfaces = wlp2s0
hosts allow = 192.168.1.
deadtime = 10
log file = /var/log/samba/log.%m
max log size = 50
map to guest = Bad User
max connections = 0

# 可guest登录，可读，指定用户可写
[public]
path = /home/king/Public
security = share
public = yes
writable = yes
write list = king
available = yes
browseable = yes

# 需要用户登录，可读写
[private]
path = /home/king
public = no
valid users = king
create mask = 0664
directory mask = 0775
available = yes
browseable = yes
writable = yes
write list = king
```

### 常用参数

- **[global]**
  - samba服务器的全局设置，对整个服务器有效。

- **workgroup = WORKGROUP**
  - 设定 Samba Server 所要加入的工作组或者域。

- **server string = Samba Server Version %v**
  - 其他 Linux 主机查看共享时的提示符。

- **netbios name = MYSERVER**
  - 用于在 Windows 网上邻居上显示的主机名

- **interfaces = lo eth0 192.168.12.2/24 192.168.13.2/24**
  - 设置Samba Server监听哪些网卡，可以写网卡名，也可以写该网卡的IP地址。

- **hosts allow = 127. 192.168.1. 192.168.10.1**
  - 表示允许连接到Samba Server的客户端，多个参数以空格隔开。可以用一个IP表示，也可以用一个网段表示。hosts deny 与hosts allow 刚好相反。

- **max connections = 0**
  - 最大连接数目。0表示不限制。

- **deadtime = 0**
  - 设置断掉一个没有打开任何文件的连接的时间。单位是分钟，0代表Samba Server不自动切断任何连接。

- **log file = /var/log/samba/log.%m**
  - 设置Samba Server日志文件的存储位置以及日志文件名称。在文件名后加个宏%m（主机名），表示对每台访问Samba Server的机器都单独记录一个日志文件。

- **max log size = 50**
  - 设置Samba Server日志文件的最大容量，单位为kB，0代表不限制。

- **security = user**
  - share：不需要提供用户名和密码。
  - user：需要提供用户名和密码，而且身份验证由 samba server 负责。
  - server：需要提供用户名和密码，可指定其他机器(winNT/2000/XP)或另一台 samba server作身份验证。
  - domain：需要提供用户名和密码，指定winNT/2000/XP域服务器作身份验证。

- **map to guest = Never**
  - Never：无效的密码或账户不存在将被拒绝登录（默认）
  - Bad User：如果账户不存在，则使用 guest 登录
  - Bad Password：密码无效或账户不存在，则使用 guest 登录
  - Bad Uid：\<Unknow\>

- **comment = 任意字符串**
  - comment是对该共享的描述，可以是任意字符串。

- **path = /var/test**
  - 共享目录路径

- **veto files = /foo/\*bar\*/**
  - 隐藏文件，斜杠表示分隔符，`foo` 和 `*bar*` 匹配的文件不会在共享中显示

- **writable = yes/no**
  - 指定该共享是否可写。

- **available = yes/no**
  - 是否可连接，no 将拒绝所有连接请求。

- **browseable = yes/no**
  - 指定该共享是否可以浏览。

- **valid users = smbuser,root**
  - 允许访问该共享的用户

- **directory mask = 0775**
  - 默认创建目录权限 rwxrwxr_x

- **create mask = 0775**
  - 默认创建文件权限 rwxrwxr_x

- **public = yes/no**
  - 允许guest用户访问，同 `guest ok = yes/no`

- **guest account = nobody**
  - 设置匿名账户为nobody

- **write list = smbuser,root**
  - 有写入权限的用户列表

- **deadtime = 10**
  - 客户端在10分钟内没有打开任何 Samba 资源，服务器将自动关闭会话

- **display charset = UTF8**
  - 设置显示的字符集

- **null passwords = yes/no**
  - 允许或禁止客户端访问具有空密码的帐户

- **include = /usr/local/samba/lib/admin_smb.conf**
  - 包含外部其他的配置文件

- **config file = /usr/local/samba/lib/smb.conf.%m**
  - 在该配置文件的基础上覆盖参数配置
