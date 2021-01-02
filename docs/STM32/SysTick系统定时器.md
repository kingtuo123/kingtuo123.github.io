---
layout: default
title: SysTick系统定时器
parent: STM32
nav_order: 12
---


# SysTick系统定时器
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## SysTick 简介

SysTick—系统定时器是属于 CM4 内核中的一个外设，内嵌在 NVIC 中。系统定时器是一个 24bit 的向下递减的计数器，计数器每计数一次的时间为 1/SYSCLK，一般我们设置系统时钟 SYSCLK 等于 180M。当重装载数值寄存器的值递减到 0 的时候，系统定时器就产生一次中断，以此循环往复。

## SysTick 寄存器介绍

SysTick—系统定时有 4 个寄存器，简要介绍如下。在使用 SysTick 产生定时的时候，只需要配置前三个寄存器，最后一个校准寄存器不需要使用。

|寄存器名称| 寄存器描述 |
|:--:|:--:|
|CTRL SysTick| 控制及状态寄存器|
|LOAD SysTick |重装载数值寄存器|
|VAL SysTick |当前数值寄存器|
|CALIB SysTick |校准数值寄存器|

CTRL控制及状态寄存器

|位段 |名称 |类型| 复位值| 描述 |
|:--:|:--:|:--:|:--:|:--|
|16 |COUNTFLAG |R/W |0 |如果在上次读取本寄存器后， SysTick 已经计到了 0，则该位为 1|
|2 |CLKSOURCE |R/W |0 |时钟源选择位，0=AHB/8，1=处理器时钟 AHB|
|1| TICKINT |R/W |0 |1=SysTick 倒数计数到 0 时产生 SysTick 异常请求，0=数到 0 时 无动作。也可以通 过读取COUNTFLAG 标志位来确定计数器是否递减到0 |
|0| ENABLE| R/W |0 |SysTick 定时器的使能位|

LOAD重装载数值寄存器

|位段| 名称| 类型 |复位值 |描述|
|:--:|:--:|:--:|:--:|:--|
|23:0| RELOAD| R/W| 0 |当倒数计数至零时，将被重装载的值|

VAL当前数值寄存器

|位段| 名称| 类型 |复位值 |描述|
|:--:|:--:|:--:|:--:|:--|
|23:0| CURRENT| R/W |0 |读取时返回当前倒计数的值，写它则使之清|

## SysTick初始化函数

```c
void SysTick_Init(void)
{
	/* SystemFrequency / 1000    1ms中断一次
	 * SystemFrequency / 100000	 10us中断一次
	 * SystemFrequency / 1000000 1us中断一次
	 */
	if (SysTick_Config(SystemCoreClock / 100000))
	{ 
		/* Capture error */ 
		while (1);
	}
}
```

SysTick_Config函数原型如下,形参 ticks 用来设置重装载寄存器的值,最大不能超过重装载寄存器的值2^24

```c
__STATIC_INLINE uint32_t SysTick_Config(uint32_t ticks)
{
	// 不可能的重装载值，超出范围
	if ((ticks - 1UL) > SysTick_LOAD_RELOAD_Msk) {
		return (1UL);
	}

	// 设置重装载寄存器
	SysTick->LOAD = (uint32_t)(ticks - 1UL);
 
	// 设置中断优先级
	NVIC_SetPriority (SysTick_IRQn, (1UL << __NVIC_PRIO_BITS) - 1UL);

	// 设置当前数值寄存器
	SysTick->VAL = 0UL;

	// 设置系统定时器的时钟源为 AHBCLK=180M
	// 使能系统定时器中断
	// 使能定时器
	SysTick->CTRL = SysTick_CTRL_CLKSOURCE_Msk | SysTick_CTRL_ENABLE_Msk;
	return (0UL);
}
```

## SysTick中断时间的计算

1s = 1000ms

1ms = 1000 us

1us = 1000 ns

当系统时钟为180MHz时，时钟一个周期时间是 1/180M = (1/180)x10^-6 = (1/180) us，180个时钟周期就是1us

延时1s需要180x10^6个周期，即ticks = 180000000

延时1ms需要180x10^3个周期，即ticks = 180000

以此类推



## SysTick定时函数

```c
/**
  * @brief   us延时程序,10us为一个单位
  * @param  
  *		@arg nTime: Delay_us( 1 ) 则实现的延时为 1 * 10us = 10us
  * @retval  无
  */
void Delay_us(__IO u32 nTime)
{ 
	TimingDelay = nTime;	

	while(TimingDelay != 0);
}
```

## SysTick 中断服务函数
```c
void SysTick_Handler(void)
{
	TimingDelay_Decrement();
}


void TimingDelay_Decrement(void)
{
	if (TimingDelay != 0x00)
	{ 
		TimingDelay--;
	}
}
```
最后在主函数里调用Delay_us()函数即可延时
