# 📤 GitHub手动上传指南

## 🚀 完整上传步骤

### 1. 初始化Git仓库
```bash
# 在项目根目录执行
git init
git branch -M main
```

### 2. 配置Git LFS（处理大文件）
```bash
# 安装Git LFS（如果没有）
git lfs install

# 跟踪大文件
git lfs track "*.safetensors"
git lfs track "*.gguf"
git lfs track "*.bin" 
git lfs track "*.task"
git lfs track "*.db"
git lfs track "*.apk"
git lfs track "*.aab"

# 添加Git LFS配置
git add .gitattributes
```

### 3. 添加远程仓库
```bash
git remote add origin https://github.com/muzappar9/software-.git
```

### 4. 添加文件并提交
```bash
# 添加所有文件
git add .

# 提交更改
git commit -m "Initial commit: AI Legal Advisor App with Gemma 270M model

✨ Features:
- 🤖 Gemma 270M AI model integration (511MB)
- 📚 Legal knowledge database (25 law articles)
- 🗣️ Intelligent conversation flow
- 🌐 Multi-language support (Chinese, English, Uyghur)
- 📱 Cross-platform Flutter app

🔧 Technical:
- Flutter 3.16.9 framework
- Codemagic CI/CD configuration
- Git LFS for large files
- Android/iOS build support"
```

### 5. 推送到GitHub
```bash
# 第一次推送
git push -u origin main

# 如果出现错误，强制推送（谨慎使用）
git push -u origin main --force
```

## 📋 需要确认的文件

### ✅ 核心配置文件
- [x] `pubspec.yaml` - Flutter项目配置
- [x] `codemagic.yaml` - CI/CD配置
- [x] `.gitignore` - Git忽略文件
- [x] `.gitattributes` - Git LFS配置
- [x] `README.md` - 项目说明

### ✅ 应用代码
- [x] `lib/` - Flutter应用代码
- [x] `android/` - Android项目
- [x] `ios/` - iOS项目

### ✅ 大文件（Git LFS管理）
- [x] `assets/models/gemma-3-270m.safetensors` (511MB)
- [x] `assets/lawpack.db` (1.8MB)
- [x] `法律顾问App-修复版.apk` (426MB)

### ✅ 辅助文件
- [x] `scripts/` - 构建脚本
- [x] `tools/` - 开发工具
- [x] `docs/` - 文档

## 🐛 常见问题解决

### 问题1: 大文件上传失败
```bash
# 确保Git LFS已安装并配置
git lfs install
git lfs track "*.safetensors"
git add .gitattributes
git add assets/models/
git commit -m "Add AI model with Git LFS"
git push
```

### 问题2: 推送被拒绝
```bash
# 先拉取远程更改
git pull origin main --allow-unrelated-histories

# 解决冲突后重新推送
git push origin main
```

### 问题3: 文件过大错误
```bash
# 增加Git缓冲区大小
git config http.postBuffer 524288000

# 使用Git LFS处理大文件
git lfs migrate import --include="*.safetensors,*.apk,*.db"
```

## 📊 上传后验证

### 检查仓库内容
1. 访问 [https://github.com/muzappar9/software-](https://github.com/muzappar9/software-)
2. 确认所有文件已上传
3. 检查Git LFS文件显示正确大小
4. 验证`codemagic.yaml`配置文件存在

### 配置Codemagic
1. 登录 [codemagic.io](https://codemagic.io)
2. 连接GitHub仓库 `software-`
3. 选择`codemagic.yaml`配置
4. 上传Android签名密钥
5. 启动构建

## 🎯 上传完成后

### 立即可用功能
- ✅ 代码版本控制
- ✅ Codemagic自动构建
- ✅ GitHub Pages部署（如需要）
- ✅ 问题跟踪和项目管理

### 下一步操作
1. 在Codemagic中配置构建流程
2. 设置Android签名证书
3. 配置Google Play发布（可选）
4. 设置自动化测试

---

💡 **提示**: 如果上传过程中遇到问题，可以分批上传文件，先上传小文件，再处理大文件。