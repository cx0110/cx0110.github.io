---
title: "T3 Code — 跨设备多 Agent 编程控制平面"
date: 2026-11-15
draft: false
weight: 10
summary: "agent 跑在你机器上,你在任何设备上看同一条线程。它赌的是 ACP 协议标准化而非逐个集成,支持任意 ACP agent。本文拆它的七条卖点、跨设备架构,以及「控制平面 vs 聊天软件」两种 agent 组织隐喻的分野。"
categories: ["🤖 AI Agent", "开源项目", "工具"]
external_link: ""
tags: ["T3-Code", "coding-agent", "控制平面", "Claude-Code", "Codex", "Cursor", "ACP", "worktree", "远程开发", "iOS", "Android", "MIT", "开源项目"]
---

# T3 Code — 跨设备多 Agent 编程控制平面

> **仓库**:https://github.com/pingdotgg/t3code
> **Star / Fork**:60836 / 10942(实测 GitHub API)
> **License**:MIT · **主语言**:TypeScript · **建仓**:
> **Topics**:agent-orchestration, agents, claude, claude-code, codex, vibe-coding, acp

## 一句话定位

**一句话结论**：agent 跑在你自己机器上，但你在任何设备上都能看到同一条线程 —— 桌前起个头，手机上点个批准。

## 为什么值得看

agent 跑在你机器上,你在任何设备上看同一条线程。它赌的是 ACP 协议标准化而非逐个集成,支持任意 ACP agent。本文拆它的七条卖点、跨设备架构,以及「控制平面 vs 聊天软件」两种 agent 组织隐喻的分野。

## 详细拆解

> 完整分析见配套文章:T3 Code 拆解 — 60K 星的跨设备 coding agent 控制平面

