Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$proj = Split-Path -Parent $PSScriptRoot
$root = Split-Path -Parent $proj
Write-Host "Project root: $root"

# 1) 生成 demo lawpack.db
$src = Join-Path $PSScriptRoot "demo_src"
$out = Join-Path $root "assets\lawpack.db"
python "$PSScriptRoot\etl_from_txt.py" --src_dir "$src" --out "$out" --rules "$PSScriptRoot\chunk_rules.yaml" --lang zh

# 2) 确保 pubspec.yaml 已包含 assets/lawpack.db（若缺则提醒）
$pub = Join-Path $root "pubspec.yaml"
$content = Get-Content $pub -Raw
if ($content -notmatch "assets/lawpack.db") {
  Write-Warning "请在 pubspec.yaml 的 flutter: assets: 下加入 - assets/lawpack.db"
} else {
  Write-Host "pubspec.yaml assets 已包含 lawpack.db"
}

Write-Host "Done. lawpack.db at: $out"

