---
title: "Astryx — Meta 开源设计系统：一个长在 Meta 内部八年的体系，向 agent 开放"
date: 2026-11-15
draft: false
weight: 9
summary: "支撑 Meta 内部 13,000+ App 的设计系统首次对外开源。真正的差异化不是 150+ 组件,而是 API、文档、CLI 三者一起设计成「人和 AI assistant 用同一套参考」。本文拆它的四个设计,并给出一条可抄的 agent CLI 入口规则。"
categories: ["🤖 AI Agent", "开源项目", "工具"]
external_link: ""
tags: ["Astryx", "设计系统", "React-19", "StyleX", "无障碍", "主题定制", "swizzle", "Meta", "CLI", "agent友好", "MIT", "开源项目"]
---

# Astryx — Meta 开源设计系统：一个长在 Meta 内部八年的体系，向 agent 开放

> **仓库**:https://github.com/meta/astryx
> **Star / Fork**:28315 / 2201(实测 GitHub API)
> **License**:MIT · **主语言**:TypeScript · **建仓**:
> **Topics**:design-system, react, stylex, accessibility, theming, agent-ready, cli

## 一句话定位

**一句话结论**：**大厂设计系统开源的第一例，但它开源的不只是组件 —— 它开源的是「人和 agent 用同一套工具建同一套界面」的方法。**

## 为什么值得看

支撑 Meta 内部 13,000+ App 的设计系统首次对外开源。真正的差异化不是 150+ 组件,而是 API、文档、CLI 三者一起设计成「人和 AI assistant 用同一套参考」。本文拆它的四个设计,并给出一条可抄的 agent CLI 入口规则。

## 详细拆解

> 完整分析见配套文章:Astryx 拆解 — Meta 把内部八年的设计系统开源,并让人和 agent 用同一套工具

