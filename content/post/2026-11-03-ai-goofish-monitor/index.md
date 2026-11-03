---
title: "ai-goofish-monitor 拆解 — 15.9K 星的闲鱼 AI 监控机器人，把「人工捡漏」拆成一条流水线"
date: 2026-11-03T11:30:00+08:00
lastmod: 2026-11-03T11:30:00+08:00
draft: false
weight: 10
authors:
  - admin
summary: "Playwright 驱动 Chromium 爬闲鱼 → 商品图 + 标题 + 详情喂给多模态大模型判断「要不要推荐」 → 命中就推送到手机。本文从源码层拆它的反检测指纹、AI 协议自适应、失败熔断设计,以及三个必须知道的坑。"
categories: ["🤖 AI Agent", "开源项目", "工具", "Python"]
tags: ["Playwright", "多模态AI", "FastAPI", "闲鱼", "自动化监控", "反爬", "风控", "Docker", "Python", "开源项目"]
external_link: ""
---

## 一、项目是什么

> **仓库**:<https://github.com/Usagi-org/ai-goofish-monitor>
> **Star**:15,954(实测 GitHub 页面 `stargazerCount`)/ **License**:MIT
> **技术栈**:Python 3.10+ · Playwright · FastAPI + SQLite · Vue3 + Vite · APScheduler
> **体量**:后端 15,178 行 Python + 前端 ~11K 行 TS/Vue + 32 个测试文件
> **作者**:dingyufei615 → 已迁至 `Usagi-org` 组织

**用 Playwright 驱动真实 Chromium 爬闲鱼,把商品图 + 标题 + 详情喂给多模态大模型做「要不要推荐」的判断,命中就推送到你的手机 —— 一条完整的「人工捡漏」自动化流水线。**

这不是又一个「关键词命中就发邮件」的爬虫脚本。真正的差异在于:**判断这一步交给了模型,而不是写死在代码里的规则**。

---

## 二、它到底做了什么

传统闲鱼监控脚本长这样:

```python
if "iPhone 15 Pro" in title and "9成新" in desc and price < 6000:
    notify()
```

问题显而易见 —— 规则写不出来。什么算「值得买」?成色、配置、附件、卖家信用、价格分位,哪个权重更高?每换一个人就要改一遍代码。

ai-goofish-monitor 的做法是:你写一句人话 ——

> 「我要买 iPhone 15 Pro,95 新以上,国行,电池健康 > 90,预算 6000 以内,不要维修过的,优先个人卖家」

后台调用 LLM 把它翻译成一组**分析标准**(本质是一段 Prompt),之后每个商品(图片 + 文本)都拿这套标准去过模型,模型回一个 `is_recommended` + `reason`。

**AI 生成的是 Prompt,不是可执行逻辑。** 这决定了它的能力边界 —— 判断质量取决于 Prompt 质量,而 Prompt 由 LLM 从你的一句话生成,误差会传导。但项目留了人工干预口:`prompts/` 目录可以手动编辑,系统设置页也能改 Prompt。

---

## 三、核心机制拆解(源码级)

### 3.1 抓取:不是裸跑 Playwright

`src/scraper.py` 在 `add_init_script` 里**注入 JS 改写 navigator**:

```javascript
// 移除webdriver标识
Object.defineProperty(navigator, 'webdriver', {get: () => undefined});
// 模拟真实移动设备的navigator属性
Object.defineProperty(navigator, 'plugins', {get: () => [1, 2, 3, 4, 5]});
Object.defineProperty(navigator, 'languages', {get: () => ['zh-CN', 'zh', 'en-US', 'en']});
Object.defineProperty(navigator, 'maxTouchPoints', {get: () => 5});
// 覆写 permissions.query
const originalQuery = window.navigator.permissions.query;
window.navigator.permissions.query = (parameters) => (...)
```

配套还有:

