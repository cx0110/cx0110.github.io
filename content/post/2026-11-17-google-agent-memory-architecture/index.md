---
title: "谷歌 Agent 记忆参考架构 — 三层记忆分存储 + 读写分离,代码已开源"
date: 2026-11-16T09:00:00+08:00
lastmod: 2026-11-16T09:00:00+08:00
draft: false
weight: 10
authors:
  - admin
summary: "Google Cloud 公开的多模态 Agent 记忆参考架构 + 开源示范项目 FashionMind。核心是两条切分线:按数据性质拆三层存储(有编号时间戳状态变更→关系库 / 无固定表头偏好→向量库 / 原始音视频流→不存),按读写时机拆热路径与后台异步。本文逐条核验源码,并给出语音场景「150 词/分 × 2 轮次 = 6-16 秒冷场」的时延预算算法。"
categories: ["🤖 AI Agent", "架构"]
tags: ["Agent记忆", "记忆架构", "多模态Agent", "Memory-Bank", "pgvector", "Vertex-AI", "Google-ADK", "Gemini-Live", "读写分离", "语音Agent", "时延预算", "FashionMind", "Harness-Engineering"]
external_link: ""
---

> **一句话结论**：谷歌给了一套**面向生产环境的多模态 Agent 记忆参考架构** —— 核心不是算法,是两条切分线：**按数据性质拆三类存储**,**按读写时机拆热路径与后台异步**。开源示范项目 FashionMind 的代码可验证。

**讲师**：Annie Wang（Google Cloud Tech 工程师）
**课程**：Google Cloud Next 多模态 Agent 记忆架构专题
**开源仓库**：<https://github.com/cuppibla/fashionmind>（代码地址 <https://g.dev/ai/fashion-mind>）
**实测数据**（2026-11-17 克隆核验）：HEAD `c876a40` · 最后提交 **2026-04-21** `feat: optimize live voice conversation with AudioWorklet and session stability` · **Apache-2.0** · Python（FastAPI + Google ADK + Gemini Live）· 仓库含 `Real-Time-Recall-v2.pptx` 演讲稿、`architecture.mmd` / `interruption_handling.mmd` 等架构图源文件

## 一、传统方案的两个坑

### 坑 1：会话一断，上下文记忆就归零

视频开篇把大模型的会话上下文比作**电脑里的内存** —— 五分钟前说过的话模型能直接拿来用，响应非常自然。

> 但一旦这次对话结束，这块内存就会立刻释放。下一次用户重新走进系统时，面对的还是一个完全不认识自己的助手。

> **记忆工程的关键从来不是存下所有信息，而是决定哪些内容值得跨会话留下来。**

### 坑 2：向量库查不准精确事实

想到长期记忆，不少开发者的第一反应就是上向量数据库 —— 把聊天文本、购买清单、日程记录全部切片、算成向量，一股脑写进去。

视频在四分半钟处专门拆解了这个误区：**向量检索的强项是找意思相近的内容，它并不擅长核对一条确切的记录。**

> 当用户问「我周四买过那件外套吗」时，向量库返回的是相似描述最多的片段。它很容易把**心愿单里的同类衣服**、或者**上个月讨论过的款式**拿来充数。

**只要问题需要精确命中某一条记录，向量库的相似度匹配就会变成隐患。**

## 二、三类记忆数据分开存储

### 1. 有编号和日期的事实 → 关系数据库

**判断标准非常具体**：只要这件事带有**编号、时间戳、状态变更和增删改需求**，就属于结构化事实。

> 比如「周四晚上七点有客户聚餐」、「已经买过蓝色夹克」、「把西装加入心愿单」。

在谷歌的架构里，这类记录直接存入 **PostgreSQL / MySQL / Cloud SQL 的行列表格**。

用户提出调整时，Agent 通过 `add_to_wishlist` / `mark_purchased` 等工具**直接执行事务更新**；读取时也是**精确的条件过滤**，不会靠模糊检索去碰运气。

### 2. 动态偏好 → 向量库

另一类长期记忆是**没有固定表头的动态理解**：

