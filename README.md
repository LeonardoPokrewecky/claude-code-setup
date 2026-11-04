# claude-code-setup — Configuração do Claude Code (Leonardo)

Repositório com toda a configuração do Claude Code (Desktop → aba **Code** → sessão **Local**, e CLI): instruções globais, settings, agentes, skills, hook de segurança e modelos para projetos.

> **Nada aqui é aplicado sozinho.** Os arquivos ficam no repositório até você rodar os passos da seção 5. Todo passo mostra antes o que vai mudar.

---

## 1. Estrutura

```text
claude-code-setup\
├── README.md                  ← este guia
├── PROPOSTA.md                ← histórico das decisões (arquivado; não descreve o estado atual)
├── Auditoria LGPD.pdf         ← documento-base da skill /lgpd-audit
├── .gitattributes             ← fim de linha LF fixo (o instalador compara arquivos por SHA-256)
├── .gitignore                 ← impede versionar segredos e arquivos gerados
│
├── global\                    ← tudo que vai para %USERPROFILE%\.claude\
│   ├── CLAUDE.md              ← instruções carregadas em toda sessão (curto)
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
└── scripts\
    ├── merge-settings.ps1     ← mescla settings (global ou camadas de projeto)
    └── instalar-arquivos.ps1  ← copia agents, skills e hooks para ~\.claude
```

---

## 2. Como funciona

