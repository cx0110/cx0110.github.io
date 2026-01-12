---
title: "zerolog使用"
subtitle: ""
summary: ""
authors:
  - admin
tags:
  - golang
categories:
  - 技术博客
date: 2026-01-12T18:03:08+08:00
lastmod: 2026-01-12T18:03:08+08:00
featured: false
draft: false
image:
  filename: go-logo.png
  focal_point: Smart
  preview_only: false
---

# Zerolog 生产环境完全指南：从入门到精通

## 引言

在微服务架构日益普及的今天，日志系统的重要性不言而喻。一个优秀的日志库不仅需要高性能，还需要提供丰富的功能来满足生产环境的需求。Zerolog 作为 Go 语言生态中最受欢迎的零分配 JSON 日志库，以其卓越的性能和简洁的 API 设计赢得了开发者的青睐。本文将深入探讨如何在生产环境中全面发挥 Zerolog 的潜力，构建一个完整的日志解决方案。

Zerolog 的核心设计理念是在保持极低开销的同时提供结构化日志能力。与传统的日志库不同，Zerolog 采用链式 API 设计，所有日志字段在写入之前就已经被序列化到缓冲区，避免了运行时的反射和动态内存分配。这种设计使得 Zerolog 在高并发场景下依然能够保持出色的性能表现。

本文将涵盖 Zerolog 生产环境配置的各个方面，包括 Request ID 追踪、错误堆栈跟踪、HTTP 中间件集成、日志采样、性能优化等高级话题。通过阅读本文，你将能够构建一个完整的生产级日志系统，为你的应用提供全方位的可观测性支持。

## 第一章：Zerolog 核心概念与快速入门

### 1.1 为什么选择 Zerolog

在深入生产配置之前，我们首先需要理解 Zerolog 的核心优势。Zerolog 的设计目标是为 Go 应用提供一个高性能、结构化的日志解决方案。以下是 Zerolog 相比其他日志库的主要优势：

首先是性能优势。Zerolog 在底层采用预分配的缓冲区，所有字段序列化都在缓冲区中进行，避免了运行时的内存分配和反射操作。根据官方基准测试，Zerolog 的性能比大多数同类库高出数倍，同时保持了零分配或极低分配的特点。这对于高吞吐量的服务来说至关重要，因为日志记录不应该成为性能瓶颈。

其次是结构化日志能力。Zerolog 原生支持 JSON 格式输出，每条日志都是一个结构化的 JSON 对象，可以直接被日志收集系统（如 ELK、Loki）解析和处理。结构化日志使得日志查询、分析和可视化变得简单高效。

第三是简洁的 API 设计。Zerolog 采用流式构建器模式，通过链式调用添加日志字段，代码可读性强。以下是一个典型的使用示例：

```go
package main

import (
    "github.com/rs/zerolog/log"
)

func main() {
    log.Info().
        Str("username", "john").
        Int("age", 25).
        Bool("active", true).
        Msg("user logged in")
}
```

上述代码将输出如下 JSON 日志：

```json
{"level":"info","username":"john","age":25,"active":true,"message":"user logged in"}
```

### 1.2 基础配置与全局日志器

在生产环境中，我们需要对 Zerolog 进行适当的配置以满足实际需求。以下是一些关键配置项的详细说明：

**时间格式配置**决定了日志中时间字段的呈现方式。Zerolog 提供了多种预定义的时间格式，同时也支持自定义格式：

```go
package main

import (
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func main() {
    // 使用 Unix 时间戳（毫秒精度）
    zerolog.TimeFieldFormat = zerolog.TimeFormatUnixMs
    
    // 或者使用 RFC3339 格式
    zerolog.TimeFieldFormat = time.RFC3339
    
    // 或者使用自定义格式
    zerolog.TimeFieldFormat = "2006-01-02 15:04:05"
    
    log.Info().Msg("time format configured")
}
```

**全局日志级别**控制日志的输出阈值。我们可以根据环境（开发、测试、生产）设置不同的级别：

```go
package main

import "github.com/rs/zerolog"

func configureLogLevel() {
    // 开发环境使用 Debug 级别
    zerolog.SetGlobalLevel(zerolog.DebugLevel)
    
    // 生产环境通常使用 Info 级别
    zerolog.SetGlobalLevel(zerolog.InfoLevel)
    
    // 或者完全禁用日志
    zerolog.SetGlobalLevel(zerolog.Disabled)
}
```

**创建全局日志器**是生产配置的重要一步。我们可以创建一个预配置好的日志器，并在整个应用中共享：

```go
package main

import (
    "os"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func SetupLogger() {
    // 创建控制台输出器
    consoleWriter := zerolog.ConsoleWriter{
        Out: os.Stdout,
    }
    
    // 配置全局日志器
    log.Logger = zerolog.New(consoleWriter).
        With().
        Timestamp().
        Str("service", "user-service").
        Str("environment", "production").
        Int("version", 1).
        Logger()
}
```

### 1.3 日志级别详解

Zerolog 提供了完整的日志级别体系，从高到低依次为：Panic、Fatal、Error、Warn、Info、Debug、Trace。理解每个级别的使用场景对于生产环境配置至关重要：

**PanicLevel** 和 **FatalLevel** 通常用于记录程序无法继续运行的严重错误。区别在于 PanicLevel 会触发 panic，而 FatalLevel 会调用 os.Exit(1)：

```go
package main

import (
    "github.com/rs/zerolog/log"
)

func criticalOperation() {
    defer func() {
        if r := recover(); r != nil {
            log.Error().Interface("recovered", r).Msg("operation recovered")
        }
    }()
    
    // 严重错误，使用 Panic
    log.Panic().Msg("database connection failed")
    
    // 或者使用 Fatal（程序将退出）
    log.Fatal().Err(err).Msg("critical system error")
}
```

**ErrorLevel** 是生产环境中最常用的级别，用于记录需要关注但不会导致程序崩溃的错误：

```go
package main

import (
    "errors"
    
    "github.com/rs/zerolog/log"
)

func processUser(userID string) error {
    err := fetchUserFromDB(userID)
    if err != nil {
        // 记录错误，但不中断程序执行
        log.Error().
            Str("user_id", userID).
            Err(err).
            Msg("failed to fetch user")
        return err
    }
    return nil
}
```

**WarnLevel** 用于记录潜在问题的警告信息，这些信息不代表错误，但值得关注：

```go
package main

import (
    "github.com/rs/zerolog/log"
)

func checkResourceLimit(usage float64) {
    if usage > 0.8 {
        log.Warn().
            Float64("usage", usage).
            Float64("threshold", 0.8).
            Msg("resource usage exceeds 80%")
    }
}
```

**InfoLevel** 是生产环境的默认级别，用于记录正常的业务操作信息：

```go
package main

import (
    "github.com/rs/zerolog/log"
)

func userLogin(username string) {
    log.Info().
        Str("username", username).
        Msg("user logged in")
}
```

**DebugLevel** 和 **TraceLevel** 通常只在开发或调试时启用，用于输出详细的调试信息：

```go
package main

import (
    "github.com/rs/zerolog/log"
)

func complexCalculation(a, b int) {
    log.Debug().
        Int("a", a).
        Int("b", b).
        Msg("starting calculation")
    
    // 详细的中间步骤
    log.Trace().
        Int("result", a + b).
        Msg("calculation completed")
}
```

## 第二章：Request ID 追踪体系

### 2.1 Request ID 的重要性

在分布式系统和微服务架构中，请求追踪是实现可观测性的基础。一个请求从入口服务经过多个下游服务的调用，最终返回结果。在这个复杂的调用链中，能够通过一个唯一的标识符将所有相关的日志串联起来，对于问题排查和性能分析至关重要。

Request ID（也称为 Trace ID 或 Correlation ID）正是解决这一问题的关键。它是一个全局唯一的标识符，伴随请求的整个生命周期，从进入系统开始，到最终响应结束。所有的日志记录都包含这个标识符，使得我们可以在日志系统中快速筛选出与特定请求相关的所有日志条目。

在生产环境中，Request ID 的应用场景非常广泛：

**故障排查**是 Request ID 最基本的用途。当用户报告问题时，客服或技术支持人员可以要求用户提供 Request ID，通过这个 ID 快速定位相关的所有日志，包括各个服务节点的调用情况、处理步骤、错误信息等。

**性能分析**也依赖于 Request ID。通过分析同一个 Request ID 下各个步骤的时间戳，我们可以计算出请求在每个服务节点、每个处理环节的耗时，从而发现性能瓶颈。

