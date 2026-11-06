# Plugin `dotnet`

Desligado por padrão (`defaultEnabled: false` no marketplace); a camada de projeto `dotnet` o liga em repositórios .NET, para que a descrição da skill `arquitetura-onion` só ocupe contexto onde é útil.

- Skill `arquitetura-onion`: projetos por camada, regra de dependência testada, convenções e fatia vertical de funcionalidade. Em projeto existente, o `CLAUDE.md` do projeto prevalece.
- `arquitetura-onion/referencia-9-projetos.md`: padrão default de projeto novo, com 9 projetos numerados (API a Tools), carregado sob demanda; a variante enxuta fica no `SKILL.md`.
- Regras por caminho de .NET ficam na camada `project-templates/dotnet/.claude/rules/` (plugin não distribui regras).