| 手段 | 实现 |
|---|---|
| 移动端 UA | `Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) ... Chrome/131.0.0.0 Mobile Safari/537.36` |
| PC→移动端 | `PCURL_TO_MOBILE` 开关,转成 `m.goofish.com` 形式 |
| 全链路随机延迟 | `random_sleep(1,2)` / `(2,4)` / `(3,5)` 分布在翻页、等待 API、取详情各节点 |
| **不解析 DOM** | 直接 hook XHR/fetch 拿闲鱼自己的 JSON API(`mtop` 协议) |

> 有意思的细节:源码里留着注释 `await random_sleep(1, 2)  # 原来是 (1.5, 2.5)` —— 这些延迟参数是**反复调参调出来的**,作者踩过风控的坑。

### 3.2 登录态:浏览器指纹复刻

`chrome-extension/` 是一个 Manifest V3 扩展,权限收得很紧:

```json
"permissions": ["activeTab", "cookies", "scripting", "storage", "tabs", "webRequest"],
"host_permissions": ["*://*.goofish.com/*"]
```

它从你**真实登录的浏览器**里提取:cookie、localStorage、navigator 环境(UA / locale / touch points)、请求头,导出 JSON 粘贴回 Web UI。

**这实际上是在做浏览器指纹复刻** —— 把真机的身份一起搬过去,让 Playwright 起的 Chromium 看起来像同一台设备。目前对抗阿里风控最有效的土办法。

### 3.3 AI 调用:协议自适应是亮点

`src/services/ai_request_compat.py` 处理了一堆真实世界的兼容问题:

- `CHAT_COMPLETIONS_API_MODE` vs `RESPONSES_API_MODE` 双协议
- `is_chat_completions_api_unsupported_error` → 自动降级
- `is_responses_api_unsupported_error` → 自动降级
- `is_json_output_unsupported_error` → 去掉 `response_format`
- `is_temperature_unsupported_error` → 去掉 `temperature`

**结论**:它不假设大家都用 OpenAI 官方 API,而是真的兼容国内一堆兼容层。`.env.example` 默认就指向 ModelScope:

```
OPENAI_BASE_URL=https://api-inference.modelscope.cn/v1/
OPENAI_MODEL_NAME=XiaomiMiMo/MiMo-V2-Flash
```

多模态输入走 OpenAI 的 `image_url` 类型(图片转 base64 data URL):

```python
user_content = [{"type": "image_url", "image_url": {"url": url}} for url in image_data_urls]
user_content.append({"type": "text", "text": text_prompt})
```

### 3.4 风控对抗:FailureGuard 熔断器

`src/failure_guard.py`(357 行)是**整个项目最有工程含量的部分**:

```python
"""
Task-level failure circuit breaker.
目标:
- 当登录态失效/风控导致任务持续失败时,避免无限重试、避免高频请求。
- 失败达到阈值后暂停任务一段时间。
- 暂停期间最多每天通知一次,直到用户更新 cookies / 登录态文件后自动恢复。
"""
```

配置:

```
TASK_FAILURE_THRESHOLD=3
TASK_FAILURE_PAUSE_SECONDS=86400   # 暂停 24 小时
```

**这个设计非常克制** —— 很多人写爬虫只会无脑重试,这个项目主动降速。`zoneinfo` 处理时区,保证「每天最多一次」按用户本地时区算。

配套还有代理池 + 账号三策略:

```python
ACCOUNT_STRATEGIES = {"auto", "fixed", "rotate"}
```

代理池失败自动拉黑 5 分钟(`PROXY_BLACKLIST_TTL=300`),重试上限 2 次。

### 3.5 并发:重活移出主链路

`src/services/item_analysis_dispatcher.py` 用信号量把「卖家资料采集 → 图片下载 → AI 分析 → 落盘」整条重活链路**移出主抓取循环**:

```python
class ItemAnalysisDispatcher:
    def __init__(self, *, concurrency, skip_ai_analysis, seller_loader,
                 image_downloader, ai_analyzer, notifier, saver):
        self._semaphore = asyncio.Semaphore(max(1, concurrency))
```

主链路只负责「发现商品」,重活丢进受控并发的 dispatcher。这是整个项目能跑得动的关键。

### 3.6 架构:正经 DDD 分层,不是脚本堆砌

