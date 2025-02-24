---
title: "正则表达式"
date: "2025-02-24"
summary: "记不住记不住"
description: ""
categories: [ "programming" ]
tags: [ "regex" ]
---




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




## 元字符

未完待续
