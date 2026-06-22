# Publica build/web na branch gh-pages (GitHub Pages)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..\..

if (-not (Test-Path "build\web\index.html")) {
    Write-Error "Rode antes: .\deploy\aws\build-web-github-pages.ps1"
    exit 1
}

$deployDir = Join-Path $env:TEMP "jfight-gh-pages-deploy"
if (Test-Path $deployDir) { Remove-Item -Recurse -Force $deployDir }
New-Item -ItemType Directory -Path $deployDir | Out-Null

Copy-Item -Recurse -Force "build\web\*" $deployDir

Push-Location $deployDir
git init | Out-Null
git checkout -b gh-pages 2>$null
git add -A
git commit -m "Deploy GitHub Pages $(Get-Date -Format 'yyyy-MM-dd HH:mm')" | Out-Null

$remote = "https://github.com/jracingdev/j-fight.git"
git remote add origin $remote 2>$null
git push -f origin gh-pages

Pop-Location
Remove-Item -Recurse -Force $deployDir

Write-Host ""
Write-Host "Publicado! Aguarde 1-3 min e abra:"
Write-Host "https://jracingdev.github.io/j-fight/"