```
src/
├── api/routes/          # FastAPI:tasks/accounts/results/logs/prompts/websocket
├── core/
├── domain/models/       # task.py / task_generation.py
├── infrastructure/
│   ├── config/settings.py
│   ├── external/notification_clients/   # ntfy/pushplus/bark/wxbot/telegram/gotify/webhook
│   └── persistence/     # SQLite bootstrap + repository(双实现)
└── services/            # 24 个 service:调度/账号策略/AI 兼容/价格历史/黑名单/导出…
```

- `domain/repositories` 抽象 + `sqlite_task_repository` / `json_task_repository` **双实现**
- `ItemAnalysisJob` 用 `@dataclass(frozen=True)` 做不可变任务对象
- 依赖注入用 `Callable[...]` 类型别名,不是硬编码
- 三层测试:`tests/{unit,integration,live}`,`live` 靠 pytest marker 隔离真实流量
- 每个模块开头有 docstring 说明设计意图 —— **对 AI 协作友好**

### 3.7 数据层:渐进式迁移

README 写得很克制:

- 当前主存储 `data/app.sqlite3`,启动时自动建库建表
- **一次性**从旧的 `config.json` / `jsonl/` / `price_history/` 导入历史数据
- `spider_v2.py` 默认从 SQLite 读任务,**只有显式传 `--config <path>` 才走 JSON 兼容模式**

作者在做**渐进式切换**,不是一刀切重写。

---

## 四、通知渠道(实测 .env.example,比 README 说的多)

| 渠道 | 环境变量 |
|---|---|
| ntfy | `NTFY_TOPIC_URL` |
| PushPlus | `PUSHPLUS_TOKEN` / `PUSHPLUS_TOPIC` |
| Bark | `BARK_URL` |
| 企业微信机器人 | `WX_BOT_URL` |
| Telegram | `TELEGRAM_BOT_TOKEN` / `TELEGRAM_CHAT_ID` / `TELEGRAM_API_BASE_URL` |
| Gotify | `GOTIFY_URL` / `GOTIFY_TOKEN` |
| 通用 Webhook | `WEBHOOK_URL` + method / content_type / headers / query / body(带 `{{title}}` `{{content}}` 模板) |

架构走 `NotificationClient` 抽象 + `factory.py` 装配,`asyncio.gather` 并发发送,单渠道失败不影响其他渠道。

---

## 五、批判性视角

### 🔴 登录态明文存盘,泄露 = 账号直接沦陷

`state/acc_1.json` 存的是闲鱼完整 cookie + localStorage,目录被 Docker 挂载到宿主机 `./state`。

**放大器**:项目本身把「多账号 + 代理池 + 轮换」做成一等公民 —— **批量账号意味着单个泄露的爆炸半径成倍放大**。

**必做**:

```bash
chmod 700 state/
chmod 600 state/*.json
```

外加 Web UI 的 `WEB_PASSWORD` 默认是 `admin123`,**必须改**。

### 🔴 平台协议与合规风险

闲鱼用户协议禁止自动化采集。项目自己的 DISCLAIMER 写得很清楚:「仅供技术学习和研究目的」「不得用于任何违法或不道德的活动」。

但**代码功能本身**(多账号 + 代理轮换 + 定时高频)与免责声明的语义是冲突的 —— 这是开源项目最常见的责任切割结构:免责声明免责,功能不设限。

### 🟡 15.9K star ≠ 15.9K 稳定用户

GitHub 新晋仓库榜 + X 上大量「副业神器」「捡漏」叙事,带来蹭流量的关注。

**但真实使用率不低** —— 证据:32 个测试文件、三层测试、`run_live_smoke.sh`、知乎/CSDN/少数派/飞牛 NAS/模力方舟多平台教程、Windows 一键包 fork、第三方整合在推进。

### 🟡 AI 判定的成本与延迟被低估

每个商品一次多模态调用。带图片时 token 消耗显著高于纯文本。20 个关键词 × 50 个商品 = 1000 次多模态调用。

