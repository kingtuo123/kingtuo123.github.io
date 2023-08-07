---
author: "kingtuo123"
title: "Qemu 常用命令"
date: "2023-03-12"
description: ""
summary: "Qemu 创建虚拟机"
tags: [ "qemu" ]
categories: [ "qemu" ]
---

- 参考文章
  - [Qemu-img Command Tutorial](https://www.poftut.com/linux-qemu-img-command-tutorial-examples-create-change-shrink-disk-images/)
  - [Invocation](https://qemu.readthedocs.io/en/latest/system/invocation.html)
  - [QEMU/Options](https://wiki.gentoo.org/wiki/QEMU/Options)
  - [Network bridge](https://wiki.gentoo.org/wiki/Network_bridge)
  - [QEMU Windows 11](https://zhuanlan.zhihu.com/p/384173611)
  - [TUN/TAP 设备](https://zhuanlan.zhihu.com/p/388742230)
  - [QEMU 网络配置](https://tomwei7.com/2021/10/09/qemu-network-config/#:~:text=QEMU%20%E7%BD%91%E7%BB%9C%E9%85%8D%E7%BD%AE%E9%9C%80%E8%A6%81%E7%BB%84%E5%90%88%E4%BD%BF%E7%94%A8%20-netdev%20TYPE%2Cid%3DNAME%2C...%20%E4%B8%8E%20-device%20device%20TYPE%2Cnetdev%3DNAME,netdev%20%E4%B8%AD%E7%9A%84%20id%20%E4%B8%8E%20device%20%E4%B8%AD%E7%9A%84%20netdev%20%E5%8F%82%E6%95%B0%E9%85%8D%E5%90%88%E7%94%A8%E4%BA%8E%E7%BB%84%E6%88%90%E4%B8%80%E7%BB%84%E7%BD%91%E7%BB%9C%E9%85%8D%E7%BD%AE%EF%BC%8C%E4%B8%80%E5%8F%B0%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%8F%AF%E4%BB%A5%E9%85%8D%E7%BD%AE%E5%A4%9A%E4%B8%AA%E7%BD%91%E7%BB%9C)


NIC(Network Interface Card ，网络接口卡、网卡)

## 创建虚拟磁盘


```bash
$ qemu-img create -f qcow2 ubuntu.qcow2 20G
```

- 磁盘映像类型
  - raw：默认类型（不指定 -f 参数），没有压缩、快照等特殊功能。优点是性能，比其他磁盘映像类型更快。
  - qcow2：提供压缩、快照、备份文件等功能。它在Kvm、Qemu社区很流行。
  - qed：支持 overlay 和 sparse images。Qed 的性能优于Qcow2。
  - qcow：是 Qcow2 的前身。
  - vmdk：VMware 流行使用的格式。
  - vdi：VirtualBox 流行使用的格式
  - vpc：第一代名为 Virtual PC 的 Microsoft 虚拟化工具使用的格式。

> 查看命令帮助信息：qemu-img create \-\-help


## 查看磁盘信息

```
$ qemu-img info ubuntu.qcow2
```

```
image: ubuntu.qcow2
file format: qcow2
virtual size: 20 GiB (21474836480 bytes)
disk size: 196 KiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    compression type: zlib
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
    extended l2: false
```

## 调整磁盘大小

```
$ qemu-img resize ubuntu.qcow2 +5G
```

qcow2不支持缩小镜像的操作。


## 安装系统至磁盘


```bash
$ qemu-system-x86_64 \
    -cdrom ~/Downloads/ubuntu.iso \
    -drive file=ubuntu.qcow2 \
    -enable-kvm \
    -cpu host \
    -smp cores=2,threads=2 \
    -m 2G \
    -vga virtio \
    -display sdl,gl=on 
```

### 常用参数

- -cdrom：为客户机指定光盘CD-ROM。
- -drive：定义一个存储驱动器。
  - file：磁盘映像文件
  - if：驱动器接口类型，ide, scsi, sd, mtd, floppy, pflash, virtio, none
  - index：驱动器的索引编号
  - media：介质类型，disk，cdrom
  - snapshot：on|off，为on时，qemu不会将磁盘数据的更改写回到镜像文件中
- -enable-kvm：使能KVM支持
- -cpu：cpu模型，使用 `-cpu help` 查看支持的参数
  - host：支持宿主机cpu的所有特性
- -smp：
  - cores：每个cpu核心数
  - threads：每个cpu线程数
- -m：内存大小，单位 M，G
- -vga：vga 卡类型，cirrus，std，vmware，qxl，tcx，cg3，virtio，none(Disable VGA card.)
- -display：显示器类型，通过 sdl 输出显示，gl=on 启用 opengl
- -netdev user,id=n1,ipv4=on,ipv6=off 

-machine type=q35,accel=kvm


