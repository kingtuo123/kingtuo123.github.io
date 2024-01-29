---
title: "STM32 移植 FreeRTOS"
date: "2023-08-17"
description: ""
summary: "real-time operating system 微控制器实时操作系统"
categories: [ "stm32", "freertos" ]
tags: [ "" ]
---

参考文章
- [FreeRTOS 官方入门指南](https://freertos.org/zh-cn-cmn-s/FreeRTOS-quick-start-guide.html)
- [韦东山 FreeRTOS 系列教程](https://blog.csdn.net/thisway_diy/article/details/121398500)
- [FreeRTOS任务调度](https://zhuanlan.zhihu.com/p/554825433)
- [本文 Demo 下载](https://github.com/kingtuo123/stm32f103x-template)（STM32F103ZET6）

## 目录结构

```bash
.
├───FreeRTOS
│   └── Source
│       ├── include
│       │   ├── atomic.h
│       │   ├── croutine.h
│       │   ├── deprecated_definitions.h
│       │   ├── event_groups.h
│       │   ├── FreeRTOS.h
│       │   ├── list.h
│       │   ├── message_buffer.h
│       │   ├── mpu_prototypes.h
│       │   ├── mpu_wrappers.h
│       │   ├── portable.h
│       │   ├── projdefs.h
│       │   ├── queue.h
│       │   ├── semphr.h
│       │   ├── stack_macros.h
│       │   ├── StackMacros.h
│       │   ├── stdint.readme
│       │   ├── stream_buffer.h
│       │   ├── task.h
│       │   └── timers.h
│       ├── portable
│       │   ├── GCC
│       │   │   └── ARM_CM3
│       │   │       ├── port.c
│       │   │       └── portmacro.h
│       │   └── MemMang
│       │       ├── heap_1.c
│       │       ├── heap_2.c
│       │       ├── heap_3.c
│       │       ├── heap_4.c
│       │       └── heap_5.c
│       ├── croutine.c
│       ├── list.c
│       ├── event_groups.c
│       ├── queue.c
│       ├── sbom.spdx
│       ├── stream_buffer.c
│       ├── tasks.c
│       └── timers.c
├── Libraries
│   ├── CMSIS
│   └── STM32F10x_StdPeriph_Driver
├── makefile
├── STM32F103ZETx_FLASH.ld
└── User
    ├── led
    │   ├── bsp_led.c
    │   └── bsp_led.h
    ├── FreeRTOSConfig.h
    ├── main.c
    ├── stm32f10x_conf.h
    ├── stm32f10x_it.c
    └── stm32f10x_it.h
```

- `FreeRTOS` 从官方源码包（最新版，非 LTS）中直接拷贝，内部目录不作调整

- `Libraries` 从 ST 标准库直接拷贝，内部目录不作调整

- `User` 用户代码目录

## makefile 配置

这里只看一下必要的 FreeRTOS 源码路径，完整 makefile 看 Demo ：

```makefile
# 内核头文件
INC_DIR += ./FreeRTOS/Source/include/
# 移植用的相关的头文件
INC_DIR += ./FreeRTOS/Source/portable/GCC/ARM_CM3/

# 内核核心源码
C_SRC   += $(wildcard ./FreeRTOS/Source/*.c)
# 移植用的相关文件，根据你的编译器和芯片架构选择
C_SRC   += ./FreeRTOS/Source/portable/GCC/ARM_CM3/port.c
# 内存管理相关文件
C_SRC   += ./FreeRTOS/Source/portable/MemMang/heap_4.c
```

MemMang 目录下的 heap 文件主要是 FreeRTOS 的内存管理单元，常用的是 `heap_4.c`

|文件|优点|缺点|
|:--|:--|:--|
|heap_1.c|分配简单，时间确定|只分配、不回收|
|heap_2.c|动态分配、最佳匹配|碎片、时间不定|
|heap_3.c|调用标准库函数|速度慢、时间不定|
|heap_4.c|相邻空闲内存可合并|可解决碎片问题、时间不定|
|heap_5.c|在heap_4基础上支持分隔的内存块|可解决碎片问题、时间不定|

> 官方关于内存管理的说明：[Memory Management](https://freertos.org/a00111.html)

## 其他设置

FreeRTOSConfig.h ：FreeRTOS 内核配置文件（功能配置，裁剪等）


从 `./FreeRTOS/Demo/CORTEX_STM32F103_GCC_Rowley/FreeRTOSConfig.h` 复制一份

添加以下内容：

```c
// 用于启动第一个任务的中断
# define  xPortPendSVHandler    PendSV_Handler
// 用于每次任务切换中断
#define  xPortSysTickHandler    SysTick_Handler
// 定时器回调函数
#define  vPortSVCHandler        SVC_Handler
```

以上是 FreeRTOS 内核实现任务调度的核心函数，需要替换掉自带的，然后在 `stm32f10x_it.c` 中把这 3 个中断函数注释掉

方法二：也可以在启动文件的中断向量表中把对应的函数替换掉，就无需上面步骤

```asm {hl_lines=[13,16,17]}
g_pfnVectors:
  .word  _estack
  .word  Reset_Handler
  .word  NMI_Handler
  .word  HardFault_Handler
  .word  MemManage_Handler
  .word  BusFault_Handler
  .word  UsageFault_Handler
  .word  0
  .word  0
  .word  0
  .word  0
  .word  SVC_Handler
  .word  DebugMon_Handler
  .word  0
  .word  PendSV_Handler
  .word  SysTick_Handler
  .word  WWDG_IRQHandler
```

## 测试

LED 不间断交替闪烁：

```c
#include "stm32f10x.h"
#include "bsp_led.h"
#include "FreeRTOS.h"
#include "task.h"


void SetSysClockTo72(void);
void task0(void *param);
void task1(void *param);


int main(void){
	SetSysClockTo72();
	LED_Init();

	xTaskCreate(task0, "task0", 128, NULL, 1, NULL);
	xTaskCreate(task1, "task1", 128, NULL, 1, NULL);
	vTaskStartScheduler();

	while(1){
	}
}


void task0(void *param){
	while(1){
		LED1_ON();
		vTaskDelay(1000);
		LED1_OFF();
		vTaskDelay(1000);
	}
}


void task1(void *param){
	while(1){
		LED2_OFF();
		vTaskDelay(1000);
		LED2_ON();
		vTaskDelay(1000);
	}
}
```
