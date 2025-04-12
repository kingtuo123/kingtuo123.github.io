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



```bash
# 变量定义，等号两边不能有空格
name="king"
var=30

# 将命令的输出赋值给变量，如果输出包含空格最好加上双引号
name=$(whoami)
name=`whoami`

# 变量引用
echo $name
echo ${name}

# 只读变量
readonly name="king"
declare -r name="king"

# 删除变量
unset variable_name

# 变量默认值，如果 var 未设置或为空，使用 default
echo ${var:-default}  

# 字符串拼接
a="$str1$str2"


```

#### 字符串操作

```bash
str="01234567"
length=${#str}          # 字符串长度 8
substring=${str:0:4}    # 子字符串 1234
```

#### 双引号 vs 单引号

单引号不会扩展变量、命令替换或输出部分特殊字符

```bash-session
$ echo "hello $(whoami)"
hello king
$ echo 'hello $(whoami)'
hello $(whoami)
```

### 特殊变量

<div class="table-container no-thead colfirst-50">

|    |                                     |
|:---|:------------------------------------|
|`0` |脚本名                               |
|`1` |第 1 个参数，参数大于 10 用 `${10}`  |
|`#` |参数个数                             |
|`@` |所有参数 （每个参数都是独立的字符串）|
|`*` |所有参数 （所有参数作为一个字符串）  |
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

<div class="table-container no-thead colfirst-50">

|      |                                                                  |
|:-----|:-----------------------------------------------------------------|
|`\|`  |将前一个命令的 **标准输出** 传递给下一个命令                      |
|`\|&` |将前一个命令的 **标准输出** 和 **标准错误** 一起传递给下一个命令  |

</div>



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
|`n<<eof`             |创建临时 `file`，逐行写入内容直到 `eof`，然后复制 `file` 的 `fd` → `n`                 |
|`n<<<string`         |创建临时 `file`，写入一行 `string`（包含空格要加引号），然后复制 `file` 的 `fd` → `n`  |
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

> 之前习惯在 `>` 右侧加空格，但像 `command 1> file1 2> file2` 和 `command 1>file1 2>file2` 明显后者更易阅读和理解，`file` 应是 `>` 的参数而不是 `command` 的参数，所以还是不加吧




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

<div class="table-container no-thead colfirst-90">

|           |                              |
|:----------|:-----------------------------|
|`break`    |立即退出循环                  |
|`continue` |跳过当前迭代，进入下一次循环  |
|`exit`     |退出整个脚本                  |

</div>



### 协进程

协进程（coprocess），允许你在脚本中启动一个子进程并与它进行双向通信

如果不指定 `NAME`，Bash 会使用默认名称 `COPROC`：

```bash
coproc NAME { command; }
```

协进程启动后，Bash 会创建两个文件描述符及 PID 变量：

<div class="table-container no-thead colfirst-90">

|           |                  |
|:----------|:-----------------|
|`NAME[0]`  | 协进程的标准输出 |
|`NAME[1]`  | 协进程的标准输入 |
|`NAME_PID` | 协进程的 PID     |

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

exec {data_processor[0]}<&-  # 无阻塞风险也可不关闭
exec {data_processor[1]}>&-  # 关闭协程的输入 fd，避免协进程的 read 无限等待输入（阻塞）

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

### 花括号扩展

```bash
echo a{b,c,d}e      # 输出: abe ace ade
echo {1..5}         # 输出: 1 2 3 4 5
echo {a..d}         # 输出: a b c d
echo {01..10}       # 输出: 01 02 03 04 05 06 07 08 09 10
echo {a..d}{1..3}   # 输出: a1 a2 a3 b1 b2 b3 c1 c2 c3 d1 d2 d3
echo {1..10..2}     # 输出: 1 3 5 7 9
echo {a..z..3}      # 输出: a d g j m p s v y
```

### 波浪号扩展

```bash
echo ~              # 当前用户的主目录，输出: /home/username 
echo ~root          # 指定用户的主目录，输出: /root
```

### 参数扩展

```bash
# 默认值
${var:-default}      # 如果 var 未设置或为空，返回 default，不修改 var
${var-default}       # 仅当 var 未设置时，返回 default，不修改 var

# 赋值默认值
${var:=default}      # 如果 var 未设置或为空，返回 default，修改 var=default

# 变量存在检查
${var:+replacement}  # 如果 var 已设置且非空，返回 replacement，不修改 var

# 错误检查
${var:?error_msg}    # 如果 var 未设置或为空，打印 error_msg 并退出

# 字符串长度
${#var}              # 返回变量值的长度

# 子字符串
${var:offset}        # 从 offset 开始截取到结尾，返回截取的部分
${var:offset:length} # 从 offset 开始，截取长度为 length，返回截取的部分
```

```bash
# 查找替换
${var/pattern/replacement}  # 替换第一个匹配
${var//pattern/replacement} # 替换所有匹配
${var/#pattern/replacement} # 替换行首匹配（^abc）
${var/%pattern/replacement} # 替换行尾匹配（abc$）

# 模式匹配
${var#pattern}     # 删除最短匹配前缀（^abc），返回剩下的部分
${var##pattern}    # 删除最长匹配前缀（^abc），返回剩下的部分
${var%pattern}     # 删除最短匹配后缀（abc$），返回剩下的部分
${var%%pattern}    # 删除最长匹配后缀（abc$），返回剩下的部分

# 示例
file="backup.tar.gz"
echo ${file#*.}      # 输出: tar.gz
echo ${file##*.}     # 输出: gz
echo ${file%.*}      # 输出: backup.tar
echo ${file%%.*}     # 输出: backup
```

### 文件名扩展

<div class="table-container no-thead colfirst-100">

|            |                               |
|:-----------|:------------------------------|
|`*`         |匹配 `>=0` 个字符              |
|`?`         |匹配 `1` 个字符                |
|`[abc]`     |匹配 `abc` 中的 `1` 个字符     |
|`[!0-9]`    |不匹配 `0-9` 中的 `1` 个字符   |
|`{jpg,png}` |匹配 `jpg` 或 `png`            |

</div>

文件名匹配有个问题，例如 `files=(*.jpg)`，当目录下没有 `jpg` 文件时，`*.jpg` 就会做为字面量赋值给 `files`：

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


### 进程替换

```bash
<(cmd)   # 作为输入文件
>(cmd)   # 作为输出文件
```


当 Bash 遇到进程替换时，它会创建一个匿名管道并使用符号链接指向管道：

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
eof
$ tee >(grep foo >foo.txt) >(grep bar >bar.txt) 0<file 1>/dev/null
$ cat foo.txt
foo123
$ cat bar.txt
bar123
```

```bash-session
示例二：使用重定向发送数据到进程替换
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
示例三：处理多个命令的输出
$ sed -e 's/foo/FOO/' -e 's/bar/BAR/' <(echo foo) <(echo bar)
FOO
BAR
```

> 有些命令如 `tr` 只支持标准输入不能直接操作文件，`ls` 则不支持标准输入，
> `sed` 既支持标准输入又能直接操作文件，要看情况使用重定向和进程替换



## IFS 与 双引号的关系

## 匿名管道

## Bash 调试

```bash
set -x 
bash -x 
set -e
```

## bash 编程常犯错误
