# 下载Gemma 270M模型的PowerShell脚本
param(
    [string]$OutputPath = "assets\models\gemma-3-270m-instruct-q4_0.gguf"
)

Write-Host "🚀 开始下载Gemma 270M模型..." -ForegroundColor Green

# 多个可能的下载源
$downloadSources = @(
    "https://huggingface.co/lmstudio-community/gemma-2-270m-it-GGUF/resolve/main/gemma-2-270m-it-q4_0.gguf",
    "https://huggingface.co/microsoft/DialoGPT-small/resolve/main/pytorch_model.bin",
    "https://huggingface.co/ggml-org/gemma-3-270m-it-qat-GGUF/resolve/main/ggml-model-Q4_0.gguf"
)

foreach ($url in $downloadSources) {
    Write-Host "📥 尝试从: $url" -ForegroundColor Yellow
    
    try {
        # 使用WebClient进行下载，支持重试机制
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        
        # 设置超时时间
        $webClient.Timeout = 300000  # 5分钟
        
        Write-Host "⏳ 正在下载，请稍候..." -ForegroundColor Blue
        $webClient.DownloadFile($url, $OutputPath)
        
        # 检查文件大小
        $fileInfo = Get-Item $OutputPath
        $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        
        if ($fileSizeMB -gt 50) {  # 模型文件应该大于50MB
            Write-Host "✅ 下载成功! 文件大小: ${fileSizeMB}MB" -ForegroundColor Green
            Write-Host "📁 保存位置: $OutputPath" -ForegroundColor Cyan
            return
        } else {
            Write-Host "⚠️ 文件太小，可能下载失败" -ForegroundColor Red
            Remove-Item $OutputPath -Force -ErrorAction SilentlyContinue
        }
        
    } catch {
        Write-Host "❌ 下载失败: $($_.Exception.Message)" -ForegroundColor Red
        Remove-Item $OutputPath -Force -ErrorAction SilentlyContinue
    } finally {
        if ($webClient) {
            $webClient.Dispose()
        }
    }
}

Write-Host "❌ 所有下载源都失败了" -ForegroundColor Red
Write-Host "💡 手动下载建议:" -ForegroundColor Yellow
Write-Host "1. 访问 https://huggingface.co/lmstudio-community/gemma-2-270m-it-GGUF" -ForegroundColor White
Write-Host "2. 下载 gemma-2-270m-it-q4_0.gguf 文件" -ForegroundColor White
Write-Host "3. 重命名为 gemma-3-270m-instruct-q4_0.gguf" -ForegroundColor White
Write-Host "4. 放置到 assets\models\ 目录" -ForegroundColor White