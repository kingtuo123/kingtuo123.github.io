---
title: "Makefile基础"
date: "2022-05-01"
description: ""
summary: "Makefile 的基本语法，规则及命令。"
categories: [ "makefile" ]
tags: [ "makefile" ]
---

> 翻译自 [Makefile Tutorial](https://makefiletutorial.com/#getting-started)，部分有增删或修改，仅供参考。

## Makefile 语法

makefile 由一组规则组成。如下所示：

```makefile
targets: prerequisites
    command
    command
    command
```

- targets 是文件名，以空格分隔。通常一个规则只有一个目标。

- command 通常是用于生成 targets 的一系列步骤。以 Tab 开头。
- prerequisites 也是文件名，以空格分隔。这些文件也称为 **依赖** ，需要在执行 command 之前存在。

## 示例

下面的 makefile 由三个单独的规则组成。当你在终端执行 `make blah` ，会以下面步骤运行并生成 `blan` 文件：

- make 以 `blah` 作为目标，所以它首先搜索这个目标。
- `blah` 需要 `blah.o` ，make 会搜索 `blah.o` 。
- `blah.o` 需要 `blah.c` ，make会搜索 `blah.c` 。
- `blah.c` 不需要依赖，所以会执行 `echo` 命令，生成 `blah.c` 。
- `blah.o` 的依赖满足，会执行  `cc -c` 命令，生成 `blah.o` 。
- `blah` 的依赖满足，会执行  `cc` 命令，生成 `blah` 。
- `blah` 即编译好的C程序。

```makefile
blah: blah.o
    cc blah.o -o blah # 第三个运行

blah.o: blah.c
    cc -c blah.c -o blah.o # 第二个运行

blah.c:
    echo "int main() { return 0; }" > blah.c # 第一个运行
```



下面这个 makefile 有一个目标 `some_file` 。默认目标是第一个目标，所以将执行 `some_file` 下的 `echo`  命令。

```makefile
some_file:
    echo "This line will always print"
```



下面这个 makefile 第一次运行会生成 `some_file` 。第二次运行由于 `some_file` 已存在，会提示 `make: 'some_file' is up to date` 。

```makefile
some_file:
    echo "This line will only print once"
    touch some_file
```



下面这个 makefile 中 `some_file` 依赖 `other_file` 。当第一次执行 `make` ，默认目标是 `some_file` ，它首先会查找依赖文件 `other_file` ，只要依赖文件比目标文件 `some_file` 新，它就会执行这个依赖文件的规则，最后在执行自身的规则。所以当第二次执行时，两条规则下的命令都不会被执行，因为目标文件已存在。

```makefile
some_file: other_file
    echo "This will run second, because it depends on other_file"
    touch some_file

other_file:
    echo "This will run first"
    touch other_file
```



 下面这个 `makefile` 始终会执行默认目标的命令，因为它的依赖始终无法满足。

```makefile
some_file: other_file
    touch some_file

other_file:
    echo "nothing"
```



`clean` 常被用来清理一些生成的文件，但它在 make 中并不是一个特殊的词。（一般都是约定俗成的，大家习惯用 clean 清理文件）

```makefile
some_file: 
    touch some_file

clean:
    rm -f some_file
```



## 变量

变量只是字符串。类似C语言中的宏定义，运行make的时候会自动替换。

使用 `$( )` 调用或 `${ }`。

```
obj = a.o b.o c.o

test: $(obj)
    gcc -o test $(obj)
```

变量赋值一般有如下符号：

|符号|作用|
| :----: | ------------------ |
|   =    | 变量赋值，仅在使用命令时查找变量并替换，而不是在定义时查找替换。 |
|   :=   | 变量赋值，与普通的编程语言中的赋值一样。 |
|   +=   | 变量追加赋值       |
|   ?=   | 变量为空则给它赋值 |

`=` 与 `:=` 的区别：

```makefile
# 这条会在下面打印出 later
one = one ${later_variable}
# 这条不会打印出 later
two := two ${later_variable}

later_variable = later

all: 
    echo $(one)
    echo $(two)
```

`:=` 允许你追加变量，但会导致死循环，如下。

```makefile
one = hello
# one gets defined as a simply expanded variable (:=) and thus can handle appending
one := ${one} there

all: 
    echo $(one)
```

`?=` 仅设置尚未设置的变量

```makefile
one = hello
one ?= will not be set
two ?= will be set

all: 
    echo $(one) # 打印 hello
    echo $(two) # 打印 will be set
```





## 目标

makefile 以第一个规则的目标为默认目标，通常只有一个。

以下 makefile 使用 `all` 可以生成多个目标。

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



## 通配符

| 通配符 | 作用               |
| :----: | ------------------ |
|   *    | 匹配零或多个字符   |
|   %    | 匹配一个或多个字符 |
|   ?    | 匹配单个字符       |

`*` 和 `%` 在 makefile 中都是通配符，但它们的含义完全不同。

`*` 会搜索你的文件系统来匹配文件名。个人建议调用 `wildcard` 函数来使用 `*` 。

```makefile
# 打印出当前路径下所有以.c结尾的文件的信息
print: $(wildcard *.c)
    ls -la  $?
```

> 危险：不要在变量定义中使用 `*` 。
>
> 危险：当 `*` 没有匹配到文件时，它会保持原样（作为一个字符串）除非使用 `wildcard` 函数。

```makefile
thing_wrong := *.o # 不要这样做，'*' 不会被展开，会被视作 "*.o" 字符串
thing_right := $(wildcard *.o) # 正确做法

all: one two three four

# 这里会出错，因为 $(thing_wrong) 是字符串 "*.o"
one: $(thing_wrong)

# 如果没有文件以 ".o" 结尾，匹配不到文件时也会被视作字符串 "*.o"
two: *.o 

# 正确运行
three: $(thing_right)

# 同规则 "three"
four: $(wildcard *.o)
```



## 自动化变量

|符号|描述|
|:-:|--|
|$@|当前目标名|
|$^|所有依赖名，去重|
|$<|第一个依赖名|
|$+|所有依赖名，不去重|
|$?|比目标新的依赖名|
|$*|目标中%匹配的部分|

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

## 规则

### 隐式规则

隐式规则会让东西变得混乱，不推荐使用，但是要了解。

- 编译 C 程序： `n.o` 由 `n.c` 自动生成，命令形式为 `$(CC) -c $(CPPFLAGS) $(CFLAGS)`
- 编译 C++ 程序：`n.o` 由 `n.cc` 或 `n.cpp` 自动生成，命令形式为 `$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)`
- 链接单个目标文件： `n` 是通过运行命令 `$(CC) $(LDFLAGS) n.o $(LOADLIBES) $(LDLIBS)` 从 `n.o` 自动生成的

隐式规则常用的几个变量：

- `CC` ：C 程序编译器，默认 `cc` 。
- `CXX` ：C++ 程序编译器，默认 `g++` 。
- `CFLAGS` ：提供给 C 编译器的参数。
- `CXXFLAGS` ：提供给 C++ 编译器的参数。
- `CPPFLAGS` ：提供给 C 预处理器的参数。
- `LDFLAGS` ：当编译器调用链接器时提供给编译器的额外参数。

下面这个例子无需明确告诉 Make 如何进行编译，就可以构建一个 C 程序。

```makefile
CC = gcc # 隐式规则的默认编译器
CFLAGS = -g # 编译器参数，-g 启用调试信息

# 隐式规则 #1：blah 是通过 C 链接器隐式规则构建的
# 隐式规则 #2：blah.o 是通过 C 编译隐式规则构建的，因为 blah.c 存在
blah: blah.o

blah.c:
    echo "int main() { return 0; }" > blah.c

clean:
    rm -f blah*
```



### 静态模式规则

下面是语法：

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

静态模式规则和 filter 函数搭配使用，如下

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

模式规则在目标中包含一个 `%` 。这个 `%` 匹配任何非空字符串，其他字符匹配它们自己。模式规则的先决条件中的 `%` 代表与目标中的 `%` 匹配的相同词干。

再看另一个例子：

```makefile
# 定义一个没有先决条件的模式规则
# $@ 表示目标文件
# 当需要时会创建一个空的 .c 文件
%.c:
    touch $@
```



### 双冒号规则

双冒号规则很少使用，但允许为同一个目标定义多个规则。如果这些是单冒号，则会打印一条警告，并且只会运行第二组命令。

```makefile
all: blah

blah::
    echo "hello"

blah::
    echo "hello again"
```



## 命令

### 不打印命令

在命令前加 `@` ，在运行时这条命令不会被打印出来。在 `make` 时加上 `-s` 参数有同样的效果。

```
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

在运行 make 时添加 `-k` 参数（--keep-going）以在遇到错误时继续运行（错误信息会被打印）。

在运行 make 时添加 `-i` 参数 （--ignore-errors），执行过程中忽略规则命令执行的错误（错误信息不会被打印）。

在命令前添加 `-` 以忽略错误 ，如下：

```makefile
one:
    # 这条错误信息不会被打印，make会继续执行下去
    -false
    touch one
```

### 中断 make

使用 `ctrl+c` ，它会中断 make 并删除新生成的目标文件。

### 嵌套执行 make

要递归调用 makefile，请使用特殊的 \$(MAKE) 而不是 make，因为它可以传递 make 的参数并且本身不会受到它们的影响。

```makefile
# 双引号中的内容等同于
# hello: 
# 		touch inside_file
new_contents = "hello:\n\ttouch inside_file"
all:
    mkdir -p subdir
    printf $(new_contents) | sed -e 's/^ //' > subdir/makefile #去掉第一行的空格并写入subdir/makefile
    cd subdir && $(MAKE)

clean:
    rm -rf subdir
```

### 使用 export 嵌套

使用 make 嵌套执行的时候，变量是否传递也是我们需要注意的。如果需要变量的传递，那么可以这样来使用：

```makefile
new_contents = "hello:\n\\techo \$$(cooly)"

all:
    mkdir -p subdir
    echo $(new_contents) | sed -e 's/^ //' > subdir/makefile
    @echo "---MAKEFILE CONTENTS---"
    @cd subdir && cat makefile
    @echo "---END MAKEFILE CONTENTS---"
    cd subdir && $(MAKE)

# 注意输出的信息，可以看到 export 全局声明起到了作用
cooly = "The subdirectory can see me!"
export cooly
# 取消全局: unexport cooly

clean:
    rm -rf subdir
```

你也可以在 shell 中使用全局变量

```makefile
one=this will only work locally
export two=we can run subcommands with this

all: 
    @echo $(one)
    # $$ 的意思是使用真实的 $ 符号
    # 即 echo $one，由于one未声明全局环境变量，所以这条打印为空
    @echo $$one
    @echo $(two)
    @echo $$two
```

也可以使用 `.EXPORT_ALL_VARIABLES` 将所用的变量都声明为全局的。

```makefile
.EXPORT_ALL_VARIABLES:
new_contents = "hello:\n\techo \$$(cooly)"

cooly = "The subdirectory can see me!"

all:
    mkdir -p subdir
    echo $(new_contents) | sed -e 's/^ //' > subdir/makefile
    @echo "---MAKEFILE CONTENTS---"
    @cd subdir && cat makefile
    @echo "---END MAKEFILE CONTENTS---"
    cd subdir && $(MAKE)

clean:
    rm -rf subdir
```

### 覆盖命令行参数

你可以使用 `override` 覆盖来自命令行的变量。在这里，我们使用 `make option_one=hi` 运行 `make`

```makefile
# 覆盖命令行参数
override option_one = did_override
# 不会覆盖
option_two = not_override
all: 
    echo $(option_one)
    echo $(option_two)
```

### define函数定义

```makefile
one = export blah="I was set!"; echo $$blah

define two
export blah=set
echo $$blah
endef

# One 和 two 是不一样的

all: 
    @echo "这条会打印 'I was set'"
    @$(one)
    @echo "这条不会打印 'I was set' 因为每条命令运行在不同的shell中"
    @$(two)
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

### if/else

```makefile
foo = ok

all:
ifeq ($(foo), ok)
    echo "foo equals ok"
else
    echo "nope"
endif
```

### 判断变量为空

```makefile
nullstring =
foo = $(nullstring) # 末尾有一个空格

all:
ifeq ($(strip $(foo)),)
    echo "foo is empty after being stripped"
endif
ifeq ($(nullstring),)
    echo "nullstring doesn't even have spaces"
endif
```

### 检查变量是否定义

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

### 命令行参数 $(MAKEFLAGS)

```makefile
bar =
foo = $(bar)

all:
# 查找 "-i" 参数。
ifneq (,$(findstring i, $(MAKEFLAGS)))
    echo "i was passed to MAKEFLAGS"
endif
```

## 函数

函数主要只是用于文本处理。使用 `$(fn, arguments)` 或 `${fn, arguments}` 调用函数。

```makefile
# 字符串替换，这里 totally 替换 not
bar := ${subst not, totally, "I am not superman"}
all: 
    @echo $(bar)
```

如果要替换空格或逗号，请使用变量

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

不要在第一个参数之后包含空格。这将被视为字符串的一部分。

```makefile
comma := ,
empty:=
space := $(empty) $(empty)
foo := a b c
bar := $(subst $(space), $(comma) , $(foo)) # $(comma) 后面有一个空格

all: 
    # 输出是 ", a , b , c"，注意空格
    @echo $(bar)
```

### 字符串替换

`$(patsubst pattern,replacement,text)` 执行以下操作：

使用 `pattern` 匹配 `text` 中的文件名，使用 `replacement` 进行替换。

```makefile
foo := a.o b.o l.a c.o
one := $(patsubst %.o,%.c,$(foo))
# 这是上面的简写
two := $(foo:%.o=%.c)
# 这是仅有后缀的简写，也等价于上述
three := $(foo:.o=.c)

# 输出 a.c b.c l.a c.c
all:
    echo $(one)
    echo $(two)
    echo $(three)
```

### foreach 函数

`$(foreach var,list,text)` ，它将一个单词列表（由空格分隔）转换为另一个单词列表。var 设置为列表中的每个单词，并为每个单词扩展文本。

这会在每个单词后附加一个感叹号：

```makefile
foo := who are you
# 对于 foo 中的每个“单词”，输出相同的单词并在后面加上感叹号
bar := $(foreach wrd,$(foo),$(wrd)!)

all:
    # 输出是 "who! are! you!"
    @echo $(bar)
```

### if 函数

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

Make 支持创建基本函数。语法是 `$(call variable,param,param)` 

`$(0)` 是变量名，`$(1)` 、`$(2)` 等是参数。

```makefile
sweet_new_fn = Variable Name: $(0) First: $(1) Second: $(2) Empty Variable: $(3)

all:
    # 输出 "Variable Name: sweet_new_fn First: go Second: tigers Empty Variable:"
    @echo $(call sweet_new_fn, go, tigers)
```

### shell 函数

这会调用 shell，但它用空格替换了换行符。

```makefile
all:
    # 非常难看，因为换行符不见了
    @echo $(shell ls -la) 
```



## 其他特性

### 应用外部makefile

`include` 的语法是

```makefile
include filenames
```

### vpath 指令

语法 `vpath <pattern> <directories>` ，`<pattern>` 会匹配 `<directories>` 中的文件名，多个目录使用 `空格` 或 `冒号` 分隔。

```
vpath %.h ../headers ../other-directory

some_binary: ../headers blah.h
    touch some_binary

../headers:
    mkdir ../headers

blah.h:
    touch ../headers/blah.h

clean:
    rm -rf ../headers
    rm -f some_binary
```

### .phony

make 并不生成“clean”这个文件。“伪目标”并不是一个文件，只是一个 `标签` ，由于“伪目标”不是文件，所以 make 无法生成它的依赖关系和决定它是否要执行。我们只有通过显式地指明这个“目标”才能让其生效（通过 `make clean` 命令）。当然，“伪目标”的取名不能和文件名重名，不然其就失去了“伪目标”的意义了。

```makefile
.PHONY clean
clean:
    rm -f *.o
```

### .delete_on_error

当规则执行失败，`.delete_on_error` 会删除规则已生成的所有目标文件。

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
# 感谢 Job Vranish (https://spin.atomicobject.com/2016/08/26/makefile-c-projects/)
# 最终要生成的目标文件名
TARGET_EXEC := final_program

# 编译生成文件的目录
BUILD_DIR := ./build
# 源文件所在的目录
SRC_DIRS := ./src

# 找到所有需要编译的 C 和 C++ 文件
# 注意 * 表达式周围的单引号。否则 Make 会错误地扩展这些。
# Note the single quotes around the * expressions. Make will incorrectly expand these otherwise.
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

# Include the .d makefiles. The - at the front suppresses the errors of missing
# Makefiles. Initially, all the .d files will be missing, and we don't want those
# errors to show up.
-include $(DEPS)
```

