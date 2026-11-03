---
title: "ai-goofish-monitor — 15.9K 星的闲鱼 AI 监控机器人"
date: 2026-11-03
draft: false
weight: 2
summary: "Playwright 爬闲鱼 + 多模态 AI 判断「值不值得买」+ 7 通道推送的自动化捡漏流水线。反检测指纹、失败熔断、DDD 分层都做得比同类项目扎实,但登录态明文落盘是必须先处理的安全问题。"
categories: ["🤖 AI Agent", "工具", "开源项目", "Python"]
external_link: ""
tags: ["Playwright", "多模态AI", "闲鱼", "自动化监控", "反爬", "Docker", "Python", "开源项目"]
---

# ai-goofish-monitor — 15.9K 星的闲鱼 AI 监控机器人

> **作者**:dingyufei615 → 已迁至 `Usagi-org` 组织
> **链接**:https://github.com/Usagi-org/ai-goofish-monitor
> **License**:MIT
> **类型**:外部开源项目 · Python / Playwright / FastAPI / Vue3

## 一句话定位

**把「人工捡漏」拆成三段流水线:Playwright 采价 → 多模态 AI 判值 → 推送触达。**

判断这一步交给模型而不是硬编码规则 —— 你写一句人话描述需求,LLM 把它翻译成分析标准,之后每个商品(图片 + 文本)都过这套标准。

## 解决什么问题

普通关键词监控脚本写不出「值不值得买」:

```python
# ❌ 规则写不出来 —— 成色/配置/附件/信用/价格分位,哪个权重更高?
if "iPhone 15 Pro" in title and "9成新" in desc and price < 6000:
```

ai-goofish-monitor 让你写:

> 「95 新以上,国行,电池健康 > 90,预算 6000,不要维修过的,优先个人卖家」

后台 LLM 把它转成 Prompt,之后自动判定。

## 亮点 & 局限

| 亮点 | 局限 |
|---|---|
| **反检测做得实** —— 注入 JS 抹除 `navigator.webdriver`、伪造 plugins/languages/maxTouchPoints、覆写 `permissions.query` | **登录态明文存本地** `state/*.json`,泄露 = 账号沦陷;必须 `chmod 700` |
| **全链路随机延迟** —— 源码注释留着「原来是 (1.5, 2.5)」,参数是调出来的 | Web UI 默认密码 `admin123`,**必须改** |
| **浏览器指纹复刻** —— Chrome 扩展把真机的 cookie + navigator + headers 一起搬过去 | 不解析 DOM 而 hook `mtop` API,接口一变就要跟 |
| **AI 协议自适应** —— chat-completions ↔ responses 双向降级,还处理不支持 `response_format` / `temperature` 的情况 | 「自然语言生成任务」生成的是 Prompt 不是逻辑,误差会传导 |
| **失败熔断** —— `FailureGuard` 失败 3 次暂停 24h,每天最多通知 1 次,按本地时区算 | 高频多账号必然触发风控,熔断器本身就是承认这点 |
| **代理池 + 账号三策略** —— auto / fixed / rotate,失败代理自动拉黑 5 分钟 | 平台协议禁止自动化采集,项目免责但功能不设限 |
| **DDD 分层** —— api / core / domain / infrastructure / services,repository 双实现(SQLite + JSON) | AI 判定成本高,每个商品一次多模态调用 |
| **7 个推送渠道** —— ntfy / PushPlus / Bark / 企业微信 / Telegram / Gotify / 通用 Webhook | 需要支持图片输入的多模态模型,默认指向 ModelScope |
| **Docker 一键,镜像内置 Chromium** | 默认分支是 `master` 不是 `main` |

## 怎么用

```bash
git clone https://github.com/Usagi-org/ai-goofish-monitor && cd ai-goofish-monitor
cp .env.example .env
# 必改:
#   WEB_PASSWORD           默认 admin123
#   OPENAI_API_KEY/BASE_URL/MODEL_NAME
#   PROXY_POOL              建议配
docker compose up -d
docker compose logs -f app
# → http://127.0.0.1:8000
```

**拿登录态**:装 `chrome-extension/`(Chrome 商店搜「Xianyu Login State Extractor」)→ 登录 goofish.com → 导出 JSON → 粘贴到「闲鱼账号管理」。

**省额度**:先用 `decision_mode=keyword` 跑通链路,再切 AI 模式。

**镜像拉不动**:用南京大学镜像站 `ghcr.nju.edu.cn/usagi-org/ai-goofish:latest`。

## 规模

| 指标 | 值 |
|---|---|
| Star | **15,954** |
| 后端 | 15,178 行 Python |
| 前端 | ~11K 行 TS/Vue |
| 测试 | 32 个测试文件(unit / integration / live 三层) |
| 服务层 | 24 个 service |

## 关联

- 博客文章:[ai-goofish-monitor 拆解 — 15.9K 星的闲鱼 AI 监控机器人](https://cx0110.github.io/post/2026-11-03-ai-goofish-monitor/)
- ob-vault:`02_Research/Tools/2026-11-03_ai-goofish-monitor拆解15.9K星的闲鱼AI监控机器人.md`
- 飞书:RePig 知识库 → 工具 / 开源项目

---

> ⚠️ **使用提示**:高频自动化操作极易触发闲鱼风控,可能导致账号被限流或封禁。建议仅做技术学习与低频个人使用,不要用于批量商业操作。
>
> 📝 本卡片基于 [ob-vault](https://github.com/cx0110/ob-vault) `02_Research/Tools/` 归档整理而成
