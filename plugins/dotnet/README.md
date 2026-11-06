# Plugin `dotnet`

Desligado por padrão (`defaultEnabled: false` no marketplace); a camada de projeto `dotnet` o liga em repositórios .NET, para que a descrição da skill `arquitetura-onion` só ocupe contexto onde é útil.

- Skill `arquitetura-onion`: projetos por camada, regra de dependência testada, convenções e fatia vertical de funcionalidade. Em projeto existente, o `CLAUDE.md` do projeto prevalece.
- Regras por caminho de .NET ficam na camada `project-templates/dotnet/.claude/rules/` (plugin não distribui regras).