**日志关联**是 Request ID 的核心价值。在微服务架构中，一个请求可能涉及多个服务的调用，通过统一的 Request ID，可以将这些分散在不同服务、不同日志文件中的记录关联起来，形成完整的调用链路视图。

### 2.2 Zerolog 的 Request ID 实现

Zerolog 通过 `hlog` 子包提供了完整的 Request ID 支持。以下是配置 Request ID 处理程序的详细方法：

```go
package main

import (
    "net/http"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
)

func setupRequestID() http.Handler {
    handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // 获取当前请求的 Request ID
        id, ok := hlog.IDFromRequest(r)
        if !ok {
            // 如果没有，则生成新的
            id = hlog.IDFromCtx(r.Context())
        }
        
        logger := hlog.FromRequest(r)
        logger.Info().
            Str("request_id", id.String()).
            Msg("request received")
        
        w.Write([]byte("OK"))
    })
    
    // 使用 RequestIDHandler 自动管理 Request ID
    return hlog.RequestIDHandler("request_id", "X-Request-Id")(handler)
}
```

`RequestIDHandler` 接受两个参数：第一个是日志字段名，第二个是 HTTP 头名。当请求到达时，它会按以下逻辑处理：

首先检查请求中是否已经包含 Request ID（通过指定的头名）。如果有，则使用现有的 ID；如果没有，则生成一个新的全局唯一 ID。然后将这个 ID 添加到日志上下文中，并设置到响应头中返回给客户端。

### 2.3 完整的中间件配置

在实际生产环境中，我们通常需要配置一个完整的中间件栈来处理日志的各个方面。以下是一个生产级的中间件配置示例：

```go
package main

import (
    "net/http"
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
)

func SetupMiddleware(handler http.Handler) http.Handler {
    // 1. NewHandler：将日志器注入请求上下文
    // 这是所有其他 hlog 中间件的基础
    handler = hlog.NewHandler(log.Logger)(handler)
    
    // 2. RequestIDHandler：生成/读取 Request ID
    // 从请求头读取或生成新的 Request ID
    // 将 ID 记录在 request_id 字段中
    // 将 ID 设置到 X-Request-Id 响应头
    handler = hlog.RequestIDHandler("request_id", "X-Request-Id")(handler)
    
    // 3. AccessHandler：记录请求访问日志
    // 在请求完成后记录访问信息
    handler = hlog.AccessHandler(func(r *http.Request, status, size int, duration time.Duration) {
        hlog.FromRequest(r).Info().
            Str("method", r.Method).
            Stringer("url", r.URL).
            Int("status", status).
            Int("size", size).
            Dur("duration", duration).
            Msg("request completed")
    })(handler)
    
    // 4. RemoteAddrHandler：记录客户端 IP 地址
    handler = hlog.RemoteAddrHandler("client_ip")(handler)
    
    // 5. UserAgentHandler：记录客户端 User-Agent
    handler = hlog.UserAgentHandler("user_agent")(handler)
    
    // 6. RefererHandler：记录 HTTP Referer
    handler = hlog.RefererHandler("referer")(handler)
    
    // 7. HostHandler：记录请求的主机名
    handler = hlog.HostHandler("host")(handler)
    
    // 8. URLHandler：记录完整的请求 URL
    handler = hlog.URLHandler("url")(handler)
    
    // 9. MethodHandler：记录请求方法
    handler = hlog.MethodHandler("http_method")(handler)
    
    // 10. ProtoHandler：记录 HTTP 协议版本
    handler = hlog.ProtoHandler("http_version")(handler)
    
    return handler
}
```

配置完成后，在 HTTP Handler 中使用 Request ID 就变得非常简单：

```go
package main

import (
    "net/http"
    
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
)

func userHandler(w http.ResponseWriter, r *http.Request) {
    // 从请求上下文中获取日志器
    logger := hlog.FromRequest(r)
    
    // 获取 Request ID
    id, _ := hlog.IDFromRequest(r)
    
    logger.Info().
        Str("request_id", id.String()).
        Str("action", "get_user").
        Msg("processing user request")
    
    // 业务逻辑...
    
    logger.Info().
        Str("request_id", id.String()).
        Msg("user request completed")
}
```

### 2.4 自定义 Request ID 生成策略

在某些场景下，我们可能需要自定义 Request ID 的生成策略。例如，从外部系统传入追踪 ID，或者使用特定的 ID 格式。Zerolog 允许我们通过自定义头处理来实现这一需求：

```go
package main

import (
    "net/http"
    
    "github.com/google/uuid"
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
)

func setupCustomRequestID() http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        ctx := r.Context()
        
        // 优先使用外部传入的追踪 ID（如 AWS X-Ray、Jaeger 等）
        traceID := r.Header.Get("X-Trace-ID")
        if traceID == "" {
            traceID = r.Header.Get("X-Correlation-ID")
        }
        if traceID == "" {
            // 使用 UUID 作为备选
            traceID = uuid.New().String()
        }
        
        // 将自定义 ID 注入上下文
        ctx = hlog.CtxWithID(ctx, uuid.MustParse(traceID))
        r = r.WithContext(ctx)
        
        // 继续处理
        // ...
    })
}
```

### 2.5 Request ID 的传播

在微服务架构中，Request ID 需要在服务间传播。当一个服务调用下游服务时，需要将当前的 Request ID 传递给下游服务，以便保持追踪链的完整性。以下是 Request ID 传播的最佳实践：

```go
package main

import (
    "context"
    "net/http"
    
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
)

type HTTPClient struct {
    client *http.Client
}

func (c *HTTPClient) GetWithRequestID(ctx context.Context, url string) (*http.Response, error) {
    logger := zerolog.Ctx(ctx)
    if logger == nil {
        logger = &log.Logger
    }
    
    // 从上下文获取 Request ID
    id, ok := hlog.IDFromCtx(ctx)
    if !ok {
        logger.Warn().Msg("no request id in context")
    }
    
    // 创建带有 Request ID 的请求
    req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
    if err != nil {
        return nil, err
    }
    
    // 将 Request ID 传递给下游服务
    if ok {
        req.Header.Set("X-Request-Id", id.String())
    }
    
    logger.Debug().
        Str("url", url).
        Str("request_id", id.String()).
        Msg("calling downstream service")
    
    return c.client.Do(req)
}
```

## 第三章：错误处理与堆栈跟踪

### 3.1 错误日志的重要性

在生产环境中，错误日志是问题排查的主要依据。一个完善的错误日志系统应该能够提供足够的上下文信息，帮助开发者快速定位问题的根本原因。Zerolog 提供了丰富的错误处理功能，包括错误字段、堆栈跟踪、错误链等。

良好的错误日志应该包含以下信息：

**错误消息**是最基本的信息，描述发生了什么错误。但仅仅有错误消息往往不足以定位问题。

**错误堆栈**显示错误发生时的调用链，包括每个调用帧的文件名、行号和函数名。这是定位错误源头的关键信息。

**上下文信息**包括与错误相关的业务数据，如请求参数、用户 ID、操作类型等。这些信息帮助开发者理解错误发生的场景。

**错误链**记录错误的传播路径，当一个错误由另一个错误引起时，可以追踪错误的根本原因。

### 3.2 基础错误日志

Zerolog 的 `Err()` 方法用于记录错误。以下是基础用法：

```go
package main

import (
    "errors"
    
    "github.com/rs/zerolog/log"
)

func divide(a, b float64) (float64, error) {
    if b == 0 {
        err := errors.New("division by zero")
        log.Error().
            Float64("a", a).
            Float64("b", b).
            Err(err).
            Msg("division failed")
        return 0, err
    }
    return a / b, nil
}
```

输出示例：

```json
{"level":"error","a":10,"b":0,"error":"division by zero","message":"division failed"}
```

### 3.3 配置错误堆栈跟踪

Zerolog 本身不包含堆栈跟踪功能，而是通过 `ErrorStackMarshaler` 接口支持外部实现。官方推荐使用 `github.com/pkg/errors` 包和 `github.com/rs/zerolog/pkgerrors` 子包来实现堆栈跟踪：

首先安装依赖：

```bash
go get github.com/pkg/errors
go get github.com/rs/zerolog/pkgerrors
```

配置错误堆栈跟踪：

```go
package main

import (
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/pkgerrors"
    "github.com/rs/zerolog/log"
)

func SetupErrorStack() {
    // 配置错误堆栈格式化器
    zerolog.ErrorStackMarshaler = pkgerrors.MarshalStack
}
```

使用堆栈跟踪记录错误：

