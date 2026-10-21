---
title: "Pipelock — AI Agent 防火墙"
date: 2026-10-21
draft: false
weight: 3
summary: "luckyPipewrench 写的 Go 出站控制 + ed25519 签名收据 - 专治 Agent 偷数据 / 提示注入 / SSRF"
categories: ["🔒 AI Agent", "Go 库"]
external_link: ""
---

# Pipelock — AI Agent 防火墙

> **作者**:luckyPipewrench
> **链接**:https://github.com/luckyPipewrench/pipelock
> **License**:开源(请参考 repo)
> **类型**:Go 库 / 工具 · AI Agent 安全

## 一句话定位

**专治 AI Agent 偷偷泄露密钥 / 中招提示注入 / 被 SSRF 攻击** — 在 Agent 与开放互联网之间划一条线。

## 使用场景

- 🛡️ **Claude Code 出站控制**:`HTTPS_PROXY=http://localhost:8080 claude` 一行启动拦截
- 🔌 **MCP wrapper**:`pipelock mcp wrap --` 包装任意 MCP Server
- 📜 **可验证收据**:每个动作生成 ed25519 签名,事后离线审计

## 监测的 5 类威胁

1. **密钥泄露** — `$PROVIDER_API_KEY` 等环境变量被外发
2. **提示注入** — 恶意 instruction 让 Agent 走偏
3. **SSRF 攻击** — Agent 调用 `http://169.254.169.254/` 拿到云元数据
4. **工具投毒** — MCP Server 返回恶意 payload
5. **危险工具调用链** — 多步组合形成攻击

## 我的使用感受

我目前部署 Pipelock 作为 Claude Code 的安全网关。**ed25519 签名收据** 是它最爽的地方 — 晚上回看,可以离线验证「今天这个 Agent 真的只是去 readme.io 读了个文档,没有被偷 API key」。这是 Snyk Agent Scan 那种静态扫描工具给不了的。

## 亮点 & 局限

| 亮点 | 局限 |
|---|---|
| 动态拦截 + 离线可验证收据 | 配置复杂,需要懂 HTTP 代理 |
| polarisxu 三件套(Herdr / AgentRQ / Pipelock) | 第一次跑要走证书配置流程 |
| 轻量 Go 单二进制 | 暂无 GUI,需要命令行 |

## 关联笔记

- 02_Research/AI-Tooling/2026-10-21_Pipelock-AI-Agent防火墙...(主归档)
- 02_Research/AI-Tooling/2026-10-12_Go每日一库之AgentRQ(polarisxu 姊妹篇 1)
- 02_Research/AI-Tooling/2026-09-05_Herdr-AI-Agent时代的tmux(polarisxu 姊妹篇 2)

---

> 📝 本卡片基于我 push 给 AI 助手归档的资料整理而成 → 详见 [ob-vault](https://github.com/cx0110/ob-vault) 02_Research/AI-Tooling/
