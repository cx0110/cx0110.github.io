---
title: "🔥 Trending"
subtitle: "最新技术热点与动态"
type: landing

sections:
  - block: collection
    content:
      title: 📈 每日技术热点
      subtitle: 'GitHub Trending & 技术动态汇总'
      text: ''
      count: 15
      filters:
        folders:
          - post
        exclude_featured: false
        exclude_future: false
        exclude_past: false
      sort_by: 'Date'
      sort_ascending: false
    design:
      view: card
      columns: '1'
      spacing:
        padding: ['1rem', 0, '2rem', 0]
  
  - block: collection
    content:
      title: 📚 技术博客
      subtitle: '深度技术文章与教程'
      text: ''
      count: 10
      filters:
        folders:
          - blog
        exclude_featured: false
        exclude_future: false
        exclude_past: false
      sort_by: 'Date'
      sort_ascending: false
    design:
      view: card
      columns: '1'
      spacing:
        padding: ['1rem', 0, '3rem', 0]
---