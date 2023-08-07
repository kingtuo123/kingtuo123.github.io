---
author: "kingtuo123"
title: "git 基础 - 常用命令"
date: "2022-06-15"
description: "Note"
summary: ""
categories: [ "git" ]
tags: [ "git" ]
---

## Git 设置

配置文件  `/etc/gitconfig`

当前用户配置文件 `~/.gitconfig`  或 `~/.config/git/config`

当前仓库配置文件 `.git/config`

后面配置会覆盖上层的配置

账号设置：

``` bash
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
git config --global core.editor vim
```



git diff 查看改动

git status 查看状态

git log 查看commit历史

```
git reset --hard commit_id
```

`git reflog` 查看命令历史



