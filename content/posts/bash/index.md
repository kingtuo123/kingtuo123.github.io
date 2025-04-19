---
title: "Bash 脚本"
date: "2025-04-15"
summary: "速查"
description: ""
categories: [ "programming" ]
tags: [ "bash" ]
---




## 变量


<div class="table-container no-thead colfirst-50">

|    |                                     |
|:---|:------------------------------------|
|变量定义|`name="king"`|
|变量引用|`$name` &ensp; `${name}` |
|只读变量|`readonly name="king"` &ensp; `declare -r name="king"`
|删除变量|`unset name`|

</div>

### 命令替换

将命令的输出赋值给变量

```bash
name=$(whoami)
name=`whoami`
```

### 间接变量引用

```bash-session
$ x="hello"
$ var="x"
$ echo ${!var}  # 相当于 $x
hello
```

### 双引号 vs 单引号

单引号不会扩展变量、命令替换或转义字符

```bash-session
$ echo "hello $(whoami)"
hello king
$ echo 'hello $(whoami)'
hello $(whoami)
```

### 临时环境变量

```bash-session
$ VAR1=value1 VAR2=value2 ... command
```

命令前添加 `VAR=value` 的形式，表示这个变量赋值仅对该 `command` 有效

```bash-session
$ echo 'echo $var' > test.sh
$ var=123
$ var=456 ./test.sh
456
$ echo $var
123
```

错误用法，`echo` 输出前 `$var` 就被展开为 `123` ：

```bash-session
$ var=123
$ var=456 echo $var
123
```

### 特殊变量

<div class="table-container no-thead colfirst-50">

|    |                                     |
|:---|:------------------------------------|
|`0` |脚本名                               |
|`1` |第 1 个参数，参数大于 10 用 `${10}`  |
|`#` |参数个数                             |
|`@` |所有参数 （有双引号时，`"$@"` 相当于 `"$1" "$2" "$3"`，每个参数都是独立的字符串）|
|`*` |所有参数 （有双引号时，`"$*"` 相当于 `"$1 $2 $3"`，所有参数作为一个字符串）  |
|`?` |上一个命令的退出状态                 |
|`$` |当前 shell 的进程 ID                 |
|`!` |最近被放入后台的进程 ID              |
|`-` |set 命令或 shell 自身设置的选项      |

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


```bash
echo "Using \"\$@\":"
for arg in "$@"; do
  echo "[$arg]"
done

echo "Using \"\$*\":"
for arg in "$*"; do
  echo "[$arg]"
done
```

```bash-session
$ ./test.sh a b 'c d'
Using "$@":
[a]
[b]
[c d]
Using "$*":
[a b c d]
```



## 数组



<div class="table-container no-thead colfirst-120">

|              |                                                |
|:-------------|:-----------------------------------------------|
|**索引数组**  |**使用数字作为索引（从 0 开始）**               |
|声明方式      |`declare -a a`                                  |
|赋值          |`a=(1 2 3)` &ensp; `a[0]=1`                     |
|**关联数组**  |**使用字符串作为键**                            |
|声明方式      |`declare -A a`                                  |
|赋值          |`a=([first]=1 [second]=2)` &ensp; `a[first]=1`  |
|**数组操作**  |                                                |
|`${a[0]}`     |访问单个元素                                    |
|`${a[@]}`     |访问所有元素，作为独立单词                      |
|`${a[*]}`     |访问所有元素，作为一个字符串                    |
|`a+=(1)`      |追加元素到末尾                                  |        
|`${#a[@]}`    |获取数组长度                                    |
|`${a[@]:1:2}` |数组切片，从索引 1 开始取 2 个元素              |
|`${!name[@]}` |匹配所有索引/键作为独立单词                     |
|`${!name[*]}` |匹配所有索引/键作为一个字符串                   |

</div>






## Shell 基础

### 匿名管道

```bash-session
$ ls /temp | grep -o "file"
ls: cannot access '/temp': No such file or directory
$ ls /temp |& grep -o "file"
file
```

<div class="table-container no-thead colfirst-50">

|      |                                                                  |
|:-----|:-----------------------------------------------------------------|
|`\|`  |将前一个命令的 **标准输出** 传递给下一个命令                      |
|`\|&` |将前一个命令的 **标准输出** 和 **标准错误** 一起传递给下一个命令  |

</div>


### 命名管道

使用 `mkfifo` 创建命名管道：

```bash-session
$ mkfifo mypipe
$ echo 'hello world' > mypipe
```

打开另一终端：

```bash-session
$ cat < mypipe
hello world
```


### 命令列表操作符

<div class="table-container no-thead colfirst-50">

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

<div class="table-container no-thead colfirst-50">

|      |                         |
|:-----|:------------------------|
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

重定向的本质是修改进程的文件描述符表，`command >file` （等同于 `command 1>file`）如下：

<div align="left">
    <img src="c1.svg" style="max-height:1000px"></img>
</div>



<div class="table-container no-thead">

