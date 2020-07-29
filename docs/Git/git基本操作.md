---
layout: default
title: git基本操作
parent: Git
nav_order: 1
---


# git基本操作
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## git init 初始化仓库
```
$ mkdir test
$ cd test
$ git init
Initialized empty Git repository in /home/king/test/.git/
```
初始化成功后会在当前目录下生成`.git`目录,这个目录里存储着管理当前目录内容所需的仓库数据。

## git status 查看仓库的状态
```
$ git status
On branch master
No commits yet
nothing to commit (create/copy files and use "git add" to track)
```
结果显示当前处于master分支下,新建README.md文件

## git add 向暂存区中添加文件
```
$ git add README.md
$ git status 
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   README.md
```

## git commit 保存仓库的历史记录
git commit命令可以将当前暂存区中的文件实际保存到仓库的历史记录中。通过这些记录，我们就可以在工作树中复原文件。
```
 $ git commit -m "First commit"
[master (root-commit) 10c811a] First commit
 1 file changed, 4 insertions(+)
 create mode 100644 README.md
```
## git log 查看提交日志
```
$ git log
commit 10c811a7b9d674bc837ae87755901d40abda75ad (HEAD -> master)
Author: kingtuo123 <kingtuo123@foxmail.com>
Date:   Mon May 25 10:00:16 2020 +0800

    First commit
```
### 只显示提交信息的第一行
`git log --pretty=short`

### 只显示指定目录、文件的日志
`git log README.md`

### 显示文件的改动
`git log -p`
 后面跟文件可显示指定文件的改动

## git diff 查看更改前后的差别
`git diff`命令可以查看工作树、暂存区、最新提交之间的差别。
在README.md中写点东西
```
$ echo hello >> README.md
```
### 查看工作树和暂存区的差别
```
$ git diff

diff --git a/README.md b/README.md
index d9c0eff..3690dad 100644
--- a/README.md
+++ b/README.md
@@ -6,3 +6,4 @@ hello world
 i'm here

 test
+hello
```
再用`git add`向暂存区中添加README.md,再次执行`git diff`,则没有任何输出

### 查看工作树和最新提交的区别
由于执行了`git add`向暂存区添加了README.md，所以`git diff`会没有输出，所以最好在`git commit`执行前执行以下命令
```
git diff HEAD
```
`git commit`提交的是暂存区的文件，所以在`git add`执行后，如果文件有新的改动则需要重新添加。










