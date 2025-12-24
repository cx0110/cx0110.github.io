---
title: Kubernetes Install
image:
  filename: python-logo.svg
tags:
  - Kubernetes
authors:
  - 1ch0
date: 2021-10-25 11:25:09
---

# Kubernetes

## 安装脚本

kubernetes-intstall-on-centos7.sh

- 升级内核

```shell
# 升级内核
# 安装新内核
wget https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-5.4.114-1.el7.elrepo.x86_64.rpm
wget https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-lt-devel-5.4.114-1.el7.elrepo.x86_64.rpm
yum -y install  kernel-lt-5.4.114-1.el7.elrepo.x86_64.rpm kernel-lt-devel-5.4.114-1.el7.elrepo.x86_64.rpm
# 调整默认内核启动
grub2-set-default "CentOS Linux (5.4.114-1.el7.elrepo) 7 (Core)"
# 检查是否修改正确并重启系统
grub2-editenv list
reboot
```

后续步骤整合

```shell
[[开启IPVS]] 支持
cat <<EOF> /etc/sysconfig/modules/ipvs.modules
#!/bin/bash
ipvs_modules="ip_vs ip_vs_lc ip_vs_wlc ip_vs_rr ip_vs_wrr ip_vs_lblc ip_vs_lblcr ip_vs_dh ip_vs_sh ip_vs_fo ip_vs_nq ip_vs_sed ip_vs_ftp nf_conntrack"
for kernel_module in ${ipvs_modules}; do
  /sbin/modinfo -F filename ${kernel_module} > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    /sbin/modprobe ${kernel_module}
  fi
done
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules
sh /etc/sysconfig/modules/ipvs.modules
lsmod | grep ip_vs
# 关闭防火墙、selinux
systemctl stop firewalld && systemctl disable firewalld
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
# 关闭系统的交换分区
swapoff -a
cp /etc/fstab  /etc/fstab.bak
cat /etc/fstab.bak | grep -v swap > /etc/fstab
# 修改 iptables 设置
cat <<EOF>>/etc/sysctl.conf
vm.swappiness = 0
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl -p
cat <<EOF>> /etc/hosts
127.0.0.1   localhost
192.168.0.10  k8smaster
192.168.0.11  k8snode1
192.168.0.12  k8snode2
192.168.0.13  k8snode3
192.168.0.21  k8snode4
192.168.0.22  k8snode5
EOF
# 指定阿里云 yum 源
cat <<EOF > /etc/yum.repos.d/k8s.repo
[k8s]
name=k8s
enabled=1
gpgcheck=0
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
EOF
# 查询可安装版本，指定版本进行安装
yum list kubelet
yum list kubectl
yum list kubeadm
# 安装 kubeadm、kubelet、kubectl

yum install -y kubelet-1.21.0-0 kubeadm-1.21.0-0 kubectl-1.21.0-0
# 将 kubectl 设置为开机启动

systemctl daemon-reload && systemctl enable kubelet
kubeadm config print init-defaults
kubeadm config images list
kubeadm config images list --kubernetes-version=v1.21.0 --image-repository swr.myhuaweicloud.com/iivey

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
systemctl restart docker
echo "source <(kubectl completion bash)" >> ~/.bashrc

```



- 开启 IPVS 支持

```shell
[[开启IPVS]] 支持
cat <<EOF> /etc/sysconfig/modules/ipvs.modules
#!/bin/bash
ipvs_modules="ip_vs ip_vs_lc ip_vs_wlc ip_vs_rr ip_vs_wrr ip_vs_lblc ip_vs_lblcr ip_vs_dh ip_vs_sh ip_vs_fo ip_vs_nq ip_vs_sed ip_vs_ftp nf_conntrack"
for kernel_module in ${ipvs_modules}; do
  /sbin/modinfo -F filename ${kernel_module} > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    /sbin/modprobe ${kernel_module}
  fi
done
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules
sh /etc/sysconfig/modules/ipvs.modules
lsmod | grep ip_vs


```

- 关闭防火墙、selinux

```shell
# 关闭防火墙、selinux
systemctl stop firewalld && systemctl disable firewalld
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
# 关闭系统的交换分区
swapoff -a
cp /etc/fstab  /etc/fstab.bak
cat /etc/fstab.bak | grep -v swap > /etc/fstab
修改 iptables 设置
cat <<EOF>>/etc/sysctl.conf
vm.swappiness = 0
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl -p

```

- 时区

```shell
yum install -y ntp
systemctl enable ntpd
systemctl start ntpd
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp yes
ntpq -p

```



- 主机名本地解析配置

