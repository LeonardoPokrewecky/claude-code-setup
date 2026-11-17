# Pendências e ideias futuras

Movido do README (antigo item 10) em 2026-11-16, sem perda de item. O README só aponta para cá.
Contexto: [README.md](../README.md) · instalação e validação: [install/README.md](../install/README.md) · plano experimental: [workers/PLANO.md](../workers/PLANO.md).

## Backlog

- [x] Uso real: o projeto financeiro foi criado com este pacote e o usa desde o início até a versão atual (informado em 17/11/2026; o repositório não está na máquina DEV).
- [ ] Registrar as evidências da seção 5 do `install/README.md` vindas do projeto financeiro (hook bloqueia, `git push` pede confirmação, `/plugin`, `/agents`) e medir `/context` antes × depois.
- [x] Executar o CI (push) para PowerShell 7 e Linux: passou (PR #3, 09/11/2026; Windows PowerShell 5.1, PowerShell 7 e Ubuntu).
- [x] Evals criados e rodados para `/blueprint`, `/revisar` e `/alterar-dados` (7 casos, todos aprovados na última rodada).
- [ ] Perfil de CI e template de CI com `anthropics/claude-code-action` (sem caso real).
- [ ] Validar a seção IIS do `/deploy-checklist` e a camada `devcontainer` em projeto real.
- [ ] Validar `-Perfil unix` numa máquina Linux (roteiro em `project-templates/devcontainer/README.md`, seção "Validar o sandbox no Linux").
- [ ] Ideia futura: trilha de auditoria com cadeia de hash (cada registro guarda o hash do anterior) para `/alterar-dados` e `/deploy-checklist`; detecta edição no meio do arquivo, não prova autoria.
- [x] Evals antigos rodados em 2026-11-14 (ver README, seção 9).
- [ ] Revisar o conteúdo das skills novas de segurança e dados (`autenticacao-e-sessao`, `endurecimento-de-infraestrutura`, `resposta-a-incidente`, `modelagem-dados`, `integracoes`, `escolha-de-banco-e-capacidade`) com a lente `seguranca` e conferir recomendações contra fontes oficiais (OWASP, docs da Microsoft e do PostgreSQL) antes de publicar.
- [ ] Criar evals para as skills novas (sem eval hoje).
- [ ] Avaliar dividir o plugin `base` (39 skills) em plugins temáticos (segurança, QA e design, produto) e complementar `dotnet`/`angular` com autenticação, EF/índices e o lado de interface.
- [ ] Skills de marketing e SEO (Luna, Lira, Rank do levantamento externo): decidir entre plugin opcional próprio ou o `marketingskills` externo.
- [ ] Fixar `marketingskills` por SHA, se o schema aceitar.
- [x] `Auditoria LGPD.pdf` (material de terceiro) removido da árvore em 2026-11-14; a skill `/lgpd-audit` agora se baseia em fontes oficiais.
- [x] O PDF continua no histórico do Git (commit `8a6ac0a`) e nas refs `refs/pull/N/head` do GitHub, que são só leitura (push forçado não as remove). Decisão em 17/11/2026: **repositório privado**, sem reescrever o histórico (confirmado: a API do GitHub sem login responde 404). Instalar o marketplace exige credencial Git com acesso ao repositório.
- [x] Arquivo próprio de fontes oficiais da LGPD por projeto (`referencias/lgpd-fontes-oficiais.md` na pasta de documentação, fora do repositório), válido por 30 dias; `/lgpd-audit` usa sem pesquisar dentro do prazo, pergunta antes de atualizar quando vence e `/lgpd-audit atualizar-fontes` atualiza a pedido. Modelo em `plugins/base/skills/lgpd-audit/fontes-modelo.md`.
- [ ] Rodar uma vez `/lgpd-audit atualizar-fontes` num projeto de teste (usa rede; só com a sua autorização) e registrar o resultado.
- [ ] Validar `desenvolvimento-de-interfaces` e `/inspecao-visual` num frontend real com a camada `playwright` (nomes das ferramentas `browser_*` do MCP, captura, console e rede) e criar evals para elas.
- [ ] **Brecha (hipótese, sem WSL na DEV para reproduzir):** no WSL2 sem `pwsh`, o `run-hook.sh` cai no `powershell.exe` do Windows (interop) com caminho Linux no `-File`; o PowerShell não acha o arquivo e sai com código ≠ 0 e ≠ 2, que o Claude Code trata como erro não bloqueante — o comando rodaria sem verificação. Correção provável: só usar `powershell`/`powershell.exe` quando `OS=Windows_NT`; senão, pedir confirmação. Tratar em blueprint próprio (registrado em 17/11/2026).
- [x] Passo 1 para aposentar um `~/.claude/CLAUDE.md` legado: as regras genéricas que faltavam (deploy, firewall, proxy/CDN, Angular) foram para `deploy-checklist`, `endurecimento-de-infraestrutura`, `componentes-e-estados` e a referência do `angular` (17/11/2026).
- [x] Passo 2: as proibições sempre ativas e as regras exclusivas de cada projeto foram para o `CLAUDE.md` local dele, e o global foi trocado pelo `core/CLAUDE.md` (máquina DEV, 17/11/2026; backups antes da troca).
- [x] `merge-settings.ps1` misturava variantes da origem do marketplace (`directory` + `repo`, ou `github` + `path`). Agora um objeto com `source` diferente é tratado como valor único (`MANTIDO` ou `SOBRESCREVE` inteiro), com teste em `tests/merge-settings.Tests.ps1` (17/11/2026).
- [ ] Validação ao vivo da seção 5 do `install/README.md` na DEV (`echo .env` bloqueado, `git -C . push` pede confirmação, `/agents`, `/context`): fazer na primeira sessão depois de reabrir o Claude Code e registrar aqui.
- [ ] Eval `qual-skill-revisar`: o grader `consultou-guia` (`arm: with-only`) só sai da nota com `--ablation with-without`; com `--ablation none` derruba o caso (0/3 em 17/11/2026, com a resposta correta 3/3). Remover o grader ou rodar a suíte com ablação.

## Pendências de validação

- `echo .env` bloqueado pelo hook do plugin: confirmar numa sessão recarregada (`/reload-plugins`); o script em si bloqueia o caso.
- Seção 5 do `install/README.md` (`git push` pede confirmação, `/plugin`, `/agents`, `/context`): conferir na interface após recarregar.
- Frontend (projeto Angular de exemplo): `npm test` com ChromeHeadless passou, 31/31 testes, em 06/11/2026.
- macOS, Linux/WSL2 e sandbox (`-Perfil unix`) continuam não testados; o devcontainer foi testado com a CLI (build, isolamento, volume), falta a autenticação e o uso em projeto real (tabela da seção 7 do README).