|                     |                                                                                       |
|:--------------------|:--------------------------------------------------------------------------------------|
|**输入重定向**       |**n 默认为 0（只读）**                                                                 |
|`n<file`             |复制 `file` 的 `fd` → `n`                                                              |
|`n<&m`               |复制 `m` → `n`                                                                         |
|`n<&m-`              |复制 `m` → `n`，然后关闭 `m`                                                           |
|`n<&-`               |关闭 `n`                                                                               |
|`n<<eof`             |创建匿名 `pipe`，逐行写入内容直到 `eof`，然后复制 `pipe` 的 `fd` → `n`                 |
|`n<<<string`         |创建匿名 `pipe`，写入一行 `string`（包含空格要加引号），然后复制 `pipe` 的 `fd` → `n`  |
|**输出重定向**       |**n 默认为 1（只写）**                                                                 |
|`n>file`             |复制 `file` 的 `fd` → `n`                                                              |
|`n>&m`               |复制 `m` → `n`                                                                         |
|`n>&m-`              |复制 `m` → `n`，然后关闭 `m`                                                           |
|`n>&-`               |关闭 `n`                                                                               |
|`n>>file`            |复制 `file` 的 `fd` → `n` ，追加模式                                                   |
|**输出+错误重定向**  |**只写**                                                                               |
|`&>file`             |复制 `file` 的 `fd` → `1` `2`                                                          |
|`&>>file`            |复制 `file` 的 `fd` → `1` `2` ，追加模式                                               |
|**自定义文件描述符** |**读写**                                                                               |
|`n<>file`            |关联 `n` → `file`                                                                      |

</div>

> 之前习惯在 `>` 右侧加空格，但像 `command 1> file1 2> file2` 和 `command 1>file1 2>file2` 明显后者更易阅读和理解，`file` 应是 `>` 的参数而不是 `command` 的参数，所以 . . .




### 命令分组 ( ) 与 { }

```bash-session
$ a=123;(echo $a)
123
$ a=123;(a=456);echo $a
123
```

- `( )` 中的命令在 `子Shell` 中运行，`子Shell` 能继承 `父Shell` 的环境变量，但不会影响 `父Shell` 的环境变量 
- `( )` 可以用于隔离环境，避免影响当前 Shell

```bash-session
$ { ls /var; ls /usr; } | grep lib
lib
lib
lib64
libexec
```

- `{ command; }` 中的命令在当前 Shell 执行，`command;` 左右都要有空格，必须以 `;` 或换行结尾
- `{ }` 可以用于需要共享上下文的场景

> `( )` 与 `{ }` 都能合并多条命令的输出，方便一起处理


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

- 表达式中的变量名前不需要加 `$`，加了也不影响，但函数参数像 `$1` 是要加的
- 表达式中的空格是可选的，但建议添加以提高可读性
- `(( ))` 只支持整数运算，浮点运算需要使用 `bc` 或 `awk` 等其他工具
- `(( ))` 不返回计算结果，只返回退出状态。要获取计算结果，应使用 `$(( ))`

<div class="table-container no-thead">

|            |                                                                                                     |
|:-----------|:----------------------------------------------------------------------------------------------------|
|**算术运算**|`+ - * / %`&ensp;`++`&ensp;`--`&ensp;`**`（幂运算）&ensp;`+=`&ensp;`-=`&ensp;`/=`&ensp;`*=`&ensp;`%=`|
|**比较运算**|`==`&ensp;`!=`&ensp;`<`&ensp;`<=`&ensp;`>`&ensp;`>=`                                                 |
|**逻辑运算**|`\|\|`&ensp;`&&`&ensp;`!`&ensp;`(( max = a > b ? a : b ))`                                           |
|**位运算**  |`&`&ensp;`\|`&ensp;`^`&ensp;`~`&ensp;`>>`&ensp;`<<`                                                  |
|**数值进制**| 十六进制 `0x` `FF`，八进制 `0` `77`，二进制 `2#` `1010`                                             |

</div>

### [[ 表达式 ]]

```bash
[[ "$a" == "$b" ]]      # 字符串相等	    
[[ -z "$a" ]]           # 字符串为空	    
[[ -n "$a" ]]           # 字符串非空	      
[[ "$a" =~ ^[0-9]+$ ]]  # 正则表达式匹配	
```

<div class="table-container colfirst-200 ">

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

