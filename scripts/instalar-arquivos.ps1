# Instala o que plugin nao cobre (core/) em ~/.claude sem substituir nada em silencio:
#   - core/CLAUDE.md          -> ~/.claude/CLAUDE.md (substituido inteiro; o dry-run mostra o diff)
#   - core/agents/*.md        -> ~/.claude/agents/ (o Explore com modelo proprio: agente de plugin nao sobrescreve
#                                o Explore embutido, https://code.claude.com/docs/en/sub-agents)
# Skills, agentes e hook ficam nos plugins (plugins/base, plugins/dotnet, plugins/angular), instalados por /plugin.
# Migracao da versao 1 (arquivos copiados em ~/.claude): skills, agentes e hook com o mesmo nome dos plugins sao
# LEGADO; sem a migracao, a copia antiga venceria o comando sem prefixo (/revisar) e o hook rodaria duas vezes.
# O legado vai para o backup (nunca e apagado).
# Fluxo obrigatorio em 2 passos, igual ao merge-settings.ps1:
#   1. -DryRun lista cada arquivo como NOVO, ALTERADO, IGUAL ou LEGADO (com SHA-256), mostra o diff dos ALTERADOS
#      e um codigo de confirmacao.
#   2. -Confirmar <codigo> copia NOVOS e ALTERADOS e move LEGADO para <Destino>/backups/instalar-<data-hora>/.
#      ALTERADO tem backup antes; cada copia e conferida pelo SHA-256. O codigo muda se o pacote ou o destino mudar.
# Arquivo que so existe no destino e nao e legado nao e tocado. O hook bloquear-segredos pede aprovacao ao ver
# -Confirmar.
param(
    [string]$Destino = (Join-Path $(if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }) '.claude'),
    [switch]$DryRun,
    [string]$Confirmar
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object Text.UTF8Encoding $false   # diff com acento legivel no PowerShell 5.1
$raiz = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
$origem = Join-Path $raiz 'core'
$Destino = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destino)

function Get-Sha([string]$caminho) { (Get-FileHash -LiteralPath $caminho -Algorithm SHA256).Hash.ToLower() }

$arquivos = @(Get-Item -LiteralPath (Join-Path $origem 'CLAUDE.md')) +
    @(Get-ChildItem -LiteralPath (Join-Path $origem 'agents') -File | Sort-Object Name)
$itens = foreach ($arq in $arquivos) {
    $rel = $arq.FullName.Substring($origem.Length + 1)
    $dest = Join-Path $Destino $rel
    $shaOrigem = Get-Sha $arq.FullName
    $shaDestino = if (Test-Path -LiteralPath $dest) { Get-Sha $dest } else { $null }
    [pscustomobject]@{
        Status     = if (-not $shaDestino) { 'NOVO' } elseif ($shaDestino -eq $shaOrigem) { 'IGUAL' } else { 'ALTERADO' }
        Rel        = $rel
        Origem     = $arq.FullName
        Destino    = $dest
        ShaOrigem  = $shaOrigem
        ShaDestino = $shaDestino
    }
}

# Nomes da versao 1 que hoje vem dos plugins (lidos dos proprios plugins) + o agente renomeado.
$nomesLegado = @(
    Get-ChildItem -LiteralPath (Join-Path $raiz 'plugins') -Directory | ForEach-Object {
        $p = $_.FullName
        if (Test-Path -LiteralPath "$p/skills") { Get-ChildItem -LiteralPath "$p/skills" -Directory | ForEach-Object { "skills/$($_.Name)" } }
        if (Test-Path -LiteralPath "$p/agents") { Get-ChildItem -LiteralPath "$p/agents" -File | ForEach-Object { "agents/$($_.Name)" } }
    }
    'agents/reviewer-haiku.md'
    'hooks/bloquear-segredos.ps1'
) | Sort-Object -Unique
$legado = @(foreach ($n in $nomesLegado) {
    $d = Join-Path $Destino $n
    if (Test-Path -LiteralPath $d) {
        $sha = if (Test-Path -LiteralPath $d -PathType Leaf) { Get-Sha $d } else {
            -join (Get-ChildItem -LiteralPath $d -Recurse -File | Sort-Object FullName | ForEach-Object { Get-Sha $_.FullName })
        }
        [pscustomobject]@{ Rel = $n; Destino = $d; Sha = $sha }
    }
})
$pendentes = @($itens | Where-Object Status -ne 'IGUAL')

$sha256 = [Security.Cryptography.SHA256]::Create()
$plano = $Destino + "`n" + (($pendentes | ForEach-Object { "$($_.Rel)|$($_.ShaOrigem)|$($_.ShaDestino)" }) -join "`n") +
    "`n" + (($legado | ForEach-Object { "LEGADO|$($_.Rel)|$($_.Sha)" }) -join "`n")
$codigo = (-join ($sha256.ComputeHash([Text.Encoding]::UTF8.GetBytes($plano)) | ForEach-Object { $_.ToString('x2') })).Substring(0, 12)

