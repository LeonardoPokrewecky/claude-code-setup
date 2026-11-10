# Instalar o claude-code-setup

Esta pasta reúne **o processo de instalação** do pacote em um só lugar: o que é instalado, onde cada coisa vai parar, em que ordem, e como conferir e desfazer.

Há dois caminhos. Os dois fazem exatamente a mesma coisa:

| Caminho | Quando usar |
|---|---|
| [**A. Guiado**](#a-caminho-guiado-instalarps1) — `install/instalar.ps1` | Quer ser conduzido: o script roda cada passo, mostra o que vai mudar e **pergunta antes de gravar**. |
| [**B. Manual**](#b-caminho-manual-passo-a-passo) — comandos um a um | Quer controlar cada comando, ou está em um ambiente onde o script não roda. |

> **Regra de ouro do pacote: nada é aplicado sozinho.** Todo passo que altera `~/.claude` primeiro mostra o que mudaria (**dry-run**), gera um **código de confirmação** e só grava quando você repete o comando com esse código. Antes de sobrescrever algo, faz **backup**. O script guiado não quebra essa regra: ele só automatiza a digitação do código depois que você responde `s`.

---

## 1. O que a instalação faz

O pacote não vai inteiro para um lugar só. Cada peça usa o mecanismo que o Claude Code suporta para ela:

| # | Passo | O que instala | Onde fica | Mecanismo |
|---|---|---|---|---|
| 1 | **Arquivo da máquina** | seu `maquina.md` (pastas, clone, projetos desta máquina) | `~/.claude/maquina.md` | cópia do modelo `core/maquina.example.md`, só se não existir |
| 2 | **Plugins** | skills, agentes e o hook contra vazamento de segredos (`base`); arquitetura `dotnet` e `angular` | gerenciado pelo Claude Code | `/plugin install` (ou `claude plugin install`) |
| 3 | **CLAUDE.md global + agente Explore** | instruções globais curtas e o `Explore` em Haiku | `~/.claude/CLAUDE.md`, `~/.claude/agents/Explore.md` | `scripts/instalar-arquivos.ps1` |
| 4 | **Settings** | permissões allow/ask/deny, modelo, marketplace (e sandbox no macOS/Linux) | `~/.claude/settings.json` | `scripts/merge-settings.ps1` |
| 5 | **Validação** | nada é gravado; você confere se tudo ficou ativo | — | testes manuais (tabela na seção 5) |

Por que não é um único comando de cópia: plugin não distribui permissões nem `CLAUDE.md` global, e o agente de plugin não sobrescreve o `Explore` embutido. Os passos 3 e 4 existem justamente para cobrir o que o plugin não cobre. Detalhes em [README.md, seção 1](../README.md).

### Como funciona o dry-run + código de confirmação

```text
 1. rodar com -DryRun     → lista o que seria criado/alterado/removido + diff + um CÓDIGO (12 caracteres)
 2. você revisa           → ALERTA (amarelo) = entrada que merece atenção
 3. rodar com -Confirmar <código>   → grava (com backup)
```

O código é um hash do pacote **e** do destino. Se qualquer um mudar entre o passo 1 e o 3 (você editou o `settings.json`, deu `git pull` no clone…), o código deixa de valer e o script recusa gravar. É a garantia de que o que você revisou é o que foi gravado.

### Backups (o que protege você)

| O que muda | Onde fica o backup |
|---|---|
| `~/.claude/settings.json` | `~/.claude/settings.json.bak-AAAAMMDD-HHmmss` |
| `~/.claude/CLAUDE.md`, agentes, itens legados | `~/.claude/backups/instalar-AAAAMMDD-HHmmss/` |

Nada é apagado: itens da versão 1 (cópias antigas de skills, agentes e hook) são **movidos** para o backup.

---

## 2. Pré-requisitos

| Item | Detalhe |
|---|---|
| **Git** | no Windows, **Git for Windows** (o hook roda no Git Bash) |
| **Claude Code** recente | validado com 2.1.319 — [instalação oficial](https://code.claude.com/docs/en/setup) |
| **PowerShell** | Windows: 5.1 ou 7. **macOS/Linux: PowerShell 7 (`pwsh`) é obrigatório** |
| `bubblewrap` e `socat` | só se for usar o sandbox no **Linux** (`-Perfil unix`) |

Instalar o `pwsh` em macOS/Linux:

```bash
brew install --cask powershell          # macOS
# Linux: https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-linux
pwsh -v                                 # confira
```

Instalar o Claude Code (se ainda não tiver):

```powershell
# Windows
irm https://claude.ai/install.ps1 | iex
```

```bash
# macOS / Linux
curl -fsSL https://claude.ai/install.sh | bash
```

> Sem `pwsh` em macOS/Linux, o plugin `base` instala, mas o hook de segredos não roda: a ponte `run-hook.sh` passa a **pedir confirmação em todo comando Bash** e a leitura de `.env` via `cat` deixa de ser bloqueada.

---

## 3. Antes de começar

1. **Clone o repositório** e entre na pasta:
   ```bash
   git clone https://github.com/LeonardoPokrewecky/claude-code-setup.git
   cd claude-code-setup
   ```
2. **Migre regras de projeto/cliente do seu `~/.claude/CLAUDE.md` atual** para o `CLAUDE.md` do repositório daquele projeto. O passo 3 **substitui o arquivo inteiro** (com backup, mas ainda assim: não deixe regra de cliente no global).
3. **Feche sessões abertas do Claude Code** que você não quer reiniciar no meio — ao final, será preciso reabrir.

---

## A. Caminho guiado (`instalar.ps1`)

Na pasta do clone:

```powershell
pwsh -NoProfile -File install/instalar.ps1
```

(No Windows só com PowerShell 5.1: `powershell -ExecutionPolicy Bypass -File install/instalar.ps1`.)

O que o script faz, nesta ordem:

| Etapa | O que acontece | Você decide |
|---|---|---|
| Checagem | confere `git`, `claude` e a versão do PowerShell; avisa o que faltar | — |
| Passo 1 | cria `~/.claude` e copia `maquina.md` se não existir | só informa; não sobrescreve |
| Passo 2 | roda `claude plugin marketplace add` e `claude plugin install` para `base`, `dotnet`, `angular` | `s/N` |
| Passo 3 | `instalar-arquivos.ps1 -DryRun`, mostra a saída, e pergunta | `s/N` → repete com o código |
| Passo 4 | `merge-settings.ps1 -DryRun`, mostra a saída (leia os **ALERTAS**), e pergunta | `s/N` → repete com o código |
| Fim | mostra a tabela de validação | — |

Opções:

| Opção | Efeito |
|---|---|
| `-SoSimular` | roda **só os dry-runs**; não grava nada. Ótimo para ver o que aconteceria. |
| `-Perfil unix` | liga o sandbox (macOS/Linux/WSL2). Sem a opção, o sandbox fica desligado. |
| `-ManterEscalares` | não sobrescreve seu `model`/`advisorModel` atuais. Recomendado se você já ajustou o modelo. |
| `-Destino <pasta>` | instala em outra pasta em vez de `~/.claude` (útil para testar). |
| `-PularPlugins` | não mexe nos plugins (faça o Passo 2 você mesmo). |

Responder `N` em qualquer etapa **pula só aquela etapa**; nada fica pela metade.

---

## B. Caminho manual (passo a passo)

Abra o PowerShell **na pasta do clone**:

```powershell
$repo = (Resolve-Path .).Path
$cl   = Join-Path $(if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }) '.claude'
```

### Passo 1 — Arquivo da máquina (só se não existir)

```powershell
New-Item -ItemType Directory -Force $cl | Out-Null
if (-not (Test-Path "$cl/maquina.md")) { Copy-Item "$repo/core/maquina.example.md" "$cl/maquina.md" }
```

Depois abra `~/.claude/maquina.md` e preencha: pasta de projetos, caminho do clone e projetos atuais. **Nunca coloque segredos nele.** Esse arquivo é **por máquina** e não vai para o Git.

### Passo 2 — Plugins

No Claude Code (ou no shell com `claude plugin ...`):

```text
/plugin marketplace add LeonardoPokrewecky/claude-code-setup     (ou o caminho local do clone)
/plugin install base@kit-dev-ia
/plugin install dotnet@kit-dev-ia
/plugin install angular@kit-dev-ia
```

`dotnet` e `angular` ficam **desligados** por padrão: a camada de projeto da stack liga o plugin certo, e a descrição da skill de arquitetura só ocupa contexto onde faz sentido.

### Passo 3 — CLAUDE.md global e agente Explore

```powershell
pwsh -NoProfile -File "$repo/scripts/instalar-arquivos.ps1" -DryRun
# revise a lista (NOVO / ALTERADO / IGUAL / LEGADO) e o diff; anote o código
pwsh -NoProfile -File "$repo/scripts/instalar-arquivos.ps1" -Confirmar <código>
```

Significado dos status:

| Status | O que é |
|---|---|
| `NOVO` | não existe no destino; será criado |
| `ALTERADO` | existe e é diferente; será substituído **depois de backup** |
| `IGUAL` | já está idêntico; nada a fazer |
| `LEGADO` | resto da versão 1 (skill/agente/hook com o mesmo nome do plugin); será **movido** para o backup, para não rodar duas vezes |

### Passo 4 — Settings (permissões, modelo, marketplace)

```powershell
pwsh -NoProfile -File "$repo/scripts/merge-settings.ps1" -DryRun -ManterEscalares
pwsh -NoProfile -File "$repo/scripts/merge-settings.ps1" -Confirmar <código> -ManterEscalares
```

- Em **macOS/Linux/WSL2**, acrescente `-Perfil unix` aos dois comandos para ligar o sandbox.
- Leia cada **ALERTA**: `allow` e marketplace novos aparecem de propósito; um alerta que você não esperava indica alteração indevida no pacote — **não confirme**.
- Sem `-ManterEscalares`, o pacote define `model` = `sonnet` e `advisorModel` = `opus`.
- O merge **soma**: objetos se mesclam, listas viram união. Para tirar algo, use `-Remover` (veja o [README principal](../README.md), Passo 4).

---

## 4. Já tenho a versão 1 instalada (migração)

Faça o **Passo 2 antes dos Passos 3 e 4**. O `instalar-arquivos.ps1` marca como `LEGADO` as skills, agentes e o hook antigos e os move para `~/.claude/backups/instalar-*/legado/`. O `merge-settings.ps1` remove do settings o hook antigo (aparece como ALERTA "proteção sai"), porque ele agora vem do plugin. O caminho guiado já segue essa ordem.

---

## 5. Validar (feche e reabra o Claude Code)

| Teste | Esperado |
|---|---|
| "rode `echo .env`" (Bash e PowerShell) | bloqueado pelo hook |
| "rode `git -C . push`" | pede confirmação |
| "rode `dotnet --version`" e depois `dotnet test` num projeto | `dotnet test` roda sem pedir |
| "leia `~/.ssh/config`" | negado |
| `/plugin` | `base` ligado; `context7` e `security-guidance` ativos; nenhum terceiro inesperado |
| `/agents` | `Explore` (usuário) + agentes `base:*` |
| `/context` | anotar o total |

Se algo falhar, vá para a [seção 7](#7-problemas-comuns).

---

## 6. Atualizar, desinstalar e recuperar

**Atualizar**

```bash
git pull
claude plugin marketplace update kit-dev-ia
claude plugin update base@kit-dev-ia
```

Depois rode `/reload-plugins` na sessão aberta e **repita os Passos 3 e 4** (o dry-run mostra só o que mudou).

**Desinstalar**

```bash
claude plugin uninstall base@kit-dev-ia
claude plugin uninstall dotnet@kit-dev-ia
claude plugin uninstall angular@kit-dev-ia
claude plugin marketplace remove kit-dev-ia
```

Depois restaure `~/.claude/CLAUDE.md` e `~/.claude/settings.json` a partir dos backups.

**Recuperar**: copie de volta o arquivo desejado de `~/.claude/settings.json.bak-*` ou `~/.claude/backups/instalar-*/`.

---

## 7. Problemas comuns

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| `Codigo de confirmacao nao confere` | o pacote ou o destino mudou depois do dry-run | rode `-DryRun` de novo, revise e use o novo código |
| `pwsh: command not found` | PowerShell 7 não instalado (macOS/Linux) | veja a seção 2 |
| Claude pede confirmação em **todo** comando Bash | sem `pwsh`, o hook cai para "perguntar sempre" | instale o `pwsh` |
| `.env` não é bloqueado | idem, ou plugin `base` não está ligado | `/plugin` e confira `base` |
| Hook falha no Windows com erro de sintaxe `sh` | Git Bash ausente | instale o Git for Windows ou defina `CLAUDE_CODE_GIT_BASH_PATH` |
| `/plugin install` não acha `base@kit-dev-ia` | marketplace não adicionado | repita `/plugin marketplace add ...` |
| Skills duplicadas (`/revisar` e `/base:revisar` com comportamento antigo) | sobra da versão 1 em `~/.claude` | rode o Passo 3: ele move o `LEGADO` para o backup |

---

## 8. Depois de instalar: ativar em um projeto

A instalação global não mexe em nenhum projeto. Para ligar o kit em um repositório, peça ao Claude: **"use a skill project-bootstrap"**. Ele detecta a stack, propõe as camadas e mostra o dry-run antes de gravar. A versão manual está em [README.md, seção 3](../README.md).
