---
title: "Go 每日一库之 Tangentry：多平台内容聚合神器，B站、YouTube、小红书、播客一个阅读器搞定"
date: 2026-11-15
draft: false
weight: 10
summary: "基于 Go 1.27 + React 19 + MyGo 桌面壳的多平台内容聚合器。核心不是「聚合」而是「视频和播客也能读」:字幕跟随、全文搜索、时间戳笔记、导出 Obsidian frontmatter。本文拆它的平台适配器统一接口和转录服务双层设计。"
categories: ["Go 库", "开源项目", "工具"]
external_link: ""
tags: ["Go", "MyGo", "内容聚合", "RSS", "视频字幕", "播客转录", "本地优先", "SQLite", "AI摘要", "whisper.cpp", "Qwen3-ASR", "yt-dlp", "React-19", "开源项目"]
---

# Go 每日一库之 Tangentry：多平台内容聚合神器，B站、YouTube、小红书、播客一个阅读器搞定

> **仓库**:https://github.com/
> **Star / Fork**: / (实测 GitHub API)
> **License**: · **主语言**: · **建仓**:
> **Topics**:

## 一句话定位

**一句话结论**：把「B站课程 + YouTube 技术分享 + 小红书图文 + 抖音短视频 + 小宇宙播客 + RSS 长文」全部收进**一个本地优先的阅读器**，并且**视频和播客也能"读"** —— 字幕跟随、全文搜索、时间戳笔记、导出 Obsidian。

## 为什么值得看

基于 Go 1.27 + React 19 + MyGo 桌面壳的多平台内容聚合器。核心不是「聚合」而是「视频和播客也能读」:字幕跟随、全文搜索、时间戳笔记、导出 Obsidian frontmatter。本文拆它的平台适配器统一接口和转录服务双层设计。

## 详细拆解

> 完整分析见配套文章:Tangentry 拆解 — 把 B站/YouTube/小红书/播客塞进一个本地优先阅读器

