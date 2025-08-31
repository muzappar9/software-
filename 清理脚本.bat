@echo off
echo 清理项目冗余文件...

REM 删除重复的构建脚本
del /f /q build_apk_direct.ps1 2>nul
del /f /q build_apk_english.bat 2>nul
del /f /q build_bulletproof_app.bat 2>nul
del /f /q build_complete_offline.bat 2>nul
del /f /q build_final_complete_apk.bat 2>nul
del /f /q build_fixed_apk.bat 2>nul
del /f /q build_fixed_complete_app.bat 2>nul
del /f /q build_offline_apk.bat 2>nul

REM 删除下载脚本
del /f /q download_model.ps1 2>nul
del /f /q download_real_model.ps1 2>nul
del /f /q 使用真实模型.ps1 2>nul

REM 删除配置脚本
del /f /q 一键配置Android.bat 2>nul
del /f /q 快速下载Android-Platform.bat 2>nul
del /f /q 快速启动App-修复版.bat 2>nul
del /f /q 快速启动App.bat 2>nul
del /f /q 快速获取真实AI.bat 2>nul
del /f /q 快速配置Android.bat 2>nul
del /f /q 手机模拟启动.bat 2>nul
del /f /q 真实检测.bat 2>nul

REM 删除临时文件
del /f /q integration_report.json 2>nul
del /f /q test_ai_integration.dart 2>nul
del /f /q test_database.py 2>nul
del /f /q 📱安装指南.txt 2>nul

echo 清理完成！
echo.
echo 保留的核心文件：
echo - lib/ (Flutter源码)
echo - android/ (Android配置)
echo - assets/ (资源文件)
echo - pubspec.yaml (依赖配置)
echo - build_apk.bat (主构建脚本)
echo - 简化构建.bat (简化构建脚本)
echo.
pause
