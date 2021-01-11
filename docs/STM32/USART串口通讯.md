---
layout: default
title: USART串口通讯
parent: STM32
nav_order: 14
---


# USART串口通讯
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---


## 嵌套向量中断控制器 NVIC 配置

```c
static void NVIC_Configuration(void)
{
    NVIC_InitTypeDef NVIC_InitStructure;

    /* 嵌套向量中断控制器组选择 */
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
    
    /* 配置USART为中断源 */
    NVIC_InitStructure.NVIC_IRQChannel = DEBUG_USART_IRQ;
    /* 抢断优先级为1 */
    NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;
    /* 子优先级为1 */
    NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;
    /* 使能中断 */
    NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
    /* 初始化配置NVIC */
    NVIC_Init(&NVIC_InitStructure);
}
```

## USART 初始化配置

### 头文件定义

```c
#ifndef __DEBUG_USART_H
#define	__DEBUG_USART_H

#include "stm32f4xx.h"
#include <stdio.h>

//引脚定义
/*******************************************************/
#define DEBUG_USART                             USART1
#define DEBUG_USART_CLK                         RCC_APB2Periph_USART1
#define DEBUG_USART_BAUDRATE                    115200  //串口波特率

#define DEBUG_USART_RX_GPIO_PORT                GPIOA
#define DEBUG_USART_RX_GPIO_CLK                 RCC_AHB1Periph_GPIOA
#define DEBUG_USART_RX_PIN                      GPIO_Pin_10
#define DEBUG_USART_RX_AF                       GPIO_AF_USART1
#define DEBUG_USART_RX_SOURCE                   GPIO_PinSource10

#define DEBUG_USART_TX_GPIO_PORT                GPIOA
#define DEBUG_USART_TX_GPIO_CLK                 RCC_AHB1Periph_GPIOA
#define DEBUG_USART_TX_PIN                      GPIO_Pin_9
#define DEBUG_USART_TX_AF                       GPIO_AF_USART1
#define DEBUG_USART_TX_SOURCE                   GPIO_PinSource9

#define DEBUG_USART_IRQHandler                  USART1_IRQHandler
#define DEBUG_USART_IRQ                 		USART1_IRQn
/************************************************************/

void Debug_USART_Config(void);
void Usart_SendByte( USART_TypeDef * pUSARTx, uint8_t ch);
void Usart_SendString( USART_TypeDef * pUSARTx, char *str);

void Usart_SendHalfWord( USART_TypeDef * pUSARTx, uint16_t ch);

#endif /* __USART1_H */
```

### USART初始化

```c
void Debug_USART_Config(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;
    USART_InitTypeDef USART_InitStructure;
    
    
    /* 使能 GPIO 时钟 */
    RCC_AHB1PeriphClockCmd(DEBUG_USART_RX_GPIO_CLK|DEBUG_USART_TX_GPIO_CLK,ENABLE);
    /* 使能 USART 时钟 */
    RCC_APB2PeriphClockCmd(DEBUG_USART_CLK, ENABLE);
    
    
    /***************************GPIO配置**************************/
    /* GPIO初始化 */
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;  
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    /* 配置Tx引脚为复用功能 */
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
    GPIO_InitStructure.GPIO_Pin = DEBUG_USART_TX_PIN  ;  
    GPIO_Init(DEBUG_USART_TX_GPIO_PORT, &GPIO_InitStructure);
    /* 配置Rx引脚为复用功能 */
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
    GPIO_InitStructure.GPIO_Pin = DEBUG_USART_RX_PIN;
    GPIO_Init(DEBUG_USART_RX_GPIO_PORT, &GPIO_InitStructure);
    /************************************************************/
    
    
    /************************关联GPIO引脚和USART*******************/
    /*F1系列无需此步骤，F4功能较多要手动设置，具体看数据手册引脚复用功能映射*/
    /* 连接 PXx 到 USARTx_Tx */
    GPIO_PinAFConfig(DEBUG_USART_RX_GPIO_PORT,DEBUG_USART_RX_SOURCE,DEBUG_USART_RX_AF);
    /* 连接 PXx 到 USARTx__Rx */
    GPIO_PinAFConfig(DEBUG_USART_TX_GPIO_PORT,DEBUG_USART_TX_SOURCE,DEBUG_USART_TX_AF);
    /************************************************************/
    
    
    /*************************USART配置***************************/
    /* 波特率设置：DEBUG_USART_BAUDRATE */
    USART_InitStructure.USART_BaudRate = DEBUG_USART_BAUDRATE;
    /* 字长(数据位+校验位)：8 */
    USART_InitStructure.USART_WordLength = USART_WordLength_8b;
    /* 停止位：1个停止位 */
    USART_InitStructure.USART_StopBits = USART_StopBits_1;
    /* 校验位选择：不使用校验 */
    USART_InitStructure.USART_Parity = USART_Parity_No;
    /* 硬件流控制：不使用硬件流 */
    USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
    /* USART模式控制：同时使能接收和发送 */
    USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
    /* 完成USART初始化配置 */
    USART_Init(DEBUG_USART, &USART_InitStructure);
    /************************************************************/      
    
    
    /*************************中断配置和使能************************/
    /* 嵌套向量中断控制器NVIC配置，中断优先级 */
    NVIC_Configuration();
    /* 使能串口接收中断 */
    USART_ITConfig(DEBUG_USART, USART_IT_RXNE, ENABLE);
    /* 使能串口 */
    USART_Cmd(DEBUG_USART, ENABLE);
    /************************************************************/
}
```

