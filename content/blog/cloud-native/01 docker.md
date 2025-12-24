---
authors:
- 1ch0
date: 2021-12-27 09:57:35
image:
  filename: docker-logo.png
  focal_point: Smart
  preview_only: false
tags:
- Docker
title: 01 Docker
---

# 01 Docker

## 1. Namespace

> namespace 是 linux 系统的底层概念，在内核层实现，即有一些不同类型的命名空间被部署在内核，各个 docker 容器运行在同一个 docker 主进程并且共用同一个宿主机系统内核，各 docker 容器运行在宿主机的用户空间，每个容器都要有类似于虚拟机一样的相互隔离的运行空间，但容器技术是在一个进程内是在哪运行指定服务的运行环境，并且还可以保护宿主机不受其他进程的干扰和影响，如文件系统空间、网络空间、进程空间等，目前主要通过以下技术实现容器运行空间的相互隔离。

|                  隔离类型                  |                功能                | 系统调用参数  |   内核版本   |
| :----------------------------------------: | :--------------------------------: | :-----------: | :----------: |
|            MNT Namespace(mount)            | 提供磁盘挂载点和文件系统的隔离能力 |  CLONE_NEWNS  | Linux 2.4.19 |
| IPC Namespace(Inter-Process Communication) |      提供进程间通信的隔离能力      | CLONE_NEWIPC  | Linux 2.6.19 |
|   UTS Namespace(UNIX Timesharing System)   |         提供主机名隔离能力         | CLONE_NEWUTS  | Linux 2.6.19 |
|   PID Namespace(Process Identification)    |          提供进程隔离能力          | CLONE_NEWPID  | Linux 2.6.24 |
|           Net Namespace(network)           |          提供网络隔离能力          | CLONE_NEWNET  | Linux 2.6.29 |
|            User Namespace(user)            |          提供用户隔离能力          | CLONE_NEWUSER |  Linux 3.8   |

### 1.1 MNT Namespace

- 每个容器都要有独立的根文件系统、独立的用户空间，以实现在容器内启动服务并且使用容器的运行环境。

- 即一个宿主机是 Ubuntu 的服务器，可以在里面启动一个 centos 运行环境的容器并且在容器里面启动个 Nginx 服务，此 Nginx 运行时使用的运行环境就是 centos 系统目录的运行环境，但是在容器里面是不能访问主机的资源，宿主机是使用了 **chroot** 技术把容器锁定到一个指定的运行目录里面并作为容器的根运行环境。



### 1.2 IPC Namespace

- 容器内的进程间通信，允许容器内的不同进程的访问。



### 1.3 UTS Namespace

- UNIX Timesharing System 包含了运行内核的名称、版本、底层体系结构类型等信息

- 用于系统标识，其中包含了 hostname 和 域名 domainname，它使得一个容器拥有属于自己 hostname 标识，这个主机名标识独立于宿主机系统和其上的其他容器。



### 1.4 PID Namespace

- Linux 系统中，有一个 PID 为 1 的进程（init/systemd）是其他所有进程的父进程，那么在每个容器内也要有一个父进程来管理其下属的自己成，那么多个容器的进程通过 PID Namespace 进程隔离（如 PID 编号重复、容器内的主进程生成与回收子进程等）。



### 1.5 Net Namespace

- 每个容器都类似于虚拟机一个样有自己的网卡、监听端口、TCP/IP 协议栈等，Docker 使用 network namespace 启动一个 vethX 接口，这样你的容器将拥有它自己的桥接 ip 地址，通常是 docker0，而docker0 实质就是 Linux 的虚拟网桥，网桥是在 OSI 七层模型的数据链路层的网络设备，通过 MAC 地址对网络进行划分，并且在不同网络直接传递数据。



### 1.6 User Namespace

- 各个容器内可能会出现重名的用户和用户组名称，或重复的用户 UID 或 GID，那么怎么隔离各个容器内的用户空间。

