# Pester 5. Testa o merge-settings.ps1 num settings temporário (nunca no ~/.claude real).
BeforeAll {
    $script:merge = Join-Path $PSScriptRoot '..\scripts\merge-settings.ps1'
    $script:utf8 = New-Object Text.UTF8Encoding $false

    $script:ps = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh' } else { 'powershell' }
    function Invoke-Merge([string]$alvo, [string[]]$extra) {
        $saida = & $script:ps -NoProfile -ExecutionPolicy Bypass -File $script:merge -Target $alvo @extra *>&1 | Out-String
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

    It '-ManterEscalares preserva o modelo, -Remover tira item e chave, hook legado sai com ALERTA' {
        $alvo = New-Alvo
        $args1 = @('-ManterEscalares', '-Remover', 'permissions.allow[]=Bash(winget:*),env.CLAUDE_CODE_SUBAGENT_MODEL')
        $r = Invoke-Merge $alvo (@('-DryRun') + $args1)
        $r.Texto | Should -Match 'MANTIDO  model'
        $r.Texto | Should -Match 'ALERTA: 1 protecao'
        $r.Texto | Should -Match 'bloquear-segredos'
        $r.Codigo | Should -Not -BeNullOrEmpty
        $g = Invoke-Merge $alvo (@('-Confirmar', $r.Codigo) + $args1)
        $g.Texto | Should -Match 'OK:'

        $s = [IO.File]::ReadAllText($alvo, $script:utf8) | ConvertFrom-Json
        $s.model | Should -Be 'opus'
        @($s.permissions.allow) | Should -Not -Contain 'Bash(winget:*)'
        @($s.permissions.allow) | Should -Contain 'Bash(git status:*)'
        $s.env.PSObject.Properties['CLAUDE_CODE_SUBAGENT_MODEL'] | Should -BeNullOrEmpty
        $s.PSObject.Properties['hooks'] | Should -BeNullOrEmpty
        $s.enabledPlugins.'base@kit-dev-ia' | Should -BeTrue
        @($s.permissions.allow) | Should -Contain 'PowerShell(dotnet test)'
        @($s.permissions.deny) | Should -Contain 'Read(**/.env)'
        @($s.permissions.deny) | Should -Not -Contain 'Read(**/appsettings.Development.json)'
        Test-Path "$alvo.bak-*" | Should -BeTrue
    }

    It 'Hook de outro script no mesmo evento é preservado; só o legado sai' {
        $alvo = New-Alvo
        $s = [IO.File]::ReadAllText($alvo, $script:utf8) | ConvertFrom-Json
        $s.hooks.PreToolUse[0].hooks += [pscustomobject]@{ type = 'command'; command = 'node meu-hook.js' }
        [IO.File]::WriteAllText($alvo, ($s | ConvertTo-Json -Depth 10), $script:utf8)
        $r = Invoke-Merge $alvo @('-DryRun')
        Invoke-Merge $alvo @('-Confirmar', $r.Codigo) | Out-Null
        $d = [IO.File]::ReadAllText($alvo, $script:utf8) | ConvertFrom-Json
        @($d.hooks.PreToolUse[0].hooks).Count | Should -Be 1
        $d.hooks.PreToolUse[0].hooks[0].command | Should -Be 'node meu-hook.js'
    }

    It 'Remover deny gera ALERTA' {
        $alvo = New-Alvo
        $r1 = Invoke-Merge $alvo @('-DryRun')
        Invoke-Merge $alvo @('-Confirmar', $r1.Codigo) | Out-Null
        $r2 = Invoke-Merge $alvo @('-DryRun', '-Remover', 'permissions.deny[]=Read(**/.env)')
        $r2.Texto | Should -Match 'ALERTA: 1 protecao'
    }

    It '-Perfil unix soma o sandbox; entradas que só restringem não geram alerta, allow gera' {
        $alvo = New-Alvo
        $r = Invoke-Merge $alvo @('-DryRun', '-Perfil', 'unix')
        $r.Codigo | Should -Not -BeNullOrEmpty
        $r.Texto | Should -Not -Match '\+ sandbox\.'
        $r.Texto | Should -Match '\+ permissions\.allow\[\]=Bash\(dotnet test\)'
        Invoke-Merge $alvo @('-Confirmar', $r.Codigo, '-Perfil', 'unix') | Out-Null
        $s = [IO.File]::ReadAllText($alvo, $script:utf8) | ConvertFrom-Json
        $s.sandbox.enabled | Should -BeTrue
        @($s.sandbox.credentials.files | Where-Object path -eq '~/.ssh').Count | Should -Be 1
    }

    It 'Sandbox com tipo errado é recusado antes de gravar' {
        $alvo = New-Alvo
        $s = [IO.File]::ReadAllText($alvo, $script:utf8) | ConvertFrom-Json
        $s | Add-Member -NotePropertyName sandbox -NotePropertyValue ([pscustomobject]@{ enabled = 'sim' })
        [IO.File]::WriteAllText($alvo, ($s | ConvertTo-Json -Depth 10), $script:utf8)
        $r = Invoke-Merge $alvo @('-DryRun')
        $r.Texto | Should -Match 'sandbox\.enabled deve ser true/false'
        $r.Codigo | Should -BeNullOrEmpty
    }

    It '-Remover inexistente recusa sem gravar' {
        $alvo = New-Alvo
        $r = Invoke-Merge $alvo @('-DryRun', '-Remover', 'nao.existe')
        $r.Texto | Should -Match 'Remover sem efeito'
        $r.Codigo | Should -BeNullOrEmpty
    }
}
