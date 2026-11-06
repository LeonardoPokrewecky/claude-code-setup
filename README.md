# claude-code-setup — base portátil para o Claude Code

Configuração genérica do Claude Code (Desktop → aba **Code**, e CLI) para qualquer projeto: instruções globais curtas, permissões por classe de operação, hook contra vazamento de segredos, skills e agentes distribuídos como **plugins**, e modelos de projeto por camadas.

> **Nada é aplicado sozinho.** Todo passo mostra antes o que vai mudar (dry-run + código de confirmação + backup).
> **Nada pessoal ou de cliente entra no pacote.** Dados da máquina ficam em `~/.claude/maquina.md`; regras de um projeto ficam no `CLAUDE.md` daquele repositório.

Inventário completo (plugins, skills, agentes, camadas, perfis), gerado dos próprios arquivos: [plugins/base/skills/env-guide/componentes.md](plugins/base/skills/env-guide/componentes.md).

---

## 1. Estrutura

```text
claude-code-setup/
├── .claude-plugin/marketplace.json   ← marketplace "kit-dev-ia" (plugins base e dotnet)
├── core/                             ← o que plugin não distribui (instalado pelos scripts)
│   ├── CLAUDE.md                     ← instruções globais (≤ 40 linhas); importa ~/.claude/maquina.md
│   ├── agents/Explore.md             ← Explore em Haiku (agente de plugin não sobrescreve o embutido)
│   ├── settings.merge.json           ← modelo, advisor, marketplace, permissões allow/ask/deny
│   └── maquina.example.md            ← modelo do arquivo por máquina (não é instalado)
├── plugins/
│   ├── base/                         ← skills, agentes, hook de segredos, evals
│   └── dotnet/                       ← arquitetura onion (ligado por projeto)
├── profiles/unix/settings.json       ← sandbox para macOS/Linux/WSL2
├── project-templates/                ← camadas de projeto (settings, regras por caminho, devcontainer)
├── scripts/                          ← merge-settings, instalar-arquivos, gerar-docs
└── tests/                            ← Pester 5+: hook, scripts, estrutura, conteúdo
```

