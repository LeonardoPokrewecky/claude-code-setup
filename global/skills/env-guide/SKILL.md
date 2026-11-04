---
name: env-guide
description: Guia do ambiente Claude Code — quais plugins, skills e agentes existem, quando usar cada um e quais plugins ativar em cada projeto. Use ao iniciar/adotar projeto, ao decidir delegar a um agente, ou quando perguntarem "qual plugin/skill usar".
---

# Guia do ambiente

## Plugins (download automático via `settings.json`)
| Plugin | Escopo | Quando usar |
|---|---|---|
| `claude-code-setup` | Global, **desligado** | Só no bootstrap: ligar com `/plugin` para recomendar hooks, skills, MCPs e agentes; desligar depois |
| `context7` | Global | Antes de usar API de biblioteca/framework em que a versão importa |
| `security-guidance` | Global | Sempre ativo: avisos ao editar e revisão do diff no fim |
| `csharp-lsp` | Projeto | Repo com `*.csproj` / `*.sln` |
| `typescript-lsp` | Projeto | Repo com `angular.json` / `tsconfig.json` |
| `pyright-lsp` | Projeto | Repo Python (camada `python`) |
| `frontend-design` | Projeto | Repo Angular (camada `angular`): criar/refinar UI; respeitar o design system do projeto |
| `playwright` | Projeto (opt-in) | Testar UI no navegador; só a pedido |
| `serena` | Projeto (opt-in) | Navegação por símbolo; exige `uvx`; só a pedido |
| `marketing-skills` | Projeto (terceiro; marketplace só na camada `marketing`) | Landing page, copy, SEO, preço, CRO |
| `supabase` | Projeto | Só se o projeto usar Supabase; começar somente leitura em dev |

Regras:
- Plugin de projeto vai em `<repo>\.claude\settings.json` → `enabledPlugins`. Nunca no global.
- Modelos prontos: `project-templates\` do repositório `claude-code-setup` (caminho do clone local: linha "Clone do `claude-code-setup`" de `~/.claude/maquina.md`).
- Marketplaces de terceiros com versão fixada (`ref` = tag no `settings.json`). Tag pode ser movida pelo autor: antes de atualizar (ou ao reinstalar), conferir que o commit da tag é o mesmo auditado (`git ls-remote <repo> refs/tags/<tag>`) e revisar o diff da tag nova: hooks, MCP, chamadas de rede.
- Plugins oficiais (`claude-plugins-official`) seguem a versão mais recente: risco aceito. `context7` envia a consulta a um serviço externo (Upstash): nunca colocar código, dado ou segredo de cliente na consulta, só nome/versão da biblioteca e a dúvida. `supabase` acessa o banco (começar somente leitura em dev); `serena` baixa e roda código via `uvx`.
- Commit de referência da tag (obtido na API do GitHub em 2026-11-03): `marketingskills` `v2.14.0` = `5ffe077d2e59486d91c5ccaecbd74b6973c32308`. Antes de instalar: `git ls-remote https://github.com/coreyhaines31/marketingskills refs/tags/v2.14.0` deve devolver o mesmo SHA; diferente = tag movida, não instalar sem auditar de novo.
- **Global sem código de terceiro.** Único marketplace de terceiro: `marketingskills`, só na camada `marketing`. Removidos em 2026-11-03: `caveman` (sem uso) e `ponytail` (hooks `node` a cada prompt lendo a transcrição; substituído por `/simplify`, `/code-review`, `/limpar-codigo`, `/revisar arquitetura` e `/divida`). Instalação antiga com ponytail: o merge grava `ponytail@ponytail: false`; para remover de vez, desinstalar em `/plugin` e apagar `~/.config/ponytail/`.
- Hook global `bloquear-segredos.ps1` (PreToolUse Bash/PowerShell). Ignora aspas e escapes no meio do nome (`.e""nv`) e reconhece o nome colado a `:`, `>`, `&` e `,`.
  - **Bloqueia** comando que cite: `.env`, `.env.*`, `.envrc` e `*.env`; `appsettings.<Production|Prod|Staging|Homolog*|Local>.json` (o base e o `Development` ficam liberados: segredo de .NET vai em User Secrets ou variável de ambiente); `local.settings.json`; `*.pfx/.p12/.p8/.pem/.key/.jks/.keystore/.vault/.kdbx/.ppk`; `secrets/`, `*secrets*.json/.yaml`, `UserSecrets`; `.credentials.json`, `.git-credentials`, `.claude.json`; `id_rsa` e similares; `.ssh`, `.aws`, `.azure`, `.kube`, `.docker/config.json` e `.config/gh`; `.npmrc/.netrc/.pgpass/.pypirc`.
  - **Pede confirmação** para:
    - comando que cite `.claude/settings*`, `hooks`, `agents`, `skills`, `commands` ou `CLAUDE.md`, inclusive a escrita por redirecionamento, `Set-Content`, `Copy-Item` etc.;
    - `cd` para `.claude`;
    - `merge-settings`/`instalar-arquivos` com `-Confirmar`;
    - `-EncodedCommand` (e `/enc`), `FromBase64String`, `base64 -d` e `certutil -decode`;
    - `Net.WebClient`, `HttpClient` e `Send-MailMessage`;
    - despejo de variáveis de ambiente e `user-secrets list`;
    - `web.config`;
    - `git` que publica, usa a rede ou descarta trabalho (`push`, `commit`, `fetch`, `pull`, `clone`, `reset --hard`, `clean`, `restore`, `checkout --`, `stash drop`, `branch -D`), inclusive com `-C pasta` ou no meio de `&&`/`;`/`|`;
    - rede (`curl`, `ssh`, `Invoke-WebRequest`…) ou apagar/mover (`rm`, `del`, `mv`, `Remove-Item`…) no meio de um encadeamento;
    - curinga que alcance um nome de segredo;
    - qualquer falha interna do próprio hook (na dúvida, pergunta em vez de liberar).
  - Precisa de leitura legítima: o usuário roda com `! <comando>`. Limitações em README, "Limitações das proteções".
