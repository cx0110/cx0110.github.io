---
title: "Linux 系统初始化"
subtitle: "Linux系统配置与初始化指南"
summary: "Linux系统的初始化配置，包括系统设置、服务配置和环境优化"
authors:
  - admin
tags:
  - Linux
  - 系统配置
  - 初始化
  - 运维
categories:
  - Linux
date: 2022-06-27T17:57:58+08:00
lastmod: 2025-12-24T10:00:00+08:00
featured: false
draft: false
image:
  filename: linux-logo.svg
  focal_point: Smart
  preview_only: false
---

 Linux Init

## 1. 修改配置

```sh
#!/bin/bash
set -x
lsb_release -a
mkdir $HOME/workspace
mkdir $HOME/workspace/docker-compose
mkdir $HOME/workspace/yaml
mkdir $HOME/workspace/scripts


tee -a $HOME/.bashrc << EOF
# User specific environment
# Basic envs
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ll='ls -al'
alias ch='chmod a+x'
alias cip='curl cip.cc'
alias aip='curl -s http://myip.ipip.net'
alias c='clear'
alias vi='nvim'
# alias psi='reptyr -s'
alias psg='ps -aux|grep'
alias s='screenfetch'
alias x='xclip'
alias k='kubectl'
alias ks='kubectl -n kube-system'
alias ka='kubectl apply -f'
alias kd='kubectl delete -f'
alias dc='docker-compose'


export LANG="en_US.UTF-8" # 设置系统语言为 en_US.UTF-8，避免终端出现中文乱码
export PS1='[\u@dev \W]\$ ' # 默认的 PS1 设置会展示全部的路径，为了防止过长，这里只展示："用户名@dev 最后的目录名"


export WORKSPACE="$HOME/workspace" # 设置工作目录
export PATH=$HOME/bin:$PATH # 将 $HOME/bin 目录加入到 PATH 变量中    
# Default entry folder
cd \$WORKSPACE 
# 登录系统，默认进入 workspace 目录
EOF

source  $HOME/.bashrc




cp /etc/apt/sources.list /etc/apt/sources.list_backup

tee /etc/apt/sources.list << EOF
#阿里源
deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
EOF
apt-get -y update
apt-get -y upgrade
sudo apt-get install libc6-dev 

# 添加公钥
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32

apt-get -y update
apt-get -y upgrade
apt -y autoremove

apt install -y screenfetch git wget net-tools vim libc6-dev snapd snapcraft add-apt-repository xclip



# 安装 neovim
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install -y neovim
# 安装 spacevim 
# curl -sLf https://spacevim.org/cn/install.sh | bash

# 使mkfontscale和mkfontdir命令正常运行
sudo apt-get install -y ttf-mscorefonts-installer
# 使fc-cache命令正常运行
sudo apt-get install -y fontconfig

tee -a $HOME/.vim/vimrc << EOF
autocmd BufNewFile *.sh exec ":call SetTitle()"
func SetTitle()
    if expand("%:e") == 'sh'
    call setline(1, "#!/bin/bash")
    call setline(2, "set -x")
    call setline(3, "")
    call setline(4, "#Author:       1ch0")
    call setline(5, "#Date:         ".strftime("%Y-%m-%d"))
    call setline(6, "#FileName:     ".expand("%"))
    call setline(7, "#Description:  1ch0 script")
    call setline(8, "#Blog:         https://1ch0.github.io/")
    call setline(9, "#Copyright(C): ".strftime("%Y")." All rights reserved")
    call setline(10, "")
    call setline(11, "")  
    endif
endfunc
autocmd BufNewFile * normal G
EOF
```

## 添加用户

```shell
useradd  -m dev
passwd dev

usermod -s /bin/bash dev

# 在 groupA 添加 dev 用户
usermod -a -G groupA dev

# 修改文件夹权限
chomod -R 764 /home/dev/work/

# 修改文件夹归属
chown  -R  dev:dev /home/dev/work/

# root 添加其他用户 docker 执行权限
chmod 666 /var/run/docker.sock



```

