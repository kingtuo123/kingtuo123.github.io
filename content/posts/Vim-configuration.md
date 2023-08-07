---
author: "kingtuo123"
title: "Vim 配置"
date: "2022-06-12"
description: ""
summary: "Linux下Vim插件管理/安装配置"
categories: [  "vim","linux" ]
tags: [ "vim","linux" ]
---

## 安装 [vim-plug](https://github.com/junegunn/vim-plug)

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

在 `.vimrc` 中添加插件，格式如下：

```vimrc
call plug#begin()

Plug '<插件>'

call plug#end()
```

| Command | Description |
| -- | -- |
| `PlugInstall [name ...] [#threads]` | 安装插件 |
| `PlugUpdate [name ...] [#threads]` | 安装或更新插件 |
| `PlugClean[!]` | 删除未列出的插件 |
| `PlugUpgrade` | 升级 vim-plug |
| `PlugStatus` | 检查插件的状态 |
| `PlugDiff` | 检查上一次更新的更改和待处理的更改 |
| `PlugSnapshot[!] [output path]` | 生成用于恢复当前插件快照的脚本 |

## 常用插件


外观及主题：

```
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'arcticicestudio/nord-vim'
```

常用插件的替代品：

- `NERDTree`：可以用 `vim` 自带的 `netrw` 替代
- `YouCompleteMe`：用 `ctrl-p` 和　`ctrl-n` 替代




















