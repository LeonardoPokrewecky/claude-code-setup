# Instala CLAUDE.md, agents, skills e hooks do pacote (global\) em ~\.claude sem substituir nada em silencio.
# O CLAUDE.md global e substituido inteiro: o dry-run avisa e mostra o diff; o original vai para o backup.
# maquina.example.md nao e instalado (cada maquina cria o seu ~/.claude/maquina.md; README, Passo 2).
# Fluxo obrigatorio em 2 passos, igual ao merge-settings.ps1:
#   1. -DryRun lista cada arquivo como NOVO, ALTERADO ou IGUAL com o SHA-256 de origem e destino, mostra o diff
#      dos ALTERADOS e um codigo de confirmacao.
#   2. -Confirmar <codigo> copia NOVOS e ALTERADOS. ALTERADO tem backup em <Destino>\backups\instalar-<data-hora>\
#      antes; cada copia e conferida pelo SHA-256. Codigo muda se o pacote ou o destino mudar depois do dry-run.
# Arquivo que so existe no destino nao e tocado. O hook bloquear-segredos pede aprovacao ao ver -Confirmar.
param(
    [string]$Destino = "$env:USERPROFILE\.claude",
    [switch]$DryRun,
    [string]$Confirmar
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object Text.UTF8Encoding $false   # diff com acento legivel no PowerShell 5.1
$origem = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\global')).ProviderPath
$Destino = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destino)

function Get-Sha([string]$caminho) { (Get-FileHash -LiteralPath $caminho -Algorithm SHA256).Hash.ToLower() }

$arquivos = @(Get-Item -LiteralPath (Join-Path $origem 'CLAUDE.md')) + @(foreach ($pasta in 'agents', 'skills', 'hooks') {
    Get-ChildItem -LiteralPath (Join-Path $origem $pasta) -Recurse -File | Sort-Object FullName
})
$itens = foreach ($arq in $arquivos) {
    $arq | ForEach-Object {
        $rel = $_.FullName.Substring($origem.Length + 1)
        $dest = Join-Path $Destino $rel
        $shaOrigem = Get-Sha $_.FullName
        $shaDestino = if (Test-Path -LiteralPath $dest) { Get-Sha $dest } else { $null }
        [pscustomobject]@{
            Status     = if (-not $shaDestino) { 'NOVO' } elseif ($shaDestino -eq $shaOrigem) { 'IGUAL' } else { 'ALTERADO' }
            Rel        = $rel
            Origem     = $_.FullName
            Destino    = $dest
            ShaOrigem  = $shaOrigem
            ShaDestino = $shaDestino
        }
    }
}
$pendentes = @($itens | Where-Object Status -ne 'IGUAL')

$sha = [Security.Cryptography.SHA256]::Create()
$plano = $Destino + "`n" + (($pendentes | ForEach-Object { "$($_.Rel)|$($_.ShaOrigem)|$($_.ShaDestino)" }) -join "`n")
$codigo = (-join ($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($plano)) | ForEach-Object { $_.ToString('x2') })).Substring(0, 12)

function Show-Plano {
    Write-Host "Destino: $Destino"
    foreach ($i in $itens) {
        $linha = '{0,-8} {1}  origem {2}  destino {3}' -f $i.Status, $i.Rel, $i.ShaOrigem.Substring(0, 16), $(if ($i.ShaDestino) { $i.ShaDestino.Substring(0, 16) } else { '-' })
        if ($i.Status -eq 'IGUAL') { Write-Host $linha } else { Write-Host $linha -ForegroundColor Yellow }
    }
}

if (-not $pendentes) {
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
        Write-Host '  O original fica em backups\instalar-<data-hora>\CLAUDE.md.' -ForegroundColor Yellow
    }
    Write-Host "`n$($pendentes.Count) arquivo(s) a gravar (NOVO/ALTERADO acima). Revise e rode de novo com: -Confirmar $codigo"
    return
}

if (-not $Confirmar) { throw 'Instalacao exige revisao: rode antes com -DryRun e depois com -Confirmar <codigo> mostrado no dry-run.' }
if ($Confirmar -ne $codigo) { throw 'Codigo de confirmacao nao confere: o pacote ou o destino mudou depois do dry-run. Rode -DryRun de novo e revise.' }

$backup = Join-Path $Destino "backups\instalar-$(Get-Date -Format yyyyMMdd-HHmmss)"
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
if (@($pendentes | Where-Object Status -eq 'ALTERADO')) { Write-Host "Backup dos substituidos: $backup" }
Write-Host "OK: $($pendentes.Count) arquivo(s) instalado(s) e conferido(s) por SHA-256."
