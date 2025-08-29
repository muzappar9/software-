Android 环境一键配置与构建说明

1) 安装 Android Studio（含 SDK、Platform-Tools、Build-Tools）
  - 在 SDK Manager 中安装：
    * Android SDK Platform 34
    * Android SDK Build-Tools 34.0.0
    * Android SDK Platform-Tools
    * NDK (Side by side) 26.3.11579264
    * CMake 3.22.1

2) 在 PowerShell 中设置环境变量（请替换 <you>）
```powershell
setx ANDROID_SDK_ROOT "C:\Users\<you>\AppData\Local\Android\Sdk"
setx JAVA_HOME "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_SDK_ROOT = [System.Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT","User")
$env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME","User")
```

3) 接受授权并检查
```bash
flutter doctor --android-licenses
flutter doctor -v
```

4) 连接真机并运行
```bash
cd D:\Development\Projects\LegalAdvisor-App\legal_advisor_app
flutter clean
flutter pub get
flutter run -d android
```

5) 打包并安装
```bash
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

如果遇到构建报错，将完整错误复制给我，我会直接给出可替换的补丁。

