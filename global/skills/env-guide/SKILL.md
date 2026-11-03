---
name: env-guide
description: Guia do ambiente Claude Code do Leonardo — quais plugins, skills e agentes existem, quando usar cada um e quais plugins ativar em cada projeto. Use ao iniciar/adotar projeto, ao decidir delegar a um agente, ou quando perguntarem "qual plugin/skill usar".
---

# Guia do ambiente

## Plugins (download automático via `settings.json`)
| Plugin | Escopo | Quando usar |
|---|---|---|
| `claude-code-setup` | Global, **desligado** | Só no bootstrap: ligar com `/plugin` para recomendar hooks, skills, MCPs e agentes; desligar depois |
| `ponytail` | Global | Sempre ativo. `/ponytail-review` no diff, `/ponytail-audit` no repo, `/ponytail-debt` para atalhos adiados |
| `context7` | Global | Antes de usar API de biblioteca/framework em que a versão importa |
| `security-guidance` | Global | Sempre ativo: avisos ao editar e revisão do diff no fim |
| `caveman` | Global, **desligado** | Só a pedido do usuário, em sessões longas de logs/testes |
| `csharp-lsp` | Projeto | Repo com `*.csproj` / `*.sln` |
| `typescript-lsp` | Projeto | Repo com `angular.json` / `tsconfig.json` |
| `frontend-design` | Projeto | Repo Angular (camada `angular`): criar/refinar UI; respeitar o design system do projeto |
| `marketing-skills` | Projeto | Landing page, copy, SEO, preço, CRO |
| `supabase` | Projeto | Só se o projeto usar Supabase; começar somente leitura em dev |

