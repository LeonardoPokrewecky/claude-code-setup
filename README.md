# Ambiente Claude Code — Configuração Global (Leonardo)

Repositório versionado com toda a configuração do Claude Code (Desktop → aba **Code** → sessões **Local**, e também CLI):
`CLAUDE.md` global, settings com plugins de download automático, skills, agentes e modelos de projeto.

> Nada aqui é aplicado sozinho. Os arquivos ficam neste repositório até você seguir os passos abaixo.

---

## 1. O que tem aqui

```text
Skill e pluggin\
├── README.md                     ← este guia
├── Auditoria LGPD.pdf            ← documento-base da skill lgpd-audit
├── global\                       ← vai para %USERPROFILE%\.claude\
│   ├── CLAUDE.md                 ← instruções globais (curto, carregado em toda sessão)
│   ├── settings.merge.json       ← modelos, advisor, plugins, bloqueio de .env
│   ├── agents\                   ← 6 agentes (Explore, researcher, reviewer, test-validator, documentation, implementer)
│   ├── hooks\                    ← bloquear-segredos.ps1 (PreToolUse: segredo via Bash/PowerShell)
│   └── skills\                   ← env-guide, project-bootstrap, lgpd-audit, session-handoff + sob demanda (/revisar, /blueprint, /alterar-dados, /deploy-checklist, /medir-antes-depois, /divida…)
├── project-templates\            ← modelos para cada projeto
│   ├── CLAUDE.project.md         ← modelo de CLAUDE.md de projeto (com a linha "Documentação:")
│   ├── gitignore.claude          ← linhas de .gitignore para projetos: segredos + arquivos gerados pelas skills
│   ├── dotnet\.claude\settings.json          ← repos backend .NET
│   ├── angular\.claude\settings.json         ← repos frontend Angular
│   ├── _base, node-ts, python, infra, playwright, serena\.claude\settings.json  ← camadas (ver scripts\merge-settings.ps1 -Layers)
│   ├── supabase\.claude\settings.json
│   └── marketing\.claude\settings.json
└── scripts\
    ├── merge-settings.ps1        ← mescla settings (global ou -Layers por projeto) sem apagar; -DryRun; backup
    └── instalar-arquivos.ps1     ← copia agents/skills/hooks para ~\.claude com SHA-256, diff, -DryRun e backup
```

## 2. Decisões de arquitetura

| Tema | Decisão |
|---|---|
| Modelos | Sessão **Sonnet** + advisor **Opus** (consultado nas decisões) + subagentes **Haiku**. Equivale a `claude --advisor opus` com subagentes Haiku, só que permanente |
| Tarefa crítica | Trocar a sessão para Opus no seletor de modelo do Desktop |
| Memória | Auto Memory nativa + `CLAUDE.md` do projeto. `.memory` só para projetos **sem Git** |
| Git ao abrir projeto | `git fetch` + aviso (sem `pull` automático) |
| Plugins | Baixados automaticamente pelo `settings.json` (`extraKnownMarketplaces` + `enabledPlugins`) |
| Plugins de projeto | Ativados no `.claude\settings.json` de cada projeto, nunca no global |

### Plugins

| Plugin | Origem | Escopo | Status |
|---|---|---|---|
| claude-code-setup | oficial Anthropic | global | **desligado** (ligar só no bootstrap) |
| context7 | oficial Anthropic | global | ativo |
| security-guidance | oficial Anthropic | global | ativo |
| ponytail | DietrichGebert/ponytail | — | **removido** (2026-11-03): substituído por `/simplify`, `/code-review`, `/limpar-codigo`, `/revisar arquitetura` e `/divida` |
| csharp-lsp / typescript-lsp | oficial Anthropic | projeto | por stack |
| marketing-skills | coreyhaines31/marketingskills (MIT) | projeto (camada `marketing`, que registra o marketplace) | quando houver marketing |
| caveman | JuliusBrussee/caveman | — | **removido** (2026-11-03, sem uso) |
| supabase | oficial Anthropic | projeto | só se usar Supabase |
| Karpathy skills | multica-ai | — | **não instalado**: 4 princípios já estão no CLAUDE.md |
| anthropics/skills | Anthropic | — | **não instalado**: duplica skills já sincronizadas (docx, pdf, pptx, xlsx) |
| Claude-Mem | thedotmack | — | **descartado**: conflita com Auto Memory e envia conversas a terceiros |
| Headroom | headroom | — | **descartado**: proxy incompatível com Desktop e com o advisor |
| OmniRoute | diegosouzapw | — | **descartado**: troca o endpoint e quebra o advisor |
| Task Observer | rebelytics | — | **pendente**: origem não confirmada |

