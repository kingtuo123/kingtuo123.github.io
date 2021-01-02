---
layout: default
title: EXTI外部中断
parent: STM32
nav_order: 10
---


# EXTI外部中断
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 优先级定义

在 NVIC 有一个专门的寄存器：中断优先级寄存器 NVIC_IPRx（在 F429 中，x=0...90）用来配置外部中断的优先级，IPR 宽度为 8bit，原则上每个外部中断可配置的优先级为0~255，数值越小，优先级越高。但是绝大多数 CM4 芯片都会精简设计，以致实际上支持的优先级数减少，在 F429 中，**只使用了高 4bit**(F103也一样)，如下所示：

<table style="font-weight:normal;">
    <tr>
        <th>bit7</th><th>bit6</th><th>bit5</th><th>bit4</th><th style="background:#cccccc;">bit3</th><th style="background:#cccccc;">bit2</th><th style="background:#cccccc;">bit1</th><th style="background:#cccccc;">bit0</th>
    </tr>
    <tr>
        <td colspan="4" align="center">用于表达优先级</td><td colspan="4" align="center" style="background:#cccccc;">未使用，读回为 0</td>
    </tr>
</table>

用于表达优先级的这 4bit，又被分组成**抢占优先级**和**子优先级**。如果有多个中断同时响应，抢占优先级高的就会 抢占 抢占优先级低的优先得到执行，如果抢占优先级相同，就比较子优先级。如果抢占优先级和子优先级都相同的话，就比较他们的硬件中断编号，**编号越小，优先级越高**。

## 优先级分组

优先级的分组由内核外设 SCB 的应用程序中断及复位控制寄存器 AIRCR 的PRIGROUP[10:8]位决定，F429 分为了 5 组，具体如下：主优先级=抢占优先级

<table >
   <tr align="center" style="font-weight:bold;">
      <td rowspan="2">PRIGROUP[2:0]</td>
      <td colspan="3">中断优先级值 PRI_N[7:4]</td>
      <td colspan="2">级数</td>
   </tr>
   <tr align="center" style="font-weight:bold;">
      <td>二进制点</td>
      <td>主优先级位</td>
      <td>子优先级位</td>
      <td>主优先级</td>
      <td>子优先级</td>
   </tr>
   <tr align="center">
      <td>0b 011</td>
      <td>0b xxxx.</td>
      <td>[7:4]</td>
      <td>None</td>
      <td>16</td>
      <td>None</td>
   </tr>
   <tr align="center">
      <td>0b 100</td>
      <td>0b xxx.y</td>
      <td>[7:5]</td>
      <td>[4]</td>
      <td>8</td>
      <td>2</td>
   </tr>
   <tr align="center" >
      <td>0b 101</td>
      <td>0b xx.yy</td>
      <td>[7:6]</td>
      <td>[5:4]</td>
      <td>4</td>
      <td>4</td>
   </tr>
   <tr align="center">
      <td>0b 110</td>
      <td>0b x.yyy</td>
      <td>[7]</td>
      <td>[6:4]</td>
      <td>2</td>
      <td>9</td>
   </tr>
   <tr align="center">
      <td>0b 111</td>
      <td>0b .yyyy</td>
      <td>None</td>
      <td>[7:4]</td>
      <td>None</td>
      <td>16</td>
   </tr>
</table>
以`0b 100`为例，二进制点为 `0b xxx.y`，表示前3位[7:5]用来表示主优先级，取值范围0-7，共8级；后1位[4]用来表示子优先级，取值范围0-1，共2级。



在F429中EXTI 有 23 个中断/事件线，每个 GPIO 都可以被设置为输入线，占用 EXTI0 至EXTI15，还有另外七根用于特定的外设事件

