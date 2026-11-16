---
title: "Scrapling — 现代化爬虫框架：从单次请求到全站爬取的统一栈"
date: 2026-11-15
draft: false
weight: 9
summary: "自适应选择器 + 反检测 + MCP server + 官方 Agent Skill 四件套,让 agent 直接挂载调用而不是自己拼 Playwright。本文对比它与 Scrapy / Firecrawl 的路线差异,并提出一个值得反思的问题:封装工具该用 skill 还是 MCP server?"
categories: ["🤖 AI Agent", "开源项目", "工具"]
external_link: ""
tags: ["Scrapling", "爬虫", "数据抓取", "MCP", "MCP-Server", "Agent-Skill", "Playwright", "stealth", "xpath", "Python", "BSD-3-Clause", "开源项目"]
---

# Scrapling — 现代化爬虫框架：从单次请求到全站爬取的统一栈

> **仓库**:https://github.com/D4Vinci/Scrapling
> **Star / Fork**:103062 / 10737(实测 GitHub API)
> **License**:BSD-3-Clause · **主语言**:Python · **建仓**:
> **Topics**:ai-scraping, mcp-server, agent-skill, playwright, stealth, xpath, data-extraction

## 一句话定位

**一句话结论**：爬虫框架里少见地同时做了三件事 —— **自动适应页面变化** + **反检测** + **MCP server（agent 可直接调用）**。

## 为什么值得看

自适应选择器 + 反检测 + MCP server + 官方 Agent Skill 四件套,让 agent 直接挂载调用而不是自己拼 Playwright。本文对比它与 Scrapy / Firecrawl 的路线差异,并提出一个值得反思的问题:封装工具该用 skill 还是 MCP server?

## 详细拆解

> 完整分析见配套文章:Scrapling 拆解 — 100K 星的爬虫框架,本体就是一个 MCP Server

