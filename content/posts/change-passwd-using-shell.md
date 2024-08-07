---
title: "Shell 脚本修改密码"
date: "2024-07-01"
description: ""
summary: "在终端无法交互的情况下，通过 shell 脚本修改密码"
categories: [ "linux" ]
tags: [ "linux" ]
---


## 目的

在终端无法交互的情况下，通过 shell 脚本修改密码。

## 使用管道符

以下方法均在 root 用户下执行

方法一：

```bash-session
# echo 用户名:密码 | chpasswd
```

方法二：

```bash-session
# echo -e "密码\n密码" | passwd 用户名
```

方法二在 docker build 中会直接打印 `\n`，原因待探究。

## USERMOD 命令

```bash-session
# usermod -p `openssl passwd -6 密码` 用户名
```

openssl passwd 参数：

```text
-1：基于 MD5 的密码算法
-5：基于 SHA256 的密码算法
-6：基于 SHA512 的密码算法（推荐）
-salt：使用指定盐值，不指定则随机生成盐值
```

目前主流 Linux 发行版采用 yescrypt 加密，openssl 不支持此加密，详见 [openssl issue 19340](https://github.com/openssl/openssl/issues/19340)

## 添加用户的同时指定密码

```bash-session
# useradd -m -s /bin/bash -u 1000 -p `openssl passwd -6 密码` 用户名
```

useradd 参数：

```text
-m：如果用户的主目录不存在，则创建它
-s：用户登录的 shell
-u：用户 uid
-p：加密后的密码
```


## 相关文件

### /etc/shadow


共 9 个字段：

```text
user:$1$AokRr$Fe2970fZE64eYgCIArCR7w3A0:19905:0:99999:7:::

1. 用户名
2. 加密密码
3. 上次密码修改时间，从 1970 年 1 月 1 日起计算，单位：天
4. 最小修改密码间隔的天数
5. 密码有效天数
6. 密码需要变更前的警告天数
7. 密码过期后的宽限天数
8. 账号失效时间，从 1970 年 1 月 1 日起计算，单位：天
9. 保留字段
```

可以使用 `chage` 命令，更改/查看密码的相关信息

字段 2 密码的格式如下，由 `$` 分隔：

```text
$1$Qtc6Dw1X$BgJqQSPrinLaJ9pTJ09lI1
[-][------][---------------------]
 |     |              |
 |     |              +-> 加密后的密码
 |     +----------------> salt
 +----------------------> $1：md5
                          $5：sha256
                          $6：sha512
                          $y：yescrypt
```


### /etc/passwd

共 7 个字段：

```text
mark:x:1001:1001:mark,,,:/home/mark:/bin/bash
[--][-][--] [--] [-----] [--------] [--------]
|    |   |    |     |         |        |
|    |   |    |     |         |        +-> 7. 登陆 shell
|    |   |    |     |         +----------> 6. 家目录
|    |   |    |     +--------------------> 5. GECOS，存储用户信息（姓名、电话等）
|    |   |    +--------------------------> 4. 组 id
|    |   +-------------------------------> 3. 用户 id
|    +-----------------------------------> 2. x 表示此用户设有密码，密码保存在 /etc/shadow
+----------------------------------------> 1. 用户名
```

### /etc/group

共 4 个字段：

```text
wheel:x:10:root,king
[---][-][-][-------]
  |   |  |     |
  |   |  |     +------> 4. 组中的用户，逗号分隔
  |   |  +------------> 3. 组 id
  |   +---------------> 2. 组密码，x 仅仅是密码标识，组密码保存在 /etc/gshadow
  +-------------------> 1. 组名
```
