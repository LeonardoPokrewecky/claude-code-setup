# Hook PreToolUse (Bash/PowerShell): bloqueia comando que referencia arquivo de segredo e pede confirmação
# para comando que altera a configuração do Claude Code ou esconde o alvo (base64, curinga, rede).
# O deny de Read/Edit/Write no settings.json não cobre cat/type/Get-Content/redirecionamento via shell; este hook fecha
# essa brecha.
# Entrada: JSON do Claude Code no stdin. Saída: exit 2 + motivo no stderr bloqueia; JSON "ask" no stdout pede
# confirmação ao usuário; exit 0 sem saída libera.
# JSON inválido ou sem comando libera (o hook nunca pode travar a sessão). Qualquer outra falha interna pede
# confirmação (trap abaixo): sem ele, a exceção sairia com código 1, que o Claude Code trata como não bloqueante.
# Defesa por texto do comando: não pega nome montado em variável/concatenação, "cd" seguido de caminho relativo nem
# curinga "*" sozinho; é camada extra sobre o deny/ask do settings.json (limitações no README).
$ErrorActionPreference = 'Stop'

# Definida antes de tudo: o trap depende dela.
function Write-Confirmar([string]$motivo) {
    $saida = @{ hookSpecificOutput = @{
        hookEventName            = 'PreToolUse'
        permissionDecision       = 'ask'
        permissionDecisionReason = "Hook bloquear-segredos: $motivo. Confira o que o comando faz antes de aprovar."
    } }
    [Console]::Out.Write(($saida | ConvertTo-Json -Compress -Depth 5))
    exit 0
}
trap { Write-Confirmar "falha interna do hook: $($_.Exception.Message)" }

