# Gera o inventario do pacote a partir dos proprios arquivos (fonte unica): plugins, skills, agentes, camadas,
# perfis e contagem de permissoes. Saida padrao: plugins/base/skills/env-guide/componentes.md (lido pela skill
# env-guide sob demanda e linkado pelo README). Nao editar a saida a mao: rodar este script e commitar.
# O teste tests/estrutura.Tests.ps1 falha se a saida commitada estiver desatualizada.
param([string]$Saida)
$ErrorActionPreference = 'Stop'
$raiz = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
if (-not $Saida) { $Saida = Join-Path $raiz 'plugins/base/skills/env-guide/componentes.md' }
$utf8 = New-Object Text.UTF8Encoding $false

function Read-Json([string]$f) { [IO.File]::ReadAllText($f, $utf8) | ConvertFrom-Json }
function Get-Front([string]$f) {
    $t = [IO.File]::ReadAllText($f, $utf8)
    $h = [ordered]@{}
    if ($t -match '(?s)^---\r?\n(.*?)\r?\n---') {
        foreach ($l in ($Matches[1] -split '\r?\n')) { if ($l -match '^([\w-]+):\s*(.*)$') { $h[$Matches[1]] = $Matches[2].Trim() } }
    }
    $h
}
function Format-Celula([string]$s) { ($s -replace '\|', '\|').Trim() }
# Ordem ordinal (independente da cultura do sistema): a saída precisa ser igual no Windows, no Linux e no CI.
function Sort-Ordinal {
    [object[]]$itens = @($input)
    [Array]::Sort($itens, [Comparison[object]] { param($a, $b) [string]::CompareOrdinal($a.Name, $b.Name) })
    $itens
}

$o = New-Object Collections.Generic.List[string]
$o.Add('# Componentes do pacote (gerado)')
$o.Add('')
$o.Add('> Gerado por `scripts/gerar-docs.ps1` a partir dos arquivos do repositório. Não editar à mão.')
$o.Add('')

$mkt = Read-Json (Join-Path $raiz '.claude-plugin/marketplace.json')
$o.Add("## Plugins (marketplace ``$($mkt.name)``)")
$o.Add('')
$o.Add('| Plugin | Ligado por padrão | Descrição |')
$o.Add('|---|---|---|')
foreach ($p in $mkt.plugins) {
    $ligado = if ($p.PSObject.Properties['defaultEnabled'] -and -not $p.defaultEnabled) { 'não (ligar por projeto)' } else { 'sim' }
    $o.Add("| ``$($p.name)`` | $ligado | $(Format-Celula $p.description) |")
}

foreach ($p in $mkt.plugins) {
    $dir = Join-Path $raiz ($p.source -replace '^\./', '')
    $o.Add('')
    $o.Add("### Plugin ``$($p.name)``")
    $skills = @(Get-ChildItem -LiteralPath (Join-Path $dir 'skills') -Directory -ErrorAction SilentlyContinue | Sort-Ordinal)
    if ($skills) {
        $o.Add('')
        $o.Add('| Skill | Invocação | Descrição |')
        $o.Add('|---|---|---|')
        foreach ($s in $skills) {
            $h = Get-Front (Join-Path $s.FullName 'SKILL.md')
            $inv = if ($h['disable-model-invocation'] -eq 'true') { "só ``/$($h['name'])``" } else { 'automática + `/' + $h['name'] + '`' }
            $o.Add("| ``$($h['name'])`` | $inv | $(Format-Celula $h['description']) |")
        }
    }
    $agentes = @(Get-ChildItem -LiteralPath (Join-Path $dir 'agents') -File -Filter *.md -ErrorAction SilentlyContinue | Sort-Ordinal)
    if ($agentes) {
        $o.Add('')
        $o.Add('| Agente | Modelo | Ferramentas | Descrição |')
        $o.Add('|---|---|---|---|')
        foreach ($a in $agentes) {
            $h = Get-Front $a.FullName
            $o.Add("| ``$($h['name'])`` | ``$($h['model'])`` | $(Format-Celula $h['tools']) | $(Format-Celula $h['description']) |")
        }
    }
    $hooks = Join-Path $dir 'hooks/hooks.json'
    if (Test-Path -LiteralPath $hooks) {
        $j = Read-Json $hooks
        $o.Add('')
        foreach ($ev in $j.hooks.PSObject.Properties) {
            foreach ($g in @($ev.Value)) { $o.Add("Hook: ``$($ev.Name)`` (matcher ``$($g.matcher)``) → ``$($g.hooks[0].command)``") }
        }
    }
}

