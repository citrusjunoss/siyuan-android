#!/bin/bash

# 构建 app.zip 脚本
# 用法: ./scripts/build-app-zip.sh [siyuan-path]

set -e

# 默认 SiYuan 项目路径
SIYUAN_PATH="${1:-../siyuan}"
ANDROID_PATH="$(pwd)"

echo "🚀 开始构建 app.zip..."
echo "📁 SiYuan 路径: $SIYUAN_PATH"
echo "📁 Android 路径: $ANDROID_PATH"

# 检查 SiYuan 项目是否存在
if [ ! -d "$SIYUAN_PATH" ]; then
    echo "❌ 错误: SiYuan 项目路径不存在: $SIYUAN_PATH"
    echo "💡 提示: 请克隆 SiYuan 项目到 $SIYUAN_PATH 或指定正确路径"
    echo "   git clone https://github.com/citrusjunoss/siyuan.git $SIYUAN_PATH"
    exit 1
fi

# 进入 SiYuan 项目目录
cd "$SIYUAN_PATH"

# 获取版本信息
SIYUAN_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "unknown")
echo "📦 SiYuan 版本: $SIYUAN_VERSION"

# 构建前端资源
echo "🔨 构建前端资源..."
cd app

# 检查是否有 pnpm
if ! command -v pnpm &> /dev/null; then
    echo "❌ 错误: pnpm 未安装"
    echo "💡 请先安装 pnpm: npm install -g pnpm@10.13.1"
    exit 1
fi

# 安装依赖并构建
pnpm install
pnpm run build

# 回到 SiYuan 根目录
cd ..

# 创建 app.zip
echo "📦 创建 app.zip..."
zip -r app.zip \
    app/appearance \
    app/changelogs \
    app/guide \
    app/stage

# 检查 zip 文件是否创建成功
if [ ! -f "app.zip" ]; then
    echo "❌ 错误: app.zip 创建失败"
    exit 1
fi

# 显示 zip 文件信息
echo "📋 app.zip 内容:"
unzip -l app.zip | head -20
echo "..."
echo "📊 总大小: $(du -h app.zip | cut -f1)"

# 复制到 Android 项目
echo "📋 复制到 Android 项目..."
cd "$ANDROID_PATH"
mkdir -p app/src/main/assets
cp "$SIYUAN_PATH/app.zip" app/src/main/assets/

echo "✅ 构建完成!"
echo "📁 app.zip 已复制到: app/src/main/assets/app.zip"
echo "🎯 SiYuan 版本: $SIYUAN_VERSION"

# 清理临时文件
rm -f "$SIYUAN_PATH/app.zip"

echo ""
echo "🔄 下一步:"
echo "  1. 测试构建: ./gradlew assembleDebug"
echo "  2. 提交更改: git add app/src/main/assets/app.zip && git commit -m 'chore: update app.zip to $SIYUAN_VERSION'"
echo "  3. 推送代码: git push"