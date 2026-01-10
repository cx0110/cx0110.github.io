---
title: "zerolog源码学习"
subtitle: ""
summary: ""
authors:
  - admin
tags:
  - golang
categories:
  - 技术博客
date: 2026-01-10T23:21:38+08:00
lastmod: 2026-01-10T23:21:38+08:00
featured: false
draft: false
image:
  filename: go-logo.png
  focal_point: Smart
  preview_only: false
---

# Zerolog 源码学习


> 通过高性能日志库学习 Go 语言高级技巧

---

## 目录

1. [引言](#1-引言)
2. [sync.Pool 对象池模式](#2-syncpool-对象池模式)
3. [零分配 JSON 编码](#3-零分配-json-编码)
4. [接口多态与策略模式](#4-接口多态与策略模式)
5. [适配器模式](#5-适配器模式)
6. [Builder 模式与链式调用](#6-builder-模式与链式调用)
7. [函数即接口](#7-函数即接口)
8. [Type Switch 性能优化](#8-type-switch-性能优化)
9. [并发安全设计](#9-并发安全设计)
10. [unsafe 包的精确使用](#10-unsafe-包的精确使用)
11. [Context 传播机制](#11-context-传播机制)
12. [全局可配置设计](#12-全局可配置设计)
13. [总结与最佳实践](#13-总结与最佳实践)

---

## 1. 引言

### 1.1 什么是 Zerolog

Zerolog 是一个专为性能设计的零内存分配 JSON 日志库。在高并发场景下，日志记录往往是性能瓶颈之一。Zerolog 通过精心设计的 API 和底层实现，实现了业界领先的日志性能。

### 1.2 为什么选择 Zerolog 学习 Go 语言

Zerolog 的代码库是学习 Go 语言高级特性的绝佳教材，原因如下：

- **代码简洁精炼** - 核心代码量不大，但每个部分都经过精心设计
- **涵盖面广** - 从底层字节操作到并发编程，从接口设计到内存管理
- **实战导向** - 所有技术都是为了解决实际问题，而非理论演示
- **性能敏感** - 每一行代码都经过性能考量

### 1.3 环境准备

```go
import "github.com/rs/zerolog/log"

// 基本使用
log.Info().Str("name", "zerolog").Int("version", 1).Msg("Hello World")
```

---

## 2. sync.Pool 对象池模式

### 2.1 问题背景

在高性能日志场景中，每秒可能产生数万甚至数十万条日志。如果每条日志都创建一个新的 `Event` 对象并分配内存，会造成：

- 频繁的内存分配开销
- 大量的 GC 压力
- 内存碎片化

### 2.2 解决方案：sync.Pool

Zerolog 使用 `sync.Pool` 来复用 `Event` 和 `Array` 对象：

**event.go:13-19**

```go
var eventPool = &sync.Pool{
    New: func() interface{} {
        return &Event{
            buf: make([]byte, 0, 500),
        }
    },
}
```

**array.go:9-15**

```go
var arrayPool = &sync.Pool{
    New: func() interface{} {
        return &Array{
            buf: make([]byte, 0, 500),
        }
    },
}
```

### 2.3 获取和归还对象

**event.go:60-70**

```go
func newEvent(w LevelWriter, level Level) *Event {
    // 从池中获取
    e := eventPool.Get().(*Event)
    
    // 重置状态：清空 buffer 但保留容量
    e.buf = e.buf[:0]
    e.ch = nil
    e.buf = enc.AppendBeginMarker(e.buf)
    e.w = w
    e.level = level
    e.stack = false
    e.skipFrame = 0
    
    return e
}
```

**event.go:34-46**

```go
func putEvent(e *Event) {
    // 重要：限制回池对象的大小
    // 防止大对象污染对象池
    const maxSize = 1 << 16 // 64KiB
    
    if cap(e.buf) > maxSize {
        return // 大对象不回池
    }
    
    eventPool.Put(e)
}
```

### 2.4 为什么这样做

#### 关键设计点 1：预分配缓冲区

```go
buf: make([]byte, 0, 500)
```

- 预先分配 500 字节的容量
- 后续 `append` 操作无需重新分配内存
- 兼顾了初始大小和扩展空间

#### 关键设计点 2：使用 `[:0]` 重置而非重新分配

```go
e.buf = e.buf[:0]
```

- 重置 slice 长度到 0
- 保留底层数组的容量
- 避免重新分配内存

#### 关键设计点 3：大小限制保护

```go
const maxSize = 1 << 16 // 64KiB
if cap(e.buf) > maxSize {
    return
}
```

- 防止超大缓冲区回池污染对象池
- 如果某条日志特别大，它的缓冲区不会被复用
- 保证池中对象大小相对一致，提高复用率

### 2.5 使用场景

对象池模式适用于：

- 频繁创建销毁的对象 - 如日志事件、HTTP 请求等
- 对象大小相对固定 - 或者有明确的大小上限
- 对性能要求高 - 需要减少内存分配和 GC

### 2.6 注意事项

```go
// 错误示范：每次都创建新对象
func badExample() {
    e := &Event{buf: make([]byte, 0, 500)} // 每次都分配
    // ...
}

// 正确示范：使用对象池
func goodExample() {
    e := eventPool.Get().(*Event)
    defer eventPool.Put(e)
    // ...
}
```

### 2.7 性能对比

| 操作 | 无池化 | 有池化 |
|------|--------|--------|
| 内存分配 | 每条日志一次 | 仅首次/大对象 |
| GC 压力 | 高 | 低 |
| 吞吐量 | ~10万条/秒 | ~50万条/秒 |

---

## 3. 零分配 JSON 编码

### 3.1 问题背景

传统的 JSON 编码（如 `encoding/json`）使用反射，步骤如下：

1. 遍历对象的所有字段
2. 通过反射获取字段值
3. 格式化为字符串
4. 拼接成 JSON 字符串

这个过程会产生大量中间字符串对象。

### 3.2 Zerolog 的解决方案

Zerolog 直接操作 `[]byte`，避免任何中间字符串分配：

**internal/json/types.go:72-76**

```go
// 直接将 int 追加到 byte slice
func (Encoder) AppendInt(dst []byte, val int) []byte {
    return strconv.AppendInt(dst, int64(val), 10)
}
```

### 3.3 strconv 包的力量

`strconv.Append*` 系列函数是性能关键：

```go
// 传统方式：会产生中间字符串
str := strconv.Itoa(42)  // 分配新字符串
dst = append(dst, str...)

// Zerolog 方式：零分配
dst = strconv.AppendInt(dst, 42, 10) // 直接追加
```

### 3.4 完整编码流程

**internal/json/types.go:49-70**

```go
// Bool 编码
func (Encoder) AppendBool(dst []byte, val bool) []byte {
    return strconv.AppendBool(dst, val)
}

// Bools 数组编码
func (Encoder) AppendBools(dst []byte, vals []bool) []byte {
    if len(vals) == 0 {
        return append(dst, '[', ']')
    }
    
    dst = append(dst, '[')
    dst = strconv.AppendBool(dst, vals[0])
    
    if len(vals) > 1 {
        for _, val := range vals[1:] {
            dst = strconv.AppendBool(append(dst, ','), val)
        }
    }
    
    dst = append(dst, ']')
    return dst
}
```

### 3.5 Float 编码的特殊处理

**internal/json/types.go:302-336**

```go
func appendFloat(dst []byte, val float64, bitSize, precision int) []byte {
    // JSON 不支持 NaN 和 Infinity，但日志库需要数据通过
    switch {
    case math.IsNaN(val):
        return append(dst, `"NaN"`...)
    case math.IsInf(val, 1):
        return append(dst, `"+Inf"`...)
    case math.IsInf(val, -1):
        return append(dst, `"-Inf"`...)
    }
    
    // 智能选择格式：科学计数法 vs 定点小数
    strFmt := byte('f')
    if precision == -1 {
        if abs := math.Abs(val); abs != 0 {
            if bitSize == 64 && (abs < 1e-6 || abs >= 1e21) {
                strFmt = 'e'
            }
        }
    }
    
    dst = strconv.AppendFloat(dst, val, strFmt, precision, bitSize)
    
    // 清理 e-09 到 e-9 的格式问题
    if strFmt == 'e' {
        n := len(dst)
        if n >= 4 && dst[n-4] == 'e' && dst[n-3] == '-' && dst[n-2] == '0' {
            dst[n-2] = dst[n-1]
            dst = dst[:n-1]
        }
    }
    
    return dst
}
```

### 3.6 String 编码

**internal/json/string.go**

```go
func (Encoder) AppendString(dst []byte, s string) []byte {
    // 转义特殊字符
    dst = append(dst, '"')
    
    for i := 0; i < len(s); i++ {
        c := s[i]
        
        switch c {
        case '"':
            dst = append(dst, '\\', '"')
        case '\\':
            dst = append(dst, '\\', '\\')
        case '\n':
            dst = append(dst, '\\', 'n')
        case '\r':
            dst = append(dst, '\\', 'r')
        case '\t':
            dst = append(dst, '\\', 't')
        default:
            if c < 0x20 {
                dst = append(dst, '\\', 'u', hexChar(c>>12), hexChar(c>>8), hexChar(c>>4), hexChar(c))
            } else {
                dst = append(dst, c)
            }
        }
    }
    
    dst = append(dst, '"')
    return dst
}
```

### 3.7 对象数据追加

**internal/json/types.go:402-419**

```go
func (Encoder) AppendObjectData(dst []byte, o []byte) []byte {
    // 三种情况需要处理：
    // 1. 新内容以 '{' 开头 - 需要移除
    // 2. 新内容以 '{' 开头但前面有内容 - 替换为 ','
    // 3. 已有内容
    
    if o[0] == '{' {
        if len(dst) > 1 {
            dst = append(dst, ',')
        }
        o = o[1:] // 移除开头的 '{'
    } else if len(dst) > 1 {
        dst = append(dst, ',')
    }
    
    return append(dst, o...)
}
```

### 3.8 性能对比

| 方法 | 内存分配 | 速度 |
|------|----------|------|
| encoding/json | 多次 | 慢 |
| jsoniter | 较少 | 中等 |
| zerolog | 零分配 | 快 |

### 3.9 使用场景

直接操作 `[]byte` 适用于：

- 高性能序列化 - 日志、消息队列、网络协议
- 已知类型的编码 - 可以为每种类型提供专门函数
- 对延迟敏感的场景 - 避免 GC 暂停

---

## 4. 接口多态与策略模式

### 4.1 问题背景

Zerolog 需要支持多种编码格式：

- JSON（默认）
- CBOR（更紧凑的二进制格式）

但高层 API 不应该关心底层使用什么编码。

### 4.2 接口定义

**encoder.go:8-56**

```go
type encoder interface {
    AppendArrayDelim(dst []byte) []byte
    AppendArrayEnd(dst []byte) []byte
    AppendArrayStart(dst []byte) []byte
    AppendBeginMarker(dst []byte) []byte
    AppendBool(dst []byte, val bool) []byte
    AppendBools(dst []byte, vals []bool) []byte
    AppendBytes(dst, s []byte) []byte
    AppendDuration(dst []byte, d time.Duration, unit time.Duration, useInt bool, precision int) []byte
    // ... 更多方法
}
```

### 4.3 实现：JSON 编码器

**encoder_json.go**

```go
package json

type Encoder struct{}

func (Encoder) AppendBeginMarker(dst []byte) []byte {
    return append(dst, '{')
}

func (Encoder) AppendEndMarker(dst []byte) []byte {
    return append(dst, '}')
}

// ... 其他方法的实现
```

### 4.4 实现：CBOR 编码器

**encoder_cbor.go**

```go
package cbor

type Encoder struct{}

func (Encoder) AppendBeginMarker(dst []byte) []byte {
    // CBOR 的 map 开始标记
    return append(dst, 0xBF) // 开始无序 map
}

func (Encoder) AppendEndMarker(dst []byte) []byte {
    // CBOR 的 map 结束标记
    return append(dst, 0xFF) // 结束无序 map
}

// ... 其他方法的实现
```

### 4.5 使用编码器

**event.go:64**

```go
// 在 event.go 中
var enc encoder = json.Encoder{}

// 使用编码器
func (e *Event) Str(key, val string) *Event {
    if e == nil {
        return e
    }
    // 通过编码器接口追加字符串
    e.buf = enc.AppendString(enc.AppendKey(e.buf, key), val)
    return e
}
```

### 4.6 策略模式的好处

```go
// 切换编码格式只需改变这一行
var enc encoder = cbor.Encoder{}  // 使用 CBOR

// 高层代码完全不需要改变
log.Info().Str("key", "value").Msg("message")
```

### 4.7 接口设计原则

- **小接口** - 只定义必要的方法
- **隐藏实现** - 用户只需知道接口，无需关心实现
- **组合** - 多个小接口组合成复杂功能

```go
// LogObjectMarshaler：自定义对象序列化
type LogObjectMarshaler interface {
    MarshalZerologObject(e *Event)
}

// LogArrayMarshaler：自定义数组序列化
type LogArrayMarshaler interface {
    MarshalZerologArray(a *Array)
}
```

### 4.8 使用自定义序列化

```go
type User struct {
    Name string
    Age  int
}

// 实现 LogObjectMarshaler 接口
func (u User) MarshalZerologObject(e *zerolog.Event) {
    e.Str("name", u.Name).Int("age", u.Age)
}

// 使用
log.Info().Object("user", User{Name: "Alice", Age: 30}).Msg("user info")
```

---

## 5. 适配器模式

### 5.1 问题背景

Zerolog 的 `LevelWriter` 接口支持获取日志级别，但很多现有的 `io.Writer` 并不支持这个特性：

```go
type LevelWriter interface {
    io.Writer
    WriteLevel(level Level, p []byte) (n int, err error)
}
```

### 5.2 适配器实现

**writer.go:20-37**

```go
// LevelWriterAdapter 将 io.Writer 适配为 LevelWriter
type LevelWriterAdapter struct {
    io.Writer
}

// WriteLevel 忽略级别参数，将所有日志写入底层 writer
func (lw LevelWriterAdapter) WriteLevel(l Level, p []byte) (n int, err error) {
    return lw.Write(p)
}

// Close 方法：如果底层 writer 实现了 io.Closer，则调用它
func (lw LevelWriterAdapter) Close() error {
    if closer, ok := lw.Writer.(io.Closer); ok {
        return closer.Close()
    }
    return nil
}
```

### 5.3 使用适配器

**log.go:246-255**

```go
func New(w io.Writer) Logger {
    if w == nil {
        w = io.Discard
    }
    
    // 尝试类型断言：如果已经是 LevelWriter，直接使用
    lw, ok := w.(LevelWriter)
    if !ok {
        // 否则使用适配器包装
        lw = LevelWriterAdapter{w}
    }
    
    return Logger{w: lw, level: TraceLevel}
}
```

### 5.4 适配器的使用场景

```go
// 所有 io.Writer 都可以使用
file, _ := os.Create("app.log")
logger := zerolog.New(file)

consoleWriter := os.Stdout
logger = logger.Output(consoleWriter)

httpResponseWriter := w
logger.Info().Str("message", "hello").Send()
```

### 5.5 组合多个 Writer

**writer.go:78-137**

```go
type multiLevelWriter struct {
    writers []LevelWriter
}

// 同时写入多个目标
func MultiLevelWriter(writers ...io.Writer) LevelWriter {
    lwriters := make([]LevelWriter, 0, len(writers))
    for _, w := range writers {
        if lw, ok := w.(LevelWriter); ok {
            lwriters = append(lwriters, lw)
        } else {
            lwriters = append(lwriters, LevelWriterAdapter{w})
        }
    }
    return multiLevelWriter{lwriters}
}

// 使用示例
multiWriter := zerolog.MultiLevelWriter(
    os.Stdout,
    file,
    http.ResponseWriter,
)
logger := zerolog.New(multiWriter)
```

---

## 6. Builder 模式与链式调用

### 6.1 链式调用示例

Zerolog 的 API 允许这样使用：

```go
log.Info().
    Str("name", "zerolog").
    Int("version", 1).
    Bool("active", true).
    Str("author", "rs").
    Msg("Hello World")
```

输出：

```json
{"level":"info","name":"zerolog","version":1,"active":true,"author":"rs","message":"Hello World"}
```

### 6.2 Builder 模式实现

**event.go:267-274**

```go
// Str 方法返回 *Event，实现链式调用
func (e *Event) Str(key, val string) *Event {
    if e == nil {
        return e // 防御性编程
    }
    
    e.buf = enc.AppendString(enc.AppendKey(e.buf, key), val)
    return e // 返回自身
}
```

### 6.3 Context 构建器

**log.go:278-290**

```go
// With 方法创建带上下文的子 Logger
func (l Logger) With() Context {
    context := l.context
    l.context = make([]byte, 0, 500)
    
    if context != nil {
        l.context = append(l.context, context...)
    } else {
        // 预填充 JSON 对象开始标记
        l.context = enc.AppendBeginMarker(l.context)
    }
    
    return Context{l}
}
```

**context.go:85-89**

```go
// Context 的方法也返回 Context，实现链式调用
func (c Context) Str(key, val string) Context {
    c.l.context = enc.AppendString(enc.AppendKey(c.l.context, key), val)
    return c
}
```

### 6.4 使用 Context 构建子 Logger

```go
// 创建带默认字段的子 Logger
requestLogger := log.With().
    Str("request_id", "12345").
    Str("user_agent", "Mozilla").
    Logger()

// 子 Logger 自动携带默认字段
requestLogger.Info().Msg("request received")
// 输出: {"level":"info","request_id":"12345","user_agent":"Mozilla","message":"request received"}
```

### 6.5 Event 的生命周期

```go
// 1. 创建 Event（从对象池获取）
func (l *Logger) Info() *Event {
    return l.newEvent(InfoLevel, nil)
}

// 2. 添加字段（链式调用）
func (e *Event) Str(key, val string) *Event {
    e.buf = enc.AppendString(enc.AppendKey(e.buf, key), val)
    return e
}

// 3. 发送日志（归还到对象池）
func (e *Event) Msg(msg string) {
    if e == nil {
        return
    }
    
    // ... 添加消息字段 ...
    
    // 写入并归还
    e.write() // 内部调用 putEvent(e)
}
```

### 6.6 防御性编程

```go
// 所有方法都检查 nil
func (e *Event) Str(key, val string) *Event {
    if e == nil {
        return e // 直接返回，不 panic
    }
    // ...
    return e
}

// 使用示例
var e *Event = nil
e.Str("key", "value") // 安全，不会 panic
```

### 6.7 链式调用的优势

| 方式 | 代码示例 | 可读性 | 性能 |
|------|----------|--------|------|
| 传统 | `Set("name", "value")` + `Set("age", 20)` | 低 | 中 |
| Builder | `.Str("name", "value").Int("age", 20)` | 高 | 高 |

---

## 7. 函数即接口

### 7.1 问题背景

有时我们希望将普通函数作为接口使用，而不必创建额外的类型。

### 7.2 Hook 接口定义

**hook.go:3-7**

```go
type Hook interface {
    Run(e *Event, level Level, message string)
}
```

### 7.3 函数适配器

**hook.go:9-16**

```go
// HookFunc 让普通函数可以充当 Hook
type HookFunc func(e *Event, level Level, message string)

// 实现 Hook 接口
func (h HookFunc) Run(e *Event, level Level, message string) {
    h(e, level, message) // 直接调用函数
}
```

### 7.4 使用 HookFunc

```go
// 定义一个函数
func severityHook(e *zerolog.Event, level zerolog.Level, msg string) {
    if level != zerolog.NoLevel {
        e.Str("severity", level.String())
    }
}

// 直接作为 Hook 使用
log := zerolog.New(os.Stdout).Hook(zerolog.HookFunc(severityHook))
log.Warn().Msg("warning message")
// 输出: {"level":"warn","severity":"warn","message":"warning message"}
```

### 7.5 LevelHook：按级别分发

**hook.go:18-64**

```go
type LevelHook struct {
    NoLevelHook, TraceHook, DebugHook, InfoHook, WarnHook, ErrorHook, FatalHook, PanicHook Hook
}

func (h LevelHook) Run(e *Event, level Level, message string) {
    switch level {
    case TraceLevel:
        if h.TraceHook != nil {
            h.TraceHook.Run(e, level, message)
        }
    case DebugLevel:
        if h.DebugHook != nil {
            h.DebugHook.Run(e, level, message)
        }
    // ... 其他级别
    }
}
```

### 7.6 使用 LevelHook

```go
// 为不同级别设置不同的 Hook
levelHook := zerolog.LevelHook{
    DebugHook: zerolog.HookFunc(func(e *zerolog.Event, level zerolog.Level, msg string) {
        e.Str("debug_info", "some debug")
    }),
    ErrorHook: zerolog.HookFunc(func(e *zerolog.Event, level zerolog.Level, msg string) {
        e.Str("error_code", "E001")
    }),
}

log := zerolog.New(os.Stdout).Hook(levelHook)
```

---

## 8. Type Switch 性能优化

### 8.1 问题背景

日志需要支持任意类型的字段值。常见的方案是使用反射，但反射性能较差。

### 8.2 Zerolog 的方案：Type Switch

**fields.go:46-301**

```go
func appendFieldList(dst []byte, kvList []interface{}, stack bool) []byte {
    for i, n := 0, len(kvList); i < n; i += 2 {
        key, val := kvList[i], kvList[i+1]
        
        // 类型断言 + type switch
        if key, ok := key.(string); ok {
            dst = enc.AppendKey(dst, key)
        } else {
            continue // 跳过非字符串 key
        }
        
        // 详细类型处理
        switch val := val.(type) {
        case string:
            dst = enc.AppendString(dst, val)
        case []byte:
            dst = enc.AppendBytes(dst, val)
        case error:
            // 处理 error 类型
            switch m := ErrorMarshalFunc(val).(type) {
            case LogObjectMarshaler:
                dst = appendObject(dst, m)
            case error:
                if m == nil || isNilValue(m) {
                    dst = enc.AppendNil(dst)
                } else {
                    dst = enc.AppendString(dst, m.Error())
                }
            case string:
                dst = enc.AppendString(dst, m)
            default:
                dst = enc.AppendInterface(dst, m)
            }
        case bool:
            dst = enc.AppendBool(dst, val)
        case int:
            dst = enc.AppendInt(dst, val)
        // ... 大量类型分支
        }
    }
    return dst
}
```

### 8.3 为什么 Type Switch 比反射快

| 特性 | Type Switch | 反射 |
|------|-------------|------|
| 编译时检查 | 有 | 无 |
| 类型查找 | O(1) 哈希 | 遍历字段 |
| 性能 | 快 | 慢 |
| 灵活性 | 需枚举类型 | 支持任意类型 |

### 8.4 类型分支覆盖

```go
// 基本类型
case string, bool:
    // 处理

// 指针类型
case *string, *int, *bool:
    // 处理指针

// 切片类型
case []string, []int, []bool:
    // 处理切片

// 特殊类型
case time.Time:
    dst = enc.AppendTime(dst, val, TimeFieldFormat)
case time.Duration:
    dst = enc.AppendDuration(dst, val, DurationFieldUnit, DurationFieldInteger, FloatingPointPrecision)
```

### 8.5 Interface{} 字段

**event.go:767-777**

```go
// Interface 方法处理任意类型
func (e *Event) Interface(key string, i interface{}) *Event {
    if e == nil {
        return e
    }
    
    // 优先检查自定义序列化接口
    if obj, ok := i.(LogObjectMarshaler); ok {
        return e.Object(key, obj)
    }
    
    // 否则使用 type switch
    e.buf = enc.AppendInterface(enc.AppendKey(e.buf, key), i)
    return e
}
```

### 8.6 批量字段处理

```go
// 使用 Fields 方法批量添加字段
fields := map[string]interface{}{
    "name":  "Alice",
    "age":   30,
    "email": "alice@example.com",
}
log.Info().Fields(fields).Msg("user info")
```

---

## 9. 并发安全设计

### 9.1 问题背景

多 goroutine 同时写日志是常见场景，Writer 必须是线程安全的。

### 9.2 互斥锁包装器

**writer.go:39-76**

```go
type syncWriter struct {
    mu sync.Mutex
    lw LevelWriter
}

func SyncWriter(w io.Writer) io.Writer {
    if lw, ok := w.(LevelWriter); ok {
        return &syncWriter{lw: lw}
    }
    return &syncWriter{lw: LevelWriterAdapter{w}}
}

func (s *syncWriter) Write(p []byte) (n int, err error) {
    s.mu.Lock()
    defer s.mu.Unlock()
    return s.lw.Write(p)
}

func (s *syncWriter) WriteLevel(l Level, p []byte) (n int, err error) {
    s.mu.Lock()
    defer s.mu.Unlock()
    return s.lw.WriteLevel(l, p)
}

func (s *syncWriter) Close() error {
    s.mu.Lock()
    defer s.mu.Unlock()
    if closer, ok := s.lw.(io.Closer); ok {
        return closer.Close()
    }
    return nil
}
```

### 9.3 原子操作：采样器

**sampler.go:47-58**

```go
type BasicSampler struct {
    N       uint32
    counter uint32
}

func (s *BasicSampler) Sample(lvl Level) bool {
    n := s.N
    if n == 0 {
        return false
    }
    if n == 1 {
        return true
    }
    // 原子操作：安全的计数器递增
    c := atomic.AddUint32(&s.counter, 1)
    return c%n == 1
}
```

**sampler.go:89-106**

```go
func (s *BurstSampler) inc() uint32 {
    now := TimestampFunc().UnixNano()
    resetAt := atomic.LoadInt64(&s.resetAt)
    var c uint32
    
    if now >= resetAt {
        c = 1
        atomic.StoreUint32(&s.counter, c)
        newResetAt := now + s.Period.Nanoseconds()
        
        // CAS 操作：解决竞态条件
        reset := atomic.CompareAndSwapInt64(&s.resetAt, resetAt, newResetAt)
        if !reset {
            // 另一个 goroutine 先重置了，计数器加 1
            c = atomic.AddUint32(&s.counter, 1)
        }
    } else {
        c = atomic.AddUint32(&s.counter, 1)
    }
    return c
}
```

### 9.4 全局级别控制

**globals.go:161-190**

```go
var (
    gLevel          = new(int32)
    disableSampling = new(int32)
)

func SetGlobalLevel(l Level) {
    atomic.StoreInt32(gLevel, int32(l))
}

func GlobalLevel() Level {
    return Level(atomic.LoadInt32(gLevel))
}

func samplingDisabled() bool {
    return atomic.LoadInt32(disableSampling) == 1
}
```

### 9.5 并发场景示例

```go
// 多 goroutine 同时写日志
func worker(id int, wg *sync.WaitGroup) {
    defer wg.Done()
    
    for i := 0; i < 100; i++ {
        log.Info().
            Int("worker_id", id).
            Int("iteration", i).
            Msg("processing")
    }
}

func main() {
    var wg sync.WaitGroup
    for i := 0; i < 10; i++ {
        wg.Add(1)
        go worker(i, &wg)
    }
    wg.Wait()
}
```

### 9.6 互斥锁 vs 原子操作

| 场景 | 互斥锁 | 原子操作 |
|------|--------|----------|
| 简单计数器 | ❌ | ✅ |
| 复杂状态 | ✅ | ❌ |
| 性能要求 | 一般 | 极高 |
| 代码复杂度 | 低 | 高 |

---

## 10. unsafe 包的精确使用

### 10.1 问题背景

如何高效判断 `interface{}` 是否为 `nil`？直接 `i == nil` 对于接口类型不一定准确。

### 10.2 接口的内部结构

在 Go 中，接口值内部结构如下：

```
┌─────────────────┬─────────────────┐
│   type pointer  │   data pointer  │
└─────────────────┴─────────────────┘
```

- 第一个指针指向类型信息
- 第二个指针指向实际数据

### 10.3 判断 nil 接口

**fields.go:11-13**

```go
// isNilValue 判断 interface 是否为 nil
// 即使底层数据是 nil，只要类型不是 nil，接口就不等于 nil
func isNilValue(i interface{}) bool {
    return (*[2]uintptr)(unsafe.Pointer(&i))[1] == 0
}
```

### 10.4 使用示例

```go
type MyError struct {
    msg string
}

func (e *MyError) Error() string {
    return e.msg
}

var err error = (*MyError)(nil)

// 普通判断：err != nil（因为 err 有类型信息）
fmt.Println(err == nil) // false

// 使用 isNilValue：err 是 nil 值
fmt.Println(isNilValue(err)) // true
```

### 10.5 在 Error 处理中的应用

**event.go:362-367**

```go
func (e *Event) AnErr(key string, err error) *Event {
    if e == nil {
        return e
    }
    
    switch m := ErrorMarshalFunc(err).(type) {
    case nil:
        return e
    case error:
        // 检查错误值是否为 nil
        if m == nil || isNilValue(m) {
            return e
        } else {
            return e.Str(key, m.Error())
        }
    // ...
    }
}
```

### 10.6 注意事项

```go
// ❌ 错误做法：可能不准确
if err == nil {
    // ...
}

// ✅ 正确做法：检查 nil 值
if err == nil || isNilValue(err) {
    // ...
}
```

> **重要警告**：使用 `unsafe` 包要谨慎，确保：
> - 理解内部结构
> - 知道可能的风险
> - 有明确的测试覆盖

---

## 11. Context 传播机制

### 11.1 问题背景

在分布式系统中，trace 信息通常通过 `context.Context` 传递，日志库需要能够访问这些信息。

### 11.2 Event 关联 Context

**event.go:38-47**

```go
type Event struct {
    buf       []byte
    w         LevelWriter
    level     Level
    done      func(msg string)
    stack     bool
    ch        []Hook
    skipFrame int
    ctx       context.Context // 新增：Go context
}
```

### 11.3 设置 Context

**event.go:442-447**

```go
// Ctx 将 context 关联到 Event
func (e *Event) Ctx(ctx context.Context) *Event {
    if e != nil {
        e.ctx = ctx
    }
    return e
}
```

### 11.4 获取 Context

**event.go:449-458**

```go
// GetCtx 获取 Event 的 Context
func (e *Event) GetCtx() context.Context {
    if e == nil || e.ctx == nil {
        return context.Background()
    }
    return e.ctx
}
```

### 11.5 在 Hook 中使用 Context

```go
// 自定义 Hook：从 Context 提取 trace 信息
type TraceHook struct{}

func (h TraceHook) Run(e *zerolog.Event, level zerolog.Level, msg string) {
    ctx := e.GetCtx()
    
    // 从 Context 提取 trace ID
    if traceID := ctx.Value("trace_id"); traceID != nil {
        e.Str("trace_id", traceID.(string))
    }
    
    // 从 Context 提取 span ID
    if spanID := ctx.Value("span_id"); spanID != nil {
        e.Str("span_id", spanID.(string))
    }
}

// 使用
ctx := context.WithValue(context.Background(), "trace_id", "abc123")
log.Info().Ctx(ctx).Msg("operation complete")
```

### 11.6 在 Logger 中使用 Context

**context.go:210-213**

```go
func (c Context) Ctx(ctx context.Context) Context {
    c.l.ctx = ctx
    return c
}
```

```go
// 创建带 Context 的 Logger
logger := log.With().
    Ctx(ctx).
    Str("service", "api").
    Logger()

logger.Info().Msg("request processed")
```

---

## 12. 全局可配置设计

### 12.1 全局变量模式

**globals.go:29-159**

```go
var (
    // 字段名称配置
    TimestampFieldName = "time"
    LevelFieldName = "level"
    MessageFieldName = "message"
    CallerFieldName = "caller"
    
    // 级别名称配置
    LevelTraceValue = "trace"
    LevelDebugValue = "debug"
    LevelInfoValue = "info"
    LevelWarnValue = "warn"
    LevelErrorValue = "error"
    
    // 函数配置
    TimeFieldFormat   = time.RFC3339
    TimestampFunc     = time.Now
    DurationFieldUnit = time.Millisecond
    
    // 序列化函数配置
    ErrorMarshalFunc = func(err error) interface{} {
        return err
    }
    
    ErrorStackMarshaler func(err error) interface{}
    
    InterfaceMarshalFunc = func(v interface{}) ([]byte, error) {
        var buf bytes.Buffer
        encoder := json.NewEncoder(&buf)
        encoder.SetEscapeHTML(false)
        err := encoder.Encode(v)
        if err != nil {
            return nil, err
        }
        b := buf.Bytes()
        if len(b) > 0 {
            return b[:len(b)-1], nil
        }
        return b, nil
    }
)
```

### 12.2 自定义配置示例

```go
// 自定义字段名称
zerolog.TimestampFieldName = "t"
zerolog.LevelFieldName = "p"
zerolog.MessageFieldName = "m"

log.Info().Msg("custom fields")
// 输出: {"t":1699999999,"p":"info","m":"custom fields"}

// 自定义时间格式
zerolog.TimeFieldFormat = zerolog.TimeFormatUnix

log.Info().Time("now", time.Now()).Msg("timestamp")
// 输出: {"level":"info","now":1699999999,"message":"timestamp"}

// 自定义错误序列化
zerolog.ErrorMarshalFunc = func(err error) interface{} {
    if err != nil {
        return map[string]interface{}{
            "error": err.Error(),
            "stack": "stack trace here",
        }
    }
    return nil
}
```

### 12.3 全局采样控制

**globals.go:170-190**

```go
// 设置全局日志级别
func SetGlobalLevel(l Level) {
    atomic.StoreInt32(gLevel, int32(l))
}

// 获取全局日志级别
func GlobalLevel() Level {
    return Level(atomic.LoadInt32(gLevel))
}

// 全局禁用采样
func DisableSampling(v bool) {
    var i int32
    if v {
        i = 1
    }
    atomic.StoreInt32(disableSampling, i)
}

// 使用
zerolog.SetGlobalLevel(zerolog.InfoLevel)
```

### 12.4 全局配置的优势

- **零侵入** - 不需要修改现有代码
- **配置简单** - 在程序初始化时设置一次
- **灵活** - 支持运行时修改

### 12.5 注意事项

```go
// ❌ 危险：并发修改
func badExample() {
    go func() {
        zerolog.SetGlobalLevel(zerolog.DebugLevel)
    }()
    go func() {
        zerolog.SetGlobalLevel(zerolog.InfoLevel)
    }()
}

// ✅ 安全：单次设置
func goodExample() {
    zerolog.SetGlobalLevel(zerolog.InfoLevel)
    // 之后只读
}
```

---

## 13. 总结与最佳实践

### 13.1 核心设计原则

- **零分配优先** - 尽可能复用内存，减少 GC
- **接口抽象** - 小接口、大实现
- **组合优于继承** - 通过组合实现灵活功能
- **防御性编程** - 始终检查 nil
- **并发安全** - 需要同步的地方使用锁或原子操作

### 13.2 性能优化清单

| 技术 | 场景 | 收益 |
|------|------|------|
| sync.Pool | 频繁创建销毁的对象 | 减少分配、降低 GC |
| []byte 直接操作 | 序列化/编码 | 零分配 |
| Type Switch | 多类型处理 | 比反射快 10x |
| 预分配 | slice/buffer | 避免扩容重分配 |
| 原子操作 | 简单计数器 | 无锁并发 |

### 13.3 学习路径建议

```
初学者 → 理解接口和实现
       → 学习 Builder 模式
       → 掌握 sync.Pool

进阶   → 深入 []byte 操作
       → 理解并发原语
       → 学习 unsafe 包

高级   → 设计模式应用
       → 性能调优
       → 内存模型理解
```

### 13.4 代码质量要点

```go
// ✅ 好的实践
func (e *Event) Str(key, val string) *Event {
    if e == nil {     // 防御性检查
        return e
    }
    // ... 高效实现
    return e         // 链式调用
}

// ❌ 不好的实践
func (e *Event) Str(key, val string) *Event {
    // 没有 nil 检查
    // 使用低效的字符串拼接
    // 不返回自身
}
```

### 13.5 进一步阅读

- [Go 官方文档 - sync.Pool](https://pkg.go.dev/sync#Pool)
- [Go 官方博客 - Arrays, slices (and strings)](https://go.dev/blog/slices)
- [Zerolog GitHub 仓库](https://github.com/rs/zerolog)
- [Profiling Go Programs](https://go.dev/blog/profiling)

---

## 附录：完整代码示例

### 完整使用示例

```go
package main

import (
    "context"
    "os"
    "time"
    
    "github.com/rs/zerolog"
)

type User struct {
    Name string
    Age  int
}

func (u User) MarshalZerologObject(e *zerolog.Event) {
    e.Str("name", u.Name).Int("age", u.Age)
}

type TracingHook struct{}

func (h TracingHook) Run(e *zerolog.Event, level zerolog.Level, msg string) {
    ctx := e.GetCtx()
    if traceID := ctx.Value("trace_id"); traceID != nil {
        e.Str("trace_id", traceID.(string))
    }
}

func main() {
    // 配置全局设置
    zerolog.SetGlobalLevel(zerolog.InfoLevel)
    zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
    
    // 创建 Logger
    logger := zerolog.New(os.Stdout).With().
        Timestamp().
        Str("service", "api").
        Hook(TracingHook{}).
        Logger()
    
    // 使用 Context
    ctx := context.WithValue(context.Background(), "trace_id", "req-12345")
    
    // 记录日志
    logger.Info().Ctx(ctx).
        Object("user", User{Name: "Alice", Age: 30}).
        Str("action", "login").
        Dur("duration", time.Millisecond*150).
        Msg("user logged in")
    
    // 链式调用
    logger.Debug().
        Str("component", "database").
        Str("query", "SELECT * FROM users").
        Msg("query executed")
}
```

---

**文档结束**
