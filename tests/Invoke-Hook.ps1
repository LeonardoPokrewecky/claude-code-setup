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
        [switch]$ViaSh,
        # Roda direto a ponte run-hook.sh pelo sh (como o fallback do hooks.json ou a execução manual).
        [switch]$ViaPonte,
        # Pasta posta no início do PATH do processo (ex.: um pwsh falso para provar qual shell foi escolhido).
        [string]$PathPrefixo,
        # Substitui o PATH inteiro do processo (ex.: só um sh e interpretadores falsos, para simular "sem PowerShell").
        [string]$PathExato,
        # Remove a variável OS (Windows_NT) do ambiente: simula Linux/WSL, onde o Git Bash não a define.
        [switch]$SemOS,
        # Raiz alternativa do plugin (pasta que contém hooks/), ex.: cópia temporária sem o bloquear-segredos.ps1.
        [string]$RaizPlugin
    )
    $padrao = if ($IsLinux -or $IsMacOS) { 'pwsh' } else { 'powershell' }
    $shell = if ($env:HOOK_SHELL) { $env:HOOK_SHELL } else { $padrao }
    $entrada = @{ hook_event_name = 'PreToolUse'; tool_name = 'Bash'; tool_input = @{ command = $Comando } } | ConvertTo-Json -Compress
    $utf8 = New-Object Text.UTF8Encoding $false

    $psi = New-Object Diagnostics.ProcessStartInfo
    if ($ViaSh) {
        # O comando real do hooks.json, com ${CLAUDE_PLUGIN_ROOT} substituído como o Claude Code faz, num sh -c.
        $base = if ($RaizPlugin) { $RaizPlugin } else { Join-Path $PSScriptRoot '../plugins/base' }
        $plugin = (Resolve-Path -LiteralPath $base).ProviderPath -replace '\\', '/'
        $cfg = [IO.File]::ReadAllText((Join-Path $plugin 'hooks/hooks.json'), $utf8) | ConvertFrom-Json
        $cmd = $cfg.hooks.PreToolUse[0].hooks[0].command.Replace('${CLAUDE_PLUGIN_ROOT}', $plugin)
        $psi.FileName = Get-ShParaHook
        $psi.Arguments = '-c "' + $cmd.Replace('\', '\\').Replace('"', '\"') + '"'
    } elseif ($ViaPonte) {
        $base = if ($RaizPlugin) { $RaizPlugin } else { Join-Path $PSScriptRoot '../plugins/base' }
        $ponte = (Resolve-Path -LiteralPath (Join-Path $base 'hooks/run-hook.sh')).ProviderPath -replace '\\', '/'
        $psi.FileName = Get-ShParaHook
        $psi.Arguments = "`"$ponte`""
    } else {
        $psi.FileName = $shell
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Hook`""
    }
    $psi.UseShellExecute = $false
    if ($PathExato) { $psi.EnvironmentVariables['PATH'] = $PathExato }
    elseif ($PathPrefixo) { $psi.EnvironmentVariables['PATH'] = $PathPrefixo + [IO.Path]::PathSeparator + $env:PATH }
    if ($SemOS) { $psi.EnvironmentVariables.Remove('OS') }
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
