# Mescla settings sem apagar o que ja existe: objetos mesclam por propriedade, arrays viram uniao, escalares sobrescrevem.
# Global (padrao):  merge-settings.ps1 [-Target <settings.json>]            -> global\settings.merge.json
# Camadas:          merge-settings.ps1 -Target <repo>\.claude\settings.json -Layers _base,dotnet,angular
#                   (cada camada = project-templates\<nome>\.claude\settings.json; -Target e obrigatorio)
# -DryRun mostra o resultado sem gravar. Grava backup <Target>.bak-AAAAMMDD antes de alterar.
param(
    [string]$Target,
    [string[]]$Layers,
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot '..'

$Layers = @($Layers | ForEach-Object { $_ -split ',' } | Where-Object { $_ })   # -File entrega "a,b" como 1 string
if ($Layers) {
    if (-not $Target) { throw '-Layers exige -Target explicito (nunca grava no settings global por engano).' }
    $sources = $Layers | ForEach-Object {
        $f = Join-Path $root "project-templates\$_\.claude\settings.json"
        if (-not (Test-Path $f)) { throw "Camada inexistente: $_" }
        $f
    }
} else {
    if (-not $Target) { $Target = "$env:USERPROFILE\.claude\settings.json" }
    $sources = @(Join-Path $root 'global\settings.merge.json')
}

function Merge-Json($a, $b) {
    foreach ($p in $b.PSObject.Properties) {
        $cur = $a.PSObject.Properties[$p.Name]
        if (-not $cur) { $a | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value; continue }
        if ($p.Value -is [pscustomobject] -and $cur.Value -is [pscustomobject]) { Merge-Json $cur.Value $p.Value }
        elseif ($p.Value -is [array] -and $cur.Value -is [array]) { $cur.Value = @(@($cur.Value) + @($p.Value) | Select-Object -Unique) }
        else { $cur.Value = $p.Value }
    }
}

$a = if (Test-Path $Target) { Get-Content $Target -Raw | ConvertFrom-Json } else { New-Object psobject }
foreach ($s in $sources) { Merge-Json $a (Get-Content $s -Raw | ConvertFrom-Json) }

$json = $a | ConvertTo-Json -Depth 30
$null = $json | ConvertFrom-Json   # valida
if ($DryRun) { $json; return }

if (Test-Path $Target) { Copy-Item $Target "$Target.bak-$(Get-Date -Format yyyyMMdd)" -Force }
else { New-Item -ItemType Directory -Force (Split-Path $Target) | Out-Null }
[IO.File]::WriteAllText($Target, $json, (New-Object Text.UTF8Encoding $false))
Write-Host "OK: $Target atualizado."
