---
layout: default
title: git推送至远程仓库
parent: Git
nav_order: 4
---


# git推送至远程仓库
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## git remote add添加远程仓库
```
$ git remote add origin https://github.com/kingtuo123/myconfig.git
```
以上命令会将远程仓库的名称设置为origin


## git push推送至远程仓库
```
$ git push -u orgin master
```
上面命令将本地的master分支推送到origin主机，同时指定origin为默认主机，后面就可以不加任何参数使用git push了