### UART初始化结构体

```c
typedef struct {
    uint32_t USART_BaudRate; // 波特率
    uint16_t USART_WordLength; // 字长
    uint16_t USART_StopBits; // 停止位
    uint16_t USART_Parity; // 校验位
    uint16_t USART_Mode; // USART 模式
    uint16_t USART_HardwareFlowControl; // 硬件流控制
} USART_InitTypeDef;
```

- **USART_BaudRate**：波特率设置。一般设置为 2400、9600、19200、115200。

- **USART_WordLength**：数据帧字长，可选 8 位或 9 位。它设定 USART_CR1 寄存器的 M 位的值。如果没有使能奇偶校验控制，一般使用 8 数据位；如果使能了奇偶校验则一般设置为 9 数据位。

   - USART_WordLength_8b

   - USART_WordLength_9b

- **USART_StopBits**：停止位设置，它设定USART_CR2 寄存器的 STOP[1:0]位的值，一般我们选择 1 个停止位。

   - USART_StopBits_1

   - USART_StopBits_0_5

   - #define USART_StopBits_2

   - USART_StopBits_1_5

- **USART_Parity** ： 奇 偶 校 验 控 制 选 择 ， 它 设 定USART_CR1 寄存器的 PCE 位和 PS 位的值。

   - USART_Parity_No		   无校验

   - USART_Parity_Even        偶校验

   - USART_Parity_Odd         奇校验

- **USART_Mode**：USART 模式选择，允许使用逻辑或运算选择两个，它设定 USART_CR1 寄存器的 RE 位和 TE 位。

   - USART_Mode_Rx

   - USART_Mode_Tx

- **USART_HardwareFlowControl**：硬件流控制选择，只有在硬件流控制模式才有效

   - USART_HardwareFlowControl_None       不使能硬件流

   - USART_HardwareFlowControl_RTS          使能 RTS

   - USART_HardwareFlowControl_CTS          使能 CTS

   - USART_HardwareFlowControl_RTS_CTS         同时使能 RTS 和 CTS




### USART_ITConfig启用中断

```c
// 函数原型，用于启用或禁用特定的USART中断
void USART_ITConfig (USART_TypeDef * USARTx, uint16_t USART_IT, FunctionalState  NewState) 
```

- **USARTx** : x 可以是 1, 2, 3, 4, 5, 6, 7 or 8 来选择 USART 或 UART 外设  

- **USART_IT** : 选择USART中断源

   - USART_IT_CTS : 	    CTS标志改变interrupt 

   - USART_IT_LBD :         LIN断开检测中断

   - USART_IT_TXE :  	    发送数据寄存器为空中断

   - USART_IT_TC :    	    传输完成中断

   - USART_IT_RXNE :       接收数据寄存器不为空中断

   - USART_IT_IDLE :         检测到空闲线路中断

   - USART_IT_PE :            奇偶校验错误中断

   - USART_IT_ERR :          错误中断(多缓冲通信中的噪声标志、上溢错误和帧错误 ) 

- **NewState** : 明确USARTx中断状态. 可以是 ENABLE 或 DISABLE. 



## 字符发送


