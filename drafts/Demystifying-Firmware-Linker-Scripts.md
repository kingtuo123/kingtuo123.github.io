---
title: "Demystifying Firmware Linker Scripts"
date: "2022-05-30"
description: "揭秘链接器脚本"
summary: "简述链接器做了哪些工作、链接器脚本的语法及如何编写"
categories: [ "Embedded" ]
tags: [ "Embedded" ]
---

> 翻译自 [Demystifying Firmware Linker Scripts](https://interrupt.memfault.com/blog/how-to-write-linker-scripts-for-firmware)，水平有限仅供参考。



[上一篇文章](https://kingtuo123.com/posts/bare-metal-c/) ，我们谈到了在调用我们的主函数之前，在 MCU 上引导 C 环境。我们认为理所当然的一件事是函数和数据都被存储在二进制文件中的正确位置。今天，我们将通过学习内存区域和链接器脚本来深入了解这是如何发生的。

你可能还记得以下自动发生的事情：

- 我们使用了 `&_ebss ` 、`&_sdata` 等变量，知道了每个部分在 flash 中的位置，并定义一些变量在 RAM 中的位置。
- MCU 在地址 `0x00000004` 找到了指向我们的 `ResetHandler` 的指针地址。

你会发现一些 MCU 有不同的内存映射，一些启动脚本以不同的方式命名这些变量，而一些程序有或多或少的段。  由于它们不是标准化的，因此需要在我们工程的某个地方指定这些内容。在工程使用类似 Unix-ld 工具链接的情况下，我们就需要链接器脚本。



## 链接简介

链接是编译程序的最后一个阶段。它需要许多已编译的目标文件并将它们合并到一个程序中，并填写地址，以便一切都在正确的位置。

下面的例子中，让我们来看看 main 函数发生了什么，先用编译器生成目标文件：

```text
$ arm-none-eabi-gcc -c -o build/objs/a/b/c/minimal.o minimal.c <CFLAGS>
```

把符号 dump 出来：

```text
$ arm-none-eabi-nm build/objs/a/b/c/minimal.o
...
00000000 T main
...
```

正如预期的那样，它还没有地址。然后，我们将链接所有内容：

```text
$ arm-none-eabi-gcc <LDFLAGS> build/objs/a/b/c/minimal.o <other object files> -o build/minimal.elf
```

我们再把 elf 文件的符号 dump 出来：

```text
$ arm-none-eabi-nm build/minimal.elf
...
00000294 T main
...
```

链接器已经完成了它的工作，我们的主函数已经被分配了一个地址。

链接器的作用通常不止于此。例如，它可以生成调试信息、垃圾收集未使用的代码部分或运行整个程序优化（也称为链接时间优化或 LTO）。 有关链接器的更多信息，请参阅 [Stack Overflow](https://stackoverflow.com/questions/3322911/what-do-linkers-do) 上的一个很棒的帖子。



## 链接器脚本解析

链接描述文件包含四个内容：      

- Memory layout：什么内存在哪里可用     
- Section definitions：程序的哪个部分应该放在哪里     
- Options：用于指定架构、入口点等的命令。如果需要的话     
- Symbols：在链接时注入程序的变量

### Memory Layout

为了分配程序空间，链接器需要知道有多少内存可用，以及该内存所在的地址。这就是链接描述文件中的 MEMORY 定义的用途。

MEMORY 的语法在 [binutils](https://sourceware.org/binutils/docs/ld/MEMORY.html#MEMORY) 文档中定义，如下所示：

```text
MEMORY
  {
    name [(attr)] : ORIGIN = origin, LENGTH = len
    ...
  }
```

- name 是用于这个区域的名称，名称没有意义，可任意命名。
- attr 是可选属性，例如这个区域是可读（r），可写（w），可执行（x）。flash 一般是（rx），ram 是（rwx）。将区域标记为不可写并不会使其写保护，这些属性旨在描述内存的属性，而不是设置它。
- origin 是内存区域的起始地址。
- len 是内存区域的大小，以字节为单位。

SAMD21G18 芯片的内存映射表如下：

|内存|起始地址|大小|
|:-|:-|:-|
|内部 Flash|0x00000000|256 Kbytes|
|内部 SRAM|0x20000000|32 Kbytes|

写成 MEMORY 定义，如下：

```text
MEMORY
{
  rom      (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
  ram      (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00008000
}
```

## Section Definitions

code 和 data 都被打包进 sections，它在内存中是一块连续的地址。没有硬性规定应该有多少 sections 或存放哪些 symbols。以下两种情况通常会把 symbols 放到同一 section 中：

1. 它们应该在同一个内存区域
2. 它们需要一起初始化

在上一篇文章中，我们了解了两种批量初始化的符号：

1. 必须从 flash 复制的初始化静态变量
2. 必须归零的未初始化静态变量

我们的链接器脚本涉及到的另外两样东西：

1. 代码和常量数据，可以存在于只读存储器（例如flash）
2. RAM 的保留部分，如栈或堆

按照惯例，我们将这些部分命名如下：

1. `.text` 代码和常量
2. `.bss` 未初始化的数据
3. `.stack` 栈
4. `.data` 已初始化的数据

 [elf spec](http://refspecs.linuxbase.org/elf/elf.pdf) 有完整的变量列表。你可以给它们起别的名字，即使固件能正常运行但不能保证某些工具在使用到这个固件时不会出现奇怪的错误。唯一不能用作命名的是 `/DISCARD/` ，这是一个保留的关键字。

首先，让我们看看如果我们不在链接描述文件中定义任何这些部分，我们的符号会发生什么。

```text
MEMORY
{
  rom      (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
  ram      (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00008000
}

SECTIONS
{
    /* empty! */
}
```

使用 objdump 查看生成的 elf 文件，我们看到以下内容：

```text
$ arm-none-eabi-objdump -h build/minimal.elf
build/minimal.elf:     file format elf32-littlearm

SYMBOL TABLE:
no symbols
```

没有符号！虽然链接器能在几乎没有信息的情况下链接，但它至少需要知道入口点应该是什么，或者在 text section 中放置什么符号。

### .text Section

让我们从添加 `.text` section 开始。我们想让这个 section 在 ROM 中。下面是语法：

```text
SECTIONS
{
    .text :
    {

    } > rom
}
```

上面定义了一个名为 `.text` 的 section，并将其添加到 ROM。然后我们需要告诉连链接器需要在 section 中添加什么。

为了找出我们目标文件中有哪些 section。我们再 objdump 一次：

```text
$ arm-none-eabi-objdump -h
build/objs/a/b/c/minimal.o:     file format elf32-littlearm

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00000000  00000000  00000000  00000034  2**1                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .data         00000000  00000000  00000000  00000034  2**0                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000000  00000000  00000000  00000034  2**0                  ALLOC
  3 .bss.cpu_irq_critical_section_counter 00000004  00000000  00000000  00000034  2**2                  ALLOC
  4 .bss.cpu_irq_prev_interrupt_state 00000001  00000000  00000000  00000034  2**0                  ALLOC
  5 .text.system_pinmux_get_group_from_gpio_pin 0000005c  00000000  00000000  00000034  2**2                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  6 .text.port_get_group_from_gpio_pin 00000020  00000000  00000000  00000090  2**1                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  7 .text.port_get_config_defaults 00000022  00000000  00000000  000000b0  2**1                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  8 .text.port_pin_set_output_level 0000004e  00000000  00000000  000000d2  2**1                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  9 .text.port_pin_toggle_output_level 00000038  00000000  00000000  00000120  2**1                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
 10 .text.set_output 00000040  00000000  00000000  00000158  2**1                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
 11 .text.main    0000002c  00000000  00000000  00000198  2**2                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
```

我们看到每一个符号都有一个 section。这是因为我们在编译时指定了 `-ffucntion-sections` 和 `-fdata-sections` 标志。如果我们没有包含这些标志，编译器可以将多个函数包含进一个 section 中去。

在我们的链接器脚本中要将所有函数都放到 `.text` 中，我们可以按以下语法：

```
<filename>(<section>)
```

`filename` 是包含我们所需符号的输入文件的名称，`section` 就是该文件中包含的 section 的名称。如果我们想要取一个文件中所有的 `.text` section，我们可以使用 `*` 通配符：

```text
.text :
{
    KEEP(*(.vector*))
    *(.text*)
} > rom
```

这里注意 `.vector` section，它是入口函数 `Reset_Handler` 所在的 section，我们需要把它放在最前面。

> KEEP( ) 函数告诉链接器不要把 .vector section 当作垃圾回收。因为 Reset_Handler 是入口函数，我们没有在程序的任何地方调用它，链接器会把没有被调用的函数当作垃圾处理以减少最后生成文件的体积。

编译后，我们 dump 下 elf 文件，可以看到如下：

```text
$ arm-none-eabi-objdump -t build/minimal.elf

build/minimal.elf:     file format elf32-littlearm

SYMBOL TABLE:
00000000 l    d  .text  00000000 .text
...
00000000 l    df *ABS*  00000000 minimal.c
00000000 l     F .text  0000005c system_pinmux_get_group_from_gpio_pin
0000005c l     F .text  00000020 port_get_group_from_gpio_pin
0000007c l     F .text  00000022 port_get_config_defaults
0000009e l     F .text  0000004e port_pin_set_output_level
000000ec l     F .text  00000038 port_pin_toggle_output_level
00000124 l     F .text  00000040 set_output
00000000 l    df *ABS*  00000000 port.c
00000190 l     F .text  00000028 system_pinmux_get_config_defaults
00000000 l    df *ABS*  00000000 pinmux.c
00000208 l     F .text  0000005c system_pinmux_get_group_from_gpio_pin
00000264 l     F .text  00000110 _system_pinmux_config
00000164 g     F .text  0000002c main
000001b8 g     F .text  0000004e port_pin_set_config
00000374 g     F .text  00000040 system_pinmux_pin_set_config
...
```

### .bss Section

`.bss` 段存放的是未初始化的变量，如下：

```text
SECTION {
    ...
    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > ram
}
```

注意 `*(COMMON)` ，这是一个特殊的段名，用来表示未初始化的全局变量。例如 `int foo` 就会在这个段中，`static int foo` 则不会。如果它们具有相同的名称，这允许链接器将多个定义合并到一个符号中。

这里还使用了 `NOLOAD` 属性标记该段不可加载，这样当程序运行时它就不会被加载到内存中。

> 在符号表中，未初始化的局部静态变量，初始化为0的全局变量及局部静态变量都wei会被表示在bss段。但是未初始化的全局变量会表示为COMMON，也相当于在bss段，但COMMON有特殊含义。未初始化的局部静态变量由于是仅编译单元内可见，不需要导出符号。所以不用置为COMMON，直接标识为bss段。

### .stack Section

`.stack` 同样不用加载到内存中，由于堆栈不包含符号，我们需要显示的指示其大小为其保留空间。我们还必须按照 ARM 过程调用标准 [AAPCS](https://static.docs.arm.com/ddi0403/ec/DDI0403E_c_armv7m_arm.pdf) 在8字节边界上对齐堆栈。

为了实现这些目标，我们使用一个特殊的变量 `.`，也称为“位置计数器”。位置计数器表示当前所在位置的地址。随着段的添加，位置计数器也会相应增加。你可以通过向前设置位置计数器来强制对齐或间隙。

```text
STACK_SIZE = 0x2000; /* 8 kB */

SECTION {
    ...
    .stack (NOLOAD) :
    {
        . = ALIGN(8);
        . = . + STACK_SIZE;
        . = ALIGN(8);
    } > ram
    ...
}
```

### .data Section

.data 部分包含在启动时具有初始值的静态变量。您会记得我们之前的文章中，由于断电时 RAM 不会保持不变，因此需要从 flash 加载这些部分。在启动时，Reset_Handler 在调用 main 函数之前将数据从 flash 复制到 RAM。

为了实现这一点，我们的链接脚本中的每个部分都有两个地址，加载地址 (LMA) 和虚拟地址 (VMA)。LMA 是在ROM 中的地址，VMA 是在 RAM 中的地址。我们生成的 bin 烧录文件，它的数据顺序就是我们在链接脚本中定义的这些 sections 的顺序，bin 文件烧录到 flash 中后的顺序也是一样的，当程序运行时，我们需要把数据从 flash 拷贝到栈中，栈所在的地址就是 VMA，flash 中的地址就是 LMA。

使用 `AT` 指定加载地址：

```text
.data :
{
    *(.data*);
} > ram AT > rom  /* "> ram" is the VMA, "> rom" is the LMA */
```

还可以显式指定一个地址，如下：

```text
.data 0x2000 : AT(0x4000)
{
    . = ALIGN(4);
    _sdata = .;
    *(.data*);
    . = ALIGN(4);
    _edata = .;
}
```

> 通常情况下从 Flash 执行的程序，text 段 VMA 和 LMA 是一样的。data 段的VMA会放在 RAM 中，LMA 会放在 flash 中，所以 data 段的 VMA 和 LMA 通常不一样。

## 完整的链接器脚本

```text
MEMORY
{
  rom      (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
  ram      (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00008000
}

STACK_SIZE = 0x2000;

/* Section Definitions */
SECTIONS
{
    .text :
    {
        KEEP(*(.vectors .vectors.*))
        *(.text*)
        *(.rodata*)
    } > rom

    /* .bss section which is used for uninitialized data */
    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > ram

    .data :
    {
        *(.data*);
    } > ram AT >rom

    /* stack section */
    .stack (NOLOAD):
    {
        . = ALIGN(8);
        . = . + STACK_SIZE;
        . = ALIGN(8);
    } > ram

    _end = . ;
}
```

你可以在这里找到链接器脚本的详细语法 [ld manual](https://sourceware.org/binutils/docs/ld/SECTIONS.html#SECTIONS)。

## 变量

在上一篇文章中，我们依靠变量获取每个 section 的地址。

为了能在程序中调用这些变量，链接器会生成符号并将他们添加进程序中。你可以在 [linker documentation](https://sourceware.org/binutils/docs/ld/Simple-Assignments.html#Simple-Assignments) 找到相关的语法。类似C语言的变量定义：`symbol = expression`

本例中，我们需要：

1. `_etext` ： `.text` 段结束地址
2. `_sdata` ： `.data` 段起始地址
3. `_edata` ： `.data` 段结束地址
4. `_sbss` ： `.bss` 段起始地址
5. `_ebss` ： `.bss` 段结束地址

我们可以在每个 section 的开头和结尾使用位置计数器 `.` 定义变量：

```text
.text :
    {
        KEEP(*(.vectors .vectors.*))
        *(.text.*)
        *(.rodata.*)
        _etext = .;
    } > rom

    .bss (NOLOAD) :
    {
        _sbss = . ;
        *(.bss .bss.*)
        *(COMMON)
        _ebss = . ;
    } > ram

    .data :
    {
        _sdata = .;
        *(.data*);
        _edata = .;
    } > ram AT >rom
```

在程序中必须使用对这些变量的引用，而不是变量本身。例如，以下代码为我们提供了一个指向 .data 段起始位置的指针：

```C
uint8_t *data_byte = &_sdata;
```

你可以在这里了解更多细节 [binutils docs](https://sourceware.org/binutils/docs/ld/Source-Code-Reference.html) 。