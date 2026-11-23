# claude-code-setup — base portátil para o Claude Code

Configuração genérica do Claude Code (Desktop → aba **Code**, e CLI) para qualquer projeto: instruções globais curtas, permissões por classe de operação, hook contra vazamento de segredos, skills e agentes distribuídos como **plugins**, e modelos de projeto por camadas.

> **Nada é aplicado sozinho.** Todo passo mostra antes o que vai mudar (dry-run + código de confirmação + backup).
> **Nada pessoal ou de cliente entra no pacote.** Dados da máquina ficam em `~/.claude/maquina.md`; regras de um projeto ficam no `CLAUDE.md` daquele repositório.

Inventário completo (plugins, skills, agentes, camadas, perfis), gerado dos próprios arquivos: [plugins/base/skills/env-guide/componentes.md](plugins/base/skills/env-guide/componentes.md).

---

## 1. Estrutura

```text
claude-code-setup/
├── .claude-plugin/marketplace.json   ← marketplace "kit-dev-ia" (plugins base, dotnet e angular)
├── core/                             ← o que plugin não distribui (instalado pelos scripts)
│   ├── CLAUDE.md                     ← instruções globais (≤ 40 linhas); importa ~/.claude/maquina.md
│   ├── indice-skills.md              ← índice das skills manuais por área (gerado; importado pelo CLAUDE.md)
│   ├── agents/Explore.md             ← Explore em Haiku (agente de plugin não sobrescreve o embutido)
│   ├── settings.merge.json           ← modelo, advisor, marketplace, permissões allow/ask/deny
│   └── maquina.example.md            ← modelo do arquivo por máquina (não é instalado)
├── plugins/
│   ├── base/                         ← skills, agentes, hook de segredos, evals
│   ├── dotnet/                       ← arquitetura onion (ligado por projeto)
│   └── angular/                      ← arquitetura de frontend Angular (ligado por projeto)
├── profiles/unix/settings.json       ← sandbox para macOS/Linux/WSL2
├── project-templates/                ← camadas de projeto (settings, regras por caminho, devcontainer)
├── scripts/                          ← merge-settings, instalar-arquivos, gerar-docs
├── install/                          ← instalação (guia canônico e instalar.ps1)
└── tests/                            ← Pester 5+: hook, scripts, estrutura, conteúdo
```

**Critério plugin × template:** vira **plugin** o que traz skills ou agentes reutilizáveis em vários projetos (instalação e atualização oficiais; `base`, `dotnet`, `angular`). Vira **template** (`project-templates/`) o que são só arquivos de partida copiados para o projeto (settings, regras por caminho, devcontainer: `node-ts`, `python`, `supabase`, `infra`, `playwright`, `serena`, `marketing`). Uma stack só ganha plugin quando tiver skill própria.

