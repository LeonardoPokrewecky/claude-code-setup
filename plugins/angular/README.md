# Plugin `angular`

Desligado por padrão (`defaultEnabled: false` no marketplace); a camada de projeto `angular` o liga em repositórios Angular, para que a descrição da skill `arquitetura-angular` só ocupe contexto onde é útil.

- Skill `arquitetura-angular`: pastas core/shared/features, regra de dependência (feature não importa feature), HTTP só no `ApiService`, contrato com o backend e fatia vertical de feature nova. Em projeto existente, o `CLAUDE.md` do projeto prevalece.
- Regras por caminho de Angular ficam na camada `project-templates/angular/.claude/rules/` (plugin não distribui regras).
