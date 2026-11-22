# Pester 5. Rodar: Invoke-Pester ./tests -Output Detailed   (shell do hook: $env:HOOK_SHELL = 'pwsh' | 'powershell')
BeforeDiscovery {
    $casos = (Import-PowerShellDataFile (Join-Path $PSScriptRoot 'casos-hook.psd1')).Casos
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'Invoke-Hook.ps1')
    function New-PastaTemporariaDeTeste {
        $p = Join-Path ([IO.Path]::GetTempPath()) "hook-teste-$([guid]::NewGuid().ToString('n'))"
        New-Item -ItemType Directory -Path $p | Out-Null
        $p
    }
    # Interpretador falso (script sh com o nome do executável); o corpo decide o código de saída.
    function New-InterpretadorFalso([string]$Pasta, [string]$Nome, [string]$Corpo) {
        $arquivo = Join-Path $Pasta $Nome
        [IO.File]::WriteAllText($arquivo, "#!/bin/sh`n$Corpo`n", (New-Object Text.UTF8Encoding $false))
        if ($IsLinux -or $IsMacOS) { chmod +x $arquivo }
    }
}

Describe 'Hook bloquear-segredos' {
    It '<Esperado>: <Comando>' -ForEach $casos {
        $r = Invoke-Hook -Comando $Comando
        $r.Resultado | Should -Be $Esperado -Because "saída: $($r.Saida) $($r.Erro)"
    }

    It 'Pela ponte run-hook.sh (como o plugin chama): <Esperado>: <Comando>' -ForEach @(
        @{ Comando = 'cat .env'; Esperado = 'Bloqueia' }
        @{ Comando = 'git -C . push'; Esperado = 'Confirma' }
        @{ Comando = 'git status'; Esperado = 'Libera' }
    ) {
        if (-not (Get-ShParaHook)) { Set-ItResult -Skipped -Because 'sh não encontrado (Git Bash ausente)'; return }
        $r = Invoke-Hook -Comando $Comando -ViaSh
        $r.Resultado | Should -Be $Esperado -Because "saída: $($r.Saida) $($r.Erro)"
    }

    It 'No Windows, o sh escolhe o powershell 5.1 mesmo com pwsh no PATH (<Via>)' -ForEach @(
        @{ Via = 'hooks.json' }
        @{ Via = 'run-hook.sh' }
    ) {
        if ($IsLinux -or $IsMacOS) { Set-ItResult -Skipped -Because 'regra só do Windows (fora dele o pwsh vem primeiro)'; return }
        if (-not (Get-ShParaHook)) { Set-ItResult -Skipped -Because 'sh não encontrado (Git Bash ausente)'; return }
        # pwsh falso que sai com 99: se for escolhido, o resultado vira Erro(99) em vez de Bloqueia.
        $pasta = Join-Path ([IO.Path]::GetTempPath()) "pwsh-falso-$([guid]::NewGuid().ToString('n'))"
        New-Item -ItemType Directory -Path $pasta | Out-Null
        [IO.File]::WriteAllText((Join-Path $pasta 'pwsh'), "#!/bin/sh`nexit 99`n", (New-Object Text.UTF8Encoding $false))
        try {
            $parametros = @{ Comando = 'cat .env'; PathPrefixo = $pasta }
            if ($Via -eq 'hooks.json') { $parametros.ViaSh = $true } else { $parametros.ViaPonte = $true }
            $r = Invoke-Hook @parametros
            $r.Resultado | Should -Be 'Bloqueia' -Because "o pwsh falso não pode ser chamado no Windows; saída: $($r.Saida) $($r.Erro)"
        } finally { Remove-Item -LiteralPath $pasta -Recurse -Force }
    }

    # Falha fechada na ponte: o Claude Code libera o comando quando o hook sai com código diferente de 0 e 2.
    It 'Interpretador que não executa o hook (código <Codigo>) pede confirmação (<Via>)' -ForEach @(
        foreach ($c in 1, 64, 127, 255) { foreach ($v in 'hooks.json', 'run-hook.sh') { @{ Codigo = $c; Via = $v } } }
    ) {
        if (-not (Get-ShParaHook)) { Set-ItResult -Skipped -Because 'sh não encontrado (Git Bash ausente)'; return }
        $pasta = New-PastaTemporariaDeTeste
        # powershell e pwsh falsos: o que o sh escolher sai com o código do caso.
        foreach ($nome in 'powershell', 'pwsh') { New-InterpretadorFalso $pasta $nome "exit $Codigo" }
        try {
            $parametros = @{ Comando = 'cat .env'; PathPrefixo = $pasta }
            if ($Via -eq 'hooks.json') { $parametros.ViaSh = $true } else { $parametros.ViaPonte = $true }
            $r = Invoke-Hook @parametros
            $r.Resultado | Should -Be 'Confirma' -Because "saída: $($r.Saida) $($r.Erro)"
            $r.Saida | Should -Match "código de saída $Codigo"
            $r.Saida | Should -Match '"permissionDecision":"ask"'
        } finally { Remove-Item -LiteralPath $pasta -Recurse -Force }
    }

    It 'Script do hook ausente pede confirmação em vez de liberar (<Via>)' -ForEach @(
        @{ Via = 'hooks.json' }
        @{ Via = 'run-hook.sh' }
    ) {
        if (-not (Get-ShParaHook)) { Set-ItResult -Skipped -Because 'sh não encontrado (Git Bash ausente)'; return }
        # Cópia do plugin só com a ponte e o hooks.json: sem o bloquear-segredos.ps1.
        $raiz = New-PastaTemporariaDeTeste
        $fonte = Join-Path $PSScriptRoot '../plugins/base/hooks'
        New-Item -ItemType Directory -Path (Join-Path $raiz 'hooks') | Out-Null
        Copy-Item -LiteralPath (Join-Path $fonte 'run-hook.sh'), (Join-Path $fonte 'hooks.json') -Destination (Join-Path $raiz 'hooks')
        try {
            $parametros = @{ Comando = 'git status'; RaizPlugin = $raiz }
            if ($Via -eq 'hooks.json') { $parametros.ViaSh = $true } else { $parametros.ViaPonte = $true }
            $r = Invoke-Hook @parametros
            $r.Resultado | Should -Be 'Confirma' -Because "saída: $($r.Saida) $($r.Erro)"
            $r.Saida | Should -Match 'não executou o hook'
        } finally { Remove-Item -LiteralPath $raiz -Recurse -Force }
    }

    It 'Código 2 do interpretador continua bloqueando, com o motivo no stderr (<Via>)' -ForEach @(
        @{ Via = 'hooks.json' }
        @{ Via = 'run-hook.sh' }
    ) {
        if (-not (Get-ShParaHook)) { Set-ItResult -Skipped -Because 'sh não encontrado (Git Bash ausente)'; return }
        $pasta = New-PastaTemporariaDeTeste
        foreach ($nome in 'powershell', 'pwsh') { New-InterpretadorFalso $pasta $nome "echo 'motivo do bloqueio' >&2`nexit 2" }
        try {
            $parametros = @{ Comando = 'git status'; PathPrefixo = $pasta }
            if ($Via -eq 'hooks.json') { $parametros.ViaSh = $true } else { $parametros.ViaPonte = $true }
            $r = Invoke-Hook @parametros
            $r.Resultado | Should -Be 'Bloqueia'
            $r.Erro | Should -Match 'motivo do bloqueio'
        } finally { Remove-Item -LiteralPath $pasta -Recurse -Force }
    }

    It 'Fora do Windows (OS ausente, como no WSL) nunca chama powershell/powershell.exe: sem pwsh, pede confirmação (<Via>)' -ForEach @(
        @{ Via = 'hooks.json' }
        @{ Via = 'run-hook.sh' }
    ) {
        if (-not (Get-ShParaHook)) { Set-ItResult -Skipped -Because 'sh não encontrado (Git Bash ausente)'; return }
        $pasta = New-PastaTemporariaDeTeste
        $marca = Join-Path $pasta 'chamado.txt'
        $marcaSh = $marca -replace '\\', '/'
        foreach ($nome in 'powershell', 'powershell.exe') { New-InterpretadorFalso $pasta $nome "echo chamado > `"$marcaSh`"`nexit 0" }
        try {
            # PATH só com os falsos (sem pwsh real): o único caminho correto é "não encontrado" → confirmação.
            $parametros = @{ Comando = 'cat .env'; PathExato = $pasta; SemOS = $true }
            if ($Via -eq 'hooks.json') { $parametros.ViaSh = $true } else { $parametros.ViaPonte = $true }
            $r = Invoke-Hook @parametros
            Test-Path -LiteralPath $marca | Should -BeFalse -Because 'powershell só vale com OS=Windows_NT'
            $r.Resultado | Should -Be 'Confirma' -Because "saída: $($r.Saida) $($r.Erro)"
            $r.Saida | Should -Match 'não encontrado'
        } finally { Remove-Item -LiteralPath $pasta -Recurse -Force }
    }

    It 'Sem nenhum PowerShell no PATH pede confirmação (<Via>)' -ForEach @(
        @{ Via = 'hooks.json' }
        @{ Via = 'run-hook.sh' }
    ) {
        if (-not (Get-ShParaHook)) { Set-ItResult -Skipped -Because 'sh não encontrado (Git Bash ausente)'; return }
        $pasta = New-PastaTemporariaDeTeste   # PATH só com a pasta vazia: nenhum pwsh/powershell visível (sh por caminho absoluto)
        try {
            $parametros = @{ Comando = 'cat .env'; PathExato = $pasta }
            if ($Via -eq 'hooks.json') { $parametros.ViaSh = $true } else { $parametros.ViaPonte = $true }
            $r = Invoke-Hook @parametros
            $r.Resultado | Should -Be 'Confirma' -Because "saída: $($r.Saida) $($r.Erro)"
            $r.Saida | Should -Match 'PowerShell .pwsh ou powershell. não encontrado'
        } finally { Remove-Item -LiteralPath $pasta -Recurse -Force }
    }

    It 'Entrada ilegível pede confirmação (falha fechada), sem ecoar a entrada' -ForEach @(
        @{ Entrada = 'isto não é json'; Eco = 'isto não é json' }
        @{ Entrada = ''; Eco = $null }
        @{ Entrada = '   '; Eco = $null }
    ) {
        $hook = Join-Path $PSScriptRoot '../plugins/base/hooks/bloquear-segredos.ps1'
        $shell = if ($env:HOOK_SHELL) { $env:HOOK_SHELL } elseif ($IsLinux -or $IsMacOS) { 'pwsh' } else { 'powershell' }
        $saida = ($Entrada | & $shell -NoProfile -ExecutionPolicy Bypass -File $hook) -join ''
        $LASTEXITCODE | Should -Be 0
        $saida | Should -Match '"permissionDecision"\s*:\s*"ask"'
        $saida | Should -Match 'entrada do hook ileg.{1,3}vel .JSON'
        if ($Eco) { $saida | Should -Not -Match ([regex]::Escape($Eco)) }
    }

    It 'JSON válido sem comando libera (nada a verificar)' -ForEach @(
        @{ Entrada = '{"tool_input":{}}' }
        @{ Entrada = '{"hook_event_name":"PreToolUse"}' }
    ) {
        $hook = Join-Path $PSScriptRoot '../plugins/base/hooks/bloquear-segredos.ps1'
        $shell = if ($env:HOOK_SHELL) { $env:HOOK_SHELL } elseif ($IsLinux -or $IsMacOS) { 'pwsh' } else { 'powershell' }
        $saida = ($Entrada | & $shell -NoProfile -ExecutionPolicy Bypass -File $hook) -join ''
        $LASTEXITCODE | Should -Be 0
        $saida.Trim() | Should -BeNullOrEmpty
    }

    It 'JSON com BOM é lido normalmente' {
        $hook = Join-Path $PSScriptRoot '../plugins/base/hooks/bloquear-segredos.ps1'
        $shell = if ($env:HOOK_SHELL) { $env:HOOK_SHELL } elseif ($IsLinux -or $IsMacOS) { 'pwsh' } else { 'powershell' }
        $saida = ([string][char]0xFEFF + '{"tool_input":{"command":"git status"}}' | & $shell -NoProfile -ExecutionPolicy Bypass -File $hook) -join ''
        $LASTEXITCODE | Should -Be 0
        $saida.Trim() | Should -BeNullOrEmpty
    }

    It 'Falha interna depois do parse pede confirmação em vez de liberar' {
        $original = Join-Path $PSScriptRoot '..\plugins\base\hooks\bloquear-segredos.ps1'
        $copia = Join-Path ([IO.Path]::GetTempPath()) "hook-falha-$([guid]::NewGuid().ToString('n')).ps1"
        $texto = [IO.File]::ReadAllText($original)
        $ancora = 'if ([string]::IsNullOrWhiteSpace($comando)) { exit 0 }'
        $texto.Contains($ancora) | Should -BeTrue
        [IO.File]::WriteAllText($copia, $texto.Replace($ancora, "$ancora`nthrow 'falha simulada'"), (New-Object Text.UTF8Encoding $true))
        try {
            $r = Invoke-Hook -Comando 'git status' -Hook $copia
            $r.Resultado | Should -Be 'Confirma'
            $r.Saida | Should -Match 'falha interna do hook'
        } finally { Remove-Item -LiteralPath $copia -Force }
    }
}
