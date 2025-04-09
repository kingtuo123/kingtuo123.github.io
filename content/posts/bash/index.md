---
title: "Bash 脚本"
date: "2025-04-01"
summary: "速查"
description: ""
categories: [ "programming" ]
tags: [ "bash" ]
---

## 基本语法

### 变量使用

#### 变量定义

等号两边不能有空格

```bash
name="king"
age=30
PI=3.14159
```

#### 将命令输出赋值给变量

```bash
name=$(whoami)
name=`whoami`
```

#### 变量引用


```bash
echo $name
echo ${name}
```

#### 双引号 vs 单引号

单引号不会扩展变量、命令替换或输出部分特殊字符

```bash-session
$ echo "hello $(whoami)"
hello king
$ echo 'hello $(whoami)'
hello $(whoami)
```

### 变量操作

#### 只读变量

```bash
readonly name="king"

```

#### 删除变量

```bash
unset variable_name
```

#### 默认值

```bash
echo ${variable:-default_value}  # 如果 variable 未设置或为空，使用 default_value
```

#### 字符串操作

```bash
str="01234567"
length=${#str}          # 字符串长度 8
substring=${str:0:4}    # 子字符串 1234
```

### 位置参数变量（内置变量）

<div class=" no-thead">

|    |                                   |   |   |
|:---|:----------------------------------|:--|:--|
|`0`|脚本名                             |   |   |
|`1`|第 1 个参数，参数大于 10 用 `${10}`|   |   |
|`#`|参数个数                           |   |   |
|`@`|所有参数                           |   |   |

</div>


```bash
#!/bin/bash
echo "脚本名 = $0"
echo "第一个参数 = $1"
echo "第二个参数 = $2"
echo "共 $# 个参数"
echo "所有参数 = $@"
```

```bash-session
$ ./test.sh f1 f2 f3
脚本名 = ./test.sh
第一个参数 = f1
第二个参数 = f2
共 3 个参数
所有参数 = f1 f2 f3
```




## 数组

### 索引数组

使用数字作为索引（从 0 开始）

```bash
# 直接赋值
fruits=("apple" "banana" "orange")

# 逐个元素赋值
colors[0]="red"
colors[1]="green"
colors[2]="blue"

# 从命令输出创建
files=(*.txt)  # 当前目录所有txt文件
```


### 关联数组

使用字符串作为键，使用 `declare -A` 声明

```bash
declare -A person
person=([name]="John" [age]=30 [city]="New York")

# 或者逐个赋值
declare -A user
user["username"]="jdoe"
user["email"]="jdoe@example.com"
```

### 数组操作

#### 获取数组长度

```bash
echo ${#fruits[@]}
```

### 遍历数组



## Shell 基础

### 管道

<div class="table-container no-thead">

|      |                                                                  |
|:-----|:-----------------------------------------------------------------|
|`\|`  |将前一个命令的 **标准输出** 传递给下一个命令                      |
|`\|&` |将前一个命令的 **标准输出** 和 **标准错误** 一起传递给下一个命令  |

</div>

```bash-session
$ ls /temp | grep -o "file"
ls: cannot access '/temp': No such file or directory
$ ls /temp |& grep -o "file"
file
```


### 命令列表操作符

<div class="table-container no-thead">

|       |                                 |
|:------|:--------------------------------|
|`;`    |顺序执行（无论前命令是否成功）   |
|`&&`   |逻辑与，前命令成功才执行后续命令 |
|`\|\|` |逻辑或，前命令失败才执行后续命令 |
|`&`    |后台执行                         |

</div>


### 循环结构


#### until 循环

只要 `test-commands` 的返回值不为 `0` 就执行 `consequent-commands`，`while` 循环也一样

```bash
until test-commands; do consequent-commands; done
```

```bash
# 基本计数器
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done

# 等待某个条件满足
until ping -c1 example.com &>/dev/null; do
    echo "Waiting for example.com to be reachable..."
    sleep 5
done
echo "example.com is now reachable!"
```

循环结构中的 `;` 可以直接用换行替代，看个人习惯

#### while 循环

```bash
# 基本计数器
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done

# 读取文件内容
while read line; do
    echo "Line: $line"
done < filename.txt

# 无限循环
while true; do
    echo "Press Ctrl+C to stop"
    sleep 1
done

# 使用算术表达式
count=0
while ((count < 5)); do
    echo "Count: $count"
    ((count++))
done
```

#### for 循环

