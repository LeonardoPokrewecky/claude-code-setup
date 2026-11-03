# Hook PreToolUse (Bash/PowerShell): bloqueia comando que referencia arquivo de segredo.
# O deny de Read(...) no settings.json não cobre cat/type/Get-Content via shell; este hook fecha essa brecha.
# Entrada: JSON do Claude Code no stdin. Saída: exit 2 + motivo no stderr bloqueia; exit 0 libera.
# JSON inválido ou sem comando libera (o hook nunca pode travar a sessão).
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)

try {
    $entrada = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $comando = [string]$entrada.tool_input.command
} catch { exit 0 }
if ([string]::IsNullOrWhiteSpace($comando)) { exit 0 }

# Cada padrão exige nome/caminho de arquivo, não só a palavra (ex.: "git log --grep secrets" passa).
$padroes = @(
    '(^|[\s"''/\\=])\.env(\.[\w.-]+)?($|[\s"'';|)])',
    'appsettings\.(Development|Production|Staging|Homologation|Test|Local)[\w.-]*\.json',
    '\.(pfx|p12|pem|key|vault|kdbx)($|[\s"'';|)])',
    '(^|[\s"''/\\])secrets[/\\]',
    '[\w-]*secrets?[\w-]*\.json',
    '\.credentials\.json',
    '\.git-credentials',
    '(^|[\s"''/\\])id_(rsa|ed25519|ecdsa)',
    '(^|[\s"''/\\])\.ssh[/\\]',
    '\.npmrc($|[\s"'';|)])'
)

foreach ($p in $padroes) {
    if ($comando -match $p) {
        [Console]::Error.WriteLine("Bloqueado pelo hook bloquear-segredos: o comando referencia um arquivo de segredo ('$($Matches[0].Trim())'). Não ler nem exibir segredos; se for indispensável, peça ao usuário para rodar o comando com '! <comando>'.")
        exit 2
    }
}
exit 0
