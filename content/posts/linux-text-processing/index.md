---
title: "Linux 文本处理命令"
date: "2025-02-27"
summary: "sed、awk、grep等命令"
description: ""
categories: [ "linux" ]
tags: [ "cmd" ]
---

## Sed

```bash
sed [选项] '[地址]命令' 文件
```

<div class="table-container">

|选项              |                                                                                                |
|:-----------------|:-----------------------------------------------------------------------------------------------|
|`-n`              |禁止自动打印，sed 每处理一行会自动打印一行，所以一般搭配 `p` 命令使用                           |
|`-e`              |多重命令，例如：`sed -e 's/foo/bar/' -e 's/baz/qux/' file.txt`                                  |
|`-i`              |直接修改文件内容                                                                                |
|`-r` 或 `-E`      |使用扩展正则表达式                                                                              |
|**地址（行定位）**|                                                                                                |
|`n`               |第 n 行                                                                                         |
|`n,m`             |第 n 到 m 行                                                                                    |
|`n,+m`            |第 n 到 n+m 行                                                                                  |
|`n~m`             |从第 n 行开始，每隔 m 行匹配一次                                                                |
|`$`               |最后一行                                                                                        |
|`/pattern/`       |包含 pattern 的行，pattern 是正则表达式                                                         |
|`/start/,/end/`   |包含 start 的行到包含 end 的行                                                                  |
|`n,/end/`         |第 n 行到包含 end 的行                                                                          |
|`!`               |对地址取反，表示不匹配的行，例如：`sed -i sed '1,3!d' file.txt` 只保留 1 到 3 行，删除其它行    |
|**命令**          |                                                                                                |
|`s`               |替换文本，格式：`s/旧文本/新文本/[标志]`，标志：`g` 全局替换，`i` 忽略大小写，`p` 打印替换后的行|
|`d`               |删除行                                                                                          |
|`p`               |打印行                                                                                          |
|`i`               |在指定行上方插入新行及文本，如 `sed '2i newline' file.txt`                                      |
|`a`               |在指定行下方插入新行及文本                                                                      |
|`c`               |替换整行内容                                                                                    |
|`=`               |打印当前行行号                                                                                  |

</div>


### sed 脚本

```sed
#!/bin/sed -f
s/hello/HELLO/g
s/world/WORLD/g
```

```bash-session
$ chmod +x example.sed
$ ./example.sed file.txt
$ sed -f example.sed file.txt
```


## Awk

```bash
awk [选项] '[表达式] { 语句1; 语句2; ... }' 文件
```

<div class="table-container">

|选项                    |                                                                                              |
|:-----------------------|:---------------------------------------------------------------------------------------------|
|`-F`                    |指定分隔符（默认为空格或制表符），使用 `$n` 引用字段，`$0` 表示整个字段                                                              |
|`-v`                    |定义变量，例如：`awk -v var=123 '{print $1+var}' file.txt`                                    |
|**表达式（行定位）**    |                                                                                              |
|`/pattern/`             |包含 pattern 的行（正则匹配），例如：`awk '/error/ { print $0 }' file.txt`                                |
|`$n ~ /pattern/`        |第 n 列包含 pattern 的行                        |
|`$n !~ /pattern/`       |第 n 列不包含 pattern 的行                                |
|`$n > 10`               |第 n 列大于 10 的行，例如：`awk '$1 > 10 { print $0 }' file.txt`，还有 `< <= > >= != ==`                                |
|`$n == "abc"`           |第 n 列等于 abc 字符串的行                                                                         |
|`$n > 10 && $n < 20 `   |第 n 列大于 10 小于 20 的行，还有 `\|\|`                                                                               |
|`$1 + $2 > 10`          |第 1、2 列的和大于 10 的行，还有 `+ - * / %` 等 |


</div>

### awk 脚本

awk 实际是一门编程语言，上面的只是在命令行的简单应用

