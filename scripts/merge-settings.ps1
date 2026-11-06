# Mescla settings sem apagar o que ja existe: objetos mesclam por propriedade, arrays viram uniao, escalares sobrescrevem.
# Global (padrao):  merge-settings.ps1 [-Target <settings.json>] [-Perfil unix] -> core/settings.merge.json
# Camadas:          merge-settings.ps1 -Target <repo>\.claude\settings.json -Layers _base,dotnet,angular
#                   (cada camada = project-templates\<nome>\.claude\settings.json; -Target e obrigatorio)
# Fluxo obrigatorio em 2 passos (nada e gravado sem o usuario ver o resultado):
#   1. -DryRun mostra o JSON final (valores com nome de segredo mascarados), os ALERTAS (toda entrada nova que nao
#      seja deny/ask/plugin desligado) e um codigo de confirmacao.
#   2. -Confirmar <codigo> grava. O codigo e o hash do alvo + resultado: se o pacote ou o alvo mudar depois
#      do dry-run, o codigo deixa de valer. Grava backup <Target>.bak-AAAAMMDD-HHmmss (nunca sobrescreve) antes.
# O codigo nao distingue usuario de agente: a aprovacao real e o "ask" que o hook bloquear-segredos pede ao ver
# -Confirmar. Sem mudanca no resultado, nada e gravado (nem backup).
# Opcoes:
#   -ManterEscalares   valor escalar que ja existe no alvo vence o do pacote (ex.: seu "model" nao e trocado).
#                      Sem ela, o dry-run lista cada escalar que sera sobrescrito (SOBRESCREVE).
#   -Remover <itens>   remove do resultado: "caminho" apaga a chave (ex.: env.CLAUDE_CODE_SUBAGENT_MODEL) e
#                      "caminho[]=valor" tira um item de lista (ex.: 'permissions.allow[]=Bash(winget:*)').
#                      Remover deny/ask/hook gera ALERTA.
#   -Perfil unix       soma profiles\unix\settings.json (sandbox ligado + credenciais negadas; macOS/Linux/WSL2).
# Hook: vem do plugin base. A entrada antiga do hook no settings e removida no merge (aparece como ALERTA).
param(
    [string]$Target,
    [string[]]$Layers,
    [switch]$DryRun,
    [string]$Confirmar,
    [string[]]$Remover,
    [switch]$ManterEscalares,
    # Perfil de ambiente somado ao settings global: profiles\<nome>\settings.json (ex.: unix = sandbox ligado).
    [ValidateSet('unix')][string[]]$Perfil
)
$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot '..'
# Pasta do usuario em Windows (USERPROFILE) e em macOS/Linux (HOME).
$pastaHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$utf8 = New-Object Text.UTF8Encoding $false

$Layers = @($Layers | ForEach-Object { $_ -split ',' } | Where-Object { $_ })   # -File entrega "a,b" como 1 string
# Mesmo motivo; item com virgula no proprio texto nao e suportado (remover a mao).
$Remover = @($Remover | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
if ($Layers) {
    if (-not $Target) { throw '-Layers exige -Target explicito (nunca grava no settings global por engano).' }
    $sources = $Layers | ForEach-Object {
        $f = Join-Path $root "project-templates/$_/.claude/settings.json"
        if (-not (Test-Path -LiteralPath $f)) { throw "Camada inexistente (ou sem settings.json): $_" }
        $f
    }
} else {
    if (-not $Target) { $Target = Join-Path $pastaHome '.claude/settings.json' }
    $sources = @(Join-Path $root 'core/settings.merge.json')
}
foreach ($p in @($Perfil | Where-Object { $_ })) { $sources += Join-Path $root "profiles/$p/settings.json" }
# Caminho absoluto pelo PowerShell: [IO.File] resolve relativo pelo diretorio do processo, que difere de $PWD apos cd.
$Target = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Target)

