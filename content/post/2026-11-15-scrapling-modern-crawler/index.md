---
title: "Scrapling 拆解 — 100K 星的爬虫框架,本体就是一个 MCP Server"
date: 2026-11-15T09:00:00+08:00
lastmod: 2026-11-15T09:00:00+08:00
draft: false
weight: 9
authors:
  - admin
summary: "自适应选择器 + 反检测 + MCP server + 官方 Agent Skill 四件套,让 agent 直接挂载调用而不是自己拼 Playwright。本文对比它与 Scrapy / Firecrawl 的路线差异,并提出一个值得反思的问题:封装工具该用 skill 还是 MCP server?"
categories: ["🤖 AI Agent", "开源项目", "工具"]
tags: ["Scrapling", "爬虫", "数据抓取", "MCP", "MCP-Server", "Agent-Skill", "Playwright", "stealth", "xpath", "Python", "BSD-3-Clause", "开源项目"]
external_link: ""
---

> **一句话结论**：爬虫框架里少见地同时做了三件事 —— **自动适应页面变化** + **反检测** + **MCP server（agent 可直接调用）**。

**仓库**：<https://github.com/D4Vinci/Scrapling> · **文档**：<https://scrapling.readthedocs.io/en/latest/>
**实测数据**（2026-11-15 GitHub API）：**103062 Star / 10737 Fork** · Python · BSD-3-Clause
**建仓**：2024-10-13 · **最近推送**：2026-11-14

README 副标题：**Effortless Web Scraping for the Modern Web**

## 一、定位

官方描述：

> The BEST Web Scraping framework that handles everything from **a single request to a full-scale crawl**.

**关键在 "from a single request to a full-scale crawl"** —— 同一个栈里既做「一次 fetch 抓一个字段」，也做「全站百万级爬取」，而不是像很多框架那样割裂成两套 API。

## 二、三个对 agent 时代特别重要的点

### 1. 自适应选择器（Adaptive Selectors）

页面结构变了，选择器还能用 —— 这是爬虫框架跟「AI 时代网页」之间最关键的一道坎。README 反复强调的核心卖点就是抓取器能自我适应，而不是写死 XPath/CSS 后等着对方改版。

### 2. 反检测 / Stealth

topics 里明确带 `stealth`，README 有专门的 Stealth 相关章节 —— 浏览器指纹伪装、请求特征模拟这类能力是标配而不是插件。

### 3. ⭐ MCP server + Agent Skill（真正的分水岭）

- README 顶部有 **Agent Skill** 徽章，指向 `scrapling.readthedocs.io/en/latest/ai/agent-skill.html`
- topics 明确含 **`mcp-server`** 和 **`mcp`**
- MCP server 名：`io.github.D4Vinci/Scrapling`

**这是本项目和 11-15 同批其他项目的最大区别** —— Scrapling 不是「给 agent 用的工具」，而是**「本身就是一个 MCP server，agent 可以直接挂载调用」**。

> 官方还提供 **Agent Skill**（skill 形态的封装）—— 这正是我之前归档的 PixelFX 那条观察的延续：**「skill 作为项目分发单位」正在成为新常态**。

## 三、生态位

| 维度 | 说明 |
|---|---|
| 语言 / 许可 | Python · BSD-3-Clause（**最宽松的宽松许可之一**，商用无忧）|
| 引擎 | Playwright + HTTP 双路径 |
| 选择器 | XPath + CSS + 自适应 |
| 部署 | PyPI + **Docker**（`pyd4vinci/scrapling`）|
| MCP | `io.github.D4Vinci/Scrapling` |
| Agent Skill | 官方 skill 包 |
| 文档 | **9 种语言版本**（英/中/日/韩/西/葡/法/德/阿）—— 这在开源项目里是少见的本地化投入 |

## 四、我的判断

**值不值得用**：如果你在做「让 agent 抓网页」这件事，Scrapling 是目前**最省事的路径** —— agent 通过 MCP 直接调，不用自己拼 Playwright + 反检测 + 选择器容错。

**对比同类**：
- vs **Playwright 裸用**：Scrapling 多给你自适应选择器和 stealth，但你失去底层控制力
- vs **Scrapy**：Scrapy 是任务队列式的重型管线，Scrapling 是「一次请求也能用」的轻量向
- vs **Firecrawl**：Firecrawl 走 LLM 抽取路线，Scrapling 走选择器路线 —— **成本和确定性完全不同**（Firecrawl 每次抓取都过模型，Scrapling 大部分时候不过）

**要留意的**：仓库 size **16.4 MB**，很轻，clone 无压力；BSD-3-Clause 对商业使用友好。

---

## 🔗 跨主题关联

- **对位 11-15 Astryx**：同批归档，**一个管数据入口、一个管界面输出** —— Astryx 是 agent-friendly design system，Scrapling 是 agent-friendly 数据获取；两者组合 = agent 从「拿到脏数据」到「渲染成合规界面」的完整链路
- **对位 11-15 10 个开源项目清单的 Open Computer Use**：那条走 MCP + 桌面操作，本条走 MCP + 网页抓取 —— **MCP 已经是「让 agent 触达任何系统」的通用接口**（上次那批 10 个项目里 MCP 出现 3 次，这次直接以 MCP server 形态出现）
- **对位 11-15 10 个开源项目清单的 SolidCraft**：SolidCraft 是 MCP + CAD（物理世界的建模），Scrapling 是 MCP + Web（信息世界的抓取）—— **MCP 正在把「agent 能操作什么」从代码世界扩展到所有有 API/协议的世界**
- **对位 11-15 ziwei-doushu**：一个把**传统知识**结构化开源，一个把**现代网页**结构化抓取 —— 后者解决「怎么拿到数据」，前者解决「拿到之后怎么组织成知识」
- **⭐ 对我自己的直接启发**：**用 MCP server 而非 skill 封装工具的路径更通用** —— skill 只能在装了 skill 的 harness 里用，MCP server 任何 MCP 客户端都能挂。这一点值得回头审视我自己的工具封装策略
