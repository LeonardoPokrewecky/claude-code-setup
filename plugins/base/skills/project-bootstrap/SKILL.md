---
name: project-bootstrap
description: Prepara um projeto para o ambiente Claude Code — modo new-project (projeto novo) ou adopt-existing (projeto existente). Cria/mescla CLAUDE.md e .claude/settings.json do projeto de forma conservadora e idempotente. Use quando o projeto não tiver CLAUDE.md ou o usuário pedir para preparar/adotar um projeto.
---

# Project Bootstrap

Nunca sobrescrever, apagar ou renomear nada. Nada é criado sem aprovação explícita.

## 1. Descoberta (somente leitura)
1. Raiz, `git status`, branch, remoto. Sem Git: avisar e sugerir `git init` (não executar sem pedido).
2. Stack por arquivos reais (define as camadas, ver `componentes.md` do `env-guide`): `*.sln`/`*.csproj`, `package.json`, `angular.json`, `tsconfig.json`, `docker-compose*.yml`, CI, testes.
3. Comandos reais de build/teste (ex.: `dotnet build`, `dotnet test`, `npm run build`, `npm test`).
4. Inventário do que já existe: `CLAUDE.md`, `.claude\`, `.mcp.json`, `AGENTS.md`, `.gitignore`, hooks, worktrees; arquivos gerados por skills já versionados (`backlog/`, `HANDOFF.md`, `RELATORIO-LGPD.md` em `git ls-files`) → apontar no relatório (remover do histórico só com pedido explícito).
5. Não abrir `.env`, chaves ou certificados.
6. Opcional: o plugin `claude-code-setup` fica desligado no global; ligar na sessão (`/plugin`) só para pedir sugestões de automação e desligar depois.

## 2. Proposta (mostrar antes de criar)
- `CLAUDE.md` do projeto a partir de `project-templates/CLAUDE.project.md` (clone do `claude-code-setup`: linha "Clone" de `~/.claude/maquina.md`).
- **Regras por caminho:** copiar `project-templates/<camada>/.claude/rules/*.md` das camadas escolhidas (hoje `dotnet` e `angular`) para `<repo>/.claude/rules/`, sem sobrescrever arquivo existente. Elas só entram no contexto quando o Claude lê/edita arquivos que casam com o `paths:`.
- **Plugins do pacote:** a camada `_base` registra o marketplace `kit-dev-ia` e liga `base`; a camada `dotnet` liga o plugin `dotnet` (arquitetura onion). Quem clonar o repo recebe a sugestão de instalar.
- **Isolamento:** Windows nativo não tem sandbox; para código não confiável, propor a camada `devcontainer` (copiar `.devcontainer/`, não validada em projeto real) ou WSL2 com o perfil `unix`.
- Skill específica do projeto nunca guarda segredo (webhook, senha de teste, token): referenciar `secrets/<projeto>/` ou variável de ambiente.
- `.claude\settings.json` por **camadas**: sempre `_base` + a(s) da stack detectada + opcionais só se pedidos. Gerar com `scripts\merge-settings.ps1 -Target <repo>\.claude\settings.json -Layers ... -DryRun` e mostrar o resultado **e os alertas** antes de gravar; o usuário confere e aprova o código de confirmação. Repo sem Git: avisar que o `deny` da `_base` é a defesa e sugerir `git init` (sem executar).
- **Pasta de documentação** (blueprints, relatório LGPD, handoff): propor `<pasta-pai-do-repo>\docs\<nome-do-repo>\` na linha `Documentação:` do `CLAUDE.md`; criar a pasta só após OK.
- **`.gitignore`**: somar as linhas de `project-templates\gitignore.claude` que faltam no `.gitignore` do projeto (comparar linha a linha lendo os dois em UTF-8 — `Get-Content -Encoding UTF8`; no PowerShell 5.1 o padrão é ANSI e linha acentuada duplica a cada rodada —, sem duplicar, sem reordenar o existente); mostrar só as linhas novas. Sem Git: não criar.
- **Arquivos do Claude versionados?** Perguntar ao usuário. Padrão: sim (`CLAUDE.md` e `.claude\settings.json` são o contexto compartilhado do projeto). Repositório de cliente onde o Claude não deve aparecer: **não** mexer no `.gitignore` (é versionado e deixaria rastro); somar `CLAUDE.md`, `CLAUDE.local.md` e `.claude/` ao exclude local (caminho via `git rev-parse --git-path info/exclude`, cobre worktree), sem duplicar linha. Se algum deles já estiver em `git ls-files`, o exclude não tem efeito: avisar (tirar do índice/histórico só com pedido explícito).
- Skills/agentes específicos só se forem exclusivos deste projeto.
- Backend .NET: comparar os projetos/pastas com a skill `arquitetura-onion`; projeto novo nasce nesse padrão, projeto existente só registra as divergências na seção Arquitetura (sem mover nada).
- Frontend Angular: mesma regra com a skill `arquitetura-angular` (plugin `angular`).
- Projeto existente: mostrar o que será preservado e o que será adicionado, arquivo por arquivo.
- Se existir `<pasta de memória>\<Projeto>.memory` (pasta em `~/.claude/maquina.md`): propor levar stack, decisões e armadilhas para o `CLAUDE.md` do projeto.

- Ao final, propor a linha do projeto na tabela "Projetos atuais" de `~/.claude/maquina.md` (não no pacote).

## 3. Aplicar (após aprovação)
1. Backup dos arquivos que serão alterados (`<arquivo>.bak-AAAAMMDD-HHmmss`).
2. Criar apenas o que falta; mesclar o que existe. O script faz a união e o backup `<arquivo>.bak-AAAAMMDD-HHmmss` do settings sozinho e não grava nada se não houver mudança. Gravar com `-Confirmar <código do dry-run>` só depois da aprovação do usuário na conversa. O hook pede a confirmação na interface: nunca contornar. Código recusado significa que algo mudou: refazer o dry-run.
3. Validar JSON e caminhos citados.
4. Relatório: arquivos criados/alterados, decisões, como reverter.

## Idempotência
Rodar de novo não duplica nada: comparar com o existente e apresentar só as diferenças.
