@echo off
echo =====================================
echo 法律顾问App - 简化构建流程
echo =====================================
echo.

set FLUTTER_BIN=D:\Development\Flutter-SDK\flutter\bin

echo [1/3] 清理项目...
"%FLUTTER_BIN%\flutter.bat" clean

echo.
echo [2/3] 获取依赖...
"%FLUTTER_BIN%\flutter.bat" pub get

echo.
echo [3/3] 构建APK...
"%FLUTTER_BIN%\flutter.bat" build apk --release

echo.
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ 构建成功！
    echo 📱 APK位置: build\app\outputs\flutter-apk\app-release.apk
    echo 📊 文件大小:
    dir "build\app\outputs\flutter-apk\app-release.apk" | findstr "app-release.apk"
) else (
    echo ❌ 构建失败，请检查错误信息
)

echo.
pause
