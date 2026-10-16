# Troca a versao oficial da pagina (a que aparece em https://enderup.com.br).
#
# Cada versao fica guardada em versoes\<nome>\index.html e tambem pode ser vista no ar
# em https://enderup.com.br/versoes/<nome>/ (bom para conferir antes de virar oficial).
# O index.html da raiz e so uma copia da versao oficial: nao edite ele direto.
#
# Uso:
#   .\trocar-versao.ps1 v2     -> v2 vira a oficial
#   .\trocar-versao.ps1 v1     -> volta para a v1
#   .\trocar-versao.ps1        -> mostra as versoes e qual esta oficial
#
# Depois de trocar, falta publicar: git add -A; git commit -m "Oficial: v2"; git push

param([string]$Versao)

$raiz = $PSScriptRoot
$pastaVersoes = Join-Path $raiz 'versoes'
$destino = Join-Path $raiz 'index.html'
$utf8 = New-Object System.Text.UTF8Encoding $false

$existentes = Get-ChildItem $pastaVersoes -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'index.html') } | ForEach-Object { $_.Name }
$atual = $null
if (Test-Path $destino) {
    $m = [regex]::Match([IO.File]::ReadAllText($destino, $utf8), 'GERADO de versoes/([^/]+)/index\.html')
    if ($m.Success) { $atual = $m.Groups[1].Value }
}

if (-not $Versao) {
    Write-Host "Versoes: $($existentes -join ', ')"
    Write-Host "Oficial agora: $(if ($atual) { $atual } else { 'desconhecida' })"
    Write-Host 'Uso: .\trocar-versao.ps1 v2'
    exit 0
}

if ($existentes -notcontains $Versao) {
    Write-Host "A versao '$Versao' nao existe. Versoes: $($existentes -join ', ')" -ForegroundColor Red
    exit 1
}

$html = [IO.File]::ReadAllText((Join-Path $pastaVersoes "$Versao\index.html"), $utf8)
$aviso = "<!-- GERADO de versoes/$Versao/index.html por trocar-versao.ps1. Nao edite aqui: edite a versao e rode o script de novo. -->"
$html = [regex]::Replace($html, '^(?i)(<!doctype html>)', "`$1`n$aviso")
[IO.File]::WriteAllText($destino, $html, $utf8)

Write-Host "Pronto: a oficial agora e a $Versao (antes: $(if ($atual) { $atual } else { 'nenhuma' }))." -ForegroundColor Green
Write-Host 'Falta publicar: git add -A; git commit -m "Oficial: ' -NoNewline
Write-Host "$Versao`"; git push"