### 普通用户无docker权限

#### Example 1: Got permission denied while trying to connect to the Docker daemon socket
sudo chmod 666 /var/run/docker.sock
#### Example 2: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
sudo chmod 666 /var/run/docker.sock
#### Example 3: dial unix /var/run/docker.sock: connect: permission denied
sudo setfacl --modify user:<user name or ID>:rw /var/run/docker.sock
#### Example 4: Server: ERROR: Got permission denied while trying to connect to the Docker daemon socket
sudo newgroup docker
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker ${USER}
#### Example 5: permission denied while trying to connect to the docker daemon socket
sudo usermod -aG docker ${ubuntu}
#### Example 6: got permission denied docker
docker deamon permission issue



## 安装常见软件

```sh
#!/bin/bash
# 安装 go
wget https://studygolang.com/dl/golang/go1.17.11.linux-amd64.tar.gz -O /tmp/go1.17.11.linux-amd64.tar.gz

mkdir -p $HOME/go
tar -xvzf /tmp/go1.17.11.linux-amd64.tar.gz -C $HOME/go
mv $HOME/go/go $HOME/go/go1.17.11
rm -f /tmp/go1.17.11.linux-amd64.tar.gz

tee -a $HOME/.bashrc <<'EOF'
# Go envs
export GOVERSION=go1.17.11 # Go 版本设置
export GO_INSTALL_DIR=$HOME/go # Go 安装目录
export GOROOT=$GO_INSTALL_DIR/$GOVERSION # GOROOT 设置
export GOPATH=$HOME/gopath  # GOPATH 设置
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH # 将 Go 语言自带的和通过 go install 安装的二进制文件加入到 PATH 路径中
export GO111MODULE="on" # 开启 Go moudles 特性
export GOPROXY=https://goproxy.cn,direct # 安装 Go 模块时，代理服务器设置
export G_MIRROR=https://golang.google.cn/dl/
export GOPRIVATE=
export GOSUMDB=off # 关闭校验 Go 依赖包的哈希值
EOF
source ~/.bashrc
go version

# 安装docker
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

# brctl show 查看docker网络
apt install -y bridge-utils 

# bash 补全
apt install -y bash-completion 
source /usr/share/bash-completion/bash_completion
source /usr/share/bash-completion/completions/docker

apt install -y bridge-utils
# 安装 npm
sudo apt-get install -y npm
npm install --global yarn
npm install -g n
n latest
```









### 1.1 修改  $HOME/.bashrc

```shell
#!/bin/bash
mkdir $HOME/workspace    
    
tee -a $HOME/.bashrc << EOF
# User specific environment
# Basic envs
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ll='ls -al'
alias ch='chmod a+x'
alias cip='curl cip.cc'
alias aip='curl -s http://myip.ipip.net'
alias c='clear'
alias vi='nvim'
# alias psi='reptyr -s'
alias psg='ps -aux|grep'
alias s='screenfetch'
alias x='xclip'
alias k='kubectl'
alias ks='kubectl -n kube-system'
alias ka='kubectl apply -f'
alias kd='kubectl delete -f'
alias dc='docker-compose'


export LANG="en_US.UTF-8" # 设置系统语言为 en_US.UTF-8，避免终端出现中文乱码
export PS1='[\u@dev \W]\$ ' # 默认的 PS1 设置会展示全部的路径，为了防止过长，这里只展示："用户名@dev 最后的目录名"


export WORKSPACE="$HOME/workspace" # 设置工作目录
export PATH=$HOME/bin:$PATH # 将 $HOME/bin 目录加入到 PATH 变量中    
# Default entry folder
cd \$WORKSPACE 
# 登录系统，默认进入 workspace 目录
EOF

source  $HOME/.bashrc


```

### 1.2  修改  $HOME/.vimrc

