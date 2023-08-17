---
title: "Vim ctags taglist"
date: "2023-08-12"
description: ""
summary: "使用 ctags 轻松索引"
categories: [ "linux" ]
tags: [ "vim" ]
---


## 安装 ctags taglist

```
# emerge -av dev-util/ctags app-vim/taglist
```

## 使用 ctags 生成索引

在你的项目根目录中执行，会生成 tags 文件

```bash-session
$ ctags -R *
$ ls -l tags
-rw-r--r-- 1 user user 1273357 Aug 12 12:11 tags
```

## 在 vim 中使用 ctag 跳转

运行 vim 时，必须在 `tags` 文件所在的目录下运行 。


### 在文件内跳转

将光标移动到函数或变量上，再按快捷键 `Ctrl + ]`，可直接跳转到定义处，按 `Ctrl + T` 可返回原处

### 命令行跳转

使用 `vim -t  函数名` 即可打开文件直接跳转到函数定义处

```
$ vim -t main
```

## 在 vim 中使用 taglist 

vim 命令模式下输入 `:Tlist` 即可打开，再次输入关闭

### taglist 配置

```vimrc
let Tlist_Show_One_File=1               " 不同时显示多个文件的 tag，只显示当前文件的
let Tlist_Exit_OnlyWindow=1             " 如果 taglist 窗口是最后一个窗口，则退出vim
let Tlist_Ctags_Cmd="/usr/bin/ctags"    " 将 taglist 与 ctags 关联
```

### taglist 快捷键

|快捷键|说明|
|:--|:--|
|回车|跳转到 tag 定义处|
|空格|在 vim 底部显示 tag 的函数原型|
|o|新窗口打开关标下的 tag|
|p|跳转到 tag 的定义处，但光标仍留在 taglist 窗口内|
|u|更新窗口中的 tag|
|s|更改排序方式，按名字排序，按出现顺序排序，之间切换|
|x|窗口放大和缩小|
|+|打开一个折叠，同 `zo`|
|-|将 tag 折叠，同 `zc`|
|\*|打开所有折叠，同 `zR`|
|=|折叠所有 tag，同 `zM`|
|[[|跳到前一个文件|
|]]|跳到后一个文件|
|q|关闭窗口|
|F1|显示帮助|