|                          |                                                                                     |
|:-------------------------|:------------------------------------------------------------------------------------|
|**逻辑操作符**            |                                                                                     |
|`[ ! condition ]`         |非，`!` 前后都要加空格                                                               |
|`[ cond1 -a cond2 ]`      |与                                                                                   |
|`[ cond1 -o cond2 ]`      |或                                                                                   |
|`[[ ! condition ]]`       |非，`!` 前后都要加空格                                                               |
|`[[ cond1 && cond2 ]]`    |与                                                                                   |
|`[[ cond1 \|\| cond2 ]]`  |或                                                                                   |
|**文件测试操作符**        |                                                                                     |    
|`-b file`                 |文件是块设备文件                                                                     |
|`-c file`                 |文件是字符设备文件                                                                   |
|`-d file`                 |文件是目录                                                                           |
|`-e file`                 |文件存在                                                                             |
|`-f file`                 |文件是普通文件（不是目录或设备文件）                                                 |
|`-h file`                 |文件是符号链接                                                                       |
|`-s file`                 |文件大小不为零                                                                       |
|`-r file`                 |文件可读                                                                             |
|`-w file`                 |文件可写                                                                             |
|`-x file`                 |文件可执行                                                                           |
|`file1 -ef file2`         |两个文件是同一个文件（硬链接或符号链接指向同一文件）                                 |
|`file1 -nt file2`         |file1 比 file2 新                                                                    |
|`file1 -ot file2`         |file1 比 file2 旧                                                                    |
|**字符串比较**            |                                                                                     |
|`-z string`               |字符串长度为 0                                                                       |
|`-n string`               |字符串长度不为 0                                                                     |
|`string1 = string2`       |字符串相等                                                                           |
|`string1 == string2`      |字符串相等                                                                           |
|`string1 != string2`      |字符串不相等                                                                         |
|`string1 < string2`       |string1 按字典顺序小于 string2                                                       |
|`string1 > string2`       |string1 按字典顺序大于 string2                                                       |
|**数值比较**              |                                                                                     |
|`num1 -eq num2`           |等于                                                                                 |
|`num1 -ne num2`           |不等于                                                                               |
|`num1 -lt num2`           |小于                                                                                 |
|`num1 -le num2`           |小于等于                                                                             |
|`num1 -gt num2`           |大于                                                                                 |
|`num1 -ge num2`           |大于等于                                                                             |
|**正则表达式匹配**        |                                                                                     |
`string =~ pattern`        |当 pattern 成功匹配到 string 中的字符则返回真，pattern 包含特殊字符时不加双引号      |
|**其他**                  |                                                                                     |
|`-o optname`              |shell 选项 optname 已启用                                                            |
|`-v varname`              |shell 变量 varname 已设置（已被赋值）                                                |
|`-R varname`              |shell 变量 varname 已设置（已被赋值或为空）                                          |

</div>

