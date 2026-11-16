---
title: "10 个开源 AI 项目 — 按「agent 能触达什么」重新排序"
date: 2026-11-13T09:00:00+08:00
lastmod: 2026-11-13T09:00:00+08:00
draft: false
weight: 9
authors:
  - admin
summary: "DeepSeek Harness / Agent Autoloop / Agent Desktop / Orkas / SolidCraft / DSH Go / Worktrunk / PixelFX / Mission Control / Open Computer Use —— 十个项目散点背后是一条完整技术路线图,本文按「本体→后台→桌面→物理→编排→隔离→移动→创意」重排,并指出两个正在成型的共性。"
categories: ["🤖 AI Agent", "开源项目"]
tags: ["开源项目", "Agent", "MCP", "CAD", "Git-Worktree", "多Agent协作", "Computer-Use", "DeepSeek-Harness", "选型", "AI-Tooling"]
external_link: ""
---

> **一句话结论**：开源社区已经把 agent 从聊天机器人推进到「操作桌面 / 建 3D 模型 / 多 agent 协作 / 后台自动执行」—— 但成熟度参差，值得挑着试。

AI 世界的发展速度惊人。每周都有开发者发布新项目，让 AI 更实用，赋予智能体新的能力，或解决一些我们此前甚至没意识到需要解决的问题。

其中一些项目的实用程度令人惊喜：**你可以用 AI 创建 3D 模型、控制桌面应用、管理多个编程智能体，甚至通过手机运行编程助手。**

有趣的是，许多项目都是开源的 —— 你可以研究它们的代码，自行运行，甚至参与开发。

## 1. DeepSeek Harness

**GitHub**：<https://github.com/deepseek-ai/deepseek-harness>

如果你能构建自己的 AI 编程助手，并且几乎所有方面都可以自定义，会怎么样？

这正是 DeepSeek Harness 的理念。它是一个用于**构建和运行 AI 智能体**的开源框架，专注于编程和可扩展性。你可以通过不同的工具和插件扩展它，为智能体增加能力，而不必局限于一套固定配置。

可以用它构建一个能够处理代码库、执行开发任务，并在需要时使用外部工具的助手。最棒的是，**你可以在本地运行它**，探索适合自己的 AI 编程环境应该如何运作。

## 2. Agent Autoloop

**GitHub**：<https://github.com/KKKKhazix/agent-autoloop>

大多数 AI 编程智能体的工作方式是：你给它一个任务，等待它完成，然后再给它下一条指令。

Agent Autoloop 采用了不同的方式 —— 它帮助 AI 智能体**在后台自动运行**：

- **定时任务**
- **事件触发**（特定事件发生时触发操作）

例如，假设你的 GitHub 仓库中出现了一个新 issue。你可以配置自动化工作流，让智能体开始调查，而不必手动打开编程助手。

还可以配置**通知和审批步骤**，确保重要操作经过你的许可后才会执行。

如果你希望 AI 智能体不只是响应提示词，这个项目值得关注。

## 3. Agent Desktop

**GitHub**：<https://github.com/vercel-labs/agent-desktop>

AI 智能体已经相当擅长编写代码，但让它们与桌面应用交互，则是另一种挑战。

Agent Desktop 让 AI 智能体能够**利用无障碍（accessibility）信息**理解桌面应用并与之交互。这意味着智能体可以识别按钮、文本框和菜单等界面元素，**而不必完全依赖屏幕截图**。

> 想象一下：你让智能体打开某个应用，找到一项特定设置并修改它。智能体可以利用实际界面的信息，而不必猜测屏幕上各个元素的位置。

这让桌面自动化更有条理，也有望更加可靠。

## 4. Orkas

**GitHub**：<https://github.com/Orkas-AI/Orkas>

既然可以拥有一整支 AI 智能体团队，为什么只用一个？

Orkas 是一个开源、**以本地为优先**的 AI 工作区，旨在协调多个专门负责不同工作的智能体。你可以围绕研究、写作、编程和制作演示文稿等不同任务来组织智能体。