### Por que essa divisão
| Peça | Mecanismo | Motivo |
|---|---|---|
| Skills, agentes, hook | Plugin (`/plugin install`) | instalação, atualização e remoção oficiais, em qualquer sistema |
| Permissões, sandbox, modelo, advisor | `merge-settings.ps1` | plugin só aplica `agent`/`subagentStatusLine` do settings ([doc](https://code.claude.com/docs/en/plugins-reference)) |
| CLAUDE.md global, agente `Explore` | `instalar-arquivos.ps1` | CLAUDE.md de plugin não carrega; agente de plugin não sobrescreve o `Explore` embutido ([doc](https://code.claude.com/docs/en/sub-agents)) |
| Regras por caminho | camadas de projeto (`.claude/rules/`) | plugin não distribui regras; elas só carregam ao tocar arquivos do tipo ([doc](https://code.claude.com/docs/en/memory)) |

Os plugins `dotnet` e `angular` ficam desligados por padrão: a camada de projeto da stack liga o seu, e a descrição da skill de arquitetura só ocupa contexto onde é útil.

---

## 2. Instalação

Procedimento completo (pré-requisitos, caminho guiado e manual, migração da versão 1, validação, atualizar, desinstalar, recuperar e problemas comuns): **[install/README.md](install/README.md)**, fonte única. Nada aqui repete esses passos.

Início rápido, na pasta do clone (Git, Claude Code e PowerShell; `pwsh` é obrigatório em macOS/Linux):
```powershell
pwsh -NoProfile -File install/instalar.ps1 -SoSimular   # só mostra o que mudaria; não grava
pwsh -NoProfile -File install/instalar.ps1              # guiado: mostra o dry-run e pergunta antes de gravar
```

---

## 3. Ativar em um projeto

Peça ao Claude: **"use a skill project-bootstrap"** (modo `adopt-existing` ou `new-project`). Ele detecta a stack, propõe as camadas e mostra o dry-run antes de gravar.

Manual:
```powershell
$proj = "<pasta do projeto>"
pwsh -NoProfile -File "$repo/scripts/merge-settings.ps1" -Target "$proj/.claude/settings.json" -Layers _base,dotnet -DryRun
pwsh -NoProfile -File "$repo/scripts/merge-settings.ps1" -Target "$proj/.claude/settings.json" -Layers _base,dotnet -Confirmar <código>
# Regras por caminho das camadas escolhidas (sem sobrescrever):
New-Item -ItemType Directory -Force "$proj/.claude/rules" | Out-Null
Get-ChildItem "$repo/project-templates/dotnet/.claude/rules" -File | Where-Object { -not (Test-Path "$proj/.claude/rules/$($_.Name)") } | Copy-Item -Destination "$proj/.claude/rules"
if (-not (Test-Path "$proj/CLAUDE.md")) { Copy-Item "$repo/project-templates/CLAUDE.project.md" "$proj/CLAUDE.md" }
```
- `.gitignore`: somar as linhas de `project-templates/gitignore.claude` que faltam (o `project-bootstrap` faz isso lendo em UTF-8).
- Repositório de cliente em que o Claude não deve aparecer: em vez do `.gitignore`, somar `CLAUDE.md`, `CLAUDE.local.md` e `.claude/` ao `.git/info/exclude`.
- **Documentação do projeto** (blueprints, relatório LGPD, handoff): as skills perguntam uma vez se fica **só local** (fora do repositório, padrão e obrigatório em projeto de cliente) ou **versionada no Git** do projeto (`docs/planejamento/`, só projeto próprio, para abrir em outro ambiente) e gravam a resposta na linha `Documentação:` do `CLAUDE.md`. Em ambos os casos, commit e push só a pedido.
- **Blueprint com aprovação:** toda alteração não trivial começa por um blueprint (status `RASCUNHO vN`) aberto no navegador pelo `ver-blueprint.ps1`; o Claude só implementa depois de um "aprovado" explícito, marca o checklist durante a implementação (dá para retomar depois de `/clear`) e fecha com a avaliação de brechas. Trivial (1 arquivo, até ~20 linhas, sem banco, autenticação, contrato, segredos ou dados de usuário) dispensa. A regra fica no `core/CLAUDE.md`: depois de atualizar o pacote, rodar `/plugin update` e o `instalar-arquivos.ps1`. Um hook que bloqueie edição sem blueprint aprovado fica para depois, só se a regra falhar no uso real.
- Camada `devcontainer` (copiar `.devcontainer/`): isolamento para Windows nativo ou código não confiável — validada com a CLI do devcontainer em 2026-11-14; **sem uso em projeto real**. A decisão por ambiente (hook, sandbox, contêiner, VM descartável, `ai-jail` como opção externa) está na seção "Isolamento por ambiente" da skill `env-guide`.

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
| Publicação e rede | **ask** (gh api/gist/secret/release/repo create, ações em PR (gh pr merge/review/comment/close/edit/ready), curl, wget, ssh, scp, rsync, Invoke-WebRequest…) |
| Destrutivas e código inline | **ask** (rm, del, mv, Remove-Item, Move-Item, `node -e`, `python -c`, `bash -c`, `powershell`, `cmd`, `iex`, `Start-Process`) |

As regras nativas dividem comandos compostos (`x && git push` pede confirmação). Nenhum modo de aprovação automática substitui esta política.

**Risco aceito no Windows nativo:** build e teste liberados rodam scripts do projeto, que podem ler segredos sem citar o nome. Mitigação: segredos fora do repositório (User Secrets, variável de ambiente); para código não confiável, WSL2 com `-Perfil unix` ou a camada `devcontainer`.

---

## 5. Uso no dia a dia

| Situação | O que fazer |
|---|---|
| Tarefa comum | sessão Sonnet; o advisor Opus entra nas decisões |
| Arquitetura, segurança, banco, LGPD | trocar a sessão para Opus |
| Alteração não trivial | skill `blueprint` (automática ou `/blueprint`): blueprint aberto no navegador, implementação só após você aprovar, avaliação de brechas no fim. Algo grande: junto com o Plan mode |
| Revisar | `/revisar` (lentes escolhidas pelo risco do diff), `/revisar <lente>` ou `/revisar pr <número|branch> [completo]` (CI, conflito com a base e veredito, só leitura); `/code-review`, `/security-review` |
| Dados em massa / deploy | `/alterar-dados`, `/deploy-checklist` (o Claude sugere a skill manual certa pelo índice `indice-skills.md`) |
| Produto e requisitos | `/historias-de-usuario`, `/priorizacao`, `/metricas-de-produto`, `/comunicacao-de-status` |
| Dados | `/escolha-de-banco-e-capacidade`, `/modelagem-dados`, `/plano-migracao` |
| Segurança | `/autenticacao-e-sessao`, `/gestao-de-segredos`, `/endurecimento-de-infraestrutura`, `/lgpd-audit` |
| Incidente | `/resposta-a-incidente` (durante), `/postmortem` (depois) |
| Bug e desempenho | `depurar` (automática ao pedir para investigar bug, exception ou teste falhando: causa raiz, correção mínima, validação rodando), `/revisar performance <caminho>` e `/medir-antes-depois` para otimizar |
| Integrações e decisões | `/integracoes`, `/adr`, `/divida` |
| Testes e qualidade | `/criar-testes`, `/teste-de-api`, `/automacao-e2e`, `/regressao-e-smoke`, `/laudo-de-evidencia`, `/medir-antes-depois` |
| Interface | `desenvolvimento-de-interfaces` (automática: criar, auditar ou corrigir telas; escolhe as especialidades), `/referencias-visuais`, `/sistema-de-design`, `/padroes-de-pagina`, `/componentes-e-estados`, `/layout-responsivo`, `/inspecao-visual` (Playwright: capturas, larguras, console e rede), `/automacao-e2e`, `/revisar interface`, `/revisar a11y` |
| Entrega e código | `/entrega-sem-pendencia`, `/preparar-pr`, `/responder-revisao` (comentários de PR: corrige, responde thread a thread e resolve, com confirmação), `/session-handoff`, `/explicar`, `/limpar-codigo` |
| Esqueceu o nome de um comando | `/comandos` (todos, com resumo de uma linha) ou `/comandos <texto>` (filtra) |

Skills de plugin também respondem com prefixo (`/base:revisar`). Desktop e CLI leem o mesmo `~/.claude`: a configuração é a mesma nos dois.

---

## 6. Atualizar, desinstalar e recuperar

Em [install/README.md, seção 6](install/README.md#6-atualizar-desinstalar-e-recuperar). Em resumo: `git pull`, atualizar o marketplace e os plugins, `/reload-plugins` e repetir os Passos 3 e 4; os backups ficam em `~/.claude/settings.json.bak-*` e `~/.claude/backups/instalar-*/`.


---

## 7. Portabilidade

| Componente | Windows PS 5.1 | Windows PS 7 | Linux / WSL2 | macOS |
|---|---|---|---|---|
| Hook (plugin, Git Bash/sh) | testado aqui | testado aqui (88 casos do `casos-hook.psd1` via `pwsh`) | CI passou (Pester no `ubuntu-latest`, PR #9); dentro do Claude Code, não testado | CI passou (Pester no `macos-latest`, PR #9); dentro do Claude Code, não testado |
| `merge-settings.ps1`, `instalar-arquivos.ps1`, `gerar-docs.ps1` | testado aqui | CI passou (`windows-latest`, PR #9) | CI passou (`ubuntu-latest`, PR #9); uso real não testado | CI passou (`macos-latest`, PR #9); uso real não testado |
| Plugins e marketplace (`claude plugin validate`, instalação isolada) | testado aqui | — | não testado | não testado |
| Sandbox (`-Perfil unix`) | não suportado (doc oficial) | não suportado | não testado | não testado |
| Devcontainer | testado com a CLI `devcontainer` (build, Claude Code instalado, volume, isolamento); autenticação e projeto real não testados | — | não testado | não testado |
| Desktop × CLI | mesma configuração (`~/.claude`) | | | |

Windows sem Git Bash: o hook em shell form roda no PowerShell e falha a sintaxe `sh` ([doc](https://code.claude.com/docs/en/hooks)). Instale o Git for Windows ou defina `CLAUDE_CODE_GIT_BASH_PATH`.

---

## 8. Limitações das proteções

- **O hook lê só o texto do comando.** Não pega nome montado em variável, `cd` + caminho relativo, curinga sozinho (`cat *`), busca que lê segredos sem citar o nome (`grep -r PASSWORD .`) nem script que lê o arquivo por dentro. Medição: 7/7 desses casos passam — é camada contra acidente.
- **Isolamento é em camadas e cada uma tem limite:** o sandbox e o contêiner reduzem o dano de um comando errado, mas não são barreira contra código hostil (para isso, VM descartável). Ferramenta externa de sandbox (ex.: `ai-jail`) com máscara de arquivo no Linux pode perder a regra se o arquivo for substituído (salvar por outro editor): mantenha segredos em pasta inteira mascarada e fora do repositório.
- **Falso positivo conhecido:** `git commit -m "... .env ..."` é bloqueado (use `! <comando>`).
- **Hook que não roda não bloqueia:** o timeout libera (decisão do Claude Code); JSON inválido ou vazio, falha interna e ausência de PowerShell (ponte) pedem confirmação. Se o Claude Code mudar o formato da entrada, haverá confirmação em todo comando Bash/PowerShell até o hook ser ajustado.
- **O hook custa tempo em todo comando Bash/PowerShell:** no Windows ele usa o PowerShell 5.1 mesmo com o `pwsh` instalado, porque abre mais rápido (medido em 17/11/2026 pelo Git Bash: ~400 ms com o 5.1 × ~610 ms com o `pwsh` 7.7 do winget). Fora do Windows usa o `pwsh`. Depois de atualizar o pacote: `/plugin update` e `/reload-plugins`.
- **Regras `ask/deny` por texto** não pegam o programa por caminho completo ou dentro de `sh -c` (doc oficial); o sandbox (macOS/Linux/WSL2) é a proteção que não depende do texto.
- **`appsettings.json` e `appsettings.Development.json` não são protegidos por nome:** mantenha-os sem segredo.
- **Agentes com Bash (`revisor`, `test-validator-haiku`):** a restrição de comandos é só instrução. Agente de plugin não aceita `hooks` nem `permissionMode` no frontmatter, e `disallowedTools: Bash(...)` remove o Bash inteiro ([doc](https://code.claude.com/docs/en/sub-agents)); valem as regras ask/deny e o hook da sessão.
- **Modelos `.env.example`, `.env.sample`, `.env.template` e `.env.dist`:** a ferramenta Read os nega (`deny Read(**/.env.*)`) e o hook libera no shell (`cat .env.example`). É intencional: `deny` prevalece sobre `allow`, e estreitar o `deny` para uma lista de sufixos abriria nomes desconhecidos (`.env.backup`, `.env.old`).
- **O código de `-Confirmar` não distingue você do agente:** a aprovação real é a confirmação que o hook pede ao ver `-Confirmar` (ou uma abreviação, como `-Conf`) em `merge-settings` ou `instalar-arquivos`, ou qualquer chamada de `install/instalar.ps1`, que os chama por dentro.
- **Variável de ambiente com nome de segredo pede confirmação, não bloqueia:** `$env:*TOKEN*`, `$GH_TOKEN`, `Get-Item env:*PASSWORD*`, `GetEnvironmentVariable` e `/proc/*/environ` (termos: TOKEN, SECRET, PASSWORD, PASSWD, API_KEY, PRIVATE_KEY, CREDENTIAL). Não pega nome montado (`$env:$x`, `${!x}`) nem variável com outro nome; o `sandbox` do perfil `unix` é a proteção que não depende do texto.
- **Nome de segredo com ponto final (`.env.`) é bloqueado, porque o Windows ignora o ponto.** Nomes curtos 8.3 (`ENV~1`) não são cobertos. Efeito colateral: `echo "veja .env."` também bloqueia.
- **Plugins oficiais seguem a versão mais recente.** `marketingskills` (camada `marketing`) é fixado por SHA completo em `ref`; conferência no `env-guide`.
- **Marketplace `kit-dev-ia` fixado por tag** (`ref: v1.0.3` em `core/settings.merge.json` e `project-templates/_base/.claude/settings.json`; exige Claude Code ≥ 2.1.324 só se o `ref` for SHA). Atualizar de propósito: (1) commitar as mudanças; (2) criar e enviar a tag nova (`git tag vX.Y.Z && git push origin vX.Y.Z`); (3) trocar o `ref` nos dois arquivos num commit seguinte (um commit não contém o próprio SHA); (4) `/plugin marketplace update kit-dev-ia`.

---

## 9. Testes e manutenção

- `Invoke-Pester ./tests -Output Detailed` (Pester 5 ou 6; o Windows PowerShell 5.1 traz o 3.4, então instale o 6.2.0: `Install-Module Pester -RequiredVersion 6.2.0 -Scope CurrentUser -SkipPublisherCheck`). O resultado oficial é o do CI (4 combinações: Windows PowerShell 5.1, Windows `pwsh`, Ubuntu e macOS); contagens não ficam fixas aqui.
- Mexeu em `core/`? Suba o número de `core/core-versao.txt` **e** de `plugins/base/core-versao.txt` (o teste exige os dois iguais); é o que faz o hook `SessionStart` avisar quem ficou com `core/` antigo.
- Casos do hook em `tests/casos-hook.psd1`: padrão novo no hook entra com caso novo.
- Mudou skill, agente, plugin, camada ou perfil? Rode `scripts/gerar-docs.ps1` e commite o `componentes.md`, o `comandos.md` da skill `/comandos` e o `core/indice-skills.md` (área e \ (o teste falha se ficarem desatualizados).
- `claude plugin validate .` e `claude plugin validate ./plugins/<nome>` antes de publicar.
- Evals em `plugins/base/evals/`: `claude plugin eval ./plugins/base --max-cost-usd <teto>` (chama o modelo; custo; o juiz padrão é o Haiku; `--case 'blueprint-*'` roda um grupo). Casos: `blueprint-*`, `revisar-*`, `alterar-dados-*`, `adotar-projeto`, `qual-skill-revisar`, `lente-testes-mock`, `responder-revisao-confirma` e `comandos-*`. Skill manual (`/revisar`, `/alterar-dados`) é acionada no eval com o prompt começando por `/base:<skill>` e avaliada pelo comportamento da resposta. Histórico de rodadas e custos: [CHANGELOG.md](CHANGELOG.md).
- Termos proibidos (dado de cliente): lista **fora** do repositório em `../docs/claude-code-setup/termos-proibidos.txt` ou `CCS_TERMOS_PROIBIDOS`; sem lista, o teste fica pulado.

Fontes: [Plugins](https://code.claude.com/docs/en/plugins-reference) · [Marketplace](https://code.claude.com/docs/en/plugin-marketplaces) · [Permissões](https://code.claude.com/docs/en/permissions) · [Sandbox](https://code.claude.com/docs/en/sandboxing) · [Hooks](https://code.claude.com/docs/en/hooks) · [Memória e regras](https://code.claude.com/docs/en/memory) · [Subagentes](https://code.claude.com/docs/en/sub-agents) · [Advisor](https://code.claude.com/docs/en/advisor) · [Evals](https://code.claude.com/docs/en/plugin-evals)

---

## 10. Pendências

Pendências abertas e o que já foi resolvido: [`docs/pendencias.md`](docs/pendencias.md). Ideias futuras: abra uma issue no repositório.
