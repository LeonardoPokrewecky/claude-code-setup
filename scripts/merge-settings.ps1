# Mescla global\settings.merge.json no settings.json do usuario sem apagar o que ja existe.
# Uso: powershell -ExecutionPolicy Bypass -File scripts\merge-settings.ps1 [-Target <caminho>]
param(
    [string]$Target = "$env:USERPROFILE\.claude\settings.json"
)
$ErrorActionPreference = 'Stop'
$src = Join-Path $PSScriptRoot '..\global\settings.merge.json'

$a = if (Test-Path $Target) { Get-Content $Target -Raw | ConvertFrom-Json } else { New-Object psobject }
$b = Get-Content $src -Raw | ConvertFrom-Json

# Chaves simples: substituem
foreach ($k in 'model', 'advisorModel') {
    $a | Add-Member -NotePropertyName $k -NotePropertyValue $b.$k -Force
}

# Chaves-objeto: mescla propriedade a propriedade (preserva o que ja existe)
foreach ($k in 'env', 'extraKnownMarketplaces', 'enabledPlugins') {
    if (-not $a.$k) { $a | Add-Member -NotePropertyName $k -NotePropertyValue (New-Object psobject) -Force }
    foreach ($p in $b.$k.PSObject.Properties) {
        $a.$k | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force
    }
}

# permissions.deny: uniao sem duplicar
if (-not $a.permissions) { $a | Add-Member -NotePropertyName permissions -NotePropertyValue (New-Object psobject) -Force }
$deny = @()
if ($a.permissions.deny) { $deny += $a.permissions.deny }
$deny += $b.permissions.deny
$a.permissions | Add-Member -NotePropertyName deny -NotePropertyValue @($deny | Select-Object -Unique) -Force

$json = $a | ConvertTo-Json -Depth 30
$null = $json | ConvertFrom-Json   # valida
[IO.File]::WriteAllText($Target, $json, (New-Object Text.UTF8Encoding $false))
Write-Host "OK: $Target atualizado."