- User Namespace 允许在各个宿主机的各个容器空间内创建相同的用户名以及相同的用户 UID 和 GID，只是会把用户的作用范围限制在每个容器内，即 A 容器和 B 容器可以有相同的用户名称和 ID 的账户，但是此用户的有效范围仅是当前容器内，不能访问另一个容器内的文件系统，即相互隔离、互不影响、永不相见。



## 2. Cgroup

> 在一个容器内，如果不对其做任何资源限制，则宿主机会允许其占用无限大的内存空间，有时候会因为代码 BUG 导致程序一直申请内存，直到把宿主机内存占尽，为了避免此类的问题集出现，宿主机有必要对容器进行资源分配限制，比如 CPU、内存等。
>
> Linxu Cgroups，全称 Linux Control Groups，限制一个进程组能够使用的资源上限，包括 CPU、内存、磁盘、网络带宽等等，此外，还能够对进程进行优先级设置，以及将进程挂起和恢复等操作。
>
> Cgroups 在内核层默认已经开启，从 centos 和 ubuntu 对比结果来看，显然内核较新的 ubuntu 支持的功能更多。

### 2.1 查看命令

```shell
# 具体查看 /boot 目录
# 具体内核版本自行 TAB 补全

cat /boot/config-5.4.0-51-generic |grep CGROUP | grep -v "^#"
cat /boot/config-5.4.0-51-generic |grep CGROUP | grep -v "^#" |wc -l

# 查看内存限制
cat /boot/config-5.4.0-51-generic |grep MEM |grep CG |grep -v "^#"
```

### 2.2 具体实现

- blkio: 块设备 IO  限制
- cpu: 使用调度程序为 cgroup 任务提供 CPU 的访问
- cpuacct: 产生 cgroup 任务的 CPU 资源报告
- cpuet: 入股欧式多核心的 CPU，这个子系统会为 cgroup 任务分配单独的 CPU 和内存
- devices: 允许或拒绝 cgroup 任务对设备的访问
- freezer: 暂停和恢复 cgroup 任务
- memory: 设置每个 cgroup 的内存限制以及产生内存资源报告
- net_cls: 标记每个网络包以供 cgroup 仿版使员工
- ns: 命名空间子系统
- perf_event: 增加了对每个 cgroup 的监测跟踪的能力，可以监测属于某个特定的 cgroup 的所有线程以及运行在特定 CPU 上的线程



## 3. Docker Install

### 3.1 Install On Centos 7

> 注意 ：
> yum -y update：升级所有包同时也升级软件和系统内核； 
> yum -y upgrade：只升级所有包，不升级软件和系统内核。

```shell
# 查看内核版本
uname -r
# 更新 yum 包
yum -y update
# 卸载旧版 docker
yum remove -y docker docker-common docker-selinux docker-engine
# 安装依赖包
yum install -y yum-utils device-mapper-persistent-data lvm2
# 添加 yum 源
yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 查看docker 版本
yum list docker-ce --showduplicates | sort -r
# 选择 docker 版本安装
yum -y install docker-ce-3:20.10.9-3.el7
# 启动 Docker
systemctl start docker
# 开机启动 docker
systemctl enable docker
# 安装 docker compose
curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose -v

systemctl daemon-reload
service docker restart
service docker status 
```



### 3.2 Install On Ubuntu

```shell
# 备份初始源
cp /etc/apt/sources.list /etc/apt/sources.list_backup

tee /etc/apt/sources.list << EOF
#  阿里源
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF
# 添加公钥
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32


apt-get -y update 
apt-get -y upgrade
apt-get -y install build-essential
apt -y autoremove

# 卸载旧版
sudo apt-get remove docker docker-engine docker.io containerd runc
# 安装 docker 1
curl -fsSL https://get.docker.com | bash -s docker --mirror aliyun
# 安装 docker 2
curl -sSL https://get.daocloud.io/docker | sh

# 安装 docker compose
curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose -v
systemctl daemon-reload
service docker restart
service docker status 
```


