# SiYuan Android 自动化构建

本文档说明 SiYuan Android 项目的自动化构建方案，实现监听 SiYuan 项目更新并自动构建 APK。

## 🎯 方案概述

**在 Android 项目中监听 SiYuan 项目更新，动态构建 app.zip 并打包 APK**

### 工作原理

1. **监听更新**：Android 项目定期检查 SiYuan 项目的提交变化
2. **构建资源**：发现更新时，克隆 SiYuan 项目并构建前端资源
3. **打包应用**：创建 app.zip，放入 assets 目录，构建 APK
4. **智能缓存**：记录上次构建的提交，避免重复构建

## 📁 文件说明

### GitHub Actions 工作流

- **`build-with-latest-siyuan.yml`** - 主工作流，监听 SiYuan 更新并构建 Android APK

### 脚本工具

- **`scripts/build-app-zip.sh`** - 本地开发脚本，用于手动构建测试

## 🤖 自动化工作流

### 工作流：`build-with-latest-siyuan.yml`

#### 触发条件

1. **定时检查**：每天凌晨 2:00 UTC 自动运行
2. **手动触发**：支持以下参数
   - `siyuan_ref`: 指定 SiYuan 的分支或标签（默认 `main`）
   - `force_build`: 强制构建，忽略变更检查（默认 `false`）

#### 工作流程

**Phase 1: 检查更新** (`check-siyuan-updates`)

1. 检出 Android 项目代码
2. 检出指定的 SiYuan 项目代码
3. 获取 SiYuan 版本和提交信息
4. 比较与上次构建的提交差异
5. 决定是否需要构建

**Phase 2: 构建应用** (`build-android`) - 仅在有更新时执行

1. 准备构建环境（Node.js, pnpm, Java）
2. 构建 SiYuan 前端资源 (`pnpm run build`)
3. 创建 `app.zip` 包含：
   - `app/appearance` - 外观主题、图标、字体
   - `app/changelogs` - 版本更新日志
   - `app/guide` - 用户指南文档
   - `app/stage` - 舞台相关文件
4. 将 `app.zip` 放入 Android assets 目录
5. 构建 Android APK (`./gradlew assembleDebug`)
6. 上传 APK 到 GitHub Artifacts
7. 更新构建记录，避免重复构建

### 智能更新检测

- **首次构建**：如果没有构建记录，执行构建
- **变更检测**：比较 `.github/last-siyuan-commit` 中记录的提交
- **强制构建**：手动触发时可选择忽略变更检查
- **构建记录**：每次成功构建后更新提交记录

## 🛠 本地开发

### 手动构建测试

```bash
# 1. 构建 app.zip（确保 SiYuan 项目在上级目录）
./scripts/build-app-zip.sh

# 2. 复制到 assets 目录进行测试
mkdir -p app/src/main/assets
cp app.zip app/src/main/assets/

# 3. 构建 Android 应用
./gradlew assembleDebug

# 4. 清理（可选）
rm app.zip app/src/main/assets/app.zip
```

### 指定 SiYuan 项目路径

```bash
# 如果 SiYuan 项目在其他位置
./scripts/build-app-zip.sh /path/to/siyuan
```

## 📊 监控和操作

### 查看构建状态

1. **访问 Actions 页面**：https://github.com/citrusjunoss/siyuan-android/actions
2. **选择工作流**：Build Android with Latest SiYuan Assets
3. **查看运行历史**：了解构建成功/失败情况

### 手动触发构建

1. 进入 Actions 页面
2. 选择 "Build Android with Latest SiYuan Assets"
3. 点击 "Run workflow"
4. 可选择：
   - **分支/标签**：指定要构建的 SiYuan 版本
   - **强制构建**：忽略变更检查，强制执行构建

### 下载构建产物

- **APK 文件**：在 Actions 运行页面的 Artifacts 区域下载
- **保留期限**：30 天
- **命名格式**：`siyuan-android-{version}`

## 🔧 配置说明

### 环境依赖

工作流使用 GitHub Actions 提供的环境：
- **操作系统**：Ubuntu Latest
- **Node.js**：版本 20
- **pnpm**：版本 10.13.1
- **Java**：Temurin JDK 17
- **Gradle**：通过 Gradle Wrapper

### 权限设置

使用默认的 `GITHUB_TOKEN`，具有以下权限：
- 读取和写入仓库内容
- 创建和上传 Artifacts
- 推送提交（更新构建记录）

### 资源配置

- **SiYuan 仓库**：`citrusjunoss/siyuan`
- **监听分支**：`main`（可通过手动触发指定其他分支）
- **构建缓存**：`.github/last-siyuan-commit` 文件记录

## 🎯 使用场景

### 自动化场景

1. **日常维护**：自动跟踪 SiYuan 项目更新
2. **版本发布**：SiYuan 更新后自动构建新版 Android 应用
3. **持续集成**：确保 Android 应用始终使用最新资源

### 手动操作场景

1. **特定版本测试**：手动指定 SiYuan 分支/标签进行构建
2. **强制重建**：当自动检测失效时强制执行构建
3. **本地开发**：使用脚本快速构建本地测试版本

## ✅ 方案优势

1. **单一项目管理**：所有自动化逻辑都在 Android 项目中
2. **智能增量构建**：只在 SiYuan 真正更新时才构建
3. **灵活触发方式**：支持定时、手动、强制等多种触发模式
4. **完整构建链**：从源码到 APK 的完整自动化流程
5. **版本控制友好**：app.zip 不进入版本控制，保持仓库整洁
6. **可追溯性**：记录每次构建对应的 SiYuan 版本和提交

## 🔄 工作流程图

```
定时触发/手动触发
        ↓
检查 SiYuan 项目更新
        ↓
[有更新] → 克隆 SiYuan 项目 → 构建前端资源 → 创建 app.zip
        ↓                              ↓
[无更新] → 跳过构建                     放入 Android assets
                                       ↓
                               构建 Android APK
                                       ↓
                               上传到 Artifacts
                                       ↓
                              更新构建记录
```

这个方案实现了你要求的架构：**Android 项目监听 SiYuan 更新，动态构建 app.zip 后打包 APK**，既保持了自动化又避免了跨项目的复杂配置。