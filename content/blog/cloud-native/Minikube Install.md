---
authors:
- 1ch0
date: 2022-04-24 16:26:08
image:
  caption: /img/docker-logo.png
tags:
- Docker
title: Docker
---

# Minikube

## 1. Install

### 1.1 先决条件

安装 Docker：[https://www.cnblogs.com/jhxxb/p/11410816.html](https://www.cnblogs.com/jhxxb/p/11410816.html)

安装 kubectl：[https://kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

### 1.2 安装 Minikube

[https://minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/)

```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
sudo install minikube /usr/local/bin/minikube

```

### 1.3 启动

```
sudo apt-get install -y conntrack

minikube start --force --driver=docker --image-mirror-country='cn' -p prd

minikube start --driver=none --image-mirror-country='cn' -p dev

minikube start --force --driver=docker --image-mirror-country='cn' -p dev
minikube start --force --driver=docker --image-mirror-country='cn' -p prd


minikube start --force --driver=docker --image-mirror-country='cn' --nodes 2 -p multicloud

minikube start --driver=none --image-mirror-country='cn' -p dev

minikube start --force --driver=docker --image-mirror-country='cn'

minikube start --force --driver=docker --image-mirror-country='cn' -p dev

minikube start --force --driver=docker --image-mirror-country='cn' --nodes 2 -p multicloud
```

![](https://img2020.cnblogs.com/blog/1595409/202109/1595409-20210902204507588-1116181331.png)

#### 安装 ingress 启用路由访问功能：

```shell
minikube addons enable ingress -p prd

```





默认为单节点，可添加节点，[https://minikube.sigs.k8s.io/docs/commands/node](https://minikube.sigs.k8s.io/docs/commands/node)

```
minikube node list
minikube node add
```

![](https://img2020.cnblogs.com/blog/1595409/202109/1595409-20210908112252205-1596529691.png)

可视化

```
minikube dashboard --url
# 让其它 IP 可以访问
kubectl proxy --port=8888 --address='0.0.0.0' --accept-hosts='^.*'
```

![](https://img2020.cnblogs.com/blog/1595409/202109/1595409-20210902204543902-215726374.png)

访问：http://10.74.2.71:8888/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/#/overview?namespace=_all

![](https://img2020.cnblogs.com/blog/1595409/202109/1595409-20210902204952968-2145669697.png)

### 1.4 部署应用与访问应用

```
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
# 获取访问地址
minikube service --url nginx
```

![](https://img2020.cnblogs.com/blog/1595409/202109/1595409-20210908110419146-150818120.png)

```
# 也可以通过 kubectl proxy 拼接 url 访问，https://kubernetes.io/zh/docs/tasks/access-application-cluster/access-cluster/#manually-constructing-apiserver-proxy-urls
# http://10.74.2.71:8888/api/v1/namespaces/default/services/nginx:80/proxy/
```

![](https://img2020.cnblogs.com/blog/1595409/202109/1595409-20210908103557167-1148701296.png)

使用负载均衡访问，Minikube 网络：[https://minikube.sigs.k8s.io/docs/handbook/accessing](https://minikube.sigs.k8s.io/docs/handbook/accessing)

[![](http://common.cnblogs.com/images/copycode.gif)](javascript:void(0); "复制代码")

```
# 新开窗口运行
minikube tunnel --cleanup=true

# 重新部署
kubectl delete deployment nginx
kubectl delete service nginx
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
# 查看外部地址
kubectl get svc
```

[![](http://common.cnblogs.com/images/copycode.gif)](javascript:void(0); "复制代码")

![](https://img2020.cnblogs.com/blog/1595409/202109/1595409-20210908111029052-595660420.png)

通过转发访问，[https://kubernetes.io/zh/docs/tasks/access-application-cluster/port-forward-access-application-cluster](https://kubernetes.io/zh/docs/tasks/access-application-cluster/port-forward-access-application-cluster)

```
kubectl port-forward pods/nginx-6799fc88d8-p8llb 8080:80 --address='0.0.0.0'
```

![](https://img2020.cnblogs.com/blog/1595409/202109/1595409-20210908114635923-979756821.png)

### 1.5 卸载

[https://minikube.sigs.k8s.io/docs/commands/delete](https://minikube.sigs.k8s.io/docs/commands/delete)

```
minikube stop
minikube delete --all
docker rmi kicbase/stable:v0.0.25
rm -rf ~/.kube ~/.minikube
sudo rm -rf /usr/local/bin/kubectl /usr/local/bin/minikube
docker system prune -a
```

**[https://github.com/AliyunContainerService/minikube/wiki](https://github.com/AliyunContainerService/minikube/wiki)**

[**https://kubernetes.io/zh/docs/tutorials/hello-minikube**](https://kubernetes.io/zh/docs/tutorials/hello-minikube)

[**https://www.cnblogs.com/k4nz/p/14543016.html**](

[Reference](https://www.cnblogs.com/jhxxb/p/15220729.html)



## Vela
```
curl -fsSl https://static.kubevela.net/script/install-velad.sh | bash -s 1.4.2
velad install
export KUBECONFIG=$(velad kubeconfig --host)
vela comp
vela addon enable ~/.vela/addons/velaux


velad uninstall



sudo mv ./vela /usr/local/bin/vela

vela install

vela addon enable velaux serviceType=NodePort repo=acr.kubevela.net


# 获取映射的端口，通过该端口访问 VelaUX

kubectl get service velaux -n vela-system -o jsonpath="{.spec.ports[0].nodePort}"
```


```
registry.aliyuncs.com/google_containers/nginx-ingress-controller:0.26.1
```

#### Get pwd

```shell
#!/bin/bash
velapwd=$(kubectl get secret/admin -n vela-system -o yaml|grep 'admin:'| awk -F ':' '{print $2}')
echo $velapwd | base64 -d
echo
```

#### iptables

```shell
iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 127.0.0.1:32785

iptables -t nat -A POSTROUTING -p tcp -d 127.0.0.1 --dport 32785 -j SNAT --to-source 0.0.0.0:443

iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 192.168.67.2:443
```