```shell
cat <<EOF> /etc/hosts
127.0.0.1   localhost
192.168.0.10  k8smaster
192.168.0.11  k8snode1
192.168.0.12  k8snode2
192.168.0.13  k8snode3
192.168.0.21  k8snode4
192.168.0.22  k8snode5
EOF
hostnamectl set-hostname
```

- 安装 kubeadm、kubelet、kubectl 工具

```shell
# 指定阿里云 yum 源
cat <<EOF > /etc/yum.repos.d/k8s.repo
[k8s]
name=k8s
enabled=1
gpgcheck=0
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
EOF
# 查询可安装版本，指定版本进行安装
yum list kubelet
yum list kubectl
yum list kubeadm
# 安装 kubeadm、kubelet、kubectl

yum install -y kubelet-1.21.0-0 kubeadm-1.21.0-0 kubectl-1.21.0-0
# 将 kubectl 设置为开机启动

systemctl daemon-reload && systemctl enable kubelet

```



- 初始化 k8s 集群

```shell
[root@vm210 ~]# kubeadm init   --image-repository registry.aliyuncs.com/google_containers   --kubernetes-version v1.21.0   --apiserver-advertise-address=192.168.0.130
[init] Using Kubernetes version: v1.22.0
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR NumCPU]: the number of available CPUs 1 is less than the required 2
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher

[root@vm210 ~]# kubelet --cgroupDriver
E0821 18:06:43.647211    8799 server.go:158] "Failed to parse kubelet flag" err="unknown flag: --cgroupDriver"

[root@vm210 ~]# systemctl status kubelet
● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; vendor preset: disabled)
  Drop-In: /usr/lib/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: activating (auto-restart) (Result: exit-code) since 六 2021-08-21 18:19:45 CST; 5s ago
     Docs: https://kubernetes.io/docs/
  Process: 8186 ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS (code=exited, status=1/FAILURE)
  Main PID: 8186 (code=exited, status=1/FAILURE)

8月 21 18:19:45 vm210 systemd[1]: kubelet.service: main process exited, code=exited, status=1/FAILURE
8月 21 18:19:45 vm210 systemd[1]: Unit kubelet.service entered failed state.
8月 21 18:19:45 vm210 systemd[1]: kubelet.service failed.

[root@vm210 ~][[vim]] /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
[root@vm210 ~][[systemctl]] daemon-reload
[root@vm210 ~][[systemctl]] restart docker
// unable to configure the Docker daemon with file /etc/docker/daemon.json
// choose to install docker-ce will solve this problem.

[root@vm210 ~][[systemctl]] restart kubelet

// run kuebeadm again
ERROR: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
errors pretty printing info
, error: exit status 1
	[ERROR Service-Docker]: docker service is not active, please run 'systemctl start docker.service'

[root@vm210 ~][[systemctl]] start docker.service

error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR ImagePull]: failed to pull image registry.aliyuncs.com/google_containers/coredns:v1.8.4: output: Error response from daemon: manifest for registry.aliyuncs.com/google_containers/coredns:v1.8.4 not found: manifest unknown: manifest unknown

[root@vm210 ~]# docker pull coredns/coredns
Using default tag: latest
latest: Pulling from coredns/coredns
c6568d217a00: Pull complete
bc38a22c706b: Pull complete
Digest: sha256:6e5a02c21641597998b4be7cb5eb1e7b02c0d8d23cce4dd09f4682d463798890
Status: Downloaded newer image for coredns/coredns:latest
docker.io/coredns/coredns:latest

[root@vm210 ~]# docker images
REPOSITORY                                                        TAG       IMAGE ID       CREATED        SIZE
registry.aliyuncs.com/google_containers/kube-apiserver            v1.22.0   838d692cbe28   2 weeks ago    128MB
registry.aliyuncs.com/google_containers/kube-controller-manager   v1.22.0   5344f96781f4   2 weeks ago    122MB
registry.aliyuncs.com/google_containers/kube-proxy                v1.22.0   bbad1636b30d   2 weeks ago    104MB
registry.aliyuncs.com/google_containers/kube-scheduler            v1.22.0   3db3d153007f   2 weeks ago    52.7MB
registry.aliyuncs.com/google_containers/etcd                      3.5.0-0   004811815584   2 months ago   295MB
coredns/coredns                                                   latest    8d147537fb7d   2 months ago   47.6MB
registry.aliyuncs.com/google_containers/pause                     3.5       ed210e3e4a5b   5 months ago    683kB

[root@vm210 ~]# docker tag coredns/coredns:latest registry.aliyuncs.com/google_containers/coredns:v1.8.4

[root@vm210 ~]# docker rmi coredns/coredns:latest

// success infomation
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.56.130:6443 --token i36hnn.8trjybo0msel27y6 \
	--discovery-token-ca-cert-hash sha256:4667ecb1cbe7692b8bef1d3fac79be22a8cf3d2086f8fd5538e00fb2b08b9ee3

```




