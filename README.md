# claude-code-setup — Configuração do Claude Code

Configuração de uso geral do Claude Code (Desktop → aba **Code** → sessão **Local**, e CLI) para Windows: instruções globais, settings, agentes, skills, hook de segurança e modelos para projetos.

> **Nada aqui é aplicado sozinho.** Os arquivos ficam no repositório até você rodar os passos da seção 5. Todo passo mostra antes o que vai mudar.
> **Nada pessoal ou de cliente entra no pacote.** Caminhos da máquina e lista de projetos ficam em `~\.claude\maquina.md` (Passo 2); regras de um projeto específico ficam no `CLAUDE.md` daquele repositório.

---

## 1. Estrutura

```text
claude-code-setup\
├── README.md                  ← este guia
├── LICENSE                    ← MIT (uso livre, sem garantia)
├── Auditoria LGPD.pdf         ← documento-base da skill /lgpd-audit
├── .gitattributes             ← fim de linha LF fixo (o instalador compara arquivos por SHA-256)
├── .gitignore                 ← impede versionar segredos e arquivos gerados
├── .github\workflows\tests.yml← roda os testes no Windows (PowerShell 5.1 e 7)
│
├── global\                    ← tudo que vai para %USERPROFILE%\.claude\
│   ├── CLAUDE.md              ← instruções carregadas em toda sessão (curto); importa ~\.claude\maquina.md
│   ├── maquina.example.md     ← modelo do arquivo por máquina (não é instalado)
│   ├── settings.merge.json    ← modelos, plugins globais, hook, regras deny/ask
│   ├── agents\                ← 6 agentes (ver seção 2.3)
│   ├── hooks\                 ← bloquear-segredos.ps1
│   └── skills\                ← 17 skills (ver seção 2.2)
│
├── project-templates\         ← o que vai para cada projeto
│   ├── CLAUDE.project.md      ← modelo de CLAUDE.md de projeto
│   ├── gitignore.claude       ← linhas para somar ao .gitignore do projeto
│   └── <camada>\.claude\settings.json   ← uma pasta por camada (ver seção 2.1)
│
├── scripts\
│   ├── merge-settings.ps1     ← mescla settings (global ou camadas de projeto)
│   └── instalar-arquivos.ps1  ← copia CLAUDE.md, agents, skills e hooks para ~\.claude
│
└── tests\                     ← Pester 5: casos do hook (casos-hook.psd1) e do merge
```

---

## 2. Como funciona

