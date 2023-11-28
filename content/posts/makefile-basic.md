---
title: "Makefile 入门"
date: "2022-05-01"
description: ""
summary: "Makefile 的基本语法，规则及命令。"
categories: [ "linux" ]
tags: [ "makefile" ]
---

- 参考文章：
  - [Makefile Tutorial](https://makefiletutorial.com/#getting-started)
  - [GNU make](https://www.gnu.org/savannah-checkouts/gnu/make/manual/html_node/)

## 语法

makefile 由多个规则组成。规则语法如下：

```makefile
targets: prerequisites
    command
    command
    command
```

- `targets` 目标文件，以空格分隔。通常一个规则只有一个目标。
- `command` 通常是用于生成 targets 的一系列步骤。以 Tab 开头。
- `prerequisites` 依赖文件（先决条件），以空格分隔。需要在执行 command 之前存在。

## 示例一

下面的 makefile 由三个单独的规则组成

```makefile
blah: blah.o
    cc blah.o -o blah # 第三个运行

blah.o: blah.c
    cc -c blah.c -o blah.o # 第二个运行

blah.c:
    echo "int main() { return 0; }" > blah.c # 第一个运行
```


当你在终端执行 `make blah` ，会以下面步骤运行并生成 `blan` 文件：

- make 以 `blah` 作为目标，所以它首先搜索这个目标。
- `blah` 依赖 `blah.o` ，make 会搜索 `blah.o` 。
- `blah.o` 依赖 `blah.c` ，make 会搜索 `blah.c` 。
- `blah.c` 无需依赖，会执行 `echo` 命令，生成 `blah.c` 。
- `blah.o` 的依赖满足，会执行  `cc -c` 命令，生成 `blah.o` 。
- `blah` 的依赖满足，会执行  `cc` 命令，生成 `blah` 。
- `blah` 即编译好的 C 程序。

make 的默认目标是规则中的第一个目标，所以直接执行 `make` 亦可：

```bash-session
$ make
echo "int main() { return 0; }" > blah.c 
cc -c blah.c -o blah.o 
cc blah.o -o blah 
```

重复执行 `make` 会提示 `up to date`：

```bash-session
$ make
make: 'blah' is up to date.
```

当依赖文件的时间戳新于目标文件，目标文件才会按规则重新生成：

```bash-session
$ touch blah.o && make
cc blah.o -o blah 

$ touch blah.c && make
cc -c blah.c -o blah.o 
cc blah.o -o blah 

$ rm -f blah.c && make
echo "int main() { return 0; }" > blah.c 
cc -c blah.c -o blah.o 
cc blah.o -o blah 
```

## 示例二

```makefile
some_file: other_file
    echo "This will always run, and runs second"
    touch some_file

# 这里 other_file 不会生成
other_file:
    echo "This will always run, and runs first"
```

上面这个 makefile 始终会执行 `touch some_file`，因为 `some_file` 的依赖始终无法满足。

> 疑问：这里可以看出 make 成功执行规则后，不会检查此规则的目标文件是否存在。为何？

## Make clean

clean 常用来清理文件，但它在 make 中并不是关键词。（一般都是约定俗成的，大家都习惯用 clean 清理文件）

```makefile
some_file: 
    touch some_file

clean:
    rm -f some_file
```
- clean 不是规则中的第一个目标，所以需要显式调用 `make clean`。

- 如果碰巧有一个名为 clean 的文件，这个目标将不会被执行，后文 `.PHONY` 一节会有说明。


## 变量

变量是 **字符串**

### 引用

使用 `$( )` 或 `${ }` 。

```makefile
obj = a.o b.o c.o

test: $(obj)
    gcc -o test $(obj)
```

### 赋值

|符号|作用|
| :--: | :-- |
|   =    | 变量赋值，在执行时查找替换 |
|   :=   | 变量赋值，在定义时查找替换 |
|   +=   | 变量追加赋值       |
|   ?=   | 变量为空则给它赋值 |

### = 与 := 的区别

```makefile
# 这条会在下面打印出 later
one = one ${later_variable}
# 这条不会打印出 later
two := two ${later_variable}

later_variable = later

all: 
    @echo $(one)
    @echo $(two)
```

```bash-session
$ make
one later
two
```

### 单个空格变量

行尾的空格不会被去掉，但行首的空格会被去掉。 要使用单个空格制作变量，请使用 `$(nullstring)`

```makefile
with_spaces =     hello     # with_spaces在 "hello" 之后有很多空格
after = $(with_spaces)there

nullstring =
space = $(nullstring) # 这里末尾有一个空格，即单个空格变量。

all: 
    echo "$(after)"
    echo start"$(space)"end
```

```bash-session
$ make
hello     there
start end
```

## 目标

makefile 以第一个规则的目标为默认目标，通常只有一个。

### all 目标

以下 makefile 通过 all 可以生成多个目标。

```makefile
all: one two three

one:
    touch one
two:
    touch two
three:
    touch three

clean:
    rm -f one two three
```

### 多目标

当一个规则有多个目标时，将为每个目标运行命令。

```makefile
all: f1.o f2.o

f1.o f2.o:
    echo $@
```

相当于：

```makefile
all: f1.o f2.o

f1.o:
    echo f1.o
f2.o:
    echo f2.o
```



## 通配符

| 符号 | 作用               |
| :----: | ------------------ |
|   *    | 匹配零或多个字符 |
|   %    | 匹配一个或多个字符 |
|   ?    | 匹配单个字符       |

`*` 一般搭配 `wildcard` 函数使用，用于搜索文件系统匹配文件名。

`%` 一般在规则中使用作为词干，用于匹配规则中的字符串，不能用于搜索文件系统。

> 注意：在变量定义中直接使用的通配符会被视为字符串

### * 通配符

在变量定义中使用 `*` ，如下（匹配 .o 文件）：

```makefile
thing_wrong := *.o             # 错误做法，* 不会被展开，会被视作 *.o 字符串
thing_right := $(wildcard *.o) # 正确做法
```

在规则中使用 `*`，如下（打印 .c 文件）：

```makefile
# 方式一：不推荐的用法
print_wrong: *.c
    ls -la  $?

# 方式二：推荐使用 wildcard
print_right: $(wildcard *.c)
    ls -la  $?
```

> 注意：第一种方式中当 `*` 没有匹配到文件时，它会保持原样（作为一个字符串）除非使用 `wildcard` 函数。

### % 通配符

下面的 makefile 中 `%.c` 会匹配所有 `.c` 文件的规则，就不用给每个 `.c` 文件单独写一条规则。

```makefile
all: f1.c f2.c f3.c
    @echo "done"

%.c:
    @echo $@
```

```bash-session
$ make
f1.c
f2.c
f3.c
done
```



## 自动化变量

> 更多自动化变量参考：[Automatic Variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)

|符号|描述|
|:-:|--|
|$@|当前目标名|
|$^|所有依赖名，去重|
|$<|第一个依赖名|
|$+|所有依赖名，不去重|
|$?|比目标新的依赖名|
|$\*|目标中%匹配的部分|

```makefile
hey: one two
    # 输出 "hey"
    echo $@

    # 输出比目标新的依赖名
    echo $?

    # 输出所有依赖名
    echo $^

    touch hey

one:
    touch one

two:
    touch two

clean:
    rm -f hey one two
```

```bash-session
$ make -s
hey
one two
one two
$ make
make: 'hey' is up to date.
$ touch one && make -s
hey
one
one two
```

## 规则

### 隐式规则

隐式规则会让事情变得混乱，不推荐使用，但是要了解：

- 编译 C 程序： `n.o` 由 `n.c` 自动生成，命令形式为 `$(CC) -c $(CPPFLAGS) $(CFLAGS)`
- 编译 C++ 程序：`n.o` 由 `n.cc` 或 `n.cpp` 自动生成，命令形式为 `$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)`
- 链接单个目标文件： `n` 是通过运行命令 `$(CC) $(LDFLAGS) n.o $(LOADLIBES) $(LDLIBS)` 从 `n.o` 自动生成的

隐式规则常用的几个变量：

- `CC` ：C 程序编译器，默认 `cc` 
- `CXX` ：C++ 程序编译器，默认 `g++` 
- `CFLAGS` ：提供给 C 编译器的参数
- `CXXFLAGS` ：提供给 C++ 编译器的参数
- `CPPFLAGS` ：提供给 C 预处理器的参数
- `LDFLAGS` ：当编译器调用链接器时提供给编译器的额外参数

下面这个例子无需明确告诉 Make 如何进行编译，就可以构建一个 C 程序：

```makefile
CC = gcc    # 隐式规则的默认编译器
CFLAGS = -g # 编译器参数，-g 启用调试信息

# 隐式规则 #1：blah   是通过 C 链接器隐式规则构建的
# 隐式规则 #2：blah.o 是通过 C 编译隐式规则构建的，因为 blah.c 存在
blah: blah.o

blah.c:
    echo "int main() { return 0; }" > blah.c

clean:
    rm -f blah*
```



### 静态模式规则

```makefile
targets...: target-pattern: prereq-patterns ...
    commands
```

`target-pattern` 会匹配 `targets` 中的文件名（通过 % 通配符），如 `%.o` 匹配 `foo.o` ，匹配到的词干为 `foo` ，然后将 `foo` 替换进 `prereq-patterns` 的 `%` 中。

下面的例子是手动编写规则生成目标文件：

```makefile
objects = foo.o bar.o all.o
all: $(objects)

# 这些目标文件通过隐式规则编译
foo.o: foo.c
bar.o: bar.c
all.o: all.c

all.c:
    echo "int main() { return 0; }" > all.c
# %.c 会匹配 foo.c 和 bar.c ，没有则创建
%.c:
    touch $@

clean:
    rm -f *.c *.o all
```

下面的例子是通过静态模式规则生成目标文件：

```makefile
objects = foo.o bar.o all.o
all: $(objects)

# 这个例子中，%.o 会匹配 targets 中的 foo.o bar.o all.o
# 取出匹配到的词干 foo bar all
# 将词干替换进 %.c 中的 % ，即 foo.c bar.c all.c
$(objects): %.o: %.c

all.c:
    echo "int main() { return 0; }" > all.c

%.c:
    touch $@

clean:
    rm -f *.c *.o all
```

### 静态模式规则和 filter 过滤器

```makefile
obj_files = foo.result bar.o lose.o
src_files = foo.raw bar.c lose.c

.PHONY: all
all: $(obj_files)
# filter 函数会匹配 obj_files 中的 bar.o lose.o
# bar.o lose.o 由静态模式规则替换成 bar.c lose.c
$(filter %.o,$(obj_files)): %.o: %.c
    echo "target: $@ prereq: $<"

# filter 函数会匹配 obj_files 中的 foo.result
# foo.result 由静态模式规则替换成 foo.raw
$(filter %.result,$(obj_files)): %.result: %.raw
    echo "target: $@ prereq: $<" 

%.c %.raw:
    touch $@

clean:
    rm -f $(src_files)
```



### 模式规则

先看一个例子：

```makefile
# 这个模式规则将每个 .c 文件编译为 .o 文件
%.o : %.c
    $(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
```

规则目标中的 `%` 匹配任何非空字符，匹配的字符称为 `词干`，上述例子中 `%.o` 与 `%.c` 拥有相同的词干

再看另一个例子：

```makefile
# 定义一个没有先决条件的模式规则
# 当需要时会创建一个空的 .c 文件
%.c:
    touch $@
```



### 双冒号规则

双冒号允许为同一个目标定义多个规则。如果是单冒号，则会打印一条警告，并且只会运行第二组规则。

```makefile
all: blah

blah::
    echo "hello"

blah::
    echo "hello again"
```



## 命令

### 命令回显/静默

在命令前加 `@` ，在运行时这条命令不会被打印出来。`make -s` 有同样的效果。

```makefile
all: 
    @echo "This make line will not be printed"
    echo "But this will"
```

### 命令执行

每个命令都在一个新的 shell 中运行。

```makefile
all: 
    cd ..
    # cd 命令不会影响下面这条命令，应为两条命令是在两个shell中运行的
    echo `pwd`

    # 如果你想要 cd 命令影响下一条命令，可以在同一行以 ; 间隔
    cd ..;echo `pwd`

    # 同上，这里使用 \ 换行
    cd ..; \
    echo `pwd`
```

### 默认 shell

默认的 shell 是 `/bin/sh` ，你可以通过 `SHELL` 变量修改。

```makefile
SHELL=/bin/bash

cool:
    echo "Hello from bash"
```

### 错误处理

在运行 make 时添加 `-k` 参数（\-\-keep-going）以在遇到错误时继续运行（错误信息会被打印）。

在运行 make 时添加 `-i` 参数 （\-\-ignore-errors），执行过程中忽略规则命令执行的错误（错误信息不会被打印）。

在命令前添加 `-` 以忽略错误 ，如下：

```makefile
one:
    # 这条错误信息不会被打印，make会继续执行下去
    -false
    touch one
```

### 中断 make

使用 `ctrl+c` ，它会中断 make 并删除新生成的目标文件。

### 递归 make

在子目录执行 make，要使用 `$(MAKE)` 而不是 `make`

```makefile
subsystem:
    cd subdir && $(MAKE)
```

> 参考此文：[How the MAKE Variable Works](https://www.gnu.org/savannah-checkouts/gnu/make/manual/html_node/MAKE-Variable.html)

### export 全局变量

`export` 将变量声明为全局变量，这样子目录的 `make` 就可以引用该变量。`unexport` 取消全局：

```makefile
cooly = "The subdirectory can see me!"
export cooly

all:
    cd subdir && $(MAKE)
```

使用 `$$` 可以在 shell 中引用全局变量：

```makefile
all: 
    echo $$one
```

```bash-session
$ export one="hello" && make
echo $one
hello
```

使用 `.EXPORT_ALL_VARIABLES` 将所有的变量都声明为全局的：

```makefile
.EXPORT_ALL_VARIABLES:
one = "hello"
two = "world"
```

### 覆盖命令行参数

你可以使用 `override` 覆盖来自命令行的变量：

```makefile
# 覆盖命令行参数
override option_one = did_override
# 不会覆盖
option_two = not_override
all: 
    @echo $(option_one)
    @echo $(option_two)
```

```bash-session
$ make option_one=hi
did_override
not_override
$ make option_two=hi
did_override
hi
```

### define 命令列表

`define` 开头，`endef` 结尾：

```makefile
define say
echo "hello"
echo "word"
endef

all:
    @$(say)
```

```bash-session
$ make
hello
word
```

### 指定目标变量

```makefile
# 给目标 all 指定 one 变量
all: one = cool

all: 
    echo one is defined: $(one) # 打印 cool

other:
    echo one is nothing: $(one) # 不会打印 cool
```

### 指定模式变量

```makefile
# 给匹配 %.c 这个模式的规则指定 one 变量
%.c: one = cool

blah.c: 
    echo one is defined: $(one) # 打印 cool

other:
    echo one is nothing: $(one) # 不会打印 cool
```

## 条件判断

|关键字|说明|
|:--:|:--|
|ifeq|是否相等|
|ifneq|是否不相等|
|ifdef|是否定义|
|ifndef|是否未定义|

都以 `endif` 结尾



### ifeq 判断变量相等

```makefile
foo = ok

all:
ifeq ($(foo), ok)
    echo "foo equals ok"
else
    echo "nope"
endif
```

### ifeq 判断变量为空

```makefile
nullstring =
foo = $(nullstring) # 末尾有一个空格，单空格变量

all:
ifeq ($(strip $(foo)),)
    echo "foo is empty after being stripped"
endif
ifeq ($(nullstring),)
    echo "nullstring doesn't even have spaces"
endif
```

### ifdef 检查变量是否定义

ifdef 不展开变量引用，它只查看是否定义了某些内容

```makefile
bar =
foo = $(bar)

all:
ifdef foo
    echo "foo is defined"
endif
ifdef bar
    echo "but bar is not"
endif
```

### $(MAKEFLAGS) 命令行参数

```makefile
all:
# 搜索 -i 标志。MAKEFLAGS 只是一个单一字符的列表，每个参数一个字符。
ifneq ($(findstring i, $(MAKEFLAGS)),)
    @echo $(MAKEFLAGS)
    @echo "i was passed to MAKEFLAGS"
endif
```

```bash-session
$ make -s -i
is
i was passed to MAKEFLAGS
```

## 函数

> 更多函数：[Functions for Transforming Text](https://www.gnu.org/software/make/manual/html_node/Functions.html)

函数主要用于文本处理。使用 `$(fn, arguments)` 或 `${fn, arguments}` 调用函数。

### subst 字符串替换

格式：`$(subst str,replacement,text)`

使用 `str` 匹配 `text` 中的字符，再用 `replacement` 进行替换。

```makefile
# 字符串替换，这里 totally 替换 not
bar := ${subst not, totally, "I am not superman"}
all: 
    @echo $(bar)
```

如果要替换空格或逗号，使用变量：

```makefile
comma := ,
empty:=
space := $(empty) $(empty)
foo := a b c
bar := $(subst $(space),$(comma),$(foo))

all: 
    # 输出是 "a,b,c"
    @echo $(bar)
```

不要在第 2、3 个参数前后包含空格，这将被视为字符串的一部分：

```makefile
comma := ,
empty:=
space := $(empty) $(empty)
foo := a b c
bar := $(subst $(space), $(comma) , $(foo)) # $(comma) 和 $(foo) 前后有一个空格

all: 
    # 输出是 ", a , b , c"
    @echo $(bar)
```

### patsubst 字符串替换

格式：`$(patsubst pattern,replacement,text)`

使用 `pattern` 匹配 `text` 中的字符，再用 `replacement` 进行替换。

```makefile
foo := a.o b.o l.a c.o
one := $(patsubst %.o,%.c,$(foo))
# 这是上面的简写
two := $(foo:%.o=%.c)
# 这是仅有后缀的简写，也等价于上述
three := $(foo:.o=.c)

# 输出都是 a.c b.c l.a c.c
all:
    echo $(one)
    echo $(two)
    echo $(three)
```

### foreach 函数

格式：`$(foreach var,list,text)` 

它将一个单词列表（由空格分隔）转换为另一个单词列表。var 设置为列表中的每个单词，并为每个单词扩展文本。

```makefile
foo := who are you
# 对于 foo 中的每个“单词”，输出相同的单词并在后面加上感叹号
bar := $(foreach wrd,$(foo),$(wrd)!)

all:
    # 输出是 "who! are! you!"
    @echo $(bar)
```

### if 函数

格式：`$(if var,yes,no)`

`if` 检查第一个参数是否为非空。如果是，则运行第二个参数，否则运行第三个。

```makefile
this-is-not-empty := hey
foo := $(if this-is-not-empty,yes,no)
empty :=
bar := $(if $(empty),yes,no)

# 输出：yes
#       no
all:
    @echo $(foo)
    @echo $(bar)
```

### call 函数

格式：`$(call variable,param,param)`

Make 支持创建基本函数，使用 `call` 调用用户创建的函数：

```makefile
# $(0) 是变量名，$(1) 、$(2) ... 等是参数。
sweet_new_fn = Variable Name: $(0) First: $(1) Second: $(2) Empty Variable: $(3)

all:
    # 输出 "Variable Name: sweet_new_fn First: go Second: tigers Empty Variable:"
    @echo $(call sweet_new_fn, go, tigers)
```

### shell 函数

格式：`$(shell command)`

调用 shell 执行 command，command 输出内容中的换行符会被替换为空格，不便阅读。

```makefile
all:
    @echo $(shell ls -la) 
```



## 其他特性

### include 包含外部 makefile

```makefile
include filename1 filename2 ...
```

### vpath 指令

make 默认搜索当前目录来匹配依赖文件（不包含子目录），`vpath` 用于添加匹配文件的搜索路径

语法： `vpath <pattern> <directories>`

`<pattern>` 会匹配 `<directories>` 中的文件名，多个目录使用 `空格` 或 `冒号` 分隔。

```makefile
# 添加 .c 文件搜索路径 dir1 dir2
vpath %.c dir1 dir2
vpath %.c dir1:dir2
```

### VPATH 变量

作用同上，用法如下：

```makefile
# 添加所有文件的搜索路径 dir1 dir2
VPATH := dir1 dir2
VPATH := dir1:dir2

```

### .PHONY 伪目标

伪目标只是一个标签，表示 make 不会生成该规则的目标文件。伪目标的取名不能和文件重名。

```makefile
.PHONY: clean
clean:
    rm -f *.o
```

### .DELETE\_ON\_ERROR

当规则执行失败，`.DELETE_ON_ERROR` 会删除规则已生成的所有目标文件。

```makefile
.DELETE_ON_ERROR:
all: one two

one:
    touch one
    false

two:
    touch two
    false
```

## makefile 模板

```makefile
# 最终要生成的目标文件名
TARGET_EXEC := final_program

# 编译生成文件的目录
BUILD_DIR := ./build
# 源文件所在的目录
SRC_DIRS := ./src

# 找到所有需要编译的 C 和 C++ 文件
# 注意 * 表达式周围的单引号。否则 Make 会错误地扩展这些。
SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s')

# 给每个 C/C++ 文件名加 .o 结尾
# 如 hello.cpp 转换为 ./build/hello.cpp.o
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# .o 结尾替换为 .d
# 如 ./build/hello.cpp.o 转换为 ./build/hello.cpp.d
DEPS := $(OBJS:.o=.d)

# ./src 中的每个文件夹都需要传递给 GCC，以便它可以找到头文件
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
# 给 INC_DIRS 添加前缀 -I ，GCC指定头文件路径需要 -I，如 moduleA 会变成 -ImoduleA
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# -MMD 和 -MP 参数会生成每个 .c 文件所依赖的头文件关系
# 保存到 .d 结尾的文件中
CPPFLAGS := $(INC_FLAGS) -MMD -MP

# 最终的编译步骤
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
    $(CC) $(OBJS) -o $@ $(LDFLAGS)

# 编译C源码
$(BUILD_DIR)/%.c.o: %.c
    mkdir -p $(dir $@)
    $(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# 编译C++源码
$(BUILD_DIR)/%.cpp.o: %.cpp
    mkdir -p $(dir $@)
    $(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

.PHONY: clean
clean:
    rm -r $(BUILD_DIR)

# 包含编译器生成的 .d 文件
-include $(DEPS)
```

