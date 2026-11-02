---
name: project-bootstrap
description: Prepara um projeto para o ambiente Claude Code — modo new-project (projeto novo) ou adopt-existing (projeto existente). Cria/mescla CLAUDE.md e .claude/settings.json do projeto de forma conservadora e idempotente. Use quando o projeto não tiver CLAUDE.md ou o usuário pedir para preparar/adotar um projeto.
---

# Project Bootstrap

Nunca sobrescrever, apagar ou renomear nada. Nada é criado sem aprovação explícita.

## 1. Descoberta (somente leitura)
1. Raiz, `git status`, branch, remoto. Sem Git: avisar e sugerir `git init` (não executar sem pedido).
2. Stack por arquivos reais: `*.sln`/`*.csproj`, `package.json`, `angular.json`, `tsconfig.json`, `docker-compose*.yml`, CI, testes.
3. Comandos reais de build/teste (ex.: `dotnet build`, `dotnet test`, `npm run build`, `npm test`).
4. Inventário do que já existe: `CLAUDE.md`, `.claude\`, `.mcp.json`, `AGENTS.md`, hooks, worktrees.
5. Não abrir `.env`, chaves ou certificados.
6. Opcional: rodar o plugin `claude-code-setup` para sugestões de automação.

## 2. Proposta (mostrar antes de criar)
- `CLAUDE.md` do projeto a partir de `project-templates\CLAUDE.project.md` (repositório de configuração em `C:\Users\Leonardo\Desktop\Skill e pluggin`).
- `.claude\settings.json` com os plugins do projeto, conforme a tabela da skill `env-guide`.
- Skills/agentes específicos só se forem exclusivos deste projeto.
- Projeto existente: mostrar o que será preservado e o que será adicionado, arquivo por arquivo.
- Se existir `C:\Workspace\Memory\<Projeto>.memory`: propor levar stack, decisões e armadilhas para o `CLAUDE.md` do projeto.

## 3. Aplicar (após aprovação)
1. Backup dos arquivos que serão alterados (`<arquivo>.bak-AAAAMMDD`).
2. Criar apenas o que falta; mesclar o que existe.
3. Validar JSON e caminhos citados.
4. Relatório: arquivos criados/alterados, decisões, como reverter.

## Idempotência
Rodar de novo não duplica nada: comparar com o existente e apresentar só as diferenças.
