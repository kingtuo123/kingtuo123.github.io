---
author: "kingtuo123"
title: "Linux 下编译 STM32"
date: "2022-07-13"
summary: "linux 使用 make 管理 stm32 工程"
description: ""
tags: [ "stm32","linux","makefile" ]
math: false
categories: [ "stm32","linux","makefile"]
---

- 参考示例：
  - [stm32f103x-template ( stm32f103zet6 )](https://github.com/kingtuo123/stm32f103x-template)

## 目录结构

```text
$ tree -L 3
.
├── Libraries
│   ├── CMSIS
│   │   ├── CM3
│   │   ├── CMSIS changes.htm
│   │   ├── CMSIS debug support.htm
│   │   ├── Documentation
│   │   └── License.doc
│   └── STM32F10x_StdPeriph_Driver
│       ├── inc
│       ├── LICENSE.txt
│       ├── Release_Notes.html
│       └── src
├── Linker
│   └── STM32F103R8Tx_FLASH.ld
├── makefile
└── Userc
    ├── led
    │   ├── bsp_led.c
    │   └── bsp_led.h
    ├── main.c
    ├── stm32f10x_conf.h
    ├── stm32f10x_it.c
    └── stm32f10x_it.h

```

其中 `Libraries` 是从官方下载固件包中直接拷贝过来，内部目录未作调整。

## Makefile

```makefile
TARGET    := LED-BLINK

BUILD_DIR := ./Build

TOOLCHAIN  = arm-none-eabi-
CC  := $(TOOLCHAIN)gcc
CP  := $(TOOLCHAIN)objcopy
AS  := $(TOOLCHAIN)gcc -x assembler-with-cpp
SZ  := $(TOOLCHAIN)size
HEX := $(CP) -O ihex
BIN := $(CP) -O binary -S


DEFS := -D STM32F10X_HD  -D USE_STDPERIPH_DRIVER

LINK_SCRIPT := ./Linker/STM32F103ZETx_FLASH.ld

STARTUP_DIR := ./Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/gcc_ride7/
STARTUP_ASM := $(STARTUP_DIR)/startup_stm32f10x_hd.s

SRC_DIR := ./Libraries/CMSIS/
SRC_DIR += ./Libraries/CMSIS/CM3/CoreSupport/
SRC_DIR += ./Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/
SRC_DIR += ./Libraries/STM32F10x_StdPeriph_Driver/inc/
SRC_DIR += ./Libraries/STM32F10x_StdPeriph_Driver/src/
SRC_DIR += ./User/
SRC_DIR += ./User/led/



INC_DIR := $(addprefix -I,$(SRC_DIR))

C_SRC := $(wildcard $(addsuffix *.c,$(SRC_DIR)))
C_OBJ := $(addprefix $(BUILD_DIR)/,$(notdir $(C_SRC:.c=.o)))

ASM_SRC := $(wildcard $(addsuffix *.s,$(SRC_DIR)))
ASM_SRC += $(STARTUP_ASM)
ASM_OBJ := $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SRC:.s=.o)))


AS_FLAGS := $(INC_DIR) -mcpu=cortex-m3 -g -gdwarf-2 -mthumb -Os -Wall -fdata-sections -ffunction-sections -MMD -MP
CP_FLAGS := $(AS_FLAGS) $(DEFS)
LD_FLAGS := -mcpu=cortex-m3 -specs=nano.specs -T $(LINK_SCRIPT) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref,--gc-sections

vpath %.c $(SRC_DIR)
vpath %.s $(SRC_DIR) $(STARTUP_DIR)


.PRECIOUS: $(BUILD_DIR)/%.o


.PHONY: all
all: $(BUILD_DIR) $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin $(BUILD_DIR)/$(TARGET).hex
        $(SZ) $(BUILD_DIR)/$(TARGET).elf
        @du -sh $(BUILD_DIR)/$(TARGET).elf
        @du -sh $(BUILD_DIR)/$(TARGET).hex
        @du -sh $(BUILD_DIR)/$(TARGET).bin
        @echo "!!! DONE !!!"

$(BUILD_DIR)/%.o: %.c
        $(CC) -c $(CP_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.s
        $(AS) -c $(AS_FLAGS) $< -o $@

$(BUILD_DIR)/%.elf: $(C_OBJ) $(ASM_OBJ)
        $(CC) $(LD_FLAGS) $^ -o $@

%.hex: %.elf
        $(HEX) $< $@

%.bin: %.elf
        $(BIN) $< $@

$(BUILD_DIR):
        mkdir -p $@




clean:
        rm $(BUILD_DIR) -rf

rebuild:
        make clean && make

st-flash:
        st-flash write $(BUILD_DIR)/$(TARGET).bin 0x8000000

isp-flash:
        stm32flash -b 115200 -i '-dtr&rts,dtr:-dtr&-rts,dtr' -v -w $(BUILD_DIR)/$(TARGET).bin /dev/ttyUSB0

isp-info:
        stm32flash -b 115200 -i '-dtr&rts,dtr:-dtr&-rts,dtr' /dev/ttyUSB0

st-erase:
        st-flash erase

isp-erase:
        stm32flash -b 115200 -i '-dtr&rts,dtr:-dtr&-rts,dtr' -o /dev/ttyUSB0


```

|编译/链接 参数|说明|
|:--|:--|
|`-D STM32F10X_HD`|表示芯片容量（必需）|
|`-D USE_STDPERIPH_DRIVER`|表示使用官方标准固件库（必需）|
|`-mcpu=cortex-m3`|指定芯片内核架构（必需）|
|`-g`|产生调试信息|
|`-gdwarf-2`||
|`-mthumb`|表示使用 thumb 指令集（必需）|
|`-Os`|优化代码大小|
|`-Wall`|允许输出所有警告|
|`-MMD`|生成依赖关系文件（.d），依赖不包括系统头文件|
|`-MP`|依赖规则中的所有.h依赖项都会在该文件中生成一个伪目标，其不依赖任何其他依赖项|
|`-fdata-sections`|为每个 data item 分配独立的 section，方便后面链接器优化|
|`-ffunction-sections`|为每个 function 分配独立的 section，方便后面链接器优化|
|`-specs=nano.specs`|使用精简版的C库替代标准C库，可以减少最终程序映像的大小|
|`-T`|指定链接脚本|
|`-Wl`|表示后面跟的参数传递给链接器，用逗号分隔|
|`-Map=<filename>`|生成 map 映射文件|
|`--cref`|Cross Reference的简写，输出交叉引用表|
|`--gc-sections`|不链接未用函数，减小可执行文件大小|

参考文章：

- [gcc -ffunction-sections -fdata-sections -Wl,–gc-sections 参数详解](https://blog.csdn.net/pengfei240/article/details/55228228)

## LinkScript

```c
/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = ORIGIN(RAM) + LENGTH(RAM);    /* end of RAM */
/* Generate a link error if heap and stack don't fit into RAM */
_Min_Heap_Size = 0x200;      /* required amount of heap  */
_Min_Stack_Size = 0x400; /* required amount of stack */

/* Specify the memory areas */
MEMORY
{
RAM (xrw)      : ORIGIN = 0x20000000, LENGTH = 64K
FLASH (rx)      : ORIGIN = 0x8000000, LENGTH = 512K
}

/* Define output sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >FLASH

  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >FLASH

  /* Constant data goes into FLASH */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    . = ALIGN(4);
  } >FLASH

  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >FLASH

  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH
  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASH

  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);

  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data :
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM AT> FLASH


  /* Uninitialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss secion */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >RAM

  /* User_heap_stack section, used to check that there is enough RAM left */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >RAM

  

  /* Remove information from the standard libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
```

## 编译出错

```text
/tmp/cceEC3n9.s:599: Error: registers may not be the same -- `strexb r0,r0,[r1]'
/tmp/cceEC3n9.s:629: Error: registers may not be the same -- `strexh r0,r0,[r1]'
```

修改固件库中 `Libraries/CMSIS/CM4/CoreSupport/core_cm3.c` 文件

将 `__STREXB` 和 `__STREXH` 函数中的 `=r` 改为 `=&r` ，一共有两处：

```asm
__ASM volatile ("strexb %0, %2, [%1]" : "=&r" (result) : "r" (addr), "r" (value) );
```
貌似是 `gcc` 编译优化导致的问题，参考下列文章：

- [Error: registers may not be the same -- strexb r0,r0,[r1]](https://github.com/stlink-org/stlink/issues/65)
- [Fix registers may not be the same ARM GCC error](http://www.cesareriva.com/fix-registers-may-not-be-the-same-error/)
- [gcc编译后出现与CMSIS相关的错误](https://amobbs.com/thread-5465367-1-1.html)


