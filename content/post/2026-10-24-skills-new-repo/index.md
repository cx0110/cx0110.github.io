---
title: "Skills 新仓库 — 4581 个 Agent 技能的三源总库"
date: 2026-10-24T09:00:00+08:00
lastmod: 2026-10-24T09:00:00+08:00
draft: false
weight: 10
authors:
  - admin
summary: "把「本地已装的 116 个 Hermes 技能」+「obra/superpowers 官方 15 个」+「ob-vault 笔记提到的 39 个上游仓库(4450 个技能文件)」汇编成一个可检索、可版本化的技能总库 — 顺带讲清楚 SKILL.md 那个「S 规范」到底是怎么运作的。"
categories: ["🤖 AI Agent", "开源项目", "工具", "知识管理"]
tags: ["Skills", "Agent-Skills", "SKILL-md", "Hermes", "obra-superpowers", "Obsidian", "知识管理", "提示词工程"]
external_link: ""
---

# Skills 新仓库 — 4581 个 Agent 技能的三源总库

> **仓库**:<https://github.com/cx0110/skills-new>
> **规模**:33,602 个文件 · **4,581** 个 `SKILL.md` · commit `c15a031` · 452 MB
> **本地路径**:`~/workspace/repos/cx0110/skills-new`

## 一句话定位

把「**本地已安装的技能**」+「**笔记里提到但没装的技能仓库**」+「**hash 锁定的官方技能**」三源汇编成一份**可检索、可版本化、可同步**的技能总库。

---

## 一、先回答「里面有什么 S 规范之类的东西」

你问的「S 规范」,在 Agent Skill 生态里指的是 **Anthropic 的 Agent Skills 规范** —— 一套让 LLM 按需加载专业知识的文件组织标准。它不是一个东西,而是**三层渐进式披露**的加载协议。

### 1.1 三件套结构

```
<skill-name>/
├── SKILL.md          ← 第 1 层:frontmatter + 核心 SOP(永远在上下文里)
├── references/       ← 第 2 层:深度资料(按需读,引用才进上下文)
├── scripts/          ← 第 3 层:可执行代码(跑起来,不占 token)
├── templates/        ← 输出模板
└── assets/           ← 图片/字体等静态资源
```

**关键机制**:Agent 启动时只加载 `SKILL.md` 的 frontmatter(几十 token),正文和 `references/` **都在磁盘上不占上下文**。只有任务命中该技能时,才把 `SKILL.md` 正文读进来;遇到「这个细节去查 `references/xxx.md`」才进一步加载。

这解决了 RAG 的老问题:**检索是关键词匹配,加载是 LLM 自主决定**。前者召回率低,后者贵。Skill 用「三级台阶」把二者结合 —— 大部分时候停在第 1 级。

### 1.2 SKILL.md 的 frontmatter 契约

```yaml
---
name: systematic-debugging
description: "Use when encountering any bug, test failure, or unexpected
  behavior, before proposing fixes. 4-phase root cause workflow:
  investigate evidence, analyze patterns, test one hypothesis, then fix."
---
```

- **`name`** — 技能标识,kebab-case
- **`description`** — **最重要的一行**。这是 Agent 判断「要不要加载我」的唯一依据,必须写清 **触发条件**,不是写清「我是什么」
- **正文** — Markdown 写的 SOP,给 LLM 读的,不是给人读的

> 这就是为什么 Hermes 的 skill 描述里满是「当用户报 X 时用此技能」这种句式 —— description 是**检索器**,不是简介。

### 1.3 渐进式披露的三级台阶

| 层级 | 内容 | 何时进上下文 | token 量级 |
|---|---|---|---|
| **L1** | `SKILL.md` frontmatter | Agent 启动,全部技能 | ~50/技能 |
| **L2** | `SKILL.md` 正文 | 技能被命中 | ~500-3000 |
| **L3** | `references/*.md` / `scripts/*` | 正文中显式引用 | 按需 |

### 1.4 本仓库的真实分层统计

我统计了本地已装的 116 个 Hermes 技能:

| 形态 | 数量 | 说明 |
|---|---|---|
| **完整三件套**(有 `references/` 或 `scripts/`) | **67** | 成熟技能,细节外置 |
| **纯 SKILL.md**(单文件) | **49** | 轻量技能,一文件说完 |

references 最多的几个(细节量 = 经验沉淀量):