[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
try { [Console]::InputEncoding = [Text.UTF8Encoding]::new($false) } catch { }

try {
    # PowerShell 5.1 pode entregar o stdin com BOM (U+FEFF); sem o Trim o parse falha e o hook libera tudo.
    $entrada = [Console]::In.ReadToEnd().TrimStart([char]0xFEFF) | ConvertFrom-Json
    $comando = [string]$entrada.tool_input.command
} catch { exit 0 }
if ([string]::IsNullOrWhiteSpace($comando)) { exit 0 }

# Aspas e escapes no meio do nome (.e""nv, .e`nv, .e^nv) somem antes do teste; testa o original e o normalizado.
$textos = @($comando, ($comando -replace '["''`^]', '')) | Select-Object -Unique

# Limites de nome: antes, nada que continue um nome; depois, fim ou qualquer caractere fora de nome
# (cobre "HEAD:.env", ".env>x", ".env&&", ".env,").
$fim = '(?=$|[^\w.-])'
$padroes = @(
    "(?<![\w.-])\.env(rc)?(\.[\w-]+)*$fim",
    "(^|[\s/\\:=<>|&;,])(?!(process|this|self|ctx|context|Deno|Bun)\.env)[\w-]+\.env$fim",
    # Só os de ambiente real: appsettings.json e appsettings.Development.json costumam ser versionados sem segredo.
    'appsettings\.([\w-]+\.)*(Production|Prod|Staging|Homolog\w*|Local)(\.[\w-]+)*\.json',
    # Sensível a caixa e fora de variável: "$_.Key" e "$obj.key" não são arquivo.
    ('(?-i:(?<!\$[\w:]*)(?<=[\w-])\.(pfx|p12|pem|key|vault|kdbx|ppk|jks|keystore|p8)' + $fim + ')'),
    '(?<![\w.-])secrets[/\\]',
    '[\w-]*secrets?[\w-]*\.(json|ya?ml)',
    'local\.settings\.json',
    'UserSecrets',
    '\.credentials\.json',
    '\.git-credentials',
    '(?<![\w.-])\.claude\.json',
    "(?<![\w.-])id_(rsa|ed25519|ecdsa|dsa)",
    '(?<![\w-])\.ssh(?=$|[^\w-])',
    "(?<![\w.-])\.(npmrc|netrc|pgpass|pypirc)$fim",
    '(?<![\w.-])\.(aws|azure|kube)(?=$|[^\w.-])',
    '\.docker[/\\]config\.json',
    '(?<![\w.-])\.config[/\\]gh(?=$|[^\w.-])'
)

# Não bloqueiam (há uso legítimo), pedem confirmação ao usuário pela própria interface do Claude Code.
$padroesConfirmar = @(
    @{ Padrao = '\.claude[/\\](settings[\w.-]*|hooks|agents|skills|commands|CLAUDE\.md)(?=$|[^\w.-])'; Motivo = 'o comando cita configuração, hook, agente ou skill do Claude Code (pode alterar as proteções)' },
    @{ Padrao = '(^|[\s;&|(])(cd|sl|Set-Location|pushd|Push-Location)\s+\S*\.claude(?=$|[\s/\\;&|)])'; Motivo = 'entra na pasta .claude (caminho relativo depois escapa das demais regras)' },
    @{ Padrao = '(merge-settings|instalar-arquivos)(\.ps1)?\b.*\s-Confirmar\b'; Motivo = 'grava configuração do Claude Code; confira o dry-run e os alertas antes de aprovar' },
    @{ Padrao = '(powershell|pwsh)(\.exe)?\b.*\s[-/](e|ec|en|enc\w*)(?=$|[\s:])|(^|[\s"''])[-/]encodedcommand\b'; Motivo = 'comando codificado em base64 (-EncodedCommand)' },
    @{ Padrao = 'FromBase64String|(^|[\s|;&])base64\s+(-\w*d|--decode)|certutil(\.exe)?\s.*[-/]decode'; Motivo = 'decodifica base64 (pode esconder o comando ou o alvo)' },
    @{ Padrao = 'Net\.WebClient|Net\.Http\.HttpClient|Net\.Sockets|Net\.Mail|Send-MailMessage|Download(String|File|Data)|Upload(String|File|Data|Values)'; Motivo = 'acesso à rede ou envio de dados pelo .NET' },
    @{ Padrao = '(^|[\s;&|(])(printenv|(Get-ChildItem|gci|ls|dir)\s+env:)|(^|[;&|]\s*)(env|set)\s*($|[|;&>])|user-secrets\s+list'; Motivo = 'despeja variáveis de ambiente ou user-secrets' },
    @{ Padrao = '(?<![\w.-])web\.[\w.]*config(?=$|[^\w.-])'; Motivo = 'web.config pode conter connection string' },
    # As regras "ask" do settings comparam só o início do comando: não pegam "git -C pasta push" nem "x && git push".
    @{ Padrao = '(^|[\s;&|(])git(\.exe)?(\s+(-C|-c|--git-dir|--work-tree)(\s+|=)\S+)*\s+(push|commit|clean|restore|fetch|pull|clone|reset\s+--hard|checkout\s+(\S+\s+)?--|checkout\s+\.|stash\s+(drop|clear)|branch\s+((?-i:-D)|-d\s+(-f|--force)|--delete\s+--force)|remote\s+(add|set-url))(?=$|[\s;&|)])'; Motivo = 'git que publica, usa a rede ou descarta trabalho (inclusive com -C ou no meio de um encadeamento)' },
    @{ Padrao = '([;&|]|\$\()\s*(curl|wget|ssh|scp|sftp|rsync|nc|ncat|ftp|iwr|irm|Invoke-WebRequest|Invoke-RestMethod)(\.exe)?(?=$|\s)'; Motivo = 'acesso à rede no meio de um encadeamento' },
    @{ Padrao = '([;&|]|\$\()\s*(rm|del|rmdir|rd|mv|Remove-Item|ri|Move-Item)(?=$|\s)'; Motivo = 'apaga ou move arquivos no meio de um encadeamento' }
)

# Curinga: compara o padrão com nomes de segredo conhecidos. Só considera trecho com 2+ caracteres literais
# (".*" e "s*" de regex não disparam); "*" sozinho fica de fora (limitação documentada).
$nomesSensiveis = '.env', '.env.local', '.envrc', 'prod.env', 'id_rsa', 'id_ed25519', 'id_ecdsa', 'chave.pem', 'chave.key',
    'cert.pfx', 'cert.p12', 'chave.ppk', 'banco.kdbx', 'store.jks', 'store.keystore', '.git-credentials', '.credentials.json',
    '.claude.json', '.npmrc', '.netrc', '.pgpass', '.pypirc', 'secrets.json', 'secrets.yaml', 'local.settings.json',
    'appsettings.Production.json'
$pastasSensiveis = '.ssh', '.aws', '.azure', '.kube', 'secrets', '.claude'

function Test-Curinga([string]$texto) {
    foreach ($token in ($texto -split '[\s|;&<>(),=:]+')) {
        if ($token -notmatch '[*?\[]') { continue }
        if ($token -match '\.claude[/\\]') { return $token }   # curinga dentro da configuração do Claude Code
        foreach ($parte in ($token -split '[/\\]')) {
            if ($parte -notmatch '[*?\[]' -or ($parte -replace '\[[^\]]*\]|[*?\[\]]', '').Length -lt 2) { continue }
            $curinga = [Management.Automation.WildcardPattern]::new($parte, [Management.Automation.WildcardOptions]::IgnoreCase)
            try {
                foreach ($n in $nomesSensiveis + $pastasSensiveis) { if ($curinga.IsMatch($n)) { return $parte } }
            } catch { return $parte }   # curinga inválido: na dúvida, perguntar
        }
    }
    $null
}

foreach ($t in $textos) {
    foreach ($p in $padroes) {
        if ($t -match $p) {
            [Console]::Error.WriteLine("Bloqueado pelo hook bloquear-segredos: o comando referencia um arquivo de segredo ('$($Matches[0].Trim())'). Não ler nem exibir segredos; se for indispensável, peça ao usuário para rodar o comando com '! <comando>'.")
            exit 2
        }
    }
}

foreach ($t in $textos) {
    foreach ($c in $padroesConfirmar) {
        if ($t -match $c.Padrao) { Write-Confirmar $c.Motivo }
    }
    $parte = Test-Curinga $t
    if ($parte) { Write-Confirmar "curinga '$parte' pode alcançar arquivo de segredo" }
}
exit 0
