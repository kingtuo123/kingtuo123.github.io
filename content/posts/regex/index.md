---
title: "正则表达式"
date: "2025-02-24"
summary: "记不住记不住"
description: ""
categories: [ "programming" ]
tags: [ "regex" ]
---


## 速测


<style>
    .container {
        /*max-width: 600px;*/
       /* margin: 0 auto;*/
    }
    .input-group {
        margin-bottom: 15px;
    }
    label {
        display: block;
        user-select: none;
        margin-bottom: 5px;
        font-weight: bold;
    }
    input[type="text"] {
        line-height: 1.5;
        font-family: monospace;
        color: var(--primary);
        width: 100%;
        padding: 8px;
        box-sizing: border-box;
        border: 1px solid var(--border);
        border-radius: var(--radius);
    }
    #highlightedText {
        line-height: 1.5;
        font-family: monospace;
    }
    #output {
        display: none;
    }
    .modifiers {
        margin-bottom: 0px;
    }
    .modifiers label {
        display: inline-block;
        margin-right: 10px;
    }
    .result {
        margin-top: 0px;
        padding: 10px;
        background-color: var(--code-bg);
        border: 1px solid var(--border);
        border-radius: var(--radius);
    }
    .highlight-0 {
        padding: 2px;
        border-radius: 3px;
    }
    .highlight-1 { padding: 2px; border-radius: 4px; background-color: #88c0d088; }
    .highlight-2 { padding: 2px; border-radius: 4px; background-color: #5e81ac88; }
    .highlight-3 { padding: 2px; border-radius: 4px; background-color: #a3be8c88; }
    .highlight-4 { padding: 2px; border-radius: 4px; background-color: #ebcb8b88; }
    .highlight-5 { padding: 2px; border-radius: 4px; background-color: #d0877088; }
</style>


<div class="container">
    <div class="input-group">
        <label for="regex">正则表达式</label>
        <input type="text" id="regex" value="[0-9]+">
    </div>
    <div class="input-group">
        <label for="testString">测试字符串</label>
        <input type="text" id="testString" value="123abc456def789GHI">
    </div>
    <div class="input-group modifiers">
        <label><input type="checkbox" name="modifier" value="i">忽略大小写 (i)</label>
        <label><input type="checkbox" name="modifier" value="g" checked>全局匹配 (g)</label>
    </div>
    <div class="result" id="result">
        <div id="highlightedText"></div>
        <p id="output"></p>
    </div>
</div>


<script>
    // 获取 DOM 元素
    const regexInput = document.getElementById('regex');
    const testStringInput = document.getElementById('testString');
    const modifierCheckboxes = document.querySelectorAll('input[name="modifier"]');
    const outputElement = document.getElementById('output');
    const highlightedTextElement = document.getElementById('highlightedText');
    // 监听输入框和复选框的变化
    regexInput.addEventListener('input', updateResult);
    testStringInput.addEventListener('input', updateResult);
    modifierCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', updateResult);
    });
    // 更新结果的函数
    function updateResult() {
        const regexValue = regexInput.value;
        const testString = testStringInput.value;
        // 获取选中的修饰符
        const modifiers = Array.from(modifierCheckboxes)
            .filter(checkbox => checkbox.checked)
            .map(checkbox => checkbox.value)
            .join('');
        try {
            const regex = new RegExp(regexValue, modifiers);
            const matches = testString.match(regex);
            // 显示匹配结果
            if (matches) {
                outputElement.innerHTML = `匹配成功：<br>${matches.join('<br>')}`;
            } else {
                outputElement.innerHTML = '没有找到匹配项';
            }
            // 高亮显示匹配的文本
            if (regexValue) {
                let highlightedText = testString;
                let colorIndex = 0; // 用于切换颜色
                const colors = ['highlight-1', 'highlight-2', 'highlight-3', 'highlight-4', 'highlight-5'];
                // 使用正则表达式替换匹配项
                highlightedText = highlightedText.replace(regex, match => {
                    const colorClass = colors[colorIndex % colors.length]; // 循环使用颜色
                    colorIndex++;
                    return `<span class="highlight-0 ${colorClass}">${match}</span>`;
                });
                highlightedTextElement.innerHTML = highlightedText;
            } else {
                highlightedTextElement.innerHTML = testString; // 如果没有正则表达式，直接显示原文本
            }
        } catch (e) {
            outputElement.innerHTML = `正则表达式错误：${e.message}`;
            highlightedTextElement.innerHTML = testString; // 显示原文本
        }
    }
    // 初始化时调用一次
    updateResult();
</script>




## 速查

<div class="table-container">

|锚点             |                                       |           |                                           |
|:----------------|:--------------------------------------|:----------|:------------------------------------------|
|`^`              |匹配字符串或行的开头                   |`^\w+`     |`an` answer or a question                  |
|`$`              |匹配字符串或行的开头                   |`\w+$`     |an answer or a `question`                  |
|`\b`             |匹配单词的开头或末尾                   |`n\b`      |a`n` answer or a questio`n`                |
|`\B`             |匹配不在单词的开头或末尾的位置         |`n\B`      |an a`n`swer or a question                  |
|**字符类**       |                                       |           |                                           |
|`[abc]`          |匹配集合中的任意字符                   |`b[eo]r`   |bar `ber` bir `bor` bur                    |
|`[^abc]`         |匹配不在集合中的任意字符               |`b[^eo]r`  |`bar` ber `bir` bor `bur`                  |
|`[a-z]`          |匹配两个字符之间的任意字符             |`[e-i]`    |abcd `e` `f` `g` `h` `i` jklmnopqrstuvwxyz |
|`.`              |匹配除换行符之外的任意字符             |`.`        |`h` `i` `0` `1` `2` `_` `-` `!` `?`        |
|`\w`             |匹配字母、数字或下划线                 |`\w`       |`h` `i` `0` `1` `2` `_` -!?                |
|`\W`             |匹配除字母、数字和下划线之外的任意字符 |`\W`       |hi012_ `-` `!` `?`                         |
|`\d`             |匹配所有数字                           |`\d`       |+`1`-(`4` `4` `4`)-`2` `2` `2`             |
|`\D`             |匹配除数字外的任意字符                 |`\D`       |`+`1`-` `(`444`)` `-`222                   |
|`\s`             |匹配任意空白字符                       |`\s`       |one` `two                                  |
|`\S`             |匹配除空白字符以外的任意字符           |`\S`       |`o` `n` `e`  `t` `w` `o`                   |
|**量词与分支**   |                                       |           |                                           |
|`+`              |匹配 1 次或多次                        |`be+p`     |bp `bep` `beep` `beeep`                    |
|`*`              |匹配 0 次或多次                        |`be*p`     |`bp` `bep` `beep` `beeep`                  |
|`?`              |匹配 0 次或 1 次                       |`colou?r`  |`color`, `colour`                          |
|`{n}`            |匹配刚好 n 次                          |`be{1}p`   |bp `bep` beep beeep                        |
|`{n,}`           |匹配至少 n 次                          |`be{1,}p`  |bp `bep` `beep` `beeep`                    |
|`{n,m}`          |匹配 n 到 m 次                         |`be{1,2}p` |bp `bep` `beep` beeep                      |
|`a\|b`           |匹配 a 或 b                            |`(c\|r)at` |fat, `cat`, `rat`                          |
|**组和引用**     |                                       |           |                                           |
|`(abc)`          |将 abc 作为一个整体（组）进行匹配      |`(ha)+`    |`hahaha` `ha`h `haha`                      |
|`\1`             |引用第一个组（第一个括号中的内容）     |`(\w)a\1`  |`hah` haa `dad`                            |
|`(?:abc)`        |创建无法引用的分组，abc 无法被 \1 引用 |`(?:ha)+`  |`hahaha` `ha`h `haha`                      |
|**零宽断言**     |                                       |           |                                           |
|`(?=abc)`        |正向先行断言，匹配后面紧跟 abc 的位置  |`\d(?=nd)` |1st `2`nd 3pc                              |
|`(?!abc)`        |负向先行断言，匹配后面不紧跟 abc 的位置|`\d(?!nd)` |`1`st 2nd `3`pc                            |
|`(?<=abc)`       |正向后行断言，匹配前面紧跟 abc 的位置  |`(?<=%)\d` |#1 $2 %`3`                                 |
|`(?<!abc)`       |负向后行断言，匹配前面不紧跟 abc 的位置|`(?<!%)\d` |#`1` $`2` %3                                 |

</div>


### 零宽断言

**零宽**：括号内的字符只用于匹配位置，不占用字符，所以被称为"零宽"，类似 `^` 和 `$` 锚定开头和末尾

**先行**：类似 `abc$`，匹配在前，锚点在后

**后行**：类似 `^abc`，锚点在前，匹配在后

**正向**：匹配括号中的表达式

**负向**：不匹配括号中的表达式


### 标志

flag 不写在正则表达式里，位于表达式之外，格式：`/pattern/flags`

`i`：不区分大小写（ignore）

`g`：全局匹配（global）

`m`：多行匹配（multi line）


### 常用正则表达式

<div class="table-container">

|                 |                                       |                                                      |
|:----------------|:--------------------------------------|:-----------------------------------------------------|
|ipv4 地址        |`(\d{1,3}\.){3}(\d{1,3})`        |64 bytes from `110.242.68.66`: icmp\_seq=2 ttl=48 time=41.6 ms|

</div>


### 参考资料

[RegexLearn](https://regexlearn.com/zh-cn)
