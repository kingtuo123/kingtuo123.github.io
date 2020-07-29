---
layout: default
title: git分支操作
parent: Git
nav_order: 2
---


# git分支操作
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## git branch 显示分支一览表 
```
$ git branch
* master
```
`*`表示当前所在分支

## git checkout -b 创建分支
创建名为feature-A的分支
```
$ git checkout -b feature-A
Switched to a new branch 'feature-A'
```
在分支下的`git add`等操作不会影响到主分支

## git checkout 切换分支
切换到主分支
```
git check master
```
切换到上一分支
```
git check -
```

## git merge 合并分支
```
git merge --no-ff feature-A
```
`git merge` 相关参数
```
--ff       快速合并(fast-forward)，这个是默认的参数。如果合并过程出现冲突，Git会显示出冲突并等待手动解决
--ff-only  只有能快速合并的情况才合并。如果合并过程出现冲突，Git会自动abort此次merge
--no-ff    不使用fast-forward方式合并，会生成一次新的提交记录,保留分支的commit历史
--squas    把多次分支commit历史压缩为一次
```

## git log --graph 以图表形式查看分支
```
$git log --graph

*   commit c62e68678e014db91bd54b034114a0c0b34c57ac (HEAD -> master)
|\  Merge: 2d5828b 7d1003a
| | Author: kingtuo123 <kingtuo123@foxmail.com>
| | Date:   Mon May 25 14:10:57 2020 +0800
| |
| |     Merge branch 'feature-A'
| |
| * commit 7d1003abe0a6af61eae4a45319b853d24ed381f8 (feature-A)
|/  Author: kingtuo123 <kingtuo123@foxmail.com>
|   Date:   Mon May 25 13:04:05 2020 +0800
|
|       fafafa
|
* commit 10c811a7b9d674bc837ae87755901d40abda75ad
  Author: kingtuo123 <kingtuo123@foxmail.com>
  Date:   Mon May 25 10:00:16 2020 +0800

      First commit
```

