---
layout: default
title: Modbus协议CRC校验
parent: STM32
nav_order: 16
---


# Modbus协议CRC校验
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---


## 什么是CRC

循环冗余校验码(cyclie redundancy check)简称CRC（循环码）。

## CRC算法原理

假如有数据A：**1011 1001**

以CRC-4为例计算该数据的CRC码，它的多项式公式 **g(x) = x⁴ + x + 1** , 用二进制表示为 **10011**

- 计算它的CRC码（冗余位）： 

   1 CRC-4表示所得CRC码为4位，在数据A右侧补上4个0，数据A：**1011 1001 0000**

   2 数据A做被除数，用除数 **10011** 做**模2除法**，如下图

   - <img src="https://knote.oss-cn-hangzhou.aliyuncs.com/img/CRC-%E6%A8%A12%E9%99%A4%E6%B3%95.png" style="height:350px"  align="left"/>



 
  
   
    
     
      
       












- 关于模2除法：
   - 本质是**异或运算**
   - 舍去最左侧0，以1对齐

最后结果 **1001** 就是CRC冗余位，将它附加在**原数据帧末尾**，构建成一个新的数据帧进行发送；最后接收方将**整个**数据帧以**模2除法**除相同的**除数**，如果没有余数，则说明数据帧在传输的过程中没有出错。
















## CRC算法参数模型

为了方便机器更好的计算CRC所以制定了一些规则，添加了一些参数参与计算，称为CRC参数模型。如CRC-8、CRC-16/MODBUS、CRC-32。

- 以CRC-16/MODBUS为例，它的参数模型如下：

|CRC算法名称|多项式公式|宽度|多项式|初始值|结果异或值|输入反转|输出反转|
|:--|:--|:--|:--|:--|:--|:--|:--|
|CRC-4/ITU|x⁴ + x + 1|4|03|00|00|true|true|
|CRC-16/MODBUS|x¹⁶ + x¹⁵ + x² + 1|16|8005|FFFF|0000|true|true|

- **CRC算法参数模型解释：** 

   - CRC算法名称（NAME）：名称后面的数字就表示生成的冗余位的位数。 

   - 宽度（WIDTH）：CRC校验宽度，即CRC比特数。 

   - 多项式（POLY）：生成项的简写，以16进制表示。例如：CRC-16/MODBUS即是0x8005，**忽略最高位的"1"**，即完整的生成项是0x18005。 

   - 初始值（INIT）：算法开始时计算（crc）的**初始化预置值**，一般取值FFFF或0000。当数据前几位为0时，因为模2除法会忽略0，先用FFFF异或将0取反为1，再进行模2除法，使数据开头的0也参与运算，以上是个人理解仅供参考。 

   - 结果异或值（REFIN）：计算结果和该值异或运算。 

   - 输入反转（REFOUT）：输入数据高低位互换，类似镜像。

   - 输出反转（XOROUT）：计算结果高低位互换，类似镜像。





## 为什么可以忽略最高位的"1"

以CRC-4为例，它的多项式公式 **g(x) = x⁴ + x + 1** , 用二进制表示为 **10011**，多项式用十六进制表示应该是13，为什么参数模型里用03表示？

再来观察上面的式子,看下图左侧，模2除法里除数和被除数左侧以1对齐后再异或运算，最左侧1在每次运算后都会被丢弃（因为1异或1为0，而模2除法会舍去0），并不会对最终结果产生影响

<img src="https://knote.oss-cn-hangzhou.aliyuncs.com/img/CRC-%E5%8E%BB1.png" style="height:350px"  align="left"/>

我们把除数左侧的1去掉，如图右侧所示，可以看出，只要将除数与被除数的第2位对齐再异或运算 ，最后结果是一样的，所以除数最高位1可以舍去，13就可以简写为03。



## 直接计算法 - 正/反向

- 以CRC-16/MODBUS参考模型为例编程
   - 第一步，输入数据反转，**只反转单个字节不改变字节顺序**，例如0x0903反转为0x90C0
   - 第二步，定义初始值FFFF，以除数8005进行模2运算
   - 最后，输出数据反转,**反转整个CRC寄存器**，例如0x0903反转为0xC090

```c
#include<stdio.h>

/* 字节反转 */
unsigned char Flip(unsigned char data) {
 	data = ((data&0x55)<<1)|((data&0xaa)>>1);
	data = ((data&0x33)<<2)|((data&0xcc)>>2);
	data = ((data&0x0f)<<4)|((data&0xf0)>>4);   
	return data;
}
/* CRC算法正向 */
unsigned short CRC16( unsigned char * data, unsigned short len) {
   int i,j;
   unsigned short CRC = 0xFFFF;  /* CRC寄存器，初始化预置值 */
   for( i = 0;i < len; i++ ) {
      CRC ^= (unsigned short)Flip(*data++)<<8;  /* 单个字节反转 */
      for(j = 0; j< 8; j++) {
         if(CRC & 0x8000)
            CRC = CRC << 1 ^ 0x8005;
         else
            CRC <<= 1;
      }
   }
	CRC = (unsigned short)Flip((unsigned char)CRC)<<8|Flip((unsigned char)(CRC>>8)); /* 全反转 */
   return CRC;
}
/* CRC算法反向，比正向效率要高，网上找的算法大多是反向的*/
unsigned short CRC16_Rev( unsigned char * data, unsigned short len) {
   int i,j;
   unsigned short CRC = 0xFFFF; 
   for( i = 0;i < len; i++ ) {
      CRC ^= *data++;
      for(j = 0; j< 8; j++) {
         if(CRC & 0x0001)
            CRC = CRC >> 1 ^ 0xA001; /* 8005反转就是A001 */
         else
            CRC >>= 1;
      }
   }
   return CRC;
}

int main(void) {
   unsigned char data[6] = {0x01,0x04,0x00,0x00,0x00,0x01};
   printf("%x\n",CRC16(data,6));     /* CRC算法正向 */
   printf("%x\n",CRC16_Rev(data,6)); /* CRC算法反向 */

   getchar();
   return 0;
}
```

这里举一个简单的例子。假设从设备地址为1,要求读取输人寄存器地址30001的值，则RTU模式下具体的查询消息帧如下：
**0x01，0x04，0x00，0x00，0x00，0x01，0x31，0xCA**
其中，**0xCA31**即为CRC值。因为Modbus规定发送时CRC必须低字节在前，高字节在后，因此实际的消息帧的发送顺序为**0x31,0xCA**。

## 查表法

异或运算有结合律：**(a^b)^c=a^(b^c)**

大概的原理如下图

<img src="https://knote.oss-cn-hangzhou.aliyuncs.com/img/CRC%E6%9F%A5%E8%A1%A8%E6%B3%95.png" style="height:450px"  align="left"/>

8位一共有256种结果，可以先将结果计算好后存入数组中。按16位查表太多有65536种结果。所以按8位查表是最合适的。

