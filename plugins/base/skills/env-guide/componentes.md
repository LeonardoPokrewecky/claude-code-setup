# Componentes do pacote (gerado)

> Gerado por `scripts/gerar-docs.ps1` a partir dos arquivos do repositório. Não editar à mão.

## Plugins (marketplace `kit-dev-ia`)

| Plugin | Ligado por padrão | Descrição |
|---|---|---|
| `base` | sim | Hook de segredos, revisão por lentes, planejamento, alteração de dados, deploy, LGPD e agentes. |
| `dotnet` | não (ligar por projeto) | Arquitetura onion para backend .NET. Ligado por projeto (camada dotnet). |
| `angular` | não (ligar por projeto) | Arquitetura de frontend Angular. Ligado por projeto (camada angular). |

### Plugin `base`

| Skill | Invocação | Descrição |
|---|---|---|
| `adr` | só `/adr` | Registra uma decisão técnica na seção "Decisões" do CLAUDE.md do projeto (contexto, escolha, alternativas, motivo). Só roda com /adr <decisão>. |
| `alterar-dados` | só `/alterar-dados` | Planeja e executa alteração de dados em banco (update em massa, backfill, correção de legado, varredura multi-tenant) com backup, dry-run e regra canário. Só roda com /alterar-dados <o que mudar e onde>. |
| `blueprint` | só `/blueprint` | Planejamento antes de implementar — cria o blueprint da atividade (decisões, checklist, use cases, requisitos não funcionais, resultado) em backlog/ na pasta de documentação fora do repositório. Só roda com /blueprint <descrição da atividade>. |
| `criar-testes` | só `/criar-testes` | Gera testes para código sem cobertura, seguindo o framework e o padrão do projeto, só nos arquivos indicados. Só roda com /criar-testes <arquivo ou classe>. |
| `deploy-checklist` | só `/deploy-checklist` | Checklist de deploy (antes, durante e depois) para APIs, frontends e workers em servidor Linux com systemd/NGINX (validado) ou Windows Server/IIS (não validado em projeto real), com auditoria pós-deploy. Só roda com /deploy-checklist <componente> [ambiente]. |
| `divida` | só `/divida` | Registra e lista dívida técnica (atalhos adiados de propósito) em DIVIDA.md do projeto, com arquivo:linha, motivo, risco e gatilho para pagar. Só roda com /divida registrar <descrição> ou /divida listar. |
| `env-guide` | automática + `/env-guide` | Guia do ambiente Claude Code deste pacote — quais plugins, skills, agentes e camadas de projeto existem, quando usar cada um e o que ativar em cada projeto. Use ao iniciar/adotar projeto, ao decidir delegar a um agente, ou quando perguntarem "qual plugin/skill usar". |
| `explicar` | só `/explicar` | Mapa de um módulo, fluxo ou projeto para onboarding (somente leitura, com caminho:linha). Só roda com /explicar <módulo, fluxo ou pasta>. |
| `lgpd-audit` | só `/lgpd-audit` | Auditoria LGPD completa e somente leitura de um app (web/mobile/API) — pesquisa a legislação vigente, mapeia dados pessoais, avalia 11 áreas, prioriza P0–P3 e gera RELATORIO-LGPD.md (fora do repositório) em linguagem simples. Só roda com /lgpd-audit. |
| `limpar-codigo` | só `/limpar-codigo` | Relatório de código morto, duplicado, imports/variáveis sem uso e simplificações possíveis (somente relatório). Só roda com /limpar-codigo [caminho]. |
| `medir-antes-depois` | só `/medir-antes-depois` | Mede o comportamento ANTES e DEPOIS de uma correção, no mesmo ambiente e com o mesmo script, para provar ou refutar que a mudança resolve algo real. Só roda com /medir-antes-depois <achado ou correção>. |
| `plano-migracao` | só `/plano-migracao` | Plano de upgrade de versão (ex.: .NET, Angular, pacote) com riscos, passos e rollback, somente leitura. Só roda com /plano-migracao <o quê> [versão alvo]. |
| `postmortem` | só `/postmortem` | Monta o post-mortem de um incidente ou bug sério (linha do tempo, causa raiz, impacto, ações). Só roda com /postmortem <descrição ou logs>. |
| `preparar-pr` | só `/preparar-pr` | Prepara o texto do PR a partir do diff (resumo, motivo, riscos, como testar, checklist). Não faz commit nem push. Só roda com /preparar-pr [branch base]. |
| `project-bootstrap` | automática + `/project-bootstrap` | Prepara um projeto para o ambiente Claude Code — modo new-project (projeto novo) ou adopt-existing (projeto existente). Cria/mescla CLAUDE.md e .claude/settings.json do projeto de forma conservadora e idempotente. Use quando o projeto não tiver CLAUDE.md ou o usuário pedir para preparar/adotar um projeto. |
| `revisar` | só `/revisar` | Revisão somente leitura por lentes (seguranca, lgpd, arquitetura, qualidade, performance, testes, contrato, banco, deps, a11y, didatico). Sem lente, escolhe as lentes pelo risco do diff. Alvo: diff, caminho ou branch. Modo PR (pr <número\|branch>) checa CI e conflito e dá veredito. Só roda com /revisar [lente\|auto\|pr] [alvo]. |
| `session-handoff` | só `/session-handoff` | Gera um resumo de passagem de bastão quando uma tarefa vai continuar em outra sessão — objetivo, estado, decisões, arquivos, testes e próximos passos. Só roda com /session-handoff. |

