---
author:  "kingtuo123"
title: "Bare metal C"
date: "2022-05-29"
description: "裸机C程序"
summary: "简述了裸机程序从上电开始，是如何进入主程序的"
categories: [ "Embedded" ]
tags: [ "Embedded"]
---

> 翻译自 [From Zero to main(): Bare metal C](https://interrupt.memfault.com/blog/zero-to-main-1)，水平有限仅供参考。

嵌入式开发遵循下列原则：

1. 程序的入口点应命名为 “main”。
2. 你应该初始化静态变量，否则机器会将它们设置为零。
3. 你应该实现中断。其中主要有 HardFault_Handler，还有 SysTick_Handler。

## 准备平台

本文介绍的大多数概念和代码都适用于所有 Cortex-M 系列 MCU，但我们的示例针对的是 Atmel 的 SAMD21G18 处理器，这是一款 Cortex-M0+ 芯片。

本文使用到以下工具：

- Adafruit’s [Metro M0 Express](https://www.adafruit.com/product/3505)  开发板
- 一个 [CMSIS-DAP](https://www.adafruit.com/product/2764) 仿真器
- 用于编程的 OpenOCD ( [Arduino fork](https://github.com/arduino/OpenOCD))

我们将实现一个简单的 LED 闪烁程序，下面是代码：

```C
#include <samd21g18a.h>

#include <port.h>
#include <stdbool.h>
#include <stdint.h>

#define LED_0_PIN PIN_PA17

static void set_output(const uint8_t pin) {
  struct port_config config_port_pin;
  port_get_config_defaults(&config_port_pin);
  config_port_pin.direction = PORT_PIN_DIR_OUTPUT;
  port_pin_set_config(pin, &config_port_pin);
  port_pin_set_output_level(pin, false);
}

int main() {
  set_output(LED_0_PIN);
  while (true) {
    port_pin_toggle_output_level(LED_0_PIN);
    for (volatile int i = 0; i < 100000; ++i) {}
  }
}
```

## 上电

我们是如何进入 main 的？从观察中我们可以看出我们给板子上电后程序开始执行。所以芯片肯定有一套固定的流程来定义代码的执行方式。

确实有！深入研究 [ARMv6-M 技术参考手册](https://static.docs.arm.com/ddi0419/d/DDI0419D_armv6m_arm.pdf)，这是 Cortex-M0+ 的底层架构手册，我们可以找到一些描述复位行为的伪代码：

```C
// B1.5.5 TakeReset()
// ============
TakeReset()
    VTOR = Zeros(32);
    for i = 0 to 12
        R[i] = bits(32) UNKNOWN;
    bits(32) vectortable = VTOR;
    CurrentMode = Mode_Thread;
    LR = bits(32) UNKNOWN; // Value must be initialised by software
    APSR = bits(32) UNKNOWN; // Flags UNPREDICTABLE from reset
    IPSR<5:0> = Zeros(6); // Exception number cleared at reset
    PRIMASK.PM = '0'; // Priority mask cleared at reset
    CONTROL.SPSEL = '0'; // Current stack is Main
    CONTROL.nPRIV = '0'; // Thread is privileged
    ResetSCSRegs(); // Catch-all function for System Control Space reset
    for i = 0 to 511 // All exceptions Inactive
        ExceptionActive[i] = '0';
    ClearEventRegister(); // See WFE instruction for more information
    SP_main = MemA[vectortable,4] AND 0xFFFFFFFC<31:0>;
    SP_process = ((bits(30) UNKNOWN):'00');
    start = MemA[vectortable+4,4]; // Load address of reset routine
    BLXWritePC(start); // Start execution of reset routine

```

简而言之，芯片做了以下工作：

- 将向量表地址重置为 `0x00000000`
- 禁用所有中断
- 从 `0x00000000` 读取堆栈指针（SP）的地址
- 从 `0x00000004` 读取程序计数器（PC）的地址

谜团解开了，看来我们的 main 函数必须在地址 `0x00000004` 处。

> SP 指向栈顶，`0x00000000` 存的是栈顶的地址。
>
> PC 指向下一条指令的地址，`0x00000004` 存的是程序初始入口地址。

我们把 bin 文件 dump 出来，看看在地址 `0x0000000` 和 `0x00000004` 有什么内容：

```text
francois-mba:zero-to-main francois$ xxd build/minimal/minimal.bin  | head
00000000: 0020 0020 c100 0000 b500 0000 bb00 0000  . . ............
00000010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000020: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000030: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000040: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000050: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000060: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000070: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000080: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000090: 0000 0000 0000 0000 0000 0000 0000 0000  ................
```

从上面来看，我们的初始堆栈地址是 `0x20002000` ，程序初始入口地址是 `0x000000c1`

我们再把符号表 dump 出来，看在地址 `0x000000c1` 上是什么：

```text
francois-mba:minimal francois$ arm-none-eabi-objdump -t build/minimal.elf | sort
...
000000b4 g     F .text  00000006 NMI_Handler
000000ba g     F .text  00000006 HardFault_Handler
000000c0 g     F .text  00000088 Reset_Handler
00000148 l     F .text  0000005c system_pinmux_get_group_from_gpio_pin
000001a4 l     F .text  00000020 port_get_group_from_gpio_pin
000001c4 l     F .text  00000022 port_get_config_defaults
000001e6 l     F .text  0000004e port_pin_set_output_level
00000234 l     F .text  00000038 port_pin_toggle_output_level
0000026c l     F .text  00000040 set_output
000002ac g     F .text  0000002c main
...
```

这很奇怪，我们的 main 函数在地址 `0x000002ac` 处。并没有符号对应地址 `0x000000c1` ，但是 `0x000000c0` 处有一个 `Reset_Handler`。

其实，PC 的最低位用来表示 thumb2 指令，它是 ARM 处理器支持的两个指令集之一，所以 `Reset_Handler` 就是我们要找的入口函数。

> 有些ARM处理器即能使用ARM指令，又能兼容Thumb指令，同一个应用程序中可能同时存在ARM指令和Thumb指令，这两者的处理方式肯定是大不相同的，所以为了切换ARM状态和Thumb状态，在跳转到Thumb指令编写的代码块的时候，将程序地址的最低位置1（因为不管是ARM指令还是Thumb指令，都至少是2字节对齐的，所以最低位一定是0，所以最低位可以拿来用于区分ARM状态和Thumb状态），这样处理器识别到最低位为1的话就会切换到Thumb状态，否则则是ARM状态。Thumb2指令集也是为了兼容以前的ARM状态和Thumb状态这样做的。

## 编写一个 Reset_Handler

不幸的是，Reset_Handler 通常是一堆混乱的汇编代码，看这个例子 [nRF52 SDK startup](https://github.com/NordicSemiconductor/nrfx/blob/293f553ed9551c1fdfd05eac48e75bbdeb4e7290/mdk/gcc_startup_nrf52.S#L217) 。与其逐行浏览这个文件，不如看看我们是否可以根据第一原则编写一个最小的 Reset_Handler。

在这里，ARM 的技术参考手册也很有用。 [Cortex-M3 TRM 第 5.9.2](https://developer.arm.com/docs/ddi0337/e/exceptions/resets/intended-boot-up-sequence) 包含下面的表格:

|动作|描述|
|:--|:--|
|初始化变量|任何全局/静态变量都需要被设置。包括初始化 BSS 变量为0，以及将非常量变量的初始化值从 ROM 拷贝到 RAM。|
|设置堆栈|如果用了多个堆栈，那么这些堆栈的 SP 也要初始化。The current SP can also be changed to Process from Main。|
|初始化运行时|可以选择调用 C/C++ 运行时初始化代码以启用堆、浮点或其他功能。这通常由 C/C++ 库中的 __main 完成。|

因此，我们的 ResetHandler 负责初始化静态和全局变量，并启动我们的程序。这反映了 C 标准告诉我们的内容：

> 所有具有静态存储持续时间的对象都应在程序启动之前进行初始化（设置为其初始值）。这种初始化的方式和时间是未指定的。

在实践中，这意味着给定以下代码段：

```C
static uint32_t foo;
static uint32_t bar = 2;
```

我们的 `Reset_Handler` 需要确保 `&foo` 处的内存为 `0x00000000`，`&bar` 处的内存为 `0x00000002`。

我们不能一个一个地初始化每个变量。相反，我们依靠编译器（技术上来讲，是链接器）将所有这些变量放在同一个地方，这样我们就可以一次初始化它们。

对于必须归零的静态变量，链接器为我们提供 _sbss 和 _ebss 作为开始和结束地址。因此我们可以这样做：

```c
/* Clear the zero segment */
for (uint32_t *bss_ptr = &_sbss; bss_ptr < &_ebss;) {
    *bss_ptr++ = 0;
}
```

对于具有初始值的静态变量，链接器为我们提供：

- `_etext` 作为存储初始值的地址（ROM）
- `_sdata` 作为静态变量所在的起始地址（RAM）
- `_edata` 作为静态变量所在的结束地址（RAM）

然后我们可以这样做：

```c
uint32_t *init_values_ptr = &_etext;
uint32_t *data_ptr = &_sdata;
if (init_values_ptr != data_ptr) {
    for (; data_ptr < &_edata;) {
        *data_ptr++ = *init_values_ptr++;
    }
}
```

把它们放在一起，可以编写我们的 Reset_Handler：

```c
void Reset_Handler(void)
{
    /* Copy init values from text to data */
    uint32_t *init_values_ptr = &_etext;
    uint32_t *data_ptr = &_sdata;

    if (init_values_ptr != data_ptr) {
        for (; data_ptr < &_edata;) {
            *data_ptr++ = *init_values_ptr++;
        }
    }

    /* Clear the zero segment */
    for (uint32_t *bss_ptr = &_sbss; bss_ptr < &_ebss;) {
        *bss_ptr++ = 0;
    }
}
```

我们还需要启动我们的主程序！可以通过简单的调用 `main()` 来实现。

```c
void Reset_Handler(void)
{
    /* Copy init values from text to data */
    uint32_t *init_values_ptr = &_etext;
    uint32_t *data_ptr = &_sdata;

    if (init_values_ptr != data_ptr) {
        for (; data_ptr < &_edata;) {
            *data_ptr++ = *init_values_ptr++;
        }
    }

    /* Clear the zero segment */
    for (uint32_t *bss_ptr = &_sbss; bss_ptr < &_ebss;) {
        *bss_ptr++ = 0;
    }

    /* 译者注：这应该是这个芯片的Bug */
    /* 覆盖 NVMCTRL.CTRLB.MANW 位的默认值（勘误参考 13134）*/
    NVMCTRL->CTRLB.bit.MANW = 1;

    /* 切换到主函数 */
    main();

    /* 死循环 */
    while (1);
}
```

你会注意到我们加了两样东西：

1. `main()` 后面有一个死循环，这样一来 main 函数返回的话就不会导致程序跑飞出现意料之外的情况。
2. 处理芯片 `bug` 的最好方法是在我们的主程序启动之前解决它。有时这些方法被包含在一个 `SystemInit` 函数中，该函数在 `main` 之前由 `Reset_Handler` 调用。这是 [Nordic 采用的方法](https://github.com/NordicSemiconductor/nrfx/blob/6f54f689e9555ea18f9aca87caf44a3419e5dd7a/mdk/system_nrf52811.c#L60)。

## 结束

本文的所有代码都可以在这里找到 [Github](https://github.com/memfault/zero-to-main/tree/master/minimal)。

更复杂的程序通常需要更复杂的 `Reset_Handler`。例如：

1. 可重定位代码必须要复制过来
2. 如果我们的程序依赖于 libc，我们必须初始化它
3. 更复杂的内存布局可以添加一些 拷贝/归零 的循环

我们将在以后的文章中介绍所有这些。但在此之前，我们将在下一篇文章中讨论神奇的内存区域变量是如何产生的，我们的 `Reset_Handler` 的地址为什么是 `0x00000004` ，以及如何编写链接器脚本文件！
