---
title: "Tangentry 拆解 — 把 B站/YouTube/小红书/播客塞进一个本地优先阅读器"
date: 2026-11-16T09:00:00+08:00
lastmod: 2026-11-16T09:00:00+08:00
draft: false
weight: 10
authors:
  - admin
summary: "基于 Go 1.27 + React 19 + MyGo 桌面壳的多平台内容聚合器。核心不是「聚合」而是「视频和播客也能读」:字幕跟随、全文搜索、时间戳笔记、导出 Obsidian frontmatter。本文拆它的平台适配器统一接口和转录服务双层设计。"
categories: ["Go 库", "开源项目", "工具"]
tags: ["Go", "MyGo", "内容聚合", "RSS", "视频字幕", "播客转录", "本地优先", "SQLite", "AI摘要", "whisper.cpp", "Qwen3-ASR", "yt-dlp", "React-19", "开源项目"]
external_link: ""
---

> **一句话结论**：把「B站课程 + YouTube 技术分享 + 小红书图文 + 抖音短视频 + 小宇宙播客 + RSS 长文」全部收进**一个本地优先的阅读器**，并且**视频和播客也能"读"** —— 字幕跟随、全文搜索、时间戳笔记、导出 Obsidian。

**Tangentry** 是一个用 **Go + React** 做的本地优先的多平台内容聚合、阅读与笔记工具，**基于 MyGo 构建**。

## 一、它想解决什么

作者列了一组很真实的痛点：

| 痛点 | 说明 |
|---|---|
| **内容分散** | 想回顾某个知识点，要在多个平台之间切换 |
| **无法专注** | 平台充满了推荐、评论、广告 |
| **笔记困难** | 视频和播客很难做笔记，**无法引用具体时间** |
| **数据不属于自己的** | 平台关闭或限制，内容就没了 |

> 要是一个工具能把所有平台的内容聚合到一个阅读器里就好了。

## 二、名字的含义

> **Tangentry = Tangent + Entry**
> Tangent：思维的发散、知识的延伸
> Entry：进入知识世界的入口
> 寓意着：**每一份内容都是探索的起点，每一次好奇都可能通向新的知识。**

## 三、六组核心能力

### 1. 多平台聚合

**B站**（UP 主、视频、收藏夹）· **YouTube**（频道、视频）· **小红书**（图文、视频）· **抖音**（短视频）· **小宇宙**（播客）· **RSS / Atom / JSON Feed** · **网页文章** · **本地 PDF**

### 2. 阅读优先 —— 视频和播客也可以"读"

- 字幕跟随 + 字幕搜索 + 上下文跳转 + 播放进度记忆
- 播客自动生成文字稿、时间戳标记、可跳转、可搜索
- 图文：网页正文提取（Readability）+ 原文划线 + AI 摘要
- PDF 阅读（带锚点）

### 3. 笔记即资产

**时间戳笔记**（视频、播客）· 原文划线笔记 · PDF 锚点 · 截帧附图 · 嵌套标签 · 置顶 · 全文搜索 · **导出 Markdown ZIP（含 Obsidian frontmatter）**

导出效果长这样：

```markdown
---
title: Go 并发编程详解
source: https://bilibili.com/video/BV123
created: 2026-10-28
tags: [go, 并发, 编程]
---

## [00:15:23] Goroutine 基础
...
```

### 4. 本地优先

**SQLite 存储在本机** · 不需要注册账号 · **数据完全属于你**

### 5. AI 增强

视频/文章摘要 · 字幕与正文翻译 · 双语导出 · **支持任意 OpenAI 兼容接口**：

```yaml
ai:
  provider: openai
  base_url: https://api.openai.com/v1
  api_key: sk-xxx
  model: gpt-4o-mini
# 或本地模型
# base_url: http://localhost:11434/v1
# model: llama3.1
```

### 6. 跨平台

macOS（Apple Silicon）· Windows（x64 / ARM64）· Linux（x64 / ARM64）· Docker 自托管

## 四、对比矩阵（原文表格）

| 特性 | Tangentry | Inoreader | Feedly | Readwise |
|---|---|---|---|---|
| 多平台聚合 | ✅ | ❌ | ❌ | ❌ |
| 视频字幕阅读 | ✅ | ❌ | ❌ | ❌ |
| 播客转录 | ✅ | ❌ | ❌ | ✅ |
| 本地存储 | ✅ | ❌ | ❌ | ❌ |
| AI 摘要 | ✅ | ✅ | ✅ | ✅ |
| 笔记锚定时间 | ✅ | ❌ | ❌ | ✅ |
| 自托管 | ✅ | ❌ | ❌ | ❌ |
| 价格 | **免费** | 付费 | 付费 | 付费 |

