---
title: "CM3 位带操作"
date: "2025-04-20"
summary: "《ARM Cortex-M3 / M4 权威指南》- 阅读笔记"
description: ""
categories: [ "embedded" ]
tags: [ "arm", "stm32"]
---





## 位带区

<div class="table-container">

||位带区范围（1MB）|别名区范围（32MB）|
|:--|:--|:--|
|**SRAM**|`0x20000000` ~ `0x200FFFFF`|`0x22000000` ~ `0x23FFFFFF`|
|**外设**|`0x40000000` ~ `0x400FFFFF`|`0x42000000` ~ `0x43FFFFFF`|

</div>





## 地址映射

<div class="table-container">

|位带区|别名区|
|:--|:--|
|`0x20000000 bit[0]`|`0x22000000 bit[0]`|
|`0x20000000 bit[1]`|`0x22000004 bit[0]`|
|`0x20000000 bit[2]`|`0x22000008 bit[0]`|
|**...**||
|`0x200FFFFC bit[31]`|`0x23FFFFC bit[0]`|

</div>

位带区每一个 `bit` 位对应别名区一个 32 位字的 `bit[0]` 位，该字的 `bit[1-31]` 为无效位





## 映射公式

```c
((addr & 0xF0000000) + 0x02000000 + ((addr & 0x000FFFFF)<<5) + (bitnum<<2))
```

<div class="table-container no-thead colfirst-200">

|                         |                                                 |
|:------------------------|:------------------------------------------------|
|`addr & 0xF0000000`      |区分 SRAM 和外设地址，`0x20000000` `0x40000000`  |
|`+ 0x02000000`           |别名区相对位带区的偏移地址                       |
|`(addr & 0x000FFFFF)<<5` |偏移字节数 * 8 位 * 4 字节（左移 5 位即乘上 32）                        |
|`bitnum<<2`              |位编号 * 4 字节                                       |

</div>





## GPIO 位带操作

```c
// 别名区地址
#define BIT_BAND(addr, bitnum) ((addr & 0xF0000000) + 0x02000000 + ((addr & 0x000FFFFF)<<5) + (bitnum<<2))
// 把地址转换成一个指针后再引用
#define MEM_ADDR(addr) *((volatile unsigned long *)(addr))
// 把别名区地址转换成指针后再引用
#define BIT_ADDR(addr, bitnum) MEM_ADDR(BIT_BAND(addr, bitnum))

// GPIOA ODR 寄存器地址映射
#define GPIOA_ODR_ADDR (GPIOA_BASE+0x0C)

// 单独操作 GPIO 的某一个 IO 口，n(0,1,2...16),n 表示具体是哪一个 IO 口
#define PAout(n) BIT_ADDR(GPIOA_ODR_ADDR,n)

int main(void){
    /* LED 端口初始化 */
    LED_GPIO_Config();
    while(1){
        PAout(10) = 0;	// PA10 = 0,点亮 LED
        SOFT_Delay(0x0FFFFF);
        PAout(10) = 1;	// PA10 = 1,熄灭 LED
        SOFT_Delay(0x0FFFFF);
    }
}
```



## 原子性

**不使用位带：** 若中断程序在 `STR` 指令写回前修改了 `0x20000000 bit[2]` 以外的位，`STR` 会覆盖修改后的数据

```asm
LDR R0, =0x20000000    ; 设置地址
LDR R1, [R0]           ; 读取 32 位数据到 R1
ORR R1, #04            ; 或运算，设置 R1:bit[2] = 1
STR R1, [R0]           ; 写回 32 的数据
```

**使用位带：** 只影响 1 个位，避免了传统的 “读-修改-写” 操作在多线程或中断环境中的竞争条件

```asm
LDR R0, =0x22000008    ; 设置别名区地址
MOV R1, #1             ; 设置 R1 = 1
STR R1, [R0]           ; 将 R1 写入别名区
```