| 技能 | references 数 | scripts |
|---|---|---|
| `workflow/wechat-curl-archive` | 54 | ✅ |
| `okx-price` | 29 | ✅ |
| `workflow/ob-vault-push` | 23 | — |
| `workflow/tech-roadmap-research` | 20 | — |
| `workflow/ob-vault-restructure` | 19 | — |
| `workflow/oss-source-analysis` | 19 | — |
| `workflow/cx0110-repos-workflow` | 17 | — |

> `wechat-curl-archive` 54 个 references 是什么概念 —— 微信公众号抓取的每一个坑位(captcha 绕过、firecrawl 403、README 表格 anchor 陷阱、批量归档节奏…)**每一个都是踩过一次才写成文件的**。这就是 skill 的真正价值:**把「试错历史」压缩成可检索的文件**。

---

## 二、三源结构

```
skills-new/
├── hermes-skills/          ← 源 1:本地已安装技能(~/.hermes/skills/)
│   └── <分类>/<技能名>/SKILL.md
├── obra-superpowers/       ← 源 2:obra/superpowers 官方技能(全 15 个)
│   └── <技能名>/SKILL.md
├── ob-vault-referenced/    ← 源 3:ob-vault 笔记提到的外部技能仓库(39 个)
│   └── <owner>__<repo>/…   (含上游 README/LICENSE)
├── README.md               ← 总索引(三源结构 + 分层索引 + 安装同步)
├── INDEX.md                ← 全量清单(机器可读,4,581 行)
├── PROVENANCE.md           ← 来源 / 获取方式 / 裁剪策略 / hash 锁定表
├── build_index.py          ← 索引生成器
├── LICENSE                 ← MIT(仓库自建部分)
└── .gitignore
```

| 源 | 数量 | 形态 | 特征 |
|---|---|---|---|
| **Hermes 已安装** | **116** | 各分类 SKILL.md | 「**能跑的**」—— 装机即用 |
| **obra/superpowers** | **15** | Anthropic 标准 | 「**锁定的**」—— hash 校验防篡改 |
| **ob-vault 引用** | **39 仓库 / 4,450** | 上游快照 | 「**看过但没装的**」—— 决策依据 |

> **为什么三者并列**:只看已装的,你会漏掉「还没用但值得知道」的存在;只看笔记提到的,全是二手。三源合起来才是完整的技能版图。

---

## 三、源 1 — Hermes 已安装技能(116)

按 **21 个分类**整理:

### 💻 软件开发方法论(15)

`debugging-hermes-tui-commands` `external-skill-install` `go-agent-harness` `go-ai-harness` `go-quality-hardening` `hermes-agent-skill-authoring` `inspecting-hermes-desktop-dom` `plan` `python-ai-harness` `requesting-code-review` `simplify-code` `subagent-driven-development` `subagent-failure-recovery` `systematic-debugging` `test-driven-development`

### 🤖 AI / LLM 与 Agent(26)

| 分类 | 技能 |
|---|---|
| `mlops` (16) | `audiocraft` `axolotl` `clip` `dspy` `grpo-rl-training` `guidance` `modal` `obliteratus` `outlines` `peft` `pytorch-fsdp` `segment-anything` `stable-diffusion` `trl-fine-tuning` `unsloth` `whisper` |
| `autonomous-ai-agents` (3) | `computer-use` `hermes-agent` `merge-reconciler` |
| `mcp` (2) | `mcporter` `native-mcp` |
| `openclaw-imports` (5) | `microsoft-foundry` + 4 个模型部署子技能(`capacity` / `customize` / `preset` / `deploy-model`) |

### 🔁 端到端工作流(13)

`ai-content-pipeline` `cx0110-repos-workflow` `github-resource-pool-ingestion` `hermes-cron-ops` `multi-perspective-corpus-curation` `ob-vault-push` `ob-vault-restructure` `ob-vault-to-feishu-wiki` `ob-vault-tooling-setup` `oss-source-analysis` `personal-cloud-drive-curation` `tech-roadmap-research` `wechat-curl-archive`

### 📊 办公生产力(13)

`box` `document-to-action-items` `docx` `lark-suite` `linear` `meeting-action-items` `pdf` `petdex` `product-price-monitor` `session-librarian` `tui-widgets` `weekly-review-planning` `xlsx`

### 📝 Spec 驱动开发流水线(10)

`workflow-start` `need-explorer` `spec-writer` `contract-builder` `build-executor` `code-reviewer` `bug-investigator` `release-archivist` `spec-merger` `spec-superflow`

