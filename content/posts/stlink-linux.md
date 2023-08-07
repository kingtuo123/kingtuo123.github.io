---
author: "kingtuo123"
title: "Linux 下使用 stlink 烧录程序"
date: "2022-07-01"
summary: "stlink 工具命令用法"
description: ""
tags: [ "stm32","linux" ]
math: false
categories: [ "stm32","linux" ]
---

## 安装

详见 [Linux 下搭建 STM32 开发环境](https://kingtuo123.com/posts/linux-stm32-development/)

## 用法

### st-info

`st-flash [OPTIONS]`

|参数|说明|
|:--|:--|
| `--version` | 打印版本信息|
| `--flash` | 显示设备中可用的 flash 数量|
| `--sram` | 显示设备中可用的 sram 内存量|
| `--descr` | 显示设备的文字描述|
| `--pagesize` | 显示设备的页面大小|
| `--chipid` | 显示设备的芯片ID|
| `--serial` | 显示设备的序列号|
| `--probe` | 显示连接的编程器和设备的汇总信息|

### st-flash

`st-flash [OPTIONS] {read|write|erase} [FILE] <ADDR> <SIZE>`

|命令|说明|
|:--|:--|
| `write` `<FILE>` `<ADDR>` | 从地址 `ADDR` 开始将文件写入设备 |
| `read` `<FILE>` `<ADDR>` `<SIZE>` | 从设备 `ADDR` 读取 `SIZE` 字节到 `FILE` |
| `erase` | 擦出设备固件 |
| `reset` | 复位设备 |

|参数|说明|
|:--|:--|
| `--version` | 打印版本信息 |
| `--debug` | TODO |
| `--reset` | 在烧录前后触发复位 |
| `--opt` | 启用忽略结束空字节优化 |
| `--serial` | TODO |
| `--flash=` | 后跟大小，如 12KB，12MB，十六进制 0x12KB，八进制 012KB |

示例

```shell
$ st-flash write firmware.bin 0x8000000
$ st-flash read firmware.bin 0x8000000 0x1000
$ st-flash erase
```

### st-trace

未完待续

### st-util

未完待续
