# 🏛️ AI法律顾问App

一个基于Gemma 270M模型的智能法律咨询应用，支持多语言（中文、英文、维吾尔语）的法律问答和案由识别。

## ✨ 功能特点

- 🤖 **本地AI推理**: 集成Gemma 3 270M模型，无需联网即可提供法律建议
- 📚 **法律知识库**: 包含25个法条样本和完整的法律数据库
- 🗣️ **智能对话**: 引导式填槽对话，自动识别案由类型
- 🌐 **多语言支持**: 中文、英文、维吾尔语界面
- 📱 **跨平台**: 支持Android、iOS、Windows、Web

## 🛠️ 技术架构

### 前端
- **Framework**: Flutter 3.16+
- **状态管理**: Provider + Riverpod
- **路由**: GoRouter
- **UI**: Material Design 3

### 后端服务
- **AI引擎**: Gemma 270M (本地推理)
- **数据库**: SQLite + JSON法条库
- **API**: FastAPI (可选)

### 构建工具
- **CI/CD**: Codemagic
- **版本控制**: Git + Git LFS (大文件)
- **依赖管理**: Flutter Pub

## 📦 项目结构

```
legal_advisor_app/
├── 📂 lib/                     # Flutter应用代码
│   ├── 📂 screens/             # 界面页面
│   ├── 📂 services/            # AI和法律服务
│   ├── 📂 providers/           # 状态管理
│   ├── 📂 widgets/             # 自定义组件
│   └── 📂 rag/                 # 法律检索模块
├── 📂 assets/                  # 静态资源
│   ├── 📂 models/              # AI模型文件(511MB)
│   ├── 📂 slots/               # 案由槽位配置
│   └── lawpack.db              # 法律数据库(1.8MB)
├── 📂 android/                 # Android项目
├── 📂 ios/                     # iOS项目
├── 📂 scripts/                 # 构建和测试脚本
├── codemagic.yaml              # CI/CD配置
└── pubspec.yaml                # Flutter依赖配置
```

## 🚀 快速开始

### 环境要求
- Flutter 3.16.9+
- Dart 3.2.6+
- Android SDK 34+
- Git LFS

### 安装步骤

1. **克隆仓库**
```bash
git clone https://github.com/muzappar9/software-.git
cd software-
```

2. **安装依赖**
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **运行应用**
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows
```

## 📱 构建发布

### 使用Codemagic CI/CD（推荐）

1. 连接GitHub仓库到Codemagic
2. 上传Android签名密钥
3. 配置环境变量
4. 触发构建流程

### 手动构建

```bash
# Android APK
flutter build apk --release --target-platform android-arm64

# Android AAB (Google Play)
flutter build appbundle --release

# iOS IPA
flutter build ios --release
```

## 🧪 测试验证

- ✅ 启动无闪退
- ✅ AI模型推理功能
- ✅ 法律数据库检索
- ✅ 多语言切换
- ✅ 引导式对话流程

## 🔧 已修复问题

- ✅ Android闪退问题
- ✅ 98个编译错误
- ✅ ModelRunner初始化异常
- ✅ LawPack数据库初始化
- ✅ Flutter绑定初始化

## 📊 应用规格

| 项目 | 详情 |
|------|------|
| APK大小 | 426.2MB (包含AI模型) |
| AI模型 | Gemma 3 270M (511MB) |
| 法律数据 | 25个法条 + 6个文件 |
| 支持语言 | 中文、英文、维吾尔语 |
| 最低Android | API 21 (Android 5.0) |

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- 项目链接: [https://github.com/muzappar9/software-](https://github.com/muzappar9/software-)
- 问题反馈: [Issues](https://github.com/muzappar9/software-/issues)

---

**⚖️ 法律声明**: 本应用仅提供法律信息参考，不构成正式法律建议。如需专业法律服务，请咨询执业律师。