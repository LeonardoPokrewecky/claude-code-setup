# Executa o hook como o Claude Code faz (JSON no stdin, processo separado) e classifica o resultado.
# Shell do hook: variável de ambiente HOOK_SHELL (powershell | pwsh); padrão powershell no Windows, pwsh fora dele.
# -ViaSh: roda pela ponte plugins/base/hooks/run-hook.sh (como o hooks.json do plugin), com o sh encontrado.
function Get-ShParaHook {
    $sh = Get-Command sh -ErrorAction SilentlyContinue
    if ($sh) { return $sh.Source }
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        foreach ($rel in '..\bin\sh.exe', '..\usr\bin\sh.exe', '..\..\bin\sh.exe', '..\..\usr\bin\sh.exe') {
            $c = Join-Path (Split-Path $git.Source) $rel
            if (Test-Path -LiteralPath $c) { return (Resolve-Path -LiteralPath $c).ProviderPath }
        }
    }
    $null
}

function Invoke-Hook {
    param(
        [Parameter(Mandatory)][string]$Comando,
        [string]$Hook = (Join-Path $PSScriptRoot '../plugins/base/hooks/bloquear-segredos.ps1'),
        [switch]$ViaSh
    )
    $padrao = if ($IsLinux -or $IsMacOS) { 'pwsh' } else { 'powershell' }
    $shell = if ($env:HOOK_SHELL) { $env:HOOK_SHELL } else { $padrao }
    $entrada = @{ hook_event_name = 'PreToolUse'; tool_name = 'Bash'; tool_input = @{ command = $Comando } } | ConvertTo-Json -Compress
    $utf8 = New-Object Text.UTF8Encoding $false

    $psi = New-Object Diagnostics.ProcessStartInfo
    if ($ViaSh) {
        # O comando real do hooks.json, com ${CLAUDE_PLUGIN_ROOT} substituído como o Claude Code faz, num sh -c.
        $plugin = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../plugins/base')).ProviderPath -replace '\\', '/'
        $cfg = [IO.File]::ReadAllText((Join-Path $plugin 'hooks/hooks.json'), $utf8) | ConvertFrom-Json
        $cmd = $cfg.hooks.PreToolUse[0].hooks[0].command.Replace('${CLAUDE_PLUGIN_ROOT}', $plugin)
        $psi.FileName = Get-ShParaHook
        $psi.Arguments = '-c "' + $cmd.Replace('\', '\\').Replace('"', '\"') + '"'
    } else {
        $psi.FileName = $shell
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Hook`""
    }
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = $utf8
    $psi.StandardErrorEncoding = $utf8

    $p = [Diagnostics.Process]::Start($psi)
    $bytes = $utf8.GetBytes($entrada)
    $p.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
    $p.StandardInput.Close()
    $saida = $p.StandardOutput.ReadToEnd()
    $erro = $p.StandardError.ReadToEnd()
    $p.WaitForExit()

    $resultado = if ($p.ExitCode -eq 2) { 'Bloqueia' }
        elseif ($p.ExitCode -eq 0 -and $saida -match '"permissionDecision"\s*:\s*"ask"') { 'Confirma' }
        elseif ($p.ExitCode -eq 0 -and -not $saida.Trim()) { 'Libera' }
        else { "Erro($($p.ExitCode))" }
    [pscustomobject]@{ Resultado = $resultado; Saida = $saida; Erro = $erro; ExitCode = $p.ExitCode }
}