### ⚙️ 运维 / 创意 / 媒体 / 其他(39)

| 分类 | 技能 |
|---|---|
| `devops` (5) | `hermes-cron-management` `kanban-orchestrator` `kanban-worker` `sdlc-review` `webhook-subscriptions` |
| `creative` (5) | `baoyu-comic` `creative-ideation` `github-site-publishing` `hermes-image-generate` `pixel-art` |
| `apple` (4) | `macos-computer-use` `macos-gui-stuck-recovery` `macos-keychain-security-diagnostic` `macos-launchd-diagnostics` |
| `media` (3) | `bilibili-auto-transcript` `heartmula` `spotify` |
| `gaming` (2) | `minecraft-modpack-server` `pokemon-player` |
| `methodology` (2) | `karpathy-guidelines` `karpathy-llm-wiki-method` |
| 单技能分类(6) | `jupyter-live-kernel`(data-science) `abtop`(devtools) `email-inbox-triage`(email) `github-issue-to-pr`(github) `obsidian`(note-taking) `godmode`(red-teaming) |
| 独立技能(12) | `aihot` `hermes-desktop-plugins` `hermes-self-upgrade` `hermes-themes` `kami` `netease-music-assistant` `netease-music-cli` `ob-vault-patch-and-amend-recipes` `okx-price` `quarkclouddrive` `skill-manager` `yuanbao` |

---|---|
| `devops` (5) | `hermes-cron-management` `kanban-orchestrator` `kanban-worker` `sdlc-review` `webhook-subscriptions` |
| `creative` (5) | `baoyu-comic` `creative-ideation` `github-site-publishing` `hermes-image-generate` `pixel-art` |
| `apple` (4) | `macos-computer-use` `macos-gui-stuck-recovery` `macos-keychain-security-diagnostic` `macos-launchd-diagnostics` |
| `media` (3) | `bilibili-auto-transcript` `heartmula` `spotify` |
| `gaming` (2) | `minecraft-modpack-server` `pokemon-player` |
| `methodology` (2) | `karpathy-guidelines` `karpathy-llm-wiki-method` |
| 单技能分类(6) | `jupyter-live-kernel`(data-science) `abtop`(devtools) `email-inbox-triage`(email) `github-issue-to-pr`(github) `obsidian`(note-taking) `godmode`(red-teaming) |
| 独立技能(12) | `aihot` `hermes-desktop-plugins` `hermes-self-upgrade` `hermes-themes` `kami` `netease-music-assistant` `netease-music-cli` `ob-vault-patch-and-amend-recipes` `okx-price` `quarkclouddrive` `skill-manager` `yuanbao` |

---

## 四、源 2 — obra/superpowers 官方技能(15)

上游:<https://github.com/obra/superpowers> · License:MIT

| # | Skill | 功能 | hash 锁定 |
|---|---|---|---|
| 1 | `brainstorming` | 头脑风暴 / 点子生成 | ✅ |
| 2 | `dispatching-parallel-agents` | 并行 Agent 分发 | ✅ |
| 3 | `executing-plans` | 执行计划 | ✅ |
| 4 | `finishing-a-development-branch` | 完成开发分支 | ✅ |
| 5 | `receiving-code-review` | 接收代码审查 | ✅ |
| 6 | `requesting-code-review` | 请求代码审查 | ✅ |
| 7 | `subagent-driven-development` | 子智能体驱动开发 | ✅ |
| 8 | `systematic-debugging` | 系统化调试 | ✅ |
| 9 | `test-driven-development` | 测试驱动开发 | ✅ |
| 10 | `using-git-worktrees` | 使用 Git Worktrees | ✅ |
| 11 | `using-superpowers` | 使用 Superpowers 系列(元技能) | ✅ |
| 12 | `verification-before-completion` | 完成前验证 | ✅ |
| 13 | `writing-plans` | 写计划 | ✅ |
| 14 | `writing-skills` | 写 Skill 元工具 | ✅ |
| +1 | `diagnosing-superpowers` | 诊断 Superpowers 自身 | — |

> **14 个 hash 锁定**来自 ob-vault 的 `skills-lock.json` —— 每次改动都算 hash,变了就知道被篡改。这是我见过的**最朴素但最有效的供应链安全做法**。
>
> 其中 4 个已装进 Hermes:`requesting-code-review` / `subagent-driven-development` / `systematic-debugging` / `test-driven-development`。

### 值得单独一说的:`systematic-debugging`

