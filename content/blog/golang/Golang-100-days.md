---
title: "Golang 100天学习计划"
subtitle: "Go语言系统学习指南"
summary: "Go语言100天学习计划，包括基础语法、高级特性和实战项目"
authors:
  - admin
tags:
  - Golang
  - 学习计划
  - 基础教程
  - 编程语言
categories:
  - Golang
date: 2020-11-05T10:00:00+08:00
lastmod: 2025-12-24T10:00:00+08:00
featured: false
draft: false
image:
  filename: golang-logo.svg
  focal_point: Smart
  preview_only: false
---

# cap（）函数的计算值



```go
package main

import "fmt"

func main() {
   var numbers []int
   printSlice(numbers)

   /* 允许追加空切片 */
   numbers = append(numbers, 0)
   printSlice(numbers)

   /* 向切片添加一个元素 */
   numbers = append(numbers, 1)
   printSlice(numbers)

   /* 同时添加多个元素 */
   numbers = append(numbers, 2,3,4)
   printSlice(numbers)

   /* 创建切片 numbers1 是之前切片的两倍容量*/
   numbers1 := make([]int, len(numbers), (cap(numbers))*2)

   /* 拷贝 numbers 的内容到 numbers1 */
   copy(numbers1,numbers)
   printSlice(numbers1)   
}

func printSlice(x []int){
   fmt.Printf("len=%d cap=%d slice=%v\n",len(x),cap(x),x)
}
```

运行结果

```shell
len=0 cap=0 slice=[]
len=1 cap=2 slice=[0]
len=2 cap=2 slice=[0 1]
len=5 cap=8 slice=[0 1 2 3 4]
len=5 cap=12 slice=[0 1 2 3 4]
```





![IP签名](https://tool.lu/netcard/)

