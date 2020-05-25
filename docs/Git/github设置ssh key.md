---
layout: default
title: github设置SSH Key
parent: Git
nav_order: 6
---


# github设置SSH Key
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 创建SSH Key
运行下列命令创建SSH Key
```shell
ssh-keygen -t rsa -C "kingtuo123@foxmail.com"
```
邮箱使用github创建时用的邮箱，输出如下，按提示操作
```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/king/.ssh/id_rsa): /home/king/.ssh/github_rsa
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
```
以上会在`～/.ssh`目录下生成`github_rsa`(私钥)和`github_rsa.pub`(公钥)文件

## 添加公钥
查看公钥的内容,执行 `cat github_rsa.pub`
```shell 
ssh-rsa [公钥的内容] kingtuo123@foxmail.com
```
打开github在`setting`->`SSH and GPG keys`中添加SSH Key

## 验证
执行
```bash
ssh -i github_rsa -T git@github.com
```
结果如下为成功
```
The authenticity of host 'github.com (52.74.223.119)' can't be established.
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'github.com,52.74.223.119' (RSA) to the list of known hosts.
Enter passphrase for key 'github_rsa': 
Hi kingtuo123! You've successfully authenticated, but GitHub does not provide shell access.
```
