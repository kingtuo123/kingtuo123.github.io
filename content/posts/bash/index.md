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

```bash-session
$ ls /temp | grep -o "file"
ls: cannot access '/temp': No such file or directory
$ ls /temp |& grep -o "file"
file
```

<div class="table-container no-thead">

|      |                                                                  |
|:-----|:-----------------------------------------------------------------|
|`\|`  |将前一个命令的 **标准输出** 传递给下一个命令                      |
|`\|&` |将前一个命令的 **标准输出** 和 **标准错误** 一起传递给下一个命令  |

</div>



### 命令列表操作符

<div class="table-container no-thead">

|       |                                 |
|:------|:--------------------------------|
|`;`    |顺序执行（无论前命令是否成功）   |
|`&&`   |逻辑与，前命令成功才执行后续命令 |
|`\|\|` |逻辑或，前命令失败才执行后续命令 |
|`&`    |后台执行                         |

</div>


### 文件描述符

每个进程都有自己独立的文件描述符表（File Descriptor Table）

<div align="left">
    <img src="fdt.svg" style="max-height:1000px"></img>
</div>

<div class="table-container no-thead">

|      |                         |
|:-----|:------------------------|:--|:--|:--|:--|
|`0`   |标准输入 `stdin`         |
|`1`   |标准输出 `stdout`        |
|`2`   |标准错误 `stderr`        |
|`3-8` |自定义文件描述符，共 6 个|

</div>

```bash-session
$ ls -l /dev/std*
lrwxrwxrwx 1 root root 15 Apr 11  2025 /dev/stderr -> /proc/self/fd/2
lrwxrwxrwx 1 root root 15 Apr 11  2025 /dev/stdin -> /proc/self/fd/0
lrwxrwxrwx 1 root root 15 Apr 11  2025 /dev/stdout -> /proc/self/fd/1
$ ls -l /proc/self
lrwxrwxrwx 1 root root 0 Apr 11  2025 /proc/self -> 6719
$ ls -l /proc/self/fd/
lrwx------ 1 king king 64 Apr 10 18:46 0 -> /dev/pts/1
lrwx------ 1 king king 64 Apr 10 18:46 1 -> /dev/pts/1
lrwx------ 1 king king 64 Apr 10 18:46 2 -> /dev/pts/1
```

<div align="left">
    <img src="link.svg" style="max-height:1000px"></img>
</div>


`/proc/self` 是一个动态变化的符号链接，由内核动态生成，
当不同进程访问 `/proc/self` 时，它们看到的是各自进程的信息，且始终指向当前进程 `PID` 的目录即 `/proc/[进程PID]`



### 重定向

重定向的本质是修改进程的文件描述符表，`command > file` （等同于 `command 1> file`）如下：

<div align="left">
    <img src="c1.svg" style="max-height:1000px"></img>
</div>



<div class="table-container no-thead">

|||
|:-----|:--|
|**输入重定向**|**n 默认为 0**|
|`n<file`|复制 `file` 的 `fd` → `n`|
|`n<&m`|复制 `m` → `n`|
|`n<<eof`|创建临时 `file`，逐行写入内容直到定界符 `eof`，然后复制 `file` 的 `fd` → `n`|
|`n<<<string`|创建临时 `file`，写入一行 `string`（包含空格要加引号），然后复制 `file` 的 `fd` → `n`|
|**输出重定向**|**n 默认为 1**|
|`n>file`|复制 `file` 的 `fd` → `n`|
|`n>&m`|复制 `m` → `n`|
|`n>>file`|追加，复制 `file` 的 `fd` → `n`|
|**标准输出/错误重定向**||
|`&>file`|复制 `file` 的 `fd` → `1` `2`  |
|`&>>file`|追加，复制 `file` 的 `fd` → `1` `2`  |

</div>

> 这一节可能理解得还有问题，官方文档看得头晕，先插个眼




### 命令分组 ( ) 与 { }

```bash-session
$ a=123;(echo $a)
123
$ a=123;(a=456);echo $a
123
```

- `( )` 中的命令在 `子Shell` 中运行，`子Shell` 能继承 `父Shell` 的环境变量，但不会影响 `父Shell` 的环境变量 
- `( )` 一般用于隔离环境，避免影响当前 Shell
- `$( )` 的内部实现就是使用子 Shell

```bash-session
$ { ls /var; ls /usr; } | grep lib
lib
lib
lib64
libexec
```

- `{ }` 中的命令在当前 Shell 执行
- `{ command; }` 中的命令左右都要有空格，必须以 `;` 或换行结尾
- `{  }` 一般用于合并多条命令的输出，方便一起处理


### (( 表达式 ))


