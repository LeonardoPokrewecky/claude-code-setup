# Componentes do pacote (gerado)

> Gerado por `scripts/gerar-docs.ps1` a partir dos arquivos do repositório. Não editar à mão.

## Plugins (marketplace `kit-dev-ia`)

| Plugin | Ligado por padrão | Descrição |
|---|---|---|
| `base` | sim | Hook de segredos, revisão por lentes, segurança, dados e integrações, testes e QA, design, requisitos e produto, deploy, LGPD e agentes. |
| `dotnet` | não (ligar por projeto) | Arquitetura onion para backend .NET. Ligado por projeto (camada dotnet). |
| `angular` | não (ligar por projeto) | Arquitetura de frontend Angular. Ligado por projeto (camada angular). |

### Plugin `base`

| Skill | Invocação | Descrição |
|---|---|---|
| `adr` | só `/adr` | Registra uma decisão técnica na seção "Decisões" do CLAUDE.md do projeto (contexto, escolha, alternativas, motivo). Só roda com /adr <decisão>. |
| `alterar-dados` | só `/alterar-dados` | Planeja e executa alteração de dados em banco (update em massa, backfill, correção de legado, varredura multi-tenant) com backup, dry-run e regra canário. Só roda com /alterar-dados <o que mudar e onde>. |
| `autenticacao-e-sessao` | automática + `/autenticacao-e-sessao` | Decide e revisa autenticação e sessão (cookie/BFF, JWT com refresh, OIDC); use ao implementar ou mudar login, token ou sessão. |
| `automacao-e2e` | só `/automacao-e2e` | Planeja e escreve testes de interface ponta a ponta estáveis (seletores, esperas, dados sintéticos, isolamento, evidência por caso), com opções de ferramenta. Executa só em ambiente local/homologação. Só roda com /automacao-e2e [fluxo ou caminho]. |
| `blueprint` | automática + `/blueprint` | Planeja antes de alteração não trivial: grava o blueprint, abre no navegador e para até o usuário aprovar. Use antes de implementar, ou com /blueprint <atividade>. |
| `comandos` | só `/comandos` | Lista os comandos do pacote com um resumo de cada um. Aceita um texto para filtrar. Só roda com /comandos [filtro]. |
| `componentes-e-estados` | só `/componentes-e-estados` | Projeta componentes de interface reutilizáveis com variantes, estados de interação (hover, foco, ativo, desabilitado, erro) e os estados de tela (carregando, vazio, erro, sucesso, parcial), com acessibilidade. Só roda com /componentes-e-estados [componente ou tela]. |
| `comunicacao-de-status` | só `/comunicacao-de-status` | Redige relatório de andamento objetivo e fiel ao que aconteceu (feito, em andamento, bloqueios, riscos, decisões necessárias, próximos passos), para equipe ou cliente. Só roda com /comunicacao-de-status [período ou destinatário]. |
| `criar-testes` | só `/criar-testes` | Gera testes para código sem cobertura, seguindo o framework e o padrão do projeto, só nos arquivos indicados. Só roda com /criar-testes <arquivo ou classe>. |
| `deploy-checklist` | só `/deploy-checklist` | Checklist de deploy (antes, durante e depois) para APIs, frontends e workers em servidor Linux com systemd/NGINX (validado) ou Windows Server/IIS (não validado em projeto real), com auditoria pós-deploy. Só roda com /deploy-checklist <componente> [ambiente]. |
| `depurar` | automática + `/depurar` | Depura até a causa raiz (reproduzir, isolar, corrigir o mínimo, validar rodando); use quando pedirem para investigar bug, exception ou teste falhando sem causa óbvia. |
| `desenvolvimento-de-interfaces` | automática + `/desenvolvimento-de-interfaces` | Coordena frontend (criar, auditar ou corrigir telas e componentes web), com especialidades de UX e inspeção no navegador. Use ao criar ou alterar interface. |
| `divida` | só `/divida` | Registra e lista dívida técnica (atalhos adiados de propósito) em DIVIDA.md do projeto, com arquivo:linha, motivo, risco e gatilho para pagar. Só roda com /divida registrar <descrição> ou /divida listar. |
| `endurecimento-de-infraestrutura` | só `/endurecimento-de-infraestrutura` | Auditoria somente leitura para reduzir a superfície de ataque da infraestrutura (exposição de portas e serviços, acesso, cabeçalhos HTTP, TLS, containers, CI/CD, rede, logs, backup), com opções por tipo de hospedagem. Alterações só com autorização. Só roda com /endurecimento-de-infraestrutura [caminho ou "servidor"]. |
| `entrega-sem-pendencia` | automática + `/entrega-sem-pendencia` | Checklist de fechamento (build, testes, restos, evidência, pendências); use antes de declarar uma tarefa pronta. Somente leitura. |
| `env-guide` | automática + `/env-guide` | Guia do ambiente deste pacote: plugins, skills, agentes e camadas. Use ao iniciar ou adotar projeto, ao delegar a agente, ou em "qual skill usar". |
| `escolha-de-banco-e-capacidade` | só `/escolha-de-banco-e-capacidade` | Ajuda a escolher o tipo de banco e a dimensionar capacidade (clientes cadastrados → simultâneos → requisições/s), com checklist de gargalos, estratégia de escala e plano de teste de carga. Somente leitura; números são estimativas a validar por medição. Só roda com /escolha-de-banco-e-capacidade [caminho ou "capacidade"]. |
| `explicar` | só `/explicar` | Mapa de um módulo, fluxo ou projeto para onboarding (somente leitura, com caminho:linha). Só roda com /explicar <módulo, fluxo ou pasta>. |
| `gestao-de-segredos` | automática + `/gestao-de-segredos` | Auditoria e rotação de segredos (histórico, cofre, mascaramento); use quando houver segredo, token ou chave no código, histórico ou exposto. |
| `historias-de-usuario` | só `/historias-de-usuario` | Escreve histórias de usuário (persona, ação, benefício) com critérios de aceite testáveis, casos de erro e condição de pronto, e quebra épicos em histórias pequenas. Só roda com /historias-de-usuario [objetivo ou épico]. |
| `inspecao-visual` | só `/inspecao-visual` | Abre a aplicação no navegador com Playwright e inspeciona as rotas relevantes em várias larguras — capturas de tela, estouro horizontal, sobreposição, erros de console e requisições com falha, interações e comparação antes/depois. Somente ambiente local/homologação. Só roda com /inspecao-visual [rota, tela ou "auditar"]. |
| `integracoes` | automática + `/integracoes` | Projeta integrações externas (timeout, retry, idempotência, assinatura, fila de descarte); use ao integrar API de terceiro, webhook, fila ou job. |
| `laudo-de-evidencia` | só `/laudo-de-evidencia` | Gera um laudo de validação (aprovado/reprovado/pulado por caso) com evidência reproduzível e sem dado sensível, em Markdown ou HTML autossuficiente. Só roda com /laudo-de-evidencia [alvo ou resultados]. |
| `layout-responsivo` | só `/layout-responsivo` | Projeta e verifica layouts responsivos de 320 px a telas largas (sem estouro horizontal, alvos de toque, texto legível, tabelas e formulários adaptáveis), com verificação no navegador nas larguras escolhidas (mínimo 320, 768 e 1280). Só roda com /layout-responsivo [tela ou caminho]. |
| `lgpd-audit` | só `/lgpd-audit` | Auditoria LGPD completa e somente leitura de um app (web/mobile/API) — pesquisa a legislação vigente, mapeia dados pessoais, avalia 11 áreas, prioriza P0–P3 e gera RELATORIO-LGPD.md (fora do repositório) em linguagem simples. Só roda com /lgpd-audit. |
| `limpar-codigo` | só `/limpar-codigo` | Relatório de código morto, duplicado, imports/variáveis sem uso e simplificações possíveis (somente relatório). Só roda com /limpar-codigo [caminho]. |
| `medir-antes-depois` | só `/medir-antes-depois` | Mede o comportamento ANTES e DEPOIS de uma correção, no mesmo ambiente e com o mesmo script, para provar ou refutar que a mudança resolve algo real. Só roda com /medir-antes-depois <achado ou correção>. |
| `metricas-de-produto` | só `/metricas-de-produto` | Define métricas de produto (aquisição, ativação, retenção, receita, indicação), liga cada entrega a um indicador e planeja a instrumentação respeitando privacidade e LGPD. Só roda com /metricas-de-produto [produto ou funcionalidade]. |
| `modelagem-dados` | automática + `/modelagem-dados` | Modela dados relacionais ou documentais (chaves, índices, integridade, LGPD, migração segura); use ao criar tabela, entidade, relacionamento ou índice. |
| `padroes-de-pagina` | só `/padroes-de-pagina` | Garante um padrão único de UX nas páginas de um projeto — cria o contrato de uma tela nova (tipo, estrutura, botões e ações, telas de configuração, microcopy, estados) ou audita a usabilidade das existentes contra o padrão do projeto (`docs/ux-padroes.md`) e as heurísticas, apontando divergências e melhorias do próprio padrão. Só roda com /padroes-de-pagina [criar\|auditar] [tela ou caminho]. |
| `plano-migracao` | só `/plano-migracao` | Plano de upgrade de versão (ex.: .NET, Angular, pacote) com riscos, passos e rollback, somente leitura. Só roda com /plano-migracao <o quê> [versão alvo]. |
| `postmortem` | só `/postmortem` | Monta o post-mortem de um incidente ou bug sério (linha do tempo, causa raiz, impacto, ações). Só roda com /postmortem <descrição ou logs>. |
| `preparar-pr` | só `/preparar-pr` | Prepara o texto do PR a partir do diff (resumo, motivo, riscos, como testar, checklist). Não faz commit nem push. Só roda com /preparar-pr [branch base]. |
| `priorizacao` | só `/priorizacao` | Ordena uma lista de itens (histórias, tarefas, dívidas, riscos) por valor, custo, risco e urgência, com justificativa escrita, e opções de método (impacto/esforço, MoSCoW, RICE, custo do atraso). Só roda com /priorizacao [lista ou caminho]. |
| `project-bootstrap` | automática + `/project-bootstrap` | Prepara projeto novo ou existente (CLAUDE.md e .claude/settings.json, de forma conservadora). Use quando o projeto não tiver CLAUDE.md ou ao adotar um projeto. |
| `referencias-visuais` | só `/referencias-visuais` | Pesquisa referências de interface sob demanda (dashboards, ERPs, SaaS, landing pages, apps) para uma necessidade real — compara abordagens, extrai padrões de layout, navegação e componentes, verifica licença e adapta ao sistema de design do projeto. Só roda com /referencias-visuais [tipo de tela e contexto]. |
| `regressao-e-smoke` | só `/regressao-e-smoke` | Define e mantém uma verificação rápida pós-publicação (smoke) e uma regressão completa pré-entrega, com critérios de aprovação, o que automatizar e o que fazer em falha. Somente leitura e proposta; executar contra produção só com autorização. Só roda com /regressao-e-smoke [smoke\|regressao\|caminho]. |
| `responder-revisao` | só `/responder-revisao` | Trata os comentários de revisão de um PR — lê o código de cada thread, corrige, verifica, responde thread a thread e resolve só depois da resposta postada. Postar e resolver pedem confirmação; commit e push só a pedido. Só roda com /responder-revisao <número do PR \| branch>. |
| `resposta-a-incidente` | automática + `/resposta-a-incidente` | Roteiro de resposta a incidente (conter, preservar evidência, recuperar, LGPD); use quando algo estiver quebrado ou exposto em produção agora. |
| `revisar` | só `/revisar` | Revisão somente leitura por lentes (seguranca, lgpd, arquitetura, qualidade, performance, testes, contrato, banco, integracoes, interface, deps, a11y, didatico). Sem lente, escolhe as lentes pelo risco do diff. Alvo: diff, caminho ou branch. Modo PR (pr <número\|branch>) checa CI e conflito e dá veredito. Só roda com /revisar [lente\|auto\|pr] [alvo]. |
| `session-handoff` | só `/session-handoff` | Gera um resumo de passagem de bastão quando uma tarefa vai continuar em outra sessão — objetivo, estado, decisões, arquivos, testes e próximos passos. Só roda com /session-handoff. |
| `sistema-de-design` | só `/sistema-de-design` | Define ou audita o sistema de design de uma interface (tokens de cor, espaço, tipografia, elevação e raio; temas claro/escuro; contraste; consistência e reaproveitamento), com opções de abordagem. Só roda com /sistema-de-design [caminho ou "auditar"]. |
| `teste-de-api` | só `/teste-de-api` | Valida endpoints de uma API (status, corpo, validação de entrada, autenticação/autorização, limites, idempotência, contrato) com casos de teste e evidência, em ambiente de teste. Não usa produção nem dado real. Só roda com /teste-de-api [caminho ou endpoint]. |

