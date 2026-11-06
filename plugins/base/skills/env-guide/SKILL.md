---
name: env-guide
description: Guia do ambiente Claude Code deste pacote — quais plugins, skills, agentes e camadas de projeto existem, quando usar cada um e o que ativar em cada projeto. Use ao iniciar/adotar projeto, ao decidir delegar a um agente, ou quando perguntarem "qual plugin/skill usar".
---

# Guia do ambiente

Inventário completo (gerado dos próprios arquivos, não editar à mão): [componentes.md](componentes.md).
Clone local do pacote: linha "Clone do `claude-code-setup`" de `~/.claude/maquina.md` (de onde vêm `project-templates/`, `profiles/` e `scripts/`).

## Onde cada coisa vive
| Peça | Onde | Como chega |
|---|---|---|
| CLAUDE.md global, agente `Explore` (Haiku) | `core/` | `scripts/instalar-arquivos.ps1` (plugin não sobrescreve o `Explore` embutido) |
| Permissões, modelo, advisor, marketplace | `core/settings.merge.json` | `scripts/merge-settings.ps1` (plugin não carrega permissões nem sandbox) |
| Sandbox (macOS, Linux, WSL2) | `profiles/unix/` | `merge-settings.ps1 -Perfil unix`. Windows nativo: sem sandbox (doc oficial) → WSL2 ou camada `devcontainer` |
| Skills, agentes, hook de segredos | plugin `base@kit-dev-ia` | `/plugin install base@kit-dev-ia` (ligado em todo projeto) |
| `arquitetura-onion` | plugin `dotnet@kit-dev-ia` | desligado por padrão; a camada `dotnet` liga no projeto |
| Regras por caminho (`.claude/rules/`), settings de projeto | `project-templates/<camada>/` | skill `project-bootstrap` ou `merge-settings.ps1 -Layers` |

## Quando usar
- Projeto sem `CLAUDE.md` → `project-bootstrap`. Camadas: sempre `_base` + as da stack (ver componentes.md); opcionais (`supabase`, `marketing`, `playwright`, `serena`, `devcontainer`) só a pedido.
- Planejar algo grande → Plan mode + `/blueprint` (requisitos não funcionais incluídos).
- Revisar → `/revisar` (escolhe as lentes pelo risco do diff) ou `/revisar <lente>`; `/code-review` e `/security-review` embutidos para o diff completo.
- Dados em massa → `/alterar-dados`; deploy → `/deploy-checklist`; LGPD do app → `/lgpd-audit`.
- Delegar: leitura ampla → `Explore`; pesquisa web → `researcher-haiku`; rodar testes → `test-validator-haiku`; só `.md` → `documentation-haiku`; implementação paralela → `implementer-sonnet`; uma lente de revisão → `revisor` (modelo da sessão; segurança/LGPD/arquitetura nunca em Haiku).
- Agentes embutidos `Plan` e `general-purpose` herdam o modelo da sessão.

## Detecção de camadas (projeto-bootstrap)
| Camada | Quando |
|---|---|
| `_base` | todo projeto |
| `dotnet` | `*.sln` / `*.csproj` |
| `angular` | `angular.json` |
| `node-ts` | `package.json` sem `angular.json` |
| `python` | `pyproject.toml` / `requirements.txt` |
| `infra` | só `docker-compose*.yml` / `*.tf` |
| `supabase` | o projeto usa Supabase |
| `marketing` | landing page, copy, SEO |
| `playwright`, `serena`, `devcontainer` | só a pedido |

## Plugins oficiais e de terceiros
| Plugin | Escopo | Quando usar |
|---|---|---|
| `context7` | Global | API de biblioteca em que a versão importa. Envia a consulta à Upstash: só nome/versão e a dúvida, nunca código ou dado de cliente |
| `security-guidance` | Global | Sempre ativo: avisos ao editar e revisão do diff |
| `claude-code-setup` | Global, desligado | Ligar com `/plugin` só para pedir sugestões de automação; desligar depois |
| `csharp-lsp`, `typescript-lsp`, `pyright-lsp`, `frontend-design` | Projeto (camadas) | Ver componentes.md |
| `playwright`, `serena` | Projeto, opt-in | Só a pedido; medir tokens. `serena` baixa e roda código via `uvx` |
| `supabase` | Projeto | Só se o projeto usar Supabase; começar somente leitura em dev |
| `marketing-skills` (terceiro) | Projeto (camada `marketing`) | Tag `v2.14.0` = `5ffe077d2e59486d91c5ccaecbd74b6973c32308` (2026-11-03). Antes de instalar: `git ls-remote https://github.com/coreyhaines31/marketingskills refs/tags/v2.14.0` deve devolver o mesmo SHA |

Regras: plugin de projeto vai em `<repo>/.claude/settings.json`, nunca no global. Plugins oficiais (`claude-plugins-official`) seguem a versão mais recente: risco aceito. Repo sem Git: a defesa é o `deny` da camada `_base` + `<pasta de memória>/<Projeto>.memory`. Plugin fora desta lista: revisar origem, licença, hooks e dados coletados e pedir aprovação. Global sem código de terceiro.
Descartados: Claude-Mem (conflita com Auto Memory e envia dados a terceiros), Headroom e OmniRoute (trocam o endpoint e quebram o advisor), anthropics/skills (duplica skills), `caveman` e `ponytail` (removidos em 2026-11-03; ponytail rodava hooks a cada prompt lendo a transcrição). Pendente: Task Observer.

## Proteções (resumo; detalhes e limitações no README do pacote)
- Permissões por classe de operação em `core/settings.merge.json`: build/teste liberados; Git que publica/descarta, instalação, rede, destrutivas e interpretadores com código inline pedem confirmação; leitura de segredos negada.
- Hook `bloquear-segredos` (plugin `base`): bloqueia comando de shell que cita arquivo de segredo e pede confirmação para o que mexe na configuração do Claude Code, esconde o comando (base64) ou usa `git -C`/`-c`. É camada contra acidente, não fronteira. Leitura legítima: o usuário roda com `! <comando>`.
- Autoproteção: `deny` de edição em `~/.claude/settings*.json`, `~/.claude/hooks/` e `~/.claude/plugins/`; `ask` em CLAUDE.md, skills e agentes do usuário.

## Documentos gerados pelas skills
Pasta de documentação = `Documentação:` do CLAUDE.md do projeto; sem indicação, `<pasta-pai-do-repo>/docs/<nome-do-repo>/` (**fora do repositório**): `backlog/*.md` (`/blueprint`), `RELATORIO-LGPD.md` (`/lgpd-audit`), `HANDOFF.md` (`/session-handoff`). Exceção: `DIVIDA.md` (`/divida`) fica versionado na raiz do projeto.

## Configuração por máquina
Pastas, clone do pacote e tabela de projetos atuais ficam em `~/.claude/maquina.md` (modelo `core/maquina.example.md`). Nada pessoal ou de cliente entra no pacote.
