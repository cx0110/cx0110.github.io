---
title: "OpenMausBot 拆解 — 开源版 Grok Bot,把一整队本地 Agent 装进聊天软件"
date: 2026-11-15T09:00:00+08:00
lastmod: 2026-11-15T09:00:00+08:00
draft: false
weight: 9
authors:
  - admin
summary: "2026 年七周内连发四个闭源个人 agent 产品,OpenMausBot 是把 Grok Bot 那套形态开源 + 本地化的版本。本文拆它的三个核心设计:bring your own CLI、本地 harness server、agent 有手,以及和 Meta Muse / OpenAI dots / Cue 的对照。"
categories: ["🤖 AI Agent", "开源项目", "工具"]
tags: ["OpenMausBot", "Grok-Bot", "Claude-Code", "Codex", "Electron", "React-19", "本地优先", "self-hosted", "computer-use", "多Agent", "Apache-2.0", "开源项目"]
external_link: ""
---

> **一句话结论**：如果 AI 应该像 IM 那样「一组联系人各自干活、各自记忆、各自有模型和电脑」，那 OpenMausBot 就是这个形态的开源实现 —— 而且全部跑在你自己机器上。

**仓库**：<https://github.com/milind-soni/OpenMausBot> · **Homepage**：<https://www.openmausbot.com/>
**实测数据**（2026-11-15 GitHub API）：**22911 Star / 3194 Fork** · TypeScript · Apache-2.0
**建仓**：2026-08-11 · **最近推送**：2026-11-15

## 一、它解决什么问题

README 的一句话立场很直接：

> **One assistant in one box is the wrong shape for agents.** 一个盒子一个助手，是 agent 的错误形态。

OpenMausBot 保留 **Grok Bot 的形态**（AI = 一个聊天软件：侧边栏一排 bot，你像给联系人发消息一样跟它们对话，每个 bot 有自己的性格、自己的对话记忆、自己的模型、自己的电脑、自己的连接应用），然后把它重建成**开源 + 本地优先 + 跑在你已有的 agent 上**。

## 二、三个核心设计

### 1. Bring your own agents —— 用你已有的 CLI 和订阅

Bot 跑在你本机已安装的 `claude` / `codex` / `grok` CLI 上 —— **你自己的登录和订阅，不用新账号，中间没有代理**。也可以在 Settings → Engines 里把任意引擎指向自定义 CLI 二进制（版本化构建或 wrapper）。

### 2. Local first —— 数据在自己 `~`

一个跑在 `127.0.0.1` 上的小 harness server 掌管所有 agent 进程。**transcripts、keys、events 全部落在 `~/.openmausbot`，不在云端**。

### 3. Agents with hands —— agent 有手

每个 bot 可以使用：**云端 Linux 桌面**、**隔离的 Local VM**，或者（在平台安全边界已认证的地方）**你自己的电脑**，外加通过 **Composio 接入的 500+ 应用**。

> ⚠️ 宿主机控制目前仅 macOS 和 Ubuntu Xorg 需显式 opt-in；**Ubuntu Wayland 的宿主机控制仍关闭**，等 issue #345 解决。

## 三、为什么值得关注：对标的 4 个闭源产品

README 直接列了 2026 年**七周内连发的四个闭源个人 agent 产品**：

| 闭源产品 | 是什么 | OpenMausBot 的差别 |
|---|---|---|
| **Grok Bot**（xAI） | 一队 bot 共用云电脑，只有 Grok，需 SuperGrok / Cursor 订阅 | 同样的「一队 bot」形态，但**每个 bot 可选任意模型**、跑你自己机器、有审批卡片 |
| **Meta Muse** | 单个个人 agent 跑在 Meta 云 VM，仅美加 | **一队而非一个**；随处可跑；数据在 `~/.openmausbot` |
| **OpenAI dots** | ChatGPT 内的常驻 agent，只有 GPT，需 Pro / Business Premium | 多个 agent；用你自己的 Claude / ChatGPT / Grok 额度 |
| **Cue by Manus** | Manus 的个人 agent | 同上形态，开源实现 |

> 这四个的共同点是：**模型、电脑和数据都在厂商那边**。OpenMausBot 就是把这个形态开源。

## 四、技术栈与边界

- **TypeScript strict + React 19 + Electron**（macOS / Windows / Ubuntu）
- 发布形态：签名的 notarized `.dmg`（Apple silicon + Intel）、Windows x64 installer、Ubuntu 24.04 x64 `.deb` 或 AppImage beta
- ⛔ 明确声明：**与任何加密货币无关**，无 token，未接受任何代币分配，也不为任何用 Maus / SupaMaus 名字的币背书

## 五、我的判断

**值不值得看**：如果你的关注点是「多 agent 怎么组织」而不是「哪个模型最强」，这个项目把**形态问题**（agent 该长什么样）摆到了台面上 —— 聊天软件隐喻本身就是一种答案，跟 T3 Code 的「控制平面」隐喻是同一个问题的两种解法（见下篇对位）。

**要留意的**：仓库 size 已达 **557 MB**，README 有大段赞助商段落（boat.dev / modelgo.ai），说明商业化压力存在 —— 评估长期可持续性时值得看一眼。

---

## 🔗 跨主题关联

- **对位 11-15 T3 Code**：**同一问题的两种隐喻** —— OpenMausBot = 「agent 是一群联系人」（IM 隐喻，每个 bot 有独立人格和记忆），T3 Code = 「agent 是一个控制平面」（所有 agent 线程统一在一个界面里切换）。前者优化**人格感**，后者优化**调度感**
- **对位 11-14 Anthropic Sub-Agent 那篇**：那篇讲「什么时候不该拆子 agent」，本篇是「拆了之后怎么组织」的工程实例 —— 一个 agent 一个会话记忆的聊天列表，恰好是「独立上下文边界」的最朴素实现
- **对位 11-14 HylaPocket**：HylaPocket 解决「手机上盯一个 agent」，OpenMausBot 解决「手机上跟一队 agent 聊天」—— **都是把 agent 的操作面从桌面搬走**
- **对位 11-15 Scrapling / Astryx**：同为本日归档 —— Scrapling 是 agent 的「手」（抓取），Astryx 是 agent 的「界面」（设计系统），OpenMausBot 是 agent 的「容器」
- **对位 11-01 DeepSeek Super-agent 架构**：Router + Worker 双层架构的**消费端形态** —— DeepSeek 讲调度机制，本篇讲调度结果的界面长什么样
