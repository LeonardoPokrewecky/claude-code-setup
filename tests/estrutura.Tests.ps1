# Pester 5+. Estrutura do pacote: marketplace, plugins, skills, agentes, hooks, regras, documentação gerada e links.
BeforeDiscovery {
    $raiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).ProviderPath
    $skills = @(Get-ChildItem -LiteralPath (Join-Path $raiz 'plugins') -Recurse -Filter SKILL.md | ForEach-Object { @{ Arquivo = $_.FullName; Pasta = $_.Directory.Name } })
    $agentes = @(Get-ChildItem -LiteralPath (Join-Path $raiz 'plugins'), (Join-Path $raiz 'core/agents') -Recurse -Filter *.md |
        Where-Object { $_.Directory.Name -eq 'agents' } | ForEach-Object { @{ Arquivo = $_.FullName; Nome = $_.BaseName } })
    $markdowns = @(git -C $raiz ls-files --cached --others --exclude-standard '*.md' | ForEach-Object { @{ Arquivo = (Join-Path $raiz $_); Rel = $_ } })
}

BeforeAll {
    $script:raiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).ProviderPath
    $script:utf8 = New-Object Text.UTF8Encoding $false
    function Read-Json([string]$f) { [IO.File]::ReadAllText($f, $script:utf8) | ConvertFrom-Json }
    function Get-Front([string]$f) {
        $t = [IO.File]::ReadAllText($f, $script:utf8)
        $h = @{}
        if ($t -match '(?s)^---\r?\n(.*?)\r?\n---') {
            foreach ($l in ($Matches[1] -split '\r?\n')) { if ($l -match '^([\w-]+):\s*(.*)$') { $h[$Matches[1]] = $Matches[2].Trim() } }
        }
        $h
    }
}

Describe 'Marketplace e plugins' {
    It 'marketplace.json tem name, owner e plugins; cada source existe e o nome bate com o plugin.json' {
        $m = Read-Json (Join-Path $raiz '.claude-plugin/marketplace.json')
        $m.name | Should -Not -BeNullOrEmpty
        $m.owner.name | Should -Not -BeNullOrEmpty
        @($m.plugins).Count | Should -BeGreaterThan 0
        foreach ($p in $m.plugins) {
            $p.source | Should -Match '^\./' -Because 'source relativo começa com ./'
            $p.source | Should -Not -Match '\.\.' -Because 'source não pode sair do marketplace'
            $dir = Join-Path $raiz ($p.source -replace '^\./', '')
            Test-Path -LiteralPath $dir | Should -BeTrue -Because "$($p.source) deve existir"
            (Read-Json (Join-Path $dir '.claude-plugin/plugin.json')).name | Should -Be $p.name
        }
    }

    It 'hooks.json de plugin aponta para arquivos que existem e usa ${CLAUDE_PLUGIN_ROOT}' {
        foreach ($h in Get-ChildItem -LiteralPath (Join-Path $raiz 'plugins') -Recurse -Filter hooks.json) {
            $plugin = Split-Path (Split-Path $h.FullName)
            foreach ($cmd in ([regex]::Matches([IO.File]::ReadAllText($h.FullName), '\$\{CLAUDE_PLUGIN_ROOT\}/([^"\\]+)') | ForEach-Object { $_.Groups[1].Value })) {
                Test-Path -LiteralPath (Join-Path $plugin $cmd) | Should -BeTrue -Because "$cmd citado em $($h.FullName)"
            }
        }
    }

    It 'hook de segredos: no Windows o powershell 5.1 vem antes do pwsh (abre mais rápido) e o código de saída é conferido (falha fechada)' {
        $cmd = (Read-Json (Join-Path $raiz 'plugins/base/hooks/hooks.json')).hooks.PreToolUse[0].hooks[0].command
        $windows = $cmd.IndexOf('[ "$OS" = "Windows_NT" ] && command -v powershell')
        $windows | Should -BeGreaterOrEqual 0 -Because 'o primeiro ramo testa OS=Windows_NT e o powershell'
        $windows | Should -BeLessThan $cmd.IndexOf('command -v pwsh')
        $cmd | Should -Not -Match '\bexec\b' -Because 'exec devolve o código bruto do interpretador, que o Claude Code trata como não bloqueante'
        $cmd | Should -Match 'case "\$r" in 0\|2\)' -Because '0 e 2 passam; qualquer outro código vira confirmação'
        $ponte = [IO.File]::ReadAllText((Join-Path $raiz 'plugins/base/hooks/run-hook.sh'), $script:utf8)
        $ponte | Should -Not -Match '(?m)^\s*exec\b' -Because 'sem exec o código de saída do PowerShell é conferido'
        $ponte.IndexOf('[ "$OS" = "Windows_NT" ] && command -v powershell') | Should -BeLessThan $ponte.IndexOf('command -v pwsh')
        $ponte.IndexOf('[ "$OS" = "Windows_NT" ] && command -v powershell') | Should -BeGreaterOrEqual 0
    }

    It 'claude plugin validate passa no marketplace e em cada plugin (quando o CLI existe)' {
        if (-not (Get-Command claude -ErrorAction SilentlyContinue) -and ($env:CI -eq 'true' -or $env:CCS_EXIGE_CLI)) { throw 'CLI claude ausente no CI: o workflow deve instalá-la (não pular em silêncio).' }
        if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { Set-ItResult -Skipped -Because 'CLI claude ausente'; return }
        foreach ($alvo in @('.') + @(Get-ChildItem -LiteralPath (Join-Path $raiz 'plugins') -Directory | ForEach-Object { "plugins/$($_.Name)" })) {
            $saida = & claude plugin validate (Join-Path $raiz $alvo) 2>&1 | Out-String
            $LASTEXITCODE | Should -Be 0 -Because $saida
            $saida | Should -Match 'Validation passed'
        }
    }
}

