---
layout: default
title: DMA直接存储访问
parent: STM32
nav_order: 18
---


# DMA直接存储访问
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---


## DMA 简介

DMA(Direct Memory Access)直接存储器存取，是单片机的一个外设，它的主要功能是用来搬数据，但是不需要占用 CPU，即在传输数据的时候，CPU 可以干其他的事情，好像是多线程一样。



## DMA功能框图

<img src="https://knote.oss-cn-hangzhou.aliyuncs.com/img/DMA%E6%A1%86%E5%9B%BE.png" style="zoom:50%;" />

### 通道选择

STM32F4xx 有两个 DMA 控制器。每个 DMA 控制器具有 8 个数据流，每个数据流对应 8 个外设请求。

<img src="https://knote.oss-cn-hangzhou.aliyuncs.com/img/DMA%E8%AF%B7%E6%B1%82%E6%98%A0%E5%B0%84.png" style="" />

每个数据流都与一个 DMA 请求相关联，此 DMA 请求可以从 8 个可能的通道请求中选出。此选择由 DMA_SxCR（DMA stream x configuration register） 寄存器中的 CHSEL[2:0] 位控制。

<img src="https://knote.oss-cn-hangzhou.aliyuncs.com/img/DMA%E9%80%9A%E9%81%93%E9%80%89%E6%8B%A9.png" style="max-height:300px"  align="center"/>

**CHSEL[2:0]**：通道选择 (Channel selection)

这些位将由软件置 1 和清零。

   - 000：选择通道 0

   - 001：选择通道 1

   - 010：选择通道 2

   - 011：选择通道 3

   - 100：选择通道 4

   - 101：选择通道 5

   - 110：选择通道 6

   - 111：选择通道 7

这些位受到保护，只有 EN 为“0”时才可以写入

### 仲裁器

数据流优先级控制

优先级管理分为两个阶段：

**软件**：每个数据流优先级都可以在 DMA_SxCR 寄存器中PL[1:0]（Priority level）配置。分为四个级别：

- 11：非常高优先级

- 10：高优先级

- 01：中优先级

- 00：低优先级

**硬件**：如果两个请求具有相同的软件优先级，则编号低的数据流优先于编号高的数据流。例如，数据流 2 的优先级高于数据流 4。



### FIFO

- 每个数据流都独立拥有四级 32 位 FIFO(先进先出存储器缓冲区)。DMA 传输具有 FIFO模式和直接模式。

- 在直接模式下，如果 DMA 配置为存储器到外设传输那 DMA 会将一个数据存放在 FIFO 内，如果外设启动 DMA 传输请求就可以马上将数据传输过去。

- FIFO 用于在源数据传输到目标地址之前临时存放这些数据。可以通过 DMA 数据流xFIFO 控制寄存器 DMA_SxFCR 的 FTH[1:0]位（FIFO threshold selection）来控制 FIFO 的阈值，分别为 1/4、1/2、3/4、4/4。如果数据存储量达到阈值级别时，FIFO 内容将传输到目标中。

- 简而言之，直接模式来一个发一个，FIFO模式凑够数再发。

- FIFO 另外一个作用使用于突发(burst)传输。

*备注：F103系列没有FIFO*



### 存储器端口、外设端口

