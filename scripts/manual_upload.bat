@echo off
chcp 65001 >nul
echo 🚀 手动上传到GitHub - 分步执行
echo.

echo 📋 当前项目状态检查...
git status
echo.

echo ⚠️  注意：这个脚本将分步执行，请按照提示操作
echo.

echo 🔍 步骤1：初始化Git仓库
echo 执行命令：git init
git init
git branch -M main
echo ✅ Git仓库初始化完成
echo.

echo 🗃️ 步骤2：配置Git LFS（大文件支持）
echo 执行命令：git lfs install
git lfs install

echo 配置大文件跟踪...
git lfs track "*.safetensors"
git lfs track "*.gguf"
git lfs track "*.bin"
git lfs track "*.task"
git lfs track "*.db"
git lfs track "*.apk"
git lfs track "*.aab"

echo ✅ Git LFS配置完成
echo.

echo 🔗 步骤3：添加远程仓库
echo 执行命令：git remote add origin https://github.com/muzappar9/software-.git
git remote remove origin 2>nul
git remote add origin https://github.com/muzappar9/software-.git
echo ✅ 远程仓库配置完成
echo.

echo 📂 步骤4：添加文件到Git
echo 添加.gitattributes文件...
git add .gitattributes

echo 添加所有文件...
git add .
echo ✅ 文件添加完成
echo.

echo 💾 步骤5：提交更改
git commit -m "Initial commit: AI Legal Advisor App with Gemma 270M model"
echo ✅ 提交完成
echo.

echo 📤 步骤6：推送到GitHub
echo 执行命令：git push -u origin main
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ✅ 🎉 项目成功上传到GitHub！
    echo.
    echo 🔗 仓库地址：https://github.com/muzappar9/software-
    echo.
    echo 📋 下一步操作：
    echo 1. 访问 https://codemagic.io
    echo 2. 使用GitHub账户登录
    echo 3. 连接 software- 仓库
    echo 4. 配置Android签名密钥
    echo 5. 启动构建流程
    echo.
) else (
    echo.
    echo ❌ 推送失败，尝试强制推送...
    echo 执行命令：git push -u origin main --force
    git push -u origin main --force
    
    if %errorlevel% equ 0 (
        echo ✅ 强制推送成功！
    ) else (
        echo ❌ 上传失败，请检查网络连接和GitHub权限
        echo.
        echo 🛠️ 手动解决方案：
        echo 1. 检查GitHub仓库 https://github.com/muzappar9/software- 是否存在
        echo 2. 确认你有仓库写入权限
        echo 3. 尝试使用GitHub Desktop或Git GUI工具
        echo 4. 检查Git LFS是否正确安装
    )
)

echo.
pause