### 2.1 Global × máquina × projeto
- **Global** (`~\.claude\`): vale para todas as sessões. Contém preferências, segurança, modelos, os plugins `context7` e `security-guidance`, agentes e skills. É igual em toda máquina.
- **Máquina** (`~\.claude\maquina.md`): pasta de projetos, pasta de memória, caminho do clone deste repositório e a tabela de projetos atuais. Importado pelo `CLAUDE.md` global (`@~/.claude/maquina.md`).
- **Projeto** (`<repo>\CLAUDE.md` + `<repo>\.claude\settings.json`): stack, comandos, arquitetura, regras de negócio e os plugins daquele projeto. Plugin de projeto nunca vai no global.
- O `settings.json` do projeto é montado por **camadas**. Cada camada é uma pasta em `project-templates\`, e você combina as que servem ao projeto. A regra é sempre `_base` + as camadas da stack:

| Stack | Camadas | O que cada uma faz |
|---|---|---|
| Backend .NET | `_base,dotnet` | `_base`: o Claude não lê `node_modules`, `bin`, `obj`, `dist` etc. · `dotnet`: `csharp-lsp` |
| Frontend Angular | `_base,angular` | `typescript-lsp` + `frontend-design` |
| Node/TS (não Angular) | `_base,node-ts` | `typescript-lsp` |
| Python | `_base,python` | `pyright-lsp`; não lê `.venv` |
| Só docker/terraform | `_base,infra` | não lê `.tfstate`/`.tfvars` |
| Opcionais | `supabase`, `marketing`, `playwright`, `serena` | só quando o projeto precisar |

Detalhes de cada plugin e camada: skill `env-guide` (`global\skills\env-guide\SKILL.md`), que é a **fonte única** de plugins e camadas.

### 2.2 Skills
- **Automáticas** (o Claude usa sozinho quando faz sentido): `env-guide` (guia do ambiente), `project-bootstrap` (prepara um projeto), `arquitetura-onion` (padrão de camadas do backend .NET) e `arquitetura-angular` (padrão do frontend Angular).
- **Sob demanda** (só rodam quando **você** digita `/nome`; não ocupam contexto): `/revisar`, `/blueprint`, `/alterar-dados`, `/deploy-checklist`, `/medir-antes-depois`, `/divida`, `/criar-testes`, `/explicar`, `/limpar-codigo`, `/preparar-pr`, `/adr`, `/plano-migracao`, `/postmortem`, `/lgpd-audit`, `/session-handoff`.
- Documentos gerados (blueprints, relatório LGPD, handoff) ficam **fora do repositório**, na pasta indicada na linha `Documentação:` do `CLAUDE.md` do projeto. A única exceção é o `DIVIDA.md`, que fica versionado na raiz do projeto.

### 2.3 Modelos e agentes
- Sessão **Sonnet** + advisor **Opus**, que é consultado nas decisões. Em tarefa crítica (arquitetura, segurança, banco, LGPD), troque a sessão para Opus no seletor.
- Agentes, cada um com `model:` próprio:

| Agente | Modelo | Faz |
|---|---|---|
| `Explore` | haiku | Busca ampla no código (substitui o embutido) |
| `researcher-haiku` | haiku | Pesquisa em documentação e web |
| `reviewer-haiku` | haiku | Revisão rápida de diff |
| `test-validator-haiku` | haiku | Roda build/testes e resume |
| `documentation-haiku` | haiku | Edita só arquivos `.md` |
| `implementer-sonnet` | sonnet | Implementação delegada, escopo fechado |

- Os embutidos `Plan` e `general-purpose` herdam o Sonnet da sessão.

### 2.4 Proteções
- **Regras `deny`**: o Claude não lê `.env`, chaves, certificados, `secrets/`, `appsettings` de ambiente real (`Production`, `Prod`, `Staging`, `Homolog*`, `Local`), credenciais em `~\.ssh`, `~\.aws` etc. Também não edita o `settings.json` global nem os hooks.
- **`appsettings.json` e `appsettings.Development.json` ficam liberados** (e versionáveis): muitos projetos os versionam sem segredo. A proteção de .NET é pelo conteúdo: segredo vai em User Secrets ou variável de ambiente, nunca no `appsettings` versionado.
- **Regras `ask`**: pedem sua confirmação antes de commit/push, `fetch`/`pull`/`clone`, comandos git que descartam trabalho (`checkout --`, `restore`, `stash drop`, `branch -D`, `reset --hard`, `clean`), instalar pacotes, rodar scripts do projeto (`npm run`/`test`/`start`, `dotnet run`/`test`), rede (`curl`, `ssh`…), apagar ou mover arquivos (`rm`, `del`, `rmdir`, `mv`) e editar CLAUDE.md/skills/agentes. Cada regra existe para Bash e para PowerShell.
- **Hook `bloquear-segredos.ps1`**: confere o texto de todo comando de shell. Bloqueia o que citar um arquivo de segredo e pede confirmação para o que mexer em `.claude`, rodar os scripts com `-Confirmar`, esconder o comando (base64) ou fazer git/rede/exclusão **no meio de um encadeamento** ou com `git -C pasta` (o que as regras `ask` por prefixo não pegam). **Se o próprio hook falhar depois de ler o comando, ele pede confirmação em vez de liberar.**
- Precisa ler algo bloqueado de propósito? Rode você mesmo com `! <comando>`.

### 2.5 Scripts em dois passos
Os dois scripts funcionam igual:
1. `-DryRun`: mostra o que vai mudar (JSON final ou lista de arquivos NOVO/ALTERADO/IGUAL com SHA-256 e diff), os **alertas** e um **código**. Não grava nada.
2. `-Confirmar <código>`: grava, fazendo backup antes. Se algo mudou desde o dry-run, o código deixa de valer: rode o dry-run de novo.

Para rejeitar, basta não rodar o segundo passo. Rodar de novo sem mudança não grava nada.

Opções do `merge-settings.ps1`:
- O merge **adiciona**: objetos se mesclam, listas viram união. Valor escalar do pacote **sobrescreve** o seu (ex.: `"model"`); o dry-run lista cada um como `SOBRESCREVE`. Use **`-ManterEscalares`** para manter os seus (aparecem como `MANTIDO`).
- **`-Remover`** tira do resultado o que o pacote não remove sozinho: `-Remover env.CLAUDE_CODE_SUBAGENT_MODEL` (apaga a chave) ou `-Remover 'permissions.allow[]=Bash(winget:*)'` (tira um item da lista). Vários itens: separe por vírgula. Remover `deny`, `ask` ou hook gera **ALERTA**.
- O caminho do hook é gravado **absoluto** (`C:/Users/<você>/.claude/hooks/...`), sem depender de `$HOME` expandir no shell do hook. Instalação antiga com `$HOME` é convertida (aparece no dry-run como hook que sai e hook que entra).
- **`-HookShell pwsh`** grava o hook com PowerShell 7, que abre mais rápido que o 5.1 (cada comando de shell abre um processo do hook). Exige `pwsh` instalado.

---

## 3. Pré-requisitos

```powershell
git --version        # Git for Windows (obrigatório para a aba Code)
node --version       # Node 20+ (alguns plugins)
claude --version     # Claude Code recente (advisor no Desktop)
pwsh --version       # opcional: PowerShell 7 para o hook (-HookShell pwsh)
```

LSPs, só se for ativar nos projetos:
```powershell
dotnet tool install --global csharp-ls
npm install -g typescript-language-server typescript
```

---

## 4. Arquivos que a instalação altera

| Arquivo em `~\.claude\` | Passo | Backup |
|---|---|---|
| `maquina.md` (só se não existir) | 2 | — |
| `CLAUDE.md`, `agents\`, `skills\`, `hooks\` (só os itens do pacote) | 3 | automático em `backups\instalar-AAAAMMDD-HHmmss\` |
| `settings.json` | 4 | automático em `settings.json.bak-AAAAMMDD-HHmmss` |

Nada mais é gravado. Arquivo que só existe no destino não é tocado.

---

## 5. Instalação

Abra o **PowerShell** (5.1 ou 7) **dentro da pasta deste repositório**:

```powershell
$repo = (Resolve-Path .).Path
$cl   = "$env:USERPROFILE\.claude"
if (-not (Test-Path "$repo\scripts\merge-settings.ps1")) { throw "Rode dentro da pasta do claude-code-setup." }
```

### Passo 1 — Backup
Copia só o que existe (instalação nova não tem nada para copiar):
```powershell
$bk = "$cl\backups\setup-$(Get-Date -Format yyyyMMdd-HHmm)"
New-Item -ItemType Directory -Force $bk | Out-Null
foreach ($f in 'CLAUDE.md', 'settings.json', 'maquina.md') { if (Test-Path "$cl\$f") { Copy-Item "$cl\$f" $bk } }
if (Test-Path "$cl\agents") { Copy-Item "$cl\agents" $bk -Recurse }
Write-Host "Backup em $bk"
```

### Passo 2 — Arquivo da máquina
Cria `~\.claude\maquina.md` a partir do modelo (só se ainda não existir) e abre para você preencher pasta de projetos, pasta de memória, caminho deste clone e projetos atuais:
```powershell
if (-not (Test-Path "$cl\maquina.md")) { Copy-Item "$repo\global\maquina.example.md" "$cl\maquina.md" }
notepad "$cl\maquina.md"
```

### Passo 3 — CLAUDE.md, agentes, skills e hook
Este passo vem antes do Passo 4, porque o settings aponta para o hook.
```powershell
powershell -ExecutionPolicy Bypass -File "$repo\scripts\instalar-arquivos.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "$repo\scripts\instalar-arquivos.ps1" -Confirmar <código>
```
**O `CLAUDE.md` global é substituído inteiro.** Se o seu atual tem regras de um projeto ou cliente específico (deploy, banco, firewall, padrões de equipe), o dry-run avisa: mova essas regras **antes** para o `CLAUDE.md` do repositório daquele projeto, e dados da máquina para o `maquina.md`. O original fica em `backups\instalar-*\CLAUDE.md`.

### Passo 4 — Settings
Mescla `global\settings.merge.json` no seu `settings.json` e preserva o que já existe. Leia cada **alerta** do dry-run: um alerta inesperado indica alteração indevida no pacote. Valores com nome de segredo aparecem como `***`, e estrutura inválida é recusada antes de gravar.
```powershell
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -DryRun -ManterEscalares
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -Confirmar <código> -ManterEscalares
```
Sem `-ManterEscalares`, o pacote define `model` = Sonnet e `advisorModel` = Opus. Para limpar sobras de outra configuração, use `-Remover` (seção 2.5); por exemplo, `env.CLAUDE_CODE_SUBAGENT_MODEL` colocava `Plan` e `general-purpose` em Haiku.

### Passo 5 — Validar (obrigatório antes de confiar nas proteções)
Feche e abra o Claude Desktop → aba **Code** → nova sessão **Local**. Na primeira abertura os plugins oficiais são baixados. Se aparecer pedido para confiar em marketplace de terceiro, **recuse**.

| Teste | Esperado |
|---|---|
| Peça: "rode `echo .env`" (pela ferramenta Bash e pela PowerShell) | **Bloqueado pelo hook.** Se o comando rodar, o hook não está ativo: confira o caminho em `hooks` no `settings.json` e o `/status` |
| Peça: "leia `~/.ssh/config`" e "leia `~/.claude/.credentials.json`" | Negado |
| Peça: "rode `git -C . push`" | Pede confirmação (hook) |
| Peça: "rode `curl.exe --version`" | Pede confirmação |
| `/status` | `Setting sources` inclui User settings; modelo esperado |
| `/advisor` | Advisor = Opus |
| `/plugin` | `context7` e `security-guidance` ativos; `claude-code-setup` desativado; nenhum de terceiro |
| `/agents` | os 6 agentes da seção 2.3 |
| "quais skills globais você tem?" | `env-guide`, `project-bootstrap`, `arquitetura-onion` e `arquitetura-angular` (as sob demanda não aparecem na lista) |

Plugin oficial que não baixou: `/plugin install <nome>@claude-plugins-official`.

---

## 6. Ativar em um projeto

### Pelo Claude (recomendado)
Abra uma sessão no projeto e peça:
- projeto existente: **"use a skill project-bootstrap no modo adopt-existing"**;
- projeto novo (criado na pasta de projetos do `maquina.md`, com `git init`): **"use a skill project-bootstrap no modo new-project"**.

O Claude detecta a stack, propõe as camadas e mostra o dry-run. Ele só grava depois da sua aprovação.

### Manual
```powershell
$proj = "<pasta de projetos>\<Projeto>"
# 1. settings por camadas (ver antes, depois aplicar com o código):
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -Target "$proj\.claude\settings.json" -Layers _base,dotnet -DryRun
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -Target "$proj\.claude\settings.json" -Layers _base,dotnet -Confirmar <código>
# 2. CLAUDE.md do projeto (só se não existir):
if (-not (Test-Path "$proj\CLAUDE.md")) { Copy-Item "$repo\project-templates\CLAUDE.project.md" "$proj\CLAUDE.md" }
# 3. pasta de documentação fora do repo:
New-Item -ItemType Directory -Force "$(Split-Path $proj)\docs\$(Split-Path $proj -Leaf)\backlog" | Out-Null
# 4. .gitignore: listar as linhas que faltam...
$gi = "$proj\.gitignore"; $atual = if (Test-Path $gi) { Get-Content $gi -Encoding UTF8 } else { @() }
$faltam = Get-Content "$repo\project-templates\gitignore.claude" -Encoding UTF8 | Where-Object { $_ -and $_ -notin $atual }
$faltam   # revisar antes de seguir
# ...e, conferidas, somar ao final sem grudar na última linha:
if ((Test-Path $gi) -and (Get-Content $gi -Raw) -notmatch '\n$') { Add-Content $gi -Value '' -Encoding utf8 }
Add-Content $gi -Value $faltam -Encoding utf8
# 5. só em repositório de cliente (Claude fora do Git sem tocar no .gitignore versionado):
$ex = "$proj\.git\info\exclude"; $atual = if (Test-Path $ex) { Get-Content $ex -Encoding UTF8 } else { @() }
'CLAUDE.md', 'CLAUDE.local.md', '.claude/' | Where-Object { $_ -notin $atual } | ForEach-Object { Add-Content $ex -Value $_ -Encoding utf8 }
```
Troque `_base,dotnet` pelas camadas da stack (tabela da seção 2.1). Depois, registre o projeto na tabela do `maquina.md`.

---

## 7. Uso no dia a dia

| Situação | O que fazer |
|---|---|
| Tarefa comum | Sessão Sonnet; o advisor Opus entra sozinho nas decisões |
| Tarefa crítica | Trocar a sessão para Opus |
| Planejar algo grande | Começar em **Plan mode** |
| Revisar código | `/revisar <estilo>` (seguranca, arquitetura, performance, testes, didatico, a11y, banco, deps, contrato); `/code-review`; `/security-review`; `/simplify` (aplica as correções) |
| Antes de implementar (se o projeto exigir) | `/blueprint <atividade>` |
| Alterar dados em massa / deploy | `/alterar-dados`, `/deploy-checklist` |
| Atalho adiado de propósito | `/divida registrar <atalho>`; `/divida listar` |
| Outras | `/criar-testes`, `/explicar`, `/limpar-codigo`, `/preparar-pr`, `/adr`, `/plano-migracao`, `/postmortem`, `/medir-antes-depois` |
| Auditoria LGPD | `/lgpd-audit` |
| Continuar em outra sessão | `/session-handoff` |
| Desligar o advisor | `/advisor off` |

---

## 8. Desfazer

```powershell
# CLAUDE.md, settings.json e maquina.md do último backup do Passo 1 (só os que existiam):
$bk = (Get-ChildItem "$cl\backups" -Directory -Filter "setup-*" | Sort-Object Name | Select-Object -Last 1).FullName
foreach ($f in 'CLAUDE.md', 'settings.json', 'maquina.md') { if (Test-Path "$bk\$f") { Copy-Item "$bk\$f" $cl -Force } }
# Agentes, skills e hook deste pacote (a lista vem da pasta global\ do repo):
Get-ChildItem "$repo\global\agents" -File      | ForEach-Object { Remove-Item "$cl\agents\$($_.Name)" -ErrorAction SilentlyContinue }
Get-ChildItem "$repo\global\skills" -Directory | ForEach-Object { Remove-Item "$cl\skills\$($_.Name)" -Recurse -ErrorAction SilentlyContinue }
Get-ChildItem "$repo\global\hooks" -File       | ForEach-Object { Remove-Item "$cl\hooks\$($_.Name)" -ErrorAction SilentlyContinue }
```
- Se você tinha versões próprias com o mesmo nome antes de instalar, elas estão em `~\.claude\backups\instalar-*\`. Copie de volta.
- Plugins: `/plugin` → desinstalar, ou remover a entrada de `enabledPlugins`.

---

## 9. Limitações das proteções

O hook e as regras reduzem o risco, mas não fecham tudo. Revise o que você aprova.
- **O hook lê só o texto do comando.** Ele não pega:
  - nome montado em variável (`$a='.e'+'nv'; gc $a`);
  - `cd` para a pasta seguido de caminho relativo (só o `cd` para `.claude` pede confirmação);
  - curinga sozinho (`cat *`);
  - busca que lê segredos sem citar o nome (`grep -r PASSWORD .`);
  - script que lê o arquivo por dentro (`node x.js`, `npm run x` — por isso `npm run`/`dotnet run` pedem confirmação).
- **`appsettings.json` e `appsettings.Development.json` não são protegidos por nome.** Segredo neles fica visível: mantenha-os sem segredo (User Secrets ou variável de ambiente).
- **Falsos positivos:** `obj.key` em JavaScript e `.env.example` são bloqueados; `git commit` dentro de um texto pede confirmação. Nesses casos, use `! <comando>` ou aprove.
- **Se o hook não rodar, ele não bloqueia.** JSON de entrada inválido, arquivo ausente ou timeout de 10 s liberam o comando. Falha interna depois de ler o comando pede confirmação. O merge avisa quando o arquivo do hook não existe; o Passo 5 prova que ele roda.
- **Desempenho:** cada comando de shell abre um processo PowerShell (5.1: ~300–800 ms). `-HookShell pwsh` reduz.
- **Regras `Read(**/...)` valem a partir da pasta da sessão.** As credenciais da pasta do usuário têm regras próprias `Read(~/...)`.
- **Regras `ask` por prefixo** (`Bash(curl:*)`) não pegam o comando por outro nome ou caminho completo. Encadeamentos (`&&`, `;`, `|`) e `git -C` de git, rede e exclusão são cobertos pelo hook; o resto, não.
- **O código de `-Confirmar` não distingue você do agente.** A aprovação real é a confirmação que o hook pede na interface. Em modo que aprova tudo sozinho (`bypassPermissions`), essa confirmação pode não aparecer.
- **O agente pode editar `global\settings.merge.json` neste repositório** (é trabalho normal aqui). Os alertas do dry-run são a defesa.
- **Plugins oficiais seguem a versão mais recente.** O `marketingskills` (camada `marketing`) é fixado por tag, que o autor pode mover. A conferência por SHA está no `env-guide`.
- **Só Windows.** Hook e scripts são PowerShell; com `pwsh` o hook roda em outros sistemas, mas os scripts e caminhos não foram testados fora do Windows.

---

## 10. Testes e manutenção

- **Testes** (Pester 5): `Invoke-Pester .\tests -Output Detailed`. Os casos do hook ficam em `tests\casos-hook.psd1` (comando → `Bloqueia`/`Confirma`/`Libera`); padrão novo no hook entra com caso novo. `$env:HOOK_SHELL = 'pwsh'` testa com PowerShell 7. O GitHub Actions roda os dois shells a cada push.
  - Pester 5 não vem com o Windows: `Install-Module Pester -MinimumVersion 5.5.0 -Scope CurrentUser -SkipPublisherCheck`.
- Alterou algo direto em `~\.claude\`? Copie de volta para `global\` e faça commit aqui. Dado da máquina vai no `maquina.md`, nunca no pacote.
- Plugin de terceiro novo ou atualizado: revisar origem, licença, hooks e dados coletados antes de ativar.
- Mudou plugin ou camada? Atualize o `env-guide` (fonte única), não o README.
- Fontes: [Advisor](https://code.claude.com/docs/en/advisor) · [Subagentes](https://code.claude.com/docs/en/sub-agents) · [Settings](https://code.claude.com/docs/en/settings) · [Memória e imports](https://code.claude.com/docs/en/memory) · [Hooks](https://code.claude.com/docs/en/hooks)

---

## 11. Pendências

- [ ] **Validar numa sessão real** (Passo 5) depois de instalar. Fora do harness: 81 casos do hook e o merge testados no PowerShell 5.1.
- [ ] Rodar os testes no PowerShell 7 (CI) antes de recomendar `-HookShell pwsh`.
- [ ] Fixar `marketingskills` por SHA, se o schema de `extraKnownMarketplaces` aceitar.
- [ ] Avaliar o plugin Task Observer (origem, licença, hooks).
- [ ] Medir tokens/custo antes e depois do advisor (`/usage`).