---

## 3. Pré-requisitos (verificar)

```powershell
git --version        # Git for Windows (obrigatório para a aba Code)
node --version       # Node 20+ (alguns plugins)
claude --version     # Claude Code 2.1.260+ (advisor no Desktop)
```

Para os LSPs (só se for ativar nos projetos):

```powershell
dotnet tool install --global csharp-ls
npm install -g typescript-language-server typescript
```

---

## 4. Instalação passo a passo

Abra o **PowerShell** (5.1 ou 7) **dentro da pasta clonada** deste repositório e defina as variáveis:

```powershell
$repo = (Resolve-Path .).Path            # pasta do claude-code-setup (confira: deve conter global\ e scripts\)
$cl   = "$env:USERPROFILE\.claude"
if (-not (Test-Path "$repo\scripts\merge-settings.ps1")) { throw "Rode dentro da pasta do claude-code-setup." }
```

**Como aprovar ou rejeitar.** Todo passo que grava em `~\.claude` mostra antes o que vai mudar. O CLAUDE.md mostra o diff; os scripts mostram a lista com SHA-256, o diff e os alertas, mais um código. Para aprovar, rode de novo com `-Confirmar <código>`. Para rejeitar, não rode nada, porque o dry-run não grava. Se o Claude rodar o `-Confirmar`, o hook pede sua aprovação na interface; recuse se não revisou o dry-run.

**Arquivos que a instalação altera:** `~\.claude\CLAUDE.md`, `~\.claude\settings.json` (com backup `settings.json.bak-AAAAMMDD-HHmmss`) e `~\.claude\agents|skills|hooks\*` (só os que vêm do pacote, com backup em `~\.claude\backups\instalar-*`). Nada mais é gravado.

### Passo 1 — Backup
```powershell
$bk = "$cl\backups\setup-$(Get-Date -Format yyyyMMdd-HHmm)"
New-Item -ItemType Directory -Force $bk | Out-Null
Copy-Item "$cl\CLAUDE.md", "$cl\settings.json" $bk
if (Test-Path "$cl\agents") { Copy-Item "$cl\agents" $bk -Recurse }
Write-Host "Backup em $bk"
```

### Passo 2 — CLAUDE.md global
Mostra o SHA-256 e o diff; só copie depois de conferir (o backup do Passo 1 guarda o atual):
```powershell
$src = "$repo\global\CLAUDE.md"; $dst = "$cl\CLAUDE.md"
(Get-FileHash $src).Hash; if (Test-Path $dst) { (Get-FileHash $dst).Hash; git diff --no-index -- $dst $src }
# conferido o diff acima:
Copy-Item $src $dst -Force
```