Describe 'Skills' {
    It 'frontmatter de <Pasta>: name igual à pasta e description presente' -ForEach $skills {
        $h = Get-Front $Arquivo
        $h['name'] | Should -Be $Pasta
        $h['description'] | Should -Not -BeNullOrEmpty
        ($h['description'] + ' ' + $h['when_to_use']).Length | Should -BeLessOrEqual 1536 -Because 'limite da listagem de skills'
    }

    It 'skill automática <Pasta> (sem disable-model-invocation) tem descrição de até 200 caracteres' -ForEach $skills {
        $h = Get-Front $Arquivo
        if ($h['disable-model-invocation'] -eq 'true') { Set-ItResult -Skipped -Because 'skill manual'; return }
        $h['description'].Length | Should -BeLessOrEqual 200 -Because 'a descrição fica sempre no contexto'
    }

    It 'as 6 skills de gatilho no meio da tarefa não têm a flag manual' {
        foreach ($n in 'entrega-sem-pendencia', 'gestao-de-segredos', 'autenticacao-e-sessao', 'integracoes', 'modelagem-dados', 'resposta-a-incidente') {
            $h = Get-Front (Join-Path $raiz "plugins/base/skills/$n/SKILL.md")
            $h['disable-model-invocation'] | Should -BeNullOrEmpty -Because "$n deve ativar sozinha"
        }
    }

    It 'argument-hint de <Pasta>, se existir, é texto entre aspas (YAML lê [ ... ] sem aspas como lista)' -ForEach $skills {
        $linha = @([IO.File]::ReadAllLines($Arquivo) | Where-Object { $_ -match '^argument-hint:' })
        foreach ($l in $linha) { $l | Should -Not -Match '^argument-hint:\s*\[' }
    }

    It '/revisar tem o modo PR: modo-pr.md referenciado e pr no argument-hint' {
        $pasta = Join-Path $raiz 'plugins/base/skills/revisar'
        Test-Path -LiteralPath (Join-Path $pasta 'modo-pr.md') | Should -BeTrue
        $skill = [IO.File]::ReadAllText((Join-Path $pasta 'SKILL.md'))
        $skill | Should -Match '\(modo-pr\.md\)'
        $skill | Should -Match 'argument-hint:\s*"\[auto\|pr\|'
    }
}

