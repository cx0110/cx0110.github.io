---
authors:
- 1ch0
date: 2021-08-07 10:00:00
image:
  filename: go-logo.png
tags:
- Design Parttern
title: GO 设计模式
---

# 单例模式 

> 一个类只允许创建一个实例。
>
> 在业务概念中，在系统中只应该保存一份的数据，适合用单例模式。

1. 饿汉式



```go
package singleton

type Singleton struct {}

var singleton *Singleton

func init()  {
	singleton = &Singleton{}
}

func GetInstance() *Singleton {
	return singleton
}
```

2. 懒汉式

```go
package singleton

import "sync"

type Singleton struct{}

var (
	lazySingleton *Singleton
	once = sync.Once{}
)

func GetLazyInstance() *Singleton {
	if lazySingleton == nil {
		once.Do(func() {
			lazySingleton = &Singleton{}
		})
	}
	return lazySingleton
}
```



