---
authors:
- admin
date: 2021-12-29 15:09:33
image:
  filename: go-logo.png
tags:
- questions
title: Go_perf
---

# Go perf

## 1. net

### 1.1 拼接 ip

```shell
net.JoinHostPort(s.BindAddress, strconv.Itoa(s.BindPort))
```

### 1.2 设置 body 

```shell
body := bytes.NewBufferString(`{"nickname":"admin2","email":"admin2@foxmail.com","phone":"1812885xxx"}`)
```



### 1.3 替换标准库

```shell
# 日志库能够兼容标准库 log 包，我们就可以很容易地替换掉标准库 log 包
# logrus 就兼容标准库 log 包
log "github.com/sirupsen/logrus"
```





![IP签名](https://tool.lu/netcard/)

