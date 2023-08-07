---
title: "STM32 位带操作"
date: "2022-07-11"
summary: "Note"
description: ""
categories: [ "stm32" ]
tags: [ "stm32" ]
math: false
---

类似于51单片机中 `sbit LED = P0^1;` 直接操作 `LED` 变量就可以控制 `P0_1` 端口了。

STM32 中是通过对处在 `位带区` 的寄存器的对应位映射到 `别名区` ，再通过操作 `别名区` 来控制对应寄存器的位。

STM32 是32位系统总线，所以位带区的一个位对应别名区会膨胀为32位，即四个字节。

## 位带区

外设位带区的地址为：`0X40000000 ~ 0X40100000`

`SRAM` 的位带区的地址为：`0X20000000 ~ X20100000`

## 位带别名区地址

对于片上外设位带区的某个比特，记它所在字节的地址为 `A`，位序号为 `n∈[0,7]`，

则该比特在别名区的地址为：

```c
AliasAddr = 0x42000000 + (A - 0x40000000)*8*4 + n*4
```

- `0x42000000`：别名区起始地址
- `(A - 0x40000000)`：外设地址相对基地址偏移多少个字节
- `(A - 0x40000000)*8`：偏移的字节总共有多少位，所以乘 8
- `(A - 0x40000000)*8*4`：每一位膨胀为 32 位（四个字节），所以乘 4
- `n*4`：所在字节上的第 n 位膨胀为 32 位，所以乘 4

> 操作别名区只对 LSB 有效，即第 0 位

同样对于 `SRAM` 位带区的某个比特在别名区的地址为：

```c
AliasAddr = 0x22000000 + (A - 0x20000000)*8*4 + n*4
```

## 统一公式

```c
#define BITBAND(addr, bitnum) ((addr & 0xF0000000) + 0x02000000 + ((addr & 0x000FFFFF)<<5) + (bitnum<<2))
```

最后我们就可以通过指针的形式操作这些位带别名区地址，最终实现位带区的比特位操作。

```c
// 把一个地址转换成一个指针
#define MEM_ADDR(addr) *((volatile unsigned long *)(addr))

// 把位带别名区地址转换成指针
#define BIT_ADDR(addr, bitnum) MEM_ADDR(BITBAND(addr, bitnum))
```

## GPIO 位带操作

```c
#define BITBAND(addr, bitnum) ((addr & 0xF0000000) + 0x02000000 + ((addr & 0x000FFFFF)<<5) + (bitnum<<2))
#define MEM_ADDR(addr) *((volatile unsigned long *)(addr))
#define BIT_ADDR(addr, bitnum) MEM_ADDR(BITBAND(addr, bitnum))

// GPIOA ODR 寄存器地址映射
#define GPIOA_ODR_Addr (GPIOA_BASE+0x0C)

// 单独操作 GPIO 的某一个 IO 口，n(0,1,2...16),n 表示具体是哪一个 IO 口
#define PAout(n) BIT_ADDR(GPIOA_ODR_Addr,n)

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