![](https://knote.oss-cn-hangzhou.aliyuncs.com/img/DMA%E6%8E%A7%E5%88%B6%E5%99%A8%E5%AE%9E%E7%8E%B0.png)

DMA1 控制器 AHB 外设端口与 DMA2 控制器的情况不同，不连接到总线矩阵，因此，仅 DMA2 数据流能够执行存储器到存储器的传输。



### 编程端口

AHB 从器件编程端口是连接至 AHB2 外设的。AHB2 外设在使用 DMA 传输时需要相关控制信号。



## DMA 数据配置



### DMA 传输模式

- 外设到存储器

- 存储器到外设

- 存储器到存储器

DMA2 支持全部三种传输模式，而 DMA1 只有外设到存储器和存储器到外设两种模式。

在 DMA_SxCR 寄存器的 PSIZE[1:0]和 MSIZE[1:0]位分别指定外设和存储器数据宽度大小，可以指定为字节(8 位)、半字(16 位)和字(32 位)，我们可以根据实际情况设置。直接模式要求外设和存储器数据宽度大小一样，实际上在这种模式下 DMA 数据流直接使用PSIZE，MSIZE 不被使用



### 源地址和目标地址

**外设地址寄存器**：

-  DMA_SxPAR(x 为 0~7)

**存储器 0 地址寄存器**：

-  DMA_SxM0AR(x 为 0~7) 

**存储器 1 地址寄存器**：

- DMA_SxM1AR(x 为 0~7) ，只用于双缓冲模式。



### 流控制器

- 流控制器主要涉及到一个控制 DMA 传输停止问题。DMA 传输在 DMA_SxCR 寄存器的 EN 位被置 1 后就进入准备传输状态，如果有外设请求 DMA 传输就可以进行数据传输。

- 很多情况下，我们明确知道传输数据的数目，比如要传 1000 个或者 2000 个数据，这样我们就可以在传输之前设置 DMA_SxNDTR 寄存器为要传输数目值，DMA 控制器在传输完这么多数目数据后就可以控制 DMA 停止传输。

- DMA 数据流 x 数据项数 DMA_SxNDTR(x 为 0~7)寄存器用来记录当前仍需要传输数目，它是一个 16 位数据有效寄存器，即最大值为 65535，这个值在程序设计是非常有用也是需要注意的地方。我们在编程时一般都会明确指定一个传输数量，在完成一次数目传输后DMA_SxNDTR 计数值就会自减，当达到零时就说明传输完成。

- 如果某些情况下在传输之前我们无法确定数据的数目，那 DMA 就无法自动控制传输停止了，此时需要外设通过硬件通信向 DMA 控制器发送停止传输信号。这里有一个大前提就是外设必须是可以发出这个停止传输信号，只有 SDIO 才有这个功能，其他外设不具备此功能。



### 循环模式

- 循环模式相对应于一次模式。一次模式就是传输一次就停止传输，下一次传输需要手动控制，而循环模式在传输一次后会自动按照相同配置重新传输，周而复始直至被控制停止或传输发生错误。

- 通过 DMA_SxCR 寄存器的 CIRC 位可以使能循环模式。



### 传输类型

在 **DMA_SxCR** 寄存器的 **PSIZE[1:0]**和 **MSIZE[1:0]**位分别指定外设和存储器数据宽度大小，可以指定为字节(8 位)、半字(16 位)和字(32 位)

**单次(Single)传输**：

- 每次 DMA 请求就传输一次 8位/ 16位/ 32位 (取决于 PSIZE)数据

**突发(Burst)传输**：

- 当DMA申请总线成功后会连续传送数据，而不给cpu使用总线的机会，直到数据传送完毕。比如stm32设置了4个节拍的突发传输，传输宽度位8位（PSIZE），则一个dma请求会连续传送4个字节，是单次传输的4倍。

**PBURST[1:0]**：在 **DMA_SxCR** 寄存器的**PBURST[1:0]**，外设突发传输配置 (Peripheral burst transfer configuration)

- 00：单次传输 

- 01：INCR4  （4 个节拍的增量突发传输） 

- 10：INCR8  （8 个节拍的增量突发传输） 

- 11：INCR16（16 个节拍的增量突发传输）



### 直接模式

- 默认情况下，DMA 工作在直接模式，不使能 FIFO 阈值级别。

- 直接模式接收到外设请求后立即启动对存储器的单次传输。直接模式要求源地址和目标地址的数据宽度必须一致，所以只有 PSIZE 控制，而 MSIZE 值被忽略。

- 突发传输是基于 FIFO 的所以直接模式不被支持。另外直接模式不能用于存储器到存储器传输。

- 在直接模式下，如果 DMA 配置为存储器到外设传输那 DMA 会见一个数据存放在FIFO 内，如果外设启动 DMA 传输请求就可以马上将数据传输过去。



### 双缓冲模式

- 设置 DMA_SxCR 寄存器的 DBM 位为 1 可启动双缓冲传输模式，并自动激活循环模式。

- 双缓冲不应用与存储器到存储器的传输。

- 双缓冲模式下，两个存储器地址指针都有效，即DMA_SxM1AR 寄存器将被激活使用。开始传输使用 DMA_SxM0AR 寄存器的地址指针所对应的存储区，当这个存储区数据传输完 DMA 控制器会自动切换至 DMA_SxM1AR 寄存器的地址指针所对应的另一块存储区，如果这一块也传输完成就再切换至 DMA_SxM0AR寄存器的地址指针所对应的存储区，这样循环调用。

- 当其中一个存储区传输完成时都会把传输完成中断标志 TCIF 位置 1，如果我们使能了DMA_SxCR 寄存器的传输完成中断，则可以产生中断信号，这个对我们编程非常有用。另外一个非常有用的信息是 DMA_SxCR 寄存器的 CT 位，当 DMA 控制器是在访问使用DMA_SxM0AR 时 CT=0，此时 CPU 不能访问 DMA_SxM0AR，但可以向 DMA_SxM1AR填充或者读取数据；当 DMA 控制器是在访问使用 DMA_SxM1AR 时 CT=1，此时 CPU 不能访问 DMA_SxM1AR，但可以向 DMA_SxM0AR 填充或者读取数据。另外在未使能DMA 数据流传输时，可以直接写 CT 位，改变开始传输的目标存储区。



### DMA 中断

每个 DMA 数据流可以在发送以下事件时产生中断：

   - **达到半传输**：DMA 数据传输达到一半时 HTIF 标志位被置 1，如果使能 HTIE 中断控制位将产生达到半传输中断

   - **传输完成**：DMA 数据传输完成时 TCIF 标志位被置 1，如果使能 TCIE 中断控制位将产生传输完成中断

   - **传输错误**：DMA 访问总线发生错误或者在双缓冲模式下试图访问“受限”存储器地址寄存器时 TEIF 标志位被置 1，如果使能 TEIE 中断控制位将产生传输错误中断

   - **FIFO错误**：发生 FIFO 下溢或者上溢时 FEIF 标志位被置 1，如果使能 FEIE 中断控制位将产生 FIFO 错误中断

   - **直接模式错误**：在外设到存储器的直接模式下，因为存储器总线没得到授权，使得先前数据没有完成被传输到存储器空间上，此时 DMEIF 标志位被置 1，如果使能 DMEIE 中断控制位将产生直接模式错误中断。



## DMA 初始化结构体详解

```c
typedef struct {
    uint32_t DMA_Channel;            //通道选择
    uint32_t DMA_PeripheralBaseAddr; //外设地址
    uint32_t DMA_Memory0BaseAddr;    //存储器 0 地址
    uint32_t DMA_DIR;                //传输方向
    uint32_t DMA_BufferSize;         //数据数目
    uint32_t DMA_PeripheralInc;      //外设递增
    uint32_t DMA_MemoryInc;          //存储器递增
    uint32_t DMA_PeripheralDataSize; //外设数据宽度
    uint32_t DMA_MemoryDataSize;     //存储器数据宽度
    uint32_t DMA_Mode;               //模式选择
    uint32_t DMA_Priority;           //优先级
    uint32_t DMA_FIFOMode;           //FIFO 模式
    uint32_t DMA_FIFOThreshold;      //FIFO 阈值
    uint32_t DMA_MemoryBurst;        //存储器突发传输
    uint32_t DMA_PeripheralBurst;    //外设突发传输
} DMA_InitTypeDef;
```

- **DMA_Channel**：DMA 请求通道选择，可选通道 0 至通道 7

  DMA_Channel_0 
  
  DMA_Channel_1 
  
  DMA_Channel_2 
  
  DMA_Channel_3 
  
  DMA_Channel_4 
  
  DMA_Channel_5 
  
  DMA_Channel_6 
  
  DMA_Channel_7 

  

- **DMA_PeripheralBaseAddr**：外设地址，设定 DMA_SxPAR 寄存器的值；一般设置为外设的数据寄存器地址，如果是存储器到存储器模式则设置为其中一个存储区地址。ADC3 的数据寄存器 ADC_DR 地址为((uint32_t)ADC3+0x4C)。

  

- **DMA_Memory0BaseAddr**：存储器 0 地址，设定 DMA_SxM0AR 寄存器值；一般设置为我们自定义存储区的首地址。

  

- **DMA_DIR**：传输方向选择，可选外设到存储器、存储器到外设以及存储器到存储器。它设定 DMA_SxCR 寄存器的 DIR[1:0]位的值。

  DMA_DIR_PeripheralToMemory
  
  DMA_DIR_MemoryToPeripheral
  
  DMA_DIR_MemoryToMemory   
  
  

- **DMA_BufferSize**：设定待传输数据数目，初始化设定 DMA_SxNDTR 寄存器的值。

  

- **DMA_PeripheralInc**：如果配置为 DMA_PeripheralInc_Enable，使能外设地址自动递增功能，它设定 DMA_SxCR 寄存器的 PINC 位的值；一般外设都是只有一个数据寄存器，所以一般不会使能该位。ADC3 的数据寄存器地址是固定并且只有一 个所以不使能外设地址递增。

  DMA_PeripheralInc_Enable 
  
  DMA_PeripheralInc_Disable

  

- **DMA_MemoryInc**：如果配置为 DMA_MemoryInc_Enable，使能存储器地址自动递增功能，它设定 DMA_SxCR 寄存器的 MINC 位的值；我们自定义的存储区一般都是存放多个数据的，所以使能存储器地址自动递增功能。

  DMA_MemoryInc_Enable 
  
  DMA_MemoryInc_Disable

  

- **DMA_PeripheralDataSize**：外设数据宽度，外设数据宽度，可选字节(8 位)、半字(16 位)和字(32位)，它设定 DMA_SxCR 寄存器的 PSIZE[1:0]位的值

  DMA_PeripheralDataSize_Byte 
  
  DMA_PeripheralDataSize_HalfWord
  
  DMA_PeripheralDataSize_Word
  
  

- **DMA_MemoryDataSize**：存储器数据宽度，可选字节(8 位)、半字(16 位)和字(32位)，它设定 DMA_SxCR 寄存器的 MSIZE[1:0]位的值。

  DMA_MemoryDataSize_Byte 
  
  DMA_MemoryDataSize_HalfWord
  
  DMA_MemoryDataSize_Word 

  

- **DMA_Mode**：DMA 传输模式选择， 可选 一次传输或者循环传输 ，它设定DMA_SxCR 寄存器的 CIRC 位的值。

  DMA_Mode_Normal 
  
  DMA_Mode_Circular
  
  


- **DMA_Priority**：软件设置数据流的优先级

  DMA_Priority_Low 
  
  DMA_Priority_Medium 
  
  DMA_Priority_High 
  
  DMA_Priority_VeryHigh

  

- **DMA_FIFOMode**：FIFO 模式使能

  DMA_FIFOMode_Disable
  
  DMA_FIFOMode_Enable 

  

- **DMA_FIFOThreshold**：FIFO 阈值选择

  1/4：DMA_FIFOThreshold_1QuarterFull 
  
  2/4：DMA_FIFOThreshold_HalfFull 
  
  3/4：DMA_FIFOThreshold_3QuartersFull
  
  4/4：DMA_FIFOThreshold_Full
  
  
  
- **DMA_MemoryBurst**：存储器突发模式选择

  单次    ：DMA_MemoryBurst_Single
  
  4节拍  ：DMA_MemoryBurst_INC4 
  
  8节拍  ：DMA_MemoryBurst_INC8 
  
  16节拍：DMA_MemoryBurst_INC16 
  
  
  
- **DMA_PeripcheralBurst**：外设突发模式选择

  单次    ：DMA_PeripheralBurst_Single
  
  4节拍  ：DMA_PeripheralBurst_INC4
  
  8节拍  ：DMA_PeripheralBurst_INC8
  
  16节拍：DMA_PeripheralBurst_INC16 





## DMA存储器到存储器模式实验

头文件

```c
/* 相关宏定义，使用存储器到存储器传输必须使用 DMA2 */
#define DMA_STREAM        DMA2_Stream0
#define DMA_CHANNEL       DMA_Channel_0
#define DMA_STREAM_CLOCK  RCC_AHB1Periph_DMA2
#define DMA_FLAG_TCIF     DMA_FLAG_TCIF0

#define BUFFER_SIZE       32
#define TIMEOUT_MAX       10000 /* 最大超时时间 */

/* 定义 aSRC_Const_Buffer 数组作为 DMA 传输数据源 */
const uint32_t aSRC_Const_Buffer[BUFFER_SIZE] = {
0x01020304,0x05060708,0x090A0B0C,0x0D0E0F10,
0x11121314,0x15161718,0x191A1B1C,0x1D1E1F20,
0x21222324,0x25262728,0x292A2B2C,0x2D2E2F30,
0x31323334,0x35363738,0x393A3B3C,0x3D3E3F40,
0x41424344,0x45464748,0x494A4B4C,0x4D4E4F50,
0x51525354,0x55565758,0x595A5B5C,0x5D5E5F60,
0x61626364,0x65666768,0x696A6B6C,0x6D6E6F70,
};
/* 定义 DMA 传输目标存储器 */
uint32_t aDST_Buffer[BUFFER_SIZE];
```

初始化配置函数

```c
static void DMA_Config(void)
{
    DMA_InitTypeDef DMA_InitStructure;
    __IO uint32_t Timeout = TIMEOUT_MAX;

    /* 使能 DMA 时钟 */
    RCC_AHB1PeriphClockCmd(DMA_STREAM_CLOCK, ENABLE);

    /* 复位初始化 DMA 数据流 */
    DMA_DeInit(DMA_STREAM);

    /* 确保 DMA 数据流复位完成 */
    while (DMA_GetCmdStatus(DMA_STREAM) != DISABLE) {
    }

    /* DMA 数据流通道选择 */
    DMA_InitStructure.DMA_Channel = DMA_CHANNEL;
    /* 源数据地址 */
    DMA_InitStructure.DMA_PeripheralBaseAddr=(uint32_t)aSRC_Const_Buffer;
    /* 目标地址 */
    DMA_InitStructure.DMA_Memory0BaseAddr = (uint32_t)aDST_Buffer;
    /* 存储器到存储器模式 */
    DMA_InitStructure.DMA_DIR = DMA_DIR_MemoryToMemory;
    /* 数据数目 */
    DMA_InitStructure.DMA_BufferSize = (uint32_t)BUFFER_SIZE;
    /* 使能自动递增功能 */
    DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Enable;
    /* 使能自动递增功能 */
    DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
    /* 源数据是字大小(32 位) */
    DMA_InitStructure.DMA_PeripheralDataSize=DMA_PeripheralDataSize_Word;
    /* 目标数据也是字大小(32 位) */
    DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_Word;
    /* 一次传输模式，存储器到存储器模式不能使用循环传输 */
    DMA_InitStructure.DMA_Mode = DMA_Mode_Normal;
    /* DMA 数据流优先级为高 */
    DMA_InitStructure.DMA_Priority = DMA_Priority_High;
    /* 禁用 FIFO 模式 */
    DMA_InitStructure.DMA_FIFOMode = DMA_FIFOMode_Disable;
    /* FIFO 阈值 */
    DMA_InitStructure.DMA_FIFOThreshold = DMA_FIFOThreshold_Full;
    /* 单次模式 */
    DMA_InitStructure.DMA_MemoryBurst = DMA_MemoryBurst_Single;
    /* 单次模式 */
    DMA_InitStructure.DMA_PeripheralBurst = DMA_PeripheralBurst_Single;
    /* 完成 DMA 数据流参数配置 */
    DMA_Init(DMA_STREAM, &DMA_InitStructure);
    /* 清除 DMA 数据流传输完成标志位 */
    DMA_ClearFlag(DMA_STREAM,DMA_FLAG_TCIF);

    /* 使能 DMA 数据流，开始 DMA 数据传输 */
    DMA_Cmd(DMA_STREAM, ENABLE);

    /* 检测 DMA 数据流是否有效并带有超时检测功能 */
    Timeout = TIMEOUT_MAX;
    while ((DMA_GetCmdStatus(DMA_STREAM) != ENABLE) && (Timeout-- > 0)) {
    }

    /* 判断是否超时 */
    if (Timeout == 0) {
        /* 超时就让程序运行下面循环：RGB 彩色灯闪烁 */
        while (1) {
            LED_RED;
            Delay(0xFFFFFF);
            LED_RGBOFF;
            Delay(0xFFFFFF);
        }
    }
}



uint8_t Buffercmp(const uint32_t* pBuffer, uint32_t* pBuffer1, uint16_t BufferLength)
{
    /* 数据长度递减 */
    while (BufferLength--) {
        /* 判断两个数据源是否对应相等 */
        if (*pBuffer != *pBuffer1) {
            /* 对应数据源不相等马上退出函数，并返回 0 */
            return 0;
        }
        /* 递增两个数据源的地址指针 */
        pBuffer++;
        pBuffer1++;
    }
    /* 完成判断并且对应数据相对 */
    return 1;
}
```

主函数

```c
int main(void)
{
    /* 定义存放比较结果变量 */
    uint8_t TransferStatus;

    /* LED 端口初始化 */
    LED_GPIO_Config();

    /* 设置 RGB 彩色灯为紫色 */
    LED_PURPLE;

    /* 简单延时函数 */
    Delay(0xFFFFFF);
    
    /* DMA 传输配置 */
    DMA_Config();
    
    /* 等待 DMA 传输完成 */
    while (DMA_GetFlagStatus(DMA_STREAM,DMA_FLAG_TCIF)==DISABLE) {
    }
    
    /* 比较源数据与传输后数据 */
    TransferStatus = Buffercmp(aSRC_Const_Buffer, aDST_Buffer, BUFFER_SIZE);
    
    /* 判断源数据与传输后数据比较结果 */
    if (TransferStatus==0) { 
        /* 源数据与传输后数据不相等时 RGB 彩色灯显示红色 */
        LED_RED;
    } else {
        /* 源数据与传输后数据相等时 RGB 彩色灯显示蓝色 */
        LED_BLUE;
    }
    
    while (1) {
    }
}
```





## DMA存储器到外设模式实验

头文件

```c
//USART
#define                           DEBUG_USART USART1
#define DEBUG_USART_CLK           RCC_APB2Periph_USART1
#define DEBUG_USART_RX_GPIO_PORT  GPIOA
#define DEBUG_USART_RX_GPIO_CLK   RCC_AHB1Periph_GPIOA
#define DEBUG_USART_RX_PIN        GPIO_Pin_10
#define DEBUG_USART_RX_AF         GPIO_AF_USART1
#define DEBUG_USART_RX_SOURCE     GPIO_PinSource10

#define DEBUG_USART_TX_GPIO_PORT  GPIOA
#define DEBUG_USART_TX_GPIO_CLK   RCC_AHB1Periph_GPIOA
#define DEBUG_USART_TX_PIN        GPIO_Pin_9
#define DEBUG_USART_TX_AF         GPIO_AF_USART1
#define DEBUG_USART_TX_SOURCE     GPIO_PinSource9

#define DEBUG_USART_BAUDRATE      115200

//DMA
#define DEBUG_USART_DR_BASE       (USART1_BASE+0x04) //0x04是USART_DR（数据寄存器）的偏移地址
#define SENDBUFF_SIZE             5000  //一次发送的数据量
#define DEBUG_USART_DMA_CLK       RCC_AHB1Periph_DMA2
#define DEBUG_USART_DMA_CHANNEL   DMA_Channel_4
#define DEBUG_USART_DMA_STREAM    DMA2_Stream7
```

USART 部分设置与 [USART串口通讯 ](https://kingtuo123.com/docs/STM32/USART%E4%B8%B2%E5%8F%A3%E9%80%9A%E8%AE%AF.html)章节内容相同，可以参考该章节内容理解

串口DMA传输配置

```c
void USART_DMA_Config(void)
{
    DMA_InitTypeDef DMA_InitStructure;
    
    /* 开启 DMA 时钟 */
    RCC_AHB1PeriphClockCmd(DEBUG_USART_DMA_CLK, ENABLE);
    
    /* 复位初始化 DMA 数据流 */
    DMA_DeInit(DEBUG_USART_DMA_STREAM);
    
    /* 确保 DMA 数据流复位完成 */
    while (DMA_GetCmdStatus(DEBUG_USART_DMA_STREAM) != DISABLE) {
    }
    
    /* usart1 tx 对应 dma2，通道 4，数据流 7 */
    DMA_InitStructure.DMA_Channel = DEBUG_USART_DMA_CHANNEL;
    /* 设置 DMA 源：串口数据寄存器地址 */
    DMA_InitStructure.DMA_PeripheralBaseAddr = DEBUG_USART_DR_BASE;
    /* 内存地址(要传输的变量的指针) */
    DMA_InitStructure.DMA_Memory0BaseAddr = (u32)SendBuff;
    /* 方向：从内存到外设 */
    DMA_InitStructure.DMA_DIR = DMA_DIR_MemoryToPeripheral;
    /* 传输大小 DMA_BufferSize=SENDBUFF_SIZE */
    DMA_InitStructure.DMA_BufferSize = SENDBUFF_SIZE;
    /* 外设地址不增 */
    DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
    /* 内存地址自增 */
    DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
    /* 外设数据单位 */
    DMA_InitStructure.DMA_PeripheralDataSize=DMA_PeripheralDataSize_Byte;
    /* 内存数据单位 8bit */
    DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_Byte;
    /* DMA 模式：不断循环 */
    DMA_InitStructure.DMA_Mode = DMA_Mode_Circular;
    /* 优先级：中 */
    DMA_InitStructure.DMA_Priority = DMA_Priority_Medium;
    /* 禁用 FIFO */
    DMA_InitStructure.DMA_FIFOMode = DMA_FIFOMode_Disable;
    DMA_InitStructure.DMA_FIFOThreshold = DMA_FIFOThreshold_Full;
    /* 存储器突发传输 16 个节拍 */
    DMA_InitStructure.DMA_MemoryBurst = DMA_MemoryBurst_Single;
    /* 外设突发传输 1 个节拍 */
    DMA_InitStructure.DMA_PeripheralBurst = DMA_PeripheralBurst_Single;
    /* 配置 DMA2 的数据流 7 */
    DMA_Init(DEBUG_USART_DMA_STREAM, &DMA_InitStructure);
    
    /* 使能 DMA */
    DMA_Cmd(DEBUG_USART_DMA_STREAM, ENABLE);
    
    /* 等待 DMA 数据流有效 */
    while (DMA_GetCmdStatus(DEBUG_USART_DMA_STREAM) != ENABLE) {
    }
}
```

主函数

```c
int main(void)
{
    uint16_t i;
    /* 初始化 USART */
    Debug_USART_Config();
    
    /* 配置使用 DMA 模式 */
    USART_DMA_Config();
    
    /* 配置 RGB 彩色灯 */
    LED_GPIO_Config();
    
    printf("\r\n USART1 DMA TX 测试 \r\n");
    
    /*填充将要发送的数据*/
    for (i=0; i<SENDBUFF_SIZE; i++) {
    SendBuff[i] = 'A';
    
    }
    
    /* USART1 向 DMA 发出 TX 请求 */
    USART_DMACmd(DEBUG_USART, USART_DMAReq_Tx, ENABLE);
    
    /* 此时 CPU 是空闲的，可以干其他的事情 */
    //例如同时控制 LED
    while (1) {
        LED1_TOGGLE
        Delay(0xFFFFF);
    }
}
```