```go
package main

import (
    "errors"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func innerFunction() error {
    return errors.New("inner error")
}

func middleFunction() error {
    err := innerFunction()
    if err != nil {
        return err
    }
    return nil
}

func outerFunction() error {
    err := middleFunction()
    if err != nil {
        // 使用 Stack() 方法启用堆栈跟踪
        log.Error().Stack().Err(err).Msg("operation failed")
        return err
    }
    return nil
}
```

输出示例：

```json
{
  "level": "error",
  "error": "inner error",
  "stack": [
    {"func":"main.innerFunction","line":"15","source":"main.go"},
    {"func":"main.middleFunction","line":"21","source":"main.go"},
    {"func":"main.outerFunction","line":"29","source":"main.go"}
  ],
  "message": "operation failed"
}
```

### 3.4 错误链与根本原因分析

在复杂的业务逻辑中，一个错误往往是另一个错误的结果。Go 语言的错误包装机制允许我们追踪错误的传播路径：

```go
package main

import (
    "errors"
    "fmt"
    
    "github.com/rs/zerolog/log"
)

type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed for %s: %s", e.Field, e.Message)
}

type DatabaseError struct {
    Query   string
    Message string
}

func (e *DatabaseError) Error() string {
    return fmt.Sprintf("database error for query %s: %s", e.Query, e.Message)
}

func validateInput(input string) error {
    if input == "" {
        return &ValidationError{Field: "name", Message: "cannot be empty"}
    }
    return nil
}

func saveToDatabase(input string) error {
    err := validateInput(input)
    if err != nil {
        // 包装原始错误
        return fmt.Errorf("failed to save: %w", err)
    }
    
    // 模拟数据库错误
    return &DatabaseError{Query: "INSERT", Message: "connection timeout"}
}

func handleRequest(input string) error {
    err := saveToDatabase(input)
    if err != nil {
        // 获取错误链的根因
        log.Error().Stack().Err(err).Msg("request handling failed")
        
        // 遍历错误链
        var validationErr *ValidationError
        var databaseErr *DatabaseError
        
        if errors.As(err, &validationErr) {
            log.Error().
                Str("field", validationErr.Field).
                Msg("validation error")
        }
        
        if errors.As(err, &databaseErr) {
            log.Error().
                Str("query", databaseErr.Query).
                Str("message", databaseErr.Message).
                Msg("database error")
        }
        
        return err
    }
    return nil
}
```

### 3.5 生产环境错误处理模式

在生产环境中，我们需要建立一套统一的错误处理模式，确保错误日志的一致性和有用性。以下是推荐的生产环境错误处理模式：

```go
package main

import (
    "errors"
    "net/http"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

type AppError struct {
    Code        string
    Message     string
    StatusCode  int
    Err         error
    RequestID   string
    UserID      string
    Operation   string
}

func (e *AppError) Error() string {
    if e.Err != nil {
        return fmt.Sprintf("%s: %v", e.Message, e.Err)
    }
    return e.Message
}

// Unwrap 实现 error 接口
func (e *AppError) Unwrap() error {
    return e.Err
}

// LogError 记录应用错误
func LogError(err error, operation string) {
    logger := log.Logger.With().Logger()
    
    var appErr *AppError
    if errors.As(err, &appErr) {
        logger = logger.With().
            Str("error_code", appErr.Code).
            Str("operation", appErr.Operation).
            Str("user_id", appErr.UserID).
            Int("status_code", appErr.StatusCode).
            Logger()
    }
    
    logger.Error().
        Str("operation", operation).
        Err(err).
        Stack().
        Msg("application error")
}

// HTTP 错误处理中间件
func ErrorHandler(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        defer func() {
            if r := recover(); r != nil {
                // 恢复 panic，记录错误
                err := recoverError(r)
                LogError(err, "panic recovery")
                
                // 返回 500 错误
                w.WriteHeader(http.StatusInternalServerError)
                w.Write([]byte("internal server error"))
            }
        }()
        
        next.ServeHTTP(w, r)
    })
}

func recoverError(r interface{}) error {
    switch v := r.(type) {
    case error:
        return v
    default:
        return errors.New("unknown panic")
    }
}
```

### 3.6 错误级别策略

不同级别的错误应该采用不同的记录策略。以下是生产环境推荐的错误级别策略：

```go
package main

import (
    "github.com/rs/zerolog/log"
)

func handleError(err error, level string) {
    switch level {
    case "critical":
        // Critical 级别：影响整个系统，需要立即关注
        log.Fatal().Err(err).Msg("critical system error")
        
    case "error":
        // Error 级别：单个请求失败，不影响系统整体运行
        log.Error().Err(err).Msg("operation failed")
        
    case "warn":
        // Warn 级别：潜在问题，可能影响性能或功能
        log.Warn().Err(err).Msg("operation completed with warning")
        
    case "info":
        // Info 级别：正常处理的预期错误
        log.Info().Err(err).Msg("operation handled gracefully")
    }
}
```

## 第四章：高性能日志输出配置

### 4.1 输出目标配置

Zerolog 支持多种输出目标，包括标准输出、文件、syslog 等。在生产环境中，我们需要根据实际需求选择合适的输出方式：

**控制台输出**适用于开发环境和容器化部署：

```go
package main

import (
    "os"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func SetupConsoleOutput() {
    consoleWriter := zerolog.ConsoleWriter{
        Out: os.Stdout,
    }
    
    log.Logger = zerolog.New(consoleWriter).
        With().
        Timestamp().
        Logger()
}
```

**文件输出**适用于需要持久化日志的场景：

```go
package main

import (
    "os"
    "path/filepath"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func SetupFileOutput(logDir string) error {
    // 确保日志目录存在
    if err := os.MkdirAll(logDir, 0755); err != nil {
        return err
    }
    
    logFile := filepath.Join(logDir, "app.log")
    
    file, err := os.OpenFile(logFile, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
    if err != nil {
        return err
    }
    
    logger := zerolog.New(file).
        With().
        Timestamp().
        Logger()
    
    log.Logger = logger
    return nil
}
```

**多目标输出**同时输出到多个目标：

```go
package main

import (
    "os"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func SetupMultiOutput() {
    consoleWriter := zerolog.ConsoleWriter{
        Out: os.Stdout,
    }
    
    file, err := os.OpenFile("/var/log/app.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
    if err != nil {
        log.Fatal().Err(err).Msg("failed to open log file")
    }
    
    // 多重写入器
    multi := zerolog.MultiLevelWriter(consoleWriter, file)
    
    log.Logger = zerolog.New(multi).
        With().
        Timestamp().
        Logger()
}
```

### 4.2 日志轮转配置

在生产环境中，日志文件会不断增长，需要配置日志轮转来管理磁盘空间。虽然 Zerolog 本身不提供日志轮转功能，但可以与 `github.com/natefinch/lumberjack` 配合使用：

首先安装依赖：

```bash
go get github.com/natefinch/lumberjack
```

配置带轮转的日志输出：

```go
package main

import (
    "os"
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
    "github.com/natefinch/lumberjack"
)

func SetupLogRotation() {
    // 配置 lumberjack
    logFile := &lumberjack.Logger{
        Filename:   "/var/log/app/app.log",
        MaxSize:    100,    // 每个日志文件最大 100MB
        MaxBackups: 30,     // 保留 30 个备份
        MaxAge:     30,     // 保留 30 天
        Compress:   true,   // 压缩旧日志
        LocalTime:  true,   // 使用本地时间
    }
    
    logger := zerolog.New(logFile).
        With().
        Timestamp().
        Str("service", "app").
        Logger()
    
    log.Logger = logger
    
    // 程序退出时关闭日志文件
    defer logFile.Close()
}
```

### 4.3 非阻塞写入优化

在高并发场景下，日志写入可能成为性能瓶颈。当日志写入速度跟不上日志产生速度时，会阻塞业务代码的执行。Zerolog 提供了 `diode`（二极管）写入器来实现非阻塞日志写入：

安装依赖：

```bash
go get code.cloudfoundry.org/go-diodes
```

配置非阻塞写入：

```go
package main

import (
    "os"
    "time"
    
    "code.cloudfoundry.org/go-diodes"
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func SetupNonBlocking() {
    // 创建二极管写入器
    diodeWriter := diode.NewWriter(
        os.Stdout,              // 输出目标
        1000,                   // 缓冲区大小
        10*time.Millisecond,    // 刷新间隔
        func(missed int) {
            // 丢失日志时的回调
            log.Warn().
                Int("missed", missed).
                Msg("log entries dropped")
        },
    )
    
    logger := zerolog.New(diodeWriter).
        With().
        Timestamp().
        Logger()
    
    log.Logger = logger
}
```

