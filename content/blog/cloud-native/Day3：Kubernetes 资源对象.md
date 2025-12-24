---
authors:
- 1ch0
date: 2022-01-16 08:59:00
image:
  filename: python-logo.svg
tags:
- Kubernetes
title: Kubernetes 资源对象
---


# Kubernetes 资源对象

## 1. k8s 的设计理念

### 1.1 分层架构

|          云原生生态系统           |
| :-------------------------------: |
|    接口层：客户端库和实用工具     |
|     管理层：自动化和策略管理      |
|        应用层：部署和理由         |
| 核心层：Kubernetes API 和执行环境 |

| 容器运行时接口（CRI） | 容器网络接口（CNI） | 容器存储接口（CSI） | 镜像仓库 | 云供应商 | 身份供应商 |
| :-------------------: | :-----------------: | :-----------------: | :------: | :------: | :--------: |

### 1.2 API 设计原则

- 所有 API 应该是声明式的
- API 对象是彼此互补而且可组合的
- 高层 API 以操作意图为基础设计
- 低层 API 根据高层 API 的控制需要设计
- 尽量避免简单封装，不要有在外部 API 无法显示知道的内部隐藏的机制
- API 操作复杂度与对象数量成正比
- API 对象状态不能依赖于网络连接状态
- 尽量避免让操作机制依赖于全局状态，因为在分布式系统中要保证全局状态的同步是非常困难的

## 2. k8s 资源管理核心

### 2.1 API：对象（k8s 集群中的管理操作单元）

#### HOW

#### WHAT

| 类别     | 名称                                                         |
| -------- | ------------------------------------------------------------ |
| 资源对象 | Pod、ReplicaSet、ReplicationController、Deployment、StatefulSet、DaemonSet、Job、CronJob、HorizontalPodAutoscaling、Node、Namespace、Service、Ingress、Label、CustomResourceDefinition |
| 存储对象 | Volume、PersistentVolume、Secret、ConfigMap                  |
| 策略对象 | SecurityContext、ResourceQuota、LimitRange                   |
| 身份对象 | ServiceAccount、Role、ClusterRole                            |

### 2.2 k8s 命令使用

| 命令集       | 命令                                                         | 用途                    |
| ------------ | ------------------------------------------------------------ | ----------------------- |
| 基础命令     | create/delete/edit/get/describe//logs/exec/scale             | 增删改查                |
|              | explain                                                      | 命令说明                |
| 配置命令     | Label：给 node 标记 label，实现 pod 和 node 亲和性           | 标签管理                |
|              | apply                                                        | 动态配置                |
|              | cluster-info/top                                             | 集群状态                |
| 集群管理命令 | cordon：警戒线、标记 node 不被调度<br />uncordon：取消警戒线标记为 cordon 的 node<br />drain：驱逐 node 上的 pod，用于 node 下线等场景<br />taint：给 node 标记污点，实现反亲 pod 与 node 反亲和性 | node 节点管理           |
|              | api-resources/api-versions/version                           | api 资源                |
|              | config                                                       | 客户端 kube-config 配置 |

## 3. k8s — API

### 3.1 k8s 的几个重要概念

- 对象 —— 用 k8s 是和什么打交道？ k8s 声明式 API
- yaml 文件 —— 怎么打交道？   调用声明式 API
- 必须字段 —— 怎么声明？
  1. apiVersion：创建该对象所使用的 Kubernetes API 的版本
  2. kind：想要创建的对象的类型
  3. metadata：帮助识别对象唯一性的数据，包括一个 name 名称、可选的 namespace
  4. spec
  5. status：Pod 创建完成后 k8s 自动生成 status 状态

#### Yaml 文件及必须字段

- 每个 API 对象都有 3 大类属性：元数据 metadata、规范 spec 和状态 status