```shell
git clone --depth=1 https://github.com.cnpmjs.org/amix/vimrc.git ~/.vim_runtime
# github.com.cnpmjs.org
# hub.fastgit.org
# git.sdut.me
# github.wuyanzheshui.workers.dev
# raw.Githubusercontent.Com

sh ~/.vim_runtime/install_awesome_vimrc.sh

tee -a $HOME/.vimrc << EOF
autocmd BufNewFile *.sh exec ":call SetTitle()"
func SetTitle()
    if expand("%:e") == 'sh'
    call setline(1, "#!/bin/bash")
    call setline(2, "#")
    call setline(3, "#***********************************************************************")
    call setline(4, "#         Author:            1ch0")
    call setline(5, "#         Date:              ".strftime("%Y-%m-%d"))
    call setline(6, "#         FileName:          ".expand("%"))
    call setline(7, "#         Description:       1ch0 script")
    call setline(8, "#         Blog:              https://1ch0.github.io/")
    call setline(9, "#         Copyright (C):     ".strftime("%Y")." All rights reserved")
    call setline(10, "#***********************************************************************")
	call setline(11, "#")
    call setline(12, "")    
    endif
endfunc
autocmd BufNewFile * normal G
EOF
```

#### Vim 常见命令

```shell
i 插入到光标前面

I 插入到行的开始位置

a 插入到光标的后面

A 插入到行的最后位置

o, O 新开一行

Esc 关闭插入模式

:w 保存

:wq, :x 保存并关闭

:q 关闭（已保存）

:q! 强制关闭

/string 搜索string字符串，如果要忽略大小写set ic

n 搜索指定字符串出现的下一个位置

:%s/old/new/g 全文替换指定字符串old--->new

:n1,n2s/old/new/g 在一定范围内替换,n1,n2表示行数

dd 删除一行

dw 删除一个单词

x 删除后一个字符

X 删除前一个字符

D 删除一行最后一个字符

[N]yy 复制一行或者N行

yw 复制一个单词

p 粘贴
```



#### 安装 vim-plug 插件管理器

```shell
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

#### 安装 SpaceVim

```shell
curl -sLf https://spacevim.org/cn/install.sh | bash

# 使mkfontscale和mkfontdir命令正常运行
sudo apt-get install -y ttf-mscorefonts-installer
# 使fc-cache命令正常运行
sudo apt-get install -y fontconfig

tee -a $HOME/.vim/vimrc << EOF
autocmd BufNewFile *.sh exec ":call SetTitle()"
func SetTitle()
    if expand("%:e") == 'sh'
    call setline(1, "#!/bin/bash")
    call setline(2, "#")
    call setline(3, "#")
    call setline(4, "#Author:       1ch0")
    call setline(5, "#Date:         ".strftime("%Y-%m-%d"))
    call setline(6, "#FileName:     ".expand("%"))
    call setline(7, "#Description:  1ch0 script")
    call setline(8, "#Blog:         https://1ch0.github.io/")
    call setline(9, "#Copyright(C): ".strftime("%Y")." All rights reserved")
    call setline(10, "#")
    call setline(11, "set -x")
	call setline(12, "#")
    call setline(13, "")    
    endif
endfunc
autocmd BufNewFile * normal G
EOF
```

```
nslookup github.com
nslookup github.global.ssl.fastly.net

vi /etc/hosts
162.125.7.1 http://github.global.ssl.fastly.net
162.125.7.1 https://github.global.ssl.fastly.net
20.205.243.166 http://github.com
20.205.243.166 https://github.com

sudo systemctl restart systemd-networkd
```

### 1.3 更换 apt 源

```shell
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
apt -y autoremove
```

#### Centos 换yun源（待完善）

```shell
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo

enabled=0

yum clean all
yum makecache
```



### 1.4 修改时区

```shell
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 后回车确认
```





### 1.5 新建用户

```shell
useradd 
passwd

# 添加 sudoers
sed -i '/^root.*ALL=(ALL).*ALL/a\going\tALL=(ALL) \tALL' /etc/sudoers
```



## 2. 安装常见软件

> 软件个人选择

### 2.1 安装常用软件

```shell
apt install -y make autoconf automake cmake  libtool gcc git-lfs telnet ctags lrzsz jq 

