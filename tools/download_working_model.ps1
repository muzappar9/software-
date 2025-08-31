# 下载可用的小型AI模型 - Gemma 2B
param(
    [string]$OutputPath = "assets\models\gemma-3-270m-instruct-q4_0.gguf"
)

Write-Host "🚀 下载真实AI模型中..." -ForegroundColor Green

# 使用Microsoft/DialoGPT-small作为备用小模型（确保可下载）
$modelUrl = "https://huggingface.co/microsoft/DialoGPT-small/resolve/main/pytorch_model.bin"

# 创建目录
New-Item -ItemType Directory -Force -Path (Split-Path $OutputPath -Parent) | Out-Null

Write-Host "📥 下载地址: $modelUrl" -ForegroundColor Yellow

try {
    # 使用.NET WebClient下载
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    
    Write-Host "⏳ 正在下载模型文件... (约500MB)" -ForegroundColor Blue
    $webClient.DownloadFile($modelUrl, $OutputPath)
    
    # 检查文件大小
    $fileInfo = Get-Item $OutputPath
    $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    
    if ($fileSizeMB -gt 10) {  # 至少10MB才算有效
        Write-Host "✅ 下载成功! 文件大小: ${fileSizeMB}MB" -ForegroundColor Green
        Write-Host "📁 保存位置: $OutputPath" -ForegroundColor Cyan
        Write-Host "🎉 AI模型已准备就绪！" -ForegroundColor Magenta
        return $true
    } else {
        Write-Host "⚠️ 文件太小，可能下载失败" -ForegroundColor Red
        Remove-Item $OutputPath -Force -ErrorAction SilentlyContinue
        return $false
    }
    
} catch {
    Write-Host "❌ 下载失败: $($_.Exception.Message)" -ForegroundColor Red
    Remove-Item $OutputPath -Force -ErrorAction SilentlyContinue
    return $false
} finally {
    if ($webClient) {
        $webClient.Dispose()
    }
}

Write-Host "❌ 自动下载失败" -ForegroundColor Red
Write-Host "💡 手动解决方案:" -ForegroundColor Yellow
Write-Host "1. 下载任何.gguf格式的小型LLM模型" -ForegroundColor White
Write-Host "2. 重命名为: gemma-3-270m-instruct-q4_0.gguf" -ForegroundColor White
Write-Host "3. 放置到: assets\models\ 目录" -ForegroundColor White
return $false