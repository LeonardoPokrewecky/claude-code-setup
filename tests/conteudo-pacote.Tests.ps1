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

    It 'sem termos proibidos (lista externa ao repositório)' {
        $lista = @()
        if ($env:CCS_TERMOS_PROIBIDOS) { $lista = $env:CCS_TERMOS_PROIBIDOS -split ';' }
        else {
            $arq = if ($env:CCS_TERMOS_PROIBIDOS_ARQUIVO) { $env:CCS_TERMOS_PROIBIDOS_ARQUIVO } else { Join-Path (Split-Path $script:raiz) 'docs/claude-code-setup/termos-proibidos.txt' }
            if (Test-Path -LiteralPath $arq) { $lista = [IO.File]::ReadAllLines($arq) }
        }
        $lista = @($lista | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') })
        if (-not $lista) { Set-ItResult -Skipped -Because 'lista de termos proibidos ausente (criada pelo usuário, fora do repositório)'; return }
        # Nunca imprimir o termo: só arquivo:linha e o índice do termo na lista.
        $achados = foreach ($f in $script:arquivos) {
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
