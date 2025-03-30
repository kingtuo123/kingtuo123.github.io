---
title: "ARM 汇编 Cortex-M3/M4"
date: "2025-03-04"
summary: "ARM Cortex-M3 / M4 权威指南 - 学习笔记"
description: ""
categories: [ "embedded " ]
tags: [ "arm", "asm"]
---


相关链接：

- [Arm 汇编在线模拟运行](https://cpulator.01xz.net/?sys=arm)
- [ARM Cortex-M3/4 指令流水线](https://blog.csdn.net/kouxi1/article/details/123318182)


## 寄存器

<div align="left">
    <img src="regs.svg" style="max-height:400px"></img>
</div>


## Thumb 指令集

ARM 架构的指令集有 ARM、Thumb、Thumb-2、ARM64 等，分别针对不同应用场景。

`thumb`：16 位指令集，是 thumb-2 的子集，用于 Cortex-M0/M0+/M1（ARMv6-M 架构）

`thumb-2`：混合指令集，支持 16 位和 32 位指令，用于 Cortex-M3/M4（ARMv7-M / ARMv7E-M 架构）


**简单对比：**

16 位指令由于空间有限，许多 16 位指令只能访问 `R0-R7`（低寄存器）

32 位指令能使用更大寄存器范围、更大的立即数、更宽的地址区域、更多的寻址模式


例如 16 位的 `MOV` 指令只能承载 8 位立即数：

```
| 15:11 | 10:8 | 7:0 |     op： 操作码（5位）
|-------|------|-----|     Rd： 目标寄存器（3位）
|  op   |  Rd  | imm |     imm：立即数（8位）
```

当立即数超过了 8 位，则需要使用多条指令来加载立即数：

```armasm
MOV R0, #0x34      ; 加载低8位
MOV R1, #0x12      ; 加载高8位
```

32 位的 `MOVW` 指令可承载 16 位的数据：

```armasm
MOVW R0, #0x1234
```


## 流水线架构

Cortex-M3/M4 采用三级流水线：取指（Fetch）、解码（Decode）、执行（Execute）

<div align="left">
    <img src="arch.svg" style="max-height:400px"></img>
</div>

当第 N 条指令执行时，第 N+2 条指令正在取值，而 PC 总是指向正在取指的指令，即指向第三条指令

- 处理器处于 ARM 状态时，每条指令为 4 个字节，PC = 当前执行的指令地址 + 8 字节
- 处理器处于 Thumb 状态时，每条指令为 2 字节，PC = 当前执行的指令地址 + 4 字节

为了保证 Thumb-2 与 Thumb 的一致性，对于 CM3/4，不管执行 16 位或 32 位指令，**PC 总为当前执行的指令地址 + 4 字节**

当执行到跳转指令时，需要清洗流水线，处理器必须从跳转目的地重新取指。
因此，尽量地少使用跳转指令可以提高程序的执行效率。





## ARM 状态与 Thumb 状态

有些处理器同时支持 ARM 和 Thumb 指令集，通过 `BX` 或 `BLX` 指令进行切换，当指令 `BX` 跳转地址的 `LSB` 位为 `1`，表示切换到 Thumb 状态，为 `0` 则切换到 ARM 状态。

无论是 ARM 还是 Thumb，其指令在存储器中都是边界对齐的（2字节或4字节对齐），也就是地址的最低位总是 0。
因此，在执行跳转过程中，PC 寄存器中的最低位被舍弃，不起作用。
在 `BX` 指令的执行过程中，最低位正好被用作状态判断的标志，不会造成存储器访问不对齐的错误。

Cortex-M 系列处理器不支持 ARM 指令，因此也不存在 ARM 状态，所以反汇编中的函数地址最低位都是 1 。


## 汇编语法

不同供应商的汇编工具，其伪指令、标签和注释的语法会有差异

Keil MDK-ARM（AC5） 语法：

```asm
;标签           ;指令    ;操作数
Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]
                IMPORT  __main
                IMPORT  SystemInit
                LDR     R0, =SystemInit
                BLX     R0               
                LDR     R0, =__main
                BX      R0
                ENDP
```

GNU 汇编语法，指令与寄存器名称可以小写：

```asm
/*标签           指令       操作数         */
                .section  .text.Reset_Handler
                .weak     Reset_Handler
                .type     Reset_Handler, %function
Reset_Handler:  
                movs      r1, #0
                b         LoopCopyDataInit

```

## 统一汇编语言

统一汇编语言（Unified Assembly Language, UAL）是一种语法规范，统一 ARM 和 Thumb 指令集的汇编指令格式

Keil 和 Gnu 是汇编 `伪指令` 不同，汇编 `指令` 语法相同


## 标签

标签（lable）用于标记代码或数据在内存中的位置，方便跳转指令等（如 B、BL）通过标签引用这些地址，而不必直接使用具体的内存地址

## 伪指令

伪指令不是实际的机器指令，但在汇编过程中会被转换为一条或多条等效的机器指令

某些指令如 `LDR R0, [R1]` 是汇编指令，`LDR R0, =0x12345678` 是伪指令，取决于它的使用方式


## Keil 汇编器伪指令

`DCB` &nbsp;&nbsp;&nbsp;&nbsp;定义字节数据，分配一个字节的空间，可存入数据

```asm
          DCB  MyVar  ;未初始化（赋值）的空间
          DCB  0x12
MyByte    DCB  0x12
MyBytes   DCB  0x12, 0x34, 0x56
MyString  DCB  'H', 'e', 'l', 'l', 'o', 0
```
`DCW` &nbsp;&nbsp;&nbsp;&nbsp;定义半字数据（2字节）

`DCD` &nbsp;&nbsp;&nbsp;&nbsp;定义字数据（4字节）

`DCQ` &nbsp;&nbsp;&nbsp;&nbsp;定义双字数据（8字节）

`SPACE` 分配指定字节的未初始化空间

```asm
MyBuffer SPACE 10  ;分配 10 个字节并初始化为零
```

`FILL` 分配指定数量的字节，并用指定值填充

```asm
MyBuffer FILL 10, 0xFF  ;填充 10 个字节，值为 0xFF
```

`EQU` &nbsp;&nbsp;&nbsp;&nbsp;定义符号常量，如 `MAX_VALUE  EQU  100`

`AREA` &nbsp;&nbsp;定义代码或数据段，为汇编器提供信息，以便正确组织和分配内存

```asm
AREA MyCode, CODE, READONLY, ALIGN=2
AREA 段名, 属性1, 属性2, ...
;段名：段的名称，通常是一个字符串，用于标识该段。
;属性：定义段的特性，常见的属性包括：
;     CODE       表示代码段，通常用于存储可执行指令
;     DATA       表示数据段，通常用于存储变量和常量
;     READONLY   表示该段是只读的
;     READWRITE  表示该段是可读写的
;     ALIGN=n    指定段的对齐方式，ALIGN=n 表示按 2^n 方字节对齐
;     NOINIT     表示该段不需要初始化

AREA |.text|, CODE, READONLY
;|.text| 是标准代码段的名称，通常用于存储程序的指令代码
;使用竖线 | 包裹段名是为了确保段名被当作一个整体处理，避免歧义
;这种写法是 Keil 汇编器的规范，尤其是在定义标准段时常用
```

`PROC` 定义一个子程序，与 `ENDP` 配对使用，`ENDP` 用于标记子程序的结束

```asm
NMI_Handler     PROC
                EXPORT  NMI_Handler                [WEAK]
                B       .
                ENDP
```

`EXPORT` 用于声明一个全局符号，使其在其他模块中可见和可调用

`IMPORT` 用于声明一个外部符号

`WEAK` 用于声明一个弱符号

```asm
WEAK    MyFunction 
EXPORT  MyFunction  [WEAK] ;与 EXPORT 配合使用
```

`ALIGN` 对齐到 `2^n` 字节边界

`IFDEF` 用于检查某个符号是否已定义

```asm
IFDEF DEBUG
    MOV R0, #1  ; 如果 DEBUG 已定义，编译这行代码
ENDIF
```

`IF`、`ELSE` 条件汇编

```asm
IF Var = 1
    MOV R1, #1  ; 如果条件为真，编译这行代码
ELSE
    MOV R1, #2  ; 如果条件为假，编译这行代码
ENDIF
; =	等于
; <>	不等于
; >	大于
; <	小于
; >=	大于等于
; <=	小于等于
```


## GNU 汇编器伪指令

 **更多参考：[The gnu Assembler](https://www.eecs.umich.edu/courses/eecs373/readings/Assembler.pdf) 第 7 章**

`.align` 用于对齐代码或数据到 `2^n` 字节边界，如 `.align 2` 对齐到 4 字节的边界

`.extern` 用于声明一个外部符号（如函数或变量）

`.include` 用于包含其他汇编文件，如 `.include "header.s" `

`.text` 表示后续代码属于 `.text` 段，类似的还有 `.data`、`.bss`  

`.section` 告诉汇编器将本行之后的代码或数据放入指定的段中，直到遇到下一个 `.section`

```asm
.section  .text.Default_Handler,"ax",%progbits
/* 格式：.section 段名 [, 标志] [, 类型] [, 对齐] [, 入口点]                                
   段名：指定段的名称，如 .text、.data、.bss 等                                             
   标志：可选参数，指定段的属性，如 "a"（可分配）、"w"（可写）、"x"（可执行）等             
   类型：可选参数，指定段的类型，如 %progbits（包含数据）、%nobits（不包含数据，如 .bss 段）
   对齐：可选参数，指定段的对齐方式，按 2^n 字节对齐                                        
   入口点：可选参数，指定段的入口点 */
```


 `.asciz`、`.string` 用于在汇编代码中定义字符串，并在末尾添加 `\0` ；`.ascii` 不会添加 `\0`

```asm
my_string:
    .string "ARM GCC Assembly"
```

`.byte` 指令用于在内存中定义一个或多个字节的数据，类似还有 `.word`、`.int`、`.float`、`.double`

```asm
.data
my_array:
    .byte 1, 2, 3, 4, 5
my_values:
    .word 0x12345678, 0x87654321, 0xABCDEF01
```

`.equ`、`.set` 用于定义符号常量，类似于 C 语言中的 `#define`，`.equ` 更通用

```asm
.equ BUFFER_SIZE, 1024 * 4
```


`.if`、`.ifdef`、`.else`、`.elseif` 和 `.endif` 是条件汇编伪指令

```asm
.equ FLAG, 0x1
.if FLAG == 1
    mov r0, r1
.else
    mov r0, r2
.endif
```

`.macro` 和 `.endm` 用于定义宏

```asm
.macro add_reg reg1, reg2
    add \reg1, \reg1, \reg2
.endm
```

`.space` 指令用于在内存中分配指定大小的空间，并用指定的值填充该空间

```asm
/* 分配 200 字节的空间，并用 0x00 填充，并使用标签 my_buffer 标记起始地址 */
my_buffer .space 200, 0x00
```

`.global` 用于声明一个全局符号，可以在其他汇编文件或 C/C++ 代码中引用

```asm
.global my_variable  /* 声明 my_variable 为全局符号（变量）*/
.global my_function  /* 声明 my_function 为全局符号（函数）*/

.data
my_variable:
    .word 0x12345678  /* 定义一个32位变量 */

.text
my_function:
    mov r0, #42
    bx lr
```

```c
// 在 C 代码中调用
extern int my_variable;
extern void my_function(void);
```


`.type` 用于声明符号的类型，如 `%function` 函数或 `%object` 对象

```asm
.globl my_function
.type my_function, %function
my_function:
    bx lr
```

```asm
.globl my_data
.type my_data, %object
my_data:
    .word 0x12345678
```

`.size` 用于指定符号（如函数或数据）的大小信息，常与 `.type` 一起使用，
帮助链接器和调试器更好地理解代码结构

```asm
.global my_function
.type my_function, %function
my_function:
    /* 函数代码 */
    mov r0, #0
    bx lr
.size my_function, .-my_function   /* 设置 my_function 的大小为当前位置（.）减去 my_function 的起始地址 */
/* .size 符号名, 表达式
    符号名：指定要设置大小的符号，通常是函数或数据的名称
    表达式：指定符号的大小，通常以字节为单位 */
```

`.weak` 指令用于声明一个弱符号

```asm
.weak my_function
my_function:
    bx lr
```

```asm
.weak my_variable
.data
my_variable:
    .word 0
```


`.syntax` 指定汇编代码的语法格式

```asm
.syntax unified  /* 统一汇编语言（默认），支持混合使用 ARM 和 Thumb 指令 */
.syntax divided  /* 传统语法，仅支持 ARM 指令集 */
```

`.cpu` 指定处理器架构，使汇编器针对特定的架构优化

```asm
.cpu cortex-m3
```

`.fpu` 指定目标处理器支持的浮点单元（FPU）类型

```asm
.fpu softvfp  /* 软件浮点运算 */
.fpu vfpv3    /* ARMv7 架构的 VFPv3 */
```

`.thumb` 使用 thumb 指令集，在某些情况下，可以在同一汇编文件中混合使用 `.arm` 和 `.thumb` 指令集

`.thumb_set` 用于将一个符号定义为另一个符号的别名 （alias），并且明确指定该别名是 Thumb 指令集的符号

```asm
.thumb_set 别名, 目标符号
```

```asm
.global my_function
.type my_function, %function
.thumb_func
my_function:
    movs r0, #0
    bx lr
.size my_function, .-my_function

/* 为 my_function 创建一个 Thumb 别名 */
.thumb_set my_function_alias, my_function
```



## 寻址方式

<div class="table-container no-thead">

|               |                         |                                                               |
|:--------------|:------------------------|:--------------------------------------------------------------|
|立即数寻址     |`MOV R0, #0x10`          |将立即数 0x10 加载到寄存器 R0                                  |
|寄存器寻址     |`MOV R1, R0`             |将寄存器 R0 的值复制到寄存器 R1                                |
|寄存器间接寻址 |`LDR R2, [R1]`           |从 R1 指向的内存地址加载数据到 R2                              |
|基址加偏移寻址 |`LDR R2, [R1, #4]`       |从 R1 + 4 的内存地址加载数据到 R2                              |
|基址加索引寻址 |`LDR R2, [R1, R0]`       |从 R1 + R0 的内存地址加载数据到 R2                             |
|前变址寻址     |`LDR R2, [R1, #4]!`      |先将 R1 增加 4，然后从 R1 指向的内存地址加载数据到 R2          |
|后变址寻址     |`LDR R2, [R1], #4`       |从 R1 指向的内存地址加载数据到 R2，然后将 R1 增加 4            |
|PC 相对寻址    |`LDR R0, [PC, #0x100]`   |从 PC + 0x100 的内存地址加载数据到 R0                          |
|字面量池寻址   |`LDR R0, =0x12345678`    |将常量 0x12345678 加载到 R0                                    |
|多寄存器寻址   |`LDMIA R1, {R2, R3, R4}` |从 R1 指向的内存地址依次加载数据到 R2, R3, R4，并自动增加 R1   |
|堆栈寻址       |`PUSH {R0, R1}`          |将 R0 和 R1 压入堆栈                                           |
|               |`POP {R0, R1}`           |从堆栈弹出数据到 R0 和 R1                                      |

</div>


## 地址对齐


<div align="left">
    <img src="align.svg" style="max-height:400px"></img>
</div>

在汇编中 `.align n` 是 `2^n` 字节对齐，在链接脚本中 `ALIGN(n)` 是 `n` 字节对齐

大多数情况下，4 字节传输的地址要 4 字节对齐，2 字节传输的地址要 2 字节对齐


## 整数状态标志

`APSR`（应用程序状态寄存器）包含以下标志位：

<div class="table-container">

|标志|置位条件                                                                           |
|:---|:----------------------------------------------------------------------------------|
|`N == 1` |结果为负、算术或逻辑运算结果的最高有效位为 1、被比较数 < 另一个数                  |
|`Z == 1` |结果为零、比较相等                                                                 |
|`C == 1` |无符号加法溢出、被减数 >= 减数，被比较数 >= 另一个数、移位时最后一个被移出的位为 1 |
|`V == 1` |有符号运算结果溢出                                                                 |
|`Q == 1` |                                                                 |

</div>


## 指令后缀

例如 `beq equal` 表示当 `Z == 1` 时，执行跳转：

```asm
cmp r0, r1      /* 比较 r0 和 r1 的值              */
beq equal       /* 如果 r0 == r1，跳转到标签 equal */
```


<div class="table-container">

|后缀   |英文                    |标志状态         |含义                       |
|:------|:-----------------------|:----------------|:--------------------------|
|`EQ`   |Equal                   |`Z == 1`         |等于                       |
|`NE`   |Not Equal               |`Z == 0`         |不等于                     |
|`HI`   |Higher                  |`C == 1` `Z == 0`|无符号 `>`                 |
|`CS/HS`|Carry set / High or Same|`C == 1`         |无符号 `>=` ，进位设置     |
|`CC/LO`|Carry Clear / Lower     |`C == 0`         |无符号 `<` ，进位清除      |
|`LS`   |Lower or Same           |`C == 0` `Z == 1`|无符号 `<=`                |
|`MI`   |Minus                   |`N == 1`         |负数                       |
|`PL`   |Plus                    |`N == 0`         |正数或零                   |
|`VS`   |Overflow Set            |`V == 1`         |有符号溢出                 |
|`VC`   |Overflow Clear          |`V == 0`         |有符号不溢出               |
|`GE`   |Greater or Equal        |`N == V`         |有符号 `>=`                |
|`LT`   |Less Than               |`N != V`         |有符号 `<`                 |
|`GT`   |Greater Than            |`Z == 0` `N == V`|有符号 `>`                 |
|`LE`   |Less or Equal           |`Z == 1` `N != V`|有符号 `<=`                |
|`AL`   |Always                  |                 |无条件，始终执行           |

</div>


<div class="table-container">

|后缀         |含义                                            |
|:------------|:-----------------------------------------------|
|`S`          |更新 `APSR`                                     |
|`.N` `.W`    |指定使用 16 位指令（narrow）或 32 位指令（wide）|
|`.32` `.F32` |指定 32 位单精度运算                            |
|`.64` `.F64` |指定 64 位双精度运算                            |

</div>



## 处理器内传送数据的指令

<div class="table-container no-thead">

||||
|:--|:--|:--|
|`MOV` |`R4, R0`      |从 `R0` 复制数据到 `R4`                      |
|`MOVS`|`R4, R0`      |从 `R0` 复制数据到 `R4`，且更新 `APSR` 标志  |
|`MRS` |`R7, PRIMASK` |将数据从 `PRIMASK` 复制到 `R7`（特殊寄存器 → 通用寄存器）               |
|`MSR` |`CONTROL, R2` |将数据从 `R2` 复制到 `CONTROL`（通用寄存器 → 特殊寄存器）              |
|`MOVW`|`R6, #0x1234` |设置 `R6` 为 16 位常量 `0x1234`              |
|`MOVT`|`R6, #0x8765` |设置 `R6` 的高 16 位为 `0x8765`              |
|`MVN` |`R3, R7`      |将 `R7` 中数据取反后送至 `R3`                |

</div>


## 存储器访问指令

<div class="table-container no-thead">

|||    |
|:---------------|:---------------|:-------------------------------|
|`LDRB`          |`STRB`          |8 位无符号（Byte）              |
|`LDRSB`         |`STRB`          |8 位有符号 （Signed Byte）      |
|`LDRH`          |`STRH`          |16 位无符号 （Half Word）       |
|`LDRSH`         |`STRH`          |16 位有符号 （Signed Half Word）|
|`LDR`           |`STR`           |32 位（Word）                   |
|`LDM`           |`STM`           |多个 32 位  （Multiple）        |
|`LDRD`          |`STRD`          |双字 64 位  （Double）          |
|`POP`           |`PUSH`          |栈操作 32 位                    |

</div>

```asm
LDR R0, [R1, #0x8]  /* 从存储器 R0 + 8 地址处读取字 */
STR R0, [R1, #0x8]  /* 将 R0 中的数据写入存储器 R0 + 8 地址处 */
```

## 多加载和多存储

`LDM`、`STM` 指令的地址模式：

- `IA`（Increment After）&nbsp;&nbsp;&nbsp;：存储后地址递增（默认模式）
- `IB`（Increment Before）&nbsp;：存储前地址递增
- `DA`（Decrement After）&nbsp;&nbsp;：存储后地址递减
- `DB`（Decrement Before）：存储前地址递减

```asm
STMIA R0!, {R4-R7}       /* 存储 R4-R7 到 R0 指向的地址，地址在每次写入后增加 4，最后将 R0+16 写回 R0 */
STMDB SP!, {R0-R3, LR}   /* 等同于 PUSH {R0-R3, LR} */
LDMIA SP!, {R0-R3, PC}   /* 等同于 POP {R0-R3, PC} */
```

`STMDB SP!, {R0-R3, LR}` 存储顺序：

```text
   栈       高地址
|      | ← SP
|  LR  | ← SP-4
|  R3  | ← SP-8 
|  R2  | ← SP-12   
|  R1  | ← SP-16 
|  R0  | ← SP-20
            低地址
```

> 注意：无论寄存器列表如何书写，编号高的寄存器总是先存储

`LDMIA SP!, {R0-R3, PC}` 加载顺序：

```text
   栈      高地址    寄存器
|      | ← SP+20
|  LR  | ← SP+16 → [  PC  ]
|  R3  | ← SP+12 → [  R3  ]
|  R2  | ← SP+8  → [  R2  ]
|  R1  | ← SP+4  → [  R1  ]
|  R0  | ← SP    → [  R0  ]
           低地址
```

> `PUSH` 实际上是 `STMDB` 的别名，`POP` 是 `LDMIA` 的别名

数组在栈中的存储顺序：

```text
| array[3] | 高地址
| array[2] |
| array[1] |
| array[0] | 低地址
```

## 排他访问

例如 `LDREXB` 通常与 `STREXB` (Exclusive Byte) 指令配合使用，
用于实现原子读-修改-写操作

```asm
try_atomic_update:
    LDREXB R1, [R0]       /* 从R0指向的地址加载字节到R1，并标记独占访问 */
    ...                   /* 在这里对 R1 的值进行修改*/
    STREXB R2, R1, [R0]   /* 尝试将修改后 R1 的值存回 R0 地址，返回状态存入 R2 */
    CMP R2, #0            /* 检查存储是否成功（R2=0表示成功）*/
    BNE try_atomic_update /* 如果不成功则重试 */
```

## 算术运算

<div class="table-container no-thead">

|                |                         |                        |
|:---------------|:------------------------|:-----------------------|
|**加法**        |`ADD` `Rd, Rn, Rm`       |Rd = Rn + Rm            |
|                |`ADD` `Rd, Rn, #immed`   |Rd = Rn + #immed        |
|**带进位的加法**|`ADC` `Rd, Rn, Rm`       |Rd = Rn + Rm + 进位     |
|                |`ADC` `Rd, #immed`       |Rd = Rn + #immed + 进位 |
|**减法**        |`SUB` `Rd, Rn, Rm`       |Rd = Rn - Rm            |
|                |`SUB` `Rd, #immed`       |Rd = Rd - #immed        |
|                |`SUB` `Rd, Rn, #immed`   |Rd = Rn - #immed        |
|**带借位的减法**|`SBC` `Rd, Rn, #immed`   |Rd = Rn - #immed - 借位 |
|                |`SBC` `Rd, Rn, Rm`       |Rd = Rn - Rm - 借位     |
|**减反转**      |`RSB` `Rd, Rn, #immed`   |Rd = #immed - Rn        |
|                |`RSB` `Rd, Rn, Rm`       |Rd = Rm - Rn            |
|**乘法**        |`MUL` `Rd, Rn, Rm`       |Rd = Rn * Rm            |
|**无符号除法**  |`UDIV` `Rd, Rn, Rm`      |Rd = Rn / Rm            |
|**有符号除法**  |`SDIV` `Rd, Rn, Rm`      |Rd = Rn / Rm            |

</div>

`ADC` 指令通常与 `ADDS` 指令配合使用，先用 `ADDS` 设置进位标志，再用 `ADC` 处理高位：

```asm
MOV  R0, #0xFFFFFFFF    ; R0 = -1 (unsigned 0xFFFFFFFF)
MOV  R1, #1
ADDS R2, R0, R1         ; R2 = 0, 设置进位 C = 1
MOV  R3, #0
ADC  R4, R3, R3         ; R4 = 0 + 0 + 1 = 1
```

64 位加法示例 `R1:R0 + R3:R2 = R5:R4`：

```asm
ADDS R4, R0, R2    ; 低 32 位相加，更新 APSR
ADC  R5, R1, R3    ; 高 32 位带进位相加
```

## 逻辑运算

<div class="table-container no-thead">

|            |                       |                  |
|:-----------|:----------------------|:-----------------|
|**按位与**  |`AND` `Rd, Rn`         |Rd = Rd & Rn      |
|            |`AND` `Rd, Rn, #immed` |Rd = Rn & #immed  |
|            |`AND` `Rd, Rn, Rm`     |Rd = Rn & Rm      |
|**按位或**  |`ORR` `Rd, Rn, Rm`     |Rd = Rn \| Rm     |
|**按位异或（Exclusive OR）**|`EOR` `Rd, Rn, Rm`     |Rd = Rn ^ Rm      |
|**按位或非（OR Not）**|`ORN` `Rd, Rn, Rm`     |Rd = Rn \| (~Rm)  |
|**位清除（Bit Clear）**  |`BIC` `Rd, Rn, Rm`     |Rd = Rn & (~Rm)   |

</div>

`BIC` 指令用于清除特定位：

```asm
BIC R0, R1, #0xFF    /* 清除 R1 的低 8 位，结果存入 R0 */
                     /* 等效于：R0 = R1 & (~0xFF)    */
```


## 移位和循环移位指令

<div align="left">
    <img src="shift.svg" style="max-height:130px"></img>
</div>

<div class="table-container no-thead">

|            |                       |                  |
|:-----------|:----------------------|:-----------------|
|**算术右移（Arithmetic Shift Right）**  |`ASR` `Rd, Rn, #immed` |Rd = Rn \>\> #immed  |
|                                        |`ASR` `Rd, Rn`         |Rd = Rd \>\> Rn      |
|                                        |`ASR` `Rd, Rn, Rm`     |Rd = Rn \>\> Rm      |
|**逻辑右移（Logical Shift Right）**     |`LSR` `Rd, Rn, #immed` |Rd = Rn \>\> #immed  |
|**逻辑左移（Logical Shift Left）**      |`LSL` `Rd, Rn, #immed` |Rd = Rn \<\< #immed  |
|**循环右移（Rotate Right）**            |`ROR` `Rd, Rn, #immed` |从右侧移出的位会循环填充到左侧空出的位置  |
|**循环右移并展开（Rotate Right with Extend）** |`RRX` `Rd, Rn`|C 标志位参与右移 1 位|

</div>

算术右移左侧用符号位填充，逻辑右移左侧用 0 填充：

```asm
MOV R0, #0xF0000000  /* R0 = 11110000 00000000 00000000 00000000              */
ASR R1, R0, #4       /* R1 = 11111111 00000000 00000000 00000000 (0xFE000000) */
```


`ROR` 指令示例：

```asm
MOV R0, #0x80000001  /* R0 = 10000000 00000000 00000000 00000001  */
ROR R1, R0, #1       /* R1 = 11000000 00000000 00000000 00000000  */
```

`RRX` 指令示例：

```asm
MOV R0, #0x80000001          /* R0 = 10000000 00000000 00000000 00000001 */
MSR APSR, #0x20000000        /* 设置 C 标志为 1 */
RRX R1, R0                   /* R1 = 11000000 00000000 00000000 00000000 (0xC0000000) */
```

```asm
MOV R0, #0x80000001          /* R0 = 10000000 00000000 00000000 00000001 */
MSR APSR, #0                 /* 清除 C 标志 */
RRX R1, R0                   /* R1 = 01000000 00000000 00000000 00000000 (0x40000000) */
```

实现 64 位数逻辑右移 4 位：

```asm
.global _start
_start:
	MOV  R0, #0x80000001   /* 低 32 位 */
	MOV  R1, #0x80000001   /* 高 32 位 */
	MOV  R2, #4            /* 循环 4 次计数 */

shift_loop:
	LSRS R1, R1, #1        /* R1 = R1 >> 1 并更新 APSR */
	RRX  R0, R0            /* R0 = {R0, C} >> 1 */
	SUBS R2, R2, #1        /* R2 = R2 - 1 并更新 APSR */
	BNE  shift_loop        /* 如果 R2 != 0 则跳转 */

.end

/*                               移位前
|          R1 = 0x8000001          |           R0 = 0x80000001        | 
10000000 00000000 00000000 00000001 10000000 00000000 00000000 00000001

                                 移位后
|          R1 = 0x0800000          |           R0 = 0x18000000        | 
00001000 00000000 00000000 00000000 00011000 00000000 00000000 00000000   */
```

## 数据转换运算

<div class="table-container no-thead">

|            |                       |                  |
|:-----------|:----------------------|:-----------------|
|**有符号展开字节为字（Signed eXtend Byte）**    |`SXTB` `Rd, Rn` | Rn = 有符号展开 Rn[7:0]，高位补符号位 |
|**有符号展开半字为字（Signed eXtend Half）**    |`SXTH` `Rd, Rn` | Rn = 有符号展开 Rn[15:0]|
|**无符号展开字节为字（Unsigned eXtend Byte）**  |`UXTB` `Rd, Rn` | Rn = 无符号展开 Rn[7:0]，高位补 0 |
|**无符号展开半字为字（Unsigned eXtend Half）**  |`UXTH` `Rd, Rn` | Rn = 无符号展开 Rn[15:0]|

</div>


```asm
LDR R0, =0x55AA8765
SXTB R1, R0    /* R1 = 0x00000065 */
SXTH R1, R0    /* R1 = 0xFFFF8765 */
UXTB R1, R0    /* R1 = 0x00000065 */
UXTH R1, R0    /* R1 = 0x00008765 */
```

<div class="table-container no-thead">

|                           |   |                       |               |
|:--------------------------|:--|:----------------------|:--------------|
|**循环移位有符号展开字节** |   |`SXTB` `Rd, Rn, ROR #n`|（n = 8/16/24）|


</div>

```asm
MOV  R0, #0x8000     /* R0 = 0x00008000 */
SXTB R1, R0, ROR #8  /* R1 = 0xFFFFFF80 */
```

<div align="left">
    <img src="rev.svg" style="max-height:200px"></img>
</div>


<div class="table-container no-thead">

|                                                |                 |   |   |   |
|:-----------------------------------------------|:----------------|:--|:--|:--|
|**反转字中的字节（Reverse）**                   |`REV` `Rd, Rn`   |   |   |   |
|**反转半字中的字节**                            |`REV16` `Rd, Rn` |   |   |   |
|**反转低半字中的字节，并将结果有符号展开**    |`REVSH` `Rd, Rn` |   |   |   |

</div>

```asm
LDR   R0, =0x12345678
REV   R1, R0  /* R1 = 0x78563412 */
REV16 R2, R0  /* R2 = 0x34127856 */

LDR   R0, =0x33448899
REVSH R3, R0  /* R3 = 0xFFFF9988 */
```

## 位域处理指令

<div class="table-container no-thead">

|                                                |                               |                                                            |
|:-----------------------------------------------|:------------------------------|:-----------------------------------------------------------|
|**清除寄存器中的位域（Bit Field Clear）**       |`BFC` `Rd, #lsb, #width`       |从 lsb 位开始清除 width 位                                  |
|**将位域插入寄存器（Bit Field Insert）**        |`BFI` `Rd, Rn, #lsb, #width`   |Rn 第 0 位开始的共 width 位，插入 Rd 第 lsb 位              |
|**前导零计数（Count Leading Zeros）**           |`CLZ` `Rd, Rn`                 |计算 Rn 最高位开始的连续 0 的个数并存入 Rd                  |
|**反转寄存器中位的顺序（Reverse Bits）**        |`RBIT` `Rd, Rn`                |如 1100 反转为 0011                                         |
|**提取位域并有符号展开（Signed Bit Field Extract）**   |`SBFX` `Rd, Rn, #lsb, #width` |提取 Rn 第 lsb 开始的 width 位并有符号展开后存入 Rd   |
|**提取位域并无符号展开（Unsigned Bit Field Extract）** |`UBFX` `Rd, Rn, #lsb, #width` |提取 Rn 第 lsb 开始的 width 位并存入 Rd               |


</div>


```asm
LDR R0, =0x1234FFFF
BFC R0, #4, #8     /* R0 = 0x1234F00F */
```

```asm
LDR R0, =0x12345678
LDR R1, =0xFFFFFFFF
BFI R1, R0, #8, #16  /* R1 = 0xFF5678FF */
```

```asm
LDR R0, =0x00FFFFFF
CLZ R1, R0           /* R1 = 8 */
```

```asm
LDR  R0, =0xC0C00000
RBIT R1, R0          /* R1 = 0x00000303 */
```

```asm
LDR  R0, =0x00000880
SBFX R1, R0, #4, #8  /* R1 = 0xFFFFFF88 */
```

```asm
LDR  R0, =0x00000880
UBFX R1, R0, #4, #8  /* R1 = 0x00000088 */
```


## 比较和测试

<div class="table-container no-thead">

|                               |                       |               |
|:------------------------------|:----------------------|:--------------|
|**比较（Compare）**            |`CMP` `Rn, Rm`         |计算 Rn-Rm     |
|                               |`CMP` `Rn, #immed`     |计算 Rn-#immed |
|**负比较（Compare Negative）** |`CMN` `Rn, #immed`         |计算 Rn+#immed     |
|**测试某些位是否被置 1（Test）**                |`TST` `Rn, #immed`  |计算 Rn&#immed，按位与| 
|**测试两个数是否按位相等（Test Equivalence）**  |`TEQ` `Rn, #immed`  |计算 Rn^#immed，按位异或|

</div>

> 以上指令均不保存计算结果，且总是会更新 APSR，因此这些指令没有 S 后缀


## 程序流程控制


<div class="table-container no-thead">

|                                           |                       |               |
|:------------------------------------------|:----------------------|:--------------|
|**跳转（Branch）**                         |`B` `lable`            |跳转到 lable 处，跳转范围 ±2KB，超出范围使用 B.W 的 32 位指令|
|**间接跳转（Branch and Exchange）**        |`BX` `Rm`              |跳转到 Rm 中存放的地址处，并且基于 Rm 第 0 位设置 ARM 或 Thumb 状态|
|**函数调用（Branch with Link）**           |`BL` `lable`           |跳转到 lable 处，并将返回地址（下一条指令的地址）保存在 LR 寄存器中|
|**函数调用**                               |`BLX` `Rm`             |跳转到 Rm 中的地址处，返回地址保存在 LR ，更新 EPSR 的 T 为 Rm 的 0 位|

</div>

> Cortex-M 处理器只支持 Thumb 状态，`BX`、`BLX` 指令中 Rm 第 0 位必须为 1

<div class="table-container no-thead">

|                                                  |                       |                             |
|:-------------------------------------------------|:----------------------|:----------------------------|
|**比较和跳转（Compare and Branch if Zero）**      |`CBZ` `Rn, lable`      |若 Rn = 0 则跳转到 lable 处  |
|**比较和跳转（Compare and Branch if None-Zero）** |`CBZ` `Rn, lable`      |若 Rn !=  0 则跳转到 lable 处|

</div>

> `CBZ` 和 `CBNZ` 不会更新 APSR 寄存器，且只能向前（更高的地址）跳转


**IT（IF-THEN）指令**

<div align="left">
    <img src="it.svg" style="max-height:200px"></img>
</div>

`IT` 指令为后续的 1-4 条指令创建了一个条件执行块：

- 第一个字母总是 T，对应 IT 指令后的第一条指令
- 后续三个字母可以是 T 或 E 或留空，可任意组合
- T 表示使用相同的条件
- E 表示使用相反的条件

```asm
MOV R0, #5
CMP R0, #5           /* 比较 R0 和 5 */
ITTEE EQ             /* 如果相等则执行前两条，否则执行后两条 */
MOVEQ R1, #1         /* R0 == 5 时执行 */
MOVEQ R2, #2         /* R0 == 5 时执行 */
MOVNE R3, #3         /* R0 != 5 时执行 */
MOVNE R4, #4         /* R0 != 5 时执行 */
```

> 在 CM3/4 中，代码中无需 `IT` 指令，`CMP` 会更新 APSR，后续指令靠条件后缀就行了，也许是为了兼容其他不支持条件后缀的处理器？？？
> 书中的描述也很是模糊？？？先插个眼？？？

**TBB 表格跳转字节（Table Branch Byte）**

<div align="left">
    <img src="tbb.svg" style="max-height:600px"></img>
</div>

```asm
TBB [PC, 3]
jumptable:
  .byte (case0 - jumptable)/2
  .byte (case1 - jumptable)/2
  .byte (case2 - jumptable)/2
  .byte (case3 - jumptable)/2

case0:
  /* case0 的代码 */
  B endswitch
case1:
  /* case1 的代码 */
  B endswitch
case2:
  /* case2 的代码 */
  B endswitch
case3:
  /* case3 的代码 */
endswitch:
  /* 后续代码 */
```

- 如果 `Rn=PC`，跳转表必须紧跟在 `TBB` 指令之后，目标地址 = PC + 2 × (查表得到的偏移量)
- `TBB` 使用 8 位偏移量，`TBH` 使用 16 位偏移量，允许更大的跳转范围
- 在 Cortex-M3/4 中，`TBB` 和 `TBH` 都只支持向前（更高的地址）跳转


**TBH 表格跳转字（Table Branch Halfword）**

- 格式：`TBH [Rn, Rm, LSL #1]`
  - `Rn`：基址
  - `Rm`：索引
  - `LSL #1`：表示将索引值左移1位（即乘以2），因为每个表项是 16 位的半字


## 饱和运算

饱和运算是指当运算结果超出目标数据类型所能表示的范围时，
结果会被限制在该数据类型所能表示的最大值或最小值，
而不是像常规运算那样发生溢出

<div class="table-container no-thead">

|                                    |                              |                                                 |
|:-----------------------------------|:-----------------------------|:------------------------------------------------|
|**有符号饱和（Signed Saturate）**   |`SSAT` `Rd, #imm, Rn{, shift}`|`shift` 为算术右移 `ASR` 或逻辑左移 `LSL`        |
|                                    |`SSAT` `R1, #16, R0`          |将 `R0` 的值饱和到 16 位有符号范围并存入 `R1`    |
|                                    |`SSAT` `R1, #8, R0, ASR #2`   |将 `R0 >> 2` 的值饱和到 8 位有符号范围并存入 `R1`|
|**无符号饱和（Unsigned Saturate）** |`USAT` `Rd, #imm, Rn{, shift}`|                                                 |

</div>

```asm
LDR  R0, =0x00020000
SSAT R1, #16, R0      /* R1 = 0x00007FFF */
USAT R2, #16, R0      /* R2 = 0x0000FFFF */
```


## 异常相关指令







## 读写 APSR ,组合程序状态字, P56
## ADR 获取标签地址
## 清除标志位 C N Z Q
## 感叹号
## mov 能使用 32 位的立即数
## 常用操作
## 分支跳转太多，就需要分支预测？
## 分支预测是硬件还是软件的工作
