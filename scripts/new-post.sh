#!/bin/bash

# 博客文章创建脚本
# 用法: ./scripts/new-post.sh [category] [title]

set -e

# 默认参数
CATEGORY=${1:-"blog"}
TITLE=${2:-"new-post"}
DATE=$(date +%Y-%m-%d)
DATETIME=$(date +%Y-%m-%dT%H:%M:%S+08:00)

# 清理标题，移除特殊字符
CLEAN_TITLE=$(echo "$TITLE" | sed 's/[^a-zA-Z0-9\u4e00-\u9fa5]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

if [ "$CATEGORY" = "trending" ]; then
    # 创建每日热点
    POST_DIR="content/post/${DATE}-daily-news"
    POST_FILE="${POST_DIR}/index.md"
    
    mkdir -p "$POST_DIR"
    
    cat > "$POST_FILE" << EOF
---
title: "🔥 每日技术热点 ${DATE}"
subtitle: "GitHub Trending & 技术动态"
summary: "今日热门开源项目与技术资讯汇总"
authors:
  - admin
tags:
  - GitHub
  - Trending
  - 技术热点
categories:
  - 每日热点
date: ${DATETIME}
lastmod: ${DATETIME}
featured: false
draft: false
image:
  filename: trending-logo.svg
  focal_point: Smart
  preview_only: false
---

## 📈 GitHub Trending

自动抓取 GitHub 官方热榜，由 AI 辅助生成中文摘要。

> 更新时间: ${DATE}

## 🔥 全球热榜 (General)

| 排名 | 项目 | Stars | 简介 |
| :--- | :--- | :--- | :--- |
| 1 | [项目链接](https://github.com/user/repo) | ⭐ | 项目简介 |

## 🐹 Go 语言热门

| 排名 | 项目 | Stars | 简介 |
| :--- | :--- | :--- | :--- |
| 1 | [项目链接](https://github.com/user/repo) | ⭐ | 项目简介 |

## 🐍 Python 热门

| 排名 | 项目 | Stars | 简介 |
| :--- | :--- | :--- | :--- |
| 1 | [项目链接](https://github.com/user/repo) | ⭐ | 项目简介 |

---

*本文由自动化脚本生成，内容来源于 GitHub Trending*
EOF

else
    # 创建技术博客
    POST_FILE="content/blog/${CATEGORY}/${CLEAN_TITLE}.md"
    
    # 根据分类选择默认图片
    case $CATEGORY in
        "golang")
            IMAGE="go-logo.png"
            ;;
        "python")
            IMAGE="python-logo.svg"
            ;;
        "linux")
            IMAGE="linux-logo.svg"
            ;;
        "rust")
            IMAGE="rust-logo.svg"
            ;;
        "cloud-native")
            IMAGE="kubernetes-logo.svg"
            ;;
        "ai")
            IMAGE="ai-logo.svg"
            ;;
        *)
            IMAGE="blog-default.svg"
            ;;
    esac
    
    mkdir -p "content/blog/${CATEGORY}"
    
    cat > "$POST_FILE" << EOF
---
title: "${TITLE}"
subtitle: ""
summary: ""
authors:
  - admin
tags:
  - ${CATEGORY}
categories:
  - 技术博客
date: ${DATETIME}
lastmod: ${DATETIME}
featured: false
draft: false
image:
  filename: ${IMAGE}
  focal_point: Smart
  preview_only: false
---

# ${TITLE}

## 简介

## 内容

## 总结

EOF

fi

echo "✅ 文章创建成功: $POST_FILE"
echo "📝 开始编辑: code $POST_FILE"