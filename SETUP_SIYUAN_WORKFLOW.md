# 在 SiYuan 项目中设置构建工作流

由于跨仓库的限制，你需要在你的 SiYuan fork 中添加构建工作流。

## 📋 需要在 citrusjunoss/siyuan 中创建的文件

### 1. 创建工作流文件

在你的 SiYuan 项目中创建：`.github/workflows/build-app-zip.yml`

```yaml
name: Build app.zip

on:
  schedule:
    - cron: '0 2 * * *'  # 每天凌晨2点检查更新
  workflow_dispatch:
  push:
    tags:
      - 'v*'  # 当打标签时构建

jobs:
  build-app-zip:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout SiYuan project
        uses: actions/checkout@v4
          
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          
      - name: Setup pnpm
        uses: pnpm/action-setup@v3
        with:
          version: '10.13.1'
          
      - name: Get SiYuan version
        id: siyuan_version
        run: |
          VERSION=$(git describe --tags --abbrev=0 2>/dev/null || git rev-parse --short HEAD)
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          
      - name: Build SiYuan assets
        run: |
          cd app
          pnpm install
          pnpm run build
          
      - name: Create app.zip
        run: |
          zip -r app.zip \
            app/appearance \
            app/changelogs \
            app/guide \
            app/stage
            
      - name: Upload app.zip as artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-zip-${{ steps.siyuan_version.outputs.version }}
          path: app.zip
          retention-days: 30
          
      - name: Check if this is latest version
        id: check_latest
        run: |
          # 检查是否有新的 tag 或者是否是手动触发
          if [[ "${{ github.event_name }}" == "workflow_dispatch" ]] || [[ "${{ github.ref_type }}" == "tag" ]]; then
            echo "is_latest=true" >> $GITHUB_OUTPUT
          else
            echo "is_latest=false" >> $GITHUB_OUTPUT
          fi
          
      - name: Create/Update latest release
        if: steps.check_latest.outputs.is_latest == 'true'
        uses: softprops/action-gh-release@v1
        with:
          tag_name: latest-assets
          name: Latest SiYuan Assets
          body: |
            ## SiYuan Assets for Android
            
            **Version**: ${{ steps.siyuan_version.outputs.version }}
            **Built**: ${{ github.run_id }}
            **Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
            
            This release contains the latest app.zip file with:
            - 🎨 Appearance files (themes, icons, fonts)
            - 📝 Changelogs
            - 📚 Guide documentation  
            - 🎭 Stage files
            
            ## Usage
            
            Download \`app.zip\` and place it in your Android project at:
            \`\`\`
            app/src/main/assets/app.zip
            \`\`\`
            
            Or use in your build process to download programmatically.
          files: app.zip
          prerelease: false
          make_latest: true
```

## 🚀 设置步骤

### 在你的 SiYuan 项目中执行：

```bash
# 1. 克隆你的 SiYuan fork (如果还没有)
git clone https://github.com/citrusjunoss/siyuan.git
cd siyuan

# 2. 创建工作流目录
mkdir -p .github/workflows

# 3. 创建工作流文件
# 复制上面的 YAML 内容到 .github/workflows/build-app-zip.yml

# 4. 提交并推送
git add .github/workflows/build-app-zip.yml
git commit -m "feat: add GitHub Actions workflow to build app.zip for Android"
git push
```

## 🔧 配置说明

### 权限设置

工作流需要以下权限（默认已有）：
- `contents: read` - 读取仓库内容
- `actions: write` - 写入 Actions artifacts
- `packages: write` - 创建 releases

### 手动触发

1. 访问你的 SiYuan 项目的 Actions 页面
2. 选择 "Build app.zip" 工作流
3. 点击 "Run workflow"

### 验证设置

工作流设置成功后，你可以：

1. **查看 Actions**：https://github.com/citrusjunoss/siyuan/actions
2. **查看 Releases**：https://github.com/citrusjunoss/siyuan/releases
3. **下载测试**：
   ```bash
   curl -L -o test.zip https://github.com/citrusjunoss/siyuan/releases/download/latest-assets/app.zip
   ```

## 📋 注意事项

- 工作流会在每天凌晨2点自动运行
- 手动触发或打tag时会创建/更新 `latest-assets` release
- 构建产物保存30天，可在 Actions artifacts 中下载
- 确保你的 SiYuan 项目能正常构建 (`pnpm run build`)

完成这个设置后，Android 项目就可以自动从你的 SiYuan 项目下载最新的 app.zip 了！