### 4.4 日志采样配置

在极高吞吐量的场景下，我们可能需要通过采样来减少日志量。Zerolog 提供了灵活的采样配置：

```go
package main

import (
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func SetupSampling() {
    // 基础采样：每 10 条日志只记录 1 条
    sampledLogger := log.Sample(&zerolog.BasicSampler{N: 10})
    
    // 高级采样：不同级别使用不同采样策略
    advancedLogger := log.Sample(zerolog.LevelSampler{
        DebugSampler: &zerolog.BurstSampler{
            Burst: 5,
            Period: 1 * time.Second,
            NextSampler: &zerolog.BasicSampler{N: 100},
        },
        InfoSampler: &zerolog.BurstSampler{
            Burst: 10,
            Period: 1 * time.Second,
            NextSampler: &zerolog.BasicSampler{N: 50},
        },
        WarnSampler: &zerolog.BurstSampler{
            Burst: 20,
            Period: 1 * time.Second,
        },
        ErrorSampler: nil, // 错误日志不采样
    })
    
    _ = sampledLogger
    _ = advancedLogger
}
```

### 4.5 自定义日志格式

Zerolog 允许我们自定义日志的输出格式，包括字段名、格式化函数等：

```go
package main

import (
    "fmt"
    "strings"
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func SetupCustomFormat() {
    // 自定义字段名
    zerolog.TimestampFieldName = "ts"
    zerolog.LevelFieldName = "lvl"
    zerolog.MessageFieldName = "msg"
    zerolog.ErrorFieldName = "err"
    
    // 自定义级别显示
    zerolog.LevelFieldMarshalFunc = func(l zerolog.Level) string {
        switch l {
        case zerolog.TraceLevel:
            return "TRACE"
        case zerolog.DebugLevel:
            return "DEBUG"
        case zerolog.InfoLevel:
            return "INFO"
        case zerolog.WarnLevel:
            return "WARN"
        case zerolog.ErrorLevel:
            return "ERROR"
        case zerolog.FatalLevel:
            return "FATAL"
        case zerolog.PanicLevel:
            return "PANIC"
        default:
            return "UNKNOWN"
        }
    }
    
    // 自定义时间格式
    zerolog.TimeFieldFormat = time.RFC3339Nano
    
    // 自定义控制台输出格式
    consoleWriter := zerolog.ConsoleWriter{
        Out:        os.Stdout,
        TimeFormat: "2006-01-02 15:04:05.000",
    }
    
    consoleWriter.FormatLevel = func(i interface{}) string {
        return strings.ToUpper(fmt.Sprintf("| %-6s |", i))
    }
    
    consoleWriter.FormatMessage = func(i interface{}) string {
        return fmt.Sprintf(">>> %s <<<", i)
    }
    
    consoleWriter.FormatFieldName = func(i interface{}) string {
        return fmt.Sprintf("%s:", i)
    }
    
    consoleWriter.FormatFieldValue = func(i interface{}) string {
        return strings.ToUpper(fmt.Sprintf("%s", i))
    }
    
    log.Logger = zerolog.New(consoleWriter).With().Timestamp().Logger()
}
```

## 第五章：上下文与 Logger 管理

### 5.1 Context 集成

Zerolog 深度集成 Go 的 context 包，允许在请求处理过程中传递和获取 Logger。这种设计使得日志器可以随着请求在服务间传递，同时保持上下文信息的完整性：

```go
package main

import (
    "context"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func processRequest(ctx context.Context) {
    // 从 context 获取 Logger
    logger := zerolog.Ctx(ctx)
    
    if logger == nil {
        // 使用全局 Logger 作为备选
        logger = &log.Logger
    }
    
    logger.Info().Msg("processing request")
    
    // 创建子 Logger 并注入新的上下文信息
    childLogger := logger.With().
        Str("action", "database_query").
        Str("query", "SELECT * FROM users").
        Logger()
    
    // 使用新的 Logger 继续处理
    childLogger.Info().Msg("executing query")
    
    // 将子 Logger 注入新的 context
    ctx = childLogger.WithContext(ctx)
    
    // 继续传递
    saveToDatabase(ctx)
}

func saveToDatabase(ctx context.Context) {
    logger := zerolog.Ctx(ctx)
    if logger != nil {
        logger.Info().Msg("saving to database")
    }
}
```

### 5.2 子 Logger 创建

子 Logger 允许我们在保留父 Logger 基本配置的同时，添加特定的上下文信息。这在记录具有共同特征的日志时非常有用：

```go
package main

import (
    "github.com/rs/zerolog/log"
)

func createSubLoggers() {
    // 创建基础 Logger
    baseLogger := log.With().
        Str("service", "user-service").
        Str("environment", "production").
        Logger()
    
    // 创建数据库操作子 Logger
    dbLogger := baseLogger.With().
        Str("component", "database").
        Logger()
    
    // 创建缓存操作子 Logger
    cacheLogger := baseLogger.With().
        Str("component", "cache").
        Logger()
    
    // 创建 HTTP 客户端子 Logger
    httpLogger := baseLogger.With().
        Str("component", "http-client").
        Logger()
    
    // 使用子 Logger
    dbLogger.Info().Str("query", "SELECT * FROM users").Msg("database query")
    cacheLogger.Info().Str("key", "user:123").Msg("cache hit")
    httpLogger.Info().Str("url", "https://api.example.com").Msg("HTTP request")
}
```

### 5.3 动态上下文更新

在某些场景下，我们需要在处理过程中动态添加上下文信息。Zerolog 提供了 `UpdateContext` 方法来实现这一功能：

```go
package main

import (
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func dynamicContext() {
    logger := log.With().
        Str("service", "api").
        Logger()
    
    // 初始上下文
    logger.Info().Msg("request received")
    
    // 动态添加用户信息
    logger.UpdateContext(func(c zerolog.Context) zerolog.Context {
        return c.Str("user_id", "12345")
    })
    
    // 添加后继续使用
    logger.Info().Msg("user authenticated")
    
    // 再添加更多信息
    logger.UpdateContext(func(c zerolog.Context) zerolog.Context {
        return c.Str("session_id", "abc123")
    })
    
    logger.Info().Msg("session created")
}
```

**注意**：`UpdateContext` 不是线程安全的，在并发环境中应该避免使用，或者在使用前创建 Logger 的副本。

### 5.4 Logger 池化与性能

在高并发场景下，频繁创建和销毁 Logger 会带来额外的开销。以下是一些性能优化的建议：

```go
package main

import (
    "sync"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

var (
    loggerPool = sync.Pool{
        New: func() interface{} {
            return log.With().
                Str("pool", "shared").
                Logger()
        },
    }
)

func getLoggerFromPool() zerolog.Logger {
    return *loggerPool.Get().(*zerolog.Logger)
}

func returnLoggerToPool(l zerolog.Logger) {
    loggerPool.Put(&l)
}

func usePooledLogger() {
    logger := getLoggerFromPool()
    defer returnLoggerToPool(logger)
    
    logger.Info().Msg("using pooled logger")
}
```

## 第六章：HTTP 服务集成实战

### 6.1 标准库 HTTP 服务集成

以下是使用 Go 标准库 `net/http` 的完整集成示例：

