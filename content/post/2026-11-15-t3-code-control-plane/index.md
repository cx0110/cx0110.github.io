---
title: "T3 Code 拆解 — 60K 星的跨设备 coding agent 控制平面"
date: 2026-11-15T09:00:00+08:00
lastmod: 2026-11-15T09:00:00+08:00
draft: false
weight: 10
authors:
  - admin
summary: "agent 跑在你机器上,你在任何设备上看同一条线程。它赌的是 ACP 协议标准化而非逐个集成,支持任意 ACP agent。本文拆它的七条卖点、跨设备架构,以及「控制平面 vs 聊天软件」两种 agent 组织隐喻的分野。"
categories: ["🤖 AI Agent", "开源项目", "工具"]
tags: ["T3-Code", "coding-agent", "控制平面", "Claude-Code", "Codex", "Cursor", "ACP", "worktree", "远程开发", "iOS", "Android", "MIT", "开源项目"]
external_link: ""
---

> **一句话结论**：agent 跑在你自己机器上，但你在任何设备上都能看到同一条线程 —— 桌前起个头，手机上点个批准。

**仓库**：<https://github.com/pingdotgg/t3code> · **Homepage**：<https://t3.codes>
**实测数据**（2026-11-15 GitHub API）：**60836 Star / 10942 Fork** · TypeScript · MIT
**建仓**：2026-02-08 · **最近推送**：2026-11-15

README 的定位只有一句：

> **The open-source control plane for coding agents.**

## 一、核心能力

> **T3 Code runs the coding agents on your machine and gives them one fast interface. Start a thread at your desk, then approve the next step from your phone.**

**支持的 agent**：Claude Code、Codex、Cursor、OpenCode、Grok Build、Antigravity、Kiro、Pi、Muse Code、fx，以及**任何走 ACP 协议的 agent**。

> 关键点：README 说得很直接 —— **只要 agent 装在你电脑上并登录了，T3 Code 就能驱动它**。

### 七条卖点

| | |
|---|---|
| **你的订阅** | **T3 Code 不转售 token**，它驱动的是你已经登录的 agent |
| **一个界面所有 agent** | 线程中途换模型；让 Claude 把任务交给 Codex |
| **桌面 + Web + 手机** | 一个 server，所有客户端看到同一批线程；iOS / Android 都有 App |
| **远程就绪** | agent 跑在任意机器上，局域网 / Tailscale / T3 Connect 都能连 |
| **Git 内置** | 每个线程可跑在**自己的 worktree** 里；看完 diff 一键 commit / push / 开 PR |
| **快** | 「Performance is a feature here. We measure it, and we treat a dropped frame as a bug.」 |
| **开放** | MIT 协议；「If you don't like something, fork it」 |

## 二、安装

### 桌面应用

<https://t3.codes/download>（macOS / Windows / Linux），也支持包管理器：

```bash
brew install --cask t3-code          # macOS
winget install T3Tools.T3Code         # Windows (或 scoop install extras/t3code)
yay -S t3code-bin                    # Arch Linux
nix profile add github:NixOS/nixpkgs/nixos-unstable#t3code
```

### 命令行（装 `t3` 命令）

```bash
curl -fsSL https://t3.codes/install.sh | sh
# Windows PowerShell:
irm https://t3.codes/install.ps1 | iex
# 不想装就想试一次：
npx t3@latest
```

### 手机

App Store / Google Play 装好后，按 [remote access 文档](https://github.com/pingdotgg/t3code/blob/main/docs/user/remote-access.md) 连到电脑。

### 登录一个 agent

T3 Code 需要**至少一个已安装并登录的 agent**：

```bash
claude auth login    # Claude Code
codex login          # Codex CLI
```

## 三、我的判断

**最有价值的设计是 ACP 那句话**：它不逐个集成 agent，而是**支持「任何 ACP agent」** —— 这意味着它赌的是协议标准化，而不是功能清单。这个选择的代价是新 agent 的高级特性可能接不上，收益是**不会被某个 agent 的版本节奏绑死**。

**和同类项目的分野**（对照我之前归档的）：这是「控制平面」思路 —— 和 **Cursor** 那类「IDE 里塞一个 agent」不同，T3 Code 的核心资产是**跨设备线程 + 多 agent 切换 + worktree 隔离**三件事。

**边界**：仓库 size **842 MB**，这是 Electron/桌面端体量的正常值，但 clone 前有心理准备。

---

## 🔗 跨主题关联

- **对位 11-15 OpenMausBot**：**同日归档的两种隐喻** —— T3 Code = 控制平面（一个界面统管所有 agent 线程，跨设备），OpenMausBot = 聊天软件（每个 bot 一个独立人格和记忆）。**前者管「调度」，后者管「人格」**
- **对位 11-14 HylaPocket**：**最直接的对位** —— HylaPocket 是「把终端揣进兜里」，T3 Code 是「把控制台揣进兜里」。两者都解决「人不在电脑前」，但 T3 Code 的抽象层更高（agent 无关），HylaPocket 更贴终端（hyla 专属）
- **对位 11-15 10 个开源项目清单的 Worktrunk**：Worktrunk 解决「多 agent 不打架」的方式是**管 Git worktree**；T3 Code 把 worktree 直接做进了每个线程 —— **同一个问题的两种落点（外部工具 vs 内置能力）**
- **对位 11-15 10 个开源项目清单的 Mission Control**：Mission Control 是「自托管仪表盘，管一队 agent」；T3 Code 也是「一个界面管一队 agent」—— **但 T3 Code 是面向 coding agent 的、且带远程和审批**，Mission Control 更像通用观测台
- **对位 11-14 Anthropic Sub-Agent 那篇**：那篇主张「能收回主循环的子 agent 就别拆」；T3 Code 的存在说明**反方向也是真实需求** —— 很多团队就是想拆，且需要一个体面的地方承载拆分结果
