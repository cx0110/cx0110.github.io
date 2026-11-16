---
title: "HylaPocket 拆解 — 把 coding agent 的终端会话原封不动搬到手机"
date: 2026-11-14T09:00:00+08:00
lastmod: 2026-11-14T09:00:00+08:00
draft: false
weight: 9
authors:
  - admin
summary: "不是远程桌面,是终端自己的字节流用 Ghostty vt 库在手机上重画一遍。本文拆它的三个关键设计:配对码即钥匙的免端口方案、pane 尺寸接管与归还机制,以及为什么「会话寿命 > 客户端寿命」是核心。"
categories: ["🤖 AI Agent", "开源项目", "工具"]
tags: ["Hyla", "HylaPocket", "coding-agent", "终端", "Android", "tailcat", "Ghostty", "GPUI", "移动端开发", "开源项目"]
external_link: ""
---

> **一句话结论**：把 coding agent 的终端会话原封不动搬到手机屏幕上 —— 不是远程桌面，是真的终端。

作者每天上下班单程 1 小时地铁，用 paseo 控制家里的机器。最近基于 kero 打磨了自己的终端工具 **hyla**（接了飞书做数字分身，会话不中断，功能按需自己加），但一直缺一个手机端入口。

原因很具体：hyla 用的是 **mygo** 这个 UI 框架，走 GPUI 绘制，性能好，但还没有手机端支持（作者说未来可能支持）。于是参考 rexpocket 实现了 **hylapocket** —— 现在终于能在手机上卸载 paseo 了。

## 一、它是什么

**Hyla 是给 coding agent 用的终端**，会话活在后台的 hylad 里，关了窗口也不结束。

**HylaPocket 就是它的 Android 客户端**：手机上列出这台机器所有的会话、每个会话里的 pane，点进去就能看、能打字。

> Rex 那边有个 rexpocket，Hyla 这边就是 HylaPocket。思路一样，各做各的 —— 或者更准确地说，HylaPocket 是参考 rexpocket，让 AI 帮忙生成的。

## 二、三件让人顺手的事

### 1. 不用开端口，也不用 VPN

手机连的是 hylad 的 **tailcat 中继**。主机上会生成 tailcat 的配对码和二维码，手机扫一下就配好了。

那个二维码里的 **pair code 本身就是地址加密码** —— 绕过公网、绕过路由器，也不用注册账号。局域网里也可以直接走：

```
tcp://192.168.x.x:7473?token=…
```

适合同一个 Wi-Fi 下自己用。

> ⚠️ **pair code 等于这机器的钥匙**：拿到它的人能进你所有会话。泄露了重新生成换一个。

### 2. 它是终端，不是远程桌面

这点差别很大：

- **远程桌面** = 把桌面上被压缩过的画面推给你 → 字体糊、点击飘
- **HylaPocket** = 收到的是终端自己的**字节流**，手机上用 Ghostty 的 vt 库（编成 `libghostty_jni.so`）重新画一遍

颜色、宽字符、光标形状跟桌面一模一样。键行上有 Esc、Tab、Ctrl、Alt 和方向键，**Ctrl+C 不会因为手机没有实体键盘就按不出来**。

> 细节：屏幕上那行 `Build · 开发 · routing group · 28m 23s` 是 agent 报给终端的进度，桌面和手机看到的是同一份。

### 3. 尺寸会还回去

一个 pane 只有一个尺寸。手机打开某个 pane 时，它先把这个 pane **接管过来**，按手机屏幕重排（pane 里的程序以为自己在四十来列的窗口里）。

你回到桌前敲一下键盘，桌面就把尺寸收回来。

最近还补了一个洞：以前手机关掉、或者切到别的会话，桌面那个窗口会一直卡在手机宽度 —— 现在离开就自动恢复。

## 三、上手

**第一步**：在电脑上安装 hyla 终端工具 → <https://github.com/smallnest/hyla/releases>
下载完毕后，在设置中开启 tailcat 监听，它会给你一个配对码。

**第二步**：安装 hylapocket → <https://github.com/smallnest/hyla-pocket/releases/>
登录的时候扫描这个二维码。

然后两边就可以同步了。

## 四、说到最后

它解决的是**「人不在电脑前」那段时间的焦虑**：

- 任务跑没跑完
- agent 有没有卡在等你确认
- 那行命令到底报了什么错

**边界要说清楚**：你要在手机上完整写代码、看 diff、改文件，它不合适 —— 那些还是留给桌面。

**目前只有 Android**。iOS 得看有没有人愿意折腾。

如果你也在 Hyla 里跑 agent，值得装一个：<https://github.com/smallnest/hyla-pocket>

---

## 🔗 跨主题关联

- **同作者姊妹篇**：本篇作者「鸟窝」在 Harness-Engineering 专题已有 2 篇（11-08 deepseek-superagent 实战、11-13 Home Repo 模式）—— 同为「把 agent 工作流从桌面延伸到别处」的主题序列
- **对位 11-13 Home Repo 模式**：Home Repo 解决「多仓库怎么跑 agent」，本篇解决「人不在电脑前怎么盯 agent」—— 一个管**空间**，一个管**时间**，都是同一件事的两种切面：让 agent 工作流不绑死在单一终端
- **对位 11-08 deepseek-superagent 实战**：DSH 的 daemon 常驻思路（agent 不随终端关闭而结束）与 hyla 的 hylad 后台会话是同一设计哲学 —— **会话寿命 > 客户端寿命**
- **对位 10-28 不同 Harness 的 Agent Loop 怎么做**：hyla 是另一个 harness 实现，pane 接管/尺寸归还机制是「终端即一等公民」的具体体现
- **反向对位 —— 本篇的 10 个开源项目清单里的 DSH Go**：同样是「Android + coding agent」，但 DSH Go 是 DeepSeek Harness 的移动端外壳，HylaPocket 是自己写的客户端；两篇一起读 = 同一需求的两种实现路径
