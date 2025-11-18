---
authors:
- 1ch0
date: 2021-10-15 10:51:24
image:
  caption: /img/docker-logo.png
tags:
- Docker
title: Docker
---

# Docker 

## 安装脚本

docker-intstall-on-centos7.sh

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
sudo service docker restart
sudo service docker status 
```

```javascript
注意 
yum -y update：升级所有包同时也升级软件和系统内核； 
yum -y upgrade：只升级所有包，不升级软件和系统内核
```

- docker compose 安装

```shell
curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose -v

```

### on ubuntu

```sh
curl -sSL https://get.daocloud.io/docker | sh
# 启动 Docker
systemctl start docker
# 开机启动 docker
systemctl enable docker
# 安装 docker compose
curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose -v

systemctl daemon-reload
sudo service docker restart
sudo service docker status 
```







## 常用命令

```shell
docker pull ubuntu:16.04
docker run -it --rm ubuntu:16.04 /bin/bash # -t 分配伪终端 -i 让容器的标准输入保持打开
docker image ls  # docker image ls列表中的镜像体积总和并非是所有镜像实际硬盘消耗
docker system df # 查看镜像、容器、数据卷所占用的空间
docker container start
docker run container -d # -d 在后台运行而不是把执行命令的结果输出在当前宿主机下
docker logs # 查看容器运行结果
docker container ls # 查看容器信息
docker container stop # 终止一个运行中的容器
docker exec -i ID bash # 对后台 docker 进行操作
docker container rm ID # 删除处于终于状态的容器
docker container prune # 清理掉所有处于终止状态的容器
docker container -aq # 清理掉所有处于终止状态的容器
docker image rm ID # 删除本地的镜像，也可使用镜像名
docker image rmi ID # 删除本地的镜像，也可使用镜像名
docker run --name webserver -d -p 80:80 nginx # --name 命名 -p 端口映射
docker diff name # 查看改动
docker commit --author "" --message "" webserver nginx:v2
docker history nginx:v2 # 查看镜像内的历史记录
docker build -t nginx:v3 . # 基于 Dockerfile 生成镜像
docker save xxx | gzip > xxx-latest.tar.gz # 保存镜像
docker load -i xxx-latest.tar.gz # 加载镜像
docker save <镜像名> | bzip2 | pv | ssh <用户名>@<主机名> 'cat | docker load' # 将镜像迁移到另一个机器
docker search name # 查询镜像，automated资源允许用户验证镜像的来源和内容
docker tag ubuntu:17.10 username/ubuntu:17.10 # 命名
docker push username/ubuntu:17.10 # username 替换为 自己的 Docker 账号用户名
docker run -d -p 5000:5000 --restart=always --name registry registry # 构建私有的镜像仓库

```

### 命令行补全

```shell
yum install -y bash-completion
source /usr/share/bash-completion/bash_completion
source /usr/share/bash-completion/completions/docker
```



## Dockerfile

```dockerfile
FROM nginx
RUN echo '<h1>Hello, Docker!</h1>' > /usr/share/nginx/html/index.html
```

```shell
docker build [选项] <上下文路径/URL/->
```

## 私有仓库

将上传的镜像放到本地的 /opt/data/registry 目录

```shell
$ docker run -d \
    -p 5000:5000 \
    -v /opt/data/registry:/var/lib/registry \
    registry
```

在私有仓库上传、搜索、下载镜像

 docker tag IMAGE[:TAG]  [REGISTRY_HOST[:REGISTRY_PORT]/]REPOSITORY[:TAG]



## 常用 docker 命令

### 容器信息

```shell
#[[查看docker]]容器版本
docker version
#[[查看docker]]容器信息
docker info
#[[查看docker]]容器帮助
docker --help

```

### 镜像操作

```shell
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

### 容器操作

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

### 

