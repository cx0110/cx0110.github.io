---
title: "Skills New — 4,581 个 Agent 技能的三源总库"
date: 2026-10-24
draft: false
weight: 1
summary: "把本地已装的 116 个 Hermes 技能 + obra/superpowers 官方 15 个 + ob-vault 笔记提到的 39 个上游仓库(4,450 个技能文件)汇编成一个可检索、可版本化的 GitHub 仓库"
categories: ["🤖 AI Agent", "工具", "开源项目", "知识管理"]
external_link: ""
tags: ["Skills", "Agent-Skills", "SKILL-md", "Hermes", "知识管理", "开源项目"]
---
---

# Skills New — 4,581 个 Agent 技能的三源总库

> **作者**:cx0110(自建)
> **链接**:https://github.com/cx0110/skills-new
> **License**:MIT(自建部分)+ 三方快照保留各自原 license
> **类型**:自建 · 技能资产库 / 知识管理

## 一句话定位

**把「本地已装」「笔记里提到但没装」「hash 锁定的官方」三源技能汇编成一份可检索、可版本化、可同步的技能总库。**

## 解决什么问题

Agent Skill 生态的现状是**散的**:

| 状态 | 在哪 | 问题 |
|---|---|---|
| 已装能用 | `~/.hermes/skills/` | 本地目录,搜不到、传不了、没版本 |
| 看过没装 | ob-vault 笔记里 136 个 GitHub URL | 只剩链接,内容得现拉 |
| 官方锁定 | `obra/superpowers` 15 个 | 有 hash 锁,但和上面两坨不在一起 |

三份清单互不相通,想找「有没有装过某个 skill」得同时查三个地方。

## 三源结构

```
skills-new/
├── hermes-skills/          ← 源 1:本地已安装技能(116)
├── obra-superpowers/       ← 源 2:官方技能(15,14 个 hash 锁定)
├── ob-vault-referenced/    ← 源 3:ob-vault 引用仓库(39 仓库 / 4,450 文件)
├── INDEX.md                ← 机器可读全量清单(4,581 行)
├── PROVENANCE.md           ← 来源 / 裁剪 / hash 锁定表
└── build_index.py          ← 索引生成器
```

## 规模

| 指标 | 值 |
|---|---|
| 跟踪文件 | 33,602 |
| **SKILL.md** | **4,581** |
| 体积 | 452 MB |
| Hermes 技能 | 116(22 分类) |
| obra/superpowers | 15 |
| ob-vault 引用 | 39 仓库 / 4,450 文件 |
| ob-vault 全库扫描出的技能类仓库 | 136(取提及频次前 39) |

## 顺带讲清 SKILL.md 那个「S 规范」

仓库里的技能本质是 **Anthropic Agent Skills 规范** —— 三层渐进式披露:

| 层 | 内容 | 进上下文时机 | token 量级 |
|---|---|---|---|
| **L1** | `SKILL.md` frontmatter | Agent 启动 | ~50/技能 |
| **L2** | `SKILL.md` 正文 | 技能被命中 | ~500-3000 |
| **L3** | `references/` / `scripts/` | 正文显式引用 | 按需 |

**description 是检索器,不是简介** —— 它决定 Agent 要不要加载这个技能,必须写清触发条件。

实测本地 116 个技能:**67 个是完整三件套**(有 references 或 scripts),**49 个是单文件**。references 数量 = 经验沉淀厚度 —— `wechat-curl-archive` 有 54 个,每一个都是踩过一次坑写成的文件。

## 亮点 & 局限

| 亮点 | 局限 |
|---|---|
| 一份清单覆盖「已装 + 未装 + 官方」三态 | 上游仓库快照是 2026-10-24 的状态,不会自动跟新 |
| `INDEX.md` 4,581 行机器可读,搜关键词秒出 | 452 MB,clone 要等 |
| 每个技能逐字节 sha256 校验,零漂移 | 三方快照**裁剪了二进制资产**(图片/字体/vendor/测试夹具) |
| hash 锁定 = 最朴素的供应链安全 | `microsoft/SkillOp` 私有,收不进来 |
| 快照非 fork,上游 README/LICENSE 全保留 | awesome-list 类仓库本身不含 SKILL.md,只作索引 |

## 怎么用

```bash
# 查技能(推荐先看 INDEX.md)
grep -r "关键词" INDEX.md

# 装单个技能
cp -R hermes-skills/<分类>/<技能名> ~/.hermes/skills/<分类>/

# 官方安装(带 hash 锁定)
npx skills add obra/superpowers
```

## 关联

- 博客文章:[Skills 新仓库 — 4581 个 Agent 技能的三源总库](https://cx0110.github.io/post/2026-10-24-skills-new-repo/)
- 飞书:RePig 知识库 → 📄 Skills → 同名文档
- ob-vault:`02_Research/Skills/`(索引)+ `2026-10-24_skills-new仓库_4581个技能三源总库.md`
- 兄弟项目:[Pipelock](https://github.com/luckyPipewrench/pipelock)(AI Agent 防火墙)

---

> 📝 本卡片基于 [ob-vault](https://github.com/cx0110/ob-vault) `02_Research/Skills/` 归档整理而成