| Agente | Modelo | Ferramentas | Descrição |
|---|---|---|---|
| `documentation-haiku` | `haiku` | Read, Grep, Glob, Write, Edit | Escreve ou atualiza documentação .md a partir do código existente. Use só para .md; comentários no código não. |
| `implementer-sonnet` | `sonnet` | Read, Grep, Glob, Edit, Write, Bash, PowerShell | Implementa mudança de código delimitada (arquivos e aceite definidos). Use para trabalho independente em paralelo; não para arquitetura. |
| `researcher-haiku` | `haiku` | Read, Grep, Glob, WebFetch, WebSearch | Pesquisa somente leitura em documentação e web (bibliotecas, APIs, versões). Busca no código do projeto é com o Explore. |
| `revisor` | `inherit` | Read, Grep, Glob, Bash | Revisão somente leitura de diff ou caminho com UMA lente (segurança, LGPD, testes etc.). Use quando /revisar delegar ou após algo não trivial. |
| `test-validator-haiku` | `haiku` | Read, Grep, Glob, Bash | Executa build e testes já existentes e autorizados e resume o resultado. Use para validar uma mudança. |

Hook: `SessionStart` (matcher `startup|resume`) → `sh "${CLAUDE_PLUGIN_ROOT}/hooks/aviso-core.sh"`
Hook: `PreToolUse` (matcher `Bash|PowerShell`) → `if [ "$OS" = "Windows_NT" ] && command -v powershell >/dev/null 2>&1; then o=$(powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/hooks/bloquear-segredos.ps1"); r=$?; elif command -v pwsh >/dev/null 2>&1; then o=$(pwsh -NoProfile -NonInteractive -File "${CLAUDE_PLUGIN_ROOT}/hooks/bloquear-segredos.ps1"); r=$?; else printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Hook bloquear-segredos: PowerShell (pwsh ou powershell) não encontrado; o comando não foi verificado. Confira o que o comando faz antes de aprovar."}}'; exit 0; fi; case "$r" in 0|2) [ -n "$o" ] && printf '%s' "$o"; exit "$r";; esac; printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Hook bloquear-segredos: o PowerShell não executou o hook (código de saída %s); o comando não foi verificado. Confira o que o comando faz antes de aprovar."}}' "$r"; exit 0`

### Plugin `dotnet`

| Skill | Invocação | Descrição |
|---|---|---|
| `arquitetura-onion` | automática + `/arquitetura-onion` | Arquitetura .NET em pastas 01-api a 09-tools, Shared leve e teste de arquitetura. Use ao criar projeto .NET, adicionar módulo ou adotar a estrutura numerada. |

### Plugin `angular`

| Skill | Invocação | Descrição |
|---|---|---|
| `arquitetura-angular` | automática + `/arquitetura-angular` | Arquitetura Angular (core, layouts, shared, pages; standalone, signals, rotas sob guard). Use ao criar projeto Angular, adicionar tela ou decidir onde um código fica. |

## Core (instalado por `scripts/instalar-arquivos.ps1`)

| Arquivo | Descrição |
|---|---|
| `core/CLAUDE.md` | Instruções globais (40 linhas) |
| `core/agents/Explore.md` | agente `Explore` (`haiku`): Busca ampla somente leitura no código (arquivos, símbolos, padrões, convenções) quando só a conclusão importa. Substitui o Explore embutido, em Haiku. |

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
