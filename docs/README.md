# 法律顾问App - 项目文档

## 📱 项目概述
基于Flutter开发的AI法律咨询应用，集成Gemma3 270M模型，支持多语言法律咨询。

## 🚀 快速开始

### 构建APK
```bash
# 使用主构建脚本
.\build_apk.bat

# 或手动构建
D:\Development\Flutter-SDK\flutter\bin\flutter.bat clean
D:\Development\Flutter-SDK\flutter\bin\flutter.bat pub get
D:\Development\Flutter-SDK\flutter\bin\flutter.bat build apk --release
```

### 安装运行
1. 构建完成后，APK位于: `build\app\outputs\flutter-apk\app-release.apk`
2. 传输到Android设备安装
3. 首次启动会初始化AI模型

## 🔧 技术栈
- **前端**: Flutter + Riverpod状态管理
- **AI引擎**: MediaPipe LLM Inference API
- **模型**: Gemma3 270M (1B参数int4量化)
- **数据库**: SQLite + FTS5全文搜索
- **多语言**: 中文、维吾尔语、哈萨克语

## 📁 项目结构
```
lib/                    # Flutter源码
├── screens/           # 界面页面
├── providers/         # 状态管理
└── constants/         # 常量配置

android/               # Android原生代码
├── app/src/main/kotlin/  # Kotlin代码
└── app/src/main/assets/  # 资源文件

assets/                # 应用资源
├── models/           # AI模型文件
├── images/           # 图片资源
└── l10n/            # 多语言文件
```

## 🔍 故障排除
- **构建失败**: 检查Flutter SDK路径和Android配置
- **模型加载失败**: 确认模型文件完整性
- **应用闪退**: 查看Android日志定位问题

## 📞 支持
如遇问题，请查看技术实现报告或联系开发团队。
