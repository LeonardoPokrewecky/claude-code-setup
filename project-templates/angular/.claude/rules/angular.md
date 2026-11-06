---
paths:
  - "**/*.ts"
  - "**/*.html"
  - "**/*.scss"
  - "angular.json"
  - "package.json"
---

# Regras Angular/frontend (carregam só ao ler/editar arquivos do frontend)

- Contrato com o backend: query params e corpo com os nomes exatos do DTO; campo novo do DTO mapeado explicitamente no serviço; caminhos da API centralizados num serviço (sem `/api/` duplicado). Revisão: `/revisar contrato`.
- Modal fecha por X ou Cancelar, não pelo backdrop; nunca `alert()`/`confirm()` nativos (usar modal/toast acessível).
- Dado sensível no navegador: nunca em `localStorage` sem criptografia; token sem "lembrar-me" em `sessionStorage`.
- Guard valida a expiração real do JWT (`exp * 1000 > Date.now()`); decodificar base64url antes de `atob`. Interceptor: 401 em rota protegida → refresh ou logout.
- Todo `input`/`textarea` com `maxlength` igual ao `[MaxLength]` do backend; máscaras e validação de dígitos para documentos e telefones.
- Erro de autenticação mostra mensagem; nunca redireciona ou some.
- Build: `fileReplacements` na configuração `production`; `provideZonelessChangeDetection()` só se o projeto for zoneless. Respeitar a versão de Node do projeto (`.nvmrc`/`package.json`); não versionar lockfile reescrito por Node errado.
- Angular 17+: publicar o conteúdo de `dist/<projeto>/browser/`; `<base href>` correto fora da raiz; `sourceMap` desligado em produção.
- Página: `lang="pt-BR"` (ou o idioma do produto), `<title>` real, `meta description`, `theme-color`, favicon próprio.
- Depois do deploy: aba nova com hard reload e conferir o hash do bundle (CDN/cache servem index antigo).