> 「这个用户怕热」、「她喜欢极简风格胜过夸张设计」、「穿深色系会让她更有自信」。

这类信息很难提前建好字段，往往要经过多轮对话甚至多场会话才能看清轮廓。它们才适合进入 **pgvector / AlloyDB / Vertex AI Agent Engine Memory Bank**。

**开源仓库的 `memory_bank_config.py` 里，谷歌设定了 7 个提取主题来约束总结范围**（已逐条核验源码）：

| # | 主题 | 类型 | 说明 |
|---|---|---|---|
| 1 | `USER_PREFERENCES` | 托管 | 用户偏好 |
| 2 | `USER_PERSONAL_INFO` | 托管 | 个人信息 |
| 3 | `style_identity` | 自定义 | 穿衣风格认同 —— 核心风格身份与反复出现的选择，含偏好的颜色、剪裁、dress code，以及用户希望在重要场合呈现的样子 |
| 4 | `signature_items` | 自定义 | 标志性单品 —— 用户反复点名的配饰或风格标记（帽子、夹克、鞋、首饰等） |
| 5 | `comfort_constraints` | 自定义 | 舒适度限制 —— 面料不喜欢、分层穿着需求、温度敏感、活动限制等影响搭配建议的实际约束 |
| 6-7 | （另两个自定义主题） | 自定义 | 视觉特征 / 场合背景 |

> 值得注意的是：**这 7 个主题本身是「记忆的数据结构设计」** —— 它决定了系统最终能「记住」什么维度的用户。定制主题时用**自然语言描述 + label** 双字段，正是给 LLM 做语义锚点。
>
> 模型配置也在同一文件里：生成模型 `gemini-2.5-flash`、嵌入模型 `gemini-embedding-001`，均可用环境变量覆盖。

⚠️ **这套分层设计不绑定任何云厂商**：自己维护 pgvector 还是用托管 Memory Bank，核心逻辑都是**把规律性理解从精确事实里剥离出来**。

### 3. 音视频 → 只存提炼结果

多模态 Agent 还会遇到第三类数据：**摄像头每秒一到两帧画面** + **16 kHz 连续麦克风音频流**。

Annie Wang 在五分半钟处给出了非常明确的边界：

> **原始音视频流本身不是 Agent 记忆，真正要存下来的是从画面和声音里提炼出的结论。**

比如系统不需要永远保存用户穿戴时的每一帧像素，只需要抽出一句「她又戴了那顶黑色帽子」或「这场晚宴偏正式」写进语义记忆。至于原始视频流和音频波形要不要留底，那是**审计、回放或模型微调层面的独立存储决策**。

## 三、读写分离：避免卡顿语音流

### 1. 开场前并行读取两类记忆

存储边界划清后，下一步是**运行时怎么把两边记忆接回来**。谷歌把读取动作放在 **Agent 开口说第一句话之前**。

新会话启动时，后端**并行发起两次读取**：
- 一边从关系型数据库捞取**即将到来的日程和心愿单**
- 一边向语义记忆系统检索**用户的穿衣禁忌和风格偏好**

> 这样一来，Agent 从开口第一秒就同时握住了**确定性事实**与**概括性理解**。不需要让用户把尺寸、预算和喜恶重新交代一遍。

### 2. 事实当场写入，偏好留给后台总结

**当用户发出清晰指令**「把那件西装加入心愿单」→ Agent 必须**在当前对话回合立刻**调用工具写进数据库，因为用户期望马上得到已保存的确认。

**风格偏好则完全相反**：用户今天随口说一句「我觉得黄色挺好看」，并不代表他从此放弃了深色简约风，**立刻覆盖长期画像反而会让记忆变得杂乱**。

更重要的是**延迟代价**：

> 提炼偏好需要调大模型通读对话上下文，这在文本聊天里多等几秒或许影响不大，在全双工语音对话里却是致命停顿。

演讲稿的测算：**语音输出大约保持在每分钟 150 词的节奏**。只要插进一轮等待模型响应再由用户确认的工具往返，就会白白烧掉 **2 个语音轮次，带来 6 到 16 秒的尴尬冷场**。