更多内容参考：[GNU awk](https://www.gnu.org/software/gawk/manual/gawk.html)、[Man gawk](https://man.archlinux.org/man/gawk.1)

#### 内置变量 / 函数

<div class="table-container">

|变量                    |                                                                                           |
|:-----------------------|:------------------------------------------------------------------------------------------|
|`NF`                    |当前行的字段数                                                                             |
|`NR`                    |当前处理的行号                                                                             |
|`FS`                    |字段分隔符（默认空格或制表符），即命令行的 `-F` 选项，可在脚本中修改                       |
|`OFS`                   |输出字段分隔符（默认空格），当 `OFS=":"`，`print $1,$2,$3` 输出类似 `a:b:c`                |
|`RS`                    |记录分隔符（默认换行符），即一个换行符被 awk 识别为一行进行处理                            |
|`ORS`                   |输出记录分隔符（默认换行符），即输出的每行末尾是换行符                                     |
|**函数**                |                                                                                           |
|`length(string)`        |返回字符串的长度                                                                           |
|`tolower(string)`       |转化为小写，还有 `toupper`                                                                 |
|`int(x)`                |返回整数部分，还有 `sqrt` 平方根、`log` 对数等                                             |
|`systime()`             |返回当前时间的时间戳                                                                       |
|`strftime(fmt, timestamp)`|将时间戳转化为格式化字符串，如 `strftime("%Y-%m-%d %H:%M:%S", systime())`                |
|`asort(array)`          |对数组进行排序，并返回数组的长度                                                           |

</div>

#### 语句

所有语句都必须包含在 `{ }` 中

多条语句使用 `;` 分隔，或者另起一行

字符串使用 `" "` 包裹


#### BEGIN 和 END 

`BEGIN` 和 `END` 在处理第一行之前和最后一行之后执行一次，例如：

```awk
#!/bin/awk -f
BEGIN { count = 0 }
/error/ { count++ }
END { print "Total error:", count }
```

#### 变量 / 数组 / 流程控制 / 函数

以下程序仅为语法示例，不能运行：

```awk
#!/bin/awk -f
BEGIN { 
    print "BEGIN" 
    i = 0
}

{
    # awk 的数组是无序的
    array[1] = "apple"
    array[2] = "banana"
    array["fruit"] = "orange"

    delete array[2]

    if ("banana" in array) {
        print "存在"
    } else {
        print "不存在"
    }

    for (i in array) {
        print "遍历数组", i, array[i]
    }

    for (i = 1; i <= n; i++) {
        print "跳过后面的语句"
        continue
        print "跳出当前循环"
        break
        print "跳过当前行，awk 是逐行处理文本的"
        next
        print "退出脚本"
        exit 0
    }

    while (i <= NF) {
        i++
    }

    switch ($1) {
        case "apple":
            print "It's an apple"
            break
        case "banana":
            print "It's a banana"
            break
        default:
            print "It's something else"
    }

    function add(a, b) {
        print "自定义函数"
        return a + b
    }
}

END { print "END" }
```

#### 实例 - 统计 /etc/passwd

```awk
#!/bin/awk -f

BEGIN {
    print "开始统计用户数据"
    FS = ":"
    OFS = "\t"
    total = 0
}

{
    print "name="$1, "uid="$3, "gid="$4
    total++
}

END {
    printf "统计完毕，共 %d 名用户\n", total
}
```

```bash-session
$ chmod +x count.awk
$ ./count.awk /etc/passwd
开始统计用户数据
name=root       uid=0   gid=0
name=bin        uid=1   gid=1
....
name=avahi      uid=61  gid=61
统计完毕，共 23 名用户
```


## Grep

```bash
grep [选项] '正则表达式' 文件
```

<div class="table-container">

|基本搜索           |                                                                                               |
|:------------------|:----------------------------------------------------------------------------------------------|
|`-i`               |忽略大小写                                                                                     |
|`-v`               |反向匹配，输出不包含匹配字符串的行                                                             |
|`-w`               |匹配整个单词，如 `grep -w 'word' file.txt` 不会匹配 `words`                                    |
|`-x`               |匹配整行，如 `grep -x 'exact line' file.txt` 只匹配完全等于 `exact line` 的行                  |
|**输出控制**       |                                                                                               |
|`-c`               |统计匹配的行数                                                                                 |
|`-n`               |显示匹配行的行号                                                                               |
|`-o`               |只输出匹配的部分，而不是整行                                                                   |
|`-q`               |静默模式，不输出任何内容，仅通过退出状态码表示是否匹配成功                                     |
|**文件操作**       |                                                                                               |
|`-r` 或 `-R`       |递归搜索目录中的文件，如 `grep -r 'pattern' /path/to/dir`                                      |
|`--include`        |指定要搜索的文件类型，如 `grep -r 'pattern' /path/to/dir --include '*.txt'`                    |
|`--exclude`        |排除特定文件类型                                                                               |
|`-l`               |输出文件中包含匹配字符串的文件名，如 `grep -l 'pattern' *.txt`输出包含 `pattern` 的 `.txt` 文件名|
|`-L`               |输出文件中不包含匹配字符串的文件名                                                             |
|**正则表达式**     |                                                                                               |
|`-E`               |使用扩展正则表达式（等同于 `egrep` 命令）；默认是基本正则表达式，不支持 `+ ? () {}` 等         |
|`-F`               |不解析正则表达式，视为普通字符串进行匹配                                                       |
|`-P`               |使用 Perl 兼容的正则表达式（PCRE），支持 `\d \w \s` 等                                         |
|**上下文控制**     |                                                                                               |
|`-A`               |显示匹配行及其后面的 `n` 行，如 `grep -A 2 'pattern' file.txt`                                 |
|`-B`               |显示匹配行及其前面的 `n` 行                                                                    |
|`-C`               |显示匹配行及其前后各 `n` 行                                                                    |
|**其他选项**       |                                                                                               |
|`--color`          |高亮显示匹配的部分                                                                             |
|`-e`               |多重匹配，如 `grep -e 'pattern1' -e 'pattern2' file.txt`                                       |

</div>



## Cut

`cut` 用于从文件或标准输入中提取指定的字符、字段

```bash
cut -d ':' -f 1 data.txt
```

<div class="table-container no-thead">

|选项                |                                                                                               |
|:-------------------|:----------------------------------------------------------------------------------------------|
|`-d`                |指定字段分隔符（默认以制表符 `\t` 为分隔符）                                                   |
|`-f`                |按字段提取，如 `cut -f 1 data.txt` 提取第一列，位置的表示方法有： `1,2,3`、`1-3`               |
|`-s`                |只输出包含分隔符的行，就不需要 `grep` 等命令过滤行了                                           |
|`-c`                |按字符提取，如 `cut -c 1-5 data.txt` 提取每行的前 5 个字符                                     |
|`--complement`      |提取除指定范围外的内容，如 `cut -d ',' -f 1 --complement data.txt` 提取除第一列外的所有列      |
|`--output-delimiter`|指定输出时的分隔符，如 `cut -d ',' -f 1,3 --output-delimiter ':' data.txt`                     |

</div>



## Tr

`tr` 用于转换或删除字符，如 `echo "hello world" | tr 'a-z' 'A-Z'` 输出 `HELLO WORLD`

```bash
tr [选项] 字符集1 字符集2
```

<div class="table-container no-thead">

|选项         |                                                                                                  |
|:------------|:-------------------------------------------------------------------------------------------------|
|`-d`         |删除字符集1中的字符，如 `echo "hello 123 world" \| tr -d '0-9 '` 输出 `helloworld`                |
|`-c`         |使用不包含在字符集1中的字符（补集），如 `echo "hello 123 world" \| tr -cd 'a-z'` 输出 `helloworld`|
|`-s`         |将字符集1中连续重复的字符压缩为单个字符，如 `echo "goooood" \| tr -s 'o'` 输出 `god`              |
|`-t`         |截断长的字符集，确保两个字符集长度一致，如 `echo "abcdef" \| tr -t 'abcdef' '123'` 输出 `123def`  |

</div>



## Tee

`tee` 的主要作用是将数据分流，既可以在屏幕上显示，又可以保存到文件中，如下：

```bash
echo "Hello, World!" | tee output.txt
```

<div class="table-container no-thead">

|选项         |                                                                                               |
|:------------|:----------------------------------------------------------------------------------------------|
|`-a`         |将数据追加到文件末尾，而不是覆盖文件                                                           |
|`-i`         |忽略中断信号（如 `Ctrl+C`）                                                                    |

</div>


## Sort

`sort` 用于对文件内容或标准输入进行排序操作

<div class="table-container no-thead">

|||
|:--|:--|
|**排序控制**||
|`-b` |忽略行首的空白字符|
|`-d` |按照字典顺序排序，只考虑字母、数字和空白|
|`-f` |忽略大小写|
|`-g` |按照常规数值排序|
|`-h` |按照人类可读的数字排序（如 2K, 1G）|
|`-i` |忽略不可打印字符|
|`-M` |按照月份名称（JAN, FEB等）排序|
|`-n` |按照数值大小排序|
|`-R` |随机排序|
|`-r` |逆序排序|
|`-V` |按照版本号排序|
|**键定义**||
|`-k` |指定排序的键（字段）位置|
|`-t` |指定字段分隔符|
|**其他选项**||
|`-c` |检查文件是否已排序|
|`-m` |合并已排序的文件|
|`-o` |将结果输出到指定文件|
|`-u` |去除重复行（相当于 uniq）|
|`-z` |以 NUL 字符作为行结束符|

</div>


## Uniq

`uniq` 只能处理 **连续的重复行**，两条重复行之间隔了一条也不行，所以一般搭配 `sort` 命令使用

```bash
sort file.txt | uniq > unique.txt
```

<div class="table-container no-thead">

|选项|描述|
|:--|:--|
|`-c`   |在每行前显示该行重复出现的次数|
|`-d`   |只显示重复的行（每组重复行只显示一次）|
|`-D`   |显示所有重复的行|
|`-u`   |只显示不重复的行|
|`-i`   |忽略大小写差异|
|`-f N`	|跳过前 N 个字段的比较，字段分隔符默认是空白字符（空格/Tab）|
|`-s N`	|跳过前 N 个字符的比较|
|`-w N`	|只比较每行的前 N 个字符|

</div>


## Wc

`wc` 用于统计文件中的行数、单词数和字节数

<div class="table-container no-thead">

|选项||
|:--|:--|
|`-l`|统计行数  |
|`-w`|统计单词数|
|`-c`|统计字节数|

</div>

## Tac

`tac` 用于将文件内容从最后一行按行逆序输出，与 `cat` 命令的功能相反