Regras:
- Plugin de projeto vai em `<repo>\.claude\settings.json` → `enabledPlugins`. Nunca no global.
- Modelos prontos: `project-templates\` do repositório `claude-code-setup` (perfil DEV: `C:\workspace\Clade md\claude-code-setup`; perfil Leonardo: `C:\Users\Leonardo\Desktop\Skill e pluggin`).
- Marketplaces de terceiros com versão fixada (`ref` = tag no `settings.json`). Atualizar só depois de revisar o diff da tag nova: hooks, MCP, chamadas de rede.
- `ponytail` (auditado em 2026-11-03, v5.3.3): roda `node` a cada prompt e lê a transcrição para métricas; sem rede por padrão. O "Task board" grava custo e o **nome/1º prompt** de cada tarefa em `~/.config/ponytail/band/`: desligar em `/plugin` → ponytail → configurar se os prompts tiverem dado de cliente. Nunca preencher `webhookUrl`.
- Hook global `bloquear-segredos.ps1` (PreToolUse Bash/PowerShell): bloqueia comando que cite `.env`, `appsettings.<Ambiente>.json`, `*.pfx/.pem/.key/.vault`, `secrets/`, `*secrets*.json`, `.credentials.json`, `.ssh/`. Precisa de leitura legítima: o usuário roda com `! <comando>`.
- Plugin fora desta lista: revisar origem, licença, hooks e dados coletados e pedir aprovação.
- **Descartados**: Claude-Mem (conflita com Auto Memory e envia dados a terceiros), Headroom (proxy incompatível com Desktop/advisor), OmniRoute (troca o endpoint e quebra o advisor), anthropics/skills (duplica skills já sincronizadas). **Pendente**: Task Observer.

## Camadas de projeto (`project-templates\`)
Aplicadas por `scripts\merge-settings.ps1 -Target <repo>\.claude\settings.json -Layers a,b` (união sem apagar; `-DryRun` mostra antes; faz backup). Cada repo = `_base` + stack + opcionais.

| Camada | Plugins / efeito | Detecção |
|---|---|---|
| `_base` | `deny` de `node_modules`, `dist`, `.angular`, `bin`, `obj`, `.vs`, lockfile, `*.min.js` | todo projeto |
| `dotnet` | `csharp-lsp` | `*.sln` / `*.csproj` |
| `angular` | `typescript-lsp`, `frontend-design` | `angular.json` |
| `node-ts` | `typescript-lsp` | `package.json` sem `angular.json` |
| `python` | `pyright-lsp`, `deny` de `.venv`/`__pycache__` | `pyproject.toml` / `requirements.txt` |
| `infra` | `deny` de `.tfstate`/`.tfvars`/`.terraform` | só `docker-compose*.yml` / `*.tf` |
| `supabase` | `supabase` | usa Supabase |
| `marketing` | `marketing-skills` | landing page, copy, SEO |
| `playwright` (opt-in) | `playwright`: testar UI no navegador | só a pedido; medir tokens |
| `serena` (opt-in) | `serena`: navegação por símbolo; exige `uvx` | só a pedido; medir tokens |

Repo sem Git: a defesa é o `deny` da `_base` + `C:\Workspace\Memory\<Projeto>.memory`.

## Projetos atuais (em `C:\Workspace`)
| Projeto | Stack | Camadas | Situação |
|---|---|---|---|
| PlanoCarreiraDev | .NET 8 + MongoDB (sem Git) | `_base`, `dotnet` | `CLAUDE.md` + `.claude\settings.json` com `_base`+`dotnet` aplicados; usa `.memory` |
| PlanoCarreiraDev.Frontend | Angular (sem Git) | `_base`, `angular` | `CLAUDE.md` + `.claude\settings.json` com `_base`+`angular` aplicados; sem `.memory` |
| LeonardoPokrewecky | README de perfil (Git) | nenhuma | — |

## Skills globais
| Skill | Quando usar |
|---|---|
| `project-bootstrap` | Projeto novo ou adoção de projeto existente |
| `lgpd-audit` | Auditoria LGPD somente leitura de um app |
| `session-handoff` | Tarefa que vai continuar em outra sessão |
| `env-guide` | Este guia |
| `security-review` (embutida) | Revisão de segurança das mudanças pendentes |
| `code-review` (embutida) | Revisão de bugs no diff |

## Skills sob demanda (`disable-model-invocation: true`: instaladas, custo fixo ~zero, só rodam quando você digita `/nome`)
| Comando | Para quê |
|---|---|
| `/revisar <estilo> [alvo]` | Revisão somente leitura, uma lente: `seguranca`, `arquitetura`, `performance`, `testes`, `didatico`, `a11y`, `banco`, `deps`, `contrato`; alvo pode ser `branch:<nome>` (worktree isolada) |
| `/blueprint <atividade>` | Documento em `backlog/` (blueprint, checklist, 5+ use cases, resultado) antes de implementar |
| `/alterar-dados <o quê>` | Update em massa/backfill com backup, dry-run, idempotência e regra canário |
| `/deploy-checklist <componente>` | Antes/durante/depois do deploy com auditoria (systemd, NGINX, SHA-256, HTTP 200) |
| `/medir-antes-depois <achado>` | Prova ou refuta uma correção medindo base × corrigido com o mesmo script |
| `/criar-testes <alvo>` | Gera só arquivos de teste novos, no padrão do projeto |
| `/explicar [tema]` | Mapa de módulo/fluxo para onboarding (só leitura) |
| `/limpar-codigo [caminho]` | Relatório de código morto/duplicado (só relatório) |
| `/preparar-pr [base]` | Texto do PR a partir do diff; não faz commit/push |
| `/adr <decisão>` | Registra decisão na seção Decisões do `CLAUDE.md` |
| `/plano-migracao <tec> [versão]` | Plano de upgrade com riscos e rollback (só leitura) |
| `/postmortem <incidente>` | Linha do tempo, causa raiz e ações |
| `/lgpd-audit`, `/session-handoff` | Auditoria LGPD; handoff para outra sessão |

## Agentes globais
| Agente | Modelo | Uso |
|---|---|---|
| `Explore` | haiku | Busca ampla no código (substitui o Explore embutido) |
| `researcher-haiku` | haiku | Pesquisa em docs/web e no código, somente leitura |
| `reviewer-haiku` | haiku | Checagem de diff contra padrões e riscos óbvios |
| `test-validator-haiku` | haiku | Rodar build/testes autorizados e resumir falhas |
| `documentation-haiku` | haiku | README, docs, resumos |
| `implementer-sonnet` | sonnet | Implementação delegada, escopo fechado |