perl-CPAN libcurl-devel expat-devel openssl-devel zlib-devel gcc-c++ glibc-
headers

apt install -y screenfetch git wget net-tools vim xclip 

apt install -y iproute2 ntpdate tcpdump telnet traceroute nfs-kernel-server nfs-common lrzsz tree openssl libssl-dev libpcre3 libpcre3-dev zlib1g-dev gcc openssh-server iotop unzip zip make selinux-utils sshpass socat  openssh

```

#### Git

```shell

cd /tmp
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.30.2.tar.gz
tar -xvzf git-2.30.2.tar.gz
cd git-2.30.2/
./configure
make
sudo make install
git --version          # 输出 git 版本号，说明安装成功
git version 2.30.2
```



### 2.2 安装 Go

#### 安装包安装

````sh
#!/bin/bash
wget https://studygolang.com/dl/golang/go1.17.11.linux-amd64.tar.gz -O /tmp/go1.17.11.linux-amd64.tar.gz

mkdir $HOME/workspace    
export WORKSPACE="$HOME/workspace"
mkdir -p $HOME/go
tar -xvzf /tmp/go1.17.11.linux-amd64.tar.gz -C $HOME/go
mv $HOME/go/go $HOME/go/go1.17.11
rm -f /tmp/go1.17.11.linux-amd64.tar.gz

tee -a $HOME/.bashrc <<'EOF'
# Go envs
export GOVERSION=go1.17.11 # Go 版本设置
export GO_INSTALL_DIR=$HOME/go # Go 安装目录
export GOROOT=$GO_INSTALL_DIR/$GOVERSION # GOROOT 设置
export GOPATH=$WORKSPACE/go # GOPATH 设置
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH # 将 Go 语言自带的和通过 go install 安装的二进制文件加入到 PATH 路径中
export GO111MODULE="on" # 开启 Go moudles 特性
export GOPROXY=https://goproxy.cn,direct # 安装 Go 模块时，代理服务器设置
export G_MIRROR=https://golang.google.cn/dl/
export GOPRIVATE=
export GOSUMDB=off # 关闭校验 Go 依赖包的哈希值
EOF
source ~/.bashrc
go version
````

#### Apt 源安装

```shell
add-apt-repository ppa:longsleep/golang-backports
apt-get update
sudo apt-get install golang-go
go version
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
go env -w G_MIRROR=https://golang.google.cn/dl/
```





#### 使用 g 安装

```shell
curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash

tar -zxvf g1.2.1.linux-amd64.tar.gz 
mv g /usr/local/bin/

echo "unalias g" >> ~/.bashrc
tee -a ~/.bashrc<<EOF
export GOROOT="${HOME}/.g/go"
export PATH="${HOME}/.g/go/bin:$PATH"
export G_MIRROR=https://golang.google.cn/dl/
# Enable the go modules feature
export GO111MODULE=on
# Set the GOPROXY environment variable
export GOPROXY=https://goproxy.io
EOF
source ~/.bashrc

# https://github.com/voidint/g/releases

g ls-remote stable
g install
```

### 安装 python



##### Conda

```shell
wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod 777 Miniconda3-latest-Linux-x86_64.sh #给执行权限
bash Miniconda3-latest-Linux-x86_64.sh #运行
```

#### 安装 gh

```sh
conda install gh --channel conda-forge

# upgrade 
conda update gh --channel conda-forge
```



### 2.3 安装 Tmux

```sh
sudo apt install -y tmux
```



### 2.4 安装 SpaceVim

```shell
curl -sLf https://spacevim.org/cn/install.sh | bash