```go
package main

import (
    "context"
    "fmt"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
)

func main() {
    // 初始化日志
    SetupProductionLogger()
    
    // 创建 HTTP 服务
    mux := http.NewServeMux()
    
    // 注册路由
    mux.HandleFunc("/", homeHandler)
    mux.HandleFunc("/users", usersHandler)
    mux.HandleFunc("/users/", userHandler)
    mux.HandleFunc("/health", healthHandler)
    
    // 配置中间件
    handler := SetupMiddleware(mux)
    
    // 创建 HTTP 服务器
    srv := &http.Server{
        Addr:         ":8080",
        Handler:      handler,
        ReadTimeout:  10 * time.Second,
        WriteTimeout: 10 * time.Second,
        IdleTimeout:  60 * time.Second,
    }
    
    // 启动服务器
    go func() {
        log.Info().Msg("server starting on :8080")
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatal().Err(err).Msg("server failed")
        }
    }()
    
    // 等待中断信号
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    
    log.Info().Msg("shutting down server...")
    
    // 优雅关闭
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()
    
    if err := srv.Shutdown(ctx); err != nil {
        log.Error().Err(err).Msg("server forced to shutdown")
    }
    
    log.Info().Msg("server stopped")
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
    logger := hlog.FromRequest(r)
    
    logger.Info().
        Str("path", r.URL.Path).
        Msg("home page accessed")
    
    fmt.Fprint(w, "Welcome to the API!")
}

func usersHandler(w http.ResponseWriter, r *http.Request) {
    logger := hlog.FromRequest(r)
    
    logger.Info().
        Str("method", r.Method).
        Msg("users endpoint accessed")
    
    switch r.Method {
    case http.MethodGet:
        listUsers(w, r, logger)
    case http.MethodPost:
        createUser(w, r, logger)
    default:
        http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
    }
}

func userHandler(w http.ResponseWriter, r *http.Request) {
    logger := hlog.FromRequest(r)
    
    userID := extractUserID(r.URL.Path)
    
    logger.Info().
        Str("user_id", userID).
        Str("method", r.Method).
        Msg("user operation")
    
    switch r.Method {
    case http.MethodGet:
        getUser(w, r, userID, logger)
    case http.MethodPut:
        updateUser(w, r, userID, logger)
    case http.MethodDelete:
        deleteUser(w, r, userID, logger)
    default:
        http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
    }
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    fmt.Fprint(w, "OK")
}

func listUsers(w http.ResponseWriter, r *http.Request, logger *zerolog.Logger) {
    logger.Info().Msg("listing all users")
    // 模拟获取用户列表
    users := []string{"alice", "bob", "charlie"}
    logger.Debug().Interface("users", users).Msg("users retrieved")
    fmt.Fprint(w, "Users: "+strings.Join(users, ", "))
}

func createUser(w http.ResponseWriter, r *http.Request, logger *zerolog.Logger) {
    logger.Info().Msg("creating new user")
    w.WriteHeader(http.StatusCreated)
    fmt.Fprint(w, "User created")
}

func getUser(w http.ResponseWriter, r *http.Request, userID string, logger *zerolog.Logger) {
    logger.Info().
        Str("user_id", userID).
        Msg("getting user")
    fmt.Fprintf(w, "User: %s", userID)
}

func updateUser(w http.ResponseWriter, r *http.Request, userID string, logger *zerolog.Logger) {
    logger.Info().
        Str("user_id", userID).
        Msg("updating user")
    fmt.Fprintf(w, "User %s updated", userID)
}

func deleteUser(w http.ResponseWriter, r *http.Request, userID string, logger *zerolog.Logger) {
    logger.Warn().
        Str("user_id", userID).
        Msg("deleting user")
    fmt.Fprintf(w, "User %s deleted", userID)
}

func extractUserID(path string) string {
    // 简化实现，实际应使用路由库
    parts := strings.Split(path, "/")
    if len(parts) >= 3 {
        return parts[2]
    }
    return ""
}

func SetupProductionLogger() {
    zerolog.TimeFieldFormat = zerolog.TimeFormatUnixMs
    zerolog.SetGlobalLevel(zerolog.InfoLevel)
    zerolog.ErrorStackMarshaler = pkgerrors.MarshalStack
    
    consoleWriter := zerolog.ConsoleWriter{
        Out: os.Stdout,
    }
    
    log.Logger = zerolog.New(consoleWriter).
        With().
        Timestamp().
        Str("service", "api-service").
        Str("environment", "production").
        Logger()
}

func SetupMiddleware(handler http.Handler) http.Handler {
    handler = hlog.NewHandler(log.Logger)(handler)
    handler = hlog.RequestIDHandler("request_id", "X-Request-Id")(handler)
    handler = hlog.AccessHandler(func(r *http.Request, status, size int, duration time.Duration) {
        hlog.FromRequest(r).Info().
            Str("method", r.Method).
            Stringer("url", r.URL).
            Int("status", status).
            Int("size", size).
            Dur("duration", duration).
            Msg("request completed")
    })(handler)
    handler = hlog.RemoteAddrHandler("client_ip")(handler)
    handler = hlog.UserAgentHandler("user_agent")(handler)
    handler = hlog.RefererHandler("referer")(handler)
    return handler
}
```

### 6.2 与路由库集成

Zerolog 可以与各种路由库无缝集成。以下是与 `chi` 路由库的集成示例：

```go
package main

import (
    "context"
    "fmt"
    "net/http"
    "time"
    
    "github.com/go-chi/chi/v5"
    "github.com/go-chi/chi/v5/middleware"
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
)

func SetupChiRouter() *chi.Mux {
    r := chi.NewRouter()
    
    // 使用 chi 的压缩中间件
    r.Use(middleware.Compress(5, "application/json"))
    
    // 使用 chi 的请求 ID 中间件
    r.Use(middleware.RequestID)
    
    // 配置日志中间件
    r.Use(chiLogger)
    
    // 路由
    r.Get("/", homeHandler)
    r.Route("/api/v1", func(r chi.Router) {
        r.Get("/users", listUsersHandler)
        r.Post("/users", createUserHandler)
        r.Get("/users/{id}", getUserHandler)
        r.Put("/users/{id}", updateUserHandler)
        r.Delete("/users/{id}", deleteUserHandler)
    })
    
    return r
}

func chiLogger(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        logger := log.With().
            Str("method", r.Method).
            Str("url", r.URL.String()).
            Str("user_agent", r.UserAgent()).
            Str("remote_addr", r.RemoteAddr).
            Logger()
        
        ctx := logger.WithContext(r.Context())
        
        ww := middleware.NewWrapResponseWriter(w, r.ProtoMajor)
        
        start := time.Now()
        
        next.ServeHTTP(ww, r)
        
        duration := time.Since(start)
        
        logger.Info().
            Int("status", ww.Status()).
            Int("size", ww.BytesWritten()).
            Dur("duration", duration).
            Msg("request completed")
    }
    
    return http.HandlerFunc(fn)
}
```

### 6.3 请求日志格式化

在生产环境中，我们通常需要标准化的请求日志格式。以下是一个完整的请求日志配置：

```go
package main

import (
    "bytes"
    "encoding/json"
    "io"
    "net/http"
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
)

type RequestLog struct {
    RequestID    string            `json:"request_id"`
    Timestamp    time.Time         `json:"timestamp"`
    Method       string            `json:"method"`
    URL          string            `json:"url"`
    Protocol     string            `json:"protocol"`
    Host         string            `json:"host"`
    Path         string            `json:"path"`
    Query        string            `json:"query"`
    RemoteAddr   string            `json:"remote_addr"`
    UserAgent    string            `json:"user_agent"`
    Referer      string            `json:"referer"`
    StatusCode   int               `json:"status_code"`
    ContentType  string            `json:"content_type"`
    ContentLength int              `json:"content_length"`
    Duration     time.Duration     `json:"duration"`
    ResponseSize int               `json:"response_size"`
    Headers      map[string]string `json:"headers,omitempty"`
}

func RequestLoggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // 读取请求体（如果需要）
        var bodyBytes []byte
        if r.Body != nil {
            bodyBytes, _ = io.ReadAll(r.Body)
            r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))
        }
        
        start := time.Now()
        logger := hlog.FromRequest(r)
        
        // 创建包装的 ResponseWriter 以捕获响应信息
        rw := &responseWriter{
            ResponseWriter: w,
            statusCode:     200,
            size:           0,
        }
        
        // 处理请求
        next.ServeHTTP(rw, r)
        
        duration := time.Since(start)
        
        // 构建请求日志
        requestLog := RequestLog{
            RequestID:    getRequestID(r),
            Timestamp:    start,
            Method:       r.Method,
            URL:          r.URL.String(),
            Protocol:     r.Proto,
            Host:         r.Host,
            Path:         r.URL.Path,
            Query:        r.URL.RawQuery,
            RemoteAddr:   r.RemoteAddr,
            UserAgent:    r.UserAgent(),
            Referer:      r.Referer(),
            StatusCode:   rw.statusCode,
            ContentType:  r.Header.Get("Content-Type"),
            ContentLength: len(bodyBytes),
            Duration:     duration,
            ResponseSize: rw.size,
        }
        
        // 序列化 Headers（注意：生产环境可能需要过滤敏感信息）
        headers := make(map[string]string)
        for k, v := range r.Header {
            if len(v) > 0 {
                headers[k] = v[0]
            }
        }
        requestLog.Headers = headers
        
        // 记录请求日志
        logger.Info().
            Str("request_id", requestLog.RequestID).
            Str("method", requestLog.Method).
            Str("url", requestLog.URL).
            Int("status_code", requestLog.StatusCode).
            Int("content_length", requestLog.ContentLength).
            Int("response_size", requestLog.ResponseSize).
            Dur("duration", requestLog.Duration).
            Msg("HTTP request")
    })
}

type responseWriter struct {
    http.ResponseWriter
    statusCode int
    size       int
}

func (rw *responseWriter) WriteHeader(statusCode int) {
    rw.statusCode = statusCode
    rw.ResponseWriter.WriteHeader(statusCode)
}

func (rw *responseWriter) Write(b []byte) (int, error) {
    size, err := rw.ResponseWriter.Write(b)
    rw.size += size
    return size, err
}

func getRequestID(r *http.Request) string {
    id, ok := hlog.IDFromRequest(r)
    if ok {
        return id.String()
    }
    return ""
}
```

