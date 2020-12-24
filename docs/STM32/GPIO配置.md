---
layout: default
title: GPIO配置
parent: STM32
nav_order: 3
---


# GPIO配置
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# GPIO配置

以F429开发板为例

## 定义GPIO_InitTypeDef类型的结构体

```c
GPIO_InitTypeDef  GPIO_InitStructure;
```
以下是GPIO_InitTypeDef在标准库源码中的定义
```c
typedef struct
{
  uint32_t GPIO_Pin;              
  GPIOMode_TypeDef GPIO_Mode;    
  GPIOSpeed_TypeDef GPIO_Speed;   
  GPIOOType_TypeDef GPIO_OType;   
  GPIOPuPd_TypeDef GPIO_PuPd;     
}GPIO_InitTypeDef;

```

## 开启相关引脚的GPIO外设时钟
```c
RCC_AHB1PeriphClockCmd (RCC_AHB1Periph_GPIOH，ENABLE）;
```

有以下可用外设时钟

```c
#define RCC_AHB1Periph_GPIOA             ((uint32_t)0x00000001)
#define RCC_AHB1Periph_GPIOB             ((uint32_t)0x00000002)
#define RCC_AHB1Periph_GPIOC             ((uint32_t)0x00000004)
#define RCC_AHB1Periph_GPIOD             ((uint32_t)0x00000008)
#define RCC_AHB1Periph_GPIOE             ((uint32_t)0x00000010)
#define RCC_AHB1Periph_GPIOF             ((uint32_t)0x00000020)
#define RCC_AHB1Periph_GPIOG             ((uint32_t)0x00000040)
#define RCC_AHB1Periph_GPIOH             ((uint32_t)0x00000080)
#define RCC_AHB1Periph_GPIOI             ((uint32_t)0x00000100) 
#define RCC_AHB1Periph_GPIOJ             ((uint32_t)0x00000200)
#define RCC_AHB1Periph_GPIOK             ((uint32_t)0x00000400)
#define RCC_AHB1Periph_CRC               ((uint32_t)0x00001000)
#define RCC_AHB1Periph_FLITF             ((uint32_t)0x00008000)
#define RCC_AHB1Periph_SRAM1             ((uint32_t)0x00010000)
#define RCC_AHB1Periph_SRAM2             ((uint32_t)0x00020000)
#define RCC_AHB1Periph_BKPSRAM           ((uint32_t)0x00040000)
#define RCC_AHB1Periph_SRAM3             ((uint32_t)0x00080000)
#define RCC_AHB1Periph_CCMDATARAMEN      ((uint32_t)0x00100000)
#define RCC_AHB1Periph_DMA1              ((uint32_t)0x00200000)
#define RCC_AHB1Periph_DMA2              ((uint32_t)0x00400000)
#define RCC_AHB1Periph_DMA2D             ((uint32_t)0x00800000)
#define RCC_AHB1Periph_ETH_MAC           ((uint32_t)0x02000000)
#define RCC_AHB1Periph_ETH_MAC_Tx        ((uint32_t)0x04000000)
#define RCC_AHB1Periph_ETH_MAC_Rx        ((uint32_t)0x08000000)
#define RCC_AHB1Periph_ETH_MAC_PTP       ((uint32_t)0x10000000)
#define RCC_AHB1Periph_OTG_HS            ((uint32_t)0x20000000)
#define RCC_AHB1Periph_OTG_HS_ULPI       ((uint32_t)0x40000000)
```

## 选择要控制的GPIO引脚
```c
GPIO_InitStructure.GPIO_Pin = GPIO_Pin_10;
```
以下是固件库中定义的引脚
```c
#define GPIO_Pin_0                 ((uint16_t)0x0001)  /* Pin 0 selected */
#define GPIO_Pin_1                 ((uint16_t)0x0002)  /* Pin 1 selected */
#define GPIO_Pin_2                 ((uint16_t)0x0004)  /* Pin 2 selected */
	......
#define GPIO_Pin_14                ((uint16_t)0x4000)  /* Pin 14 selected */
#define GPIO_Pin_15                ((uint16_t)0x8000)  /* Pin 15 selected */
#define GPIO_Pin_All               ((uint16_t)0xFFFF)  /* All pins selected */
```

## 设置引脚为输入或输出
```c
GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;  
```
以下是固件库中定义的可用的模式
```c
typedef enum
{ 
  GPIO_Mode_IN   = 0x00, /*!< GPIO Input Mode */
  GPIO_Mode_OUT  = 0x01, /*!< GPIO Output Mode */
  GPIO_Mode_AF   = 0x02, /*!< GPIO Alternate function Mode */
  GPIO_Mode_AN   = 0x03  /*!< GPIO Analog Mode */
}GPIOMode_TypeDef;
```

## 设置引脚的输出类型

