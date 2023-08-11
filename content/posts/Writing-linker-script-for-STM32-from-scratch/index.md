---
title: "从零编写 STM32 链接脚本"
date: "2022-06-01"
description: ""
summary: ""
categories: [ "stm32" ]
tags: [ "stm32"]
---


- 参考文章：
  - [Writing linker script for STM32 from scratch](https://itachi.pl/hardware/writing_linker_script_for_stm32_from_scratch)
  - [链接脚本(Linker Scripts)语法和规则解析](https://www.cnblogs.com/jianhua1992/p/16852784.html)
  - [LD链接脚本解析](https://blog.csdn.net/weixin_39177986/article/details/108455827)


## 硬件平台

 STM32F103ZET6 野火霸道开发板 V2

## 准备工具

ARM GCC 工具链，参考此文安装：[Linux 下搭建 STM32 开发环境](../linux-stm32-development/)




## 预备知识

### STM32 启动模式

|BOOT0|BOOT1|启动方式|
|--|--|--|
|0|X|内部flash，用户程序|
|1|0|系统存储器，BootLoader|
|0|1|内部SRAM，程序调试|

### 内存映射

<div align="left">
    <img src="1.png" style="max-height:350px"></img>
</div>

FLASH 起始地址是 `0x0800 0000`，SRAM 起始地址是 `0x2000 0000`


参考手册 `Boot configuration` 一节有这样一段话：

<div align="left">
    <img src="2.png" style="max-height:80px"></img>
</div>

上电后，CPU 从地址 `0x0000 0000` 获取栈顶地址，然后从地址 `0x0000 0004` 处开始执行代码


<div align="left">
    <img src="3.png" style="max-height:130px"></img>
</div>

当 CPU 从地址 `0x00000000` 读取数据，它实际上可能会访问不同的存储器，具体取决于所选的启动模式。这称为 `内存映射`。默认情况下，STM32 从 FLASH 启动，所以它将内存区域 `0x08000000` 映射到 `0x00000000`；然后就可以从其原始地址 `0x08000000` 或 `0x00000000` 访问 FLASH。这允许 CPU 直接从 FLASH 开始读取指令。

大多数情况下，在芯片启动时需要设置堆栈指针，不同架构的平台方法也不同。步骤很简单：找到存储堆栈地址的位置，将该地址设置为栈顶地址。逻辑上来说，栈空间是从上往下增长的，所以它需要足够的空间（指定大小）。

> `0x0000 0000` 中的值会被加载到 SP 寄存器，`0x0000 0004` 中的值会被加载到 PC 寄存器

## 开始编写

### 最简单的链接脚本

链接文件由一个称为 `SECTIONS` 的块组成。在此块中，你定义的段将被分配到二进制文件中。

- 最重要的段是：
  - `.test` - 包含你的代码
  - `.data` - 包含已初始化的全局/静态变量
  -  `.bss` - 包含未初始化的全局/静态变量

我们的第一个脚本，将只使用 `.text` 。没有数据，没有变量，只有纯代码。我们创建一个 `script.ld` 文件，写入下面的内容：

```c
SECTIONS
{
  .text : { *(.text) }
}
```

- 上面的脚本告诉链接器：
  1. 创建一个 `.text` 段（冒号左边的部分）
  2. 获取目标文件中所有的 `.text` 段（花括号中的部分）
  3. 把第 2 步获取的段放到第 1 步创建的段中

我们定义了代码部分，但没有指定它放在哪里。根据之前讲述的内容，它应该被放到地址 `0x08000000`：

```c
SECTIONS
{
  . = 0x08000000;
  .text : { *(.text) }
}
```

链接脚本中的点 `.` 是位置计数器。它从 `0x0` 开始，可以直接修改，如上所示。也可以通过添加段、常量等间接修改。因此，如果你在 `.text` 段之后读取位置计数器的值，它的值将是 `0x08000000` 加上你添加的段的大小。

好了，我们的代码有了一个正确的位置，接下来只要知道入口程序地址以及堆栈地址：

```c
ENTRY(main);

SECTIONS
{
    . = 0x08000000;
    .text :
    {   // BYTE，SHORT，LONG，QUAD 命令分别存储 1，2，4，8 字节
        LONG(0x20010000);
        LONG(main | 1);
        *(.text)

    }
}
```

当 STM32 启动时，它会从 FLASH 读取两个地址（共 8 字节）。第一个是栈顶地址，第二个是入口程序地址。

- `ENTRY(main)` 告诉链接器应该使用哪个符号作为程序的入口点。这也可以防止包含 `main` 函数的 `.text` 部分被链接器作为垃圾丢弃。

- `LONG(0x20010000)` 告诉链接器将 `0x20010000` 这四个字节放入输出的二进制文件中。为什么是这四个字节？因为 SRAM 地址从 `0x20000000` 开始，大小有 64KB（0x10000）。 `0x20000000 + 0x10000 = 0x20010000` 就是栈顶的地址。

- `LONG(main | 1)` 将 main 函数的地址输出到二进制文件中。如你所见，main 与 1 做了或运算生成一个奇数值。在 ARM 体系结构中，函数地址是奇数（最后一位是1）告诉 CPU 切换到 thumb 模式，而不是表示 ARM 模式的偶数地址。


好了，我们有了一个链接器脚本，再创建 `main.c` 来点亮开发板上的红色 LED ：

```c
#include "registers.h"

// 由于没有配置时钟源，STM32 将使用内部 8 MHz RC 振荡器，这对于这个简单的项目来说绰绰有余
int main(void) {
    // 开启 GPIOB 时钟
    RCC->APB2ENR  |= (1 << LED_CLK);
    // 配置引脚推挽输出
    LED_GPIO->CRL |= (3 << (LED_PIN * 4));
    // 引脚输出低电平
    LED_GPIO->BRR  = (1 << LED_PIN);
    while (1);
}
```

创建头文件 `registers.h` ：

```c
#ifndef __REGISTERS_H
#define __REGISTERS_H

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

typedef struct {
    uint32_t CRL;
    uint32_t CRH;
    uint32_t IDR;
    uint32_t ODR;
    uint32_t BSRR;
    uint32_t BRR;
    uint32_t LCKR;
} GPIOB_Reg;
#define GPIOB ((GPIOB_Reg*) 0x40010C00)

#define LED_CLK     3
#define LED_GPIO    GPIOB
#define LED_PIN     5

#endif
```

创建 `makefile` ：

```makefile
TARGET    := led

BUILD_DIR := ./Build

C_SRC := main.c
C_OBJ := main.o

CP_FLAGS := -mcpu=cortex-m3 -mthumb -Os -Wall -fdata-sections -ffunction-sections -MMD -MP
LD_FLAGS := -mcpu=cortex-m3 -specs=nano.specs -T script.ld  -Wl,--gc-sections

.PHONY: all
all: $(BUILD_DIR) $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin
        @echo "Done"

%.hex: %.elf
        arm-none-eabi-objcopy -O ihex $< $@

%.bin: %.elf
        arm-none-eabi-objcopy -O binary -S $< $@

%.elf: $(BUILD_DIR)/$(C_OBJ)
        arm-none-eabi-gcc $(LD_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.c
        arm-none-eabi-gcc -c $(CP_FLAGS) $< -o $@

$(BUILD_DIR):
        mkdir -p $@

clean:
        rm $(BUILD_DIR) -rf

install:
        st-flash write $(BUILD_DIR)/$(TARGET).bin 0x08000000

-include $(BUILD_DIR)/*.d

```

现在你的目录下有这几个文件：

```bash-session
$ ls
main.c  makefile  registers.h  script.ld
```

编译代码：

```bash-session
$ make
mkdir -p Build
arm-none-eabi-gcc -c -mcpu=cortex-m3 -mthumb -Os -Wall -fdata-sections -ffunction-sections -MMD -MP main.c -o Build/main.o
arm-none-eabi-gcc -mcpu=cortex-m3 -specs=nano.specs -T script.ld  -Wl,--gc-sections Build/main.o -o Build/led.elf
arm-none-eabi-objcopy -O ihex Build/led.elf Build/led.hex
arm-none-eabi-objcopy -O binary -S Build/led.elf Build/led.bin
Done
$ ls Build/
led.bin  led.elf  led.hex  main.d  main.o 
```

查看 `led.bin` 文件：

```bash-session
$ hexdump Build/led.bin
0000000 0000 2001 0011 0800 b5f8 bf00 b5f8 bf00
0000010 4a06 6993 f043 0308 6193 4b05 681a f442
0000020 1240 601a 2220 615a e7fe bf00 1000 4002
0000030 0c00 4001
```

前面 8 个字节 `0000 2001 0011 0800`，我们将数据从小端转换为大端就是：`2001 0000` ，`0800 0011`

第一个就是我们在链接脚本中设置的栈顶地址 `0x20010000`

第二个很可能就是 main 函数的地址 `0x08000011`

再执行一个命令：

```bash-session
$ arm-none-eabi-objdump -D Build/led.elf
08000010 <main>:
 8000010:       4a06            ldr     r2, [pc, #24]   @ (800002c <main+0x1c>)
 8000012:       6993            ldr     r3, [r2, #24]
```

main 函数的实际地址在 `0x08000010` 处，记得我们之前对它进行或运算吗，main 函数的实际地址并未改变，只是调用方式不同。


### MEMORY


在链接脚本中，我们可以定义一个名为 MEMORY  的块（只能存在一个）。在这个块中，我们可以定义常用的内存区域，FLASH 和 SRAM：

```c
MEMORY {
 /* 名称   读写属性  起始地址               大小 */
    FLASH   (RX) : ORIGIN = 0x08000000, LENGTH = 128K
    SRAM    (RW) : ORIGIN = 0x20000000, LENGTH = 20K
}

ENTRY(main);

SECTIONS
{
    .text :
    {
        LONG(0x20010000);
        LONG(main | 1);
        *(.text)
    } > FLASH

    .data :
    {
        *(.data)
    } > SRAM
}
```

上面做了一些改动：

- 增加了 MEMORY 块
- 删除了位置计数器
- 告诉链接器把 `.text` 放到 FLASH 中去： `> FLASH`
- 增加了 `.data` 段，可以存放变量
- 告诉链接器把 `.data` 放到 SRAM 中去： `> SRAM`

现在，我们再 main.c 中添加一个全局变量：`int a = 0xDEADBEEF`，看看它会被放在哪里:

```c
#include "registers.h"
int a = 0xDEADBEEF;
int main(void) {
    a = 0;
    RCC->APB2ENR  |= (1 << LED_CLK);
    LED_GPIO->CRL |= (3 << (LED_PIN * 4));
    LED_GPIO->BRR  = (1 << LED_PIN);
    while (1);
}
```

```bash-session
$ arm-none-eabi-objdump -D Build/led.elf
Disassembly of section .data.a:

20000000 <a>:
20000000:       deadbeef        cdple   14, 10, cr11, cr13, cr15, {7}
```

可以看到地址是 `20000000`，全局变量成功被放置在 SRAM 中。

最后再来看一下 bin 文件：

```bash-session
$ hexdump Build/led.bin 
0000000 0000 2001 0011 0800 b5f8 bf00 b5f8 bf00
0000010 2200 4b09 601a f102 4280 f502 3204 6993
0000020 f043 0308 6193 4b05 681a f042 0203 601a
0000030 2201 615a e7fe bf00 0000 2000 0c00 4001
0000040 beef dead                              
0000044
```


**结束，未完**