Describe 'Agentes' {
    It 'frontmatter de <Nome>: name, description e model válido' -ForEach $agentes {
        $h = Get-Front $Arquivo
        $h['name'] | Should -Be $Nome
        $h['description'] | Should -Not -BeNullOrEmpty
        $h['model'] | Should -BeIn @('haiku', 'sonnet', 'opus', 'fable', 'inherit')
    }

    It 'descrição de <Nome> tem até 150 caracteres' -ForEach $agentes {
        (Get-Front $Arquivo)['description'].Length | Should -BeLessOrEqual 150
    }

    It 'revisão nunca em Haiku: agentes de revisão herdam ou usam modelo forte' {
        foreach ($a in Get-ChildItem -LiteralPath (Join-Path $raiz 'plugins') -Recurse -Filter 'revisor*.md') {
            (Get-Front $a.FullName)['model'] | Should -Not -Be 'haiku'
        }
    }
}

Describe 'Core e settings' {
    It 'core/CLAUDE.md tem no máximo 40 linhas' {
        @([IO.File]::ReadAllLines((Join-Path $raiz 'core/CLAUDE.md'))).Count | Should -BeLessOrEqual 40
    }

    It 'toda regra Bash(...) de allow/ask tem a versão PowerShell(...) correspondente' {
        $s = Read-Json (Join-Path $raiz 'core/settings.merge.json')
        foreach ($lista in 'allow', 'ask') {
            $regras = @($s.permissions.$lista)
            foreach ($b in $regras | Where-Object { $_ -like 'Bash(*' }) {
                $nome = $b -replace '^Bash\(', 'PowerShell('
                # Comandos só de Unix sem equivalente usual no PowerShell ficam de fora.
                if ($b -match '^Bash\((nc|ncat|bash -c|sh -c|del|rmdir|python3 -c|pip3 install)') { continue }
                $regras | Should -Contain $nome -Because "$b em $lista"
            }
        }
    }

    It 'nenhum allow libera rede, instalação, push ou exclusão' {
        $s = Read-Json (Join-Path $raiz 'core/settings.merge.json')
        foreach ($a in @($s.permissions.allow)) {
            $a | Should -Not -Match '(push|install|curl|wget|ssh|rm |Remove-Item|npx|run \*|run:\*|^Bash\(\*\)|^PowerShell\(\*\))'
        }
    }

    It 'ações que alteram um PR pelo gh pedem confirmação (Bash e PowerShell)' {
        $ask = @((Read-Json (Join-Path $raiz 'core/settings.merge.json')).permissions.ask)
        foreach ($acao in 'merge', 'review', 'comment', 'close', 'edit', 'ready') {
            foreach ($ferramenta in 'Bash', 'PowerShell') { $ask | Should -Contain "$ferramenta(gh pr ${acao}:*)" }
        }
    }

    It 'cada camada tem settings.json válido ou README que explica o uso' {
        foreach ($d in Get-ChildItem -LiteralPath (Join-Path $raiz 'project-templates') -Directory) {
            $f = Join-Path $d.FullName '.claude/settings.json'
            if (Test-Path -LiteralPath $f) { { Read-Json $f } | Should -Not -Throw }
            else { Test-Path -LiteralPath (Join-Path $d.FullName 'README.md') | Should -BeTrue -Because $d.Name }
        }
    }

    It 'regras por caminho têm frontmatter paths' {
        foreach ($r in Get-ChildItem -LiteralPath (Join-Path $raiz 'project-templates') -Recurse -Filter *.md | Where-Object { $_.Directory.Name -eq 'rules' }) {
            [IO.File]::ReadAllText($r.FullName) | Should -Match '(?s)^---\r?\npaths:'
        }
    }
}

