# Pester 5. Rodar: Invoke-Pester ./tests -Output Detailed   (shell do hook: $env:HOOK_SHELL = 'pwsh' | 'powershell')
BeforeDiscovery {
    $casos = (Import-PowerShellDataFile (Join-Path $PSScriptRoot 'casos-hook.psd1')).Casos
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'Invoke-Hook.ps1')
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

    It 'JSON inválido libera (o hook nunca trava a sessão)' {
        $hook = Join-Path $PSScriptRoot '../plugins/base/hooks/bloquear-segredos.ps1'
        $shell = if ($env:HOOK_SHELL) { $env:HOOK_SHELL } elseif ($IsLinux -or $IsMacOS) { 'pwsh' } else { 'powershell' }
        'isto não é json' | & $shell -NoProfile -ExecutionPolicy Bypass -File $hook | Out-Null
        $LASTEXITCODE | Should -Be 0
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
