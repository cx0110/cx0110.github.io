# 1ch0's Blog

基于 [Hugo Blox Builder](https://github.com/HugoBlox/hugo-blox-builder) 构建的个人技术博客。

## 📖 博客简介

这是一个专注于技术分享的个人博客，主要内容包括：

- 🔥 **每日技术热点** - GitHub Trending 与技术动态汇总
- 🤖 **AI & Machine Learning** - RAG、LangGraph、MCP等AI技术
- 🐹 **Go语言** - Go编程技巧、框架使用、性能优化
- 🐍 **Python** - Python开发实践、工具使用
- 🐧 **Linux** - 系统管理、运维技巧
- ☁️ **云原生** - Docker、Kubernetes、微服务
- 🦀 **Rust** - Rust语言学习与实践
- 📝 **技术笔记** - 开发经验总结

## 🚀 快速开始

### 本地开发

```bash
# 克隆仓库
git clone https://github.com/cx0110/cx0110.github.io.git
cd cx0110.github.io

# 安装依赖
hugo mod tidy

# 启动开发服务器
hugo server --disableFastRender

# 访问 http://localhost:1313
```

### 构建部署

```bash
# 构建静态文件
hugo --minify

# 文件输出到 public/ 目录
```

## ✍️ 博客编写指南

### 创建新文章

```bash
# 创建技术博客文章
hugo new content/blog/golang/new-post.md

# 创建每日热点
hugo new content/post/$(date +%Y-%m-%d)-daily-news/index.md
```

### 文章Front Matter模板

```yaml
---
title: "文章标题"
subtitle: "副标题（可选）"
summary: "文章摘要"
authors:
  - admin
tags:
  - 标签1
  - 标签2
categories:
  - 分类
date: 2025-12-24T09:00:00+08:00
lastmod: 2025-12-24T09:00:00+08:00
featured: false
draft: false
image:
  filename: "相关技术logo.svg"  # 可选：python-logo.svg, go-logo.png等
  focal_point: "Smart"
  preview_only: false
---
```

### 技术分类对应图标

| 分类 | 图标文件 | 用途 |
|------|----------|------|
| AI & ML | `ai-logo.svg` | AI/机器学习相关文章 |
| Golang | `go-logo.png` | Go语言相关文章 |
| Python | `python-logo.svg` | Python相关文章 |
| Linux | `linux-logo.svg` | Linux系统相关 |
| 云原生 | `kubernetes-logo.svg` | K8s/Docker相关 |
| Rust | `rust-logo.svg` | Rust语言相关 |
| 每日热点 | `trending-logo.svg` | GitHub Trending |
| 通用 | `blog-default.svg` | 默认博客图片 |

## 🛠️ 调试指南

### 常见问题

1. **构建缓慢**
   ```bash
   # 清理缓存
   hugo mod clean
   hugo mod tidy
   ```

2. **图片不显示**
   - 检查图片路径：`static/img/图片名`
   - 确认front matter中的filename正确

3. **文章不显示**
   - 检查`draft: false`
   - 确认日期格式正确
   - 检查文件路径和命名

4. **样式问题**
   ```bash
   # 重新构建CSS
   hugo server --disableFastRender --noHTTPCache
   ```

### 开发技巧

- 使用 `--disableFastRender` 确保完整重建
- 修改配置文件后需要重启服务器
- 使用 `hugo --verbose` 查看详细构建信息
- 图片优先使用SVG格式，体积小且清晰

### 目录结构

```
├── content/
│   ├── blog/           # 技术博客
│   │   ├── golang/     # Go语言文章
│   │   ├── python/     # Python文章
│   │   └── ...
│   ├── post/           # 每日热点
│   └── authors/        # 作者信息
├── static/
│   └── img/            # 图片资源
├── config/
│   └── _default/       # 配置文件
└── hugo-blox/          # 主题文件
```

## 📝 写作规范

- 文章标题使用中文，简洁明了
- 代码块指定语言类型以启用语法高亮
- 图片添加alt描述
- 链接使用有意义的锚文本
- 每日热点保持统一格式

## 🔗 相关链接

- [Hugo Blox Builder](https://github.com/HugoBlox/hugo-blox-builder) - 原始主题
- [Hugo Documentation](https://gohugo.io/documentation/) - Hugo官方文档
- [Markdown Guide](https://www.markdownguide.org/) - Markdown语法指南

---

⭐ 如果这个博客对你有帮助，欢迎给个Star！
