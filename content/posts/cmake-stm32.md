---
title: "使用 CMake 构建 STM32 工程"
date: "2024-03-17"
summary: "STM32 CMakeLists"
description: ""
categories: [ "linux" ]
tags: [ "cmake", "stm32" ]
---

参考文章

- [STM32 CMake Template](https://jchisholm204.github.io/posts/stm32_cmake/)
- [Cmake使用教程-交叉编译](https://www.cnblogs.com/uestc-mm/p/15666249.html)
- [CMake on STM32](https://dev.to/pgradot/cmake-on-stm32-the-beginning-3766)


## 目录结构

```text
$ tree
.
├── Libraries
│   ├── CMSIS
│   └── STM32F10x_StdPeriph_Driver
│       ├── inc
│       └── src
├── CMakeLists.txt
├── STM32F103ZETx_FLASH.ld
└── User
    ├── led
    │   ├── bsp_led.c
    │   └── bsp_led.h
    ├── main.c
    ├── stm32f10x_conf.h
    ├── stm32f10x_it.c
    └── stm32f10x_it.h
```

## CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

# 目标平台系统名称，裸机嵌入式一般就写 Generic
set(CMAKE_SYSTEM_NAME Generic)
# 目标平台的体系结构
set(CMAKE_SYSTEM_PROCESSOR arm)


set(CMAKE_C_COMPILER   arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_OBJCOPY      arm-none-eabi-objcopy)


# 跳过编译器 -rdynamic 检查
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)


project(led)
enable_language(C ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED OFF)
set(CMAKE_C_EXTENSIONS OFF)


set(ELF_TARGET ${CMAKE_PROJECT_NAME}.elf)


# 预定义参数
add_definitions(
    -D STM32F10X_HD
    -D USE_STDPERIPH_DRIVER
)

# CPU 架构
set(CPU_FLAGS
    -mcpu=cortex-m3
)


# 链接脚本
set(LINK_SCRIPT
    ${CMAKE_CURRENT_SOURCE_DIR}/STM32F103ZETx_FLASH.ld
)


# 启动文件
set(STARTUP_SCRIPT
    ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/gcc_ride7/startup_stm32f10x_hd.s
)


# CMSIS 内核文件
set(CMSIS_CORE
    ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/CMSIS/CM3/CoreSupport/core_cm3.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/system_stm32f10x.c
)


# 标准库外设源文件
file(GLOB STDPERIPH_DRIVER
    ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/STM32F10x_StdPeriph_Driver/src/*.c
)


# 用户程序的源文件
file(GLOB_RECURSE USER_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/User/*.c
)


# 目标程序
add_executable(${ELF_TARGET}
    ${CMSIS_CORE}
    ${STARTUP_SCRIPT}
    ${STDPERIPH_DRIVER}
    ${USER_SRC}
)


# 头文件路径
target_include_directories(${ELF_TARGET} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/CMSIS/CM3/CoreSupport/
    ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/
    ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/STM32F10x_StdPeriph_Driver/inc/
    ${CMAKE_CURRENT_SOURCE_DIR}/User/
    ${CMAKE_CURRENT_SOURCE_DIR}/User/led/
)


#  编译参数
target_compile_options(${ELF_TARGET} PRIVATE
    ${CPU_FLAGS}
    -Wall
    -Wextra
    -g 
    -gdwarf-2 
    -mthumb 
    -Os 
    -Wall 
    -fdata-sections 
    -ffunction-sections
    -fmessage-length=0
)


# 链接参数
target_link_options(${ELF_TARGET} PRIVATE
    -T${LINK_SCRIPT}
    ${CPU_FLAGS}
    --specs=nano.specs
    -Wl,--gc-sections
    -Wl,-Map=${CMAKE_PROJECT_NAME}.map
    -Wl,--cref
    -Wl,--print-memory-usage
)


# 添加自定义 makefile 规则，用于生成 hex bin 格式文件
add_custom_command(TARGET ${ELF_TARGET} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${ELF_TARGET} ${CMAKE_PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary -S ${ELF_TARGET} ${CMAKE_PROJECT_NAME}.bin
)
```

## Linux

```bash-session
$ cmake -S . -B Build
$ cmake --build Build
```

## Windwos

需要安装 `MinGW-w64`，使用以下命令构建：

```bash-session
$ cmake -S . -B Build -G "MinGW Makefiles"
$ cmake --build Build
```

或


```bash-session
$ cmake -S . -B Build -G "MinGW Makefiles"
$ cd Build
$ mingw32-make
```

## 遇到的问题

下面两句必需放在开头

```cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
```

下面这句必须放在 `project()` 之前

```cmake
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
```

总之，`project()` 之前的语句位置不要改动，否则会导致编译器检查失败，至于原因还有待探究。
