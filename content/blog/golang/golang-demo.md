---
authors:
- 1ch0
date: 2021-12-14 14:28:44
image:
  caption: /img/go-logo.png
tags:
- go
title: Golang Demo
---

# Golang Demo

## for 循环轮询

```go

ticker := time.NewTicker(shutdownPollInterval) // 设置轮询时间
  defer ticker.Stop()
  for {
        // 真正的操作
    if srv.closeIdleConns() && srv.numListeners() == 0 {
      return lnerr
    }
    select {
    case <-ctx.Done(): // 如果ctx有设置超时，有可能触发超时结束
      return ctx.Err()
    case <-ticker.C:  // 如果没有结束，最长等待时间，进行轮询
    }
  }
```