# UTF-8 explicito: no PowerShell 5.1 o Get-Content le UTF-8 sem BOM como ANSI e corrompe acentos.
function Read-Json([string]$caminho) { [IO.File]::ReadAllText($caminho, $utf8) | ConvertFrom-Json }

function New-ConjuntoTexto { New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal) }

# Uniao de arrays pela forma JSON de cada item, diferenciando maiusculas: Select-Object -Unique comparava objetos
# pelo texto "@{...}" e @{} ignora caixa (Read(**/A) e Read(**/a) viravam 1).
function Join-Unique($x, $y) {
    $vistos = New-ConjuntoTexto
    ,@(@($x) + @($y) | Where-Object {   # "," impede o PowerShell de desenrolar array de 1 item em escalar
        $vistos.Add($(if ($_ -is [string]) { "s:$_" } else { 'j:' + ($_ | ConvertTo-Json -Compress -Depth 30) }))
    })
}

# Escalares do alvo que o pacote troca (ou que -ManterEscalares preservou): mostrados no dry-run.
$sobrescritos = New-Object Collections.Generic.List[string]
$nomeSegredo = '(?i)(token|secret|passw|pwd|apikey|api_key|auth|credential|cookie|bearer|private|connectionstring|key$)'

function Merge-Json($a, $b, [string]$caminho) {
    foreach ($p in $b.PSObject.Properties) {
        $cur = $a.PSObject.Properties[$p.Name]
        $aqui = if ($caminho) { "$caminho.$($p.Name)" } else { $p.Name }
        if (-not $cur) { $a | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value; continue }
        if ($p.Value -is [pscustomobject] -and $cur.Value -is [pscustomobject]) { Merge-Json $cur.Value $p.Value $aqui }
        elseif ($p.Value -is [array] -and $cur.Value -is [array]) { $cur.Value = Join-Unique $cur.Value $p.Value }
        elseif (($cur.Value | ConvertTo-Json -Compress -Depth 30) -ceq ($p.Value | ConvertTo-Json -Compress -Depth 30)) { }
        else {
            $mostrar = { param($v) if ($p.Name -match $nomeSegredo) { '***' } else { $v | ConvertTo-Json -Compress -Depth 30 } }
            $de = & $mostrar $cur.Value; $para = & $mostrar $p.Value
            if ($ManterEscalares -and $cur.Value -isnot [pscustomobject] -and $cur.Value -isnot [array]) {
                $sobrescritos.Add("MANTIDO  $aqui = $de (pacote: $para)")
            } else {
                $sobrescritos.Add("SOBRESCREVE  $aqui : $de -> $para")
                $cur.Value = $p.Value
            }
        }
    }
}

# Migracao: o hook bloquear-segredos agora vem do plugin base (plugins/base/hooks/hooks.json). A entrada antiga no
# settings (~/.claude/hooks/bloquear-segredos.ps1) faria o hook rodar duas vezes, ou apontaria para arquivo que a
# instalacao nova move para o backup. Sai do alvo e aparece no dry-run como protecao que sai (ALERTA), para o
# usuario conferir que o plugin base esta instalado antes de confirmar.
function Remove-HookLegado($o) {
    if (-not $o.hooks) { return }
    foreach ($ev in @($o.hooks.PSObject.Properties)) {
        $grupos = @(foreach ($g in @($ev.Value)) {
            $g.hooks = @(@($g.hooks) | Where-Object { "$($_.command)" -notmatch '\.claude[/\\]hooks[/\\]bloquear-segredos\.ps1' })
            if ($g.hooks.Count) { $g }
        })
        if ($grupos.Count) { $ev.Value = $grupos } else { $o.hooks.PSObject.Properties.Remove($ev.Name) }
    }
    if (-not @($o.hooks.PSObject.Properties).Count) { $o.PSObject.Properties.Remove('hooks') }
}