**代码验证**（`backend/agent/agent.py`）：

```python
async def add_session_to_memory(callback_context):
    """After-agent callback: saves session to memory bank in background."""
    ...
    async def _save():
        for attempt in range(3):
            try:
                await svc.add_session_to_memory(session)
                return
            except Exception as e:
                # 指数退避重试
                if attempt < 2:
                    await asyncio.sleep(1 * (attempt + 1))
        logger.error(f"Memory save FAILED after 3 attempts: {session.id}")

    asyncio.create_task(_save())   # ← 真正的「后台异步」
```

挂在 ADK 的 `after_agent_callback=add_session_to_memory if USE_MEMORY_BANK else None`。每次交互后由 `gemini-2.5-flash` 在热路径之外静默提炼会话并写回 Memory Bank —— **保证前面语音流始终顺畅不断句**。

> ⭐ 附带发现：`_save()` 里有 **3 次重试 + 递增退避（1s → 2s）**。这是原文没提但值得抄的细节 —— 后台任务失败不该静默丢失，重试逻辑和热路径的可靠性要求不同。

## 四、开源代码里的三处工程取舍

对照演讲方案和 `cuppibla/fashionmind` 仓库最新代码，团队为了扛住真实网络环境下的延迟和断连，对最初设想做了三处明显取舍。

### 取舍 1：删掉推荐工具，改用正则匹配

最初方案想在模型说话时顺便触发一个 `recommend_products` 工具往前端推商品卡片，但现行代码**特意移除了这个工具**。

**源码证据**：

```python
# backend/agent/agent.py:54
# recommend_products is deliberately EXCLUDED — the backend now detects
# product mentions from the model's spoken output and pushes UI updates
```

```python
# backend/main.py:136
def _detect_products_in_text(text: str) -> list[dict]:
```

```python
# backend/main.py:171
# _extract_recommendations and _suppress_recommend_products_response are no
```

> `wardrobe_tools.py` 里 `recommend_products` 函数**仍然存在**（第 230 行），只是**不再注册给模型**。

**原因还是省去工具调用的往返回合**：后端在下行流函数里直接用正则匹配文本里的商品名称，话音刚说出口，前端卡片就已经同步亮起。

演讲稿给的目录大小经验线：

| 商品数 | 策略 |
|---|---|
| **< 100 件** | 直接全量放进上下文 |
| **100 – 500 件** | 只保留名称与价格 |
| **> 500 件** | 退回检索工具调用 |

项目说明补充：这套直接注入上下文的做法在**当前约 200 件商品附近会触及 token 成本上限**，且**单一会话期内不会动态刷新记忆**。

### 取舍 2：宁可晚几秒开麦，也要等记忆先读完

早期文档和演示图曾主打**零毫秒直接开麦**，再靠 `LiveRequestQueue` 在后台把记忆硬插进对话流。

现行 `main.py` 里，团队**特意延后了实时音频流起步**：

```python
# backend/main.py
timeout=8.0,      # Memory Bank 召回
...
user_context = await asyncio.wait_for(user_context_task, timeout=2.0)   # 数据库上下文
...
async def _startup_task():
    ...
    await _startup_task()   # 记忆就绪后才放开实时音频连接
```

**两个超时是分开的**：语义记忆召回 **8 秒**、数据库上下文查询 **2 秒**。等记忆准备妥当后再放开实时音频连接。

> ⚠️ **注意这和 README 的表述有出入**：README 仍写着「Both tasks start at `t=0ms`. The session is live immediately — audio flows before context injection even completes.」** —— 这是**文档滞后于代码**的典型案例，正好印证了原文「工程团队为了扛住真实网络环境对最初设想做了取舍」的说法。

### 取舍 3：对话状态暂放本地内存，避开远程延迟

```python
# backend/agent/services.py:63
# Always use InMemorySessionService — VertexAiSessionService calls append_event on every
session_service = InMemorySessionService()
```

