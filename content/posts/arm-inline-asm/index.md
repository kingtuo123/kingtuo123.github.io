---
title: "ARM 内联汇编"
date: "2023-08-19"
description: ""
summary: "arm inline assembly"
categories: [ "embedded" ]
tags: [ "arm", "asm" ]
---

参考文章
- [ARM GCC Inline Assembler Cookbook](http://www.ethernut.de/en/documents/arm-inline-asm.html)
- [Writing Arm assembly code](https://developer.arm.com/documentation/102694/0100/Introduction)
- [ARM内联汇编](https://finsenty54.github.io/2020/09/24/ARM%E5%86%85%E8%81%94%E6%B1%87%E7%BC%96/)
- [[ARM]内联汇编](https://blog.csdn.net/myprogram_player/article/details/121372941)
- [从0学ARM-内联汇编、混合汇编、ATPCS规则](https://zhuanlan.zhihu.com/p/338563574)
- [ARM中C语言和汇编语言的混合编程](https://blog.csdn.net/andrewgithub/article/details/79164865)
- [内联汇编语句](https://www.ibm.com/docs/zh/openxl-c-and-cpp-aix/17.1.0?topic=features-inline-assembly-statements)
- [移动端arm cpu优化学习笔记第4弹--内联汇编入门](https://zhuanlan.zhihu.com/p/143328317)
- **[Linux Kernel 源码学习必备知识之：GCC 内联汇编](https://zhuanlan.zhihu.com/p/606376595)** **\<-推荐看这篇**


## ARM GCC

格式：

```
asm qualifiers (
    "asm code    \n\t" 
    : output operand list 
    : input operand list 
    : clobber list
);
```

### qualifiers - 修饰符

有三种，也可以不加：`volatile`，`inline`，`goto`
    

### asm code - 汇编代码

使用双引号包含，多条指令用 `\n\t`分隔，只有单条指令可以不加分隔符，如下：

```
"mov lr, %1    \n\t"
```


### operand list - 操作数列表


有输入和输出操作数，多个操作数使用逗号分隔，每个操作数都有下面格式：

```
[operand name] "[modifier]constraint" (C expression)
```

- operand name：操作数名称

- modifier：修改符，只用于输出操作数
  - `+` 可读可写
  - `=` 只写
  - `&` 表示该输出操作数不能使用输入部分使用过的寄存器，只能用 `+&` 或 `=&` 的方式使用

- constraint：限定符，用于定义变量的存放位置
  - `r` 表示使用任何可用的寄存器
  - `m` 表示使用变量的内存地址
  - `i` 表示使用立即数

- C expression：C 表达式
  - 输出操作数通常是一个变量
  - 输入操作数可以是变量、常量

### clobber list 

使用双引号包含，多个参数使用逗号分隔：

```
"r1", "r2", ...
```

汇编代码执行后会破坏一些内存或寄存器资源，通过此项通知编译器，可能造成寄存器或内存数据的破坏，这样 gcc 就知道哪些寄存器或内存需要提前保护起来。

- 常用的参数：
  - `r1` 表示内联汇编代码修改了通用寄存器 `r1`，不能用大写 `R`
  - `cc` 表示内联汇编代码修改了标志寄存器
  - `memory` 表示汇编代码修改了内存，输入或输出操作数（修改了操作数所在的内存）


特殊用法，参考 [内存屏障](https://blog.csdn.net/KISSMonX/article/details/9105823)：

```c
asm volatile("" ::: "memory");
```

memory 强制 gcc 编译器假设 RAM 所有内存单元均被汇编指令修改，这样 cpu 中的 registers 和 cache 中已缓存的内存单元中的数据将作废。cpu 将不得不在需要的时候重新读取内存中的数据。这就阻止了 cpu 又将 registers, cache 中的数据用于去优化指令，而避免去访问内存。


### 在汇编代码中引用操作数

方法一，`%[操作数名称]`：

```c
int res = 0;
// result，input_i，input_j 就是操作数名称
__asm ("ADD %[result], %[input_i], %[input_j]"
    : [result] "=r" (res)
    : [input_i] "r" (i), [input_j] "r" (j)
);
```

方法二，`%操作数序号`：

```c
int res = 0;
// 按变量的顺序，%0 对应 res，%1 对应 i，%2 对应 j
__asm ("ADD %0, %1, %2"
    : "=r" (res)
    : "r" (i), "r" (j)
);
```

### 示例程序

```c
#include <stdio.h>

int add(int i, int j)
{
  int res = 0;
  __asm ("ADD %[result], %[input_i], %[input_j]"
    : [result] "=r" (res)
    : [input_i] "r" (i), [input_j] "r" (j)
  );
  return res;
}

int main(void)
{
  int a = 1;
  int b = 2;
  int c = 0;

  c = add(a,b);

  printf("Result of %d + %d = %d\n", a, b, c);
}
```

## Arm Compiler 6（armclang）


同上面的格式，参考：[Writing inline assembly code](https://developer.arm.com/documentation/100748/0620/Using-Assembly-and-Intrinsics-in-C-or-C---Code/Writing-inline-assembly-code)

## Arm Compiler 5（armcc）


参考：[Using inline assembly to improve code efficiency](https://developer.arm.com/documentation/102694/0100/Introduction)

格式：

```
__asm
    {
        ...
        instruction
        ...
    }
```

示例：

```c
#include  <stdio.h>

int add_inline(int r5, int r6)
{
    int res = 0;
    __asm
    {
        ADD res, r5, r6
    }
    return res;
}

int main(void)
{
    int a = 12;
    int b = 2;
    int c = 0;

    c = add_inline(a,b);

    printf("Result of %d + %d = %d\n", a, b, c);
}
```
