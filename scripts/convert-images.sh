#!/bin/bash

# 批量图片处理脚本
set -e

echo "🔄 开始批量处理图片..."

# 1. 转换所有SVG为PNG
echo "📸 转换SVG图片为PNG..."
for svg in static/img/*.svg; do
    if [ -f "$svg" ]; then
        filename=$(basename "$svg" .svg)
        echo "转换: $svg -> static/img/${filename}.png"
        magick "$svg" "static/img/${filename}.png"
    fi
done

# 2. 复制所有PNG图片到assets/media目录
echo "📁 复制PNG图片到assets/media..."
mkdir -p assets/media
for png in static/img/*.png; do
    if [ -f "$png" ]; then
        filename=$(basename "$png")
        echo "复制: $png -> assets/media/$filename"
        cp "$png" "assets/media/$filename"
    fi
done

# 3. 复制其他格式图片到assets/media
echo "📁 复制其他图片到assets/media..."
for img in static/img/*.jpg static/img/*.jpeg static/img/*.gif; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        echo "复制: $img -> assets/media/$filename"
        cp "$img" "assets/media/$filename"
    fi
done

# 4. 删除SVG文件
echo "🗑️  清理SVG文件..."
for svg in static/img/*.svg; do
    if [ -f "$svg" ]; then
        echo "删除: $svg"
        rm "$svg"
    fi
done

# 5. 删除.missing文件
echo "🗑️  清理.missing文件..."
for missing in static/img/*.missing; do
    if [ -f "$missing" ]; then
        echo "删除: $missing"
        rm "$missing"
    fi
done

echo "✅ 图片处理完成！"
echo ""
echo "📊 处理结果："
echo "static/img/ 目录："
ls -la static/img/
echo ""
echo "assets/media/ 目录："
ls -la assets/media/