> **定位：免费、本地、全平台的内容聚合与阅读工具。**

## 五、技术实现

### 架构

```
Tangentry
 ├─ 前端（React 19）
 │   ├─ 发现页 / 订阅管理 / 阅读器 / 笔记库 / 设置
 ├─ 后端（Go 1.27）
 │   ├─ API 服务
 │   ├─ 平台适配器（B站 / YouTube / 小红书 / 抖音 / 小宇宙 / RSS）
 │   ├─ 转录服务 / AI 服务 / 下载服务
 │   └─ 数据库（SQLite）
 └─ 桌面壳（MyGo）— macOS / Windows / Linux
```

### 平台适配器接口

```go
type PlatformAdapter interface {
    GetRecommendations(ctx context.Context) ([]Content, error)
    GetSubscriptions(ctx context.Context, subscriptions []Subscription) ([]Content, error)
    ParseURL(ctx context.Context, url string) (*Content, error)
    GetSubtitles(ctx context.Context, videoID string) ([]Subtitle, error)
    Download(ctx context.Context, videoID string, quality string) (string, error)
}
```

**这个接口设计值得看**：把「推荐 / 订阅 / 链接解析 / 字幕 / 下载」抽象成统一契约，**加一个新平台 = 实现一个 adapter**，前端完全不用动。

B站适配器的实现要点（原文示例）：调用 `https://api.bilibili.com/x/web-interface/index/top/rcmd` 拿推荐，解析 `data.items[].bvid / title / duration`，再转换成统一的 `Content{Platform, ID, Title, Duration}` 结构。

### 转录服务

| 层级 | 引擎 |
|---|---|
| **本机转录** | whisper.cpp · faster-whisper · **Qwen3-ASR** |
| **云端转录** | Groq · SiliconFlow · Cloudflare Workers AI |

功能：平台字幕优先 · 转录结果缓存 · 多语言支持

### 下载管理

基于 **yt-dlp + FFmpeg**：音视频下载 · 队列管理 · 超时控制 · 自动选择画质

## 六、我的判断

**最值得抄的两点**：

1. **「视频/播客也能读」这个定位** —— 不是把视频塞进阅读器，而是**把字幕变成一等公民**：跟随、搜索、跳转、笔记锚定到时间戳。这解决了 RSS 阅读器最普遍的短板（视频内容无法沉淀成可检索资产）。
2. **导出 Markdown ZIP（含 Obsidian frontmatter）** —— 本地优先工具的**出口必须能被别的工具消费**。这跟 Obsidian-Tools 专题里的插件思路一致：**数据是自己的，但要用顺手的方式带走**。

**要留意的**：平台适配器依赖各平台未公开的 API/接口 —— B站、抖音、小红书这类平台**接口一变就得改**，这类项目的维护成本天然高于纯 RSS 聚合器。

**技术选型上的一个信号**：它用 MyGo（纯 Go 桌面壳）而不是 Electron —— 这跟 Go 专题里 10-28 那篇 MyGo 深度拆解、以及 11-04 tryboxi 是同一个技术路线。

---

## 🔗 跨主题关联

- **对位 10-28 MyGo 纯 Go 写桌面应用**：Tangentry 的桌面壳正是 MyGo —— **同一作者、同一技术底座的连续作品**（11-04 tryboxi 也是 MyGo 路线）
- **对位 11-04 tryboxi 沙箱**：那篇是 AI Agent 需要的沙箱，本篇是内容聚合器 —— **同属「Go 写基础设施工具」这条线**
- **对位 Tools 专题的 YouTube Digest（8-29 zarazhang）**：**功能高度重叠但路线相反** —— YouTube Digest 是浏览器扩展 + 云端转录，Tangentry 是本地优先 + 多平台 + 完整笔记系统。**前者轻量即用，后者是完整的工作台**
- **对位 Tools 专题的 ai-goofish-monitor（11-03）**：一个抓闲鱼、一个抓内容平台 —— **同类「反爬 + 数据本地化」需求，但 Tangentry 把阅读和笔记也做进去了**
- **对位 10-21 bilibili-auto-transcript（B站转录）**：那篇是 Hermes 的 skill，Tangentry 是完整的桌面产品 —— **同一个能力从「插件」升级成「产品」的路径**
- **⭐ 对位本批次 Scrapling**：Scrapling 解决「怎么抓」，Tangentry 解决「抓完怎么读怎么沉淀」—— **两者叠加就是一个完整的个人知识管道**
