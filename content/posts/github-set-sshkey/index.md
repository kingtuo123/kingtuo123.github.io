---
title: "Github 设置 SSH Key"
date: "2021-01-02"
description: ""
summary: "通过 ssh 来操作 github 仓库"
categories: [ "github" ]
tags: [ "github" ]
---


## 创建SSH Key
运行下列命令创建SSH Key，邮箱使用github创建时用的邮箱。

```text
ssh-keygen -t rsa -C "kingtuo123@foxmail.com"
```

输出如下，一路回车

```text
Generating public/private rsa key pair.
Enter file in which to save the key (/home/king/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
```

以上会在 `～/.ssh` 目录下生成 `id_rsa` （私钥）和 `id_rsa.pub` （公钥）文件。

## 配置 SSH 私钥路径

`ssh` 默认使用的私钥文件定义在 `/etc/ssh/ssh_config` 或 `~/.ssh/config`

```bash
#   这里是默认身份文件路径
#   IdentityFile ~/.ssh/id_rsa
#   IdentityFile ~/.ssh/id_dsa
#   IdentityFile ~/.ssh/id_ecdsa
#   IdentityFile ~/.ssh/id_ed25519
```

为 `github.com` 指定密钥, 修改 `~/.ssh/config` , 添加下列内容:

```
Host github.com
 IdentityFile /home/user/.ssh/github/id_rsa
```





## 添加公钥
查看公钥的内容

```bash
cat ~/.ssh/id_rsa.pub
```

打开 `github` 主页在 **setting -> SSH and GPG keys** 中添加SSH Key，将上面的输出复制进去。

## 验证

```bash
ssh -T git@github.com

# 指定rsa路径
ssh -i <rsa path> -T git@github.com
```

返回如下信息则配置成功

```text
You've successfully authenticated, but GitHub does not provide shell access
```
## 使用SSH Key推送

<div align="left">
    <img src="git.png" style="max-height:200px"></img>
</div>

使用以上的链接。
