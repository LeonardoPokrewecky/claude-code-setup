# Plugin `angular`

Desligado por padrão (`defaultEnabled: false` no marketplace); a camada de projeto `angular` o liga em repositórios Angular, para que a descrição da skill `arquitetura-angular` só ocupe contexto onde é útil.

- Skill `arquitetura-angular`: `core/` (guards, interceptors, models, services, utils), `layouts/<nome>-shell`, `shared/` sem regra de negócio e `pages/<tela>`; standalone, `inject()`, zoneless e signals; rotas com `loadComponent` sob guard; HTTP só no `ApiService`; contrato com o backend. Em projeto existente, o `CLAUDE.md` do projeto prevalece.
- `arquitetura-angular/referencia-regras-spa.md`: regras de sessão e rede (interceptor que desembrulha, guard assíncrono com renovação única, 401/403, busca com debounce, `index.html` sem cache), carregadas sob demanda.
- Regras por caminho de Angular ficam na camada `project-templates/angular/.claude/rules/` (plugin não distribui regras).
