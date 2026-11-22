# Pester 5+. O pacote não pode carregar segredo nem dado de cliente.
# Termos proibidos (nomes de cliente, hosts, produtos) NUNCA ficam no repositório: vêm de um arquivo externo
# (CCS_TERMOS_PROIBIDOS_ARQUIVO ou <pasta-pai>/docs/claude-code-setup/termos-proibidos.txt) ou da variável
# CCS_TERMOS_PROIBIDOS (termos separados por ;). Sem lista, o teste fica PULADO — nunca aprovado.
BeforeAll {
    $script:raiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).ProviderPath
    $script:arquivos = @(git -C $script:raiz ls-files --cached --others --exclude-standard |
        Where-Object { $_ -notmatch '\.(pdf|png|jpg)$' } | ForEach-Object { Join-Path $script:raiz $_ })
}

Describe 'Conteúdo do pacote' {
    It 'sem segredo com cara de valor real (chave privada, token, connection string com senha)' {
        $padroes = @(
            '-----BEGIN [A-Z ]*PRIVATE KEY-----',
            '\bsk-ant-[\w-]{20,}', '\bsk-[A-Za-z0-9]{32,}', '\bgh[pousr]_[A-Za-z0-9]{30,}', '\bxox[abp]-[\w-]{20,}',
            '\bAKIA[0-9A-Z]{16}\b', '(?i)(password|pwd)\s*=\s*[^;"\s<>{}$]{6,};', '(?i)mongodb(\+srv)?://[^/\s:@]+:[^/\s@<]+@'
        )
        $achados = foreach ($f in $script:arquivos) {
            $n = 0
            foreach ($l in [IO.File]::ReadAllLines($f)) {
                $n++
                foreach ($p in $padroes) { if ($l -match $p) { "$($f.Substring($script:raiz.Length + 1)):$n (padrão $p)" } }
            }
        }
        @($achados) | Should -BeNullOrEmpty
    }

    It 'sem PDF, docs/pendencias.md nem workers/ rastreados (material do repositório privado)' {
        $rastreados = @(git -C $script:raiz ls-files)
        @($rastreados | Where-Object { $_ -match '(?i)\.pdf$' -or $_ -eq 'docs/pendencias.md' -or $_ -match '^workers/' }) | Should -BeNullOrEmpty
    }

    It 'workflow: actions por SHA completo, Pester em versão exata e CLI claude fixada' {
        $wf = [IO.File]::ReadAllText((Join-Path $script:raiz '.github/workflows/tests.yml'), [Text.Encoding]::UTF8)
        $usos = [regex]::Matches($wf, '(?m)^\s*-?\s*uses:\s*(\S+)') | ForEach-Object { $_.Groups[1].Value }
        @($usos).Count | Should -BeGreaterThan 0
        foreach ($u in $usos) { $u | Should -Match '@[0-9a-f]{40}$' -Because "action sem SHA completo: $u" }
        $wf | Should -Match 'Install-Module Pester -RequiredVersion \d+\.\d+\.\d+'
        $wf | Should -Not -Match 'MinimumVersion|MaximumVersion'
        $wf | Should -Match "CLAUDE_CODE_VERSION: '\d+\.\d+\.\d+'"
        $wf | Should -Match 'CCS_EXIGE_CLI'
    }

    It 'marketplace kit-dev-ia fixado por ref nos dois settings' {
        foreach ($rel in 'core/settings.merge.json', 'project-templates/_base/.claude/settings.json') {
            $j = [IO.File]::ReadAllText((Join-Path $script:raiz $rel), [Text.Encoding]::UTF8) | ConvertFrom-Json
            $j.extraKnownMarketplaces.'kit-dev-ia'.source.ref | Should -Match '^v\d+\.\d+\.\d+$|^[0-9a-f]{40}$' -Because $rel
        }
    }

    It 'modelo de fontes da LGPD existe, com validade de 30 dias, sem data real e sem conteúdo jurídico copiado' {
        $m = Join-Path $script:raiz 'plugins/base/skills/lgpd-audit/fontes-modelo.md'
        Test-Path -LiteralPath $m | Should -BeTrue
        $t = [IO.File]::ReadAllText($m, [Text.Encoding]::UTF8)
        $t | Should -Match 'verificado-em: AAAA-MM-DD'
        $t | Should -Match 'validade-dias: 30'
        $t | Should -Not -Match 'verificado-em: \d{4}-\d{2}-\d{2}' -Because 'o modelo não carrega data real'
        $skill = [IO.File]::ReadAllText((Join-Path $script:raiz 'plugins/base/skills/lgpd-audit/SKILL.md'), [Text.Encoding]::UTF8)
        $skill | Should -Match 'fontes-modelo\.md' -Because 'a Etapa 0 aponta para o modelo'
        $skill | Should -Match 'atualizar-fontes'
    }

    It 'sem termos proibidos (lista externa ao repositório)' {
        $lista = @()
        if ($env:CCS_TERMOS_PROIBIDOS) { $lista = $env:CCS_TERMOS_PROIBIDOS -split ';' }
        else {
            $arq = if ($env:CCS_TERMOS_PROIBIDOS_ARQUIVO) { $env:CCS_TERMOS_PROIBIDOS_ARQUIVO } else { Join-Path (Split-Path $script:raiz) 'docs/claude-code-setup/termos-proibidos.txt' }
            if (Test-Path -LiteralPath $arq) { $lista = [IO.File]::ReadAllLines($arq) }
        }
        $lista = @($lista | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') })
        if (-not $lista -and $env:CI -eq 'true') { throw 'No CI a lista de termos proibidos não pode ficar vazia (CCS_TERMOS_PROIBIDOS no workflow).' }
        if (-not $lista) { Set-ItResult -Skipped -Because 'lista de termos proibidos ausente (criada pelo usuário, fora do repositório)'; return }
        # Nunca imprimir o termo: só arquivo:linha e o índice do termo na lista.
        # O workflow carrega a lista genérica mínima do CI; ele não entra na varredura.
        $achados = foreach ($f in ($script:arquivos | Where-Object { $_ -notmatch '[\\/]\.github[\\/]workflows[\\/]' })) {
            $n = 0
            foreach ($l in [IO.File]::ReadAllLines($f)) {
                $n++
                for ($i = 0; $i -lt $lista.Count; $i++) {
                    if ($l.IndexOf($lista[$i], [StringComparison]::OrdinalIgnoreCase) -ge 0) { "$($f.Substring($script:raiz.Length + 1)):$n (termo nº $($i + 1))" }
                }
            }
        }
        @($achados) | Should -BeNullOrEmpty
    }
}
