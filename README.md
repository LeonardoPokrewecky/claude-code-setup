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
│   └── skills\                   ← env-guide, project-bootstrap, lgpd-audit, session-handoff
├── project-templates\            ← modelos para cada projeto
│   ├── CLAUDE.project.md         ← modelo de CLAUDE.md de projeto
│   ├── dotnet\.claude\settings.json          ← repos backend .NET
│   ├── angular\.claude\settings.json         ← repos frontend Angular
│   ├── _base, node-ts, python, infra, playwright, serena\.claude\settings.json  ← camadas (ver scripts\merge-settings.ps1 -Layers)
│   ├── supabase\.claude\settings.json
│   └── marketing\.claude\settings.json
└── scripts\
    └── merge-settings.ps1        ← mescla settings (global ou -Layers por projeto) sem apagar; -DryRun; backup
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
| claude-code-setup | oficial Anthropic | global | ativo |
| context7 | oficial Anthropic | global | ativo |
| security-guidance | oficial Anthropic | global | ativo |
| ponytail | DietrichGebert/ponytail (MIT) | global | ativo |
| caveman | JuliusBrussee/caveman (Apache-2.0) | global | **desligado** (ligar com `/caveman`) |
| csharp-lsp / typescript-lsp | oficial Anthropic | projeto | por stack |
| marketing-skills | coreyhaines31/marketingskills (MIT) | projeto | quando houver marketing |
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

Abra o **PowerShell** e defina a pasta do repositório:

```powershell
$repo = "$env:USERPROFILE\Desktop\Skill e pluggin"
$cl   = "$env:USERPROFILE\.claude"
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
```powershell
Copy-Item "$repo\global\CLAUDE.md" "$cl\CLAUDE.md" -Force
```

### Passo 3 — Agentes e skills
Copia sem sobrescrever arquivos que já existam:
```powershell
foreach ($d in 'agents', 'skills') {
  Get-ChildItem "$repo\global\$d" -Recurse -File | ForEach-Object {
    $dest = $_.FullName.Replace("$repo\global", $cl)
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    if (-not (Test-Path $dest)) { Copy-Item $_.FullName $dest } else { Write-Host "Já existe: $dest" }
  }
}
```

### Passo 4 — Settings (modelos + plugins automáticos)
Mescla `global\settings.merge.json` no seu `settings.json`, preservando permissões e chaves existentes. Pode rodar mais de uma vez sem duplicar.
```powershell
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1"
```

### Passo 5 — Abrir o Claude Desktop e validar
1. Feche e abra o Claude Desktop → aba **Code** → nova sessão **Local** em qualquer pasta.
2. Na primeira abertura os plugins são baixados (pode pedir para confiar nos marketplaces de terceiros — aceite só ponytail, caveman e marketingskills).
3. Rode na sessão:

| Comando | Esperado |
|---|---|
| `/status` | `Setting sources` inclui User settings; modelo Sonnet |
| `/advisor` | Advisor = Opus |
| `/plugin` | claude-code-setup, context7, security-guidance, ponytail instalados; caveman desativado |
| `/agents` | Explore, researcher-haiku, reviewer-haiku, test-validator-haiku, documentation-haiku, implementer-sonnet |
| "quais skills globais você tem?" | env-guide, project-bootstrap, lgpd-audit, session-handoff |

Se um plugin não baixar sozinho, instale manualmente:
```text
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

---

## 5. Ativar em um projeto

### Projeto existente (ex.: PlanoCarreiraDev — camadas `_base,dotnet`)
Abra uma sessão no projeto e peça: **"use a skill project-bootstrap no modo adopt-existing"**.
O Claude faz o inventário, mostra a proposta (com `-DryRun`) e só grava após sua aprovação.

Manual, se preferir:
```powershell
$proj = "C:\Workspace\PlanoCarreiraDev"
# ver antes:
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -Target "$proj\.claude\settings.json" -Layers _base,dotnet -DryRun
# aplicar (faz backup do settings existente):
powershell -ExecutionPolicy Bypass -File "$repo\scripts\merge-settings.ps1" -Target "$proj\.claude\settings.json" -Layers _base,dotnet
if (-not (Test-Path "$proj\CLAUDE.md")) { Copy-Item "$repo\project-templates\CLAUDE.project.md" "$proj\CLAUDE.md" }
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
| Revisar código | `/revisar <estilo>` (seguranca, arquitetura, performance, testes, didatico, a11y, banco, deps); `/ponytail-review`, `/code-review`, `/security-review` |
| Outras sob demanda | `/criar-testes`, `/explicar`, `/limpar-codigo`, `/preparar-pr`, `/adr`, `/plano-migracao`, `/postmortem` |
| Auditoria LGPD | `/lgpd-audit` |
| Continuar amanhã | `/session-handoff` |
| Muitos logs/testes longos | `/caveman` para respostas curtas; `/caveman off` para voltar |
| Desligar advisor | `/advisor off` |

---

## 7. Rollback

```powershell
$bk = (Get-ChildItem "$cl\backups" -Directory -Filter "setup-*" | Sort-Object Name | Select-Object -Last 1).FullName
Copy-Item "$bk\CLAUDE.md", "$bk\settings.json" $cl -Force
# Remover agentes e skills instalados por este setup:
'Explore','researcher-haiku','reviewer-haiku','test-validator-haiku','documentation-haiku','implementer-sonnet' |
  ForEach-Object { Remove-Item "$cl\agents\$_.md" -ErrorAction SilentlyContinue }
'env-guide','project-bootstrap','lgpd-audit','session-handoff' |
  ForEach-Object { Remove-Item "$cl\skills\$_" -Recurse -ErrorAction SilentlyContinue }
```
Plugins: `/plugin` → desinstalar, ou remover a entrada de `enabledPlugins`.

---

## 8. Pendências

- [x] Limpar as permissões antigas do `settings.json` global (F1, 2026-11-02; backup em `~\.claudeackups\F1-*`).
- [ ] Fixar versão (commit/tag) dos marketplaces de terceiros.
- [ ] Confirmar que `"caveman@caveman": false` deixa o plugin instalado e inativo.
- [ ] Migrar contexto útil de `Memory\PlanoCarreiraDev.memory` para o `CLAUDE.md` do projeto, se ainda não estiver lá.
- [ ] Avaliar Task Observer (origem, licença, hooks).
- [ ] Medir tokens/custo antes e depois do caveman e do advisor (`/usage`).

## 9. Manutenção

- Alterou algo em `~\.claude\`? Copie de volta para `global\` e faça commit aqui.
- Revisar plugins de terceiros a cada atualização: licença, hooks e dados coletados.
- Fontes: [Advisor](https://code.claude.com/docs/en/advisor) · [Subagentes](https://code.claude.com/docs/en/sub-agents) · [Settings](https://code.claude.com/docs/en/settings) · [Modelos](https://code.claude.com/docs/en/model-config)