```bash
# 遍历简单列表
for i in 1 2 3 4 5; do
    echo "Number $i"
done

# 遍历字符串列表
for color in red green blue; do
    echo "Color is $color"
done

# 使用大括号展开
for i in {1..5}; do
    echo "Counting $i"
done

# 指定步长
for i in {1..10..2}; do
    echo "Step $i"
done

# 遍历命令输出
for file in $(ls); do
    echo "File: $file"
done

# C 语言风格的 for 循环
for ((i=0; i<5; i++)); do
    echo "C-style loop: $i"
done
```

#### 循环控制

<div class="table-container no-thead">

|           |                              |
|:----------|:-----------------------------|
|`break`    |立即退出循环                  |
|`continue` |跳过当前迭代，进入下一次循环  |
|`exit`     |退出整个脚本                  |

</div>

### 条件结构

#### If 语句

```bash
if [ -f "file1" ]; then
    echo "文件 file1 存在"
elif test -f "file2"; then
    echo "文件 file2 存在"
elif [[ -f "file3" ]]; then
    echo "文件 file3 存在"
else
    echo "nothing"
fi
```


<div class="table-container">

|                  |`[ ]`                           |`[[ ]]`               |
|:-----------------|:-------------------------------|:---------------------|
|**POSIX 兼容**    |是（sh）                        |否（仅 Bash/Ksh/Zsh） |
|**变量双引号要求**|是                              |可选，最好加上        |
|**逻辑操作符**    |`-a`，`-o`                      |`&&`，`\|\|`          |
|**模式匹配**      |不支持                          |支持 `==`、`=~`       |
|**通配符展开**    |不展开                          |展开                  |

</div>

-  `[ ]` 等同 `test` 命令，如果编写可移植的 POSIX shell 脚本（如 sh），使用 `[ ]`
- 如果使用 Bash，优先用 `[[ ]]`，因为它更安全、功能更强
- 变量引用最好用双引号括起来，如 `[ "$var1" = "$var2" ]`，防止空变量或包含空格的问题

> 总之，尽量用 `[[ ]]`，用 `[ ]` 总会遇到奇怪的问题，变量一定要用双引号括起来



<div class="table-container no-thead">

|                          |                                |
|:-------------------------|:-------------------------------|
|**逻辑操作符**            |                                |
|`! [ condition ]`         |非，`!` 前后都要加空格          |
|`[ cond1 -a cond2 ]`      |与                              |
|`[ cond1 -o cond2 ]`      |或                              |
|`! [[ condition ]]`       |非，`!` 前后都要加空格          |
|`[[ cond1 && cond2 ]]`    |与                              |
|`[[ cond1 \|\| cond2 ]]`  |或                              |
|**文件测试操作符**        |                                |    
|`-e file`                 |文件存在                        |
|`-f file`                 |是普通文件（不是目录或设备文件）|
|`-d file`                 |是目录                          |
|`-s file`                 |文件大小不为零                  |
|`-r file`                 |文件可读                        |
|`-w file`                 |文件可写                        |
|`-x file`                 |文件可执行                      |
|`-L file`                 |文件是符号链接                  |
|`file1 -nt file2`         |file1 比 file2 新               |
|`file1 -ot file2`         |file1 比 file2 旧               |
|**字符串比较**            |                                |
|`-z string`               |字符串长度为 0                  |
|`-n string`               |字符串长度不为 0                |
|`string1 = string2`       |字符串相等                      |
|`string1 == string2`      |字符串相等                      |
|`string1 != string2`      |字符串不相等                    |
|`string1 < string2`       |string1 按字典顺序小于 string2  |
|`string1 > string2`       |string1 按字典顺序大于 string2  |
|**数值比较**              |                                |
|`num1 -eq num2`           |等于                            |
|`num1 -ne num2`           |不等于                          |
|`num1 -lt num2`           |小于                            |
|`num1 -le num2`           |小于等于                        |
|`num1 -gt num2`           |大于                            |
|`num1 -ge num2`           |大于等于                        |

</div>

#### Case 语句

```bash
echo -n "The $1 has "
case $1 in
    d*g | "cat")
        echo -n "4"
        ;;
    "man")
        echo -n "2"
        ;;
    *)
        echo -n "?"
        ;;
esac
echo " legs"
```

```bash-session
$ ./test.sh cat
The cat has 4 legs
$ ./test.sh dog
The dog has 4 legs
$ ./test.sh dooog
The dooog has 4 legs
$ ./test.sh man
The man has 2 legs
$ ./test.sh snake
The snake has ? legs
```






## Shell 扩展




## Bash 调试

```bash
set -x 
bash -x 
set -e
```
