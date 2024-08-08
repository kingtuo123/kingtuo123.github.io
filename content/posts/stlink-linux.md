---
title: "Linux 下使用 stlink 烧录程序"
date: "2022-07-01"
summary: "stlink 命令行下载工具"
description: ""
categories: [ "embedded" ]
tags: [ "stm32" ]
---

## 命令

  - st-info
  - st-flash
  - st-trace
  - st-util

### st-info 读取设备信息

|参数|说明|
|:--|:--|
|\-\-version| 打印版本信息|
|\-\-flash| 显示设备中可用的 flash 数量|
|\-\-sram| 显示设备中可用的 sram 内存量|
|\-\-descr| 显示设备的文字描述|
|\-\-pagesize| 显示设备的页面大小|
|\-\-chipid| 显示设备的芯片ID|
|\-\-serial| 显示设备的序列号|
|\-\-probe| 显示连接的编程器和设备的汇总信息|

### st-flash 读写 flash

常用示例：

```bash
# 烧录 bin 文件
st-flash --format binary write firmware.bin 0x08000000
# 烧录 hex 文件
st-flash --format ihex write firmware.hex
# 从 FLASH 读取 0x1000 个字节
st-flash read firmware.bin 0x08000000 0x1000
# 擦除 FLASH
st-flash erase
```
