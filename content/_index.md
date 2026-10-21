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
---