### 2.1 Global × projeto
- **Global** (`~\.claude\`): vale para todas as sessões. Contém preferências, segurança, modelos, os plugins `context7` e `security-guidance`, agentes e skills.
- **Projeto** (`<repo>\CLAUDE.md` + `<repo>\.claude\settings.json`): contém stack, comandos, arquitetura e os plugins daquele projeto. Plugin de projeto nunca vai no global.
- O `settings.json` do projeto é montado por **camadas**. Cada camada é uma pasta em `project-templates\`, e você combina as que servem ao projeto. A regra é sempre `_base` + as camadas da stack:

| Stack | Camadas | O que cada uma faz |
|---|---|---|
| Backend .NET | `_base,dotnet` | `_base`: o Claude não lê `node_modules`, `bin`, `obj`, `dist` etc. · `dotnet`: `csharp-lsp` |
| Frontend Angular | `_base,angular` | `typescript-lsp` + `frontend-design` |
| Node/TS (não Angular) | `_base,node-ts` | `typescript-lsp` |
| Python | `_base,python` | `pyright-lsp`; não lê `.venv` |
| Só docker/terraform | `_base,infra` | não lê `.tfstate`/`.tfvars` |
| Opcionais | `supabase`, `marketing`, `playwright`, `serena` | só quando o projeto precisar |

Detalhes de cada plugin e camada: skill `env-guide` (`global\skills\env-guide\SKILL.md`), que é a **fonte única** de plugins e projetos atuais.

### 2.2 Skills
- **Automáticas** (o Claude usa sozinho quando faz sentido): `env-guide` (guia do ambiente) e `project-bootstrap` (prepara um projeto).
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
- **Regras `deny`**: o Claude não lê `.env`, chaves, certificados, `secrets/`, `appsettings.*.json`, credenciais em `~\.ssh`, `~\.aws` etc. Também não edita o `settings.json` global nem os hooks.
- **Regras `ask`**: pedem sua confirmação antes de commit/push, instalar pacotes, rede (`curl`, `ssh`…), apagar arquivos e editar CLAUDE.md/skills/agentes. Cada regra existe para Bash e para PowerShell.
- **Hook `bloquear-segredos.ps1`**: confere o texto de todo comando de shell. Bloqueia o que citar um arquivo de segredo e pede confirmação para o que mexer em `.claude` ou rodar os scripts com `-Confirmar`.
- Precisa ler algo bloqueado de propósito? Rode você mesmo com `! <comando>`.

### 2.5 Scripts em dois passos
Os dois scripts funcionam igual:
1. `-DryRun`: mostra o que vai mudar (JSON final ou lista de arquivos NOVO/ALTERADO/IGUAL com SHA-256 e diff), os **alertas** e um **código**. Não grava nada.
2. `-Confirmar <código>`: grava, fazendo backup antes. Se algo mudou desde o dry-run, o código deixa de valer: rode o dry-run de novo.

Para rejeitar, basta não rodar o segundo passo. Rodar de novo sem mudança não grava nada.
O merge de settings **só adiciona**: uma chave removida do pacote continua no seu `settings.json` e precisa ser removida à mão.

---

## 3. Pré-requisitos

```powershell
git --version        # Git for Windows (obrigatório para a aba Code)
node --version       # Node 20+ (alguns plugins)
claude --version     # Claude Code 2.1.260+ (advisor no Desktop)
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
| `CLAUDE.md` | 2 | Passo 1 |
| `agents\`, `skills\`, `hooks\` (só os itens do pacote) | 3 | automático em `backups\instalar-AAAAMMDD-HHmmss\` |
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
```powershell
$bk = "$cl\backups\setup-$(Get-Date -Format yyyyMMdd-HHmm)"
New-Item -ItemType Directory -Force $bk | Out-Null
Copy-Item "$cl\CLAUDE.md", "$cl\settings.json" $bk
if (Test-Path "$cl\agents") { Copy-Item "$cl\agents" $bk -Recurse }
Write-Host "Backup em $bk"
```

### Passo 2 — CLAUDE.md global
Confira o diff e só depois copie. Ele **substitui** o arquivo inteiro.
```powershell
$src = "$repo\global\CLAUDE.md"; $dst = "$cl\CLAUDE.md"
(Get-FileHash $src).Hash; if (Test-Path $dst) { (Get-FileHash $dst).Hash; git diff --no-index -- $dst $src }
# conferido o diff acima:
Copy-Item $src $dst -Force
```

### Passo 3 — Agentes, skills e hook
Este passo vem antes do Passo 4, porque o settings aponta para o hook.
```powershell
powershell -ExecutionPolicy Bypass -File "$repo\scripts\instalar-arquivos.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "$repo\scripts\instalar-arquivos.ps1" -Confirmar <código>
```

### Passo 4 — Settings
Mescla `global\settings.merge.json` no seu `settings.json` e preserva o que já existe. Leia cada **alerta** do dry-run: um alerta inesperado indica alteração indevida no pacote. Valores com nome de segredo aparecem como `***`, e estrutura inválida é recusada antes de gravar.
```powershell
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -Confirmar <código>
```
Vindo de versão anterior:
- Se o seu `settings.json` tiver `env.CLAUDE_CODE_SUBAGENT_MODEL`, remova à mão. Essa chave colocava `Plan` e `general-purpose` em Haiku.
- Se tinha `ponytail`, o merge grava `"ponytail@ponytail": false`. Para remover de vez: `/plugin` → desinstalar, apagar `~/.config/ponytail/` e tirar `ponytail` de `extraKnownMarketplaces`.

### Passo 5 — Validar
Feche e abra o Claude Desktop → aba **Code** → nova sessão **Local**. Na primeira abertura os plugins oficiais são baixados. Se aparecer pedido para confiar em marketplace de terceiro, **recuse**.

| Comando | Esperado |
|---|---|
| `/status` | `Setting sources` inclui User settings; modelo Sonnet |
| `/advisor` | Advisor = Opus |
| `/plugin` | `context7` e `security-guidance` ativos; `claude-code-setup` desativado; nenhum de terceiro |
| `/agents` | os 6 agentes da seção 2.3 |
| "quais skills globais você tem?" | `env-guide` e `project-bootstrap` (as sob demanda não aparecem na lista) |

Plugin oficial que não baixou: `/plugin install <nome>@claude-plugins-official`.

---

## 6. Ativar em um projeto

### Pelo Claude (recomendado)
Abra uma sessão no projeto e peça:
- projeto existente: **"use a skill project-bootstrap no modo adopt-existing"**;
- projeto novo (criado em `C:\Workspace\<Nome>`, com `git init`): **"use a skill project-bootstrap no modo new-project"**.

O Claude detecta a stack, propõe as camadas e mostra o dry-run. Ele só grava depois da sua aprovação.

### Manual
```powershell
$proj = "C:\Workspace\<Projeto>"
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
```
Troque `_base,dotnet` pelas camadas da stack (tabela da seção 2.1).

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
# CLAUDE.md e settings.json do último backup do Passo 1:
$bk = (Get-ChildItem "$cl\backups" -Directory -Filter "setup-*" | Sort-Object Name | Select-Object -Last 1).FullName
Copy-Item "$bk\CLAUDE.md", "$bk\settings.json" $cl -Force
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
  - script que lê o arquivo por dentro (`node x.js`).
- **Falsos positivos:** `obj.key` em JavaScript e `.env.example` são bloqueados. Nesses casos, use `! <comando>`.
- **Se o hook falhar, ele não bloqueia.** Isso vale para JSON inválido, arquivo ausente, timeout de 10 s ou erro do PowerShell. O merge avisa quando o arquivo do hook não existe.
- **Regras `Read(**/...)` valem a partir da pasta da sessão.** As credenciais da pasta do usuário têm regras próprias `Read(~/...)`.
- **Regras `ask` por prefixo** (`Bash(curl:*)`) não pegam o comando no meio de um encadeamento, nem por outro nome ou caminho completo.
- **O código de `-Confirmar` não distingue você do agente.** A aprovação real é a confirmação que o hook pede na interface. Em modo que aprova tudo sozinho (`bypassPermissions`), essa confirmação pode não aparecer.
- **O agente pode editar `global\settings.merge.json` neste repositório** (é trabalho normal aqui). Os alertas do dry-run são a defesa.
- **Plugins oficiais seguem a versão mais recente.** O `marketingskills` (camada `marketing`) é fixado por tag, que o autor pode mover. A conferência por SHA está no `env-guide`.

---

## 10. Manutenção

- Alterou algo direto em `~\.claude\`? Copie de volta para `global\` e faça commit aqui.
- Plugin de terceiro novo ou atualizado: revisar origem, licença, hooks e dados coletados antes de ativar.
- Mudou plugin, camada ou projeto? Atualize o `env-guide` (fonte única), não o README.
- Fontes: [Advisor](https://code.claude.com/docs/en/advisor) · [Subagentes](https://code.claude.com/docs/en/sub-agents) · [Settings](https://code.claude.com/docs/en/settings) · [Modelos](https://code.claude.com/docs/en/model-config)

---

## 11. Pendências

- [ ] **Aplicar no perfil DEV** (hoje: `settings.json` sem `deny`/`ask` e com `Read(//c//**)`).
  **Atenção ao Passo 2:** o `~\.claude\CLAUDE.md` do DEV é o padrão MonitorContabil (~250 linhas: blueprint, `.memory`/history, deploy, Mongo/EF, firewall, operação remota). O Passo 2 o substitui inteiro. Parte já virou skill (`/blueprint`, `/deploy-checklist`, `/alterar-dados`). O restante (frontend, EF Core, túnel/operação remota, comunicação) precisa ir antes para o `CLAUDE.md` dos repos do MonitorContabil. O backup do Passo 1 é obrigatório.
- [ ] **Validar numa sessão real** depois de instalar (até agora testado só fora do harness: PowerShell 5.1, 88 casos do hook):
  1. `echo .env` pela ferramenta Bash e pela PowerShell → bloqueado (prova que o hook roda e que `$HOME` expande);
  2. `Read` de `~/.ssh/config` e de `~/.claude/.credentials.json` com a sessão aberta num projeto → negado;
  3. pedir ao Claude `merge-settings.ps1 -Confirmar x` → aparece a confirmação do hook;
  4. `curl.exe --version` → pede confirmação.
- [ ] Testar hook e scripts no PowerShell 7.
- [ ] Fixar `marketingskills` por SHA, se o schema de `extraKnownMarketplaces` aceitar.
- [ ] Migrar o contexto útil de `Memory\PlanoCarreiraDev.memory` para o `CLAUDE.md` do projeto.
- [ ] Avaliar o plugin Task Observer (origem, licença, hooks).
- [ ] Medir tokens/custo antes e depois do advisor (`/usage`).

Histórico (decisões de 2026-11-02, plugins removidos ou descartados, auditoria de vazamento de 2026-11-03): `PROPOSTA.md`.