```bash
(( i++ ))
(( --i ))
(( a = b + c ))
(( a += 2 ))
result=$(( 2**4 ))

(( a > b && c < d ))
(( a > b || c < d ))
(( !(a > b) ))

(( a = 5 & 3 ))
(( b = 5 | 3 ))
(( c = 5 ^ 3 ))

(( hex = 0xFF ))
(( oct = 077 ))
(( bin = 2#1010 ))

(( a = 5, b = 10, c = a + b ))  # 逗号分隔多个表达式
```

- 表达式中的变量名前不需要加 `$`
- 表达式中的空格是可选的，但建议添加以提高可读性
- `(( ))` 只支持整数运算，浮点运算需要使用 `bc` 或 `awk` 等其他工具
- `(( ))` 不返回计算结果，只返回退出状态。要获取计算结果，应使用 `$(( ))`

<div class="table-container no-thead">

|||
|:--|:--|
|**算术运算**   |`+-*/%`&ensp;`++`&ensp;`--`&ensp;`**`（幂运算）&ensp;`+=`&ensp;`-=` 等等           |
|**比较运算**   |`==`&ensp;`!=`&ensp;`<`&ensp;`<=`&ensp;`>`&ensp;`>=`                               |
|**逻辑运算**   |`\|\|`&ensp;`&&`&ensp;`!`                                              |
|**位运算**     |`&`&ensp;`\|`&ensp;`^`&ensp;`~`&ensp;`>>`&ensp;`<<`                                |
|**三元运算符** |`(( max = a > b ? a : b ))` 如果 a 大于 b，max=a，否则 max=b   |
|**数值进制**   | 十六进制 `0x` `FF`&ensp;八进制 `0` `77`，二进制 `2#` `1010`       |

</div>

### [[ 表达式 ]]

```bash
[[ "$a" == "$b" ]]      # 字符串相等	    
[[ -z "$a" ]]           # 字符串为空	    
[[ -n "$a" ]]           # 字符串非空	      
[[ "$a" =~ ^[0-9]+$ ]]  # 正则表达式匹配	
```

<div class="table-container">

|区别              |`[ ]`                           |`[[ ]]`               |
|:-----------------|:-------------------------------|:---------------------|
|**POSIX 兼容**    |是（sh）                        |否（仅 Bash/Ksh/Zsh） |
|**变量双引号要求**|是                              |可选，最好加上        |
|**逻辑操作符**    |`-a`，`-o`                      |`&&`，`\|\|`          |
|**模式匹配**      |不支持                          |支持 `==`、`=~`       |
|**通配符展开**    |不展开                          |展开                  |

</div>

-  `[ ]` 等同 `test` 命令，如果编写可移植的 POSIX shell 脚本（如 sh），使用 `[ ]`
- 如果使用 Bash，优先用 `[[ ]]`，因为它更安全、功能更强
- 变量引用最好用双引号括起来，防止空变量或包含空格的变量

<div class="table-container no-thead">

|                          |                                |
|:-------------------------|:-------------------------------|
|**逻辑操作符**            |                                |
|`[ ! condition ]`         |非，`!` 前后都要加空格          |
|`[ cond1 -a cond2 ]`      |与                              |
|`[ cond1 -o cond2 ]`      |或                              |
|`[[ ! condition ]]`       |非，`!` 前后都要加空格          |
|`[[ cond1 && cond2 ]]`    |与                              |
|`[[ cond1 \|\| cond2 ]]`  |或                              |
|**文件测试操作符**        |                                |    
|`-e file`                 |文件存在                        |
|`-f file`                 |是普通文件（不是目录或设备文件）|
|`-d file`                 |是目录                          |
|`-L file`                 |文件是符号链接，或者 `-h`       |
|`-s file`                 |文件大小不为零                  |
|`-r file`                 |文件可读                        |
|`-w file`                 |文件可写                        |
|`-x file`                 |文件可执行                      |
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
|**正则表达式匹配**        |                                |
`string =~ pattern`        |当 pattern 成功匹配到 string 中的字符则返回真，pattern 包含特殊字符时不加双引号|

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

#### Select 语句

```bash
select fruit in Apple Banana Cherry "Dragon Fruit"
do
    echo "Your selected: $fruit"
    break  # 退出选择循环
done
```

```bash-session
$ ./test.sh
1) Apple
2) Banana
3) Cherry
4) Dragon Fruit
#? 2
Your selected: Banana
```



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
for file in "$(ls)"; do
    echo "File: $file"
done

# C 语言风格的 for 循环
for ((i=0; i<5; i++)); do
    echo "C-style loop: $i"
done
```

#### 循环控制

<div class="table-container">

|           |                              |
|:----------|:-----------------------------|
|`break`    |立即退出循环                  |
|`continue` |跳过当前迭代，进入下一次循环  |
|`exit`     |退出整个脚本                  |

</div>



### 协进程

协进程（coprocess），允许你在脚本中启动一个子进程并与它进行双向通信















## IFS 与 双引号的关系

## Shell 扩展

## Bash 调试

```bash
set -x 
bash -x 
set -e
```

## bash 编程常犯错误