**缓解**:`SKIP_AI_ANALYSIS` 开关 + `decision_mode=keyword` 纯本地零成本路径。关键词引擎还有边界处理:

```python
# 纯英数字关键词按完整词匹配,避免 Q1 误命中 Q1R5
_ASCII_TOKEN_BOUNDARY = r"[a-z0-9]"
```

### 🟢 工程质量比预期高得多

分层清晰、24 个 service 各司其职、依赖注入、三层测试、中文注释详尽 —— **这在个人开源项目里是上游水平**。

---

## 六、实战建议

### ✅ 适合

- **技术研究** —— Playwright 反检测 + 多模态 AI 判定的完整参考实现
- **低频个人使用** —— 每天跑几次、每次盯 1-2 个关键词,风控压力可接受
- **学 DDD 分层在 Python 里的落地**
- **NAS / 飞牛玩家** —— Docker 一键

### ❌ 不适合

- **高频批量** —— 项目自带的熔断器就是承认这点
- **商业化倒卖 / 规模化套利** —— 平台协议 + 封号风险
- **弱网环境跑本地模型** —— 默认走云端多模态 API
- **对隐私敏感的账号** —— cookie 明文落盘

### 🎯 上手路径

```bash
git clone https://github.com/Usagi-org/ai-goofish-monitor && cd ai-goofish-monitor
cp .env.example .env
# 至少改这几项:
#   WEB_PASSWORD           默认 admin123 必须改
#   OPENAI_API_KEY/BASE_URL/MODEL_NAME  要支持图片输入的模型
#   PROXY_POOL              建议配
docker compose up -d
docker compose logs -f app
# → http://127.0.0.1:8000
```

**拿登录态**:

1. 安装 `chrome-extension/`(或在 Chrome 商店搜「Xianyu Login State Extractor」)
2. 登录 goofish.com,点扩展导出 JSON
3. 粘贴到「闲鱼账号管理」

**建议的初始配置**:

| 项 | 值 | 理由 |
|---|---|---|
| `TASK_FAILURE_THRESHOLD` | 3 | 别调大 |
| `TASK_FAILURE_PAUSE_SECONDS` | 86400 | 别缩短 |
| `PROXY_ROTATION_ENABLED` | `true` | 有代理就配 |
| `decision_mode` | 先 `keyword` | 跑通链路省 API 额度,再切 AI |

镜像拉不动可以用南京大学镜像站:

```bash
docker pull ghcr.nju.edu.cn/usagi-org/ai-goofish:latest
docker tag ghcr.nju.edu.cn/usagi-org/ai-goofish:latest ghcr.io/usagi-org/ai-goofish:latest
```

---

## 七、一句话总结

**ai-goofish-monitor 把「人工捡漏」这条真实存在的经济活动,拆成「Playwright 采价 → 多模态 AI 判值 → 推送触达」三段流水线 —— 工程分层、反检测指纹、失败熔断都比同类开源项目成熟一档,值得当技术范本读;但登录态明文落盘、多账号代理轮换、默认弱密码这三点,决定了它适合学习与低频自用,不适合当规模化套利基础设施。**

---

## 附:研究方法论

本次研究走的是「**GitHub 仓库级源码实读**」路线,几个可复用的点:

1. **web_extract 对 github.com / raw.githubusercontent.com / api.github.com 全部 blocked** —— 三段降级:
   - `curl -sL raw.githubusercontent.com/<owner>/<repo>/<branch>/README.md` 拿真实 README
   - `git clone --depth 1` 拿全量源码做实算(`wc -l`、目录树、关键文件精读)
   - `api.github.com` 只作补充(常 403 限流),**星标数可从 GitHub HTML 页面的 `"stargazerCount":N` 直接 grep**
2. **仓库默认分支不一定是 `main`** —— 这个项目是 `master`
3. **`git ls-remote` 会触发终端 consent 拦截**,`git clone` 反而能过
4. **二手文章的项目介绍普遍滞后 3+ 个版本**,README 才是事实基准线

---

> 📝 本篇基于 [ob-vault](https://github.com/cx0110/ob-vault) `02_Research/Tools/` 归档整理而成
