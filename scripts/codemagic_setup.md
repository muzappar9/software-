# 🚀 Codemagic CI/CD 设置指南

## 📋 前置准备

### 1. GitHub 准备
- ✅ 项目已上传到: `https://github.com/muzappar9/software-`
- ✅ 包含 `codemagic.yaml` 配置文件
- ✅ 使用 Git LFS 管理大文件（模型、数据库）

### 2. Codemagic 账户设置
1. 访问 [codemagic.io](https://codemagic.io)
2. 使用 GitHub 账户登录
3. 连接你的 `software-` 仓库

## ⚙️ Android 构建配置

### 1. 环境变量设置
在 Codemagic 项目设置中添加：

```bash
# Google Play 发布（可选）
GOOGLE_PLAY_TRACK=internal
PACKAGE_NAME=com.legaladvisor.app
GCLOUD_SERVICE_ACCOUNT_CREDENTIALS=[Google Play Console JSON密钥]
```

### 2. Android 签名配置
上传以下文件到 Codemagic:
- **Keystore文件**: `android-keystore.jks`
- **密钥别名**: `legal_advisor_key`
- **Keystore密码**: `[你的密码]`
- **密钥密码**: `[你的密码]`

### 3. 生成签名密钥（如果没有）
```bash
keytool -genkey -v -keystore android-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias legal_advisor_key
```

## 🍎 iOS 构建配置（可选）

### 1. Apple 开发者账户
- Apple Developer Program 会员资格
- App Store Connect API 密钥

### 2. 证书和配置文件
- Distribution Certificate (.p12)
- Provisioning Profile
- App Store Connect API Key

## 🏗️ 构建流程

### 自动触发
- 推送到 `main` 分支时自动构建
- Pull Request 时运行测试

### 手动触发
1. 登录 Codemagic
2. 选择 `software-` 项目
3. 点击 "Start new build"
4. 选择工作流：`android-workflow` 或 `ios-workflow`

## 📦 构建产物

### Android
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **映射文件**: `build/app/outputs/mapping/release/mapping.txt`

### iOS  
- **IPA**: `build/ios/ipa/legal_advisor_app.ipa`

## 🚀 发布选项

### 内部测试
- 构建完成后自动发布到 Google Play 内部测试
- TestFlight 内部测试（iOS）

### 生产发布
需要手动修改 `codemagic.yaml`:
```yaml
google_play:
  track: production  # 改为 production
  submit_as_draft: false  # 改为 false
```

## 🐛 故障排除

### 常见问题

#### 1. 构建超时
```yaml
max_build_duration: 120  # 增加到120分钟
```

#### 2. 大文件问题
确保使用 Git LFS:
```bash
git lfs track "*.safetensors"
git lfs track "*.apk"
```

#### 3. 内存不足
```yaml
instance_type: mac_mini_m2  # 升级到更大内存实例
```

#### 4. Flutter 版本
```yaml
flutter: 3.16.9  # 指定具体版本
```

## 📊 监控和通知

### Slack 通知（可选）
1. 创建 Slack App
2. 获取 Webhook URL  
3. 在 Codemagic 中配置

### 邮件通知
默认发送到注册邮箱

## 🔗 有用链接

- [Codemagic 文档](https://docs.codemagic.io/)
- [Flutter CI/CD 最佳实践](https://docs.codemagic.io/flutter-configuration/flutter-projects/)
- [Android 签名指南](https://docs.codemagic.io/code-signing/android-code-signing/)
- [iOS 签名指南](https://docs.codemagic.io/code-signing/ios-code-signing/)

---

✅ **设置完成后，每次推送代码都会自动构建并生成APK/AAB文件！**