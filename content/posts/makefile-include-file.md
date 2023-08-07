---
title: "Makefile 头文件依赖"
date: "2022-06-10"
description: "Makefile 的规则中为何要包含头文件依赖"
summary: "Makefile 的规则中为何要包含头文件依赖"
categories: [ "makefile" ]
tags: [ "makefile" ]
---

## Note

之前学习 makefile 时发现不需要使用 gcc 的 `-MMD` 参数生成的依赖关系，程序也能编译通过。因为只要你的 makefile 中包含了头文件的路径，编译器在编译时会自动找到这个头文件。

本以为可以省去生成依赖关系这一步，后来发现。

如果你引用了隐式规则外的头文件，且头文件发生了改变，你再 make 是不会重新编译的（除非你 make clean），因为该头文件不在依赖中。

很简单的问题，有时候还是脑子短路了。