### 3.3 Install bash-completion

```shell
yum install -y bash-completion
apt install -y bash-completion
source /usr/share/bash-completion/bash_completion
source /usr/share/bash-completion/completions/docker
```



## 4. Docker Command

> 官方手册
>
> [Docker 基础命令](https://docs.docker.com/engine/reference/run/)

### 4.0 build 脚本

```shell
#!/usr/bin/env bash

images=(
    'harbor.test.com/1ch0/centos-app:7.6'
    'harbor.test.com/1ch0/centos-app'
)
for image in ${images[@]}; do
    docker build -t "$image" .
    docker push "$image"
done

```



### 4.1 容器信息

```shell
#[[查看docker]]容器版本
docker version
#[[查看docker]]容器信息
docker info
#[[查看docker]]容器帮助
docker --help
```

### 4.2 镜像操作

```shell
# 删除 tag 为 none 的镜像
docker images|grep none|awk '{print $3}'|xargs docker rmi -f

#[[列出本地images]]
docker images
##含中间映像层
docker images -a
#[[只显示镜像ID]]
docker images -q
##含中间映像层
docker images -qa   
##显示镜像摘要信息(DIGEST列)
docker images --digests
##显示镜像完整信息
docker images --no-trunc
#[[搜索仓库MySQL]]镜像
docker search mysql
## --filter=stars=600：只显示 starts>=600 的镜像
docker search --filter=stars=600 mysql
## --no-trunc 显示镜像完整 DESCRIPTION 描述
docker search --no-trunc mysql
## --automated ：只列出 AUTOMATED=OK 的镜像
docker search  --automated mysql
#[[搜索仓库MySQL]]镜像
docker search mysql
## --filter=stars=600：只显示 starts>=600 的镜像
docker search --filter=stars=600 mysql
## --no-trunc 显示镜像完整 DESCRIPTION 描述
docker search --no-trunc mysql
## --automated ：只列出 AUTOMATED=OK 的镜像
docker search  --automated mysql
#[[下载Redis官方最新镜像，相当于：docker]] pull redis:latest
docker pull redis
#[[下载仓库所有Redis]]镜像
docker pull -a redis
##下载私人仓库镜像
docker pull bitnami/redis
#[[单个镜像删除，相当于：docker]] rmi redis:latest
docker rmi redis
##强制删除(针对基于镜像有运行的容器进程)
docker rmi -f redis
##多个镜像删除，不同镜像间以空格间隔
docker rmi -f redis tomcat nginx
##删除本地全部镜像
docker rmi -f $(docker images -q)

#[[（1）编写dockerfile]]
cd /docker/dockerfile
vim mycentos
#[[（2）构建docker]]镜像
docker build -f /docker/dockerfile/mycentos -t mycentos:1.1
```

### 4.3 容器操作

```shell
#[[新建并启动容器，参数：-i]]  以交互模式运行容器；-t  为容器重新分配一个伪输入终端；--name  为容器指定一个名称
docker run -i -t --name mycentos
#[[后台启动容器，参数：-d]]  已守护方式启动容器
docker run -d mycentos

##启动一个或多个已经被停止的容器
docker start redis
##重启容器
docker restart redis

[[top]]支持 ps 命令参数，格式：docker top [OPTIONS] CONTAINER [ps OPTIONS]
#[[列出redis]]容器中运行进程
docker top redis
##查看所有运行容器的进程信息
for i in  `docker ps |grep Up|awk '{print $1}'`;do echo \ &&docker top $i; done

#[[查看redis]]容器日志，默认参数
docker logs rabbitmq
#[[查看redis容器日志，参数：-f]]  跟踪日志输出；-t   显示时间戳；--tail  仅列出最新N条容器日志；
docker logs -f -t --tail=20 redis
#[[查看容器redis从2019年05月21日后的最新10]]条日志。
docker logs --since="2019-05-21" --tail=10 redis

#[[使用run]]方式在创建时进入
docker run -it centos /bin/bash
##关闭容器并退出
exit
##仅退出容器，不关闭
快捷键：Ctrl + P + Q
#[[直接进入centos]] 容器启动命令的终端，不会启动新进程，多个attach连接共享容器屏幕，参数：--sig-proxy=false  确保CTRL-D或CTRL-C不会关闭容器
docker attach --sig-proxy=false centos 
##在 centos 容器中打开新的交互模式终端，可以启动新进程，参数：-i  即使没有附加也保持STDIN 打开；-t  分配一个伪终端
docker exec -i -t  centos /bin/bash
##以交互模式在容器中执行命令，结果返回到当前终端屏幕
docker exec -i -t centos ls -l /tmp
##以分离模式在容器中执行命令，程序后台运行，结果不会反馈到当前终端
docker exec -d centos  touch cache.txt 

##查看正在运行的容器
docker ps
#[[查看正在运行的容器的ID]]
docker ps -q
##查看正在运行+历史运行过的容器
docker ps -a
##显示运行容器总文件大小
docker ps -s

##显示最近创建容器
docker ps -l
#[[显示最近创建的3]]个容器
docker ps -n 3
##不截断输出
docker ps --no-trunc 

#[[获取镜像redis]]的元信息
docker inspect redis
#[[获取正在运行的容器redis]]的 IP
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis

##停止一个运行中的容器
docker stop redis
##杀掉一个运行中的容器
docker kill redis
##删除一个已停止的容器
docker rm redis
##删除一个运行中的容器
docker rm -f redis
##删除多个容器
docker rm -f $(docker ps -a -q)
docker ps -a -q | xargs docker rm
## -l 移除容器间的网络连接，连接名为 db
docker rm -l db 
## -v 删除容器，并删除容器挂载的数据卷
docker rm -v redis

#[[基于当前redis容器创建一个新的镜像；参数：-a]] 提交的镜像作者；-c 使用Dockerfile指令来创建镜像；-m :提交时的说明文字；-p :在commit时，将容器暂停
docker commit -a="DeepInThought" -m="my redis" [redis容器ID]  myredis:v1.1

#[[将rabbitmq容器中的文件copy]]至本地路径
docker cp rabbitmq:/[container_path] [local_path]
#[[将主机文件copy至rabbitmq]]容器
docker cp [local_path] rabbitmq:/[container_path]/
#[[将主机文件copy至rabbitmq]]容器，目录重命名为[container_path]（注意与非重命名copy的区别）
docker cp [local_path] rabbitmq:/[container_path]
```

## [5. Harbor Install](https://k8scat.com/posts/harbor/install-single-instance/)

### 5.1 生成证书

```shell
apt install openssl

curl -LO https://github.com/goharbor/harbor/releases/download/v2.2.2/harbor-online-installer-v2.2.2.tgz
tar -zxvf harbor-online-installer-v2.2.2.tgz && rm -f harbor-online-installer-v2.2.2.tgz
cd harbor && ls -la

## 自建 CA
openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=CN/ST=Shenzhen/L=Shenzhen/O=example/OU=Personal/CN=k8scat.com" \
    -key ca.key \
    -out ca.crt
## 生成域名证书
openssl genrsa -out harbor.k8scat.com.key 4096
## 生成证书签名请求文件 CSR（Certificate Signing Request）
openssl req -sha512 -new \
    -subj "/C=CN/ST=Shenzhen/L=Shenzhen/O=example/OU=Personal/CN=harbor.k8scat.com" \
    -key harbor.k8scat.com.key \
    -out harbor.k8scat.com.csr
## 生成 x509 v3 扩展文件，以此来满足 SAN（Subject Alternative Name） 和 x509 v3 扩展的要求
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=harbor.k8scat.com
EOF
## 使用 ca.crt、ca.key、harbor.k8scat.com.csr 和 v3.ext 来生成我们需要的域名证书
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in harbor.k8scat.com.csr \
    -out harbor.k8scat.com.crt
```

### 5.2 配置证书

```shell
## 配置 Harbor 和 Docker 的证书
mkdir -p /data/cert/
cp harbor.k8scat.com.crt /data/cert/
cp harbor.k8scat.com.key /data/cert/

## Docker
## 转换
openssl x509 -inform PEM -in harbor.k8scat.com.crt -out harbor.k8scat.com.cert
mkdir -p /etc/docker/certs.d/harbor.k8scat.com/
cp harbor.k8scat.com.cert /etc/docker/certs.d/harbor.k8scat.com/
cp harbor.k8scat.com.key /etc/docker/certs.d/harbor.k8scat.com/
cp ca.crt /etc/docker/certs.d/harbor.k8scat.com/
systemctl restart docker

```

### 5.3 配置 harbor.yml

1. cp harbor.yml.tmpl harbor.yml
2. 修改
   - hostname : harbor.k8scat.com
   - https
     - certificate: /data/cert/harbor.k8scat.com.crt
     - private_key: /data/cert/harbor.k8scat.com.key
   - harbor_admin_password: xxx
   - database.password: xxx
3. ./install.sh
4. harbor 搭建成功([点击访问](https://139.198.166.89/))

### 5.4 up && down

```shell
cd harbor
docker-compose up
docker-compose down
```


## [6. Harbor HA](https://blog.51cto.com/qsyj/3246708)



## 7. docker 打包

```markdown
打包容器为镜像：
 docker commit 65cbaa57fe08  alg_324
镜像迁移到其他服务器：
docker image ls # 找到对应docker
docker save XXX:latest > XXX.tar # 保存docker镜像为tar文件
scp /etc/share/test.js root@123.123.123.123:/opt/soft/test.js  # scp传输，将本机镜像传输到其他服务器
docker load < XXX.tar  # 解压镜像
服务器之间传输文件－scp命令
在工作中遇到一个需求，需要在两台服务器之间传输文件，用到了scp命令，用着还挺方便。

scp是secure copy的简写，用于在Linux下进行远程拷贝文件的命令，和它类似的命令有cp，不过cp只是在本机进行拷贝不能跨服务器，而且scp传输是加密的。

使用方式：

scp [参数] [原路径] [目标路径]

常用可选参数：

-B 使用批处理模式（传输过程中不询问传输口令或短语）
-C 允许压缩。（将-C标志传递给ssh，从而打开压缩功能）
-p 保留原文件的修改时间，访问时间和访问权限。
-r 递归复制整个目录。
-P port 注意是大写的P, port是指定数据传输用到的端口号
路径规则：

user@IP:dirname
user:登录用户名
IP:登录服务器地址
dirname:文件路径
例如： root@123.123.123.123:/etc/share/test.js 表示123.123.123.123服务器上，root用户/etc/share/下的test.js文件

注意：

执行scp命令之后，会要求输入user的登录密码，（如果两台机器之前已部署ssh身份验证，则不需要）；
如果是从服务器获取文件，则目标路径直接填写本地存放路径即可。
如果是上传文件到服务器，则原路径填写本地文件路径即可。
从远程服务器复制文件到本机目录
$scp root@123.123.123.123:/opt/soft/test.js /etc/share/
表示：复制123.123.123.123机器上/opt/soft/目录下test.js文件到本机/etc/share/下。

传输本机文件到远程机器指定目录
$scp /etc/share/test.js root@123.123.123.123:/opt/soft/test.js
表示：复制本机器/etc/share/目录下test.js文件到远程123.123.123.123机器上的/opt/soft/目录下。
```

## Reference

1. https://k8scat.com/posts/harbor/install-single-instance
2. https://blog.51cto.com/qsyj/3246708
3. https://mp.weixin.qq.com/s/yXJxTR_sPdEMt56cf7JPhQ
