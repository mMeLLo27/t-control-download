# Instala (ou atualiza) o T-Control no Windows com um comando só, no PowerShell:
#
#   irm https://raw.githubusercontent.com/mMeLLo27/t-control-download/main/instalar.ps1 | iex
#
# Baixa o instalador da última versão publicada no GitHub e roda sem perguntas:
# instala só para o usuário (sem senha de administrador), cria o ícone na área
# de trabalho e abre o app. Os dados não são tocados numa atualização.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'  # o download fica muito mais rápido sem a barra

$url = 'https://github.com/mMeLLo27/t-control-download/releases/latest/download/T-Control-Windows-Setup.exe'
$setup = Join-Path $env:TEMP 'T-Control-Windows-Setup.exe'

Write-Host '==> Baixando o T-Control' -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $setup -UseBasicParsing

Write-Host '==> Instalando' -ForegroundColor Cyan
Start-Process -FilePath $setup -ArgumentList '/SILENT', '/SUPPRESSMSGBOXES', '/CLOSEAPPLICATIONS', '/NORESTART' -Wait
Remove-Item $setup -ErrorAction SilentlyContinue

$exe = Join-Path $env:LOCALAPPDATA 'Programs\T-Control\T-Control.exe'
if (-not (Test-Path $exe)) { throw 'A instalação não terminou. Tente de novo ou baixe o instalador pela página do GitHub.' }

Write-Host '==> Abrindo o T-Control' -ForegroundColor Cyan
Start-Process -FilePath $exe
Write-Host 'Pronto. O T-Control está na área de trabalho e no menu Iniciar; o ícone dele aparece perto do relógio.'
