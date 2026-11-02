---
name: env-guide
description: Guia do ambiente Claude Code do Leonardo — quais plugins, skills e agentes existem, quando usar cada um e quais plugins ativar em cada projeto. Use ao iniciar/adotar projeto, ao decidir delegar a um agente, ou quando perguntarem "qual plugin/skill usar".
---

# Guia do ambiente

## Plugins (download automático via `settings.json`)
| Plugin | Escopo | Quando usar |
|---|---|---|
| `claude-code-setup` | Global | Projeto novo/adotado: recomendar hooks, skills, MCPs e agentes |
| `ponytail` | Global | Sempre ativo. `/ponytail-review` no diff, `/ponytail-audit` no repo, `/ponytail-debt` para atalhos adiados |
| `context7` | Global | Antes de usar API de biblioteca/framework em que a versão importa |
| `security-guidance` | Global | Sempre ativo: avisos ao editar e revisão do diff no fim |
| `caveman` | Global, **desligado** | Só a pedido do usuário, em sessões longas de logs/testes |
| `csharp-lsp` | Projeto | Repo com `*.csproj` / `*.sln` |
| `typescript-lsp` | Projeto | Repo com `angular.json` / `tsconfig.json` |
| `marketing-skills` | Projeto | Landing page, copy, SEO, preço, CRO |
| `supabase` | Projeto | Só se o projeto usar Supabase; começar somente leitura em dev |

Regras:
- Plugin de projeto vai em `<repo>\.claude\settings.json` → `enabledPlugins`. Nunca no global.
- Modelos prontos: `project-templates\` do repositório de configuração (`C:\Users\Leonardo\Desktop\Skill e pluggin`).
- Plugin fora desta lista: revisar origem, licença, hooks e dados coletados e pedir aprovação.
- **Descartados**: Claude-Mem (conflita com Auto Memory e envia dados a terceiros), Headroom (proxy incompatível com Desktop/advisor), OmniRoute (troca o endpoint e quebra o advisor), anthropics/skills (duplica skills já sincronizadas). **Pendente**: Task Observer.

## Projetos atuais
| Projeto | Stack | Plugins de projeto |
|---|---|---|
| ZapVendedor (backend, frontend, admin) | .NET + Angular | `csharp-lsp`, `typescript-lsp` |
| Buscador Contabil (backend, frontend) | .NET + Angular | `csharp-lsp`, `typescript-lsp` |
| DiscordTorLauncher | .NET (sem Git) | `csharp-lsp` |
| WAHA | docker-compose (sem Git) | nenhum |

## Skills globais
| Skill | Quando usar |
|---|---|
| `project-bootstrap` | Projeto novo ou adoção de projeto existente |
| `lgpd-audit` | Auditoria LGPD somente leitura de um app |
| `session-handoff` | Tarefa que vai continuar em outra sessão |
| `env-guide` | Este guia |
| `security-review` (embutida) | Revisão de segurança das mudanças pendentes |
| `code-review` (embutida) | Revisão de bugs no diff |

## Agentes globais
| Agente | Modelo | Uso |
|---|---|---|
| `Explore` | haiku | Busca ampla no código (substitui o Explore embutido) |
| `researcher-haiku` | haiku | Pesquisa em docs/web e no código, somente leitura |
| `reviewer-haiku` | haiku | Checagem de diff contra padrões e riscos óbvios |
| `test-validator-haiku` | haiku | Rodar build/testes autorizados e resumir falhas |
| `documentation-haiku` | haiku | README, docs, resumos |
| `implementer-sonnet` | sonnet | Implementação delegada, escopo fechado |