Describe 'Documentação' {
    It 'componentes.md, comandos.md e indice-skills.md gerados estão atualizados (rode scripts/gerar-docs.ps1)' {
        $id = [guid]::NewGuid().ToString('n')
        $tmp = Join-Path ([IO.Path]::GetTempPath()) "componentes-$id.md"
        $tmpComandos = Join-Path ([IO.Path]::GetTempPath()) "comandos-$id.md"
        $tmpIndice = Join-Path ([IO.Path]::GetTempPath()) "indice-$id.md"
        $ps = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh' } else { 'powershell' }
        # As saídas vão para a pasta temporária: o teste nunca grava nos arquivos commitados.
        & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $raiz 'scripts/gerar-docs.ps1') -Saida $tmp -SaidaComandos $tmpComandos -SaidaIndice $tmpIndice | Out-Null
        try {
            foreach ($par in @(@($tmp, 'plugins/base/skills/env-guide/componentes.md'), @($tmpComandos, 'plugins/base/skills/comandos/comandos.md'), @($tmpIndice, 'core/indice-skills.md'))) {
                $gerado = [IO.File]::ReadAllText($par[0]) -replace '\r\n', "`n"
                $commitado = [IO.File]::ReadAllText((Join-Path $raiz $par[1])) -replace '\r\n', "`n"
                $commitado | Should -Be $gerado -Because "$($par[1]) desatualizado"
            }
        } finally { Remove-Item -LiteralPath $tmp, $tmpComandos, $tmpIndice -Force -ErrorAction SilentlyContinue }
    }

    It 'indice-skills.md: toda skill manual aparece uma vez, com "quando usar" de até 70 caracteres' {
        $d = Import-PowerShellDataFile -LiteralPath (Join-Path $raiz 'scripts/areas-skills.psd1')
        $manuais = @(Get-ChildItem -LiteralPath (Join-Path $raiz 'plugins') -Recurse -Filter SKILL.md |
            Where-Object { (Get-Front $_.FullName)['disable-model-invocation'] -eq 'true' } | ForEach-Object { (Get-Front $_.FullName)['name'] })
        @($d.Skills.Keys | Sort-Object) | Should -Be @($manuais | Sort-Object)
        foreach ($n in $manuais) {
            $d.Skills[$n].Area | Should -BeIn $d.Areas -Because "area de $n"
            $d.Skills[$n].Quando.Length | Should -BeIn (1..70) -Because "quando usar de $n"
        }
        $linhas = @([IO.File]::ReadAllLines((Join-Path $raiz 'core/indice-skills.md'), $script:utf8) | Where-Object { $_ -match '^- `/' })
        $linhas.Count | Should -Be $manuais.Count
    }

    It 'core/CLAUDE.md importa o indice-skills.md e o instalador o instala' {
        [IO.File]::ReadAllText((Join-Path $raiz 'core/CLAUDE.md'), $script:utf8) | Should -Match '@~/\.claude/indice-skills\.md'
        [IO.File]::ReadAllText((Join-Path $raiz 'scripts/instalar-arquivos.ps1'), $script:utf8) | Should -Match 'indice-skills\.md'
    }

    It 'comandos.md lista toda skill uma vez, com resumo de 1 a 80 caracteres' {
        $linhas = @([IO.File]::ReadAllLines((Join-Path $raiz 'plugins/base/skills/comandos/comandos.md'), $script:utf8) | Where-Object { $_ -match '^\| `/' })
        $nomes = @($linhas | ForEach-Object { ([regex]::Match($_, '^\| `/([^`]+)`')).Groups[1].Value })
        $skills = @(Get-ChildItem -LiteralPath (Join-Path $raiz 'plugins') -Recurse -Filter SKILL.md | ForEach-Object { (Get-Front $_.FullName)['name'] })
        ($nomes | Sort-Object) -join ',' | Should -Be (($skills | Sort-Object) -join ',')
        foreach ($l in $linhas) {
            $resumo = (($l -split '\|')[2]).Trim() -replace ' \(também automática\)$', ''
            $resumo.Length | Should -BeIn (1..80) -Because "resumo em: $l"
        }
    }

    It 'links relativos de <Rel> apontam para arquivos que existem' -ForEach $markdowns {
        $texto = [IO.File]::ReadAllText($Arquivo)
        $texto = [regex]::Replace($texto, '(?s)```.*?```', '')
        foreach ($m in [regex]::Matches($texto, '\]\(([^)\s#]+)(#[^)]*)?\)')) {
            $alvo = $m.Groups[1].Value
            if ($alvo -match '^(https?:|mailto:)') { continue }
            Test-Path -LiteralPath (Join-Path (Split-Path $Arquivo) $alvo) | Should -BeTrue -Because "link $alvo em $Rel"
        }
    }
}
