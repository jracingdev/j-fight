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
try {
    # Git escreve mensagens normais no stderr; evita falso erro com Stop.
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    git init 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git init falhou (exit $LASTEXITCODE)" }

    git checkout -b gh-pages 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git checkout -b gh-pages falhou (exit $LASTEXITCODE)" }

    git add -A
    git commit -m "Deploy GitHub Pages $(Get-Date -Format 'yyyy-MM-dd HH:mm')" 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git commit falhou (exit $LASTEXITCODE)" }

    $remote = "https://github.com/jracingdev/j-fight.git"
    git remote remove origin 2>&1 | Out-Null
    git remote add origin $remote 2>&1 | Out-Null

    git push -f origin gh-pages 2>&1
    if ($LASTEXITCODE -ne 0) { throw "git push falhou (exit $LASTEXITCODE)" }

    $ErrorActionPreference = $prevEap
}
finally {
    Pop-Location
    if (Test-Path $deployDir) { Remove-Item -Recurse -Force $deployDir }
}

Write-Host ""
Write-Host "Publicado! Aguarde 1-3 min e abra:"
Write-Host "https://jracingdev.github.io/j-fight/"