# 使mkfontscale和mkfontdir命令正常运行
sudo apt-get install ttf-mscorefonts-installer
# 使fc-cache命令正常运行
sudo apt-get install fontconfig 
```

#### 2.3 安装 vim-plug 插件管理器

```sh
 curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```



### 2.5 安装k8s

#### Sealos

##### 2.5.0 安装前配置

- 统一时间

  ```shell
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  ```

  

- 修改 hostname

  ```shell
  tee /etc/hostname << EOF
  node2
  EOF
  # 重启linux
  reboot
  ```

- 配置静态 ip、ssh、root 密码 

- 下载常用软件，需下载 socat

  ```shell
  apt install -y screenfetch git wget net-tools vim openssh socat
  ```

  

#### 2.5.1 安装

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

##### 2.5.2 增加 Master

```shell
sealos join --master 192.168.0.6 --master 192.168.0.7
# 或者多个连续IP
sealos join --master 192.168.0.6-192.168.0.9  
```

##### 2.5.3 增加node

```
sealos join --node 192.168.0.6 --node 192.168.0.7
sealos join --node 192.168.0.6-192.168.0.9  # 或者多个连续IP
```

##### 2.5.4 删除指定master节点

```
sealos clean --master 192.168.0.6 --master 192.168.0.7
sealos clean --master 192.168.0.6-192.168.0.9  # 或者多个连续IP
```

##### 2.5.5 删除指定node节点

```
sealos clean --node 192.168.0.6 --node 192.168.0.7
sealos clean --node 192.168.0.6-192.168.0.9  # 或者多个连续IP
```

##### 2.5.6 清理集群

```
sealos clean --all
```

#### [2.5.2 使用 kubeasz安装](https://github.com/easzlab/kubeasz/blob/master/docs/setup/quickStart.md)

#####  使用纯净服务器，未安装过 docker k8s

#####  安装

```shell
export release=3.0.0
wget https://github.com/easzlab/kubeasz/releases/download/${release}/ezdown
chmod +x ./ezdown

./ezdown -D

./ezdown -S
docker exec -it kubeasz ezctl start-aio

```



##### 5.清理

以上步骤创建的K8S开发测试环境请尽情折腾，碰到错误尽量通过查看日志、上网搜索、提交`issues`等方式解决；当然你也可以清理集群后重新创建。

在宿主机上，按照如下步骤清理

- 清理集群 `docker exec -it kubeasz ezctl destroy default`
- 清理运行的容器 `./ezdown -C`
- 清理容器镜像 `docker system prune -a`
- 停止docker服务 `systemctl stop docker`
- 删除docker文件

```
 umount /var/run/docker/netns/default
 umount /var/lib/docker/overlay
 rm -rf /var/lib/docker /var/run/docker
```

### 2.6 安装配置 zsh

```shell
apt-get install -y zsh
wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh

tee -a ~/.zshrc << EOF
ZSH_THEME="agnoster"  	# 主题配置
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
)
# 插件配置，常用插件，git分支显示，关键字高亮，自动建议
source "/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

EOF
# 安装插件
git clone https://hub.fastgit.org/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins 
git clone https://hub.fastgit.org/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins 

source ~/.zshrc
```



### 2.7 安装 Docker

#### 2.7.1 安装 Docker

```shell
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
apt install -y bridge-utils # brctl show 查看docker网络
```

#### 2.7.2 安装 bash 补全

```shell
# yum install -y bash-completion
apt install -y bash-completion 
source /usr/share/bash-completion/bash_completion
source /usr/share/bash-completion/completions/docker

apt install -y bridge-utils # brctl show 查看docker网络
```

### 

## 3. 配置

### 3.1 配置 ssh

- 配置 root 密码，开启远程登录

```shell
sudo passwd

vim /etc/ssh/sshd_config

port 22
PermitRootLogin yes
PasswordAuthentication no


tee -a /etc/ssh/sshd_config << EOF
port 22
PermitRootLogin yes
PasswordAuthentication no
EOF

service sshd restart

```

开启 ssh，关闭密码验证
https://blog.csdn.net/qq_43228568/article/details/110824158

- 配置 key

```shell
https://jingyan.baidu.com/article/0f5fb0990660076d8234ea50.html