### 6.4 业务日志与请求关联

在业务处理过程中，我们需要将业务日志与请求关联起来。以下是最佳实践：

```go
package main

import (
    "context"
    "net/http"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
)

type ContextKey string

const (
    UserIDKey    ContextKey = "user_id"
    OperationKey ContextKey = "operation"
    RequestIDKey ContextKey = "request_id"
)

func WithUserID(ctx context.Context, userID string) context.Context {
    return context.WithValue(ctx, UserIDKey, userID)
}

func WithOperation(ctx context.Context, operation string) context.Context {
    return context.WithValue(ctx, OperationKey, operation)
}

type BusinessLogger struct {
    logger  *zerolog.Logger
    request *http.Request
}

func NewBusinessLogger(r *http.Request) *BusinessLogger {
    logger := hlog.FromRequest(r)
    
    // 注入常用字段
    logger = logger.With().
        Str("request_id", getRequestID(r)).
        Logger()
    
    return &BusinessLogger{
        logger:  &logger,
        request: r,
    }
}

func (bl *BusinessLogger) WithUser(userID string) *BusinessLogger {
    newLogger := bl.logger.With().
        Str("user_id", userID).
        Logger()
    return &BusinessLogger{
        logger:  &newLogger,
        request: bl.request,
    }
}

func (bl *BusinessLogger) WithOperation(operation string) *BusinessLogger {
    newLogger := bl.logger.With().
        Str("operation", operation).
        Logger()
    return &BusinessLogger{
        logger:  &newLogger,
        request: bl.request,
    }
}

func (bl *BusinessLogger) Info() *zerolog.Event {
    return bl.logger.Info()
}

func (bl *BusinessLogger) Error() *zerolog.Event {
    return bl.logger.Error()
}

func (bl *BusinessLogger) Debug() *zerolog.Event {
    return bl.logger.Debug()
}

func (bl *BusinessLogger) Warn() *zerolog.Event {
    return bl.logger.Warn()
}

func getRequestID(r *http.Request) string {
    id, ok := hlog.IDFromRequest(r)
    if ok {
        return id.String()
    }
    return ""
}

// 使用示例
func userHandler(w http.ResponseWriter, r *http.Request) {
    bl := NewBusinessLogger(r)
    
    userID := r.URL.Query().Get("user_id")
    
    bl.WithUser(userID).
        WithOperation("get_user").
        Info().
        Str("action", "fetching user").
        Msg("starting user fetch")
    
    // 业务逻辑...
    
    bl.WithUser(userID).
        WithOperation("get_user").
        Info().
        Str("action", "user fetched").
        Msg("user fetch completed")
}
```

## 第七章：最佳实践与性能调优

### 7.1 日志级别使用策略

制定清晰的日志级别使用策略对于维护良好的日志质量至关重要。以下是生产环境推荐的策略：

```go
package main

import (
    "github.com/rs/zerolog/log"
)

// 日志级别策略常量
const (
    LevelDebug = "debug"
    LevelInfo  = "info"
    LevelWarn  = "warn"
    LevelError = "error"
)

// 根据环境返回合适的日志级别
func GetLogLevel(environment string) zerolog.Level {
    switch environment {
    case "development":
        return zerolog.DebugLevel
    case "staging":
        return zerolog.DebugLevel
    case "production":
        return zerolog.InfoLevel
    default:
        return zerolog.InfoLevel
    }
}

// 使用建议
var logLevelGuidelines = map[string]string{
    "debug": "仅在开发调试时使用，记录详细的执行步骤和变量值",
    "info":  "记录正常的业务流程操作，如请求开始/结束、关键状态变更",
    "warn":  "记录潜在的问题，如缓存未命中、超时重试、资源使用率警告",
    "error": "记录错误和异常，包括业务错误、系统错误、第三方调用失败",
    "fatal": "记录导致程序无法继续运行的严重错误，会终止程序",
    "panic": "记录程序 panic，通常用于捕获未预期的严重错误",
}
```

### 7.2 避免日志性能陷阱

以下是一些常见的性能陷阱以及避免方法：

```go
package main

import (
    "github.com/rs/zerolog/log"
)

func avoidPerformancePitfalls() {
    // 陷阱 1：在热路径中创建 Logger
    // 避免：每次调用都创建新的 Logger
    funcBad := func() {
        log.With().Str("key", "value").Logger().Info().Msg("bad")
    }
    
    // 推荐：预先创建 Logger
    logger := log.With().Str("key", "value").Logger()
    funcGood := func() {
        logger.Info().Msg("good")
    }
    
    _ = funcBad
    _ = funcGood
    
    // 陷阱 2：使用 fmt.Sprintf 在日志消息中格式化
    // 避免
    funcBad2 := func() {
        log.Info().Msg("user " + "name" + " logged in")
    }
    
    // 推荐：使用字段
    funcGood2 := func() {
        log.Info().Str("user", "name").Msg("logged in")
    }
    
    _ = funcBad2
    _ = funcGood2
    
    // 陷阱 3：在禁用日志时仍然计算复杂参数
    // 避免
    funcBad3 := func() {
        expensiveValue := computeExpensiveValue()
        log.Debug().Interface("value", expensiveValue).Msg("")
    }
    
    // 推荐：先检查日志级别
    funcGood3 := func() {
        if e := log.Debug(); e.Enabled() {
            expensiveValue := computeExpensiveValue()
            e.Interface("value", expensiveValue).Msg("")
        }
    }
    
    _ = funcBad3
    _ = funcGood3
    
    // 陷阱 4：记录大型对象
    // 避免：直接记录整个大对象
    funcBad4 := func() {
        largeData := make([]byte, 1024*1024) // 1MB
        log.Info().Bytes("data", largeData).Msg("")
    }
    
    // 推荐：只记录关键信息
    funcGood4 := func() {
        log.Info().
            Int("size", 1024*1024).
            Str("summary", "large data truncated").
            Msg("")
    }
    
    _ = funcBad4
    _ = funcGood4
}

func computeExpensiveValue() string {
    // 模拟耗时操作
    return "expensive"
}
```

### 7.3 敏感数据过滤

在日志中包含敏感数据是安全风险。以下是敏感数据过滤的最佳实践：