```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
  	metadata:
  	  labels:
  	    app: nginx
  	spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

#### Spec 和 status 的区别

- spec 是期望状态
- status 是实际状态

### 3.2 Pod

#### 概述

1. Pod 是 k8s 中的最小单元
2. 一个 pod 中可以运行一个容器，也可以运行多个容器
3. 运行多个容器的话，这些容器是一起被调度的
4. Pod 的生命周期是短暂的，不会自愈，是用完就销毁的实体
5. 一般我们是通过 Controller 来创建和管理 Pod  的

#### Pod 声明周期

- 初始化容器、启动前操作、就绪探针、存活探针、删除 Pod 操作

#### LivenessProbe 和 readinessProbe

- livenessProbe：存活探针
  - 检测应用发生故障时使用，不能提供服务、超时等
  - 检测失败重启 Pod
- readinessProbe：就绪探针
  - 检测 Pod 启动之后应用是否就绪，是否可以提供服务
  - 检测成功，Pod 才开始接收流量

### 3.3 Controller：控制器

| 控制器名称             | 版本   | 特性                  |
| ---------------------- | ------ | --------------------- |
| Replication Controller | 第一代 | = !=                  |
| ReplicaSet             | 第二代 | 新增 in  notin        |
| Deployment             | 第三代 | 新增 滚动升级、回滚等 |

### 3.4 Service

- Why
  - Pod 重建之后 ip 就变了，Pod 之间直接访问会有问题
- What
  - 解耦了服务和应用
- How
  - 声明一个 service 对象
- 一般常用的有两种
  - k8s 集群内的 service：selector 指定 Pod，自动创建 Endpoints
  - k8s 集群外的 service：手动创建 Endpoints，指定外部服务的 ip、端口和协议

#### Kube-proxy 和 service 的关系

- kube-proxy ---watch---> k8s-apiserver
- kube-proxy 监听着k8s-apiserver，一旦 service 资源发生变化（调 k8-api 修改 service 信息），kube-proxy 就会生成对应的负载调度的调整，这样就保证 service 的最新状态。
- kube-proxy 有三种调度模型
  - userspace：k8s 1.1 之前
  - iptables: 1.2-k8s1.11 之前
  - ipvs: k8s 1.11 之后，如果没有开启 ipvs，则自动降级为 iptables

### 3.5 Volume

- Why
  - 数据和镜像解耦，以及容器间的数据共享
- What
  - k8s 抽象出的一个对象，用来保存数据，做存储用
- 常用的几种卷
  - emptyDir：本地临时卷
  - hostPath：本地卷
  - nfs 等：共享卷
  - configmap：配置文件

#### EmptyDIr

- 当 Pod 被分配给节点时，首先创建 emptyDir 卷，并且只要该 Pod 在该节点上运行，该卷就会存在。正如卷的名字所述，它最初是空的。Pod 中的容器可以读取和写入 emptyDir 卷中的相同文件，尽管该卷可以挂载到每个容器中的相同或不同路径上。当出于任何原因从节点中删除 Pod 时，emptyDir 中的数据将被永久性删除。

#### HostPath

- hostPath 卷将主机节点的文件系统中的文件或目录挂载到集群中，Pod 删除的时候，卷不会删除。

#### Nfs 等共享存储

- nfs 卷允许将现有的 NFS （网络文件系统）共享挂载到容器中。与 emptyDir 不同，当删除 Pod 时，nfs 卷的内容被保留，卷仅仅是被卸载。这意味着 NFS 卷可以预填充数据，并且可以在 Pod  之间”切换“数据。NFS 可以被多个写入者同时挂载。
  - 创建多个 Pod  测试挂载同一个 NFS
  - 创建多个 Pod 测试每个 Pod 挂载多个 NFS

#### Configmap

- Why
  - 配置信息和镜像解耦
- What
  - 将配置信息放到 configmap 对象中，然后在 Pod 的对象中导入 configmap 对象，实现导入配置的操作
- How
  - 声明一个 configMap 的对象，作为 Volume 挂载到 Pod 中

### PV/PVC

- PersistentVolume（PV）
  - 是由管理员设置的存储，它是群集的一部分。
  - 就像节点时集群中的资源一样，PV 也是集群中的资源。
  - PV 是 Volume 之类的卷插件，但具有独立于使用 PV 的 Pod 的生命周期。
  - 此 API 对象包含存储实现的细节，即 NFS、iSCSI 或特定于云供应商的存储系统
- PersistentVolumeClaim（PVC）
  - 是用户存储的请求。
  - 它与 Pod 相似。Pod 消耗节点资源，PVC 消耗 PV 资源。
  - Pod 可以请求特定级别的资源（CPU 和内存）。PVC 可以请求特定的大小和访问模式（例如，可以以读/写一次或只读多次模式挂载）

### Statufulset

- Why
  - 为了解决有状态服务的问题
- What
  - 它所管理的 Pod 拥有固定的 Pod 名称，主机名，启停顺序
- How
  - 创建一个 StatefulSet 类型的 Pod ，并制定 serviceName，创建 headless 类型的 svc

### DaemonSet

- DaemonSet 在当前集群中每个节点运行同一个 Pod ，当有新的节点加入集群时也会为新的节点配置相同的 Pod ，当节点从集群中移出时其 Pod 也会被 Kubernetes 回收，但是删除 DaemonSet将删除其创建的所有的 Pod 。









