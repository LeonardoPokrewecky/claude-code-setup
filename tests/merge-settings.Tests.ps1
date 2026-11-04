# Pester 5. Testa o merge-settings.ps1 num settings temporário (nunca no ~/.claude real).
BeforeAll {
    $script:merge = Join-Path $PSScriptRoot '..\scripts\merge-settings.ps1'
    $script:utf8 = New-Object Text.UTF8Encoding $false

    function Invoke-Merge([string]$alvo, [string[]]$extra) {
        $saida = & powershell -NoProfile -ExecutionPolicy Bypass -File $script:merge -Target $alvo @extra *>&1 | Out-String
        [pscustomobject]@{ Texto = $saida; Codigo = $(if ($saida -match '-Confirmar ([0-9a-f]{12})') { $Matches[1] }) }
    }

    function New-Alvo {
        $dir = Join-Path ([IO.Path]::GetTempPath()) "merge-teste-$([guid]::NewGuid().ToString('n'))"
        New-Item -ItemType Directory -Path $dir | Out-Null
        $alvo = Join-Path $dir 'settings.json'
        $inicial = @'
{
  "model": "opus",
  "env": { "CLAUDE_CODE_SUBAGENT_MODEL": "haiku" },
  "permissions": { "allow": [ "Bash(winget:*)", "Bash(git status:*)" ] },
  "hooks": { "PreToolUse": [ { "matcher": "Bash|PowerShell", "hooks": [ { "type": "command",
    "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"$HOME/.claude/hooks/bloquear-segredos.ps1\"", "timeout": 10 } ] } ] }
}
'@
        [IO.File]::WriteAllText($alvo, $inicial, $script:utf8)
        $alvo
    }
}

Describe 'merge-settings.ps1' {
    It 'Dry-run avisa escalar sobrescrito e não grava' {
        $alvo = New-Alvo
        $antes = [IO.File]::ReadAllText($alvo)
        $r = Invoke-Merge $alvo @('-DryRun')
        $r.Texto | Should -Match 'SOBRESCREVE  model : "opus" -> "sonnet"'
        $r.Codigo | Should -Not -BeNullOrEmpty
        [IO.File]::ReadAllText($alvo) | Should -Be $antes
    }

    It '-ManterEscalares preserva o modelo, -Remover tira item e chave, hook vira caminho absoluto sem duplicar' {
        $alvo = New-Alvo
        $args1 = @('-ManterEscalares', '-Remover', 'permissions.allow[]=Bash(winget:*),env.CLAUDE_CODE_SUBAGENT_MODEL')
        $r = Invoke-Merge $alvo (@('-DryRun') + $args1)
        $r.Texto | Should -Match 'MANTIDO  model'
        $r.Codigo | Should -Not -BeNullOrEmpty
        $g = Invoke-Merge $alvo (@('-Confirmar', $r.Codigo) + $args1)
        $g.Texto | Should -Match 'OK:'

        $s = [IO.File]::ReadAllText($alvo, $script:utf8) | ConvertFrom-Json
        $s.model | Should -Be 'opus'
        @($s.permissions.allow) | Should -Not -Contain 'Bash(winget:*)'
        @($s.permissions.allow) | Should -Contain 'Bash(git status:*)'
        $s.env.PSObject.Properties['CLAUDE_CODE_SUBAGENT_MODEL'] | Should -BeNullOrEmpty
        @($s.hooks.PreToolUse).Count | Should -Be 1
        $s.hooks.PreToolUse[0].hooks[0].command | Should -Not -Match '\$HOME'
        $s.hooks.PreToolUse[0].hooks[0].command | Should -Match '/\.claude/hooks/bloquear-segredos\.ps1'
        @($s.permissions.deny) | Should -Contain 'Read(**/.env)'
        @($s.permissions.deny) | Should -Not -Contain 'Read(**/appsettings.Development.json)'
        Test-Path "$alvo.bak-*" | Should -BeTrue
    }

    It 'Remover deny gera ALERTA' {
        $alvo = New-Alvo
        $r1 = Invoke-Merge $alvo @('-DryRun')
        Invoke-Merge $alvo @('-Confirmar', $r1.Codigo) | Out-Null
        $r2 = Invoke-Merge $alvo @('-DryRun', '-Remover', 'permissions.deny[]=Read(**/.env)')
        $r2.Texto | Should -Match 'ALERTA: 1 protecao'
    }

    It '-Remover inexistente recusa sem gravar' {
        $alvo = New-Alvo
        $r = Invoke-Merge $alvo @('-DryRun', '-Remover', 'nao.existe')
        $r.Texto | Should -Match 'Remover sem efeito'
        $r.Codigo | Should -BeNullOrEmpty
    }
}
