# Build web para GitHub Pages com API na AWS
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..\..

$apiBase = if ($env:JFIGHT_API_BASE) { $env:JFIGHT_API_BASE.TrimEnd('/') } else { "https://api.jracing.dev.br" }
$apiV1 = "$apiBase/api/v1"

Write-Host "API_BASE_URL = $apiV1"
Write-Host "API_PUBLIC_URL = $apiBase"
Write-Host ""

flutter build web --release --base-href "/j-fight/" --pwa-strategy=none `
  --dart-define=API_BASE_URL=$apiV1 `
  --dart-define=API_PUBLIC_URL=$apiBase `
  --dart-define=GOOGLE_WEB_CLIENT_ID=276798866114-q4s5b17hfk4ftsu3ag5hht2gu9f273r6.apps.googleusercontent.com

Write-Host ""
Write-Host "Build em: build\web"
Write-Host "Proximo passo: .\deploy\aws\publicar-github-pages.ps1"
