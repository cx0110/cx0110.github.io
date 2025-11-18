---
authors:
- 1ch0
date: 2021-09-07 10:00:00
image:
  caption: /img/go-logo.png
tags:
- Golang
- Web
title: Onion Model 洋葱模型
---

# Onion Model 洋葱模型

> 请求进来，一层一层的通过中间件执行`next`函数进入到你设置的下一个中间件中，并且可以通过`context`对象一直向下传递下去，当到达最后一个中间件的时候，又向上返回到最初的地方。

代码示例：

```go
package main

import (
	"fmt"
	"math"
)

type Context struct {
	handlers []func(c *Context)
	index int8
}

const abortIndex = math.MaxInt8 / 2

func (this *Context) Use(f func(c *Context) ) {
	this.handlers = append(this.handlers, f)
}

func (this *Context) GET(path string, f func(c *Context))  {
	this.handlers = append(this.handlers, f)
}

func (this *Context) Next()  {
	if this.index < int8(len(this.handlers)) {
		this.index++
		this.handlers[this.index](this)
	}
	return
}

func (this *Context) Abort()  {
	this.index = abortIndex
}

func (this *Context) Run()  {
	this.handlers[0](this)
}

func main() {
	c := &Context{}
	c.Use(middle3())
	c.Use(middle2())
	c.Use(middle1())
	c.GET("/", func(c *Context) {
		fmt.Println("ONION>>>>>>>>>>>>")
	})
	c.Run()
}

func middle1() func(c *Context) {
	return func(c *Context) {
		fmt.Println("middle1----BEGIN")
		c.Next()
		fmt.Println("middle1----END")
	}
}

func middle2() func(c *Context) {
	return func(c *Context) {
		fmt.Println("middle2----BEGIN")
		c.Abort()
		c.Next()
		fmt.Println("middle2----END")
	}
}

func middle3() func(c *Context) {
	return func(c *Context) {
		fmt.Println("middle3----BEGIN")
		c.Next()
		fmt.Println("middle3----END")
	}
}
```

运行结果：

```shell
middle3----BEGIN
middle2----BEGIN
middle1----BEGIN
ONION>>>>>>>>>>>>
middle1----END
middle2----END
middle3----END
```

