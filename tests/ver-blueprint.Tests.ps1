# Pester 5. Testa o ver-blueprint.ps1 numa pasta temporária, sempre com -NaoAbrir (nunca abre navegador).
BeforeAll {
    $script:alvo = Join-Path $PSScriptRoot '../plugins/base/skills/blueprint/ver-blueprint.ps1'
    $script:utf8 = New-Object Text.UTF8Encoding $false
    $script:ps = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh' } else { 'powershell' }
    function Invoke-Ver([string[]]$argumentos) {
        $ErrorActionPreference = 'Continue'
        $saida = & $script:ps -NoProfile -ExecutionPolicy Bypass -File $script:alvo @argumentos -NaoAbrir *>&1 | Out-String
        [pscustomobject]@{ Texto = $saida; Codigo = $LASTEXITCODE }
    }
    function New-Pasta {
        $d = Join-Path ([IO.Path]::GetTempPath()) "ver-blueprint-$([guid]::NewGuid().ToString('n'))"
        New-Item -ItemType Directory -Path $d | Out-Null
        $d
    }
}

Describe 'ver-blueprint.ps1' {
    It 'gera o .html ao lado do .md, com título, status e acentos preservados' {
        $d = New-Pasta
        $md = Join-Path $d 'teste.md'
        [IO.File]::WriteAllText($md, "# Filtro por período`n`n``Status: RASCUNHO v1```n`n- [ ] item`n", $script:utf8)
        $r = Invoke-Ver @('-Caminho', $md)
        $r.Codigo | Should -Be 0 -Because $r.Texto
        $html = Join-Path $d 'teste.html'
        Test-Path -LiteralPath $html | Should -BeTrue
        $t = [IO.File]::ReadAllText($html, $script:utf8)
        $t | Should -Match '<title>Filtro por período</title>'
        $t | Should -Match 'RASCUNHO v1'
        $t | Should -Match 'lang="pt-BR"'
        Remove-Item -LiteralPath $d -Recurse -Force
    }

    It 'escapa a tag script do texto quando não há ConvertFrom-Markdown' {
        if (Get-Command ConvertFrom-Markdown -ErrorAction SilentlyContinue) { Set-ItResult -Skipped -Because 'caminho de fallback só no Windows PowerShell 5.1'; return }
        $d = New-Pasta
        $md = Join-Path $d 'x.md'
        [IO.File]::WriteAllText($md, "# T`n<script>alert(1)</script>`n", $script:utf8)
        (Invoke-Ver @('-Caminho', $md)).Codigo | Should -Be 0
        $t = [IO.File]::ReadAllText((Join-Path $d 'x.html'), $script:utf8)
        $t | Should -Not -Match '<script>'
        $t | Should -Match '&lt;script&gt;'
        Remove-Item -LiteralPath $d -Recurse -Force
    }

    It 'falha com mensagem clara se o arquivo não existe, sem gravar nada' {
        $d = New-Pasta
        $r = Invoke-Ver @('-Caminho', (Join-Path $d 'nao-existe.md'))
        $r.Codigo | Should -Not -Be 0
        $r.Texto | Should -Match 'não encontrado'
        @(Get-ChildItem -LiteralPath $d).Count | Should -Be 0
        Remove-Item -LiteralPath $d -Recurse -Force
    }

    It 'recusa arquivo que não é .md' {
        $d = New-Pasta
        $txt = Join-Path $d 'a.txt'
        [IO.File]::WriteAllText($txt, 'x', $script:utf8)
        $r = Invoke-Ver @('-Caminho', $txt)
        $r.Codigo | Should -Not -Be 0
        $r.Texto | Should -Match '\.md'
        Test-Path -LiteralPath (Join-Path $d 'a.html') | Should -BeFalse
        Remove-Item -LiteralPath $d -Recurse -Force
    }
}