$o.Add('')
$o.Add('## Core (instalado por `scripts/instalar-arquivos.ps1`)')
$o.Add('')
$o.Add('| Arquivo | Descrição |')
$o.Add('|---|---|')
$o.Add('| `core/CLAUDE.md` | Instruções globais (' + @([IO.File]::ReadAllLines((Join-Path $raiz 'core/CLAUDE.md'), $utf8)).Count + ' linhas) |')
foreach ($a in Get-ChildItem -LiteralPath (Join-Path $raiz 'core/agents') -File -Filter *.md | Sort-Ordinal) {
    $h = Get-Front $a.FullName
    $o.Add("| ``core/agents/$($a.Name)`` | agente ``$($h['name'])`` (``$($h['model'])``): $(Format-Celula $h['description']) |")
}

$s = Read-Json (Join-Path $raiz 'core/settings.merge.json')
$o.Add('')
$o.Add('## Permissões (`core/settings.merge.json`)')
$o.Add('')
$o.Add("Modelo ``$($s.model)``, advisor ``$($s.advisorModel)``. Regras: $(@($s.permissions.allow).Count) allow, $(@($s.permissions.ask).Count) ask, $(@($s.permissions.deny).Count) deny. Política por classe de operação: README, seção Permissões.")

$o.Add('')
$o.Add('## Perfis (`profiles/`, `merge-settings.ps1 -Perfil <nome>`)')
$o.Add('')
foreach ($d in Get-ChildItem -LiteralPath (Join-Path $raiz 'profiles') -Directory | Sort-Ordinal) {
    $j = Read-Json (Join-Path $d.FullName 'settings.json')
    $chaves = ($j.PSObject.Properties.Name | ForEach-Object { '`' + $_ + '`' }) -join ', '
    $o.Add('- `' + $d.Name + '`: chaves ' + $chaves)
}

$o.Add('')
$o.Add('## Camadas de projeto (`project-templates/`)')
$o.Add('')
$o.Add('| Camada | Plugins | Deny | Regras por caminho | Outros arquivos |')
$o.Add('|---|---|---|---|---|')
foreach ($d in Get-ChildItem -LiteralPath (Join-Path $raiz 'project-templates') -Directory | Sort-Ordinal) {
    $f = Join-Path $d.FullName '.claude/settings.json'
    $plugins = '-'; $deny = '-'
    if (Test-Path -LiteralPath $f) {
        $j = Read-Json $f
        if ($j.enabledPlugins) { $plugins = ($j.enabledPlugins.PSObject.Properties.Name | ForEach-Object { '`' + $_ + '`' }) -join ', ' }
        if ($j.permissions.deny) { $deny = '' + @($j.permissions.deny).Count + ' regra(s)' }
    }
    $regras = @(Get-ChildItem -LiteralPath (Join-Path $d.FullName '.claude/rules') -File -ErrorAction SilentlyContinue | ForEach-Object { '`' + $_.Name + '`' }) -join ', '
    $outros = @(Get-ChildItem -LiteralPath $d.FullName -Force | Where-Object { $_.Name -ne '.claude' } | ForEach-Object { '`' + $_.Name + '`' }) -join ', '
    $o.Add("| ``$($d.Name)`` | $plugins | $deny | $(if ($regras) { $regras } else { '-' }) | $(if ($outros) { $outros } else { '-' }) |")
}

$texto = ($o -join "`n") + "`n"
New-Item -ItemType Directory -Force -Path (Split-Path $Saida) | Out-Null
[IO.File]::WriteAllText($Saida, $texto, $utf8)
Write-Host "OK: $Saida"
