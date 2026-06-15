# Remove service worker do flutter_bootstrap (build com --pwa-strategy=none).
$path = Join-Path $PSScriptRoot "..\build\web\flutter_bootstrap.js"
if (-not (Test-Path $path)) { Write-Error "Build web primeiro: flutter build web --release --base-href / --pwa-strategy=none"; exit 1 }
$c = Get-Content $path -Raw
$c = $c -replace '_flutter\.loader\.load\(\{\s*serviceWorkerSettings:\s*\{[^}]+\}\s*\}\);', '_flutter.loader.load({});'
Set-Content $path $c -NoNewline
Write-Host "flutter_bootstrap.js patched (sem service worker)."
