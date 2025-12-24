---
authors:
- 1ch0
date: 2022-01-24 08:02:00
image:
  filename: python-logo.svg
tags:
- Kubernetes
title: null
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [blog.csdn.net](https://blog.csdn.net/sinat_28371057/article/details/109895159)

问题 “The connection to the server <master>:6443 was refused - did you specify the right host or port?” 的处理！

一、故障产生

    在不关闭 kubernets 相关服务的情况下，对 kubernets 的 master 节点进行重启。（模拟服务器的异常掉电）

二、故障状况

  启动后无法远程到 kubernets 的 dashbaord，后进行如下命令报错。

```
# kubectl get nodes
The connection to the server <master>:6443 was refused - did you specify the right host or port?
```

故障处理：

1. 检查环境变量情况（正常）

```
# systemctl restart docker.service
 
# systemctl restart kubelet.service
```

![](https://img-blog.csdnimg.cn/img_convert/e72726c87380dcbff791d72df9a1d3f9.png)

2. 检查 docker 服务（正常）

```
# systemctl status docker.service
```

![](https://img-blog.csdnimg.cn/img_convert/bd519e0d8452303417672cdb6be81e84.png)

3. 检查 kubelet 服务（表面正常）

```
# systemctl status kubelet.service
```

![](https://img-blog.csdnimg.cn/img_convert/d1e3bde5b653ea141d885ac47b92d9d3.png)

4. 查看端口是是否被监听（没有监听）

```
# netstat -pnlt | grep 6443
```

5. 检查防火墙状态（正常）

```
# systemctl status firewalld.service
```

![](https://img-blog.csdnimg.cn/img_convert/af5554c2f58568acb7c9c222b8298ee6.png)

6. 查看日志

```
# journalctl -xeu kubelet
```

![](https://img-blog.csdnimg.cn/img_convert/15c8f4a793a7d9a38a90042ee0b7d2fb.png)

这里分析，应该是镜像的问题。

6.1 重新导入一下 API 镜像即可。

```
# docker load -i kube-apiserver-amd64_v1.9.0.tar
```

6.2 重启 docker 和 kubelet 服务

```
# systemctl restart docker.service
 
# systemctl restart kubelet.service
```

6.3 检查服务（此时正常）

```
# kubectl get nodes
```

![](https://img-blog.csdnimg.cn/img_convert/036bbf9f0dd20c5d2b5a44311894bebd.png)

至此，故障处理完成。