### Passo 3 — Agentes, skills e hooks
Mesmo fluxo de dois passos do settings. O dry-run lista cada arquivo como NOVO, ALTERADO ou IGUAL, com o SHA-256 de origem e de destino, e mostra o diff dos ALTERADOS. O `-Confirmar` copia NOVOS e ALTERADOS, guarda backup dos substituídos e confere cada cópia pelo SHA-256. Arquivo que só existe no destino não é tocado. O hook precisa estar em `~\.claude\hooks\` antes do Passo 4.
```powershell
powershell -ExecutionPolicy Bypass -File "$repo\scripts\instalar-arquivos.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "$repo\scripts\instalar-arquivos.ps1" -Confirmar <código>
```

### Passo 4 — Settings (modelos + plugins automáticos)
Mescla `global\settings.merge.json` no seu `settings.json`, preservando permissões e chaves existentes. Pode rodar mais de uma vez: sem mudança, nada é gravado e nenhum backup é criado.
Dois passos obrigatórios:
- O `-DryRun` mostra o JSON final, os **alertas** e um código. Valores com nome de segredo (token, key, password, auth…) aparecem como `***`. Toda entrada nova gera alerta, exceto `deny`, `ask`, plugin desligado e `$schema`. Também avisa se o hook aponta para um arquivo que não existe.
- Só grava com o código. Leia cada alerta antes de confirmar: um alerta inesperado é sinal de alteração indevida no pacote.
- Estrutura inválida (tipo errado em `permissions`, `env`, `hooks` ou `enabledPlugins`) é recusada antes de gravar.
```powershell
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -Confirmar <código>
```

### Passo 5 — Abrir o Claude Desktop e validar
1. Feche e abra o Claude Desktop → aba **Code** → nova sessão **Local** em qualquer pasta.
2. Na primeira abertura os plugins oficiais são baixados. O global não registra marketplace de terceiro; se pedir para confiar em algum, recuse (só `marketingskills`, e só em projeto com a camada `marketing`).
3. Rode na sessão:

| Comando | Esperado |
|---|---|
| `/status` | `Setting sources` inclui User settings; modelo Sonnet |
| `/advisor` | Advisor = Opus |
| `/plugin` | context7, security-guidance ativos; claude-code-setup desativado; nenhum plugin de terceiro |
| `/agents` | Explore, researcher-haiku, reviewer-haiku, test-validator-haiku, documentation-haiku, implementer-sonnet |
| "quais skills globais você tem?" | env-guide, project-bootstrap, lgpd-audit, session-handoff |

Se um plugin oficial não baixar sozinho, instale manualmente (ex.: `/plugin install context7@claude-plugins-official`).
Instalação antiga com `ponytail`: o merge grava `"ponytail@ponytail": false` (desliga o plugin). Para remover de vez: `/plugin` → desinstalar, apagar `~/.config/ponytail/` e tirar `ponytail` de `extraKnownMarketplaces` do `settings.json` (o merge só soma, não remove chaves).

### Limitações das proteções
O hook e as regras reduzem o risco, mas não fecham tudo. Use-os junto com a revisão do que você aprova.
- **O hook lê o texto do comando.** Não detecta nome montado em variável ou concatenação (`$a='.e'+'nv'; gc $a`), `cd` para a pasta seguido de caminho relativo (só o `cd` para `.claude` pede confirmação), curinga `*` sozinho (`cat *`), busca recursiva que lê o conteúdo de segredos sem citar o nome (`grep -r PASSWORD .`) nem script que lê o arquivo por dentro (`node x.js`, `python x.py`).
- **Falsos positivos conhecidos.** `obj.key` em código JavaScript e `.env.example` são bloqueados. Nesses casos, peça ao usuário para rodar com `! <comando>`.
- **Quando o hook falha, ele não bloqueia.** Isso vale para JSON inválido, arquivo ausente, timeout de 10 s ou erro do PowerShell. O merge avisa quando o arquivo do hook não existe.
- **Regras `Read(...)` com `**/` valem a partir do diretório da sessão.** As credenciais da pasta do usuário têm regras próprias `Read(~/...)`. A conferência em sessão real está nas Pendências.
- **Regras `ask` por prefixo** (`Bash(curl:*)`) não pegam o comando no meio de um encadeamento nem por outro nome (alias, caminho completo do executável).
- **O código de `-Confirmar` não distingue usuário de agente.** A aprovação real é a confirmação que o hook pede na interface. Em modo que aprova tudo sozinho (`bypassPermissions`), essa confirmação pode não aparecer.
- **O agente ainda pode editar `global\settings.merge.json` neste repositório** (é trabalho normal aqui). Os alertas do dry-run são a defesa: leia-os sempre.
- **Plugins oficiais seguem a versão mais recente**, e `marketingskills` está fixado por tag, que o autor pode mover (ver `env-guide`).

---

## 5. Ativar em um projeto

### Projeto existente (ex.: PlanoCarreiraDev — camadas `_base,dotnet`)
Abra uma sessão no projeto e peça: **"use a skill project-bootstrap no modo adopt-existing"**.
O Claude faz o inventário, mostra a proposta (com `-DryRun`) e só grava após sua aprovação.

Manual, se preferir:
```powershell
$proj = "C:\Workspace\PlanoCarreiraDev"
# ver antes (JSON, alertas e código):
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -Target "$proj\.claude\settings.json" -Layers _base,dotnet -DryRun
# aplicar com o código do dry-run (faz backup do settings existente):
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -Target "$proj\.claude\settings.json" -Layers _base,dotnet -Confirmar <código>
if (-not (Test-Path "$proj\CLAUDE.md")) { Copy-Item "$repo\project-templates\CLAUDE.project.md" "$proj\CLAUDE.md" }
# pasta de documentação fora do repo (blueprints, relatório LGPD, handoff):
New-Item -ItemType Directory -Force "$(Split-Path $proj)\docs\$(Split-Path $proj -Leaf)\backlog" | Out-Null
# .gitignore: ver as linhas que faltam e, conferidas, somar ao final (sem duplicar)
$gi = "$proj\.gitignore"; $atual = if (Test-Path $gi) { Get-Content $gi -Encoding UTF8 } else { @() }
$faltam = Get-Content "$repo\project-templates\gitignore.claude" -Encoding UTF8 | Where-Object { $_ -and $_ -notin $atual }
$faltam   # revisar antes de rodar as linhas abaixo
if ((Test-Path $gi) -and (Get-Content $gi -Raw) -notmatch '\n$') { Add-Content $gi -Value '' -Encoding utf8 }   # não grudar na última linha
Add-Content $gi -Value $faltam -Encoding utf8
```

Camadas: sempre `_base` + a(s) da stack. Tabela completa em `global\skills\env-guide\SKILL.md`.

| Stack | Camadas |
|---|---|
| Backend .NET | `_base,dotnet` |
| Frontend Angular | `_base,angular` |
| Node/TS (não Angular) | `_base,node-ts` |
| Python | `_base,python` |
| Só docker/terraform | `_base,infra` |
| Usa Supabase / marketing | somar `supabase` / `marketing` |
| Testar UI / navegação por símbolo (opt-in) | somar `playwright` / `serena` |

### Projeto novo
Crie em `C:\Workspace\<Nome>`, rode `git init` e peça: **"use a skill project-bootstrap no modo new-project"**.

### Projetos atuais
| Projeto | Git | Camadas | Observação |
|---|---|---|---|
| PlanoCarreiraDev | **não** | `_base,dotnet` | tem `CLAUDE.md` e `.claude\settings.json`; falta `_base`; usa `.memory` |
| PlanoCarreiraDev.Frontend | **não** | `_base,angular` | sem `CLAUDE.md` nem `.claude\` |

Projetos antigos (ZapVendedor, BuscadorContabil, DiscordTorLauncher, WAHA) foram removidos do uso em 2026-11-02.

---

## 6. Uso no dia a dia

| Situação | O que fazer |
|---|---|
| Tarefa comum | Sessão Sonnet; o advisor Opus entra sozinho nas decisões |
| Tarefa crítica (arquitetura, banco, segurança, LGPD) | Trocar a sessão para Opus no seletor |
| Planejar algo grande | Iniciar em **Plan mode** |
| Revisar código | `/revisar <estilo>` (seguranca, arquitetura, performance, testes, didatico, a11y, banco, deps); `/code-review`, `/security-review`; `/simplify` para simplificar o diff (aplica as correções) |
| Atalho adiado de propósito | `/divida registrar <atalho>`; `/divida listar` para ver e priorizar |
| Outras sob demanda | `/criar-testes`, `/explicar`, `/limpar-codigo`, `/preparar-pr`, `/adr`, `/plano-migracao`, `/postmortem` |
| Auditoria LGPD | `/lgpd-audit` |
| Continuar amanhã | `/session-handoff` |
| Desligar advisor | `/advisor off` |

---

## 7. Rollback

```powershell
$bk = (Get-ChildItem "$cl\backups" -Directory -Filter "setup-*" | Sort-Object Name | Select-Object -Last 1).FullName
Copy-Item "$bk\CLAUDE.md", "$bk\settings.json" $cl -Force
# Remover agentes e skills instalados por este setup:
'Explore','researcher-haiku','reviewer-haiku','test-validator-haiku','documentation-haiku','implementer-sonnet' |
  ForEach-Object { Remove-Item "$cl\agents\$_.md" -ErrorAction SilentlyContinue }
