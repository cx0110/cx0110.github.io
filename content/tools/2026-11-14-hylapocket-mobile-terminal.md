---
title: "HylaPocket：把终端揣进兜里"
date: 2026-11-15
draft: false
weight: 9
summary: "不是远程桌面,是终端自己的字节流用 Ghostty vt 库在手机上重画一遍。本文拆它的三个关键设计:配对码即钥匙的免端口方案、pane 尺寸接管与归还机制,以及为什么「会话寿命 > 客户端寿命」是核心。"
categories: ["🤖 AI Agent", "开源项目", "工具"]
external_link: ""
tags: ["Hyla", "HylaPocket", "coding-agent", "终端", "Android", "tailcat", "Ghostty", "GPUI", "移动端开发", "开源项目"]
---

# HylaPocket：把终端揣进兜里

> **仓库**:https://github.com/
> **Star / Fork**: / (实测 GitHub API)
> **License**: · **主语言**: · **建仓**:
> **Topics**:

## 一句话定位

**一句话结论**：把 coding agent 的终端会话原封不动搬到手机屏幕上 —— 不是远程桌面，是真的终端。

## 为什么值得看

不是远程桌面,是终端自己的字节流用 Ghostty vt 库在手机上重画一遍。本文拆它的三个关键设计:配对码即钥匙的免端口方案、pane 尺寸接管与归还机制,以及为什么「会话寿命 > 客户端寿命」是核心。

## 详细拆解

> 完整分析见配套文章:HylaPocket 拆解 — 把 coding agent 的终端会话原封不动搬到手机

