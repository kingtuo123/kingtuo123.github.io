---
title: "Linux 下编译 STM32"
date: "2022-07-13"
summary: "使用 make 管理 stm32 工程"
description: ""
categories: [ "stm32","linux"]
tags: [ "stm32","linux","makefile" ]
math: false
---


- 参考文章：
  - [gcc -ffunction-sections -fdata-sections -Wl,–gc-sections 参数详解](https://blog.csdn.net/pengfei240/article/details/55228228)
  - [dwarf 调试信息存储格式](https://zhuanlan.zhihu.com/p/419908664)
  - [GCC STM32 链接文件和启动文件分析](https://blog.csdn.net/weixin_43522787/article/details/121869803)


## 使用标准库

### 目录结构

```text {hl_lines=[7,8,16,"25-27","30-33","35-38"]}
$ tree
.
├── Libraries
│   ├── CMSIS
│   │   └── CM3
│   │       ├── CoreSupport
│   │       │   ├── core_cm3.c
│   │       │   └── core_cm3.h
│   │       └── DeviceSupport
│   │           └── ST
│   │               └── STM32F10x
│   │                   ├── startup
│   │                   │   ├── arm
│   │                   │   ├── gcc_ride7
│   │                   │   │   ├── startup_stm32f10x_cl.s
│   │                   │   │   ├── startup_stm32f10x_hd.s
│   │                   │   │   ├── startup_stm32f10x_hd_vl.s
│   │                   │   │   ├── startup_stm32f10x_ld.s
│   │                   │   │   ├── startup_stm32f10x_ld_vl.s
│   │                   │   │   ├── startup_stm32f10x_md.s
│   │                   │   │   ├── startup_stm32f10x_md_vl.s
│   │                   │   │   └── startup_stm32f10x_xl.s
│   │                   │   ├── iar
│   │                   │   └── TrueSTUDIO
│   │                   ├── stm32f10x.h
│   │                   ├── system_stm32f10x.c
│   │                   └── system_stm32f10x.h
│   └── STM32F10x_StdPeriph_Driver
│       ├── inc
│       │   ├── misc.h
│       │   ├── stm32f10x_adc.h
│       │   ├── ...
│       │   └── stm32f10x_wwdg.h
│       └── src
│           ├── misc.c
│           ├── stm32f10x_adc.c
│           ├── ...
│           └── stm32f10x_wwdg.c
├── makefile
├── STM32F103ZETx_FLASH.ld
└── User
    ├── led
    │   ├── bsp_led.c
    │   └── bsp_led.h
    ├── main.c
    ├── stm32f10x_conf.h
    ├── stm32f10x_it.c
    └── stm32f10x_it.h

```

- `Libraries` 是从官方下载固件包中直接拷贝过来，内部目录不作调整。

- `User` 是存放用户代码的目录。

### makefile 文件

```makefile
TARGET    := LED-BLINK

# 存放编译文件的目录
BUILD_DIR := ./Build

# ARM GCC 工具链
TOOLCHAIN  = arm-none-eabi-
CC  := $(TOOLCHAIN)gcc
CP  := $(TOOLCHAIN)objcopy
AS  := $(TOOLCHAIN)gcc -x assembler-with-cpp
SZ  := $(TOOLCHAIN)size
HEX := $(CP) -O ihex
BIN := $(CP) -O binary -S

# CPU 内核架构
CPU := cortex-m3

# 预定义
DEFS := -D STM32F10X_HD -D USE_STDPERIPH_DRIVER

# 链接脚本
LINK_SCRIPT := ./STM32F103ZETx_FLASH.ld

# 头文件路径
INC_DIR := ./Libraries/CMSIS/CM3/CoreSupport/
INC_DIR += ./Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/
INC_DIR += ./Libraries/STM32F10x_StdPeriph_Driver/inc/
INC_DIR += ./User/
INC_DIR += ./User/led/

# STARTUP 启动文件
ASM_SRC := ./Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/gcc_ride7/startup_stm32f10x_hd.s

# CMSIS 内核文件
C_SRC := ./Libraries/CMSIS/CM3/CoreSupport/core_cm3.c
C_SRC += ./Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/system_stm32f10x.c

# 标准库外设源码
C_SRC += $(wildcard ./Libraries/STM32F10x_StdPeriph_Driver/src/*.c)

# 用户代码
C_SRC += $(wildcard ./User/*.c)
C_SRC += $(wildcard ./User/led/*.c)

# 目标文件
C_OBJ := $(addprefix $(BUILD_DIR)/,$(notdir $(C_SRC:.c=.o)))
ASM_OBJ := $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SRC:.s=.o)))

# 编译参数
CP_FLAGS := $(addprefix -I,$(INC_DIR)) -mcpu=$(CPU) -g -gdwarf-2 -mthumb -Os -Wall -fdata-sections -ffunction-sections -MMD -MP $(DEFS)
# 汇编参数
AS_FLAGS := $(addprefix -I,$(INC_DIR)) -mcpu=$(CPU) -g -gdwarf-2 -mthumb -Os -Wall -fdata-sections -ffunction-sections -MMD -MP
# 链接参数
LD_FLAGS := -mcpu=$(CPU) -specs=nano.specs -T $(LINK_SCRIPT) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref,--gc-sections

# 设置 make 文件搜索路径，.h文件由 gcc -I 参数包含了
vpath %.c $(sort $(dir $(C_SRC)))
vpath %.s $(sort $(dir $(ASM_SRC)))

# 保留目标文件，make 默认会删除编译生成的 .o 文件
.PRECIOUS: $(BUILD_DIR)/%.o


.PHONY: all
all: $(BUILD_DIR) $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin $(BUILD_DIR)/$(TARGET).hex
	@echo "-------------------------------------------------------------------------------"
	$(SZ) $(BUILD_DIR)/$(TARGET).elf
	@echo "-------------------------------------------------------------------------------"
	@stat $(BUILD_DIR)/$(TARGET).bin | head -n2
	@echo "-------------------------------------------------------------------------------"

$(BUILD_DIR)/%.o: %.c
	$(CC) -c $(CP_FLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.s
	$(AS) -c $(AS_FLAGS) $< -o $@

%.elf: $(C_OBJ) $(ASM_OBJ) 
	$(CC) $(LD_FLAGS) $^ -o $@

%.hex: %.elf
	$(HEX) $< $@

%.bin: %.elf
	$(BIN) $< $@

$(BUILD_DIR):
	mkdir -p $@


clean:
	rm $(BUILD_DIR)/* -rf

rebuild:
	make clean && make

install:
	st-flash write $(BUILD_DIR)/$(TARGET).bin 0x8000000

st-flash:
	st-flash write $(BUILD_DIR)/$(TARGET).bin 0x8000000

st-erase:
	st-flash erase

isp-flash:
	stm32flash -b 115200 -i '-dtr&rts,dtr:-dtr&-rts,dtr' -v -w $(BUILD_DIR)/$(TARGET).bin /dev/ttyUSB0

isp-erase:
	stm32flash -b 115200 -i '-dtr&rts,dtr:-dtr&-rts,dtr' -o /dev/ttyUSB0

isp-info:
	stm32flash -b 115200 -i '-dtr&rts,dtr:-dtr&-rts,dtr' /dev/ttyUSB0


# 包含由 gcc -MMD 参数生成的 .d 文件
-include $(BUILD_DIR)/*.d
```



### STM32F103ZETx_FLASH.ld 链接脚本

链接脚本使用 `STM32CubeMX` 生成：

<div align="center">
    <img src="1.png" style="max-height:180px"></img>
</div>

随便建个工程，按图中所示选择 `Makefile` 生成代码即可。

```c
// 设置入口地址为 Reset_Handler
ENTRY(Reset_Handler)

// RAM 的结束地址
_estack = ORIGIN(RAM) + LENGTH(RAM);

// 设置堆栈大小
_Min_Heap_Size = 0x200;
_Min_Stack_Size = 0x400;

// 指定内存区域
MEMORY
{
// RAM 起始地址和大小
RAM (xrw)      : ORIGIN = 0x20000000, LENGTH = 64K
// FLASH 起始地址和大小
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


### 编译出错解决

```bash-session
$ make
/tmp/cceEC3n9.s:599: Error: registers may not be the same -- `strexb r0,r0,[r1]'
/tmp/cceEC3n9.s:629: Error: registers may not be the same -- `strexh r0,r0,[r1]'
```

修改固件库中 `Libraries/CMSIS/CM3/CoreSupport/core_cm3.c` 文件

将 `__STREXB` 和 `__STREXH` 函数中的 `=r` 改为 `=&r` ，一共有两处：

```asm
__ASM volatile ("strexb %0, %2, [%1]" : "=&r" (result) : "r" (addr), "r" (value) );
```
貌似是 `gcc` 编译优化导致的问题，参考下列文章：

- [Error: registers may not be the same -- strexb r0,r0,[r1]](https://github.com/stlink-org/stlink/issues/65)
- [Fix registers may not be the same ARM GCC error](http://www.cesareriva.com/fix-registers-may-not-be-the-same-error/)
- [gcc编译后出现与CMSIS相关的错误](https://amobbs.com/thread-5465367-1-1.html)

成功编译后如下：

```bash-session
$ make
-------------------------------------------------------------------------------
arm-none-eabi-size ./Build/LED-BLINK.elf
   text    data     bss     dec     hex filename
   1812       8    5152    6972    1b3c ./Build/LED-BLINK.elf
-------------------------------------------------------------------------------
  File: ./Build/LED-BLINK.bin
  Size: 1820            Blocks: 8          IO Block: 4096   regular file
-------------------------------------------------------------------------------
```

### GCC 参数说明

|参数|说明|
|:--|:--|
|-D STM32F10X\_HD|表示芯片容量|
|-D USE\_STDPERIPH\_DRIVER|表示使用官方标准固件库|
|-mcpu=cortex-m3|指定芯片内核架构|
|-g|产生调试信息|
|-gdwarf-2|调试信息格式|
|-mthumb|表示使用 thumb 指令集|
|-Os|优化代码大小|
|-Wall|允许输出所有警告|
|-MMD|生成依赖关系文件 .d，依赖不包括系统头文件|
|-MP|依赖规则中的所有 .h 依赖项都会在该文件中生成一个伪目标，其不依赖任何其他依赖项|
|-fdata-sections|为每个 data item 分配独立的 section，方便后面链接器优化|
|-ffunction-sections|为每个 function 分配独立的 section，方便后面链接器优化|
|-specs=nano.specs|使用精简版的C库替代标准C库，可以减少最终程序映像的大小|
|-T|指定链接脚本|
|-Wl|表示后面跟的参数传递给链接器，用逗号分隔|
|-Map=\<filename\>|生成 map 映射文件|
|--cref|Cross Reference 的简写，输出交叉引用表|
|--gc-sections|不链接未用函数，减小可执行文件大小|

