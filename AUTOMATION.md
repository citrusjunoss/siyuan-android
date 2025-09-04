# SiYuan Android 自动化构建

本文档说明如何自动化构建和使用 SiYuan Android 应用的资源文件 (`app.zip`)。

## 🎯 新方案说明

**app.zip 不再提交到版本控制**，而是通过以下方式使用：

1. **GitHub Actions 构建** - 自动构建并发布到 Releases
2. **按需下载** - Android 构建时自动下载最新版本
3. **本地开发** - 使用脚本本地构建测试

## 📁 文件说明

### GitHub Actions 工作流

- **`build-app-zip.yml`** - 在 SiYuan 项目中构建 app.zip 并发布
- **`build-android.yml`** - Android 项目构建，自动下载最新 assets

### 脚本工具

- **`scripts/build-app-zip.sh`** - 本地构建脚本，用于开发和测试

## 🤖 自动化工作流

### 方案：构建 + 发布 + 下载

#### 1. SiYuan 项目自动构建 (`build-app-zip.yml`)

**触发时机**：
- 每天凌晨 2:00 自动运行
- 手动触发
- 打 tag 时自动构建

**工作流程**：
1. 检出 `citrusjunoss/siyuan` 项目
2. 构建前端资源 (`pnpm run build`)
3. 打包为 `app.zip`
4. 上传为 GitHub Artifact（保留30天）
5. 发布到 GitHub Releases (`latest-assets` tag)
6. 触发 Android 项目构建

#### 2. Android 项目自动构建 (`build-android.yml`)

**触发时机**：
- 收到 `assets-updated` 事件
- 手动触发（可指定下载地址）

**工作流程**：
1. 从 GitHub Releases 下载最新 `app.zip`
2. 放置到 `app/src/main/assets/`
3. 构建 Android APK
4. 上传 APK 到 Artifacts

## 🛠 本地开发

### 构建 app.zip

```bash
# 确保 SiYuan 项目在上级目录
./scripts/build-app-zip.sh

# 或指定 SiYuan 项目路径
./scripts/build-app-zip.sh /path/to/siyuan
```

### 测试 Android 构建

```bash
# 1. 构建 app.zip
./scripts/build-app-zip.sh

# 2. 复制到 assets 目录
mkdir -p app/src/main/assets
cp app.zip app/src/main/assets/

# 3. 构建 Android 应用
./gradlew assembleDebug
```

### 前置要求

- **Node.js** >= 20
- **pnpm** 10.13.1
- **Java** 17 (Android 构建)
- **SiYuan 项目** 需要在指定路径

## 🚀 使用场景

### 开发模式

1. **本地快速测试**：使用 `build-app-zip.sh` 脚本
2. **版本验证**：手动指定特定版本的 app.zip
3. **调试构建**：在本地验证资源文件正确性

### 生产模式

1. **自动更新**：CI/CD 自动下载最新 assets
2. **版本控制**：通过 Releases 管理不同版本的 assets
3. **分布式构建**：Android 构建不依赖本地 SiYuan 项目

## 📋 资源文件内容

### 来源（SiYuan 项目）

```
app/
├── appearance/          # 外观主题、图标、字体
├── changelogs/         # 版本更新日志  
├── guide/              # 用户指南文档
└── stage/              # 舞台相关文件
```

### 输出

- **构建产物**：`app.zip` (不提交到版本控制)
- **使用位置**：`app/src/main/assets/app.zip` (构建时)
- **发布位置**：GitHub Releases

## 🔧 配置说明

### 环境变量

无需特殊配置，使用默认的 `GITHUB_TOKEN`

### 权限要求

- **读取仓库**：下载源码和 releases
- **创建 releases**：发布 app.zip
- **触发工作流**：跨仓库事件通信

### 下载地址

- **最新版本**：`https://github.com/citrusjunoss/siyuan/releases/download/latest-assets/app.zip`
- **特定版本**：通过 GitHub Releases API 或手动指定

## 📊 监控和调试

### 查看构建状态

1. **SiYuan 项目**：
   - Actions: `build-app-zip.yml`
   - Releases: 查看 `latest-assets`

2. **Android 项目**：
   - Actions: `build-android.yml`
   - Artifacts: 下载构建的 APK

### 手动操作

```bash
# 手动下载最新 app.zip
curl -L -o app.zip https://github.com/citrusjunoss/siyuan/releases/download/latest-assets/app.zip

# 验证内容
unzip -l app.zip

# 使用指定版本
curl -L -o app.zip https://github.com/citrusjunoss/siyuan/releases/download/v3.2.1/app.zip
```

## ✅ 优势

1. **版本控制干净**：大文件不进入 Git 历史
2. **构建分离**：SiYuan 和 Android 项目独立构建
3. **按需更新**：可以选择使用特定版本的 assets
4. **缓存友好**：构建产物可重复使用
5. **存储优化**：通过 GitHub Releases 管理大文件

## 🔄 工作流程图

```
SiYuan 更新 → 自动构建 app.zip → 发布到 Releases → 触发 Android 构建 → 生成 APK
     ↓                ↓                    ↓                ↓              ↓
  代码变更          CI/CD构建            Release管理        自动下载        产物交付
```

这种方案既保持了自动化的便利性，又避免了在版本控制中存储大型二进制文件的问题。