# -Remover: "caminho" apaga a chave; "caminho[]=valor" tira o item (texto exato) da lista.
function Remove-Entrada($o, [string]$item) {
    $lista = $item -match '^(.+?)\[\]=(.*)$'
    if ($lista) { $caminho = $Matches[1]; $valor = $Matches[2] } else { $caminho = $item }
    $partes = $caminho -split '\.'
    $pai = $o
    foreach ($parte in $partes[0..($partes.Count - 2)]) {
        if ($partes.Count -eq 1) { break }
        $pai = $pai.PSObject.Properties[$parte].Value
        if ($pai -isnot [pscustomobject]) { return $false }
    }
    $prop = $pai.PSObject.Properties[$partes[-1]]
    if (-not $prop) { return $false }
    if (-not $lista) { $pai.PSObject.Properties.Remove($partes[-1]); return $true }
    if ($prop.Value -isnot [array]) { return $false }
    $novo = @($prop.Value | Where-Object { -not ($_ -is [string] -and $_ -ceq $valor) })
    if ($novo.Count -eq @($prop.Value).Count) { return $false }
    $prop.Value = $novo
    $true
}

# Achata o settings em linhas "caminho=valor"; item de array objeto vira uma linha so (ex.: um hook inteiro).
function Get-Entradas($o, [string]$caminho) {
    if ($o -is [pscustomobject]) {
        foreach ($p in $o.PSObject.Properties) { Get-Entradas $p.Value ($(if ($caminho) { "$caminho.$($p.Name)" } else { $p.Name })) }
    } elseif ($o -is [array]) {
        foreach ($i in $o) {
            if ($i -is [pscustomobject] -or $i -is [array]) { "$caminho[]=" + ($i | ConvertTo-Json -Compress -Depth 30) }
            else { "$caminho[]=$i" }
        }
    } else { "$caminho=$o" }
}

# Lista do que e seguro (so restringe ou desliga), nao do que e perigoso: chave nova desconhecida tambem gera alerta.
# Sandbox: so as entradas que restringem (ligar, falhar sem sandbox, proibir fuga, negar credencial).
$entradasSeguras = '^(\$schema=|permissions\.(deny|ask)\[\]=|enabledPlugins\.[^=]+=False$|sandbox\.(enabled|failIfUnavailable)=True$|sandbox\.allowUnsandboxedCommands=False$|sandbox\.credentials\.(files|envVars)\[\]=\{.*"mode":"deny"\}$)'

# Devolve o indice de cada entrada nova fora da lista segura (o indice localiza a mesma entrada na versao mascarada).
function Get-Alertas($antes, $depois) {
    $conhecidas = New-ConjuntoTexto
    foreach ($e in $antes) { [void]$conhecidas.Add($e) }
    for ($i = 0; $i -lt $depois.Count; $i++) {
        if (-not $conhecidas.Contains($depois[$i]) -and $depois[$i] -notmatch $entradasSeguras) { $i }
    }
}

# Mascara valor de propriedade com nome de segredo e valor com cara de credencial (o dry-run vai para a transcricao).
$valorSegredo = '(?i)^bearer\s|^basic\s|://[^/\s:@]+:[^/\s@]+@|^sk-[\w-]{16,}|^gh[pousr]_\w{20,}|^xox[abp]-'
function Hide-Segredos($o) {
    if ($o -is [pscustomobject]) {
        foreach ($p in $o.PSObject.Properties) {
            if ($p.Value -is [pscustomobject] -or $p.Value -is [array]) { Hide-Segredos $p.Value }
            elseif ($null -ne $p.Value -and ($p.Name -match $nomeSegredo -or "$($p.Value)" -match $valorSegredo)) { $p.Value = '***' }
        }
    } elseif ($o -is [array]) {
        foreach ($i in $o) { if ($i -is [pscustomobject] -or $i -is [array]) { Hide-Segredos $i } }
    }
}

