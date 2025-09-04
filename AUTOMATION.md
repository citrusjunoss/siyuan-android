# SiYuan Android 自动化构建

本文档说明如何自动化构建和更新 SiYuan Android 应用的资源文件 (`app.zip`)。

## 📁 文件说明

### GitHub Actions 工作流

- **`.github/workflows/sync-assets.yml`** - 完整版工作流，支持 PR 模式
- **`.github/workflows/sync-assets-simple.yml`** - 简化版工作流，直接推送更新

### 脚本工具

- **`scripts/build-app-zip.sh`** - 本地构建脚本，用于手动构建和测试

## 🤖 自动化方案

### 方案一：定时同步（推荐）

工作流 `sync-assets-simple.yml` 会：

1. **触发时机**：
   - 每天凌晨 2:00 自动运行
   - 手动触发（在 GitHub Actions 页面）

2. **工作流程**：
   - 检出 SiYuan Android 项目
   - 检出 SiYuan 主项目最新代码
   - 构建前端资源 (`pnpm run build`)
   - 打包资源文件为 `app.zip`
   - 更新到 Android 项目的 `app/src/main/assets/`
   - 自动提交并推送更改

### 方案二：Pull Request 模式

工作流 `sync-assets.yml` 会创建 PR 而不是直接推送，适合需要代码审查的场景。

## 🛠 本地开发

### 手动构建 app.zip

```bash
# 确保 SiYuan 项目在上级目录
./scripts/build-app-zip.sh

# 或指定 SiYuan 项目路径
./scripts/build-app-zip.sh /path/to/siyuan
```

### 前置要求

1. **Node.js** >= 20
2. **pnpm** 10.13.1
3. **SiYuan 项目** 需要在 `../siyuan` 或指定路径

## 📋 工作流详情

### 输入文件（来自 SiYuan 主项目）

```
app/
├── appearance/          # 外观主题、图标、字体
├── changelogs/         # 版本更新日志
├── guide/              # 用户指南文档
└── stage/              # 舞台相关文件
```

### 输出文件

- `app/src/main/assets/app.zip` - Android 应用资源包

### 构建过程

1. **克隆项目** - 获取最新的 SiYuan 源码
2. **安装依赖** - `pnpm install` 在 `app/` 目录
3. **构建资源** - `pnpm run build` 编译前端资源
4. **打包文件** - 使用 `zip` 打包指定目录
5. **更新资源** - 复制到 Android 项目的 assets 目录
6. **提交更改** - 自动 commit 并 push

### 版本跟踪

- 提交信息包含 SiYuan 的版本标签
- 格式：`chore: update app.zip from SiYuan v3.2.1`

## 🔧 配置说明

### 环境要求

GitHub Actions 环境已包含所需工具：
- Ubuntu Latest
- Node.js 20
- pnpm 10.13.1
- Git

### 权限设置

使用默认的 `GITHUB_TOKEN`，具有：
- 读取仓库内容
- 推送到当前仓库
- 创建 Pull Request（如需要）

## 📊 监控和调试

### 查看构建状态

1. 访问 GitHub 仓库的 **Actions** 标签页
2. 查看最近的工作流运行状态
3. 点击具体运行查看详细日志

### 手动触发构建

1. 进入 **Actions** 页面
2. 选择对应的工作流
3. 点击 **Run workflow** 按钮

### 常见问题

1. **构建失败**：检查 SiYuan 项目是否有破坏性更改
2. **权限错误**：确认 GitHub Token 权限正确
3. **文件过大**：检查 app.zip 大小是否超出限制

## 🔄 更新策略

- **增量更新**：只在文件确实发生变化时才提交
- **版本追踪**：每次更新都会记录对应的 SiYuan 版本
- **自动化程度**：完全自动化，无需人工干预

## 🎯 使用场景

1. **日常维护**：自动跟上 SiYuan 主项目的更新
2. **版本发布**：确保 Android 版本使用最新资源
3. **开发测试**：本地快速构建最新资源包

这套自动化方案确保 SiYuan Android 应用始终使用最新的 UI 资源和文档，减少手动维护工作量。