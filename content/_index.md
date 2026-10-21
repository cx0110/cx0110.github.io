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

  - block: markdown
    id: topic-nav
    content:
      title: 📚 按专题浏览工具
      subtitle: '每个专题都有独立 collection 块 — 跨领域工具一目了然'
      text: |
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1.25rem; margin-top: 1rem;">
          <a href="/tools/" style="display: block; padding: 1.5rem; border-radius: 1rem; background: linear-gradient(135deg, #fafafa 0%, #f0f0f0 100%); border: 1px solid #e5e5e5; text-decoration: none; color: inherit; transition: all 0.3s ease;">
            <div style="font-size: 1.875rem; margin-bottom: 0.5rem;">🛠️</div>
            <div style="font-size: 1.125rem; font-weight: 600; margin-bottom: 0.25rem;">工具介绍</div>
            <div style="font-size: 0.875rem; color: #71717a;">我用过的开源工具 + 自研工具 + 项目收藏</div>
          </a>
          <a href="/ai-tools/" style="display: block; padding: 1.5rem; border-radius: 1rem; background: linear-gradient(135deg, #f5f3ff 0%, #ede9fe 100%); border: 1px solid #ddd6fe; text-decoration: none; color: inherit; transition: all 0.3s ease;">
            <div style="font-size: 1.875rem; margin-bottom: 0.5rem;">🤖</div>
            <div style="font-size: 1.125rem; font-weight: 600; margin-bottom: 0.25rem;">AI 工具</div>
            <div style="font-size: 0.875rem; color: #6b7280;">Agent 框架 / LLM 路由 / RAG / 安全 / 内容生成</div>
          </a>
          <a href="/golang-projects/" style="display: block; padding: 1.5rem; border-radius: 1rem; background: linear-gradient(135deg, #ecfeff 0%, #cffafe 100%); border: 1px solid #a5f3fc; text-decoration: none; color: inherit; transition: all 0.3s ease;">
            <div style="font-size: 1.875rem; margin-bottom: 0.5rem;">🐹</div>
            <div style="font-size: 1.125rem; font-weight: 600; margin-bottom: 0.25rem;">Golang 开源项目</div>
            <div style="font-size: 0.875rem; color: #6b7280;">Go 生态 — Agent 工具栈 / Web 框架 / RAG / 测试</div>
          </a>
          <a href="/open-source/" style="display: block; padding: 1.5rem; border-radius: 1rem; background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%); border: 1px solid #fed7aa; text-decoration: none; color: inherit; transition: all 0.3s ease;">
            <div style="font-size: 1.875rem; margin-bottom: 0.5rem;">📦</div>
            <div style="font-size: 1.125rem; font-weight: 600; margin-bottom: 0.25rem;">开源项目</div>
            <div style="font-size: 0.875rem; color: #6b7280;">AI / Go / Obsidian / 浏览器扩展 / 桌面应用</div>
          </a>
        </div>
    design:
      columns: '1'
      spacing:
        padding: ['1rem', 0, '4rem', 0]
---
