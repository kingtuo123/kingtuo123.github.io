---
title: "C 可变参数"
date: "2024-01-01"
summary: "可变参数函数是一种可以接受不定数量和类型的参数的函数"
description: ""
categories: [ "programming" ]
tags: [ "c" ]
---

## man stdarg

```c
#include <stdarg.h>

/* 允许访问可变参数，last 是函数的第一个参数，用于确定参数在栈中的地址 */
void va_start(va_list ap, last);
/* 访问下一个可变参数 */
type va_arg(va_list ap, type);
/* 结束可变参数的遍历 */
void va_end(va_list ap);
```

## 示例

```c
#include <stdio.h>
#include <stdarg.h>

int sum(int count, ...) {
    int total = 0;
    va_list args;

    va_start(args, count);

    for (int i = 0; i < count; i++) {
        int tmp = va_arg(args, int);
        printf("#%d: %d\n", i, tmp);
        total += tmp;
    }

    va_end(args);

    return total;
}

int main() {
    printf("1 + 2 + 3 = %d\n", sum(3, 1, 2, 3));
    return 0;
}
```

输出：

```text
#0: 1
#1: 2
#2: 3
1 + 2 + 3 = 6
```
