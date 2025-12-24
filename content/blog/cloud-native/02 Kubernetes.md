---
authors:
- 1ch0
date: 2022-01-07 15:33:06
image:
  filename: python-logo.svg
tags:
- Kubernetes
title: 02 Kubernetes
---

 02 [Kubernetes](https://kubernetes.io)

> [CNCF](https://cncf.io)
>
> [生态图](https://landscape.cncf.io)

## 1. 基于dockerfile构建nginx镜像

### 1.1 编写 dockerfile

```shell
# Nginx image
FROM ubuntu:20.04

LABEL "maintainer"="1ch0 github1ch0@163.com"

# COPY sources.list /etc/apt/sources.list

RUN apt update && apt install -y iproute2 ntpdate tcpdump telnet traceroute nfs-kernel-server nfs-common lrzsz tree openssl libssl-dev libpcre3 libpcre3-dev zlib1g-dev gcc openssh-server iotop unzip zip make vim && mkdir -p /data/nginx

ADD nginx-1.20.2.tar.gz /usr/local/src
RUN cd /usr/local/src/nginx-1.20.2 && ./configure --prefix=/apps/nginx && make && make install && ln -sv /apps/nginx/sbin/nginx /usr/bin && rm -rf /usr/local/src/nginx-1.20.2 && rm -rf /usr/local/src/nginx-1.20.2.tar.gz
# ADD nginx.conf /apps/nginx/conf/nginx.conf
# ADD static.tar.gz /data/nginx/html

RUN ln -sv /dev/stdout /apps/nginx/logs/access.log
RUN ln -sv /dev/stderr /apps/nginx/logs/error.log
# sed -i -E 's,listen 80;,listen 80;\n listen [::]:80;,' /etc/nginx/conf.d/default.conf

RUN groupadd -g 2022 nginx && useradd -g nginx -s /usr/sbin/nologin -u 2022 nginx && chown -R nginx.nginx /apps/nginx /data/nginx

EXPOSE 80 443
STOPSIGNAL SIGTERM

CMD ["/apps/nginx/sbin/nginx","-g","daemon off;"]

```

### 1.2 编写 build_image.sh

```shell
#!/bin/bash
#
#***********************************************************************
#         Author:            1ch0
#         Date:              2022-01-07
#         FileName:          build_image.sh
#         Description:       1ch0 script
#         Blog:               https://1ch0.github.io/
#         Copyright (C): 2022 All rights reserved
#***********************************************************************
# TAG=$1

# docker image build -t nginx:${TAG} ./

images=(
    '1ch0/nginx:ubuntu20.04'
)
for image in ${images[@]}; do
    docker build -t "$image" .
    docker push "$image"
done
```

### 1.3 docker_test.sh

```shell
#!/bin/bash

image=$(grep -m 1 1ch0 build_image.sh | awk '{print $1}')
# 删除字符中的首尾单引号
eval image=$image

echo -e "running docker image: $image\n"

docker run -it --rm -p 8080:80 "$image" bash

```



## 2. 资源限制

### 2.1 内存限制

- -m

```shell
# 限制容器最多使用 256M 内存
docker run -it --rm -m 256m --name 1ch0-test lorel/docker-stress-ng --vm 2 --vm-bytes 256M
```



### 2.2 CPU 限制

- --cpus

```shell
# 限制容器最多使用 2 核 CPU
docker run -it --rm --cpus 2 --name 1ch0-test lorel/docker-stress-ng --cpu 4 --vm 4
```

##  3. 整理k8s master和node节点各组件的功能
### [3.1 kube-apiserver](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-apiserver/)

> Kubernetes API server 提供了 k8s 各类资源对象的增删改查及 watch 等 HTTP Rest 接口，这些对象包括 pods、services、replication、controllers 等，API server 为 REST 操作提供服务，并为集群的共享状态提供前端，所有其他组件都通过该前端进行交互

- 默认端口  6443，通过启动参数 “ --secure-port ” 的值来修改默认值

- 默认 IP 地址为非本地（Non-Localhost） 网络端口，通过启动参数 “--bind-address” 设置该值

- 该端口用于接收客户端、dashboard 等外部 HTTPS 请求

- 用于基于 Token 文案或客户端证书及 HTTP Base 的认证

- 用于基于策略的授权

- 整个 Kubernetes 集群入口，负责鉴权

- 与 node 节点持续交互

- Kubernetes API 测试

  ```shell
  curl --cacert /etc/kubernetes/ssl/ca.pem -H "Authorization: Bearer ${TOKEN}" https://172.16.0.4:6443
  
  curl 127.0.0.1:6443/ #返回所有的API列表
  curl 127.0.0.1:6443/apis #分组 API
  curl 127.0.0.1:6443/api/v1 # 带具体版本号的API
  curl 127.0.0.1:6443/version # API 版本信息
  curl 127.0.0.1:6443/healthz/etcd # 与 etcd 的心跳监测
  curl 127.0.0.1:6443/apis/autoscaling/v1 # API 的详细信息
  curl 127.0.0.1:6443/metrics # 指标数据
  ```

###        [3.3 kube-scheduler](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-scheduler/)

>  Kubernetes 调度器是一个控制面进程，负责将 Pods 指派到节点上。

- 通过调度算法为待调度 Pod 列表的每个 Pod 从可用 Node 列表中选择一个最适合的 Node，并将信息写入 etcd 中
- node 节点上的 kubelet 通过 API Server 监听到 Kubernetes Scheduler 产生的 Pod 绑定信息，然后获取对应的 Pod 清单，下载 Image，并启动容器。
- 策略：
  - LeastRequestedPriority：优先从备选节点列表汇总选择资源消耗最小的节点（CPU+内存）
    1. 先配出不符合条件的节点
    2. 在剩余的可用选出一个最符合条件的节点
  - CalculateNodeLabelPriority：优先选择含有指定 Label 的节点
  - BalancedResourceAllocation：优先从备选节点列表中选择各项资源使用率最均衡的节点

###         [3.2 kube-controller-manager](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-controller-manager/)

> Controller Manager 还包括一些子控制器（副本控制器、节点控制器、命名开工阿金开工至器和服务账号控制器等），控制器作为集群内部的管理控制中心，负责集群内的 Node、Pod 副本、服务端点（Endpoint）、命名空间（Namespace）、服务账号（ServiceAccount）、资源定额（ResourceQuota）的管理，当某个 Node 意外宕机时， Controller Manager 会即使发现并执行自动化修复流程，确保集群中的 pod 副本始终处于与其的工作状态。

- Controller Manager 每间隔 5 秒检查一次节点的状态
- 如果 Controller Manager 控制器没有收到自节点的心跳，则将该 node 节点被标记位不可达。
- Controller Manager 将在标记为无法访问之前等待 40 秒
- 如果该 node 节点被标记为无法访问后 5 分钟还没有恢复，Controller Manager 会删除当前 node 节点的所有 pod 并在其它可用节点重建这些 pod 
- pod 高考用机制
  - ndoe monitor period：节点监视周期 5s
  - node monitor grace period：节点监视器宽限期 40s
  - pod eviction timeout：pod 驱逐超时时间 5m

###       [3.4 kube-proxy](https://kubernetes.io/docs/reference/config-api/)

> Kubernetes 网络代理运行在 node 上，它反映了 node 上 Kubernetes API 中定义的服务，并可以通过一组后盾进行简单的 TCP、UDP 和 SCTP 流转发或者在一组后端进行循环 TCP、UDP 和 SCTP 转发，yognhu8必须使用 apiserver API 创建一个服务来配置代理，其实就是 kube proxy 通过在主机上维护网络规则并执行廉洁转发来实现 Kubernetes 服务访问

- kube proxy 运行在每个节点上，监听 API Server 中服务对象的变化，再通过管理 IPtables 或者 IPVS 规则来实现网络的转发

- 和 apiserver 进行交互，将请求写到 etcd，用来维护网络规则

- kube proxy 不同的版本可支持三种工作模式
  - UserSpace：k8s v1.1之前使员工，k8s 1.2及以后就已经淘汰
  - IPtables：k8s 1.1版本开始支持，1.2 开始为默认
  - IPVS：k8s 1.9 引入到 1.11 为正式版本，需要安装 ipvsadm、ipset 工具包和加载 ip_vs 内核模块
  
- IPVS 相对 IPTables 效率会更高一些，使用 IPVS 模式需要在运行 kube proxy 的节点上安装 ipvsadm 、ipset 工具包和加载 ip_vs 内核模块，当 kube proxy 以 IPVS 代理模式启动时，kube proxy 将验证节点上是否安装了 IPVS 模块，如果未安装，则 kube proxy 将回退到 IPTables 代理模式

- 使用 IPVS 模式，kube proxy 会监视 Kubernetes Service 对象和 Endpoints，调用宿主机内核 Netlink 接口以相应地创建 IPVS 规则并定期与 Kubernetes Service 对象 Endpoints 对象同步 IPVS 规则，以确保 IPVS 状态与期望一直，访问服务时，流量将被重定向到其中一个后端 Pod，IPVS 规则，以确保 IPVS 状态与期望一致，访问服务时，流量将被重定向到其中一个后端 Pod，IPVS 使用哈希表作为底层数据结构并在内核开工阿金中工作，这意味着 IPVS 可以更快的重定向流量，兵器在同步代理规则时具有更好的性能，此外，IPVS 为负载均衡算法提供了更多选项，例如：rr（轮训调度）、lc（最小连接数）、dh（目标哈希）、sh（源哈希）、sed（最短期望延迟）、nq（不排队调度）等

- [配置使用 IPVS 及制定调度算法](https://kubernetes.io/docs/reference/config-api/kube-proxy-config.v1alpha1/#ClientConnectionConfiguration)

  kube-proxy-config.yaml

  ```shell
  kind: KubeProxyConfiguration
  apiVersion: Kubeproxy.config.k8s.io/v1alpha1
  bindAddress: 172.31.7.111
  clientConnectino:
    kubeconfig: "/etc/kubernetes/kube-proxy.kubeconfig"
  clusterCIDR: "10.100.0.0/16"
  conntrack:
    maxPerCore: 32768
    min: 131072
    tcpCloseWaitTimeout: 1h0m0s
    tcpEstablishedTimeout: 24h0m0s
  healthzBinAddress: 172.31.7.111:10256
  hostnameOverride: "172.31.7.111"
  metricsBindAddress: 172.31.7.111:10249
  mode: "ipvs" # 指定使用 ipvs 及调度算法
  ipvs:
    scheduler: sh
  ```

- 开启会话保持

  nginx-service.yaml

  ```shell
  kind: Service
  apiVersion: v1
  metadata:
    labels:
      app: nginx-service-label
    name: nginx-service
    namespace: echoc
  spec:
    type: NOdePort
    ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
      nodePort: 30004
    selector:
      app: nginx
    sessionAffinity: ClientIP
    sessionAffinityConfig:
      clientIP:
        timeoutSeconds: 1800
  ```

###       [3.5 kubelet](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kubelet/)

> kubelet 是运行在每个 worker 节点的代理组件，它会监视已分配给节点的 pod
>
> 是一个通过命令行对 Kubernetes 集群进行管理的客户端工具

- 向 master 汇报 node 节点的状态信息
- 接收指令并在 pod 中创建 docker 容器
- 准备 pod 所需的数据卷
- 返回 pod 的运行状态

###         3.6 etcd

- 在 node 节点执行容器健康检查

### [3.6 etcd](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)

> etcd 是 CoreOS 公司开发，目前是 Kubernetes 默认使用 的 key-value 数据存储系统，用于保存 Kubernetes 的所有集群数据，etcd 支持分布式集群功能，生产环境使用时需要为 etcd 数据提供定期备份机制。
>
> 官网：https://etcd.io/
>
> github: https://github.com/etcd-io/etcd

###         3.7 组件

#### [3.7.1 DNS](https://kubernetes.io/zh/docs/concepts/services-networking/dns-pod-service/)

> DNS 负责为整个集群提供 DNS 服务，从而实现服务之间的访问
>
> coredns
>
> kube-dns: 1.18
>
> sky-dns

#### 3.7.2 Dashboard

> Dashboard 是基于网页的 Kubernetes 用户界面，可以使用 Dashboard 获取运行在集群中的应用的概览信息，也可以创建或者修改 Kubernetes 资源（如 Deployment、Job、DaemonSet 等等），也可以对 Deployment 实现弹性伸缩、发起滚动升级、重启 Pod 或者使用向导创建新的应用。



 ##   4. 部署高可用的k8s集群

### 4.1 使用 sealos 安装k8s

```shell
# 下载并安装sealos, sealos是个golang的二进制工具，直接下载拷贝到bin目录即可, release页面也可下载
wget -c https://sealyun.oss-cn-beijing.aliyuncs.com/latest/sealos && \
    chmod +x sealos && mv sealos /usr/bin

# 下载离线资源包
wget -c https://sealyun.oss-cn-beijing.aliyuncs.com/05a3db657821277f5f3b92d834bbaf98-v1.22.0/kube1.22.0.tar.gz

# 安装一个三master的kubernetes集群
sealos init --passwd '123456' \
	--master 192.168.0.2  --master 192.168.0.3  --master 192.168.0.4  \
	--node 192.168.0.5 \
	--pkg-url /root/kube1.22.0.tar.gz \
	--version v1.22.0
```

安装结果

![](/img/default.png)



