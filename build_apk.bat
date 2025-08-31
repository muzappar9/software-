@echo off
echo =====================================
echo 构建法律顾问App APK
echo =====================================
echo.

set FLUTTER_BIN=D:\Development\Flutter-SDK\flutter\bin

echo 清理项目...
"%FLUTTER_BIN%\flutter.bat" clean

echo.
echo 获取依赖...
"%FLUTTER_BIN%\flutter.bat" pub get

echo.
echo 构建Release APK...
"%FLUTTER_BIN%\flutter.bat" build apk --release

echo.
echo 构建完成！APK位置：
echo build\app\outputs\flutter-apk\app-release.apk
echo.

pause