```c
GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
```
以下是可用的输出类型
```c
typedef enum
{ 
  GPIO_OType_PP = 0x00, /*推挽输出*/
  GPIO_OType_OD = 0x01  /*开漏输出*/
}GPIOOType_TypeDef;
```

## 设置引脚上拉或下拉

```c
GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
```
以下为可用的模式
```c
typedef enum
{ 
  GPIO_PuPd_NOPULL = 0x00,	/*浮空*/
  GPIO_PuPd_UP     = 0x01,	/*上拉*/
  GPIO_PuPd_DOWN   = 0x02	/*下拉*/
}GPIOPuPd_TypeDef;
```

## 设置引脚速率

```c
GPIO_InitStructure.GPIO_Speed = GPIO_Speed_2MHz;
```
以下是可用的速率
```c
typedef enum
{ 
  GPIO_Low_Speed     = 0x00, /*!< Low speed    */
  GPIO_Medium_Speed  = 0x01, /*!< Medium speed */
  GPIO_Fast_Speed    = 0x02, /*!< Fast speed   */
  GPIO_High_Speed    = 0x03  /*!< High speed   */
}GPIOSpeed_TypeDef;

/* Add legacy definition */
#define  GPIO_Speed_2MHz    GPIO_Low_Speed    
#define  GPIO_Speed_25MHz   GPIO_Medium_Speed 
#define  GPIO_Speed_50MHz   GPIO_Fast_Speed 
#define  GPIO_Speed_100MHz  GPIO_High_Speed 
```

## 调用库函数初始化GPIO

```
GPIO_Init(GPIOH, &GPIO_InitStructure);	
```

## 操作GPIO端口

首先看下GPIO在固件库中的定义
```c
typedef struct
{
  __IO uint32_t MODER;    /*!< GPIO port mode register,               Address offset: 0x00      */
  __IO uint32_t OTYPER;   /*!< GPIO port output type register,        Address offset: 0x04      */
  __IO uint32_t OSPEEDR;  /*!< GPIO port output speed register,       Address offset: 0x08      */
  __IO uint32_t PUPDR;    /*!< GPIO port pull-up/pull-down register,  Address offset: 0x0C      */
  __IO uint32_t IDR;      /*!< GPIO port input data register,         Address offset: 0x10      */
  __IO uint32_t ODR;      /*!< GPIO port output data register,        Address offset: 0x14      */
  __IO uint16_t BSRRL;    /*!< GPIO port bit set/reset low register,  Address offset: 0x18      */
  __IO uint16_t BSRRH;    /*!< GPIO port bit set/reset high register, Address offset: 0x1A      */
  __IO uint32_t LCKR;     /*!< GPIO port configuration lock register, Address offset: 0x1C      */
  __IO uint32_t AFR[2];   /*!< GPIO alternate function registers,     Address offset: 0x20-0x24 */
} GPIO_TypeDef;
```

可以操作`ODR`或`BSRRL`、`BSRRH`控制引脚高低电平


```c
GPIOH->ODR |= GPIO_Pin_10	/*设置10脚为高电平*/
GPIOH->ODR &= ~GPIO_Pin_10	/*设置10脚为低电平*/

GPIOH->BSRRL = GPIO_Pin_10	/*设置10脚为高电平,写1后ODR对应位置1*/
GPIOH->BSRRH = GPIO_Pin_10	/*设置10脚为低电平,写1后ODR对应位置0*/
```
## 常用GPIO 库函数
|函数名| 描述|
|:--|:--|
|GPIO_DeInit |将外设 GPIOx 寄存器重设为缺省值|
|GPIO_AFIODeInit |将复用功能（重映射事件控制和 EXTI 设置）重设为缺省值|
|GPIO_Init |根据 GPIO_InitStruct 中指定的参数初始化外设 GPIOx 寄存器|
|GPIO_StructInit |把 GPIO_InitStruct 中的每一个参数按缺省值填入|
|GPIO_ReadInputDataBit |读取指定端口管脚的输入|
|GPIO_ReadInputData |读取指定的 GPIO 端口输入|
|GPIO_ReadOutputDataBit |读取指定端口管脚的输出|
|GPIO_ReadOutputData |读取指定的 GPIO 端口输出|
|GPIO_SetBits |设置指定的数据端口位|
|GPIO_ResetBits |清除指定的数据端口位|
|GPIO_WriteBit |设置或者清除指定的数据端口位|
|GPIO_Write |向指定 GPIO 数据端口写入数据|
|GPIO_PinLockConfig |锁定 GPIO 管脚设置寄存器|
|GPIO_EventOutputConfig |选择 GPIO 管脚用作事件输出|
|GPIO_EventOutputCmd |使能或者失能事件输出|
|GPIO_PinRemapConfig |改变指定管脚的映射|
|GPIO_EXTILineConfig |选择 GPIO 管脚用作外部中断线路|

