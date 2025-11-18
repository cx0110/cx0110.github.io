---
authors:
- 1ch0
date: 2022-01-24 08:24:00
image:
  caption: /img/default.png
tags:
- Kubernetes
title: k8s question
---

# K8s question

## 1. Init

### Unable to connect to the server: x509: certificate signed by unknown authority

#### 原因

删除集群然后重新创建，这个目录还是存在的。$HOME/.kube

#### 处理

```sh
rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### The connection to the server....:6443 was refused - did you specify the right host or port?

#### 原因

 在不关闭kubernets相关服务的情况下，对kubernets的master节点进行重启。（模拟服务器的异常掉电）

#### 处理

env | grep -i kub
systemctl status docker.service
systemctl status kubelet.service
netstat -pnlt | grep 6443
systemctl status firewalld.service

journalctl -xeu kubelet
\# docker load -i kube-apiserver-amd64_v1.9.0.tar
systemctl restart docker.service
systemctl restart kubelet.service
kubectl get nodes

### Unable to connect to the server: x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "kubernetes")


```sh
rm -rf $HOME/.kube
mkdir -p $HOME/.kube 
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```