ssh-keygen -t dsa /etc/ssh/ssh_host_dsa_key

ssh-keygen -t ecdsa /etc/ssh/ssh_host_ecdsa_key

ssh-keygen -t ed25519 /etc/ssh/ssh_host_ed25519_key

ssh-keygen -t rsa /etc/ssh/ssh_host_rsa_key

ssh-keygen -t rsa1 /etc/ssh/ssh_host_rsa1_key

chmod 600 /etc/ssh/*key

cat /etc/ssh/ssh*pub>>/home/ubuntu/.ssh/authorized_keys

cat /home/ubuntu/.ssh/authorized_keys >/root/.ssh/authorized_keys

chmod 644 /root/.ssh/authorized_keys
```



### 3.2 配置静态 IP

```shell
tee /etc/netplan/00-installer-config.yaml << EOF
network:
  ethernets:
    ens33:
      addresses:
        - 192.168.0.15/24
      dhcp4: no
      gateway4: 192.168.0.2
      nameservers:
          addresses: ['114.114.114.114']
  version: 2
EOF
netplan apply
ifconfig
```

### 3.3 克隆虚拟机

```shell
# 修改hostname
vim /etc/hostname
# 修改ip
vim /etc/netplan/00-installer-config.yaml
netplan apply
```

## Summary

```ad-summary
#!/bin/bash

mkdir $HOME/workspace    
    
tee -a $HOME/.bashrc << EOF
# User specific environment
# Basic envs
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ll='ls -al'
alias ch='chmod a+x'
alias cip='curl cip.cc'
alias c='clear'
# alias psi='reptyr -s'
alias psg='ps -aux|grep'
alias s='screenfetch'
alias dc='docker-compose'
alias ll='ls -la'
alias c='clear'
alias aip='curl -s http://myip.ipip.net'
alias k='kubectl'
alias ka='kubectl apply -f'
alias kd='kubectl delete -f'
alias ch='chmod a+x'

# Go env
 export GOROOT="/root/.g/go"
 export PATH="/root/.g/go/bin:/root/.g/go/bin:/root/bin:/root/bin:/root/bin:/    root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/     games:/usr/local/games:/snap/bin"
 export G_MIRROR=https://golang.google.cn/dl/
 # Enable the go modules feature
 export GO111MODULE=on
 # Set the GOPROXY environment variable
 export GOPROXY=https://goproxy.io

export LANG="en_US.UTF-8" # 设置系统语言为 en_US.UTF-8，避免终端出现中文乱码
export PS1='[\u@dev \W]\$ ' # 默认的 PS1 设置会展示全部的路径，为了防止过长，这里只展示："用户名@dev 最后的目录名"

export WORKSPACE="$HOME/workspace" # 设置工作目录
export PATH=$HOME/bin:$PATH # 将 $HOME/bin 目录加入到 PATH 变量中    
# Default entry folder
cd \$WORKSPACE
# 登录系统，默认进入 workspace 目录
EOF

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
apt -y autoremove
apt install -y screenfetch git wget net-tools vim 

git clone --depth=1 https://github.com.cnpmjs.org/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

tee $HOME/.vimrc << EOF
autocmd BufNewFile *.sh exec ":call SetTitle()"
func SetTitle()
    if expand("%:e") == 'sh'
    call setline(1, "#!/bin/bash")
    call setline(2, "#")
    call setline(3, "#***********************************************************************")
    call setline(4, "#         Author:            1ch0")
    call setline(5, "#         Date:              ".strftime("%Y-%m-%d"))
    call setline(6, "#         FileName:          ".expand("%"))
    call setline(7, "#         Description:       1ch0 script")
    call setline(8, "#         Blog:              https://1ch0.github.io/")
    call setline(9, "#         Copyright (C):     ".strftime("%Y")." All rights reserved")
    call setline(10, "#***********************************************************************")
    call setline(11, "")
    endif
endfunc
autocmd BufNewFile * normal G
EOF

source  $HOME/.bashrc
```