例如，一个智能体研究主题，另一个整理信息，还有一个帮助准备最终成果。

它还支持与 **Claude Code、Codex 和 OpenCode** 等编程工具协同工作 —— 目标是把多个智能体整合到同一个工作空间，让你无需在不同的 AI 应用之间频繁切换。

## 5. SolidCraft

**GitHub**：<https://github.com/tangency-labs/solidcraft>

如果你用过 3D 建模软件，这个项目会格外有意思。

SolidCraft 是一款开源**参数化 CAD 应用**，允许 AI 智能体通过 **MCP** 创建和修改 3D 模型。

> 想象一下：你让 AI 为一个电子项目创建一个简单的外壳。随后，你可以让它增大尺寸、改变壁厚，或修改设计中的特定部分 —— 全程用自然语言引导，无需手动调整每一处尺寸。

这个例子很有意思，展现了 AI 如何开始**从文本和代码走向实际的设计与工程工作流**。

## 6. DSH Go

**GitHub**：<https://github.com/ccch1mneyyy/dsh-Go>

如果你能随身携带 AI 编程助手，而不再局限于电脑前，会怎么样？

DSH Go 是一款基于 **DeepSeek Harness** 构建的 **Android 应用**。它提供了与编程智能体协作的移动端界面，让你能够通过手机参与开发工作流。

根据具体配置，你可以在设备上运行智能体，也可以**连接到电脑上已有的会话**。

> 想象一下：你离开办公桌后仍能查看编程任务的进度，或是不打开笔记本电脑就能发送下一条指令。

对于不希望 AI 辅助工作流被绑定在单一设备上的开发者来说，这个思路很实用。

## 7. Worktrunk

**GitHub**：<https://github.com/max-sixty/worktrunk>

如果你曾尝试让**多个 AI 编程智能体同时处理同一个项目**，应该知道事情很容易变得混乱 —— 两个智能体可能会尝试修改相同的文件、覆盖改动，或干扰彼此的工作。

Worktrunk 通过简化 **Git worktree** 的管理来帮助避免这些问题。Git worktree 允许你为同一个仓库创建多个工作副本，每个副本使用不同的分支。

> 例如：你可以让一个 AI 智能体修复 bug，同时让另一个开发新功能。两者可以独立工作，无需不断修改同一个工作目录。

如果你正在尝试使用多个编程智能体，Worktrunk 值得探索。

## 8. PixelFX

**GitHub**：<https://github.com/patch-gg/pixelfx>

有趣的 AI 项目并不一定都围绕编程助手或自动化展开。

PixelFX 是一个面向游戏开发者的**像素风视觉特效和动画合集**，包含数百种特效，可用于游戏和其他创意项目。

特别有意思的是，它还包含一个 **Claude Code skill** —— 这让开发者可以借助 AI 编程助手创建、渲染和改进像素风特效。

> 例如：让编程助手创建一个像素风爆炸效果，预览结果，然后不断调整，直到效果满意。

这是 AI 帮助创意开发的一个好例子 —— 用途不限于编写应用代码。

## 9. Mission Control

**GitHub**：<https://github.com/builderz-labs/mission-control>

运行多个 AI 智能体令人兴奋，直到你发现，想轻松掌握它们各自在做什么并不容易。

Mission Control 是一个**可自行托管的仪表盘**，集中管理和监控多个 AI 智能体：

- 分配任务
- 跟踪智能体活动
- 检查错误
- 关注智能体的表现

可以把它看作 AI 团队的**控制室**。有了这个集中监控工作流的平台，就不必打开多个终端，逐一查看每个智能体。

对于正在尝试使用多个自主智能体的开发者来说，这个项目尤其值得关注。

## 10. Open Computer Use

**GitHub**：<https://github.com/opensymph/open-computer-use>

AI 智能体能够编写代码、搜索网页和处理信息。但让它们**实际操作你的电脑**呢？