# Recusa estrutura que o Claude Code nao entende antes de gravar (tipo errado vira configuracao ignorada em silencio).
function Test-Estrutura($o) {
    foreach ($k in 'allow', 'deny', 'ask', 'additionalDirectories') {
        $v = $o.permissions.$k
        if ($null -ne $v -and -not ($v -is [array] -and -not @($v | Where-Object { $_ -isnot [string] }))) { "permissions.$k deve ser lista de textos" }
    }
    if ($null -ne $o.permissions.defaultMode -and $o.permissions.defaultMode -isnot [string]) { 'permissions.defaultMode deve ser texto' }
    if ($o.env) { foreach ($p in $o.env.PSObject.Properties) { if ($p.Value -isnot [string]) { "env.$($p.Name) deve ser texto" } } }
    foreach ($k in 'enabled', 'failIfUnavailable', 'allowUnsandboxedCommands', 'autoAllowBashIfSandboxed') {
        if ($null -ne $o.sandbox.$k -and $o.sandbox.$k -isnot [bool]) { "sandbox.$k deve ser true/false" }
    }
    if ($o.enabledPlugins) { foreach ($p in $o.enabledPlugins.PSObject.Properties) { if ($p.Value -isnot [bool]) { "enabledPlugins.$($p.Name) deve ser true/false" } } }
    if ($o.hooks) {
        foreach ($ev in $o.hooks.PSObject.Properties) {
            if ($ev.Value -isnot [array]) { "hooks.$($ev.Name) deve ser lista"; continue }
            foreach ($g in $ev.Value) {
                if ($g.hooks -isnot [array]) { "hooks.$($ev.Name)[].hooks deve ser lista"; continue }
                foreach ($h in $g.hooks) { if (-not $h.type -or ($h.type -eq 'command' -and -not $h.command)) { "hooks.$($ev.Name): hook sem type/command" } }
            }
        }
    }
}

# Hook apontando para arquivo inexistente falha sem bloquear nada: avisar antes de gravar.
function Get-HooksAusentes($o) {
    if (-not $o.hooks) { return }
    foreach ($ev in $o.hooks.PSObject.Properties) {
        foreach ($h in @($ev.Value | ForEach-Object { $_.hooks })) {
            if ("$($h.command)" -match '-File\s+"?([^"]+?\.ps1)') {
                $arq = $Matches[1] -replace '^(\$HOME|~|\$env:USERPROFILE|%USERPROFILE%)', $pastaHome
                if (-not (Test-Path -LiteralPath $arq)) { $arq }
            }
        }
    }
}

$existe = Test-Path -LiteralPath $Target
$textoAtual = if ($existe) { [IO.File]::ReadAllText($Target, $utf8) } else { $null }
$a = if ($existe -and $textoAtual.Trim()) { $textoAtual | ConvertFrom-Json } else { New-Object psobject }
$antes = @(Get-Entradas $a '')
$antesMascarado = @(Get-Entradas $(if ($existe -and $textoAtual.Trim()) { $m = $textoAtual | ConvertFrom-Json; Hide-Segredos $m; $m } else { New-Object psobject }) '')
Remove-HookLegado $a
foreach ($s in $sources) { $pacote = Read-Json $s; Merge-Json $a $pacote '' }
$naoEncontrados = @(foreach ($r in @($Remover | Where-Object { $_ })) { if (-not (Remove-Entrada $a $r)) { $r } })
if ($naoEncontrados.Count) { throw "-Remover sem efeito (caminho ou item inexistente), nada foi gravado:`n  " + ($naoEncontrados -join "`n  ") }

$json = $a | ConvertTo-Json -Depth 30
$resultado = $json | ConvertFrom-Json   # alertas e validacao sobre o que sera gravado, nao sobre o objeto em memoria
$depois = @(Get-Entradas $resultado '')
$erros = @(Test-Estrutura $resultado)
if ($erros.Count) { throw "Resultado invalido, nada foi gravado:`n  " + ($erros -join "`n  ") }
$ausentes = @(Get-HooksAusentes $a)
$alertas = @(Get-Alertas $antes $depois)

$mascarado = $json | ConvertFrom-Json
Hide-Segredos $mascarado
$depoisMascarado = @(Get-Entradas $mascarado '')