```c
/*****************  发送一个字符  **********************/
void Usart_SendByte( USART_TypeDef * pUSARTx, uint8_t ch)
{
    /* 发送一个字节数据到USART */
    USART_SendData(pUSARTx,ch);
    	
    /* 等待发送数据寄存器为空 */
    while (USART_GetFlagStatus(pUSARTx, USART_FLAG_TXE) == RESET);	
}

/*****************  发送字符串  **********************/
void Usart_SendString( USART_TypeDef * pUSARTx, char *str)
{
    unsigned int k=0;
    do
    {
    	Usart_SendByte( pUSARTx, *(str + k) );
    	k++;
    } while(*(str + k)!='\0');
    
    /* 等待发送完成 */
    while(USART_GetFlagStatus(pUSARTx,USART_FLAG_TC)==RESET)
    {}
}

/*****************  发送一个16位数  **********************/
void Usart_SendHalfWord( USART_TypeDef * pUSARTx, uint16_t ch)
{
    uint8_t temp_h, temp_l;
    
    /* 取出高八位 */
    temp_h = (ch&0XFF00)>>8;
    /* 取出低八位 */
    temp_l = ch&0XFF;
    
    /* 发送高八位 */
    USART_SendData(pUSARTx,temp_h);	
    while (USART_GetFlagStatus(pUSARTx, USART_FLAG_TXE) == RESET);
    
    /* 发送低八位 */
    USART_SendData(pUSARTx,temp_l);	
    while (USART_GetFlagStatus(pUSARTx, USART_FLAG_TXE) == RESET);	
}
```


### USART_SendData函数原型


```c
void USART_SendData(USART_TypeDef* USARTx, uint16_t Data)
{
    /* Check the parameters */
    assert_param(IS_USART_ALL_PERIPH(USARTx));
    assert_param(IS_USART_DATA(Data)); 
    
    /* Transmit Data */
    USARTx->DR = (Data & (uint16_t)0x01FF);
}
```

(Data & (uint16_t)0x01FF) 只截取9位数据，因为数据帧的字长可选 8 位或 9 位。


## USART中断服务函数


```c
void DEBUG_USART_IRQHandler(void)
{
    uint8_t ucTemp;
    if(USART_GetITStatus(DEBUG_USART,USART_IT_RXNE)!=RESET)
    {		
    	ucTemp = USART_ReceiveData( DEBUG_USART );
    	USART_SendData(DEBUG_USART,ucTemp);		// 回显
    }	 
}
```

### USART_GetITStatus函数原型

```c
/**
  * @brief  Checks whether the specified USART interrupt has occurred or not.
  * @param  USARTx: where x can be 1, 2, 3, 4, 5, 6, 7 or 8 to select the USART or 
  *         UART peripheral.
  * @param  USART_IT: specifies the USART interrupt source to check.
  *          This parameter can be one of the following values:
  *            @arg USART_IT_CTS:  CTS change interrupt (not available for UART4 and UART5)
  *            @arg USART_IT_LBD:  LIN Break detection interrupt
  *            @arg USART_IT_TXE:  Transmit Data Register empty interrupt
  *            @arg USART_IT_TC:   Transmission complete interrupt
  *            @arg USART_IT_RXNE: Receive Data register not empty interrupt
  *            @arg USART_IT_IDLE: Idle line detection interrupt
  *            @arg USART_IT_ORE_RX : OverRun Error interrupt if the RXNEIE bit is set
  *            @arg USART_IT_ORE_ER : OverRun Error interrupt if the EIE bit is set  
  *            @arg USART_IT_NE:   Noise Error interrupt
  *            @arg USART_IT_FE:   Framing Error interrupt
  *            @arg USART_IT_PE:   Parity Error interrupt
  * @retval The new state of USART_IT (SET or RESET).
  */
ITStatus USART_GetITStatus(USART_TypeDef* USARTx, uint16_t USART_IT);
```

### USART_ReceiveData函数原型

```c
/**
  * @brief  Returns the most recent received data by the USARTx peripheral.
  * @param  USARTx: where x can be 1, 2, 3, 4, 5, 6, 7 or 8 to select the USART or 
  *         UART peripheral.
  * @retval The received data.
  */
uint16_t USART_ReceiveData(USART_TypeDef* USARTx)
{
    /* Check the parameters */
    assert_param(IS_USART_ALL_PERIPH(USARTx));
    
    /* Receive Data */
    return (uint16_t)(USARTx->DR & (uint16_t)0x01FF);
}
```

## 主函数

```c
int main(void)
{
    /*初始化USART 配置模式为 115200 8-N-1，中断接收*/
    Debug_USART_Config();
    /* 发送一个字符串 */
    Usart_SendString( DEBUG_USART,"这是一个串口中断接收回显实验\n");
    while(1);
}
```


**8-N-1是什么 ?**

801  是数位为8位,奇校验,1个停止位

8N1 是数位为8位,无校验,1个停止位

8E1  是数位为8位,偶校验,1个停止位

同理：

802  是数位为8位,奇校验,2个停止位

8N2 是数位为8位,无校验,2个停止位

8E2  是数位为8位,偶校验,2个停止位
