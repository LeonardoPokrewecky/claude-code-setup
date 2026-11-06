# Pester 5+. Testa o instalar-arquivos.ps1 num destino temporário (nunca no ~/.claude real).
BeforeAll {
    $script:inst = Join-Path $PSScriptRoot '../scripts/instalar-arquivos.ps1'
    $script:ps = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh' } else { 'powershell' }
    function Invoke-Inst([string]$dest, [string[]]$extra) {
        # O GitHub Actions roda o passo com $ErrorActionPreference = 'Stop'; no PowerShell 5.1 o stderr do git (aviso de CRLF) viraria exceção aqui.
        $ErrorActionPreference = 'Continue'
        $saida = & $script:ps -NoProfile -ExecutionPolicy Bypass -File $script:inst -Destino $dest @extra *>&1 | Out-String
        # Linha: saída numa linha só (o pwsh quebra mensagens de erro na largura do console).
        [pscustomobject]@{ Texto = $saida; Linha = ($saida -replace '\s*\r?\n\s*(\|\s*)?', ' '); Codigo = $(if ($saida -match '-Confirmar ([0-9a-f]{12})') { $Matches[1] }) }
    }
    function New-Destino {
        $d = Join-Path ([IO.Path]::GetTempPath()) "inst-teste-$([guid]::NewGuid().ToString('n'))"
        foreach ($p in 'skills/revisar', 'skills/minha-skill', 'agents', 'hooks') { New-Item -ItemType Directory -Force -Path (Join-Path $d $p) | Out-Null }
        Set-Content -LiteralPath (Join-Path $d 'skills/revisar/SKILL.md') -Value 'versao 1'
        Set-Content -LiteralPath (Join-Path $d 'skills/minha-skill/SKILL.md') -Value 'minha'
        Set-Content -LiteralPath (Join-Path $d 'agents/reviewer-haiku.md') -Value 'antigo'
        Set-Content -LiteralPath (Join-Path $d 'hooks/bloquear-segredos.ps1') -Value 'antigo'
        Set-Content -LiteralPath (Join-Path $d 'CLAUDE.md') -Value 'regras antigas'
        $d
    }
}

Describe 'instalar-arquivos.ps1' {
    It 'Dry-run lista legado e alterado, sem gravar' {
        $d = New-Destino
        $r = Invoke-Inst $d @('-DryRun')
        $r.Texto | Should -Match 'LEGADO   skills/revisar'
        $r.Texto | Should -Match 'LEGADO   agents/reviewer-haiku.md'
        $r.Texto | Should -Match 'LEGADO   hooks/bloquear-segredos.ps1'
        $r.Texto | Should -Not -Match 'minha-skill'
        $r.Texto | Should -Match 'ALTERADO CLAUDE.md'
        $r.Codigo | Should -Not -BeNullOrEmpty
        Test-Path (Join-Path $d 'skills/revisar/SKILL.md') | Should -BeTrue
    }

    It 'Confirmar instala o core, move o legado para o backup e não toca o que é do usuário' {
        $d = New-Destino
        $r = Invoke-Inst $d @('-DryRun')
        $g = Invoke-Inst $d @('-Confirmar', $r.Codigo)
        $g.Texto | Should -Match 'OK:'
        Test-Path (Join-Path $d 'skills/revisar') | Should -BeFalse
        Test-Path (Join-Path $d 'hooks/bloquear-segredos.ps1') | Should -BeFalse
        Test-Path (Join-Path $d 'skills/minha-skill/SKILL.md') | Should -BeTrue
        Test-Path (Join-Path $d 'agents/Explore.md') | Should -BeTrue
        @(Get-ChildItem -LiteralPath (Join-Path $d 'backups') -Recurse -Filter 'SKILL.md').Count | Should -Be 1
        @(Get-ChildItem -LiteralPath (Join-Path $d 'backups') -Recurse -Filter 'CLAUDE.md').Count | Should -Be 1
        $de = Invoke-Inst $d @('-DryRun')
        $de.Texto | Should -Match 'Nada a instalar'
    }

    It 'Código de outro plano é recusado' {
        $d = New-Destino
        $g = Invoke-Inst $d @('-Confirmar', '000000000000')
        $g.Linha | Should -Match 'nao confere'
        Test-Path (Join-Path $d 'skills/revisar') | Should -BeTrue
    }
}
