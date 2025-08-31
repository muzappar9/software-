@echo off
echo 🔑 生成Android签名证书...
echo.

echo 请输入以下信息（可以都输入相同的密码以简化）:
echo.

keytool -genkey -v -keystore legal-advisor-keystore.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 ^
  -alias legal-advisor-key

echo.
echo ✅ 证书生成完成！
echo 📁 文件位置: legal-advisor-keystore.jks
echo 🔑 密钥别名: legal-advisor-key
echo.
echo 📋 请记住你设置的密码，上传到Codemagic时需要用到
echo.
pause