# Download Gemma 270M Model Script (Fixed)
param(
    [string]$OutputPath = "assets\models\gemma-3-270m-instruct-q4_0.gguf"
)

Write-Host "🚀 Starting Gemma 270M model download..." -ForegroundColor Green

# Target download URL - ZeroWw/gemma-3-270m-it-GGUF Q6_K (440MB)
$modelUrl = "https://huggingface.co/ZeroWw/gemma-3-270m-it-GGUF/resolve/main/gemma-3-270m-it-Q6_K.gguf"

Write-Host "📥 Downloading from: $modelUrl" -ForegroundColor Yellow

try {
    # Create WebClient with headers
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
    
    Write-Host "⏳ Downloading model file, please wait..." -ForegroundColor Blue
    $webClient.DownloadFile($modelUrl, $OutputPath)
    
    # Check file size
    $fileInfo = Get-Item $OutputPath
    $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    
    if ($fileSizeMB -gt 100) {  # Model should be >100MB
        Write-Host "✅ Download successful! File size: ${fileSizeMB}MB" -ForegroundColor Green
        Write-Host "📁 Saved to: $OutputPath" -ForegroundColor Cyan
        exit 0
    } else {
        Write-Host "⚠️ File too small, download may have failed" -ForegroundColor Red
        Remove-Item $OutputPath -Force -ErrorAction SilentlyContinue
        exit 1
    }
    
} catch {
    Write-Host "❌ Download failed: $($_.Exception.Message)" -ForegroundColor Red
    Remove-Item $OutputPath -Force -ErrorAction SilentlyContinue
    
    Write-Host "💡 Manual download instructions:" -ForegroundColor Yellow
    Write-Host "1. Visit: https://huggingface.co/ZeroWw/gemma-3-270m-it-GGUF" -ForegroundColor White
    Write-Host "2. Download Q6_K.gguf file (440MB)" -ForegroundColor White  
    Write-Host "3. Rename to: gemma-3-270m-instruct-q4_0.gguf" -ForegroundColor White
    Write-Host "4. Place in: assets\models\ directory" -ForegroundColor White
    exit 1
} finally {
    if ($webClient) {
        $webClient.Dispose()
    }
}