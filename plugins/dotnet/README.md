# Plugin `dotnet`

Desligado por padrão (`defaultEnabled: false` no marketplace); a camada de projeto `dotnet` o liga em repositórios .NET, para que a descrição da skill `arquitetura-onion` só ocupe contexto onde é útil.

- Skill `arquitetura-onion`: pastas numeradas por camada, regra de dependência testada, allowlist de hosts, convenções e fatia vertical de funcionalidade. Em projeto existente, o `CLAUDE.md` do projeto prevalece.
- `arquitetura-onion/referencia-estrutura.md`: padrão default de projeto novo (`01-api` a `07-shared`, mais `tests/` e `tools/`), com Shared como shared kernel leve, segredos (Key Vault só como migração futura, a pedido) e regras de robustez, carregado sob demanda; a variante enxuta fica no `SKILL.md`.
- `arquitetura-onion/exemplo-teste-arquitetura.md`: modelo do teste de arquitetura obrigatório (direção, Shared leve, allowlist de hosts), carregado sob demanda.
- Regras por caminho de .NET ficam na camada `project-templates/dotnet/.claude/rules/` (plugin não distribui regras).
