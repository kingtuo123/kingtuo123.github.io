---
title: "Autodependencies with GNU make"
date: "2022-06-10"
description: "make 自动生成依赖关系"
summary: "make 自动生成依赖关系"
categories: [ "makefile" ]
tags: [ "makefile"]
---


> 本文翻译自 [Autodependencies with GNU make](http://scottmcpeak.com/autodepend/autodepend.html) 水平有限仅供参考。




## 问题描述

编译器将 C 源文件（.c 文件）和一些头文件（.h 文件）编译成目标文件（.o 文件）。 make 是一种编排构建过程的工具，因此每当源文件更改时，依赖它的文件都会重新构建。

虽然 `make` 能很好地处理 `.o` 文件对 `.c` 文件的依赖关系，但它没有内置工具来确定对 `.h` 文件的依赖关系，也没有方便的表达方式。更重要的是，任何解决方案都必须处理好自动生成的源文件。

本文概述了我对这个问题的解决方案，实际上非常简单。我最初写这个是因为我认为它是原创的，但事实证明 Paul Smith 已经记录了这个 [解决方案](http://make.paulandlesley.org/autodep.html)。

## 情景描述

假设我有一个像这样的（GNU）Makefile：

```makefile
OBJS := foo.o bar.o

# 链接
proggie: $(OBJS)
	gcc $(OBJS) -o proggie

# 编译
%.o: %.c
	gcc -c $(CFLAGS) $*.c -o $*.o

# 清除编译生成的文件
clean:
	rm -f proggie *.o
```

这个 Makefile 中描述了两个源文件 foo.c 和 bar.c，它们被编译和链接以生成可执行的 proggie。它还描述了在一般情况下如何在给定 .c 文件的情况下构建 .o 文件。

但是，假设 foo.c 和 bar.c 都包含 foo.h。这意味着各自的 .o 文件都依赖于 foo.h 的内容，但这一事实并未在 Makefile 中表达。因此，如果程序员更改了 foo.h，那么程序在重建时很可能会出现不一致。

当然可以添加更多行，例如：

```makefile
foo.o: foo.h
bar.o: bar.h
```

但很明显，除了最小的程序之外，这后续维护起来是个麻烦。

## 解决方法

解决方案相当简单：每次我们构建一个 .o 文件时，我们还创建一个扩展名为 .d（用于依赖关系）的文件，该文件记录了哪些文件用于创建相应的 .o 文件。 （请注意，与某些方法相比，我们不会提前创建 .d 文件。） .d 文件将用 make 语言本身编写，并包含在主 Makefile 中。我们可以使用 gcc 的 -MM 选项生成该文件：

```makefile
OBJS := foo.o bar.o

# link
proggie: $(OBJS)
	gcc $(OBJS) -o proggie

# 获取所有 .o 文件的依赖关系
-include $(OBJS:.o=.d)

# 编译并生成依赖信息
%.o: %.c
	gcc -c $(CFLAGS) $*.c -o $*.o
	gcc -MM $(CFLAGS) $*.c > $*.d

# remove compilation products
clean:
	rm -f proggie *.o *.d
```
鉴于上述情况，我们会在编译后得到两个 .d 文件。其中之一 bar.d 看起来像：

```makefile
bar.o: bar.c foo.h
```

当 make 读取这一行时，由于没有指定 shell 命令，它会将依赖项列表附加到 bar.o 已经拥有的任何依赖项，而不会影响用于构建它的命令。

请注意，当且仅当对应的 `.o` 文件存在时，`.d` 文件才存在。这是有道理的，因为如果 `.o` 文件还不存在，我们不需要 `.d` 文件来告诉我们必须重建它。

最巧妙的是，在我们拥有构建相应 `.o` 文件的必要成分之前，我们从不尝试构建 `.d` 文件。当项目有一些自动构建的源文件（例如 Bison 输出）时，这一点很重要，因为任何过早构建 `.d` 文件的尝试都会失败。

`-include $(OBJS:.o=.d)` 语法可能需要一些解释。首先，`$(OBJS:.o=.d)` 取 `$(OBJS)` 的值，并将名称末尾的所有 `.o` 替换为 `.d`。接下来，字符`（“-”）`表示如果某些 `.d` 文件不存在，`make` 应该继续进行而不报错（同样，如果` .d` 文件不存在，那么 `.o` 文件也不存在，所以 `.o` 文件将被正确重建）。

> 关于头文件依赖，参考 [这篇文章](https://kingtuo123.com/posts/makefile-include-file/)

## 改进一下

上面的 Makefile 有一个问题。假设我将 `foo.h` 重命名为 `foo2.h`，并相应地更改 `foo.c` 和 `bar.c`。当我尝试重新编译时，`make` 会提示（例如）`bar.o` 依赖于不存在的 `foo.h`。我必须执行 `make clean` 或类似的事情才能让它再次正常工作。

> **参阅 make 手册的第 4 章，“没有命令或先决条件的规则”。**
> GNU make 有一个晦涩难懂的功能：如果一个文件作为目标出现在没有先决条件和命令的规则中，并且该文件不存在且无法重新创建，那么 make 将重建所有依赖于该文件的目标并且不报告错误。 

要利用此功能，必须为每个 `.d` 文件添加无命令、无先决条件的规则。有很多方法可以实现，我选择使用 `sed` 和 `fmt` 的组合。我还选择在新命令前添加 `@` 符号，因此在 `make` 运行时它们不会得到回显：

```makefile
OBJS := foo.o bar.o

# link
proggie: $(OBJS)
	gcc $(OBJS) -o proggie

# pull in dependency info for *existing* .o files
-include $(OBJS:.o=.d)

# compile and generate dependency info;
# more complicated dependency computation, so all prereqs listed
# will also become command-less, prereq-less targets
#   sed:    strip the target (everything before colon)
#   sed:    remove any continuation backslashes
#   fmt -1: list words one per line
#   sed:    strip leading spaces
#   sed:    add trailing colons
%.o: %.c
	gcc -c $(CFLAGS) $*.c -o $*.o
	gcc -MM $(CFLAGS) $*.c > $*.d
	@cp -f $*.d $*.d.tmp
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | \
	  sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp

# remove compilation products
clean:
	rm -f proggie *.o *.d
```

现在依赖文件看起来像这样：

```makefile
bar.o: bar.c foo.h
bar.c:
foo.h:
```

再来看之前的假设：假设我将 `foo.h` 重命名为 `foo2.h`。由于规则 `foo.h:` 没有依赖条件且 `bar.o` 依赖于 `foo.h` ，`bar.o` 将被重新编译并生成新的 `.d` 依赖关系。

## 最后调整

如果源文件（和目标 `.o` 文件）位于与运行 `make` 的目录不同的目录中，则上述命令将无法正常工作。事实证明，`gcc -MM` 将创建一个目标名为 `bar.o` 的 `.d` 依赖文件，而正确的目标名应为 `dir/bar.o`。

例如，上面的 makefile 可能会创建 `.d` 文件：

```makefile
bar.o: dir/bar.c dir/foo.h
dir/bar.c:
dir/foo.h:
```

这将起不到作用，因为 Makefile 中没有其他内容引用 `bar.o`。

为了解决这个问题，在构建依赖项的块中还需要一个 sed 命令：

```makefile
%.o: %.c
	gcc -c $(CFLAGS) $*.c -o $*.o
	gcc -MM $(CFLAGS) $*.c > $*.d
	@mv -f $*.d $*.d.tmp
	@sed -e 's|.*:|$*.o:|' < $*.d.tmp > $*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | \
	  sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp
```

这将生成一个依赖文件，如下：

```makefile
dir/bar.o: dir/bar.c dir/foo.h
dir/bar.c:
dir/foo.h:
```

