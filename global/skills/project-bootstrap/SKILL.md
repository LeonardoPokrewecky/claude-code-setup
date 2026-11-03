---
name: project-bootstrap
description: Prepara um projeto para o ambiente Claude Code — modo new-project (projeto novo) ou adopt-existing (projeto existente). Cria/mescla CLAUDE.md e .claude/settings.json do projeto de forma conservadora e idempotente. Use quando o projeto não tiver CLAUDE.md ou o usuário pedir para preparar/adotar um projeto.
---

# Project Bootstrap

Nunca sobrescrever, apagar ou renomear nada. Nada é criado sem aprovação explícita.

## 1. Descoberta (somente leitura)
1. Raiz, `git status`, branch, remoto. Sem Git: avisar e sugerir `git init` (não executar sem pedido).
2. Stack por arquivos reais (define as camadas, ver tabela de camadas no `env-guide`): `*.sln`/`*.csproj`, `package.json`, `angular.json`, `tsconfig.json`, `docker-compose*.yml`, CI, testes.
3. Comandos reais de build/teste (ex.: `dotnet build`, `dotnet test`, `npm run build`, `npm test`).
4. Inventário do que já existe: `CLAUDE.md`, `.claude\`, `.mcp.json`, `AGENTS.md`, `.gitignore`, hooks, worktrees; arquivos gerados por skills já versionados (`backlog/`, `HANDOFF.md`, `RELATORIO-LGPD.md` em `git ls-files`) → apontar no relatório (remover do histórico só com pedido explícito).
5. Não abrir `.env`, chaves ou certificados.
6. Opcional: o plugin `claude-code-setup` fica desligado no global; ligar na sessão (`/plugin`) só para pedir sugestões de automação e desligar depois.

## 2. Proposta (mostrar antes de criar)
- `CLAUDE.md` do projeto a partir de `project-templates\CLAUDE.project.md` (repositório `claude-code-setup`; caminho por máquina no `env-guide`).
- Skill específica do projeto nunca guarda segredo (webhook, senha de teste, token): referenciar `secrets/<projeto>/` ou variável de ambiente.
- `.claude\settings.json` por **camadas**: sempre `_base` + a(s) da stack detectada + opcionais só se pedidos. Gerar com `scripts\merge-settings.ps1 -Target <repo>\.claude\settings.json -Layers ... -DryRun` e mostrar o resultado **e os alertas** antes de gravar; o usuário confere e aprova o código de confirmação. Repo sem Git: avisar que o `deny` da `_base` é a defesa e sugerir `git init` (sem executar).
- **Pasta de documentação** (blueprints, relatório LGPD, handoff): propor `<pasta-pai-do-repo>\docs\<nome-do-repo>\` na linha `Documentação:` do `CLAUDE.md`; criar a pasta só após OK.
- **`.gitignore`**: somar as linhas de `project-templates\gitignore.claude` que faltam no `.gitignore` do projeto (comparar linha a linha lendo os dois em UTF-8 — `Get-Content -Encoding UTF8`; no PowerShell 5.1 o padrão é ANSI e linha acentuada duplica a cada rodada —, sem duplicar, sem reordenar o existente); mostrar só as linhas novas. Sem Git: não criar.
- Skills/agentes específicos só se forem exclusivos deste projeto.
- Projeto existente: mostrar o que será preservado e o que será adicionado, arquivo por arquivo.
- Se existir `C:\Workspace\Memory\<Projeto>.memory`: propor levar stack, decisões e armadilhas para o `CLAUDE.md` do projeto.

## 3. Aplicar (após aprovação)
1. Backup dos arquivos que serão alterados (`<arquivo>.bak-AAAAMMDD-HHmmss`).
2. Criar apenas o que falta; mesclar o que existe. O script faz a união e o backup `<arquivo>.bak-AAAAMMDD-HHmmss` do settings sozinho e não grava nada se não houver mudança. Gravar com `-Confirmar <código do dry-run>` só depois da aprovação do usuário na conversa. O hook pede a confirmação na interface: nunca contornar. Código recusado significa que algo mudou: refazer o dry-run.
3. Validar JSON e caminhos citados.
4. Relatório: arquivos criados/alterados, decisões, como reverter.

## Idempotência
Rodar de novo não duplica nada: comparar com o existente e apresentar só as diferenças.
