# Hook SessionStart aviso-core.sh: compara core-versao.txt instalado (~/.claude) com o do plugin. Nunca bloqueia.
BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'Invoke-Hook.ps1')
    $temSh = [bool](Get-ShParaHook)
}

BeforeAll {
    $script:raiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).ProviderPath
    $script:utf8 = New-Object Text.UTF8Encoding $false
    . (Join-Path $PSScriptRoot 'Invoke-Hook.ps1')
    $script:sh = Get-ShParaHook

    # Roda o script com um plugin falso e um HOME falso. $plugin/$instalada: $null = arquivo ausente.
    function Invoke-Aviso($plugin, $instalada, [byte[]]$instaladaBytes) {
        $d = Join-Path ([IO.Path]::GetTempPath()) ('aviso-' + [guid]::NewGuid().ToString('N'))
        $pl = Join-Path $d 'plugin'; $home_ = Join-Path $d 'home'
        New-Item -ItemType Directory -Force -Path (Join-Path $pl 'hooks'), (Join-Path $home_ '.claude') | Out-Null
        Copy-Item (Join-Path $script:raiz 'plugins/base/hooks/aviso-core.sh') (Join-Path $pl 'hooks/aviso-core.sh')
        if ($null -ne $plugin) { [IO.File]::WriteAllText((Join-Path $pl 'core-versao.txt'), $plugin, $script:utf8) }
        if ($null -ne $instaladaBytes) { [IO.File]::WriteAllBytes((Join-Path $home_ '.claude/core-versao.txt'), $instaladaBytes) }
        elseif ($null -ne $instalada) { [IO.File]::WriteAllText((Join-Path $home_ '.claude/core-versao.txt'), $instalada, $script:utf8) }

        $psi = New-Object Diagnostics.ProcessStartInfo
        $psi.FileName = $script:sh
        $psi.Arguments = '"' + ((Join-Path $pl 'hooks/aviso-core.sh') -replace '\\', '/') + '"'
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
        $psi.EnvironmentVariables['CLAUDE_PLUGIN_ROOT'] = ($pl -replace '\\', '/')
        $psi.EnvironmentVariables['HOME'] = ($home_ -replace '\\', '/')
        $p = [Diagnostics.Process]::Start($psi)
        $saida = $p.StandardOutput.ReadToEnd(); $null = $p.StandardError.ReadToEnd(); $p.WaitForExit()
        Remove-Item -LiteralPath $d -Recurse -Force
        [pscustomobject]@{ Saida = $saida; Codigo = $p.ExitCode }
    }
}

Describe 'versão do core/' {
    It 'core/core-versao.txt e plugins/base/core-versao.txt são iguais e inteiros' {
        $a = [IO.File]::ReadAllText((Join-Path $script:raiz 'core/core-versao.txt'), $script:utf8).Trim()
        $b = [IO.File]::ReadAllText((Join-Path $script:raiz 'plugins/base/core-versao.txt'), $script:utf8).Trim()
        $a | Should -Match '^\d+$'
        $b | Should -Be $a -Because 'mexeu em core/? suba a versão nos dois arquivos'
    }

    It 'hooks.json registra o SessionStart apontando para aviso-core.sh, sem remover o PreToolUse' {
        $h = (Get-Content (Join-Path $script:raiz 'plugins/base/hooks/hooks.json') -Raw | ConvertFrom-Json).hooks
        $h.SessionStart[0].hooks[0].command | Should -Match 'aviso-core\.sh'
        $h.PreToolUse | Should -Not -BeNullOrEmpty
    }

    It 'o instalador instala core-versao.txt' {
        (Get-Content (Join-Path $script:raiz 'scripts/instalar-arquivos.ps1') -Raw) | Should -Match "core-versao\.txt'\)"
    }
}

Describe 'aviso-core.sh' -Skip:(-not $temSh) {
    It 'versão igual: silêncio e código 0' {
        $r = Invoke-Aviso "2`n" "2`n"
        $r.Codigo | Should -Be 0; $r.Saida | Should -BeNullOrEmpty
    }
    It 'instalada maior: silêncio' {
        $r = Invoke-Aviso '2' '5'
        $r.Codigo | Should -Be 0; $r.Saida | Should -BeNullOrEmpty
    }
    It 'instalada menor: systemMessage com as duas versões' {
        $r = Invoke-Aviso '3' '1'
        $r.Codigo | Should -Be 0
        $j = $r.Saida | ConvertFrom-Json
        $j.systemMessage | Should -Match 'v1'
        $j.systemMessage | Should -Match 'v3'
        $j.systemMessage | Should -Match 'instalar-arquivos\.ps1 -DryRun'
    }
    It 'instalada ausente: avisa que não foi possível comparar' {
        $r = Invoke-Aviso '2' $null
        $r.Codigo | Should -Be 0
        ($r.Saida | ConvertFrom-Json).systemMessage | Should -Match 'nao foi possivel comparar'
    }
    It 'arquivo do plugin ausente: silêncio e código 0' {
        $r = Invoke-Aviso $null '1'
        $r.Codigo | Should -Be 0; $r.Saida | Should -BeNullOrEmpty
    }
    It 'conteúdo não numérico no plugin: silêncio; na instalada: trata como ausente' {
        (Invoke-Aviso 'abc' '1').Saida | Should -BeNullOrEmpty
        $r = Invoke-Aviso '2' 'abc'
        $r.Codigo | Should -Be 0
        ($r.Saida | ConvertFrom-Json).systemMessage | Should -Match 'nao foi possivel comparar'
    }
    It 'instalada com BOM e CRLF é lida normalmente' {
        $bytes = [byte[]](0xEF, 0xBB, 0xBF) + $script:utf8.GetBytes("2`r`n")
        $r = Invoke-Aviso '2' $null $bytes
        $r.Codigo | Should -Be 0; $r.Saida | Should -BeNullOrEmpty
    }
}
