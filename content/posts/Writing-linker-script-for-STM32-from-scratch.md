---
author:  "kingtuo123"
title: "Writing linker script for STM32 from scratch"
date: "2022-06-01"
description: "从零开始编写stm32链接脚本"
summary: "从零开始编写stm32链接脚本"
categories: [ "Embedded" ]
tags: [ "Embedded"]
---

> 本文翻译自 [Writing linker script for STM32 from scratch](https://itachi.pl/hardware/writing_linker_script_for_stm32_from_scratch)
> 水平有限仅供参考

本文将解释三件事：

- 如何从零编写一个简单的链接器脚本
- 在stm32上实现应用（本文是STM32F103RBT6）
- 如何避免使用厂商提供的头文件，代码等

这个话题对我来说也是刚接触到的。因为我之前一直都在使用厂商提供的脚本，直到昨天我决定自己实现这个脚本。有部分原因是我想锻炼我的脑子，但主要还是为了学习新的知识。本文将一步步引导你从创建最简单、甚至简陋的链接器脚本开始，直至一个成熟且完善的脚本。

我决心要研究单片机的链接器脚本是因为这能让你对底层有更深入的理解，使你有能力在单片机上完成更多的操作。你需要了解内存地址、在内存的哪个地方又要放入什么数据。不过别担心，下面我会一一解释。

## 准备工具

你只需要两件事即可开始：ARM 工具链和你最喜欢的文本编辑器。最新的 ARM 工具链可以直接从 [ARM 官网](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)下载。

如果你很幸运并且在 Mac 或 Linux 上工作，你可以简单地将工具链提解压到任何地方并将其添加到 shell 的路径中：

```text
$ export PATH=/your/toolchain/bin:$PATH
```
现在你应该能够执行工具链的所有工具，前缀为：`arm-none-eabi-`

## 预备知识

在开始之前，我们还需要了解一些知识：目标设备的内存布局。如果你不知道将代码、变量放到哪里，就无发编写链接脚本。不同的架构、设备之间的内存布局是不同的，因此你必须查看数据手册找到相应的信息。以STM32F103RBT6为例，可以在参考手册的第 53 页（SRAM）和第 54 页（Flash）中找到：

- SRAM 起始地址是 0x2000 0000
- Flash 起始地址是 0x0800 0000

这意味着你需要将代码放到地址 0x0800 0000 处，所有的变量要放到 0x2000 0000 处。别担心，后面我会解释。

差点忘了，你还需要了解 MCU 是如何启动的。大多数情况下，在芯片启动时需要设置堆栈指针，不同架构的平台方法也不同。步骤很简单：找到存储堆栈地址的位置，将该地址设置为栈顶地址。逻辑上来说，栈空间是从上往下增长的，所以它需要足够的空间（指定大小）。

如果你看下手册第61页，上面有STM32 如何启动以及它如何设置堆栈指针的详细描述：

> 上电后，CPU 从地址 0x0000 0000 获取栈顶地址，然后从 0x0000 0004 开始的引导存储器开始执行代码。

记下重点：

- Stack initializer：0x0000 0000
- Entry point：0x0000 0004

关于 STM32 你还需了解重要的一点是：这在文档61页也有说明，当 CPU 从地址 0x00000000 读取数据，它实际上可能会访问不同的存储器，具体取决于所选的引导模式。这称为“内存映射”。默认情况下，STM32 从 flash 启动，所以它将内存区域 0x08000000 映射到 0x00000000；然后就可以从其原始地址或 0x00000000 访问 flash。这允许 CPU 直接从 flash 开始读取指令。

记住以上信息，并且知道我们想从 flash 启动，我们已经可以为堆栈初始化程序和入口点计算适当的地址：

- Stack initializer：0x0800 0000
- Entry point：0x0800 0004

>其实上面的文档有一点误导。Entry point 并不是程序真正开始执行的地方。实际上，这里存储着起始代码的所在地址，从这个地址跳到代码所在位置开始执行。换句话说，0x00000000 中的值会被加载到 SP 寄存器，0x00000004 中的值会被加载到 PC 寄存器。

## 开始编写

### 最简单的链接脚本

链接描述文件可以由一个称为 `SECTIONS` 的块组成。在此块中，你定义的段将被分配到二进制文件中。最重要的段是：

- `.test` - 包含你的代码
- `.data` - 包含已初始化的全局/静态变量
-  `.bss` - 包含未初始化的全局/静态变量

我们的第一个脚本，将只使用 `.text` 。没有数据，没有变量，只有纯代码。我们创建一个 script.ld 文件，写入下面的内容：

```text
SECTIONS
{
  .text : { *(.text) }
}
```

上面的脚本告诉链接器：

1. 创建一个 `.text` 段（表达式最左边的部分）
2. 获取目标文件中所有的 `.text` 段（花括号中的表达式）
3. 把第2步或取的段放到第1步创建的段中

这很简单，不是吗？但是我们缺少一些东西，甚至是一些东西。我们定义了代码部分，但我们没有指定它应该放在哪里。在当前的脚本中，代码将被放置在地址 0x0，但根据我们之前讲述的内容，它应该被加载到地址 0x08000000，对吧？没错，让我们来解决这个问题：

```text
SECTIONS
{
  . = 0x08000000;
  .text : { *(.text) }
}
```

链接脚本中的 `.` 是位置计数器。它从 0x0 开始，可以直接修改，如上所示。也可以通过添加段、常量等间接修改。因此，如果你在 `text` 段之后读取位置计数器的值，它的值将是 0x08000000 加上你添加的段的大小。如果你不以其他方法指定段的地址（其他方法在后面会讲到），那么该段的地址将会从当前位置计数器的地址开始。

好了，我们代码有了一个正确的位置。接下来只要知道入口程序地址以及堆栈地址：

```text
ENTRY(main);
 
SECTIONS
{
  . = 0x08000000;
  LONG(0x20005000);
  LONG(main | 1);
  .text : { *(.text) }
}
```

我想我欠你一个解释。

如果你还记得，当 STM32 启动时，它会从 flash 读取两个双字。第一个是栈顶地址，第二个是入口程序地址。`LONG(0x20005000)` 告诉链接器将这四个字节放入输出的二进制文件中。为什么是这四个字节？因为STM32 SRAM 地址从 0x20000000 开始，大小有 20kb（0x5000）。 `0x20000000 + 0x5000 = 0x20005000` 就是栈顶的地址。

第二条表达式 `LONG(main | 1);` 将 main 函数的地址输出到二进制文件中。如你所见，main 与 1 做了或运算生成一个奇数值。在 ARM 体系结构中，函数地址是奇数（最后一位是1）告诉 CPU 切换到 thumb 模式，而不是表示 ARM 模式的偶数地址。

> Not all branch instructions causes mode switch. `B` or `BL` only branches; `BX` branches with mode switch accordingly to the last bit of an address; `BLX` branches and always switches the mode. You can read more on the [dedicated page](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0204j/Cihfddaf.htmlm).

STM32F103RBT6 基于仅支持 Thumb 指令的 Cortex-M3，这就是我们在开始时告诉它切换到 Thumb  模式的原因。这通常对开发人员是透明的，编译器要么使用 BL  指令保持当前模式，要么自动修复调用地址。我们在这里手动执行此操作的原因是因为我们创建了链接脚本。

我还添加了另一个新东西：`ENTRY(main)`。这告诉链接器应该使用哪个符号作为程序的入口点。这也可以防止包含 `main` 函数的 `.text` 部分被链接器作为垃圾收集。

好了，我们有一个链接器脚本，这很好，但我们还需要有一些东西可以链接。让我们创建一个简单的代码来点亮 Nucleo 板上的绿色 LED：

```c
#include "registers.h"
     
void main(void) {
    RCC->APB2ENR |= (1 << RCC_APB2ENR_IOPAEN);
    GPIOA->CRL |= (0b10 << GPIOA_CRL_MODE5);
    GPIOA->CRL &= ~(0b11 << GPIOA_CRL_CNF5);
    GPIOA->BSRR = (1 << 5);
     
    while (1);
}
```

`registers.h` 文件是一个包含寄存器地址的头文件。我是根据参考手册中的信息创建的。我只是为每组寄存器定义了一个结构体，然后使用基地址定义了一个指向该结构的指针。多亏了结构体，我不需要手动执行指针运算，因为它是在访问结构体的字段时自动完成的：

```c
#ifndef LINKER_TUTORIAL_REGISTERS_H
#define LINKER_TUTORIAL_REGISTERS_H
     
#include <stdint.h>
     
typedef struct {
    uint32_t CR;
    uint32_t CFGR;
    uint32_t CIR;
    uint32_t APB2RSTR;
    uint32_t APB1RSTR;
    uint32_t AHBENR;
    uint32_t APB2ENR;
    uint32_t APB1ENR;
    uint32_t BDCR;
    uint32_t CSR;
} RCC_Reg;
#define RCC ((RCC_Reg*) 0x40021000)
#define RCC_APB2ENR_IOPAEN 2
     
typedef struct {
    uint32_t CRL;
    uint32_t CRH;
    uint32_t IDR;
    uint32_t ODR;
    uint32_t BSRR;
    uint32_t BRR;
    uint32_t LCKR;
} GPIOA_Reg;
#define GPIOA ((GPIOA_Reg*) 0x40010800)
#define GPIOA_CRL_MODE5 20
#define GPIOA_CRL_CNF5 22
     
#endif //LINKER_TUTORIAL_REGISTERS_H
```

就这样！由于没有配置时钟源，STM32 将使用内部 8 MHz RC 振荡器，这对于这个简单的项目来说绰绰有余。让我们编译并链接它：

```text
$ arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -Tscript.ld -Wl,--gc-sections -Os main.c
```

为了编译和链接，我将 CPU 类型设置为 Cortex-M3，指令设置为  Thumb，我选择了链接器脚本，告诉链接器删除未使用的部分并设置代码大小优化。如果一切顺利，固件文件将创建为 a.out。此文件为 ELF  格式，不能直接用于 MCU，你需要将其转换为 Intel HEX。这可以使用以下命令轻松完成：

```text
$ arm-none-eabi-objcopy -O ihex a.out fw.hex
```

查看 `fw.hex` 文件的前两行：

```hex
: 02 0000 04 0800 F2
: 08 0000 00 0050002011000008 71
```

第一个是 04 记录（扩展线性地址），这意味着它为接下来的 00 记录设置起始地址。如你所见，地址是 0800，看起来很眼熟吧？如果将其扩展到 32 位（这就是扩展线性地址的工作方式），你将得到：0x08000000。这是我们的 flash 地址！

下一条记录的类型是 00，表示数据。这正是将加载到 flash 的内容。该行指示程序员在先前设置的地址 + 0x0000 偏移处闪存 8  个字节。让我们将数据从小端转换为大端：20005000 08000011。第一个是初始堆栈指针，第二个可能是 main 函数的地址！让我们再执行一个命令：

```text
$ arm-none-eabi-objdump -D a.out
```

如果将输出滚动到顶部，你应该会看到如下内容：

```text
08000010 <main>:
 8000010: 4a07    ldr r2, [pc, #28] ; (8000030 <main+0x20>)
```

main 函数的实际地址在 0x08000010 处，记得我们之前对它进行或运算吗，main 函数的实际地址并未改变，只是调用方式不同。

代码成功编译，堆栈指针和入口点地址位于有效位置，一切看起来都很有希望。烧录到开发板上！它在我的板上工作得很好，绿色 LED 按预期亮起。

**注意事项：**

我们编写的脚本虽然能正常工作，但我们无法修改全局或静态变量。因为我们没有在脚本中定义 `.data` 段，链接器会把这些全局/静态变量都放到 `.text` 段后面。因此它们是可读不可写的。

```text
Disassembly of section .data:

08000058 <a>:
 8000058:	deadbeef 	cdple	14, 10, cr11, cr13, cr15, {7}
```

我另外添加了一个全局变量：`int a =  0xDEADBEEF`，然后使用我们的脚本编译/链接。如你所见，该变量确实存在于 flash 中。局部变量不会受到影响，它们被放置在堆栈上，因此只要你不使用全局或静态变量，此链接器脚本就可以为你工作。如果你需要更复杂的东西，请继续阅读。

### MEMORY

在前面的示例中，我们使用的位置计数器来设置 `.text` 段的起始地址。对于简单的脚本来说，这就足够了，但是随着我们添加更多的内存区域，它会变得一团糟。仅使用位置计数器我们将自己限制在非常基本的配置上，我们很快就会碰壁。

在链接脚本中，我们可以定义一个且只有一个名为 MEMORY  的块。在这个块中，我们列出了我们常用的内存区域。我们在那里定义的区域不需要准确地反映 MCU 的内存布局，但是它们之间存在很强的相关性。 MEMORY 块仅用于链接器，它不会以任何方式影响目标设备。

那么，我们应该在这个块中定义哪些区域？这很明显：flash 和 SRAM：

```text
MEMORY {
  flash   (RX) : ORIGIN = 0x08000000, LENGTH = 128K
  sram    (RW) : ORIGIN = 0x20000000, LENGTH = 20K
}
 
ENTRY(main);
 
SECTIONS
{
  . = 0x08000000;
  LONG(0x20005000);
  LONG(main | 1);
  .text : { *(.text) }
}
```

`MEMORY` 语法：

- `flash` 表示该区域的名称
- `(RX)` 表示读/写/执行属性
- `ORIGIN` 表示该区域起始地址
- `LENGTH` 表示该区域大小

现在是时候稍微重新组织一下脚本了：

```text
MEMORY {
  flash   (RX) : ORIGIN = 0x08000000, LENGTH = 128K
  sram    (RW) : ORIGIN = 0x20000000, LENGTH = 20K
}
 
ENTRY(main);
 
SECTIONS
{
  .text :
  {
    LONG(0x20005000);
    LONG(main | 1);
    *(.text) 
  } > flash
}
```

上面做了一些改动：

- 删除了位置计数器
- 把堆栈指针和入口点移动到 `.text` 段
- 告诉链接器把这段放到 flash 中去： `> flash`

我们还需要对 SRAM 存储器做一些事情。当我们创建脚本时，变量被放置在 flash 中，因为链接器不知道其他内存区域的存在。现在，我们终于可以放置变量了：

```text
MEMORY {
  flash   (RX) : ORIGIN = 0x08000000, LENGTH = 128K
  sram    (RW) : ORIGIN = 0x20000000, LENGTH = 20K
}
 
ENTRY(main);
 
SECTIONS
{
  .text :
  {
    LONG(0x20005000);
    LONG(main | 1);
    *(.text) 
  } > flash
  .data :
  {
    *(.data)
  } > sram
}
```

如上，我们简单地定义了一个新的段：`.data`，它将包括所有目标文件中的所有 `.data` 节，并将被放置在 SRAM 内存中。为了查看链接器现在将把全局变量放在哪里，我添加了一个：`int a = 0xDEADBEEF`。让我们 dump 看看:

```text
Disassembly of section .data:

20000000 <a>:
20000000:	deadbeef 	cdple	14, 10, cr11, cr13, cr15, {7}
```

这看起来不错！这一次，全局变量被放置在 SRAM 内存中，它既可以被读取也可以被写入。我们也来看看 Intel HEX 文件的最后几行（在做 objcopy 之后）：

```text
:02 0000 04 2000 DA
:04 0000 00 EFBEADDE C4
```

第一条记录告诉编程器将编程地址设置为 `0x20000000`，下一行告诉它在那里写入 `0xDEADBEEF`。看起来不错？嗯……不。你在这里尝试做的是将数据写入到 SRAM，这是不可能的。即使它可行，所有数据都会在第一次断电后消失。



**结束，未完**