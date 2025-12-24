#!/bin/bash

# 批量修复图片配置脚本
set -e

echo "🔄 开始批量修复图片配置..."

# 定义图片映射
declare -A IMAGE_MAP
IMAGE_MAP["/img/go-logo.png"]="go-logo.png"
IMAGE_MAP["/img/default.png"]="blog-default.svg"
IMAGE_MAP["/img/docker-logo.png"]="docker-logo.png"
IMAGE_MAP["/img/rust-logo.png"]="rust-logo.svg"
IMAGE_MAP["/img/python-logo.svg"]="python-logo.svg"
IMAGE_MAP["/img/linux-logo.svg"]="linux-logo.svg"
IMAGE_MAP["/img/kubernetes-logo.svg"]="kubernetes-logo.svg"
IMAGE_MAP["/img/ai-logo.svg"]="ai-logo.svg"

# 查找所有使用caption格式的文件
echo "📝 查找需要修复的文件..."
files=$(grep -r "caption: /img/" content/ --include="*.md" -l)

for file in $files; do
    echo "修复文件: $file"
    
    # 读取当前的caption值
    caption_line=$(grep "caption: /img/" "$file")
    if [[ $caption_line =~ caption:\ (/img/[^[:space:]]+) ]]; then
        old_path="${BASH_REMATCH[1]}"
        
        # 查找对应的新文件名
        if [[ -n "${IMAGE_MAP[$old_path]}" ]]; then
            new_filename="${IMAGE_MAP[$old_path]}"
            echo "  $old_path -> $new_filename"
            
            # 替换整个image块
            sed -i '' '/^image:$/,/^[[:alpha:]]/ {
                /^image:$/ {
                    N
                    s/image:\n  caption: .*$/image:\
  filename: '"$new_filename"'\
  focal_point: Smart\
  preview_only: false/
                }
            }' "$file"
        else
            echo "  警告: 未找到 $old_path 的映射，使用默认图片"
            sed -i '' '/^image:$/,/^[[:alpha:]]/ {
                /^image:$/ {
                    N
                    s/image:\n  caption: .*$/image:\
  filename: blog-default.svg\
  focal_point: Smart\
  preview_only: false/
                }
            }' "$file"
        fi
    fi
done

echo "✅ 图片配置修复完成！"