四阶段 SOP,强制 Agent 按顺序走:

```
现象 → 证据 → 假设 → 验证 → 修复
```

1. **调查根因** —— 读报错、稳定复现、检查近期变更
2. **分析模式** —— 找正常案例对比,查配置/依赖/环境差异
3. **提出并验证假设** —— **一次只提一个**,最小改动验证;不成立就回证据重新分析
4. **修复并验证** —— 先写能复现的测试,再修根因

**核心不是「AI 一眼看穿」,而是「流程不许它跳过证据」** —— 这才是能根治「改一下试试」式修复的东西。

---

## 五、源 3 — ob-vault 引用的 39 个上游仓库(4,450 个技能文件)

我扫了 ob-vault 全部 **1,800 篇** Markdown,按 GitHub URL 频次提取出 **136 个**技能类仓库,收录了其中引用最密集的 **39 个**。

| 仓库 | ob-vault 提及 | 收录 SKILL.md |
|---|---|---|
| [`ComposioHQ/awesome-claude-skills`](https://github.com/ComposioHQ/awesome-claude-skills) | 114 | 864 |
| [`ComposioHQ/awesome-codex-skills`](https://github.com/ComposioHQ/awesome-codex-skills) | 11 | 880 |
| [`alirezarezvani/claude-skills`](https://github.com/alirezarezvani/claude-skills) | 16 | 465 |
| [`K-Dense-AI/scientific-agent-skills`](https://github.com/K-Dense-AI/scientific-agent-skills) | 63 | 177 |
| [`K-Dense-AI/claude-scientific-skills`](https://github.com/K-Dense-AI/claude-scientific-skills) | 19 | 177 |
| [`google/skills`](https://github.com/google/skills) | 17 | 180 |
| [`dotnet/skills`](https://github.com/dotnet/skills) | 57 | 113 |
| [`tech-leads-club/agent-skills`](https://github.com/tech-leads-club/agent-skills) | 14 | 94 |
| [`zhaoxuya520/reverse-skill`](https://github.com/zhaoxuya520/reverse-skill) | 20 | 89 |
| [`Jeffallan/claude-skills`](https://github.com/Jeffallan/claude-skills) | 15 | 67 |
| [`Imbad0202/academic-research-skills`](https://github.com/Imbad0202/academic-research-skills) | 67 | 5 |
| [`Yuan1z0825/nature-skills`](https://github.com/Yuan1z0825/nature-skills) | 47 | 23 |
| [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) | 74 | 25 |
| [`anthropics/skills`](https://github.com/anthropics/skills) | **144** ⭐ | 20 |
| [`openai/skills`](https://github.com/openai/skills) | 46 | 44 |
| [`huggingface/skills`](https://github.com/huggingface/skills) | 25 | 26 |
| [`microsoft/power-platform-skills`](https://github.com/microsoft/power-platform-skills) | 11 | 133 |
| [`MiniMax-AI/skills`](https://github.com/MiniMax-AI/skills) | 11 | 23 |
| [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills) | 65 | 52 |
| [`mukul975/Anthropic-Cybersecurity-Skills`](https://github.com/mukul975/Anthropic-Cybersecurity-Skills) | 58 | 818 |
| …另 20 个 | | |

### 5.1 特别收录:Obsidian 生态

来自 ob-vault `00_Inbox/AI/OB skills.md` 的「Obsidian 必装 Skills」清单 —— 全部到位:

| Skill | 作者 / 仓库 | 目录 |
|---|---|---|
| `defuddle` | kepano/obsidian-skills | `ob-vault-referenced/kepano__obsidian-skills/` |
| `obsidian-cli` | kepano/obsidian-skills | 同上 |
| `obsidian-bases` | kepano/obsidian-skills | 同上 |
| `obsidian-markdown` | kepano/obsidian-skills | 同上 |
| `json-canvas` | kepano/obsidian-skills | 同上 |
| `knap` | kepano/obsidian-skills | 同上 |
| `obsidian-canvas-creator` | axtonliu/axton-obsidian-visual-skills | `ob-vault-referenced/axtonliu__axton-obsidian-visual-skills/` |
| `mermaid-visualizer` | axtonliu/axton-obsidian-visual-skills | 同上 |
| `excalidraw-diagram` | axtonliu/axton-obsidian-visual-skills | 同上 |
| `tutor` / `tutor-setup` | RoundTable02/tutor-skills | `ob-vault-referenced/RoundTable02__tutor-skills/` |
| `scholar-skill`(zh-CN/en) | EESJGong/scholar-skill | `ob-vault-referenced/EESJGong__scholar-skill/` |
| `obsidian` | openclaw/openclaw | `ob-vault-referenced/openclaw__openclaw/` |

> `defuddle` 特别值得点名 —— 网页正文清洗器,自动剔掉导航条/侧边栏/广告,转成干净 Markdown,**直接省 AI 调用的 token**。用 `npx skills add kepano/obsidian-skills` 就能装。

### 5.2 一个没能收录的

| 仓库 | 原因 |
|---|---|
| `microsoft/SkillOp` | 私有仓库或已删除,`git clone` 报 `could not read Username` |

已在 `ob-vault-referenced/microsoft__SkillOp/NOTE.md` 留占位说明,附手动补入命令。

> 另外 `sickn33/antigravity-awesome-skills`、`VoltAgent/awesome-openclaw-skills` 本身不含 SKILL.md,但含**数百条技能链接目录** —— 作为索引参考保留。

---

## 六、怎么用

### 6.1 从本仓库装到 Hermes

```bash
# 单个技能
hermes skills install <path/to/SKILL.md>

# 或直接复制
cp -R hermes-skills/<分类>/<技能名> ~/.hermes/skills/<分类>/

# obra/superpowers 官方安装(带 hash 锁定)
npx skills add obra/superpowers
```

### 6.2 查技能

直接看 `INDEX.md` —— 机器可读,4,581 行,每行含**分类 / 技能名 / description / 路径**。搜关键词秒出。

### 6.3 保持同步

```bash
cd ob-vault-referenced
for d in */; do
  repo=$(echo "$d" | tr '_' '/')
  git -C "$d" pull --ff-only 2>/dev/null
done

python3 build_index.py    # 重建索引
```

---

## 七、几个值得学的设计决策

### 7.1 「快照」而非「fork」

`ob-vault-referenced/` 下每个目录**保留上游的 `README.md` / `LICENSE` / `CHANGELOG.md`,未做任何改写**。这是快照,不是 fork —— 你随时能回到上游,也能一眼看清哪些是原装的。

### 7.2 裁剪有明确边界

| 类别 | 处理 | 理由 |
|---|---|---|
| 二进制资产(图片/字体/音视频) | 删除 | 不含技能逻辑,只占体积(609 MB → 452 MB) |
| `node_modules/` `vendor/` | 删除 | 依赖产物,可重建 |
| `test/` `fixtures/` | 删除 | 测试数据,非技能内容 |
| lock 文件 | 删除 | 可重建 |
| `.git/` | 删除 | 快照非 fork |
| **`README` `LICENSE` `CHANGELOG`** | **保留** | **溯源与授权依据** |

### 7.3 hash 锁定是最朴素的供应链安全

`skills-lock.json` 存每个 superpowers 技能的 sha256。任何一次改动都会让 hash 对不上 —— **不需要签名、不需要证书,一行 hash 就能发现「这个技能被偷偷改了」**。

### 7.4 references 的数量 = 经验沉淀的厚度

`wechat-curl-archive` 54 个 references,每一个都是「踩过一次坑,写成文件,下次不用再踩」。**这就是 skill 生态真正的复利来源** —— 不是提示词写得多好,而是踩过的坑有没有被结构化存下来。

---

## 八、验证

| 检查项 | 结果 |
|---|---|
| 116 个 Hermes 技能逐字节 sha256 比对 | ✅ **零漂移** |
| 全量重新 clone 验证 | ✅ 4,581 个 SKILL.md 全部落地 |
| INDEX.md 数据行 | ✅ 4,581 行,**0 个断链路径** |
| local vs remote SHA | ✅ `c15a031` = `c15a031` |

---

## 九、延伸阅读

| 资源 | 位置 |
|---|---|
| ob-vault 主索引(三源全景) | `~/workspace/memory/ob-vault/02_Research/Skills/README.md` |
| hash 锁定文件 | `~/workspace/memory/ob-vault/skills-lock.json` |
| Obsidian 必装清单 | `~/workspace/memory/ob-vault/00_Inbox/AI/OB skills.md` |
| Skill 机制源码剖析 | ob-vault `02_Research/Harness-Engineering/` 30+ 篇 |
| 本仓库 | <https://github.com/cx0110/skills-new> |

---

*2026-10-24 · 归档于 ob-vault + 飞书知识库*