> 更选项多见：[Bash Conditional Expressions](https://www.gnu.org/software/bash/manual/bash.html#Bash-Conditional-Expressions)


### 条件结构

#### If 语句

```bash
if [ -f "file1" ]; then
elif test -f "file2"; then
elif [[ -f "file3" ]]; then
elif (( a > b )); then
else
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

#### for 循环

```bash
# 遍历简单列表
for i in 1 2 3 4 5; do
    echo "Number $i"
done
```

```bash
# 遍历字符串列表
for color in red green blue; do
    echo "Color is $color"
done
```

```bash
# 使用大括号展开
for i in {1..5}; do
    echo "Counting $i"
done
```

```bash
# 指定步长
for i in {1..10..2}; do
    echo "Step $i"
done
```

```bash
# 遍历命令输出
for file in "$(ls)"; do
    echo "File: $file"
done
```

```bash
# C 语言风格的 for 循环
for ((i=0; i<5; i++)); do
    echo "C-style loop: $i"
done
```

#### while 循环

```bash
# 基本计数器
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done
```

```bash
# 读取文件内容
while read line; do
    echo "Line: $line"
done < filename.txt
```

```bash
# 无限循环
while true; do
    echo "Press Ctrl+C to stop"
    sleep 1
done
```

```bash
# 使用算术表达式
count=0
while ((count < 5)); do
    echo "Count: $count"
    ((count++))
done
```

#### until 循环

```bash
# 基本计数器
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done
```

```bash
# 等待某个条件满足
until ping -c1 example.com &>/dev/null; do
    echo "Waiting for example.com to be reachable..."
    sleep 5
done
echo "example.com is now reachable!"
```

#### 循环控制

<div class="table-container no-thead colfirst-90">

|           |                              |
|:----------|:-----------------------------|
|`break`    |立即退出循环                  |
|`continue` |跳过当前迭代，进入下一次循环  |
|`exit`     |退出整个脚本                  |

</div>



### 函数

```bash
# 语法：不加 function 也可以
function func_name() {
    commands
}
```

```bash
# 函数参数：使用 位置参数变量 访问，$1 $2 ...
greet() {
    echo "Hello, $1!"
}
greet "Alice"
```

```bash
# 返回值：使用 echo 返回一个数组
create_array() {
    local arr=(1 2 3 4 5)
    echo "${arr[@]}"
}
my_array=($(create_array))
echo "Array elements: ${my_array[@]}"
```

```bash
# 返回函数执行状态：使用 return（0-255），0 表示成功，大于 1 表示失败
is_number() {
    [[ "$1" =~ ^[0-9]+$ ]] && return 0 || return 1
}
is_number "123" && echo "Valid number"
```

```bash
# 作用域：使用 local 创建局部变量，默认是全局变量
demo() {
    local var1="local"  # 局部变量
    var2="global"       # 全局变量
}
```

```bash
# 递归
factorial() {
    if (( $1 <= 1 )); then
        echo 1
    else
        local prev=$(factorial $(( $1 - 1 )))
        echo $(( $1 * prev ))
    fi
}
echo "计算阶乘： 5! = $(factorial 5)"
```

```bash
# 调用外部函数：使用 source 引入函数库
source functions.sh
```

```bash
# 重定向
log_to_file() {
    echo "This is a log message"
} > output.log
# 调用函数，输出会写入output.log
log_to_file
```



## Shell 扩展


<div class="table-container no-thead">

|                       |                                                                                  |
|:----------------------|:---------------------------------------------------------------------------------|
|**花括号扩展**         |                                                                                  |
|`a{b,c,d}e`            |`abe ace ade`                                                                     |
|`{1..5}`               |`1 2 3 4 5`                                                                       |
|`{a..d}`               |`a b c d`                                                                         |
|`{01..10}`             |`01 02 03 04 05 06 07 08 09 10`                                                   |
|`{a..d}{1..3}`         |`a1 a2 a3 b1 b2 b3 c1 c2 c3 d1 d2 d3`                                             |
|`{1..10..2}`           |`1 3 5 7 9`                                                                       |
|`{a..z..3}`            |`a d g j m p s v y`                                                               |
|**波浪号扩展**         |                                                                                  |
|`~`                    |当前用户的家目录                                                                  |
|`~user`                |`user` 用户的家目录                                                               |
|`~+`                   |当前目录，等同 `$PWD`                                                             |
|`~-`                   |之前目录，等同 `$OLDPWD`                                                          |
|**参数扩展**           |                                                                                  |
|`${var:-default}`      |当 `var` 未设置或为空，返回 `default`，不修改 `var`                               |
|`${var-default}`       |当 `var` 未设置，返回 `default`，不修改 `var`                                     |
|`${var:=default}`      |当 `var` 未设置或为空，返回 `default`，修改 `var=default`                         |
|`${var:+replacement}`  |当 `var` 已设置且非空，返回 `replacement`，不修改 `var`                           |
|`${var:?error_msg}`    |当 `var` 未设置或为空，打印 `error_msg` 并退出脚本                                |
|`${#str}`              |返回 `str` 的长度                                                                 |
|`${str:offset}`        |截取 `str` 从 `offset` 到末尾的部分                                               |
|`${str:offset:length}` |截取 `str` 从 `offset` 到 `offset + length` 的部分                                |
|`${str@operator}`      |操作符 `operator`                                                                 |
|                       |`u`：将 `str` 第一个字符化为大写                                                  |
|                       |`U`：将 `str` 所有字母转化为大写                                                  |
|                       |`L`：将 `str` 所有字母转化为小写                                                  |
|                       |`Q`：给 `str` 加上单引号（保留空格/引号/`$` 等特殊字符），返回 `'str'`            |
|                       |`E`：将 `str` 中的转义字符（`\n` `\t` 等）展开，类似 `echo -e`                    |
|                       |`A`：显示变量是如何声明的，如 `str='hello'` 则 `echo ${str@A}` 输出 `str='hello'` |

</div>



<div class="table-container no-thead">

|                              |                          |                |                     |
|:-----------------------------|:-------------------------|:---------------|:--------------------|
|**模式匹配**                  |                          |                |                     |
|`${var#pattern}`              |从开头删除最短匹配        |`${var#*.}`     |~~backup.~~ `tar.gz` |
|`${var##pattern}`             |从开头删除最长匹配        |`${var##*.}`    |~~backup.tar.~~ `gz` |
|`${var%pattern}`              |从末尾删除最短匹配        |`${var%.*}`     |`backup.tar` ~~.gz~~ |
|`${var%%pattern}`             |从末尾删除最长匹配        |`${var%%.*}`    |`backup` ~~.tar.gz~~ |
|`${var/pattern/replacement}`  |替换第一个匹配            |`${var/h/H}`    |`H` olahola          |
|`${var//pattern/replacement}` |替换所有匹配              |`${var//h/H}`   |`H` ola `H` ola      |
|`${var/#pattern/replacement}` |替换行首匹配              |`${var/#ho/HO}` |`HO` lahola          |
|`${var/%pattern/replacement}` |替换行尾匹配              |`${var/%la/LA}` |holaho `LA`          |
|`${var^单个通配符}`              |匹配行首字符并转换为大写  |`${var^}`       |`H` olahola          |
|`${var^^单个通配符}`             |匹配的所有字符转换为大写  |`${var^^}`      |`HOLAHOLA`           |
|`${var,单个通配符}`              |匹配行首字符并转换为小写  |`${var,}`       |`h` OLAHOLA          |
|`${var,,单个通配符}`             |匹配的所有字符转换为小写  |`${var,,}`      |`holahola`           |

</div>

<div class="table-container no-thead">

|                              |                                            |
|:-----------------------------|:-------------------------------------------|
|**变量名匹配**                |                                            |
|`${!prefix@}`                 |匹配所有以 `prefix` 开头的变量名作为独立单词，类似 `$@` |
|`${!prefix*}`                 |匹配所有以 `prefix` 开头的变量名作为一个字符串，类似 `$*` |

</div>



## 文件名匹配

<div class="table-container no-thead">

|                   |                                                                     |
|:------------------|:--------------------------------------------------------------------|
|**通配符**         |                                                                     |
|`*`                |匹配 `>=0` 个任意字符                                                |
|`?`                |匹配 `1` 个任意字符                                                  |
|`[abc]`            |匹配 `abc` 中的 `1` 个字符                                           |
|`[^0-9]`           |匹配除 `0-9` 以外的 `1` 个任意字符                                   |
|**扩展通配符**     |**需启用** `shopt -s extglob`                                        |
|`file?(.txt)`      |匹配 `file` 和 `file.txt`（匹配括号中的内容 `0` 或 `1` 次）          |
|`file*(.txt)`      |匹配 `file` `file.txt` `file.txt.txt` 等（匹配括号中的内容 `>=0` 次）|
|`file+(.txt)`      |匹配 `file.txt` `file.txt.txt` 等（匹配括号中的内容 `>=1` 次）       |
|`file@(.txt\|.log)`|匹配 `file.txt` 或 `file.log`（匹配括号内的其中一项）                |
|`!(*.txt)`         |匹配所有不以 `.txt` 结尾的文件（匹配不符合任何给定模式的）           |
|**递归匹配**       |**需启用** `shopt -s globstar`                                       |
|`**/*.txt`         |匹配当前目录及所有子目录中的 `.txt` 文件                             |

</div>


**文件名匹配问题一**：例如 `files=(*.jpg)`，当目录下没有 `jpg` 文件时，`*.jpg` 就会做为字面量赋值给 `files`：

```bash-session
$ touch {a,b,c}.txt
$ files=(*.txt)
$ echo ${files[@]}
a.txt  b.txt  c.txt
$ files=(*.jpg)
$ echo ${files[@]}
*.jpg
```

解决办法，启用 Bash 的 `nullglob` 选项，可以让通配符在没有匹配时扩展为空：

```bash
$ shopt -s nullglob
$ files=(*.jpg)
$ echo ${files[@]}   # 输出为空
```

> 其它 Bash 选项：`failglob` 没有匹配的文件则报错；`nocaseglob` 匹配时忽略大小写

**文件名匹配问题二**：`IFS` 在文件名（含空格）匹配中的应用：

```bash
IFS=$'\n' files=($(ls -1 *.txt)) # 每个文件名占一行
for f in ${files[@]}; do
    echo "处理文件: $f"
done
```

```bash-session
$ touch {'a b c',d,e}.txt
$ ./test.sh
处理文件: a b c.txt
处理文件: d.txt
处理文件: e.txt
```

如果不使用 `IFS=$'\n'` ，输出如下：

```bash-session
处理文件: a
处理文件: b
处理文件: c.txt
处理文件: d.txt
处理文件: e.txt
```


## 进程替换

```bash
<(cmd)   # 作为输入文件
>(cmd)   # 作为输出文件
```

当 Bash 遇到进程替换时，它会创建一个匿名管道并使用符号链接指向匿名管道：

```bash-session
$ ls -l <(cat)
lr-x------ 1 king king 64 Apr 12 22:01 /dev/fd/63 -> 'pipe:[521085]'
$ ls -l >(cat)
l-wx------ 1 king king 64 Apr 12 22:02 /dev/fd/63 -> 'pipe:[525267]'
```

把 `<(cmd)` 和 `>(cmd)` 看作文件，主命令可以从 `<(cmd)` 文件读取数据，向 `>(cmd)` 文件写入数据

```bash-session
示例一：tee 命令能将标准输入的数据同时向多个文件及标准输出传送
$ cat 0<<eof 1>file
foo123
bar123
eof                    # 可以看作 tee 文件1 文件2 <file >/dev/null
$ tee >(grep foo >foo.txt) >(grep bar >bar.txt) 0<file 1>/dev/null 
$ cat foo.txt
foo123
$ cat bar.txt
bar123
```

```bash-session
示例二：使用重定向发送数据到进程替换，可以看作 echo "foobar" > 文件
$ echo "foobar" 1> >(tr 'a-z' 'A-Z' >foobar.txt)
$ cat foobar.txt
FOOBAR

错误示例：后面的重定向会覆盖前面的重定向，应该使用 tee 命令（见示例一）
$ echo "foobar" 1> >(tr 'a-z' 'A-Z' >foobar.txt) 1> >(sed s/$/BAD/ >bad.txt)
$ cat foobar.txt
$ cat bad.txt
foobarBAD
```

```bash-session
示例三：可以看作 sed 参数 文件1 文件2
$ sed -e 's/foo/FOO/' -e 's/bar/BAR/' <(echo foo) <(echo bar)
FOO
BAR
```

> 有些命令如 `tr` 只支持标准输入不能直接操作文件，`ls` 则不支持标准输入，
> `sed` 既支持标准输入又能直接操作文件，要看情况使用重定向和进程替换


## 字段分隔符 IFS

`IFS`（Internal Field Separator），是 Bash 中的一个特殊环境变量，用于单词的分割，Bash 会对未包含在双引号中的参数扩展 `$var`、命令替换 `$(cmd)` 和算术扩展 `$(())` 的结果进行扫描，以执行单词分割

`IFS` 默认值为空格、制表符 `\t` 和换行符 `\n`，`IFS` 的查看和修改：

```bash
printf "%q\n" "$IFS"
IFS=$' \t\n'
```

> `$' '` 允许在字符串中使用转义序列来表示特殊字符，即 `\t` 会被转化为真正的制表符存入 `IFS` 中

`IFS` 只影响 **不加引号** 的参数扩展，如 `$str` ：

```bash
str="one:two:three"
IFS=:
for word in $str; do
    echo "[$word]"
done
```

```bash-session
[one]
[two]
[three]
```

若加了引号，则引号里面内容被视作为一个元素：

```bash
str="one:two:three"
IFS=:
for word in "$str"; do
    echo "[$word]"
done
```

```bash-session
[one:two:three]
```

`IFS` 不会影响字面量：

```bash
IFS=:
for word in one:two:three; do
    echo "[$word]"
done
```

```bash-session
[one:two:three]
```

`IFS` 配合 `read` 命令使用：

```bash
IFS=: read user pass shell <<< "root:secret:/bin/bash"
echo -e "User=$user,  Passwd=$pass,  Shell=$shell"
```

```bash-session
User=root,  Passwd=secret,  Shell=/bin/bash
```

`IFS` 在数组中的使用：

```bash
str="apple:banana:orange"
IFS=: arr=($str)
echo "arr[0]=${arr[0]},  arr[1]=${arr[1]},  arr[2]=${arr[2]}"
```

```bash-session
arr[0]=apple,  arr[1]=banana,  arr[2]=orange
```


`IFS` 对位置参数变量 `$*` 的影响：

```bash
set -- "one" "two" "three"    # set -- 用于手动设置位置参数 $1, $2, $3 ...
IFS=:
# $* 会按 IFS 的第一个字符为分隔符展开变量
echo "Using \$*: $*"
# $@ 不受 IFS 影响
echo "Using \$@: $@"
```

```bash-session
Using $*: one:two:three
Using $@: one two three
```







## 协进程

协进程（coprocess），允许你在脚本中启动一个子进程并与它进行双向通信


```bash
coproc NAME { command; }
```

如果不指定 `NAME`，Bash 会使用默认名称 `COPROC`，协进程启动后，Bash 会创建两个文件描述符及 PID 变量：

<div class="table-container colfirst-90">

|           |                                     |
|:----------|:------------------------------------|
|`NAME[0]`  | 用于从协进程读取（协进程的标准输出）|
|`NAME[1]`  | 用于向协进程写入（协进程的标准输入）|
|`NAME_PID` | 协进程的 PID                        |

</div>

```bash
#!/bin/bash

coproc data_processor {
    while read input; do
        sleep 1  # 模拟处理延迟
        echo "$input" | tr 'a-z' 'A-Z'  # 处理数据 - 这里简单转换为大写
    done
}

for i in {1..5}; do
    echo "data packet $i" >&"${data_processor[1]}"  # 非阻塞发送
done
echo "数据发送完成"

echo "干点别的事..."
sleep 3

for i in {1..5}; do
    read -t 5 response <&"${data_processor[0]}"
    echo "Received: $response"
done
echo "数据接收完成"

exec ${data_processor[0]}<&-  # 无阻塞风险也可不关闭
exec ${data_processor[1]}>&-  # 关闭协程的输入 fd，避免协进程的 read 无限等待输入（阻塞）

# 关闭文件描述符后，协进程通常会自行终止，也可 kill ${data_processor_PID}
wait $data_processor_PID     # 确保协进程正确退出并回收其资源
```

```bash-session
$ ./test.sh
数据发送完成
干点别的事...
Received: DATA PACKET 1
Received: DATA PACKET 2
Received: DATA PACKET 3
Received: DATA PACKET 4
Received: DATA PACKET 5
数据接收完成
```




## Bash 调试


基本调试方法，执行并打印每条命令：

```bash-session
$ bash -x script.sh
```

局部调试：

```bash
#!/bin/bash
set -x   # 开启调试
# 需要调试的代码部分
set +x   # 关闭调试
```



## 任务控制

将任务转入后台，使用 `&` 或 `Ctrl+z` ：

```bash-session
$ sleep 60 &
[1] 13492
```

查看后台任务，使用 `jobs` 命令：

```bash-session
$ jobs
[1]   Done                    sleep 60
[2]   Stopped                 sleep 600 &
[3]-  Running                 sleep 6000 &
[4]+  Running                 sleep 60000 &
```

其中 `+` 表示最近放入后台的任务，`-` 表示倒数第二放入后台的任务

恢复后台任务到前台，使用 `fg` 命令：

```bash-session
$ fg      # 恢复最近的任务到前台，即带 + 号的
$ fg %2   # 恢复 2 号任务到前台
```
让后台 `Stopped` 的任务继续运行，使用 `bg` 命令：

```bash-session
$ bg      # 让最近放入后台的任务继续运行
$ bg %2   # 让 2 号后台任务继续运行
```


## 信号处理

`trap` 用于在脚本执行过程中捕获和处理信号

```bash
#!/bin/bash
trap "echo '捕获到Ctrl+C';" SIGINT
echo "按Ctrl+C试试看"
sleep 10
```

```bash-session
$ ./test.sh
按Ctrl+C试试看
^C捕获到Ctrl+C
```

<div class="table-container colfirst-80">

|信号编号|信号名	|说明                               |
|:-------|:---------|:----------------------------------|
|1	     |SIGHUP	|终端挂断或控制进程终止             |
|2	     |SIGINT	|键盘中断 `Ctrl+C`                  |
|3	     |SIGQUIT	|键盘退出  `Ctrl+\`                 |
|9	     |SIGKILL	|强制终止 `kill -9`（不能被捕获）   |
|15	     |SIGTERM	|终止信号 `kill`                    |
|0	     |EXIT	    |Shell 脚本运行完成后退出时默认触发 |

</div>



## Shell 内置命令

> 下表由 DeepSeek 生成，仅供参考，详见官方文档 [Shell Builtin Commands](https://www.gnu.org/software/bash/manual/bash.html#Shell-Builtin-Commands)

| 命令 | 说明 |
|:------|:------|
| `:` | 空操作(返回 true) |
| `.` | 在当前 shell 中执行脚本 |
| `alias` | 创建命令别名 |
| `bg` | 将作业放到后台运行 |
| `bind` | 绑定按键到 readline 函数或宏 |
| `break` | 退出 for/while/until 循环 |
| `builtin` | 执行指定的 shell 内置命令 |
| `caller` | 返回当前子程序调用的上下文 |
| `case` | 多分支条件判断 |
| `cd` | 改变工作目录 |
| `command` | 执行命令(绕过函数查找) |
| `compgen` | 生成可能的补全匹配 |
| `complete` | 指定命令如何补全 |
| `continue` | 继续下一次循环迭代 |
| `declare` | 声明变量/设置属性 |
| `dirs` | 显示目录栈 |
| `disown` | 从作业表中移除作业 |
| `echo` | 显示参数 |
| `enable` | 启用/禁用内置命令 |
| `eval` | 将参数作为命令执行 |
| `exec` | 用指定命令替换 shell |
| `exit` | 退出 shell |
| `export` | 设置环境变量 |
| `false` | 返回 false |
| `fc` | 编辑并重新执行命令 |
| `fg` | 将作业放到前台运行 |
| `for` | 循环命令 |
| `function` | 定义函数 |
| `getopts` | 解析位置参数 |
| `hash` | 记住命令的完整路径 |
| `help` | 显示帮助信息 |
| `history` | 显示命令历史 |
| `if` | 条件判断 |
| `jobs` | 列出活动作业 |
| `kill` | 向进程发送信号 |
| `let` | 执行算术运算 |
| `local` | 声明局部变量 |
| `logout` | 退出登录 shell |
| `mapfile` | 从标准输入读取到数组 |
| `popd` | 从目录栈中移除目录 |
| `printf` | 格式化输出 |
| `pushd` | 向目录栈添加目录 |
| `pwd` | 打印当前工作目录 |
| `read` | 从标准输入读取一行 |
| `readarray` | 同 mapfile |
| `readonly` | 标记变量为只读 |
| `return` | 从函数中返回 |
| `select` | 生成菜单选择 |
| `set` | 设置/取消设置 shell 选项和位置参数 |
| `shift` | 移动位置参数 |
| `shopt` | 设置/取消设置 shell 选项 |
| `source` | 同 . (在当前 shell 中执行脚本) |
| `suspend` | 暂停 shell 执行 |
| `test` | 条件测试 |
| `time` | 测量命令执行时间 |
| `times` | 显示 shell 和进程的累计用户/系统时间 |
| `trap` | 设置信号处理程序 |
| `true` | 返回 true |
| `type` | 显示命令类型 |
| `typeset` | 同 declare |
| `ulimit` | 设置/获取资源限制 |
| `umask` | 设置文件创建掩码 |
| `unalias` | 移除别名 |
| `unset` | 移除变量或函数 |
| `until` | 直到条件为真时循环 |
| `variables` | 列出 shell 变量 |
| `wait` | 等待作业完成 |
| `while` | 当条件为真时循环 |
| `{ }` | 命令分组(在当前 shell 中执行) |
| `[[ ]]` | 条件表达式测试 |


## Shell 变量

> 下表由 DeepSeek 生成，仅供参考，详见官方文档 [Shell Variables](https://www.gnu.org/software/bash/manual/bash.html#Shell-Variables)

| 变量名 | 说明 |
|--------|------|
| `BASH` | 当前 Bash 实例的完整路径名 |
| `BASHOPTS` | 已启用 shell 选项的列表（冒号分隔） |
| `BASHPID` | 当前 Bash 进程的 PID |
| `BASH_ALIASES` | 关联数组，包含当前定义的别名 |
| `BASH_ARGC` | 数组，包含当前子程序调用栈的帧数 |
| `BASH_ARGV` | 数组，包含所有当前子程序调用栈中的参数 |
| `BASH_ARGV0` | 引用当前 Bash 命令名的变量 |
| `BASH_CMDS` | 关联数组，包含已执行命令的位置 |
| `BASH_COMMAND` | 正在执行或即将执行的命令 |
| `BASH_COMPAT` | 设置兼容模式级别 |
| `BASH_ENV` | 如果设置，在非交互式 shell 启动时会执行该文件 |
| `BASH_EXECUTION_STRING` | 使用 -c 选项调用的命令字符串 |
| `BASH_LINENO` | 数组，包含调用栈中各帧的行号 |
| `BASH_LOADABLES_PATH` | 冒号分隔的目录列表，用于查找可加载的内建命令 |
| `BASH_REMATCH` | 数组，包含最近正则表达式匹配的结果 |
| `BASH_SOURCE` | 数组，包含调用栈中各帧的源文件名 |
| `BASH_SUBSHELL` | 当前子 shell 的嵌套级别 |
| `BASH_VERSINFO` | 数组，包含 Bash 版本信息 |
| `BASH_VERSION` | Bash 的版本号字符串 |
| `BASH_XTRACEFD` | 调试跟踪输出的文件描述符 |
| `CDPATH` | cd 命令的搜索路径 |
| `CHILD_MAX` | 设置 shell 记住的已完成子进程数量 |
| `COLUMNS` | 终端宽度（列数） |
| `COMP_CWORD` | 当前光标位置在 `${COMP_WORDS}` 中的索引 |
| `COMP_LINE` | 当前命令行 |
| `COMP_POINT` | 当前光标位置相对于命令开始的位置 |
| `COMP_TYPE` | 补全尝试类型 |
| `COMP_KEY` | 触发补全的键 |
| `COMP_WORDBREAKS` | 单词补全的分隔符 |
| `COMP_WORDS` | 数组，包含当前命令行的各个单词 |
| `COMPREPLY` | 数组，包含可能的补全结果 |
| `COPROC` | 协进程的文件描述符数组 |
| `DIRSTACK` | 数组，包含目录栈的内容 |
| `EMACS` | 如果设置为 't'，表示在 Emacs shell 缓冲区中运行 |
| `ENV` | 类似于 `BASH_ENV`，用于 POSIX 模式 |
| `EUID` | 当前用户的有效用户 ID |
| `EXECIGNORE` | 冒号分隔的模式列表，`PATH` 查找时忽略匹配的文件 |
| `FCEDIT` | fc 命令的默认编辑器 |
| `FIGNORE` | 文件名补全时忽略的后缀列表 |
| `FUNCNAME` | 数组，包含当前调用栈中的所有函数名 |
| `FUNCNEST` | 函数嵌套的最大深度 |
| `GLOBIGNORE` | 模式列表，扩展时忽略匹配的文件名 |
| `GROUPS` | 数组，包含当前用户所属的组 |
| `HISTCMD` | 当前命令在历史记录中的编号 |
| `HISTCONTROL` | 控制历史记录如何保存 |
| `HISTFILE` | 历史记录文件路径 |
| `HISTFILESIZE` | 历史记录文件的最大行数 |
| `HISTIGNORE` | 冒号分隔的模式列表，匹配的命令不存入历史 |
| `HISTSIZE` | 内存中历史记录的最大数量 |
| `HISTTIMEFORMAT` | 历史时间戳格式 |
| `HOME` | 当前用户的主目录 |
| `HOSTFILE` | 包含主机名补全列表的文件 |
| `HOSTNAME` | 当前主机名 |
| `HOSTTYPE` | 主机类型（CPU 架构） |
| `IGNOREEOF` | 控制 EOF 作为输入时的行为 |
| `INPUTRC` | readline 初始化文件路径 |
| `LANG` | 本地化语言设置 |
| `LC_ALL` | 覆盖所有本地化设置的变量 |
| `LC_COLLATE` | 设置排序顺序 |
| `LC_CTYPE` | 设置字符分类和转换 |
| `LC_MESSAGES` | 设置消息显示的语言 |
| `LC_NUMERIC` | 设置数字格式 |
| `LINENO` | 脚本或函数中的当前行号 |
| `LINES` | 终端高度（行数） |
| `MACHTYPE` | 系统类型的完整描述 |
| `MAILCHECK` | 检查新邮件的频率（秒） |
| `MAPFILE` | 数组，包含 mapfile/readarray 读取的文本行 |
| `OLDPWD` | 前一个工作目录 |
| `OPTERR` | 控制是否显示 getopts 错误 |
| `OSTYPE` | 操作系统类型 |
| `PIPESTATUS` | 数组，包含最近前台管道中每个命令的退出状态 |
| `POSIXLY_CORRECT` | 如果设置，Bash 以 POSIX 模式运行 |
| `PPID` | 父进程的 PID |
| `PROMPT_COMMAND` | 在主提示符显示前执行的命令 |
| `PROMPT_DIRTRIM` | 设置路径缩写显示的深度 |
| `PS0` | 在交互式 shell 读取命令后显示的字符串 |
| `PS1` | 主提示符字符串 |
| `PS2` | 次提示符字符串 |
| `PS3` | select 命令的提示符 |
| `PS4` | 调试跟踪时的提示符 |
| `PWD` | 当前工作目录 |
| `RANDOM` | 返回 0-32767 之间的随机数 |
| `READLINE_LINE` | readline 行缓冲区的内容 |
| `READLINE_POINT` | readline 行缓冲区中的光标位置 |
| `REPLY` | read 命令的默认输出变量 |
| `SECONDS` | shell 启动后经过的秒数 |
| `SHELL` | shell 的路径名 |
| `SHELLOPTS` | 已启用 shell 选项的列表（冒号分隔） |
| `SHLVL` | shell 嵌套级别 |
| `TIMEFORMAT` | time 命令的输出格式 |
| `TMOUT` | 输入超时时间（秒） |
| `TMPDIR` | 临时文件目录 |
| `UID` | 当前用户的真实用户 ID |
| `_` | 上一个命令的最后一个参数 |
