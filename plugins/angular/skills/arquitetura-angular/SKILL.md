---
name: arquitetura-angular
description: Padrão de arquitetura para frontend Angular — core (guards, interceptors, models, services, utils), layouts/<nome>-shell, shared sem regra de negócio e pages/<tela>; standalone, inject(), zoneless e signals; rotas com loadComponent sob guard; contrato centralizado com o backend; URL em environment; regras de sessão e rede em arquivo de referência. Use ao criar projeto Angular novo, adicionar página/tela ou revisar onde um código deve ficar.
---

# Arquitetura Angular

- **Projeto novo:** nasce neste padrão (o da Fábrica do iAVendedor).
- **Projeto existente:** o `CLAUDE.md` do projeto prevalece; o padrão vale para **código novo** e as divergências são só registradas, sem mover pastas em massa. Adoção total só a pedido do usuário, com commit antes, build e testes verdes a cada etapa (sugerir `/plano-migracao`).
- **Front e back separados:** projetos independentes, nunca o front dentro de pasta do back; regra e organização no `project-bootstrap`. Contrato: OpenAPI do backend ou a seção 4 abaixo. O front **nunca** consome o Shared .NET.
- **Regras de sessão e rede** (interceptor, guard, 401/403, cache do `index.html`, busca com debounce): `referencia-regras-spa.md`, sob demanda. Estados de tela e componentes: `/componentes-e-estados`. Modelo de autenticação: `/autenticacao-e-sessao`. Não duplicar aqui.

## 1. Pastas (`src/app`)

```
core/
  guards/  interceptors/  models/  services/  utils/
layouts/<nome>-shell/        shell protegido (menu, outlet) — as rotas filhas ficam sob o guard
shared/                      UI reutilizável (componentes, pipes, diretivas), sem regra de negócio
pages/<tela>/<tela>.ts · .html · .scss     uma pasta por tela, `*.spec.ts` ao lado
src/environments/            apiUrl e demais valores por ambiente
```

- `core/`: o que o app inteiro usa e existe uma vez. `core/services/api.service.ts` é o **único** acesso HTTP; `core/models/` tem **um arquivo** de models espelhando os `*View`/`*Request` do backend.
- Estado usado por mais de uma página (store) vai para `core/services`; estado de uma tela só fica na própria página.
- Tela pequena pode ter um arquivo; separar em `<tela>.ts` + `<tela>.store.ts` + componentes quando crescer.

## 2. Regra de dependência

- `pages` → `core` e `shared`. `layouts` → `core` e `shared`. `shared` → nada do app. `core` → nada de `pages`.
- **Página não importa outra página.** Se duas precisam do mesmo código, ele sobe para `shared` (UI) ou `core` (dado/serviço).
- Imposição por ferramenta, não só por texto: `eslint-plugin-boundaries` ou `dependency-cruiser` rodando no `npm test`/CI. Instalar pacote só com pedido do usuário; sem a ferramenta, a regra é conferida na revisão.

## 3. Convenções

- Componente **standalone**; dependências com `inject()`; **zoneless** em projeto novo (estável a partir do Angular 20.2 e padrão no 21; em versão anterior, seguir o `CLAUDE.md` do projeto).
- Estado com `signal()` e `computed()`; template com `@if`, `@for`, `@switch`.
- **Todas as rotas com `loadComponent`**, e as telas internas como **filhas do shell protegido por guard**.
- Interceptors **funcionais** (`HttpInterceptorFn`); HTTP só via `ApiService`, componente não usa `HttpClient`; erro de API passa por `erroMsg`.
- URL da API só em `environment.apiUrl`, nunca fixa. O `environment.ts` de **desenvolvimento nunca aponta para produção** (e o pacote publicado é conferido: ver checklist).
- Sem `alert`/`confirm` nativos. Singleton com estado ganha `reset()` chamado no logout. O build sai **fora da pasta do código** (`outputPath`).
- Teste `*.spec.ts` ao lado do arquivo testado.

## 4. Contrato com o backend

- O front não inventa campo: o modelo nasce do `*View`/`*Request` do backend, com os mesmos nomes do JSON. Mudou o contrato → alterar os dois repositórios e conferir.
- Preferir tipos gerados do OpenAPI quando o backend publica o documento. Sem isso, comparar o JSON antes/depois da mudança (descartável).
- Campo opcional vazio vai **ausente** no envio, não como texto vazio.

## 5. Fatia vertical de uma tela nova (checklist)

1. Contrato: modelo em `core/models` e método em `ApiService` (o endpoint existe no backend?).
2. Store/serviço (signal) e teste.
3. Página em `pages/<tela>/`, standalone, com os estados de carregando, vazio e erro (`erroMsg`).
4. Rota com `loadComponent` como filha do shell, em `app.routes.ts`.
5. `npm run build` e `npm test` verdes; rodar contra a API real é passo à parte (senão, **PARCIAL**).
6. Antes de publicar: o pacote tem `apiUrl` de produção e o `index.html` sai sem cache.

## 6. Ao revisar

Import cruzando página, `HttpClient` fora do `ApiService`, URL fixa, `environment` de dev apontando para produção, modelo divergente do backend, rota sem `loadComponent` ou fora do shell, `alert`/`confirm`, tela sem spec, regra de negócio em `shared`, singleton sem `reset()`.