- Autoproteção: o `settings.json` global e `~/.claude/hooks/` têm `deny` de Edit/Write. O settings de projeto e `~/.claude/CLAUDE.md`, `skills/` e `agents/` têm `ask`. Pelo shell, o hook pede confirmação. Não é garantia absoluta: nome montado em variável escapa do hook. Mudar só pelo `scripts\merge-settings.ps1` e pelo `scripts\instalar-arquivos.ps1`, rodados pelo usuário ou aprovados na confirmação do hook.
- Plugin fora desta lista: revisar origem, licença, hooks e dados coletados e pedir aprovação.
- **Descartados**: Claude-Mem (conflita com Auto Memory e envia dados a terceiros), Headroom (proxy incompatível com Desktop/advisor), OmniRoute (troca o endpoint e quebra o advisor), anthropics/skills (duplica skills já sincronizadas). **Pendente**: Task Observer.

## Documentos gerados pelas skills
Pasta de documentação = `Documentação:` do `CLAUDE.md` do projeto; sem indicação, `<pasta-pai-do-repo>\docs\<nome-do-repo>\` (**fora do repositório**).
| Arquivo | Skill | Onde | Por quê |
|---|---|---|---|
| `backlog\*.md` | `/blueprint` | pasta de documentação | causa raiz e falhas antes da correção |
| `RELATORIO-LGPD.md` | `/lgpd-audit` | pasta de documentação | mapa de dados pessoais e falhas abertas |
| `HANDOFF.md` | `/session-handoff` | pasta de documentação | estado de trabalho (projeto sem Git: `.memory`) |
| `DIVIDA.md` | `/divida` | raiz do projeto, versionado | sem segredo; útil para a equipe |

Defesa extra: `project-templates\gitignore.claude` (segredos + gerados) somado ao `.gitignore` do projeto pelo `/project-bootstrap`.

## Camadas de projeto (`project-templates\`)
Aplicadas por `scripts\merge-settings.ps1 -Target <repo>\.claude\settings.json -Layers a,b` (união sem apagar; `-DryRun` mostra o resultado, os alertas e um código; gravar só com `-Confirmar <código>`; faz backup). Cada repo = `_base` + stack + opcionais.

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

Repo sem Git: a defesa é o `deny` da `_base` + `<pasta de memória>\<Projeto>.memory`.

## Configuração por máquina
Pasta de projetos, pasta de memória, caminho do clone deste pacote e a tabela de **projetos atuais** ficam em `~/.claude/maquina.md` (modelo: `global\maquina.example.md`; importado pelo `CLAUDE.md` global). Nada pessoal ou de cliente entra no pacote.

## Skills globais (invocadas automaticamente pelo modelo)
| Skill | Quando usar |
|---|---|
| `project-bootstrap` | Projeto novo ou adoção de projeto existente |
| `env-guide` | Este guia |
| `arquitetura-onion` | Backend .NET: camadas, regra de dependência, convenções e fatia vertical de funcionalidade nova |
| `security-review` (embutida) | Revisão de segurança das mudanças pendentes |
| `code-review` (embutida) | Revisão de bugs no diff |
| `simplify` (embutida) | Reuso, simplificação e eficiência do código alterado (aplica as correções: rodar só com diff revisável) |

## Skills sob demanda (`disable-model-invocation: true`: instaladas, custo fixo ~zero, só rodam quando você digita `/nome`)
| Comando | Para quê |
|---|---|
| `/revisar <estilo> [alvo]` | Revisão somente leitura, uma lente: `seguranca`, `arquitetura`, `performance`, `testes`, `didatico`, `a11y`, `banco`, `deps`, `contrato`; alvo pode ser `branch:<nome>` (worktree isolada) |
| `/blueprint <atividade>` | Documento em `<docs>\backlog\`, fora do repositório (blueprint, checklist, 5+ use cases, resultado) antes de implementar |
| `/alterar-dados <o quê>` | Update em massa/backfill com backup, dry-run, idempotência e regra canário |
| `/deploy-checklist <componente>` | Antes/durante/depois do deploy com auditoria (systemd, NGINX, SHA-256, HTTP 200) |
| `/divida registrar <atalho>` / `/divida listar` | Dívida técnica adiada de propósito em `DIVIDA.md` (arquivo:linha, motivo, risco, gatilho) |
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
| `researcher-haiku` | haiku | Pesquisa em docs/web, somente leitura (código: `Explore`) |
| `reviewer-haiku` | haiku | Checagem de diff contra padrões e riscos óbvios |
| `test-validator-haiku` | haiku | Rodar build/testes autorizados e resumir falhas |
| `documentation-haiku` | haiku | README, docs, resumos — só `.md`, nunca código |
| `implementer-sonnet` | sonnet | Implementação delegada, escopo fechado, só em paralelo ou com muito ruído |
