---
title: 'Home'
date: 2023-10-24
type: landing
sections:
  - block: resume-biography
    content:
      # The user's folder name in content/authors/
      username: admin
    design:
      spacing:
        padding: [0, 0, 0, 0]
      biography:
        style: 'text-align: justify; font-size: 0.8em;'
      # Avatar customization
      avatar:
        size: medium  # Options: small (150px), medium (200px, default), large (320px), xl (400px), xxl (500px)
        shape: circle # Options: circle (default), square, rounded
  - block: collection
    id: recent
    content:
      title: 📚 最新文章
      subtitle: '最新的技术热点和博客文章'
      text: ''
      count: 15
      filters:
        folders:
          - blog
          - post
        exclude_featured: false
        exclude_future: false
        exclude_past: false
      sort_by: 'Date'
      sort_ascending: false
    design:
      view: card
      columns: '2'
      spacing:
        padding: ['3rem', 0, '6rem', 0]

  - block: collection
    id: tools
    content:
      title: 🛠️ 工具介绍
      subtitle: '我用过的开源工具 + 自研工具 + 项目收藏 - 点击卡片查看详细介绍'
      text: '每个工具都附带核心定位 / 使用场景 / 亮点局限 / GitHub 链接。'
      count: 12
      filters:
        folders:
          - tools
        exclude_featured: false
        exclude_future: false
        exclude_past: false
      sort_by: 'Weight'
      sort_ascending: true
    design:
      view: card
      columns: '3'
      spacing:
        padding: ['2rem', 0, '4rem', 0]
  - block: collection
    id: ai-tools-teaser
    content:
      title: 🤖 AI 工具专题
      subtitle: 'Agent 框架 / LLM 路由 / RAG / 安全 / 内容生成'
      text: '按 tag=AI 聚合 — 包含我用过和重点收藏的 AI 工具'
      count: 12
      filters:
        tags: ["AI"]
      sort_by: 'Weight'
      sort_ascending: true
    design:
      view: card
      columns: '3'
      spacing:
        padding: ['1rem', 0, '2rem', 0]
  - block: collection
    id: golang-projects-teaser
    content:
      title: 🐹 Golang 开源项目
      subtitle: 'Go 生态 — Agent 工具栈 / Web 框架 / RAG / 测试 / 数据库驱动'
      text: '按 tag=Golang 聚合 — polarisxu 同公众号姊妹篇 + 我用过的 Go 库'
      count: 12
      filters:
        tags: ["Golang"]
      sort_by: 'Weight'
      sort_ascending: true
    design:
      view: card
      columns: '3'
      spacing:
        padding: ['1rem', 0, '2rem', 0]
  - block: collection
    id: open-source-teaser
    content:
      title: 📦 开源项目专题
      subtitle: '我用过的开源项目 — AI / Go / Obsidian / 浏览器扩展 / 桌面应用'
      text: '按 tag=开源项目 聚合 — 跨语言跨领域的开源工具收藏'
      count: 12
      filters:
        tags: ["开源项目"]
      sort_by: 'Weight'
      sort_ascending: true
    design:
      view: card
      columns: '3'
      spacing:
        padding: ['1rem', 0, '4rem', 0]
---
