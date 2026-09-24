<#
  publicar-perfil.ps1 — sobe o README de perfil do GitHub.

      .\publicar-perfil.ps1                    commit + push
      .\publicar-perfil.ps1 "texto do commit"  idem, com sua mensagem

  O repositorio no GitHub PRECISA se chamar exatamente ShendonC — e assim
  que o GitHub reconhece um README de perfil. O nome desta pasta aqui nao
  importa.
#>
param([Parameter(Position = 0)][string]$Mensagem = "")

# git escreve em stderr sem que isso seja erro; sem esta linha o
# PowerShell 7.3+ aborta no meio.
if (Test-Path variable:PSNativeCommandUseErrorActionPreference) {
  $PSNativeCommandUseErrorActionPreference = $false
}

$REPO = "https://github.com/ShendonC/ShendonC.git"

function Titulo($t) { Write-Host ""; Write-Host "  $t" -ForegroundColor Cyan }
function Ok($t)     { Write-Host "  ok    $t" -ForegroundColor Green }
function Aviso($t)  { Write-Host "  aviso $t" -ForegroundColor Yellow }
function Erro($t)   { Write-Host "  ERRO  $t" -ForegroundColor Red }
function Fechar($c) { Write-Host ""; Read-Host "  Enter para fechar" | Out-Null; exit $c }

# Sempre trabalha na pasta do proprio script. Caminho relativo depende de
# onde o terminal esta, e isso ja quebrou antes.
Set-Location $PSScriptRoot
Write-Host ""
Write-Host "  Perfil GitHub — $PSScriptRoot" -ForegroundColor White

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Erro "git nao esta instalado.  https://git-scm.com/download/win"
  Fechar 1
}

# Guarda: sem estes dois o perfil sobe vazio.
foreach ($f in @("README.md", "banner.svg")) {
  if (-not (Test-Path (Join-Path $PSScriptRoot $f))) {
    Erro "falta $f nesta pasta. Nada foi enviado."
    Fechar 1
  }
}
Ok "README.md e banner.svg encontrados"

# ── repositorio ─────────────────────────────────────────────────────────
Titulo "GIT"
if (-not (Test-Path (Join-Path $PSScriptRoot ".git"))) {
  Aviso "esta pasta ainda nao e um repositorio git."
  $r = Read-Host "        criar agora e ligar em $REPO ? (s/N)"
  if ($r -notmatch '^[sSyY]') { Aviso "cancelado"; Fechar 0 }

  git init -b main | Out-Null
  git remote add origin $REPO
  Ok "repositorio criado e ligado no remoto"
  Write-Host "        Crie o repositorio VAZIO no GitHub antes do primeiro push:" -ForegroundColor DarkGray
  Write-Host "        https://github.com/new  ->  nome: ShendonC  ->  Public" -ForegroundColor DarkGray
  Write-Host "        Sem README, sem .gitignore, sem licenca — senao o push e recusado." -ForegroundColor DarkGray
  Write-Host ""
  Read-Host "        Enter DEPOIS de criar o repositorio no GitHub" | Out-Null
}

if (-not (git remote)) {
  git remote add origin $REPO
  Ok "remoto configurado"
}

# ── commit ──────────────────────────────────────────────────────────────
$sujo = @(git status --porcelain)
if ($sujo.Count -eq 0) {
  Ok "nada mudou desde o ultimo commit"
} else {
  Write-Host "  $($sujo.Count) arquivo(s) alterado(s):"
  $sujo | ForEach-Object { Write-Host "        $_" -ForegroundColor DarkGray }

  if ([string]::IsNullOrWhiteSpace($Mensagem)) {
    Write-Host ""
    $Mensagem = Read-Host "  mensagem do commit (Enter usa a data)"
  }
  if ([string]::IsNullOrWhiteSpace($Mensagem)) {
    $Mensagem = "atualiza perfil " + (Get-Date -Format "yyyy-MM-dd HH:mm")
  }

  git add -A
  git commit -m $Mensagem | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Erro "o commit falhou. Se for a primeira vez, configure seu nome:"
    Write-Host '        git config --global user.name  "Luiz Otavio"' -ForegroundColor DarkGray
    Write-Host '        git config --global user.email "luiz.otavdm@gmail.com"' -ForegroundColor DarkGray
    Fechar 1
  }
  Ok "commit: $Mensagem"
}

# ── push ────────────────────────────────────────────────────────────────
Titulo "PUSH"
git push -u origin main
if ($LASTEXITCODE -eq 0) {
  Ok "no ar: https://github.com/ShendonC"
  Write-Host "        Confira se o banner esta animando — e a unica coisa" -ForegroundColor DarkGray
  Write-Host "        que so da para verificar depois de publicado." -ForegroundColor DarkGray
} else {
  Erro "o push falhou (a mensagem do git esta acima)."
  Write-Host ""
  Write-Host "        'Repository not found' -> o repositorio ainda nao existe no" -ForegroundColor DarkGray
  Write-Host "        GitHub, OU voce nao esta autenticado. O GitHub responde 404" -ForegroundColor DarkGray
  Write-Host "        nos dois casos, de proposito, para nao revelar o que existe." -ForegroundColor DarkGray
  Write-Host "        Crie em https://github.com/new -> ShendonC -> Public -> vazio," -ForegroundColor DarkGray
  Write-Host "        e rode este script de novo." -ForegroundColor DarkGray
  Write-Host ""
  Write-Host "        'rejected' / 'fetch first' -> foi criado COM README. Apague e" -ForegroundColor DarkGray
  Write-Host "        recrie vazio, ou rode: git pull --rebase origin main" -ForegroundColor DarkGray
}

Fechar 0
