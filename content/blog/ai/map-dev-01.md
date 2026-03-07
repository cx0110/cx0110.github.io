---
title: "Go 实战：从零开发 MCP Server"
subtitle: "使用 Go 构建 Model Context Protocol 服务"
summary: "通过 Go 语言从零实现 MCP Server，介绍 MCP 的核心概念、Tool 实现方式、Server 架构以及生产环境部署实践"
authors:
  - admin
tags:
  - MCP
  - Go
  - LLM
  - AI Agent
  - Model Context Protocol
categories:
  - AI & Machine Learning
date: 2026-03-07T10:00:00+08:00
lastmod: 2026-03-07T10:00:00+08:00
featured: true
draft: false
image:
  filename: ai-logo.svg
  focal_point: Smart
  preview_only: false
---

**Go 实战：从零开发一个 MCP Server**

**MCP 是什么**
MCP（Model Context Protocol）是一种用于连接 AI 模型与外部工具、数据源的协议。通过 MCP Server，开发者可以把自己的 API、数据库、业务系统等能力暴露给 AI，让 AI 能够调用这些能力完成更复杂的任务。

简单来说：
AI 负责理解用户需求，MCP Server 负责提供真实的能力。

**MCP Server 的核心能力**
一个 MCP Server 通常提供三类能力：

* **Tools（工具）**：AI 可以调用的函数，例如查询天气、搜索数据库等
* **Resources（资源）**：可以读取的数据，例如文件、文档、数据库记录
* **Prompts（提示模板）**：可复用的提示词模板

在实际开发中，最常见的是实现 Tools。

**Go 开发 MCP Server 的技术选型**
Go 语言非常适合开发 MCP Server，原因包括：

* 高性能并发处理
* 编译后单文件部署
* HTTP / JSON 生态成熟
* 适合构建微服务

常见技术栈：

* Go 1.21+
* net/http 或 Gin
* JSON-RPC 或 HTTP
* Docker（部署）

**项目结构设计**

一个简单 MCP Server 项目结构：

```
mcp-server-go/
├── main.go
├── server/
│   └── server.go
├── tools/
│   └── weather.go
├── models/
│   └── request.go
└── go.mod
```

**定义 Tool 数据结构**

MCP 中 Tool 本质是一个可调用函数，需要描述名称、参数和执行逻辑。

```go
type Tool struct {
    Name        string                 `json:"name"`
    Description string                 `json:"description"`
    InputSchema map[string]interface{} `json:"inputSchema"`
}
```

示例 Tool：查询天气。

```go
var WeatherTool = Tool{
    Name:        "get_weather",
    Description: "获取指定城市天气",
    InputSchema: map[string]interface{}{
        "type": "object",
        "properties": map[string]interface{}{
            "city": map[string]string{
                "type": "string",
            },
        },
        "required": []string{"city"},
    },
}
```

**实现 Tool 逻辑**

```go
func GetWeather(city string) string {
    // 实际项目中可以调用真实 API
    return fmt.Sprintf("%s 当前天气：晴 25°C", city)
}
```

**实现 MCP Server**

使用 Go 原生 HTTP 服务即可。

```go
package main

import (
    "encoding/json"
    "net/http"
)

func main() {

    http.HandleFunc("/tools", func(w http.ResponseWriter, r *http.Request) {
        tools := []Tool{WeatherTool}
        json.NewEncoder(w).Encode(tools)
    })

    http.HandleFunc("/call", func(w http.ResponseWriter, r *http.Request) {

        var req struct {
            Name string `json:"name"`
            City string `json:"city"`
        }

        json.NewDecoder(r.Body).Decode(&req)

        if req.Name == "get_weather" {
            result := GetWeather(req.City)
            json.NewEncoder(w).Encode(map[string]string{
                "result": result,
            })
        }
    })

    http.ListenAndServe(":8080", nil)
}
```

**运行服务器**

编译并运行：

```
go run main.go
```

服务器启动后：

```
http://localhost:8080/tools
```

返回可用工具列表。

调用工具：

```
POST /call
{
  "name": "get_weather",
  "city": "北京"
}
```

返回：

```
北京 当前天气：晴 25°C
```

**接入 AI Agent**

当 AI Agent 连接 MCP Server 时：

1. 读取 `/tools` 获取工具列表
2. 根据用户问题选择工具
3. 调用 `/call` 执行工具
4. 将结果返回给用户

整个过程完全自动。

**生产级 MCP Server 优化**

真实项目中建议增加：

**日志系统**

```
zap / logrus
```

**配置管理**

```
viper
```

**API 调用**

```
resty
```

**并发控制**

```
goroutine + worker pool
```

**安全机制**

* API Key
* OAuth
* Rate Limit

**Docker 部署**

Dockerfile 示例：

```
FROM golang:1.22

WORKDIR /app
COPY . .

RUN go build -o mcp-server

CMD ["./mcp-server"]
```

构建：

```
docker build -t mcp-go .
docker run -p 8080:8080 mcp-go
```

**总结**

Go 开发 MCP Server 的流程非常清晰：

**理解 MCP 协议**
确定 Tool、Resource 或 Prompt 的类型。

**设计工具接口**
定义参数结构和返回值。

**实现业务逻辑**
连接 API、数据库或内部系统。

**暴露 MCP 接口**
提供工具列表和调用接口。

**部署与接入 AI**
通过 HTTP 或 STDIO 与 AI Agent 通信。

通过 MCP Server，可以让 AI 直接操作真实系统，例如：

* 查询数据库
* 调用内部 API
* 操作 DevOps
* 自动化业务流程

这也是未来 **AI + 软件系统融合的重要基础设施**。

> 后续思考
> **Go MCP Server 完整项目（含 SDK、Agent、Docker、OpenAI 接入）**
> 或者**Go + Gin 构建生产级 MCP Server 框架**。
