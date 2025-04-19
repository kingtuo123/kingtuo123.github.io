---
title: "Markdown 语法"
date: "2021-05-01"
description: ""
categories: [ "web" ]
tags: [ "markdown" ]
---




## 标题

```markdown
# 这是一级标题
## 这是二级标题
### 这是三级标题
#### 这是四级标题
##### 这是五级标题
###### 这是六级标题
```

## 字体样式

```markdown
*倾斜的文字*
**加粗的文字**
***斜体加粗的文字***
~~加删除线的文字~~
```

## 引用

```markdown
> 这是引用的内容
>
> 这是引用的内容
```

换行则使用单个 `>`


## 分割线

```markdown
---
----
***
*****
```

三个或者三个以上的 `-` 或者 `*` 都可以


## 图片

```markdown
![](url)
![图片alt](图片url "图片title")
```

指定图片大小，使用 html：

```html
<div align="center">
    <img src="1.png" style="max-height:180px"></img>
</div>
```

超链接图片：

```html
<div align="center">
    <a href="1.jpg" target="_blank">
        <img src="1.jpg" style="max-height:980px"></img>
    </a>
</div>
```


## 超链接

```markdown
[name](url)
[超链接名](超链接url "超链接title")
```

## 列表

```markdown
- 无序列表
+ 无序列表
* 无序列表
```

```markdown
1. 有序列表
2. 有序列表
3. 有序列表
```

```markdown
- 多级列表
  - 二级无序列表内容
  - 二级无序列表内容
  - 二级无序列表内容
```


## 表格

```markdown
|align left|align center|align right|
|:---------|:----------:|----------:|
|content   |content     |content    |
|content   |content     |content    |
```


## 代码


```text
​```bash
  代码...
  代码...
  代码...
​```
```

## 左右分隔代码块

<div align="left">
    <img src="split.png" style="max-height:425px"></img>
</div>


<div align="left" style="width:100%;display:flex;flex-flow:row wrap;">
<div align="left" style="max-width:400px;flex:1;padding:3px;">

这是左边：

```c
/* This is the foobar value */
#define FOOBAR 42
```

</div>
<div align="left" style="max-width:400px;flex:1;padding:3px;">

这是右边：

```c
/* This is the foobar value */
#define FOOBAR 42
```

</div>
</div>


## 任务列表

```markdown
- [x] Write the press release
- [ ] Update the website
- [ ] Contact the media
```

## 定义列表

```markdown
term
: definition
```

## 空格

普通空格 `&nbsp;`：|&nbsp;|

半角空格 `&ensp;`：|&ensp;|

全角空格 `&emsp;`：|&emsp;|
