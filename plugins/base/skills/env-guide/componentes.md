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
| `autenticacao-e-sessao` | só `/autenticacao-e-sessao` | Decide e revisa o modelo de autenticação e sessão (cookie de sessão/BFF, JWT de acesso curto com refresh, IdP externo OIDC), com critérios de escolha, checklist de segurança e testes. Somente leitura; a escolha final é validada com o usuário na implementação. Só roda com /autenticacao-e-sessao [caminho ou "revisar"]. |
| `automacao-e2e` | só `/automacao-e2e` | Planeja e escreve testes de interface ponta a ponta estáveis (seletores, esperas, dados sintéticos, isolamento, evidência por caso), com opções de ferramenta. Executa só em ambiente local/homologação. Só roda com /automacao-e2e [fluxo ou caminho]. |
| `blueprint` | automática + `/blueprint` | Planejamento obrigatório antes de qualquer alteração não trivial — cria o blueprint da atividade (decisões, requisitos não funcionais, checklist, use cases, resultado) em backlog/ na pasta de documentação fora do repositório, abre no navegador e para até o usuário aprovar; depois guia a implementação e a avaliação de brechas. Usar antes de implementar, ou com /blueprint <descrição da atividade>. |
| `componentes-e-estados` | só `/componentes-e-estados` | Projeta componentes de interface reutilizáveis com variantes, estados de interação (hover, foco, ativo, desabilitado, erro) e os estados de tela (carregando, vazio, erro, sucesso, parcial), com acessibilidade. Só roda com /componentes-e-estados [componente ou tela]. |
| `comunicacao-de-status` | só `/comunicacao-de-status` | Redige relatório de andamento objetivo e fiel ao que aconteceu (feito, em andamento, bloqueios, riscos, decisões necessárias, próximos passos), para equipe ou cliente. Só roda com /comunicacao-de-status [período ou destinatário]. |
| `criar-testes` | só `/criar-testes` | Gera testes para código sem cobertura, seguindo o framework e o padrão do projeto, só nos arquivos indicados. Só roda com /criar-testes <arquivo ou classe>. |
| `deploy-checklist` | só `/deploy-checklist` | Checklist de deploy (antes, durante e depois) para APIs, frontends e workers em servidor Linux com systemd/NGINX (validado) ou Windows Server/IIS (não validado em projeto real), com auditoria pós-deploy. Só roda com /deploy-checklist <componente> [ambiente]. |
| `desenvolvimento-de-interfaces` | automática + `/desenvolvimento-de-interfaces` | Coordena trabalho de frontend (criar, auditar ou corrigir telas, páginas e componentes web) — escolhe o modo, ativa só as especialidades de interface necessárias, planeja UX e fecha com inspeção no navegador e testes. Use quando a tarefa for criar ou alterar interface, auditar uma aplicação web ou corrigir problema visual/de layout. |
| `divida` | só `/divida` | Registra e lista dívida técnica (atalhos adiados de propósito) em DIVIDA.md do projeto, com arquivo:linha, motivo, risco e gatilho para pagar. Só roda com /divida registrar <descrição> ou /divida listar. |
| `endurecimento-de-infraestrutura` | só `/endurecimento-de-infraestrutura` | Auditoria somente leitura para reduzir a superfície de ataque da infraestrutura (exposição de portas e serviços, acesso, cabeçalhos HTTP, TLS, containers, CI/CD, rede, logs, backup), com opções por tipo de hospedagem. Alterações só com autorização. Só roda com /endurecimento-de-infraestrutura [caminho ou "servidor"]. |
| `entrega-sem-pendencia` | só `/entrega-sem-pendencia` | Checklist de fechamento antes de declarar uma tarefa pronta (build e testes limpos, sem TODO/placeholder/código morto, critérios de aceite atendidos, evidência de funcionamento real, documentação e pendências registradas). Somente leitura. Só roda com /entrega-sem-pendencia [alvo]. |
| `env-guide` | automática + `/env-guide` | Guia do ambiente Claude Code deste pacote — quais plugins, skills, agentes e camadas de projeto existem, quando usar cada um e o que ativar em cada projeto. Use ao iniciar/adotar projeto, ao decidir delegar a um agente, ou quando perguntarem "qual plugin/skill usar". |
| `escolha-de-banco-e-capacidade` | só `/escolha-de-banco-e-capacidade` | Ajuda a escolher o tipo de banco e a dimensionar capacidade (clientes cadastrados → simultâneos → requisições/s), com checklist de gargalos, estratégia de escala e plano de teste de carga. Somente leitura; números são estimativas a validar por medição. Só roda com /escolha-de-banco-e-capacidade [caminho ou "capacidade"]. |
| `explicar` | só `/explicar` | Mapa de um módulo, fluxo ou projeto para onboarding (somente leitura, com caminho:linha). Só roda com /explicar <módulo, fluxo ou pasta>. |
| `gestao-de-segredos` | só `/gestao-de-segredos` | Auditoria e procedimento de gestão de segredos (varredura do histórico do Git, rotação na ordem certa, cofre/User Secrets/variável de ambiente, mascaramento, exposição já ocorrida). Somente leitura por padrão; rotação e reescrita de histórico só com autorização. Só roda com /gestao-de-segredos [caminho ou "exposicao"]. |
| `historias-de-usuario` | só `/historias-de-usuario` | Escreve histórias de usuário (persona, ação, benefício) com critérios de aceite testáveis, casos de erro e condição de pronto, e quebra épicos em histórias pequenas. Só roda com /historias-de-usuario [objetivo ou épico]. |
| `inspecao-visual` | só `/inspecao-visual` | Abre a aplicação no navegador com Playwright e inspeciona as rotas relevantes em várias larguras — capturas de tela, estouro horizontal, sobreposição, erros de console e requisições com falha, interações e comparação antes/depois. Somente ambiente local/homologação. Só roda com /inspecao-visual [rota, tela ou "auditar"]. |
| `integracoes` | só `/integracoes` | Projeta integrações com sistemas externos (API de terceiros, webhooks, filas, jobs) com timeout, nova tentativa, circuit breaker, idempotência, verificação de assinatura, fila de descarte, contrato e observabilidade, com opções por tipo de integração. Somente leitura e proposta; chamar serviço real ou alterar produção só com autorização. Só roda com /integracoes [integração ou caminho]. |
| `laudo-de-evidencia` | só `/laudo-de-evidencia` | Gera um laudo de validação (aprovado/reprovado/pulado por caso) com evidência reproduzível e sem dado sensível, em Markdown ou HTML autossuficiente. Só roda com /laudo-de-evidencia [alvo ou resultados]. |
| `layout-responsivo` | só `/layout-responsivo` | Projeta e verifica layouts responsivos de 320 px a telas largas (sem estouro horizontal, alvos de toque, texto legível, tabelas e formulários adaptáveis), com verificação no navegador nas larguras escolhidas (mínimo 320, 768 e 1280). Só roda com /layout-responsivo [tela ou caminho]. |
| `lgpd-audit` | só `/lgpd-audit` | Auditoria LGPD completa e somente leitura de um app (web/mobile/API) — pesquisa a legislação vigente, mapeia dados pessoais, avalia 11 áreas, prioriza P0–P3 e gera RELATORIO-LGPD.md (fora do repositório) em linguagem simples. Só roda com /lgpd-audit. |
| `limpar-codigo` | só `/limpar-codigo` | Relatório de código morto, duplicado, imports/variáveis sem uso e simplificações possíveis (somente relatório). Só roda com /limpar-codigo [caminho]. |
| `medir-antes-depois` | só `/medir-antes-depois` | Mede o comportamento ANTES e DEPOIS de uma correção, no mesmo ambiente e com o mesmo script, para provar ou refutar que a mudança resolve algo real. Só roda com /medir-antes-depois <achado ou correção>. |
| `metricas-de-produto` | só `/metricas-de-produto` | Define métricas de produto (aquisição, ativação, retenção, receita, indicação), liga cada entrega a um indicador e planeja a instrumentação respeitando privacidade e LGPD. Só roda com /metricas-de-produto [produto ou funcionalidade]. |
| `modelagem-dados` | só `/modelagem-dados` | Modelagem de dados para relacional ou documental (entidades, relacionamentos, chaves, índices a partir das consultas, tipos, integridade, histórico/auditoria, dados pessoais e LGPD) com migração segura. Somente leitura e proposta; criar ou alterar esquema só com autorização. Só roda com /modelagem-dados [funcionalidade ou caminho]. |
| `plano-migracao` | só `/plano-migracao` | Plano de upgrade de versão (ex.: .NET, Angular, pacote) com riscos, passos e rollback, somente leitura. Só roda com /plano-migracao <o quê> [versão alvo]. |
| `postmortem` | só `/postmortem` | Monta o post-mortem de um incidente ou bug sério (linha do tempo, causa raiz, impacto, ações). Só roda com /postmortem <descrição ou logs>. |
| `preparar-pr` | só `/preparar-pr` | Prepara o texto do PR a partir do diff (resumo, motivo, riscos, como testar, checklist). Não faz commit nem push. Só roda com /preparar-pr [branch base]. |
| `priorizacao` | só `/priorizacao` | Ordena uma lista de itens (histórias, tarefas, dívidas, riscos) por valor, custo, risco e urgência, com justificativa escrita, e opções de método (impacto/esforço, MoSCoW, RICE, custo do atraso). Só roda com /priorizacao [lista ou caminho]. |
| `project-bootstrap` | automática + `/project-bootstrap` | Prepara um projeto para o ambiente Claude Code — modo new-project (projeto novo) ou adopt-existing (projeto existente). Cria/mescla CLAUDE.md e .claude/settings.json do projeto de forma conservadora e idempotente. Use quando o projeto não tiver CLAUDE.md ou o usuário pedir para preparar/adotar um projeto. |
| `referencias-visuais` | só `/referencias-visuais` | Pesquisa referências de interface sob demanda (dashboards, ERPs, SaaS, landing pages, apps) para uma necessidade real — compara abordagens, extrai padrões de layout, navegação e componentes, verifica licença e adapta ao sistema de design do projeto. Só roda com /referencias-visuais [tipo de tela e contexto]. |
| `regressao-e-smoke` | só `/regressao-e-smoke` | Define e mantém uma verificação rápida pós-publicação (smoke) e uma regressão completa pré-entrega, com critérios de aprovação, o que automatizar e o que fazer em falha. Somente leitura e proposta; executar contra produção só com autorização. Só roda com /regressao-e-smoke [smoke\|regressao\|caminho]. |
| `resposta-a-incidente` | só `/resposta-a-incidente` | Roteiro de resposta a incidente em andamento (classificar, conter, preservar evidência, erradicar, recuperar, comunicar e avaliar notificação LGPD), com modelo de linha do tempo. Orienta decisões; ações destrutivas ou em produção só com autorização. Só roda com /resposta-a-incidente [descrição curta do incidente]. |
| `revisar` | só `/revisar` | Revisão somente leitura por lentes (seguranca, lgpd, arquitetura, qualidade, performance, testes, contrato, banco, integracoes, interface, deps, a11y, didatico). Sem lente, escolhe as lentes pelo risco do diff. Alvo: diff, caminho ou branch. Modo PR (pr <número\|branch>) checa CI e conflito e dá veredito. Só roda com /revisar [lente\|auto\|pr] [alvo]. |
| `session-handoff` | só `/session-handoff` | Gera um resumo de passagem de bastão quando uma tarefa vai continuar em outra sessão — objetivo, estado, decisões, arquivos, testes e próximos passos. Só roda com /session-handoff. |
| `sistema-de-design` | só `/sistema-de-design` | Define ou audita o sistema de design de uma interface (tokens de cor, espaço, tipografia, elevação e raio; temas claro/escuro; contraste; consistência e reaproveitamento), com opções de abordagem. Só roda com /sistema-de-design [caminho ou "auditar"]. |
| `teste-de-api` | só `/teste-de-api` | Valida endpoints de uma API (status, corpo, validação de entrada, autenticação/autorização, limites, idempotência, contrato) com casos de teste e evidência, em ambiente de teste. Não usa produção nem dado real. Só roda com /teste-de-api [caminho ou endpoint]. |

