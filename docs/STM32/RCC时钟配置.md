---
layout: default
title: RCC时钟配置
parent: STM32
nav_order: 8
---


# RCC时钟配置
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

摘自《野火零死角玩转STM32-F429》

## F4系列使用HSE 配置系统时钟

![](https://knote.oss-cn-hangzhou.aliyuncs.com/img/RCC_HSE.png)



```c
void HSE_SetSysClock(uint32_t m, uint32_t n, uint32_t p, uint32_t q)
{
	__IO uint32_t HSEStartUpStatus = 0;

	// 使能 HSE，开启外部晶振，野火 F429 使用 HSE=25M,该函数参数有如下
	// RCC_HSE_OFF:    普通模式关
	// RCC_HSE_ON: 	   普通模式开
	// RCC_HSE_Bypass: 旁路模式，不经过PLL配置，一般用于有源晶振
	RCC_HSEConfig(RCC_HSE_ON);

    
	// 等待 HSE 启动稳定，该函数返回枚举类型SUCCESS和ERROR
	HSEStartUpStatus = RCC_WaitForHSEStartUp();

	if (HSEStartUpStatus == SUCCESS) {
		// 调压器电压输出级别配置为 1，以便在器件为最大频率
		// 工作时使性能和功耗实现平衡
		RCC->APB1ENR |= RCC_APB1ENR_PWREN;
		PWR->CR |= PWR_CR_VOS;
 
		// HCLK = SYSCLK / 1   AHB
		RCC_HCLKConfig(RCC_SYSCLK_Div1);

		// PCLK2 = HCLK / 2    APB2
		RCC_PCLK2Config(RCC_HCLK_Div2);

		// PCLK1 = HCLK / 4    APB1
		RCC_PCLK1Config(RCC_HCLK_Div4);

		// 锁相环配置部分如上图红色线所示
		// 设置 PLL 来源时钟，设置 VCO 分频因子 m，设置 VCO 倍频因子 n，
		// 设置系统时钟分频因子 p，设置 OTG FS,SDIO,RNG 分频因子 q
		RCC_PLLConfig(RCC_PLLSource_HSE, m, n, p, q);
 
		// 使能 PLL
		RCC_PLLCmd(ENABLE);
 
		// 等待 PLL 稳定，函数返回值SET和RESET
		while (RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET) {
		}

		/*-----------------------------------------------------*/
		// 开启 OVER-RIDE 模式，以能达到更高频率
		PWR->CR |= PWR_CR_ODEN;
		while ((PWR->CSR & PWR_CSR_ODRDY) == 0) {
		}
		PWR->CR |= PWR_CR_ODSWEN;
		while ((PWR->CSR & PWR_CSR_ODSWRDY) == 0) {
		}
		// 配置 FLASH 预取指,指令缓存,数据缓存和等待状态
		FLASH->ACR = FLASH_ACR_PRFTEN
		| FLASH_ACR_ICEN
		| FLASH_ACR_DCEN
		| FLASH_ACR_LATENCY_5WS;
 		/*-----------------------------------------------------*/

		// 当 PLL 稳定之后，把 PLL 时钟切换为系统时钟 SYSCLK，对应图中sw处即选择时钟源
		RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);
 
		// 读取时钟切换状态位，确保 PLLCLK 被选为系统时钟
        // 0x00: HSI used as system clock 
		// 0x04: HSE used as system clock 
		// 0x08: PLL used as system clock 
		while (RCC_GetSYSCLKSource() != 0x08) {
		}
	} else {
		// HSE启动出错处理
        
		while (1) {
		}
	}
}
```

函数有 4 个形参 m、n、p、q，具体说明如下：

|形参|形参说明|取值范围|
|:---|:---|:---|
|m| VCO 输入时钟 分频因子 |2~63|
|n |VCO 输出时钟 倍频因子 |192~432|
|p |PLLCLK 时钟分频因子 |2/4/6/8|
|q |OTG FS,SDIO,RNG 时钟分频因子 |4~15|

SYSCLK=PLLCLK=HSE/m*n/p，HSE_SetSysClock(25, 360, 2, 7) 把系统时钟设置为 180M，HSE_SetSysClock(25, 432, 2, 9)把系统时钟设置为 216M。



## F4系列使用HSI 配置系统时钟

![](https://knote.oss-cn-hangzhou.aliyuncs.com/img/RCC_HSI.png)

同上区别不大

```c
void HSI_SetSysClock(uint32_t m, uint32_t n, uint32_t p, uint32_t q)
{
	__IO uint32_t HSIStartUpStatus = 0;

	// 把 RCC 外设初始化成复位状态
	RCC_DeInit();

	//使能 HSI, HSI=16M
	RCC_HSICmd(ENABLE);

	// 等待 HSI 就绪
	HSIStartUpStatus = RCC->CR & RCC_CR_HSIRDY;

	// 只有 HSI 就绪之后则继续往下执行
	if (HSIStartUpStatus == RCC_CR_HSIRDY) {
		// 调压器电压输出级别配置为 1，以便在器件为最大频率
		// 工作时使性能和功耗实现平衡
		RCC->APB1ENR |= RCC_APB1ENR_PWREN;
		PWR->CR |= PWR_CR_VOS;

		// HCLK = SYSCLK / 1
		RCC_HCLKConfig(RCC_SYSCLK_Div1);

		// PCLK2 = HCLK / 2
		RCC_PCLK2Config(RCC_HCLK_Div2);

		// PCLK1 = HCLK / 4
		RCC_PCLK1Config(RCC_HCLK_Div4);

		// 如果要超频就得在这里下手啦
		// 设置 PLL 来源时钟，设置 VCO 分频因子 m，设置 VCO 倍频因子 n，
		// 设置系统时钟分频因子 p，设置 OTG FS,SDIO,RNG 分频因子 q
		RCC_PLLConfig(RCC_PLLSource_HSI, m, n, p, q);

		// 使能 PLL
		RCC_PLLCmd(ENABLE);

		// 等待 PLL 稳定
		while (RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET) {
		}

		/*-----------------------------------------------------*/
		//开启 OVER-RIDE 模式，以能达到更高频率
		PWR->CR |= PWR_CR_ODEN;
		while ((PWR->CSR & PWR_CSR_ODRDY) == 0) {
		}
		PWR->CR |= PWR_CR_ODSWEN;
		while ((PWR->CSR & PWR_CSR_ODSWRDY) == 0) {
		}
		// 配置 FLASH 预取指,指令缓存,数据缓存和等待状态
		FLASH->ACR = FLASH_ACR_PRFTEN
		| FLASH_ACR_ICEN
		|FLASH_ACR_DCEN
		|FLASH_ACR_LATENCY_5WS;
		/*-----------------------------------------------------*/

		// 当 PLL 稳定之后，把 PLL 时钟切换为系统时钟 SYSCLK
		RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);

		// 读取时钟切换状态位，确保 PLLCLK 被选为系统时钟
		while (RCC_GetSYSCLKSource() != 0x08) {
		}
	} else {
		// HSI 启动出错处理
		while (1) {
		}
	}
}
```

## F1系列使用HSE 配置系统时钟

![](https://knote.oss-cn-hangzhou.aliyuncs.com/img/RCC_F103_HSE.png)

```c
void HSE_SetSysClock(uint32_t pllmul){
	__IO uint32_t StartUpCounter = 0, HSEStartUpStatus = 0;
 
	// 把 RCC 外设初始化成复位状态
	RCC_DeInit();

	//使能 HSE，开启外部晶振，野火 STM32F103 系列开发板用的是 8M
	RCC_HSEConfig(RCC_HSE_ON);

	// 等待 HSE 启动稳定
	HSEStartUpStatus = RCC_WaitForHSEStartUp();

	// 只有 HSE 稳定之后则继续往下执行
	if (HSEStartUpStatus == SUCCESS) {
		//------------------------------------------------------------//
		// 这两句是操作 FLASH 闪存用到的，如果不操作 FLASH，这两个注释掉也没影响
		// 使能 FLASH 预存取缓冲区
		FLASH_PrefetchBufferCmd(FLASH_PrefetchBuffer_Enable);

		// SYSCLK 周期与闪存访问时间的比例设置，这里统一设置成 2
		// 设置成 2 的时候，SYSCLK 低于 48M 也可以工作，如果设置成 0 或者 1 的时候，
		// 如果配置的 SYSCLK 超出了范围的话，则会进入硬件错误，程序就死了
		// 0：0 < SYSCLK <= 24M
		// 1：24< SYSCLK <= 48M
		// 2：48< SYSCLK <= 72M
		FLASH_SetLatency(FLASH_Latency_2);
		//------------------------------------------------------------//

		// AHB 预分频因子设置为 1 分频，HCLK = SYSCLK
		RCC_HCLKConfig(RCC_SYSCLK_Div1);

		// APB2 预分频因子设置为 1 分频，PCLK2 = HCLK
		RCC_PCLK2Config(RCC_HCLK_Div1);

		// APB1 预分频因子设置为 1 分频，PCLK1 = HCLK/2
		RCC_PCLK1Config(RCC_HCLK_Div2);

		//-----------------设置各种频率主要就是在这里设置-------------------//
		// 设置 PLL 时钟来源为 HSE，设置 PLL 倍频因子
		// PLLCLK = 8MHz * pllmul
		RCC_PLLConfig(RCC_PLLSource_HSE_Div1, pllmul);
		//-------------------------------------------------------------//
 
		// 开启 PLL
		RCC_PLLCmd(ENABLE);

		// 等待 PLL 稳定
		while (RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET) {
		}

		// 当 PLL 稳定之后，把 PLL 时钟切换为系统时钟 SYSCLK
		RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);

		// 读取时钟切换状态位，确保 PLLCLK 被选为系统时钟
		while (RCC_GetSYSCLKSource() != 0x08) {
		}
	} else {
		// 如果 HSE 开启失败，那么程序就会来到这里，用户可在这里添加出错的代码处理
		// 当 HSE 开启失败或者故障的时候，单片机会自动把 HSI 设置为系统时钟，
		// HSI 是内部的高速时钟，8MHZ
		while (1) {
		}
	}
}
```

函数调用举例：

HSE_SetSysClock(RCC_PLLMul_9); 则设置系统时钟为：8MHZ * 9 = 72MHZ

HSE_SetSysClock(RCC_PLLMul_16); 则设置系统时钟为：8MHZ * 16 = 128MHZ

## F1系列使用HSI配置系统时钟

![](https://knote.oss-cn-hangzhou.aliyuncs.com/img/RCC_F103_HSI.png)

```c
void HSI_SetSysClock(uint32_t pllmul){
	__IO uint32_t HSIStartUpStatus = 0;

	// 把 RCC 外设初始化成复位状态
	RCC_DeInit();

	//使能 HSI
	RCC_HSICmd(ENABLE);

	// 等待 HSI 就绪
	HSIStartUpStatus = RCC->CR & RCC_CR_HSIRDY;

	// 只有 HSI 就绪之后则继续往下执行
	if (HSIStartUpStatus == RCC_CR_HSIRDY) {
		//-------------------------------------------------------------//
		// 这两句是操作 FLASH 闪存用到的，如果不操作 FLASH，这两个注释掉也没影响
		// 使能 FLASH 预存取缓冲区
		FLASH_PrefetchBufferCmd(FLASH_PrefetchBuffer_Enable);

		// SYSCLK 周期与闪存访问时间的比例设置，这里统一设置成 2
		// 设置成 2 的时候，SYSCLK 低于 48M 也可以工作，如果设置成 0 或者 1 的时候，
		// 如果配置的 SYSCLK 超出了范围的话，则会进入硬件错误，程序就死了
		// 0：0 < SYSCLK <= 24M
		// 1：24< SYSCLK <= 48M
		// 2：48< SYSCLK <= 72M
		FLASH_SetLatency(FLASH_Latency_2);
		//------------------------------------------------------------//

		// AHB 预分频因子设置为 1 分频，HCLK = SYSCLK
		RCC_HCLKConfig(RCC_SYSCLK_Div1);

		// APB2 预分频因子设置为 1 分频，PCLK2 = HCLK
		RCC_PCLK2Config(RCC_HCLK_Div1);

		// APB1 预分频因子设置为 1 分频，PCLK1 = HCLK/2
		RCC_PCLK1Config(RCC_HCLK_Div2);

		//-----------设置各种频率主要就是在这里设置-------------------//
		// 设置 PLL 时钟来源为 HSE，设置 PLL 倍频因子
		// PLLCLK = 4MHz * pllmul
		RCC_PLLConfig(RCC_PLLSource_HSI_Div2, pllmul);
		//-------------------------------------------------------//

		// 开启 PLL
		RCC_PLLCmd(ENABLE);

		// 等待 PLL 稳定
		while (RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET) {
		}

		// 当 PLL 稳定之后，把 PLL 时钟切换为系统时钟 SYSCLK
		RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);

		// 读取时钟切换状态位，确保 PLLCLK 被选为系统时钟
		while (RCC_GetSYSCLKSource() != 0x08) {
		}
	} else {
		// 如果 HSI 开启失败，那么程序就会来到这里，用户可在这里添加出错的代码处理
		// 当 HSE 开启失败或者故障的时候，单片机会自动把 HSI 设置为系统时钟，
		// HSI 是内部的高速时钟，8MHZ
		while (1) {
		}
	}
}
```

从时钟框图可以看出，HSI 必须 2 分频之后才能作为 PLL 的时钟来源，所以使用 HSI 时，最大的系统时钟 SYSCLK 只能是 HSI/2\*16=4\*16=64MHZ

函数调用举例：HSI_SetSysClock(RCC_PLLMul_9); 则设置系统时钟为：4MHZ * 9 = 36MHZ。