Open Computer Use 是一个开源项目，让 AI 智能体能够通过 **MCP 服务器**与桌面应用交互。兼容的 AI 助手可以执行点击按钮、输入文本、滚动页面以及与应用窗口交互等操作。

> 想象一下：你让 AI 助手打开某个应用，在界面中进行操作，并完成一项重复性任务。

智能体可以直接与电脑交互，而不只是向你解释每一步该怎么做 —— 这是更大转变的一部分：**AI 智能体不仅告诉你如何做事，还能真正帮你完成事情。**

## 最后的思考

这些项目的有趣之处在于，它们展示了 AI 正以多快的速度**超越简单聊天机器人的范畴**。我们已经开始看到 AI 智能体与桌面应用交互、创建 3D 设计、与其他智能体协作，以及在后台自动执行任务。

而且，你**未必需要等待大型科技公司发布这些功能** —— 许多开发者已经在以开源项目的形式构建它们。

> 这里的项目并非都已达到可在生产环境中日常使用的成熟程度，但如果你喜欢探索 AI 的可能性，它们都值得一试。

---

## 🔗 跨主题关联

**★ 这 10 个项目不是散点，而是一条完整的技术路线图 —— 按「agent 能触达什么」排序：**

| 层级 | 项目 | 解决什么 |
|---|---|---|
| **本体（造 agent）** | DeepSeek Harness | 构建和运行 agent 的框架，可自定义扩展 |
| **后台自动化** | Agent Autoloop | 定时/事件驱动，agent 不用你盯着 |
| **触达桌面** | Agent Desktop（无障碍）/ Open Computer Use（MCP） | 两种不同的桌面交互路径 |
| **触达物理/工程** | SolidCraft（MCP + 参数化 CAD） | 从文本到 3D 模型 |
| **多 agent 编排** | Orkas（工作区）/ Mission Control（仪表盘） | 一个管协作，一个管观测 |
| **并发隔离** | Worktrunk（Git worktree） | 多 agent 不打架的前提 |
| **移动端** | DSH Go / HylaPocket | 把 agent 揣进兜里 |
| **创意域** | PixelFX（含 Claude Code skill） | 不写应用代码也能用 |

- **对位 11-14 HylaPocket 篇**：**DSH Go 与 HylaPocket 是同一需求的两种实现** —— 前者复用 DeepSeek Harness 体系做 Android 壳，后者基于自研 hyla 的 GPUI 终端写客户端；两篇一起读 = 移动端 agent 的两条路线
- **对位 11-01 DeepSeek Super-agent 架构**：DeepSeek Harness 在本篇是「可扩展框架」定位，在 11-01 那篇是「OS 四抽象平移」的运行时定位 —— **一个是框架层，一个是运行时层**
- **对位 11-14 Anthropic Sub-Agent 那篇**：Orkas / Mission Control / Worktrunk 三件套 = 多 agent 架构的**运维侧**（怎么分工、怎么观测、怎么隔离）；而 Anthropic 那篇讲的是**什么时候不该用多 agent** —— 本篇给工具，那篇给判断标准
- **对位 10-21 AgentRQ（Human-in-loop 任务管理器）**：Agent Autoloop 的「通知和审批步骤」= AgentRQ 的 human-in-loop 审批环 —— 同一需求的两种实现深度
- **⭐ 值得注意的共性**：**MCP 出现了 3 次**（SolidCraft / Open Computer Use / 隐含在 Orkas 的工具协同）—— MCP 已经从「给 agent 加工具」变成「让 agent 触达任何有 MCP server 的系统」，包括 CAD 软件和桌面应用
- **⭐ 另一个共性**：**两个项目自带 Claude Code skill**（PixelFX 明确自带，DeepSeek Harness 可扩展）—— 「skill 作为项目分发单位」正在成为新常态
- **对位 10-21 RoboParty RP1**：本篇的 SolidCraft 是「软件里的物理世界」，RP1 是「物理世界里的软件」—— 同一趋势的两端
