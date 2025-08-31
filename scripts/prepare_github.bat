@echo off
echo 🚀 准备上传到 GitHub...

REM 检查 Git 是否已初始化
if not exist .git (
    echo 📦 初始化 Git 仓库...
    git init
    git branch -M main
) else (
    echo ✅ Git 仓库已存在
)

REM 添加远程仓库（如果不存在）
git remote | findstr origin >nul
if errorlevel 1 (
    echo 🔗 添加远程仓库...
    git remote add origin https://github.com/muzappar9/software-.git
) else (
    echo ✅ 远程仓库已配置
)

REM 创建 .gitignore（如果不存在或需要更新）
echo 📝 更新 .gitignore...
(
echo # Miscellaneous
echo *.class
echo *.log
echo *.pyc
echo *.swp
echo .DS_Store
echo .atom/
echo .buildlog/
echo .history
echo .svn/
echo migrate_working_dir/
echo.
echo # IntelliJ related
echo *.iml
echo *.ipr
echo *.iws
echo .idea/
echo.
echo # The .vscode folder contains launch configuration and tasks you configure in
echo # VS Code which you may wish to be included in version control, so this line
echo # is commented out by default.
echo #.vscode/
echo.
echo # Flutter/Dart/Pub related
echo **/doc/api/
echo **/ios/Flutter/.last_build_id
echo .dart_tool/
echo .flutter-plugins
echo .flutter-plugins-dependencies
echo .packages
echo .pub-cache/
echo .pub/
echo /build/
echo.
echo # Symbolication related
echo app.*.symbols
echo.
echo # Obfuscation related
echo app.*.map.json
echo.
echo # Android Studio will place build artifacts here
echo /android/app/debug
echo /android/app/profile
echo /android/app/release
echo.
echo # Large model files - use Git LFS
echo *.safetensors
echo *.gguf
echo *.bin
echo *.task
echo.
echo # Database files
echo *.db
echo *.sqlite
echo *.sqlite3
) > .gitignore

REM 设置 Git LFS 用于大文件
echo 🗃️ 设置 Git LFS...
git lfs track "*.safetensors"
git lfs track "*.gguf" 
git lfs track "*.bin"
git lfs track "*.task"
git lfs track "*.db"
git lfs track "*.apk"

REM 添加所有文件
echo 📂 添加文件到 Git...
git add .
git add .gitattributes

REM 提交更改
echo 💾 提交更改...
git commit -m "Initial commit: AI Legal Advisor App with Gemma 270M model"

REM 推送到 GitHub
echo 📤 推送到 GitHub...
git push -u origin main

echo.
echo ✅ 项目已成功上传到 GitHub!
echo 🔗 仓库地址: https://github.com/muzappar9/software-
echo.
echo 📋 下一步:
echo 1. 在 Codemagic 中连接你的 GitHub 仓库
echo 2. 配置签名证书和密钥
echo 3. 运行构建流程
echo.
pause