### Por que essa divisão
| Peça | Mecanismo | Motivo |
|---|---|---|
| Skills, agentes, hook | Plugin (`/plugin install`) | instalação, atualização e remoção oficiais, em qualquer sistema |
| Permissões, sandbox, modelo, advisor | `merge-settings.ps1` | plugin só aplica `agent`/`subagentStatusLine` do settings ([doc](https://code.claude.com/docs/en/plugins-reference)) |
| CLAUDE.md global, agente `Explore` | `instalar-arquivos.ps1` | CLAUDE.md de plugin não carrega; agente de plugin não sobrescreve o `Explore` embutido ([doc](https://code.claude.com/docs/en/sub-agents)) |
| Regras por caminho | camadas de projeto (`.claude/rules/`) | plugin não distribui regras; elas só carregam ao tocar arquivos do tipo ([doc](https://code.claude.com/docs/en/memory)) |

Não existe plugin `frontend`: não há conteúdo próprio de frontend além das regras da camada `angular`. Um plugin novo só entra com caso real.

---

## 2. Instalação

Pré-requisitos: Git (no Windows, **Git for Windows**: o hook roda no Git Bash), Claude Code recente (validado com 2.1.318), PowerShell 5.1 ou 7 (`pwsh` em macOS/Linux).

Abra o PowerShell **na pasta deste repositório**:
```powershell
$repo = (Resolve-Path .).Path
$cl   = Join-Path $(if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }) '.claude'
```

**Passo 1 — Arquivo da máquina** (só se não existir): copie `core/maquina.example.md` para `~/.claude/maquina.md` e preencha pastas, clone e projetos.
```powershell
if (-not (Test-Path "$cl/maquina.md")) { Copy-Item "$repo/core/maquina.example.md" "$cl/maquina.md" }
```

**Passo 2 — Plugins** (no Claude Code, ou no shell com `claude plugin ...`):
```text
/plugin marketplace add LeonardoPokrewecky/claude-code-setup     (ou o caminho local do clone)
/plugin install base@kit-dev-ia
/plugin install dotnet@kit-dev-ia     (fica desligado; a camada dotnet liga por projeto)
```

**Passo 3 — CLAUDE.md global e Explore** (antes deste passo, mova regras de projeto/cliente do seu CLAUDE.md atual para o repositório daquele projeto: o arquivo é substituído inteiro, com backup):
```powershell
powershell -ExecutionPolicy Bypass -File "$repo/scripts/instalar-arquivos.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "$repo/scripts/instalar-arquivos.ps1" -Confirmar <código>
```

**Passo 4 — Settings** (permissões, modelo, marketplace). Em macOS/Linux/WSL2, acrescente `-Perfil unix` para ligar o sandbox (exige `bubblewrap` e `socat` no Linux):
```powershell
powershell -ExecutionPolicy Bypass -File "$repo/scripts/merge-settings.ps1" -DryRun -ManterEscalares
powershell -ExecutionPolicy Bypass -File "$repo/scripts/merge-settings.ps1" -Confirmar <código> -ManterEscalares
```
Leia cada **ALERTA**: `allow` e marketplace novos aparecem de propósito; um alerta inesperado indica alteração indevida no pacote. Sem `-ManterEscalares`, o pacote define `model` = `sonnet` e `advisorModel` = `opus` (advisor: experimental, só Anthropic API).

Opções do `merge-settings.ps1`:
- O merge **adiciona**: objetos se mesclam, listas viram união; valor escalar do pacote sobrescreve o seu (`SOBRESCREVE` no dry-run), a menos que use **`-ManterEscalares`** (`MANTIDO`).
- **`-Remover`** tira o que o pacote não remove sozinho: `-Remover env.CLAUDE_CODE_SUBAGENT_MODEL` (apaga a chave) ou `-Remover 'permissions.allow[]=Bash(winget:*)'` (tira um item); vários itens separados por vírgula. Remover `deny`, `ask` ou hook gera **ALERTA**.
- **`-Perfil unix`** soma `profiles/unix/settings.json`. **`-Layers a,b -Target <repo>/.claude/settings.json`** aplica camadas de projeto.
- Sem mudança no resultado, nada é gravado; estrutura inválida (tipo errado em `permissions`, `env`, `enabledPlugins`, `hooks`, `sandbox`) é recusada antes de gravar; valores com nome de segredo aparecem como `***`.
- A opção `-HookShell` da versão 1 saiu: o hook agora escolhe `pwsh`/`powershell` sozinho.

**Passo 5 — Validar** (feche e abra o Claude Code):
| Teste | Esperado |
|---|---|
| "rode `echo .env`" (Bash e PowerShell) | bloqueado pelo hook |
| "rode `git -C . push`" | pede confirmação |
| "rode `dotnet --version`" e depois `dotnet test` num projeto | `dotnet test` roda sem pedir |
| "leia `~/.ssh/config`" | negado |
| `/plugin` | `base` ligado; `context7` e `security-guidance` ativos; nenhum terceiro inesperado |
| `/agents` | `Explore` (usuário) + agentes `base:*` |
| `/context` | anotar o total (compare com a medição do pacote) |

### Migração da versão 1 (arquivos copiados em `~/.claude`)
Faça o Passo 2 **antes** dos Passos 3 e 4. O `instalar-arquivos.ps1` lista como **LEGADO** as skills, os agentes e o hook antigos com o mesmo nome e os move para `~/.claude/backups/instalar-*/legado/`. O `merge-settings.ps1` remove do settings o hook antigo (ALERTA "proteção sai"), porque ele agora vem do plugin.

---

## 3. Ativar em um projeto

Peça ao Claude: **"use a skill project-bootstrap"** (modo `adopt-existing` ou `new-project`). Ele detecta a stack, propõe as camadas e mostra o dry-run antes de gravar.

Manual:
```powershell
$proj = "<pasta do projeto>"
powershell -ExecutionPolicy Bypass -File "$repo/scripts/merge-settings.ps1" -Target "$proj/.claude/settings.json" -Layers _base,dotnet -DryRun
powershell -ExecutionPolicy Bypass -File "$repo/scripts/merge-settings.ps1" -Target "$proj/.claude/settings.json" -Layers _base,dotnet -Confirmar <código>
# Regras por caminho das camadas escolhidas (sem sobrescrever):
New-Item -ItemType Directory -Force "$proj/.claude/rules" | Out-Null
Get-ChildItem "$repo/project-templates/dotnet/.claude/rules" -File | Where-Object { -not (Test-Path "$proj/.claude/rules/$($_.Name)") } | Copy-Item -Destination "$proj/.claude/rules"
if (-not (Test-Path "$proj/CLAUDE.md")) { Copy-Item "$repo/project-templates/CLAUDE.project.md" "$proj/CLAUDE.md" }
```
- `.gitignore`: somar as linhas de `project-templates/gitignore.claude` que faltam (o `project-bootstrap` faz isso lendo em UTF-8).
- Repositório de cliente em que o Claude não deve aparecer: em vez do `.gitignore`, somar `CLAUDE.md`, `CLAUDE.local.md` e `.claude/` ao `.git/info/exclude`.
- Camada `devcontainer` (copiar `.devcontainer/`): isolamento para Windows nativo ou código não confiável — **não validada em projeto real**.

---

## 4. Permissões (fonte: `core/settings.merge.json`)

| Classe | Política |
|---|---|
| Leitura e pesquisa | sem prompt (somente leitura nativos); **deny** de leitura de segredos (`.env`, chaves, `secrets/`, `appsettings` de ambiente real, credenciais em `~/.ssh`, `~/.aws`…) |
| Edição | prompt nativo; **deny** em `~/.claude/settings*.json`, `hooks/`, `plugins/`; **ask** em CLAUDE.md, skills e agentes do usuário |
| Build e testes | **allow**: `dotnet build/test`, `npm test`, `npm run build/test/lint`, `pytest` (Bash e PowerShell) |
| Instalar dependências | **ask** (npm/pnpm/yarn dlx, npx, uvx, pip, dotnet add/tool, winget) |
| Banco de dados | sem regra genérica; `/alterar-dados` (backup + canário) e aprovação explícita |
| Git | leitura nativa; **ask** para commit, push, fetch/pull/clone, reset --hard, clean, restore, checkout --, stash drop/clear, branch -D, remote add/set-url; o hook cobre `git -C`/`-c` |
| Publicação e rede | **ask** (gh api/gist/secret/release/repo create, curl, wget, ssh, scp, rsync, Invoke-WebRequest…) |
| Destrutivas e código inline | **ask** (rm, del, mv, Remove-Item, Move-Item, `node -e`, `python -c`, `bash -c`, `powershell`, `cmd`, `iex`, `Start-Process`) |

As regras nativas dividem comandos compostos (`x && git push` pede confirmação). Nenhum modo de aprovação automática substitui esta política.

**Risco aceito no Windows nativo:** build e teste liberados rodam scripts do projeto, que podem ler segredos sem citar o nome. Mitigação: segredos fora do repositório (User Secrets, variável de ambiente); para código não confiável, WSL2 com `-Perfil unix` ou a camada `devcontainer`.

---

## 5. Uso no dia a dia

| Situação | O que fazer |
|---|---|
| Tarefa comum | sessão Sonnet; o advisor Opus entra nas decisões |
| Arquitetura, segurança, banco, LGPD | trocar a sessão para Opus |
| Planejar algo grande | Plan mode + `/blueprint` (inclui requisitos não funcionais) |
| Revisar | `/revisar` (lentes escolhidas pelo risco do diff) ou `/revisar <lente>`; `/code-review`, `/security-review` |
| Dados em massa / deploy | `/alterar-dados`, `/deploy-checklist` |
| Outras | `/divida`, `/medir-antes-depois`, `/criar-testes`, `/explicar`, `/limpar-codigo`, `/preparar-pr`, `/adr`, `/plano-migracao`, `/postmortem`, `/lgpd-audit`, `/session-handoff` |

Skills de plugin também respondem com prefixo (`/base:revisar`). Desktop e CLI leem o mesmo `~/.claude`: a configuração é a mesma nos dois.

---

## 6. Atualizar, desinstalar e recuperar

- **Atualizar:** `git pull` no clone; `claude plugin marketplace update kit-dev-ia` e `claude plugin update base@kit-dev-ia` (o `version` do `plugin.json` fixa a versão: suba-o a cada mudança publicada); `/reload-plugins` na sessão aberta; depois rodar de novo os Passos 3 e 4 (o dry-run mostra só o que mudou).
- **Desinstalar:** `/plugin uninstall base@kit-dev-ia` e `dotnet@kit-dev-ia`; `claude plugin marketplace remove kit-dev-ia`; restaurar `~/.claude/CLAUDE.md` e `settings.json` do backup.
- **Recuperar:** `settings.json` → `~/.claude/settings.json.bak-AAAAMMDD-HHmmss`; CLAUDE.md, agentes e legado → `~/.claude/backups/instalar-*/`. Copie de volta o arquivo desejado.

---

## 7. Portabilidade

| Componente | Windows PS 5.1 | Windows PS 7 | Linux / WSL2 | macOS |
|---|---|---|---|---|
| Hook (plugin, Git Bash/sh) | testado aqui | alterado para o CI, não executado | alterado para o CI, não executado | não testado |
| `merge-settings.ps1`, `instalar-arquivos.ps1`, `gerar-docs.ps1` | testado aqui | CI, não executado | CI, não executado | não testado |
| Plugins e marketplace (`claude plugin validate`, instalação isolada) | testado aqui | — | não testado | não testado |
| Sandbox (`-Perfil unix`) | não suportado (doc oficial) | não suportado | não testado | não testado |
| Devcontainer | não testado | — | não testado | não testado |
| Desktop × CLI | mesma configuração (`~/.claude`) | | | |

Windows sem Git Bash: o hook em shell form roda no PowerShell e falha a sintaxe `sh` ([doc](https://code.claude.com/docs/en/hooks)). Instale o Git for Windows ou defina `CLAUDE_CODE_GIT_BASH_PATH`.

---

## 8. Limitações das proteções

- **O hook lê só o texto do comando.** Não pega nome montado em variável, `cd` + caminho relativo, curinga sozinho (`cat *`), busca que lê segredos sem citar o nome (`grep -r PASSWORD .`) nem script que lê o arquivo por dentro. Medição: 7/7 desses casos passam — é camada contra acidente.
- **Falso positivo conhecido:** `git commit -m "... .env ..."` é bloqueado (use `! <comando>`).
- **Hook que não roda não bloqueia:** JSON inválido ou timeout liberam; falha interna depois do parse pede confirmação; sem PowerShell, a ponte pede confirmação.
- **Regras `ask/deny` por texto** não pegam o programa por caminho completo ou dentro de `sh -c` (doc oficial); o sandbox (macOS/Linux/WSL2) é a proteção que não depende do texto.
- **`appsettings.json` e `appsettings.Development.json` não são protegidos por nome:** mantenha-os sem segredo.
- **O código de `-Confirmar` não distingue você do agente:** a aprovação real é a confirmação que o hook pede ao ver `-Confirmar`.
- **Plugins oficiais seguem a versão mais recente.** `marketingskills` (camada `marketing`) é fixado por tag; conferência por SHA no `env-guide`.

---

## 9. Testes e manutenção

- `Invoke-Pester ./tests -Output Detailed` (Pester 5 ou 6: `Install-Module Pester -MinimumVersion 5.5.0 -Scope CurrentUser -SkipPublisherCheck`).
- Casos do hook em `tests/casos-hook.psd1`: padrão novo no hook entra com caso novo.
- Mudou skill, agente, plugin, camada ou perfil? Rode `scripts/gerar-docs.ps1` e commite o `componentes.md` (o teste falha se ficar desatualizado).
- `claude plugin validate .` e `claude plugin validate ./plugins/<nome>` antes de publicar.
- Evals em `plugins/base/evals/`: `claude plugin eval ./plugins/base` (chama o modelo; custo).
- Termos proibidos (dado de cliente): lista **fora** do repositório em `../docs/claude-code-setup/termos-proibidos.txt` ou `CCS_TERMOS_PROIBIDOS`; sem lista, o teste fica pulado.

Fontes: [Plugins](https://code.claude.com/docs/en/plugins-reference) · [Marketplace](https://code.claude.com/docs/en/plugin-marketplaces) · [Permissões](https://code.claude.com/docs/en/permissions) · [Sandbox](https://code.claude.com/docs/en/sandboxing) · [Hooks](https://code.claude.com/docs/en/hooks) · [Memória e regras](https://code.claude.com/docs/en/memory) · [Subagentes](https://code.claude.com/docs/en/sub-agents) · [Advisor](https://code.claude.com/docs/en/advisor) · [Evals](https://code.claude.com/docs/en/plugin-evals)

---

## 10. Pendências

- [ ] Validar numa sessão real (Passo 5) e medir `/context` antes × depois.
- [ ] Executar o CI (push) para PowerShell 7 e Linux.
- [ ] Rodar `claude plugin eval ./plugins/base` e criar evals para skills sob demanda (`/revisar`, `/blueprint`, `/alterar-dados`) — invocação por `/comando` em eval não confirmada na doc.
- [ ] Perfil de CI e template de CI com `anthropics/claude-code-action` (sem caso real).
- [ ] Validar a seção IIS do `/deploy-checklist` e a camada `devcontainer` em projeto real.
- [ ] Fixar `marketingskills` por SHA, se o schema aceitar.
- [ ] Confirmar direitos de distribuição do `Auditoria LGPD.pdf`.
