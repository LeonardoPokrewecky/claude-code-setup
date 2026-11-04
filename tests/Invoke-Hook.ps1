# Executa o hook como o Claude Code faz (JSON no stdin, processo separado) e classifica o resultado.
# Shell do hook: variável de ambiente HOOK_SHELL (powershell | pwsh); padrão powershell.
function Invoke-Hook {
    param(
        [Parameter(Mandatory)][string]$Comando,
        [string]$Hook = (Join-Path $PSScriptRoot '..\global\hooks\bloquear-segredos.ps1')
    )
    $shell = if ($env:HOOK_SHELL) { $env:HOOK_SHELL } else { 'powershell' }
    $entrada = @{ hook_event_name = 'PreToolUse'; tool_name = 'Bash'; tool_input = @{ command = $Comando } } | ConvertTo-Json -Compress
    $utf8 = New-Object Text.UTF8Encoding $false

    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $shell
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Hook`""
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