```shell
kubeadm config print init-defaults
kubeadm config images list
kubeadm config images list --kubernetes-version=v1.21.0 --image-repository swr.myhuaweicloud.com/iivey

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
systemctl  restart docker
echo "source <(kubectl completion bash)" >> ~/.bashrc

kubeadm config print init-defaults > kubeadm.yaml
kubeadm init --config=kubeadm.yaml

kubeadm version
kubeadm init --kubernetes-version=v1.21.0 --image-repository registry.aliyuncs.com/google_containers --apiserver-advertise-address 192.168.0.102 --pod-network-cidr=10.244.0.0/16
```

- master 节点

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

```yaml
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 1.2.3.4
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: node
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.aliyuncs.com/google_containers
kind: ClusterConfiguration
kubernetesVersion: 1.21.0
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
scheduler: {}
```

```shell
kubeadm init --image-repository registry.aliyuncs.com/google_containers  \
    --kubernetes-version v1.21.0  \
    --apiserver-advertise-address=192.168.0.10 \
    --pod-network-cidr=10.100.0.0/16
```



- 添加集群节点

```shell
kubeadm join 172.16.213.221:6443 --token bnefy8.d79yn6ylxlk7k8hr     --discovery-token-ca-cert-hash sha256:eaa17f4b308e9406891f85f664c0d2c97a49bd9e963f64c9453b7042509e106c
kubectl get node
```

生成 token

```shell
kubeadm token create --ttl 0 --print-join-command

```

>  查看日志
>
> journalctl -f -u kubelet.service

****

- 安装网络插件

  - Flannel

    ```shell
    export POD_SUBNET=10.100.0.0/16
    kubectl apply -f https://kuboard.cn/install-script/v1.21.x/calico-operator.yaml
    wget https://kuboard.cn/install-script/flannel/flannel-v0.14.0.yaml
    sed -i "s#10.244.0.0/16#${POD_SUBNET}#" flannel-v0.14.0.yaml
    kubectl apply -f ./flannel-v0.14.0.yaml
    ```

  - Calico

    - ```shell
    wget https://docs.projectcalico.org/manifests/tigera-operator.yaml
      wget https://docs.projectcalico.org/manifests/custom-resources.yaml
    vim custom-resources.yaml
        cidr: 192.168.0.0/16  => cidr: 10.100.0.0/16
      kubectl create -f tigera-operator.yaml
      kubectl create -f custom-resources.yaml
      watch kubectl get pods -n calico-system
      watch kubectl get nodes
      ```



    - 方法一

      ```shell
      wget https://docs.projectcalico.org/manifests/calico.yaml
      kubectl apply -f calico.yaml
      kubectl  get node
      kubectl get pods -n kube-system
      watch kubectl get pods -n calico-system
      ```

    - 方法二



    ```shell
    export POD_SUBNET=10.100.0.0/16
    kubectl apply -f https://kuboard.cn/install-script/v1.21.x/calico-operator.yaml
    wget https://kuboard.cn/install-script/v1.21.x/calico-custom-resources.yaml
    sed -i "s#192.168.0.0/16#${POD_SUBNET}#" calico-custom-resources.yaml
    kubectl apply -f calico-custom-resources.yaml

    ```



- 安装 kubernetes-dashboard

  可从https://github.com/kubernetes/dashboard/releases/tag/v2.2.0 下载最新的dashboard/资源文件，然后进行安装。

  下载下来的文件名为recommended.yaml，默认情况下此文件中的几个镜像地址，国内无法访问，需要修改

```shell
kubectl apply -f  recommended.yaml
# 查看 Kubernetes-dashboard 随机的访问端口
kubectl  get svc -n kubernetes-dashboard
```

此时，可以通过集群任意一个节点的ip加上32081端口访问kubernetes-dashboard 。

访问dashboard需要认证，因此还需要创建一个认证机制，执行如下命令，创建一个ServiceAccount用户dashboard-admin：

```shell
kubectl create serviceaccount dashboard-admin -n kube-system
serviceaccount/dashboard-admin created
```



然后将dashboard-admin用户与角色绑定:

```shell
 kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
clusterrolebinding.rbac.authorization.k8s.io/dashboard-admin created
```



最后，查看Token令牌，执行如下组合命令：

[root@master k8s]# kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}')
1.

此命令输出中，token就是令牌，复制出来保存。有了令牌后，就可以在dashboard选择令牌登录了。


https://blog.51cto.com/ixdba/2857919

```javascript
注意
yum -y update：升级所有包同时也升级软件和系统内核；
yum -y upgrade：只升级所有包，不升级软件和系统内核
```

## 常用命令

```shell

```