| Agente | Modelo | Ferramentas | Descrição |
|---|---|---|---|
| `documentation-haiku` | `haiku` | Read, Grep, Glob, Write, Edit | Escreve ou atualiza arquivos de documentação .md (README, docs, resumos) a partir do código existente. Use quando a tarefa for só documentação em .md; comentários dentro do código não são com este agente. |
| `implementer-sonnet` | `sonnet` | Read, Grep, Glob, Edit, Write, Bash, PowerShell | Implementa uma mudança de código bem delimitada (arquivos e critério de aceite definidos pelo chamador). Use só para trabalho independente em paralelo, ou quando a implementação geraria muito ruído no contexto principal; mudança simples a sessão faz direto. Não para decisões de arquitetura. |
| `researcher-haiku` | `haiku` | Read, Grep, Glob, WebFetch, WebSearch | Pesquisa somente leitura em documentação e web para responder perguntas factuais ou levantar opções. Use para pesquisa de bibliotecas, APIs e versões antes de decidir algo. Busca no código do projeto é com o Explore. |
| `revisor` | `inherit` | Read, Grep, Glob, Bash | Revisão somente leitura de um diff ou caminho com UMA lente (segurança, LGPD, arquitetura, qualidade, testes, contrato, banco, performance). Use quando a skill /revisar delegar uma lente, ou após implementar algo não trivial. O chamador informa o alvo e o arquivo da lente. |
| `test-validator-haiku` | `haiku` | Read, Grep, Glob, Bash | Executa build e testes já existentes e autorizados (ex. dotnet build/test, npm run build/test) e resume o resultado. Use para validar uma mudança. |

Hook: `PreToolUse` (matcher `Bash|PowerShell`) → `if command -v pwsh >/dev/null 2>&1; then exec pwsh -NoProfile -NonInteractive -File "${CLAUDE_PLUGIN_ROOT}/hooks/bloquear-segredos.ps1"; elif command -v powershell >/dev/null 2>&1; then exec powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/hooks/bloquear-segredos.ps1"; else sh "${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.sh"; fi`

### Plugin `dotnet`

| Skill | Invocação | Descrição |
|---|---|---|
| `arquitetura-onion` | automática + `/arquitetura-onion` | Padrão de arquitetura onion para backend .NET — projetos por camada (começa enxuto, separa por demanda), regra de dependência testada, convenções de nome, filtros tipados e a fatia vertical de uma funcionalidade (entidade → configuração EF → repositório → contrato → caso de uso → controller). Use ao criar projeto .NET novo, adicionar módulo/funcionalidade de backend ou revisar onde um código deve ficar. |

### Plugin `angular`

| Skill | Invocação | Descrição |
|---|---|---|
| `arquitetura-angular` | automática + `/arquitetura-angular` | Padrão de arquitetura para frontend Angular — pastas core/shared/features, regra de dependência (feature não importa feature), acesso HTTP em um único serviço, URL em environments, estado com signal, contrato com o backend e checklist de funcionalidade nova. Use ao criar projeto Angular novo, adicionar feature/página ou revisar onde um código deve ficar. |

## Core (instalado por `scripts/instalar-arquivos.ps1`)

| Arquivo | Descrição |
|---|---|
| `core/CLAUDE.md` | Instruções globais (40 linhas) |
| `core/agents/Explore.md` | agente `Explore` (`haiku`): Busca ampla e somente leitura no código — localizar arquivos, símbolos, padrões e convenções quando só a conclusão importa. Substitui o Explore embutido para rodar em Haiku. |

## Permissões (`core/settings.merge.json`)

Modelo `sonnet`, advisor `opus`. Regras: 32 allow, 170 ask, 58 deny. Política por classe de operação: README, seção Permissões.

## Perfis (`profiles/`, `merge-settings.ps1 -Perfil <nome>`)

- `unix`: chaves `sandbox`

## Camadas de projeto (`project-templates/`)

| Camada | Plugins | Deny | Regras por caminho | Outros arquivos |
|---|---|---|---|---|
| `_base` | `base@kit-dev-ia` | 7 regra(s) | - | - |
| `angular` | `typescript-lsp@claude-plugins-official`, `frontend-design@claude-plugins-official`, `angular@kit-dev-ia` | - | `angular.md` | - |
| `devcontainer` | - | - | - | `.devcontainer`, `README.md` |
| `dotnet` | `csharp-lsp@claude-plugins-official`, `dotnet@kit-dev-ia` | - | `dotnet.md` | - |
| `infra` | - | 4 regra(s) | - | - |
| `marketing` | `marketing-skills@marketingskills` | - | - | - |
| `node-ts` | `typescript-lsp@claude-plugins-official` | - | - | - |
| `playwright` | `playwright@claude-plugins-official` | - | - | - |
| `python` | `pyright-lsp@claude-plugins-official` | 2 regra(s) | - | - |
| `serena` | `serena@claude-plugins-official` | - | - | - |
| `supabase` | `supabase@claude-plugins-official` | - | - | - |