```go
package main

import (
    "regexp"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

var (
    // 敏感数据正则表达式
    creditCardRegex  = regexp.MustCompile(`\b(?:\d[ -]*?){13,16}\b`)
    emailRegex       = regexp.MustCompile(`[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`)
    passwordRegex    = regexp.MustCompile(`(?i)(password|passwd|pwd)[\s:=]*[^\s,]+`)
    tokenRegex       = regexp.MustCompile(`(?i)(api_key|apikey|token|secret)[\s:=]*[^\s,]+`)
    ssnRegex         = regexp.MustCompile(`\b\d{3}-\d{2}-\d{4}\b`)
)

func SetupSensitiveDataFilter() {
    // 自定义日志过滤
    zerolog.MessageFieldName = "message"
    
    // 创建一个包装的 Logger 来过滤敏感数据
    log.Logger = log.With().Caller().Logger()
}

// 过滤敏感数据
func sanitizeData(data map[string]interface{}) map[string]interface{} {
    result := make(map[string]interface{})
    
    for k, v := range data {
        if isSensitiveKey(k) {
            result[k] = "[REDACTED]"
        } else if str, ok := v.(string); ok {
            result[k] = sanitizeString(str)
        } else {
            result[k] = v
        }
    }
    
    return result
}

func isSensitiveKey(key string) bool {
    keyLower := toLower(key)
    sensitiveKeys := []string{
        "password", "passwd", "pwd",
        "secret", "api_key", "apikey", "token",
        "credit_card", "card_number", "cvv",
        "ssn", "social_security",
        "access_token", "refresh_token",
    }
    
    for _, sk := range sensitiveKeys {
        if keyLower == sk || contains(keyLower, sk) {
            return true
        }
    }
    return false
}

func sanitizeString(s string) string {
    s = creditCardRegex.ReplaceAllString(s, "[CREDIT_CARD]")
    s = emailRegex.ReplaceAllString(s, "[EMAIL]")
    s = passwordRegex.ReplaceAllString(s, "[PASSWORD]")
    s = tokenRegex.ReplaceAllString(s, "[TOKEN]")
    s = ssnRegex.ReplaceAllString(s, "[SSN]")
    return s
}

func toLower(s string) string {
    result := make([]byte, len(s))
    for i := 0; i < len(s); i++ {
        c := s[i]
        if c >= 'A' && c <= 'Z' {
            result[i] = c + 32
        } else {
            result[i] = c
        }
    }
    return string(result)
}

func contains(s, substr string) bool {
    return len(s) >= len(substr) && findSubstring(s, substr)
}

func findSubstring(s, substr string) bool {
    for i := 0; i <= len(s)-len(substr); i++ {
        if s[i:i+len(substr)] == substr {
            return true
        }
    }
    return false
}
```

### 7.4 日志聚合建议

在微服务架构中，日志聚合是实现可观测性的关键。以下是与常见日志聚合系统集成的建议：

```go
package main

import (
    "os"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

func SetupForELK() {
    // 配置适合 ELK 栈的日志格式
    zerolog.TimestampFieldName = "@timestamp"
    zerolog.LevelFieldName = "level"
    zerolog.MessageFieldName = "message"
    
    // 添加服务标识字段
    log.Logger = log.With().
        Str("service", getServiceName()).
        Str("environment", getEnvironment()).
        Str("version", getVersion()).
        Logger()
}

func SetupForLoki() {
    // Loki 友好的配置
    zerolog.TimestampFieldName = "timestamp"
    zerolog.LevelFieldName = "level"
    
    // Loki 标签
    log.Logger = log.With().
        Str("service", getServiceName()).
        Str("environment", getEnvironment()).
        Str("level", "info"). // 会被覆盖
        Logger()
}

func SetupForCloudWatch() {
    // CloudWatch Logs 友好的配置
    // 确保 JSON 输出没有转义问题
    zerolog.MessageFieldName = "message"
    
    // CloudWatch 会自动提取时间戳
    zerolog.TimeFieldFormat = "2006-01-02T15:04:05.000Z07:00"
}

func SetupForDatadog() {
    // Datadog 友好的配置
    zerolog.MessageFieldName = "message"
    zerolog.TimestampFieldName = "date"
    
    // 添加 Datadog 标准字段
    log.Logger = log.With().
        Str("service", getServiceName()).
        Str("env", getEnvironment()).
        Str("version", getVersion()).
        Logger()
}

func getServiceName() string {
    return os.Getenv("SERVICE_NAME")
}

func getEnvironment() string {
    return os.Getenv("ENVIRONMENT")
}

func getVersion() string {
    return os.Getenv("VERSION")
}
```

### 7.5 监控与告警

将日志与监控告警系统集成：

```go
package main

import (
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
)

type ErrorTracker struct {
    errorCounts    map[string]int
    warningCounts  map[string]int
    errorWindow    time.Duration
    errorThreshold int
}

func NewErrorTracker(window time.Duration, threshold int) *ErrorTracker {
    return &ErrorTracker{
        errorCounts:    make(map[string]int),
        warningCounts:  make(map[string]int),
        errorWindow:    window,
        errorThreshold: threshold,
    }
}

func (et *ErrorTracker) TrackError(errorType string) {
    et.errorCounts[errorType]++
    
    // 检查是否超过阈值
    if et.errorCounts[errorType] >= et.errorThreshold {
        log.Warn().
            Str("error_type", errorType).
            Int("count", et.errorCounts[errorType]).
            Dur("window", et.errorWindow).
            Msg("error rate alert: threshold exceeded")
        
        // 触发告警
        et.sendAlert(errorType)
    }
}

func (et *ErrorTracker) TrackWarning(warningType string) {
    et.warningCounts[warningType]++
}

func (et *ErrorTracker) sendAlert(errorType string) {
    // 这里可以集成到你的告警系统
    // 如 PagerDuty、Opsgenie、Slack 等
    log.Info().
        Str("error_type", errorType).
        Msg("alert sent")
}

// 使用示例
func handleErrors() {
    tracker := NewErrorTracker(5*time.Minute, 10)
    
    // 在错误处理中使用
    func() {
        defer func() {
            if r := recover(); r != nil {
                tracker.TrackError("panic")
                log.Error().Interface("recovered", r).Msg("panic occurred")
            }
        }()
        
        // 可能 panic 的代码
    }()
}
```

## 第八章：完整生产配置示例

### 8.1 配置文件

以下是完整的生产环境配置文件：

```go
package config

import (
    "os"
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/pkgerrors"
)

type LoggerConfig struct {
    Level              string        `json:"level"`
    Format            string        `json:"format"`
    Output            string        `json:"output"`
    TimeFormat        string        `json:"time_format"`
    EnableStackTrace  bool          `json:"enable_stack_trace"`
    EnableCaller      bool          `json:"enable_caller"`
    ServiceName       string        `json:"service_name"`
    Environment       string        `json:"environment"`
    Version           string        `json:"version"`
    
    // 文件输出配置
    LogFile           string        `json:"log_file"`
    MaxSize           int           `json:"max_size"`        // MB
    MaxBackups        int           `json:"max_backups"`
    MaxAge            int           `json:"max_age"`         // days
    Compress          bool          `json:"compress"`
    
    // 采样配置
    SamplingEnabled   bool          `json:"sampling_enabled"`
    SampleRate        int           `json:"sample_rate"`     // 每 N 条记录 1 条
}

func LoadLoggerConfig() LoggerConfig {
    return LoggerConfig{
        Level:              getEnv("LOG_LEVEL", "info"),
        Format:             getEnv("LOG_FORMAT", "json"),
        Output:             getEnv("LOG_OUTPUT", "stdout"),
        TimeFormat:         getEnv("LOG_TIME_FORMAT", "unix_ms"),
        EnableStackTrace:  getEnvAsBool("LOG_STACK_TRACE", true),
        EnableCaller:       getEnvAsBool("LOG_CALLER", true),
        ServiceName:        getEnv("SERVICE_NAME", "unknown"),
        Environment:        getEnv("ENVIRONMENT", "development"),
        Version:            getEnv("VERSION", "unknown"),
        LogFile:            getEnv("LOG_FILE", ""),
        MaxSize:            getEnvAsInt("LOG_MAX_SIZE", 100),
        MaxBackups:         getEnvAsInt("LOG_MAX_BACKUPS", 30),
        MaxAge:             getEnvAsInt("LOG_MAX_AGE", 30),
        Compress:           getEnvAsBool("LOG_COMPRESS", true),
        SamplingEnabled:   getEnvAsBool("LOG_SAMPLING", false),
        SampleRate:         getEnvAsInt("LOG_SAMPLE_RATE", 10),
    }
}

func ConfigureLogger(cfg LoggerConfig) zerolog.Logger {
    // 设置时间格式
    switch cfg.TimeFormat {
    case "unix_ms":
        zerolog.TimeFieldFormat = zerolog.TimeFormatUnixMs
    case "unix":
        zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
    case "rfc3339":
        zerolog.TimeFieldFormat = time.RFC3339
    default:
        zerolog.TimeFieldFormat = cfg.TimeFormat
    }
    
    // 设置日志级别
    level := parseLevel(cfg.Level)
    zerolog.SetGlobalLevel(level)
    
    // 配置错误堆栈
    if cfg.EnableStackTrace {
        zerolog.ErrorStackMarshaler = pkgerrors.MarshalStack
    }
    
    // 配置调用者信息
    if cfg.EnableCaller {
        zerolog.CallerSkipFrameCount = 2
    }
    
    // 创建 Logger
    logger := zerolog.New(os.Stdout).
        With().
        Timestamp().
        Str("service", cfg.ServiceName).
        Str("environment", cfg.Environment).
        Str("version", cfg.Version)
    
    if cfg.EnableCaller {
        logger = logger.Caller()
    }
    
    return *logger.Logger()
}

func parseLevel(level string) zerolog.Level {
    switch level {
    case "trace":
        return zerolog.TraceLevel
    case "debug":
        return zerolog.DebugLevel
    case "info":
        return zerolog.InfoLevel
    case "warn", "warning":
        return zerolog.WarnLevel
    case "error":
        return zerolog.ErrorLevel
    case "fatal":
        return zerolog.FatalLevel
    case "panic":
        return zerolog.PanicLevel
    case "disabled":
        return zerolog.Disabled
    default:
        return zerolog.InfoLevel
    }
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func getEnvAsBool(key string, defaultValue bool) bool {
    value := os.Getenv(key)
    if value == "" {
        return defaultValue
    }
    return value == "1" || value == "true" || value == "TRUE"
}

func getEnvAsInt(key string, defaultValue int) int {
    value := os.Getenv(key)
    if value == "" {
        return defaultValue
    }
    var result int
    for _, c := range value {
        if c < '0' || c > '9' {
            return defaultValue
        }
        result = result*10 + int(c-'0')
    }
    return result
}
```

### 8.2 完整的应用入口示例

以下是整合所有功能的完整应用示例：

```go
package main

import (
    "context"
    "fmt"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"
    
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/hlog"
    "github.com/rs/zerolog/log"
    "your-app/config"
)

func main() {
    // 加载配置
    cfg := config.LoadLoggerConfig()
    
    // 配置日志
    logger := config.ConfigureLogger(cfg)
    log.Logger = logger
    
    // 设置全局日志级别
    zerolog.SetGlobalLevel(parseLevel(cfg.Level))
    
    log.Info().
        Str("service", cfg.ServiceName).
        Str("environment", cfg.Environment).
        Str("version", cfg.Version).
        Msg("starting application")
    
    // 创建 HTTP 服务器
    srv := &http.Server{
        Addr:         ":8080",
        ReadTimeout:  10 * time.Second,
        WriteTimeout: 30 * time.Second,
        IdleTimeout:  60 * time.Second,
    }
    
    // 配置路由
    mux := http.NewServeMux()
    mux.HandleFunc("/", healthCheck)
    mux.HandleFunc("/ready", readinessCheck)
    mux.HandleFunc("/api/users", usersHandler)
    mux.HandleFunc("/api/users/", userHandler)
    
    // 配置中间件
    handler := setupMiddleware(mux)
    handler = recoveryMiddleware(handler)
    srv.Handler = handler
    
    // 启动服务器
    go func() {
        log.Info().Msg("server starting on :8080")
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatal().Err(err).Msg("server failed")
        }
    }()
    
    // 等待中断信号
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    
    log.Info().Msg("shutting down server...")
    
    // 优雅关闭
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()
    
    if err := srv.Shutdown(ctx); err != nil {
        log.Error().Err(err).Msg("server forced to shutdown")
    }
    
    log.Info().Msg("server stopped")
}

func setupMiddleware(handler http.Handler) http.Handler {
    handler = hlog.NewHandler(log.Logger)(handler)
    handler = hlog.RequestIDHandler("request_id", "X-Request-Id")(handler)
    handler = hlog.AccessHandler(logRequest)(handler)
    handler = hlog.RemoteAddrHandler("client_ip")(handler)
    handler = hlog.UserAgentHandler("user_agent")(handler)
    handler = hlog.RefererHandler("referer")(handler)
    return handler
}

func logRequest(r *http.Request, status, size int, duration time.Duration) {
    hlog.FromRequest(r).Info().
        Str("method", r.Method).
        Stringer("url", r.URL).
        Int("status", status).
        Int("size", size).
        Dur("duration", duration).
        Msg("request completed")
}

func recoveryMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        defer func() {
            if r := recover(); r != nil {
                err := fmt.Errorf("panic: %v", r)
                log.Error().Stack().Err(err).Msg("panic recovered")
                w.WriteHeader(http.StatusInternalServerError)
                w.Write([]byte("internal server error"))
            }
        }()
        next.ServeHTTP(w, r)
    })
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
    logger := hlog.FromRequest(r)
    logger.Info().Msg("health check")
    w.WriteHeader(http.StatusOK)
    fmt.Fprint(w, "OK")
}

func readinessCheck(w http.ResponseWriter, r *http.Request) {
    logger := hlog.FromRequest(r)
    logger.Info().Msg("readiness check")
    w.WriteHeader(http.StatusOK)
    fmt.Fprint(w, "Ready")
}

func usersHandler(w http.ResponseWriter, r *http.Request) {
    logger := hlog.FromRequest(r)
    
    logger.Info().
        Str("method", r.Method).
        Msg("users endpoint")
    
    switch r.Method {
    case http.MethodGet:
        listUsers(w, r, logger)
    case http.MethodPost:
        createUser(w, r, logger)
    default:
        http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
    }
}

func userHandler(w http.ResponseWriter, r *http.Request) {
    logger := hlog.FromRequest(r)
    
    // 从 URL 提取用户 ID
    userID := extractUserID(r.URL.Path)
    
    logger.Info().
        Str("user_id", userID).
        Str("method", r.Method).
        Msg("user operation")
    
    switch r.Method {
    case http.MethodGet:
        getUser(w, r, userID, logger)
    case http.MethodPut:
        updateUser(w, r, userID, logger)
    case http.MethodDelete:
        deleteUser(w, r, userID, logger)
    default:
        http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
    }
}

func listUsers(w http.ResponseWriter, r *http.Request, logger *zerolog.Logger) {
    logger.Info().Msg("listing users")
    fmt.Fprint(w, `["user1", "user2", "user3"]`)
}

func createUser(w http.ResponseWriter, r *http.Request, logger *zerolog.Logger) {
    logger.Info().Msg("creating user")
    w.WriteHeader(http.StatusCreated)
    fmt.Fprint(w, `{"id": "new-user", "status": "created"}`)
}

func getUser(w http.ResponseWriter, r *http.Request, userID string, logger *zerolog.Logger) {
    logger.Info().
        Str("user_id", userID).
        Msg("getting user")
    
    if userID == "" {
        logger.Warn().Msg("empty user id requested")
        http.Error(w, "user id required", http.StatusBadRequest)
        return
    }
    
    fmt.Fprintf(w, `{"id": "%s", "name": "Test User"}`, userID)
}

func updateUser(w http.ResponseWriter, r *http.Request, userID string, logger *zerolog.Logger) {
    logger.Info().
        Str("user_id", userID).
        Msg("updating user")
    fmt.Fprintf(w, `{"id": "%s", "status": "updated"}`, userID)
}

func deleteUser(w http.ResponseWriter, r *http.Request, userID string, logger *zerolog.Logger) {
    logger.Warn().
        Str("user_id", userID).
        Msg("deleting user")
    fmt.Fprintf(w, `{"id": "%s", "status": "deleted"}`, userID)
}

func extractUserID(path string) string {
    // 简化实现
    for i := len(path) - 1; i >= 0; i-- {
        if path[i] == '/' {
            return path[i+1:]
        }
    }
    return ""
}

func parseLevel(level string) zerolog.Level {
    switch level {
    case "trace":
        return zerolog.TraceLevel
    case "debug":
        return zerolog.DebugLevel
    case "info":
        return zerolog.InfoLevel
    case "warn":
        return zerolog.WarnLevel
    case "error":
        return zerolog.ErrorLevel
    case "fatal":
        return zerolog.FatalLevel
    case "panic":
        return zerolog.PanicLevel
    case "disabled":
        return zerolog.Disabled
    default:
        return zerolog.InfoLevel
    }
}
```

## 总结

本文全面介绍了 Zerolog 在生产环境中的配置和使用方法，涵盖了从基础配置到高级特性的各个方面。以下是本文的核心要点：

**Request ID 追踪**是分布式系统可观测性的基础，通过 `hlog.RequestIDHandler` 可以轻松实现请求追踪，同时配合其他 `hlog` 中间件可以获取完整的请求上下文信息。

**错误堆栈跟踪**对于问题排查至关重要，通过配置 `ErrorStackMarshaler` 并在日志中使用 `.Stack()` 方法，可以获取完整的错误调用链，包括文件名、行号和函数名。

**高性能输出**通过合理的输出配置、日志轮转、非阻塞写入和采样策略，可以在保证性能的同时满足生产环境的日志管理需求。

**最佳实践**包括合理的日志级别使用、避免性能陷阱、敏感数据过滤以及与日志聚合系统的集成，这些实践有助于构建一个健康、可维护的日志系统。

**上下文管理**通过 Go 的 context 包和 Zerolog 的上下文集成，可以在请求处理过程中传递和共享日志器，确保所有日志都包含必要的上下文信息。

通过本文的学习和实践，你将能够构建一个完整的生产级日志系统，为你的应用提供全方位的可观测性支持。记住，良好的日志实践不是一蹴而就的，需要在实践中不断优化和完善。
