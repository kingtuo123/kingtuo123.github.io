---
title: "CMake 入门"
date: "2024-02-27"
summary: "CMake 是一个跨平台的项目构建工具"
description: ""
categories: [ "linux" ]
tags: [ "cmake" ]
---

参考文章

- [Official / CMake Reference Documentation](https://cmake.org/cmake/help/latest/index.html)
- [CMake Cookbook](https://www.bookstack.cn/read/CMake-Cookbook/README.md)
- [CMake 保姆级教程](https://subingwen.cn/cmake/CMake-primer/)

## 概述

CMake 是基于 CMakeLists.txt 构建的

## 命令行

### 构建

创建一个 `Build` 目录并在此目录下生成 `makefile` 或其他文件：

```bash-session
$ cmake -S . -B Build
```

生成项目（编译）：

```bash-session
$ cmake --build Build
```

上面两条命令等同于：

```bash-session
$ mkdir Build
$ cd Build
$ cmake ..
$ make
```

### 其他

```bash-session
$ cmake -P CMakeLists.txt
```

`-P` 选项告诉 cmake 运行指定脚本，但是不生成构建文件



## 变量

变量的值都被视为字符串

### set 命令

```cmake
# 设置单个值，双引号可加可不加
set(var1 hello)
set(var2 "world")
message("${var1}")
message("${var2}")

# 设置多个值，使用 ; 或空格分割
set(var3 hello world)
set(var4 hello;world)
message("${var3}")
message("${var4}")
```

```bash-session
$ cmake -P CMakeLists.txt
hello
world
hello;world
hello;world
```

### list 命令

```cmake
# 列表添加元素
list(APPEND list1 a0 a1 a3 a8)
message("APPEND:      ${list1}")

# 列表删除元素
list(REMOVE_ITEM list1 a8)
message("REMOVE_ITEM: ${list1}")

# 获取列表元素个数
list(LENGTH list1 len)
message("LENGTH:      ${len}")

# 在列表中查找元素返回索引，索引从 0 开始
list(FIND list1 a3 index)
message("FIND:        ${index}")

# 在指定索引位置插入元素
list(INSERT list1 2 a2)
message("INSERT:      ${list1}")

# 反转 list
list(REVERSE list1)
message("REVERSE:     ${list1}")

# 排序 list
list(SORT list1)
message("SORT:        ${list1}")
```

```bash-session
$ cmake -P CMakeLists.txt
APPEND:      a0;a1;a3;a8
REMOVE_ITEM: a0;a1;a3
LENGTH:      3
FIND:        2
INSERT:      a0;a1;a2;a3
REVERSE:     a3;a2;a1;a0
SORT:        a0;a1;a2;a3
```

## 流程控制

### if 条件判断

```cmake
if(<condition>)
  <commands>
elseif(<condition>)
  <commands>
else()
  <commands>
endif()
```

#### 逻辑运算符

```cmake
if(NOT <condition>)
if(<cond1> AND <cond2>)
if(<cond1> OR  <cond2>)
```

#### 存在性检查

参考：[Existence Checks](https://cmake.org/cmake/help/latest/command/if.html#existence-checks)

```cmake
if(COMMAND <command-name>)
```

- `COMMAND`：如果给定的名称是命令、宏或者函数这类可被调用的对象，则返回真
- `DEFINED`：如果变量被定义则为真


#### 文件操作

参考：[File Operations](https://cmake.org/cmake/help/latest/command/if.html#file-operations)

```cmake
if(EXISTS <path-to-file-or-directory>)
```

- `EXISTS`：如果文件或目录存在并且可读，则为真
- `IS_DIRECTORY`：如果路径是目录，则为真


#### 比较

参考：[Comparisons](https://cmake.org/cmake/help/latest/command/if.html#version-comparisons)

```cmake
if(<variable|string> MATCHES <regex>)
```

- `MATCHES`：字符串或变量的值与给定的正则表达式匹配，则为真
- `LESS`：小于
- `LESS_EQUAL`：小于等于
- `EQUAL`：等于
- `GREATER`：大于
- `GREATER_EQUAL`：大于等于



### foreach 循环

```cmake
foreach(<loop_var> <items>)
    <commands>
endforeach()
```

几种用法：

```cmake
# 从 0-stop 迭代，stop 不能是负值
foreach(<loop_var> RANGE <stop>)
# 从 start-stop 迭代，步长为 step（默认 1） 
foreach(<loop_var> RANGE <start> <stop> [step])

# 从 list1 list2 ... 中对每个列表依次迭代
foreach(<loop_var> IN LISTS <list1> <list2> ...)
# 从变量 <var1> <var2> ... 中依次取值
foreach(<loop_var> IN ITEMS <var1> <var2> ...)
# 从列表 <list1> <list2> 变量 <var1> <var2> ... 中依次取值
foreach(<loop_var> IN LISTS <list1> <list2> ITEMS <var1> <var2> ...)

# 同时迭代多个列表，每次迭代的值存放在 pair_0 pair_1 ...
foreach(<pair> IN ZIP_LIST <list1> <list2> ...)
# 同时迭代两个列表，上面的另一种写法
foreach(<pair0> <pair1> IN ZIP_LIST <list1> <list2>)
```

## 函数

```cmake
function(<name> [<arg1> ...])
  <commands>
endfunction()
```

示例，ARGV0、1、2 ... 表示函数的第 1、2、3 ... 个参数：

```cmake
function(myfunc first)
	message("FuncName = ${CMAKE_CURRENT_FUNCTION}")
	message("first = ${first}")
	message("ARGV0 = ${ARGV0}")
	message("ARGV1 = ${ARGV1}")
	message("ARGV2 = ${ARGV2}")
	message("ARGV3 = ${ARGV3}")
endfunction()

set(var 1)

myfunc(${var} 2 3 4)
```

```bash-session
$ cmake -P CMakeLists.txt
FuncName = myfunc
first = 1
ARGV0 = 1
ARGV1 = 2
ARGV2 = 3
ARGV3 = 4
```

### 作用域

类似 C 语言：

- 函数内部可以引用外部定义的变量
- 外部不能引用函数内部定义的变量
- 函数内部定义重复变量会覆盖外部定义的变量

想要在函数内部修改外部定义的变量，使用 `PARENT_SCOPE` 如下：

```cmake
set(ABC 123)

function(myfunc)
    set(ABC 456 PARENT_SCOPE)
endfunction()

message("Before = ${ABC}")
myfunc()
message("After  = ${ABC}")
```

```bash-session
$ cmake -P CMakeLists.txt
Before = 123
After  = 456
```

### 函数返回值

使用 set 的 `PARENT_SCOPE` 特性实现：

```cmake
function(add ret)
    message("ret = ${ret}")
    math(EXPR temp "${ARGV1} + ${ARGV2}")
    # 注意 sum 是作为一个参数（字符串）传入 add 函数，所以下面要使用 ${ret}
    set(${ret} ${temp} PARENT_SCOPE)
endfunction()

add(sum 1 2)
message("sum = ${sum}")
```

```bash-session
$ cmake -P CMakeLists.txt
ret = sum
sum = 3
```

## 未完待续
