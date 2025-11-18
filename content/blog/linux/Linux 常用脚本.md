---
authors:
- 1ch0
date: 2022-01-09 21:56:39
image:
  caption: /img/default.png
tags:
- Linux
title: Linux Init
---

# 1ch0 script

## 1. 配置查询

```shell
# 查看 cpu 配置
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c

cat /proc/cpuinfo |grep "physical id"|sort|uniq|wc -l

cat /proc/cpuinfo |grep "cpu cores"|wc -l


# pv page view
cat /var/log/httpd/access_log|wc -l

sort -t: -k3 /etc/passwd
```

- 分区磁盘占用最大值

  ```shell
  df | tr -s ' ' %| cut -d% -f5 | sort -nr| head -n1
  ```

- 查看连接数

  ```shell
  last|tr -s ' '|cut -d ' ' -f3|sort|uniq -c|sort -n -r
  
  lastb|tr -s ' '|cut -d ' ' -f3|sort|uniq -c|sort -n -r
  lastb|tr -s ' '|cut -d ' ' -f3|sort|uniq -c|sort -n -r|tr -s ' '|cut -d ' ' -f3
  
  
  vim /etc/hosts.deny
  
  sshd: 120.246.107.20
  
  ```

- cut

  ```shell
  cut -d: -f1,3 /etc/passwd | sort -t: -k2 -nr
  ```

- uniq

  ```shell
  cat /var/log/httpd/access_log|cut -d" " -f1 | sort|uniq -c |sort -nr |head
  ```


# 2. 批量执行
## 2.1批量执行命令
### 2.1.1 expect
```shell
#!/bin/bash
cat iplist|while read line #iplist文件中存放了IP地址和密码，每行格式为“IP地址 密码”
do
    a=($line)                    
    /usr/bin/expect <<EOF       
    spawn ssh root@${a[0]}     
    expect {
    "*yes/no" { send "yes\r"; exp_continue}
    "*password:" { send "${a[1]}\r" } 
    }
    expect "#"
    send "whoami\r"
    send "ip add\r"                
    send "exit\r"           
    expect eof
    EOF
done
```
### 2.1.2 Fabric 工具
```python
from fabric.api import *

hosts=['10.1.1.221','10.1.1.132']
env.user='root'
env.password = 'abc123!'
def host_type():
    run('uname -r')
    sudo("cd /tmp;touch 1.txt") 
    run('ls /tmp')

for host in hosts:
    env.host_string = host
    try:
        host_type()
    except:
        pass
```