# Entradas que saem do alvo (-Remover, escalar sobrescrito, hook reescrito). Sair deny/ask/hook afrouxa a protecao.
$conjuntoDepois = New-ConjuntoTexto
foreach ($e in $depois) { [void]$conjuntoDepois.Add($e) }
$saem = @(for ($i = 0; $i -lt $antes.Count; $i++) { if (-not $conjuntoDepois.Contains($antes[$i])) { $i } })
$saemProtecao = @($saem | Where-Object { $antes[$_] -match '^(permissions\.(deny|ask)\[\]=|hooks\.)' })

$sha = [Security.Cryptography.SHA256]::Create()
$bytes = $utf8.GetBytes($Target + "`n" + $json)
$codigo = (-join ($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') })).Substring(0, 12)

function Show-Alertas {
    if ($alertas.Count) {
        Write-Host "ALERTA: $($alertas.Count) entrada(s) nova(s) fora da lista segura (executa codigo, desvia API, libera acesso ou liga terceiro). Confira cada uma:" -ForegroundColor Yellow
        $alertas | ForEach-Object { Write-Host "  + $($depoisMascarado[$_])" -ForegroundColor Yellow }
    } else { Write-Host 'Sem alertas: nenhuma entrada nova fora da lista segura.' }
    if ($saemProtecao.Count) {
        Write-Host "ALERTA: $($saemProtecao.Count) protecao(oes) sai(em) do alvo (deny/ask/hook). Confira:" -ForegroundColor Yellow
        $saemProtecao | ForEach-Object { Write-Host "  - $($antesMascarado[$_])" -ForegroundColor Yellow }
        if (@($saemProtecao | Where-Object { $antes[$_] -match 'bloquear-segredos\.ps1' }).Count) {
            Write-Host '  O hook bloquear-segredos antigo sai porque agora vem do plugin base. Instale-o ANTES de confirmar:' -ForegroundColor Yellow
            Write-Host '  /plugin marketplace add LeonardoPokrewecky/claude-code-setup  e  /plugin install base@kit-dev-ia' -ForegroundColor Yellow
        }
    }
    $saem | Where-Object { $_ -notin $saemProtecao } | ForEach-Object { Write-Host "  sai: $($antesMascarado[$_])" }
    $sobrescritos | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
    $ausentes | ForEach-Object { Write-Host "AVISO: hook aponta para arquivo inexistente (falharia sem bloquear): $_" -ForegroundColor Yellow }
}

if ($existe -and $textoAtual -ceq $json) {
    Write-Host "Sem alteracoes: $Target ja contem o resultado. Nada a gravar."
    return
}

if ($DryRun) {
    $mascarado | ConvertTo-Json -Depth 30
    Write-Host "Alvo: $Target ($(if ($existe) { 'sera alterado; backup antes' } else { 'sera criado' }))"
    Show-Alertas
    Write-Host "Para gravar, revise o JSON e os alertas acima e rode de novo com: -Confirmar $codigo"
    return
}

if (-not $Confirmar) { throw 'Gravacao exige revisao: rode antes com -DryRun e depois com -Confirmar <codigo> mostrado no dry-run.' }
if ($Confirmar -ne $codigo) { throw 'Codigo de confirmacao nao confere: o pacote ou o alvo mudou depois do dry-run. Rode -DryRun de novo e revise.' }

Show-Alertas
if ($existe) {
    $carimbo = Get-Date -Format yyyyMMdd-HHmmss
    $backup = "$Target.bak-$carimbo"
    for ($n = 1; Test-Path -LiteralPath $backup; $n++) { $backup = "$Target.bak-$carimbo-$n" }
    [IO.File]::Copy($Target, $backup, $false)
    Write-Host "Backup: $backup"
} else { New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null }
[IO.File]::WriteAllText($Target, $json, $utf8)
if ([IO.File]::ReadAllText($Target, $utf8) -cne $json) {
    if ($existe) { [IO.File]::Copy($backup, $Target, $true) }
    throw "Falha ao conferir a gravacao de $Target; conteudo anterior restaurado."
}
Write-Host "OK: $Target atualizado."