function Show-Plano {
    Write-Host "Destino: $Destino"
    foreach ($i in $itens) {
        $linha = '{0,-8} {1}  origem {2}  destino {3}' -f $i.Status, $i.Rel, $i.ShaOrigem.Substring(0, 16), $(if ($i.ShaDestino) { $i.ShaDestino.Substring(0, 16) } else { '-' })
        if ($i.Status -eq 'IGUAL') { Write-Host $linha } else { Write-Host $linha -ForegroundColor Yellow }
    }
    foreach ($l in $legado) { Write-Host ('LEGADO   {0}  (vai para o backup; agora vem do plugin)' -f $l.Rel) -ForegroundColor Yellow }
}

if (-not $pendentes -and -not $legado) {
    Show-Plano
    Write-Host 'Nada a instalar: destino ja igual ao pacote.'
    return
}

if ($DryRun) {
    Show-Plano
    foreach ($i in @($pendentes | Where-Object Status -eq 'ALTERADO')) {
        Write-Host "`n--- diff (destino -> pacote): $($i.Rel)" -ForegroundColor Cyan
        if (Get-Command git -ErrorAction SilentlyContinue) {
            git -c core.quotepath=off diff --no-index --no-color -- $i.Destino $i.Origem | ForEach-Object { Write-Host $_ }
        } else {
            Compare-Object (Get-Content -LiteralPath $i.Destino -Encoding UTF8) (Get-Content -LiteralPath $i.Origem -Encoding UTF8) |
                ForEach-Object { Write-Host "$(if ($_.SideIndicator -eq '=>') { '+' } else { '-' }) $($_.InputObject)" }
        }
    }
    $claude = $pendentes | Where-Object { $_.Rel -eq 'CLAUDE.md' -and $_.Status -eq 'ALTERADO' }
    if ($claude) {
        $linhas = @(Get-Content -LiteralPath $claude.Destino -Encoding UTF8).Count
        Write-Host "`nATENCAO: o CLAUDE.md global atual ($linhas linhas) sera SUBSTITUIDO inteiro pelo do pacote." -ForegroundColor Yellow
        Write-Host '  Regras de um projeto ou cliente especifico (deploy, banco, firewall, padroes de equipe) devem ir ANTES' -ForegroundColor Yellow
        Write-Host '  para o CLAUDE.md do repositorio daquele projeto; dados desta maquina vao em ~/.claude/maquina.md.' -ForegroundColor Yellow
        Write-Host '  O original fica em backups/instalar-<data-hora>/CLAUDE.md.' -ForegroundColor Yellow
    }
    if ($legado) {
        Write-Host "`nATENCAO: instale o plugin base ANTES de confirmar (/plugin marketplace add + /plugin install base@kit-dev-ia)," -ForegroundColor Yellow
        Write-Host '  senao as skills, agentes e o hook de segredos ficam indisponiveis ate a instalacao do plugin.' -ForegroundColor Yellow
    }
    Write-Host "`n$($pendentes.Count) arquivo(s) a gravar e $($legado.Count) item(ns) legado(s) para o backup. Revise e rode de novo com: -Confirmar $codigo"
    return
}

if (-not $Confirmar) { throw 'Instalacao exige revisao: rode antes com -DryRun e depois com -Confirmar <codigo> mostrado no dry-run.' }
if ($Confirmar -ne $codigo) { throw 'Codigo de confirmacao nao confere: o pacote ou o destino mudou depois do dry-run. Rode -DryRun de novo e revise.' }

$backup = Join-Path $Destino "backups/instalar-$(Get-Date -Format yyyyMMdd-HHmmss)"
foreach ($i in $pendentes) {
    if ($i.Status -eq 'ALTERADO') {
        $b = Join-Path $backup $i.Rel
        New-Item -ItemType Directory -Force -Path (Split-Path $b) | Out-Null
        [IO.File]::Copy($i.Destino, $b, $false)
    }
    New-Item -ItemType Directory -Force -Path (Split-Path $i.Destino) | Out-Null
    [IO.File]::Copy($i.Origem, $i.Destino, $true)
    if ((Get-Sha $i.Destino) -ne $i.ShaOrigem) { throw "SHA-256 diferente depois de copiar $($i.Rel); backup em $backup." }
    Write-Host "$($i.Status): $($i.Destino)"
}
foreach ($l in $legado) {
    $b = Join-Path (Join-Path $backup 'legado') $l.Rel
    New-Item -ItemType Directory -Force -Path (Split-Path $b) | Out-Null
    Move-Item -LiteralPath $l.Destino -Destination $b
    Write-Host "LEGADO -> backup: $b"
}
if (@($pendentes | Where-Object Status -eq 'ALTERADO') -or $legado) { Write-Host "Backup: $backup" }
Write-Host "OK: $($pendentes.Count) arquivo(s) instalado(s) e conferido(s) por SHA-256; $($legado.Count) legado(s) no backup."
