# Converte um blueprint (.md) em HTML ao lado do arquivo e abre no navegador padrão.
# PowerShell 7+: ConvertFrom-Markdown. Windows PowerShell 5.1: texto em <pre>, escapado.
# Só lê o .md informado e grava <nome>.html na mesma pasta; sem rede, sem executar o conteúdo.
param(
    [Parameter(Mandatory)][string]$Caminho,
    [switch]$NaoAbrir
)
$ErrorActionPreference = 'Stop'
# Escapa só o necessário (WebUtility.HtmlEncode trocaria acentos por entidades).
function ConvertTo-HtmlSeguro([string]$s) { $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;') }

if (-not (Test-Path -LiteralPath $Caminho -PathType Leaf)) { throw "Arquivo não encontrado: $Caminho" }
if ([IO.Path]::GetExtension($Caminho) -ne '.md') { throw "Esperado um arquivo .md: $Caminho" }

$md = (Resolve-Path -LiteralPath $Caminho).ProviderPath
$utf8 = New-Object Text.UTF8Encoding $false
$texto = [IO.File]::ReadAllText($md, $utf8)
$titulo = if ($texto -match '(?m)^#\s+(.+)$') { $Matches[1].Trim() } else { [IO.Path]::GetFileNameWithoutExtension($md) }

if (Get-Command ConvertFrom-Markdown -ErrorAction SilentlyContinue) {
    $corpo = ($texto | ConvertFrom-Markdown).Html
} else {
    $corpo = '<pre>' + (ConvertTo-HtmlSeguro $texto) + '</pre>'
}

$html = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<title>$(ConvertTo-HtmlSeguro ($titulo))</title>
<style>
body { font-family: system-ui, sans-serif; max-width: 960px; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; color: #1f2328; }
table { border-collapse: collapse; margin: 1rem 0; } th, td { border: 1px solid #d0d7de; padding: .4rem .6rem; vertical-align: top; text-align: left; }
th { background: #f6f8fa; } code { background: #f6f8fa; padding: .1rem .3rem; border-radius: 4px; }
pre { background: #f6f8fa; padding: 1rem; overflow-x: auto; white-space: pre-wrap; } pre code { padding: 0; }
.rodape { color: #59636e; font-size: .85rem; margin-top: 2rem; }
</style>
</head>
<body>
$corpo
<p class="rodape">Gerado de $(ConvertTo-HtmlSeguro ([IO.Path]::GetFileName($md))) em $(Get-Date -Format 'yyyy-MM-dd HH:mm'). Ao atualizar o blueprint, recarregue a página.</p>
</body>
</html>
"@

$saida = [IO.Path]::ChangeExtension($md, '.html')
[IO.File]::WriteAllText($saida, $html, $utf8)
Write-Output $saida
if (-not $NaoAbrir) { Start-Process -FilePath $saida }
