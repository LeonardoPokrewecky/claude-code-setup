# Instalador guiado do claude-code-setup. Veja install/README.md.
#
# Este script NAO inventa um caminho novo: ele chama, na ordem, os mesmos comandos do README (Passos 1 a 4) e
# mantem a regra do pacote: cada gravacao em ~/.claude passa por DRY-RUN -> revisao sua -> -Confirmar <codigo>.
# O codigo e lido da saida do dry-run, mas so e usado depois que voce responde "s".
#
# Uso (na pasta do clone):
#   pwsh -NoProfile -File install/instalar.ps1                 # guiado
#   pwsh -NoProfile -File install/instalar.ps1 -SoSimular      # so os dry-runs, nao grava nada
#   pwsh -NoProfile -File install/instalar.ps1 -Perfil unix -ManterEscalares
param(
    [string]$Destino = (Join-Path $(if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }) '.claude'),
    [ValidateSet('unix')][string[]]$Perfil,
    [switch]$ManterEscalares,
    [switch]$SoSimular,
    [switch]$PularPlugins
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object Text.UTF8Encoding $false
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
$Destino = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destino)

function Titulo([string]$t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }
function Pergunta([string]$t) { (Read-Host "$t [s/N]") -match '^(s|sim|y|yes)$' }

# Interpretador usado para chamar os scripts do pacote (pwsh quando existir; senao o PowerShell 5.1 do Windows).
$ps = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
$extra = if ($ps -eq 'powershell') { @('-ExecutionPolicy', 'Bypass') } else { @() }

# Roda um script do pacote, mostra a saida e devolve @{ Saida; Ok }.
function Rodar([string]$script, [string[]]$args_) {
    $saida = (& $ps -NoProfile @extra -File (Join-Path $repo "scripts/$script") @args_ 2>&1 | Out-String)
    $ok = ($LASTEXITCODE -eq 0)
    Write-Host $saida
    @{ Saida = $saida; Ok = $ok }
}

# Dry-run -> revisao -> confirmacao. Devolve $true se gravou.
function DryRunEConfirma([string]$nome, [string]$script, [string[]]$argsBase) {
    $d = Rodar $script (@('-DryRun') + $argsBase)
    if (-not $d.Ok) { Write-Host "O dry-run de $nome falhou. Nada foi gravado." -ForegroundColor Red; return $false }
    if ($d.Saida -notmatch '-Confirmar\s+([0-9a-f]{12})') {
        Write-Host "$nome : nada a gravar (ja esta em dia)." -ForegroundColor Green; return $false
    }
    $codigo = $Matches[1]
    if ($SoSimular) { Write-Host "(-SoSimular) $nome nao foi gravado. Codigo do dry-run: $codigo" -ForegroundColor Yellow; return $false }
    if (-not (Pergunta "Revisou a saida acima (inclusive os ALERTAS) e quer gravar $nome?")) {
        Write-Host "$nome pulado. Nada foi gravado." -ForegroundColor Yellow; return $false
    }
    $g = Rodar $script (@('-Confirmar', $codigo) + $argsBase)
    if (-not $g.Ok) { Write-Host "A gravacao de $nome falhou." -ForegroundColor Red; return $false }
    Write-Host "$nome gravado." -ForegroundColor Green
    $true
}

Titulo 'Checagem'
Write-Host "Clone do pacote : $repo"
Write-Host "Destino         : $Destino"
Write-Host "Interpretador   : $ps ($($PSVersionTable.PSVersion))"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Host 'AVISO: git nao encontrado.' -ForegroundColor Yellow }
$temClaude = [bool](Get-Command claude -ErrorAction SilentlyContinue)
if (-not $temClaude) { Write-Host 'AVISO: comando "claude" nao encontrado: o Passo 2 (plugins) sera pulado. Veja install/README.md, secao 2.' -ForegroundColor Yellow }
if ($ps -eq 'powershell' -and -not $IsWindows -and $PSVersionTable.PSEdition -ne 'Desktop') { throw 'Em macOS/Linux o PowerShell 7 (pwsh) e obrigatorio.' }
if ($SoSimular) { Write-Host 'Modo -SoSimular: nada sera gravado.' -ForegroundColor Yellow }

Titulo 'Passo 1 - Arquivo da maquina'
$maquina = Join-Path $Destino 'maquina.md'
if (Test-Path -LiteralPath $maquina) {
    Write-Host "Ja existe: $maquina (nao sera tocado)."
} elseif ($SoSimular) {
    Write-Host "(-SoSimular) criaria $maquina a partir de core/maquina.example.md."
} else {
    New-Item -ItemType Directory -Force $Destino | Out-Null
    Copy-Item (Join-Path $repo 'core/maquina.example.md') $maquina
    Write-Host "Criado: $maquina. Abra e preencha pastas, clone e projetos (sem segredos)." -ForegroundColor Green
}

Titulo 'Passo 2 - Plugins'
if ($PularPlugins -or -not $temClaude) {
    Write-Host 'Pulado. Faca depois: /plugin marketplace add <clone> ; /plugin install base@kit-dev-ia (e dotnet, angular).'
} elseif ($SoSimular) {
    Write-Host "(-SoSimular) rodaria: claude plugin marketplace add `"$repo`" ; claude plugin install base|dotnet|angular@kit-dev-ia"
} elseif (Pergunta 'Adicionar o marketplace kit-dev-ia e instalar base, dotnet e angular?') {
    & claude plugin marketplace add $repo
    foreach ($p in 'base', 'dotnet', 'angular') { & claude plugin install "$p@kit-dev-ia" }
    Write-Host 'Plugins processados. Confira com /plugin dentro do Claude Code.' -ForegroundColor Green
} else {
    Write-Host 'Pulado.'
}

Titulo 'Passo 3 - CLAUDE.md global e agente Explore'
Write-Host 'Atencao: o ~/.claude/CLAUDE.md e substituido inteiro (com backup). Mova regras de projeto/cliente antes.' -ForegroundColor Yellow
[void](DryRunEConfirma 'CLAUDE.md e Explore' 'instalar-arquivos.ps1' @('-Destino', $Destino))

Titulo 'Passo 4 - Settings (permissoes, modelo, marketplace)'
$argsSettings = @('-Target', (Join-Path $Destino 'settings.json'))
if ($Perfil) { $argsSettings += @('-Perfil', ($Perfil -join ',')) }
if ($ManterEscalares) { $argsSettings += '-ManterEscalares' }
[void](DryRunEConfirma 'settings.json' 'merge-settings.ps1' $argsSettings)

Titulo 'Passo 5 - Validar'
Write-Host 'Feche e reabra o Claude Code e confira (tabela completa em install/README.md, secao 5):'
Write-Host '  - "rode echo .env"        -> bloqueado pelo hook'
Write-Host '  - "rode git -C . push"    -> pede confirmacao'
Write-Host '  - /plugin                 -> base ligado'
Write-Host '  - /agents                 -> Explore (usuario) + agentes base:*'
Write-Host "Backups: $Destino/settings.json.bak-* e $Destino/backups/instalar-*/"