'env-guide','project-bootstrap','lgpd-audit','session-handoff','revisar','criar-testes','explicar','limpar-codigo',
'preparar-pr','adr','plano-migracao','postmortem','blueprint','alterar-dados','deploy-checklist','medir-antes-depois','divida' |
  ForEach-Object { Remove-Item "$cl\skills\$_" -Recurse -ErrorAction SilentlyContinue }
Remove-Item "$cl\hooks\bloquear-segredos.ps1" -ErrorAction SilentlyContinue   # e tirar o bloco "hooks" do settings.json
```
Plugins: `/plugin` → desinstalar, ou remover a entrada de `enabledPlugins`.
Backups automáticos dos scripts: `~\.claude\settings.json.bak-AAAAMMDD-HHmmss` (merge) e `~\.claude\backups\instalar-AAAAMMDD-HHmmss\` (arquivos substituídos). Para voltar, copie de volta o backup desejado.

---

## 8. Pendências

- [x] Limpar as permissões antigas do `settings.json` global (F1, 2026-11-02; backup em `~\.claude\backups\F1-*`).
- [x] Fixar versão (tag) dos marketplaces de terceiros (2026-11-03: ponytail v5.3.3, caveman v4.0.1, marketingskills v2.14.0).
- [ ] Aplicar este setup no perfil **DEV** (hoje: `settings.json` sem `deny`/`ask` e com `Read(//c//**)`); a F1 foi feita só no perfil Leonardo.
- [ ] Validar numa sessão real, depois de instalar (2026-11-03: testado só fora do harness, PowerShell 5.1, 88 casos do hook):
  1. o hook roda (`echo .env` pela ferramenta Bash e pela PowerShell → bloqueado; prova que `$HOME` expande);
  2. `Read` de `~/.ssh/config` e de `~/.claude/.credentials.json` com a sessão aberta num projeto → negado;
  3. `merge-settings.ps1 -Confirmar x` pedido ao Claude → aparece a confirmação do hook;
  4. `curl.exe --version` → pede confirmação.
- [ ] Testar hook e scripts no PowerShell 7 (não instalado nesta máquina em 2026-11-03).
- [ ] Fixar `marketingskills` por SHA, se o schema de `extraKnownMarketplaces` aceitar (não confirmado; exige rede).

## 8b. Auditoria de vazamento (2026-11-03)
Repo privado no GitHub. Sem caractere invisível/bidi, comentário HTML, URL estranha ou comando de rede/execução nos `.md`/`.json`/`.ps1`; histórico Git limpo; `Auditoria LGPD.pdf` sem JavaScript, ações ou anexos.
Plugins de terceiros (código baixado e lido, não executado): `ponytail` — hooks `node` em SessionStart/SubagentStart/UserPromptSubmit, lê transcrição, grava métricas locais, webhook só se configurado; `caveman` (desligado) — hooks `node`, sem rede; `marketing-skills` — só skills (recomenda ferramentas de parceiros), sem hooks/MCP. Nenhum trecho malicioso; o risco é de cadeia de suprimento (resolvido com `ref`).
- [x] `caveman` e `ponytail` removidos; global sem código de terceiro; `marketingskills` só na camada `marketing` (2026-11-03).
- [ ] Migrar contexto útil de `Memory\PlanoCarreiraDev.memory` para o `CLAUDE.md` do projeto, se ainda não estiver lá.
- [ ] Avaliar Task Observer (origem, licença, hooks).
- [ ] Medir tokens/custo antes e depois do advisor (`/usage`).

## 9. Manutenção

- Alterou algo em `~\.claude\`? Copie de volta para `global\` e faça commit aqui.
- Revisar plugins de terceiros a cada atualização: licença, hooks e dados coletados.
- Fontes: [Advisor](https://code.claude.com/docs/en/advisor) · [Subagentes](https://code.claude.com/docs/en/sub-agents) · [Settings](https://code.claude.com/docs/en/settings) · [Modelos](https://code.claude.com/docs/en/model-config)