因为在连续语音流下，**每次数据块都要往远程服务追加 `append_event` 记录**，不仅叠加延迟，长时间流中途一旦碰到 **OAuth 凭证刷新**还容易导致连接异常断开。

> 先保住当下这一通电话的稳定不断线，把跨会话记忆沉淀交给异步后台处理 —— 成了更务实的选择。

## 五、我的判断

**这套架构真正值得学的是「两条切分线」的思路本身**：

| 切分线 | 判据 | 产物 |
|---|---|---|
| **数据性质** | 有编号/时间戳/状态变更 → 关系库；无固定表头 → 向量库；原始流 → 不存 | 决定「存在哪」 |
| **读写时机** | 明确指令 → 热路径当场写；需归纳 → 后台异步提炼 | 决定「什么时候写」 |

**判据都很具体、可判定** —— 这比「我们把记忆分层了」这种空话有用得多。

**⭐ 最值得抄的一条：语音 Agent 的时延预算要用「轮次」而不是「毫秒」来算。**
原文的算法：语音输出 ~150 词/分钟 → 一次工具往返 = 2 个语音轮次 = **6–16 秒冷场**。这个换算让「该不该用工具调用」变成一个可算的决策，而不是拍脑袋。

**⚠️ 需要留意的三点**：

1. **它绑定的是 Google 的技术栈**（ADK + Gemini Live + Vertex Memory Bank + Cloud SQL）。但**分层逻辑本身可移植** —— 文章也明确说了这一点。移植时最容易丢的是「7 个记忆主题」这类**语义结构设计**，而那恰恰是最值钱的部分。
2. **README 与代码不一致**（见取舍 2）—— 读这类项目**必须读代码而不是读文档**。原文作者做对了这一点，这也是本文比原始课程更有价值的原因。
3. **FashionMind 的 commit 停在 2026-04-21**（HEAD `c876a40`）—— 说明这是个**教学示范项目而非活跃产品**。价值在架构范式，不在代码维护度。

**它和我之前归档的 9-19 那篇（60 位学者综述「别把向量检索当记忆」）是同一结论的两次相遇** —— 学术综述和工程实现指向了同一条分界线：**精确事实不该走语义检索**。

---

## 🔗 跨主题关联

- **⭐ 对位 09-19「Agent 记忆进入下半场」（斯坦福+Google 60 位学者）**：那篇是**学术综述**喊出「别把向量检索当记忆」，本篇是**Google 自己给的工程实现** —— 同一结论，一个给论证一个给代码。**本篇可以当那篇的「参考实现」来读**
- **⭐ 对位 11-13 Praxis「Super-agent 架构把智能体的记忆分了层」**：那篇主张用**关系 / 本体 / 现象**三层来承接记忆，本篇主张用**关系库 / 向量库 / 不存原始流**三层 —— **两套分层维度正交**：Praxis 分的是「记忆的认知结构」，谷歌分的是「记忆的存储介质」。**可以叠起来看**
- **对位 07-03 CoMe ContextMemory（无需向量库）**：同样是「向量库不是记忆的唯一答案」的路线，本篇给出了**更细的判据**（带编号/时间戳/状态变更 → 关系库）
- **对位 10-21 powercontext + PG + pgvector**：那篇把 OceanBase 的 work-handoff context 层落到 PG，跟本篇的 Cloud SQL 行列表格是同一类 substrate
- **对位 11-15 Scrapling / Astryx 等 5 个 GitHub 项目**：**本篇是同批里第一个「架构范式 > 代码质量」的例子** —— 和 ziwei-doushu 那篇（主动公布失败率）一样，**值得学的都是方法论纪律而非实现**
- **对位 11-14 Anthropic Sub-Agent 那篇**：那篇讲「按上下文边界拆 agent」，本篇讲「上下文边界里的东西该存哪」—— **拆分之后每个 agent 的记忆怎么落库**
- **⭐ 方法论对位（可直接抄）**：**「读代码而不是读文档」** —— 本篇作者正是因为读了代码才发现三处取舍、以及 README 与代码的出入。**这跟 ziwei-doushu 主动公布失败率是同一种诚实**
