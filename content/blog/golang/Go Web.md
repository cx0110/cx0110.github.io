---
authors:
- 1ch0
date: 2021-09-08 10:00:00
image:
  filename: go-logo.png
  focal_point: Smart
  preview_only: false
tags:
- Golang
- Web
title: Go Web
---

[TOC]

# Go Web 



## 01 net/http

**库函数  > 结构定义 > 结构函数**

> 创建服务 > 创建连接 > 监听请求 > 

### server 源码：

1. http.ListenAndServe 创建 server 数据结构, server.ListenAndServe

2. net. listen     Server.serve

3. c.serve   l.accept 接受请求  srv.NewConn 创建连接结构（ httpconn ） go c.serve(connCtx)

4. 先判断是否升级为 https ，新建 读文本的 reader  和 写文本 buffer ， 读取数据

5. serverHanler{c.server}.ServeHTTP(w, w.req)

   ```go
   type serverHandle struct {
       srv *Server
   }
   
   func (sh serverHandle) ServeHTTP(rw ResponseWriter, req *Request) {
       handle := sh.srv.Handler
       if handler == nil {
           handler = DefualtServeMux
       }
       ...
       handler.ServeHTTP(rw, req)
   }
   ```

   

6. serveHandler{c.server}.ServeHTTP(w, w.req) 判断 handler 是否为 nil，nil 则使用 DefaultServeMux,

7. DefaultServeMux.Handle   http.handle()  http.handleFunc() 去处理，map 形式 

实现

### 实现

#### 实现 Handler 路由

```go
package framework

import "net/http"

type Core struct {
    
}

func NewCore() *Core {
    return &Core{}
}

func (c *Core) HttpHandler(rep http.Reponse, req http.Request) {
    
}
```



#### 创建 server 数据结构

```go
package main

import "./fromework"

func main() {
    server := &http.Serve{
        Handler: framework.NewCore(),
        Addr: ":8080",
    }
    server.ListenAndServe()
}
```

---



go doc context|grep "^func"

---



##### http.FileServer()

1. http.FileServer 创建 FileHandler 数据结构
2. FileHandler 结构体中包含 FileSystem 接口，FileSystem 接口包含Open 方法
3. http.Dir 的 Open 方法 实现  FileSystem 接口 的 Open 方法
4. http.Dir 的 Open 方法对表示字符串的文件路径进行判断：
    1. 先判断 分隔符是否为 "/"且该字符串中是否包含分隔符，若不满足 返回 nil 和 error信息 "http: invalid character in file path"
    2. 将 http.Dir 从 Dir 类型转换为 string 类型，判断该是否为空，若为空，将 dir 赋值为 "."
    3. 使用 path.Clean ，filepath.FromSlash 和 filepath.Join 方法获得路径全名
    4. 使用 os.Open 方法打开文件，如果打开失败，返回错误信息，如果成功以读模式打开文件

​     RuneSelf = utf8.0x80

​	r < RuneSelf 代表 Rune 为单字节，rune为utf-8 unicode   4个字节  int32，

​	byte 代表 uint8，代表ASCII 码的一个字符

- 表示非ASCII字符的多字节串的第一个字节总是在0xC0到0xFD的范围里，并指出这个字符包含多少个字节。**多字节串的其余字节都在0x80到0xBF范围里**，这使得重新同步非常容易，并使编码无国界，且很少受丢失字节的影响。
- 将高位设置为0时，它是一个单字节值。
- 将两个高位设置为10时，这是一个连续字节。
- 否则，它是一个多字节序列的第一个字节，前导1位的数量表示该序列总共有多少个字节(110...表示两个字节，1110...表示三个字节，依此类推)。

## 03 ROUTE



## 04 MiddleWare



## 05 封装











