<table>
   <tr>
      <td>中断/事件线</td>
      <td>输入源</td>
   </tr>
   <tr>
      <td>EXTI0</td>
      <td>PX0(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI1</td>
      <td>PX1(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI2</td>
      <td>PX2(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI3</td>
      <td>PX3(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI4</td>
      <td>PX4(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI5</td>
      <td>PX5(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI6</td>
      <td>PX6(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI7</td>
      <td>PX7(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI8</td>
      <td>PX8(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI9</td>
      <td>PX9(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI10</td>
      <td>PX10(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI11</td>
      <td>PX11(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI12</td>
      <td>PX12(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI13</td>
      <td>PX13(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI14</td>
      <td>PX14(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI15</td>
      <td>PX15(X 可为 A,B,C,D,E,F,G,H,I)</td>
   </tr>
   <tr>
      <td>EXTI16</td>
      <td>可编程电压检测器(PVD)输出</td>
   </tr>
   <tr>
      <td>EXTI17</td>
      <td>RTC 闹钟事件</td>
   </tr>
   <tr>
      <td>EXTI18</td>
      <td>USB OTG FS 唤醒事件</td>
   </tr>
   <tr>
      <td>EXTI19</td>
      <td>以太网唤醒事件</td>
   </tr>
   <tr>
      <td>EXTI20</td>
      <td>USB OTG HS(在 FS 中配置)唤醒事件</td>
   </tr>
   <tr>
      <td>EXTI21</td>
      <td>RTC 入侵和时间戳事件</td>
   </tr>
   <tr>
      <td>EXTI22</td>
      <td>RTC 唤醒事件</td>
   </tr>
</table>
下图是F4参考手册中的内容

![](https://knote.oss-cn-hangzhou.aliyuncs.com/img/EXTI.png)

## 嵌套向量中断控制器NVIC配置

```c
static void NVIC_Configuration(void)
{
	NVIC_InitTypeDef NVIC_InitStructure;

	/* 配置 NVIC 为优先级组 1 */
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1);

	/* 配置中断请求通道：按键 1 */
	NVIC_InitStructure.NVIC_IRQChannel = EXTI0_IRQn;
	/* 配置抢占优先级：1 */
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;
	/* 配置子优先级：1 */
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;
	/* 使能中断通道 */
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&NVIC_InitStructure);

	/* 配置中断请求通道：按键 2，其他使用上面相关配置 */
	NVIC_InitStructure.NVIC_IRQChannel = EXTI15_10_IRQn;
	NVIC_Init(&NVIC_InitStructure);
}
```

NVIC_PriorityGroupConfig可用的优先级分组

|优先级分组 |主优先级| 子优先级 |描述|
|:--:|:--:|:--:|:--:|
|NVIC_PriorityGroup_0 |0 |0-15 |主-0bit，子-4bit|
|NVIC_PriorityGroup_1 |0-1| 0-7 |主-1bit，子-3bit|
|NVIC_PriorityGroup_2 |0-3 |0-3 |主-2bit，子-2bit|
|NVIC_PriorityGroup_3 |0-7 |0-1 |主-3bit，子-1bit|
|NVIC_PriorityGroup_4 |0-15| 0| 主-4bit，子-0bit|

NVIC_InitTypeDef在固件库中的定义

```c
typedef struct
{
	uint8_t NVIC_IRQChannel;					//中断请求通道，其实就是中断号
	uint8_t NVIC_IRQChannelPreemptionPriority;	//主优先级
	uint8_t NVIC_IRQChannelSubPriority;			//子优先级
	FunctionalState NVIC_IRQChannelCmd;			//中断请求通道使能
} NVIC_InitTypeDef; 
```

- NVIC_IRQChannel ：
   - 先确定需端口对应的中断线（如PA0对应EXTI0），中断请求通道名称的定义可以在stm32f4xx.h文件中找到
   - 中断线 0-4 每个线对应一个中断函数，中断请求通道名称EXTIx_IRQn，中断函数名称EXTIx_IRQHandler
   - 中断线 5-9 共用中断函数，中断请求通道名称EXTI9_5_IRQn， 中断函数名称EXTI9_5_IRQHandler
   - 中断线 10-15 共用中断函数，中断请求通道名称EXTI15_10_IRQn， 中断函数名称EXTI15_10_IRQHandler

- NVIC_IRQChannelPreemptionPriority 按优先级分组中的取值范围选取

- NVIC_IRQChannelSubPriority 按优先级分组中的取值范围选取

- NVIC_IRQChannelCmd 启用ENABLE，禁用DISABLE

## EXTI 中断配置

![](https://knote.oss-cn-hangzhou.aliyuncs.com/img/EXTI_SYS.png)

```c
void EXTI_Key_Config(void)
{
	GPIO_InitTypeDef GPIO_InitStructure; 
	EXTI_InitTypeDef EXTI_InitStructure;
  
	/*开启按键GPIO口的时钟*/
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA|RCC_AHB1Periph_GPIOC ,ENABLE);

	/* 使能 SYSCFG 时钟 ，使用GPIO外部中断时必须使能SYSCFG时钟，在F103使能的是AFIO*/
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_SYSCFG, ENABLE);
  
	/* 配置 NVIC */
	NVIC_Configuration();
  
	/* 选择按键1的引脚 */ 
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
	/* 设置引脚为输入模式 */ 
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
	/* 设置引脚不上拉也不下拉 */
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
	/* 使用上面的结构体初始化按键 */
	GPIO_Init(GPIOA, &GPIO_InitStructure); 

	/* 连接 EXTI 中断源 到key1引脚 , 在F103系列中使用GPIO_EXTILineConfig函数*/
	SYSCFG_EXTILineConfig(EXTI_PortSourceGPIOA,EXTI_PinSource0);

	/* 选择 EXTI 中断源 */
	EXTI_InitStructure.EXTI_Line = EXTI_Line0;
	/* 中断模式 */
	EXTI_InitStructure.EXTI_Mode = EXTI_Mode_Interrupt;
	/* 上升沿触发 */
	EXTI_InitStructure.EXTI_Trigger = EXTI_Trigger_Rising;  
	/* 使能中断/事件线 */
	EXTI_InitStructure.EXTI_LineCmd = ENABLE;
	EXTI_Init(&EXTI_InitStructure);
  
	/* 选择按键2的引脚 */ 
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13;  
	/* 其他配置与上面相同 */
	GPIO_Init(GPIOC, &GPIO_InitStructure);      

	/* 连接 EXTI 中断源 到key2 引脚 */
	SYSCFG_EXTILineConfig(EXTI_PortSourceGPIOC,EXTI_PinSource13);

	/* 选择 EXTI 中断源 */
	EXTI_InitStructure.EXTI_Line = EXTI_Line13;
	EXTI_InitStructure.EXTI_Mode = EXTI_Mode_Interrupt;
	/* 下降沿触发 */
	EXTI_InitStructure.EXTI_Trigger = EXTI_Trigger_Falling;  
	EXTI_InitStructure.EXTI_LineCmd = ENABLE;
	EXTI_Init(&EXTI_InitStructure);
}
```
- SYSCFG_EXTILineConfig函数：

```c
void SYSCFG_EXTILineConfig  ( uint8_t  EXTI_PortSourceGPIOx, uint8_t  EXTI_PinSourcex );
// EXTI_PortSourceGPIOx：中断源使用的GPIO端口
// EXTI_PinSourcex：端口引脚号
```

EXTI_InitTypeDef在固件库中的定义

```c
typedef struct
{
	uint32_t EXTI_Line;               /*!指定要使能的中断线*/
	EXTIMode_TypeDef EXTI_Mode;       /*!中断线的工作模式 */
	EXTITrigger_TypeDef EXTI_Trigger; /*!边缘信号触发方式*/
	FunctionalState EXTI_LineCmd;     /*!中断使能 ENABLE or DISABLE */ 
}EXTI_InitTypeDef;
```

- EXTI_Line： 中断线，EXTI_Linex ， { x \| 0≤ x ≤22 }
- EXTI_Mode :
   - EXTI_Mode_Interrupt：产生外部中断，中断信号发送到NVIC，然后执行中断函数
   - EXTI_Mode_Event：产生外部事件，事件信号发送到脉冲发生器，然后产生脉冲给其他外设使用如TIM、ADC
- EXTI_Trigger：
   - EXTI_Trigger_Rising        上升沿触发
   - EXTI_Trigger_Falling	   下降沿触发
   - EXTI_Trigger_Rising_Falling 	 以上两者都可触发
- EXTI_LineCmd：ENABLE 或 DISABLE

## EXTI 中断服务函数

```c
// 中断函数名都是固定的，可以define定义别名
#define KEY1_IRQHandler EXTI0_IRQHandler

void KEY1_IRQHandler(void)
{
  	//确保是否产生了EXTI Line中断
	if(EXTI_GetITStatus(EXTI_Line0) != RESET)
	{
		// LED1 取反		
		LED1_TOGGLE;
    	//清除中断标志位
		EXTI_ClearITPendingBit(EXTI_Line0);
	}  
}
```

EXTI_GetITStatus 函数用来获取 EXTI 的中断标志位状态，如果 EXTI 线有中断发生函数返回“SET”否则返回“RESET”。实际上，EXTI_GetITStatus 函数是通过读取EXTI_PR 寄存器值来判断 EXTI 线状态的。
