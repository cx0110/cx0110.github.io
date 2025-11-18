---
authors:
- 1ch0
date: 2022-01-11 08:00:00
image:
  caption: /img/default.png
tags:
- Kubernetes
title: K8S-M-Docker
---

 01 docker

## 00 introduction

- containerd  1.24 之后使用 containerd 

## 01 Concept

### 镜像发布

- 镜像仓库  harbor   几十 T
- 运维 -> Api-server -> ETCD -> NODE 节点 （访问 harbor 下载镜像）-> kubectl 
-  Build -> Share -> Run

### 技术的演进

- 目前还是有很多服务跑在虚拟机上
- 公有云主要营收来自虚拟机

#### 虚拟化

- 2000 非虚拟化  模拟器 Sun

- 2001 VMwarestation

- 2006 IasS: amazon

- 2009 PaaS: heroku

- 2010 Open Source IaaS: openstack

- 2011 Open Source PaaS: cloud foundry 

- 2013 Containers: docker

- 2015 Cloud Native: Cloud Native

  

### Docker 的组成

- Host
- Server
- Client
- Registry
- Images
- Container

### Docker 对比虚拟机

- 资源利用率更高： 一台物理机可以运行数百个容器，但是一般只能运行数十个虚拟机
- 开销更小：不需要启动单独的虚拟机占用硬件资源
- 启动速度更快：可以在数秒内完成启动

## 02 Namespace

- 命名空间

- ls /proc/  查看进程相关内容，数据放在内存中

- 查询  iptables -t nat -vnl

bridge-utils

 brctl show

## 04 Cgroup

cat /boot/config- | grep CGROUP

内存限制

cat /boot/config- | grep MEM |grep CG



## 05 容器技术分类

### Containerd

k8s 通过 dockershim 调用 docker， 

1.24 之后使用 containerd，之后 dockershim 由单独公司维护

之后 k8s 直接通过 CRI Plugin 调用 containerd

ls /var/lib/system/docker.service

### 优缺点

#### 优点

- 快速部署
- 高效虚拟化
- 节省开支
- 简化配置
- 快速迁移和拓展

#### 缺点

- 隔离性
- 安全性





usermod -g docker user

## 06 容器的核心技术

### **OCI** 

> open container interface 

指定规范

https://github.com/opencontainers

### Runtime(runtime spec)

- Lxc
- runc
- rkt



### 容器定义

- Docker image
- Dockerfile
- ACI(App container image)

### 编排工具

- docker swarm
- Kubernetes 
- Mesos + Marathon





