| Agente | Modelo | Ferramentas | Descrição |
|---|---|---|---|
| `documentation-haiku` | `haiku` | Read, Grep, Glob, Write, Edit | Escreve ou atualiza arquivos de documentação .md (README, docs, resumos) a partir do código existente. Use quando a tarefa for só documentação em .md; comentários dentro do código não são com este agente. |
| `implementer-sonnet` | `sonnet` | Read, Grep, Glob, Edit, Write, Bash, PowerShell | Implementa uma mudança de código bem delimitada (arquivos e critério de aceite definidos pelo chamador). Use só para trabalho independente em paralelo, ou quando a implementação geraria muito ruído no contexto principal; mudança simples a sessão faz direto. Não para decisões de arquitetura. |
| `researcher-haiku` | `haiku` | Read, Grep, Glob, WebFetch, WebSearch | Pesquisa somente leitura em documentação e web para responder perguntas factuais ou levantar opções. Use para pesquisa de bibliotecas, APIs e versões antes de decidir algo. Busca no código do projeto é com o Explore. |
| `revisor` | `inherit` | Read, Grep, Glob, Bash | Revisão somente leitura de um diff ou caminho com UMA lente (segurança, LGPD, arquitetura, qualidade, testes, contrato, banco, integracoes, performance, interface, deps, a11y, didatico). Use quando a skill /revisar delegar uma lente, ou após implementar algo não trivial. O chamador informa o alvo e o arquivo da lente. |
| `test-validator-haiku` | `haiku` | Read, Grep, Glob, Bash | Executa build e testes já existentes e autorizados (ex. dotnet build/test, npm run build/test) e resume o resultado. Use para validar uma mudança. |

Hook: `PreToolUse` (matcher `Bash|PowerShell`) → `if command -v pwsh >/dev/null 2>&1; then exec pwsh -NoProfile -NonInteractive -File "${CLAUDE_PLUGIN_ROOT}/hooks/bloquear-segredos.ps1"; elif command -v powershell >/dev/null 2>&1; then exec powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/hooks/bloquear-segredos.ps1"; else sh "${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.sh"; fi`

### Plugin `dotnet`

| Skill | Invocação | Descrição |
|---|---|---|
| `arquitetura-onion` | automática + `/arquitetura-onion` | Padrão de arquitetura para backend .NET — Solution padrão de 9 projetos numerados (API a Tools) com Shared como shared kernel (entidades, enums e DTOs; ordem api → application → domain → infra; variante enxuta Domain/Contracts para projeto pequeno), regra de dependência testada, convenções de nome, filtros tipados e a fatia vertical de uma funcionalidade (entidade → configuração EF → repositório → contrato → caso de uso → controller). Use ao criar projeto .NET novo, adicionar módulo/funcionalidade de backend ou revisar onde um código deve ficar. |

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
