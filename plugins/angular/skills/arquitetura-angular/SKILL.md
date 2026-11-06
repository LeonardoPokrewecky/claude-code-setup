---
name: arquitetura-angular
description: Padrão de arquitetura para frontend Angular — pastas core/shared/features, regra de dependência (feature não importa feature), acesso HTTP em um único serviço, URL em environments, estado com signal, contrato com o backend e checklist de funcionalidade nova. Use ao criar projeto Angular novo, adicionar feature/página ou revisar onde um código deve ficar.
---

# Arquitetura Angular

- **Projeto novo:** nasce neste padrão.
- **Projeto existente:** o `CLAUDE.md` do projeto prevalece; melhorias só em código novo, sem mover pastas em massa. Adoção total só a pedido do usuário, com commit antes, build e testes verdes a cada etapa (sugerir `/plano-migracao`).

## 1. Pastas (`src/app`)
- `core/`: o que o app inteiro usa e existe uma vez — `api.service.ts` (único acesso HTTP), `models.ts` (DTOs espelhando os `*View`/`*Request` do backend), interceptors, guards, utilitários (`util.ts`).
- `shared/`: UI reutilizável sem regra de negócio (componentes, pipes, diretivas).
- `features/<feature>/`: páginas, componentes, serviço/store da feature e `*.spec.ts` ao lado do código.
- `src/environments/`: `apiUrl` e demais valores por ambiente.
- Feature pequena pode ser um arquivo (`painel.ts`); separar em `<feature>.ts` + `<feature>.store.ts` + componentes quando crescer.

## 2. Regra de dependência
- `features` → `core` e `shared`. `shared` → nada do app. `core` → nada de `features`.
- **Feature não importa outra feature.** Se duas precisam do mesmo código, ele sobe para `shared` (UI) ou `core` (dado/serviço).
- Imposição por ferramenta, não só por texto: `eslint-plugin-boundaries` ou `dependency-cruiser` rodando no `npm test`/CI. Instalar pacote só com pedido do usuário; sem a ferramenta, a regra é conferida na revisão.

## 3. Convenções
- Componente standalone, carregado com `loadComponent` nas rotas.
- HTTP só via `ApiService`; erro de API passa por `erroMsg`. Componente não usa `HttpClient`.
- URL da API só em `environments`; nunca fixa no código.
- Estado local com `signal`; store compartilhado só quando mais de uma feature usa (ex.: `equipe.store.ts`).
- Modelos em `core/models.ts` com os mesmos nomes de campo do JSON do backend.
- Teste `*.spec.ts` ao lado do arquivo testado.

## 4. Contrato com o backend
- O front não inventa campo: o modelo nasce do `*View`/`*Request` do backend. Mudou o contrato → alterar os dois repositórios e conferir.
- Preferir tipos gerados do OpenAPI do backend quando ele publica o documento. Sem isso, comparar o JSON antes/depois da mudança (descartável).

## 5. Fatia vertical de uma feature nova (checklist)
1. Contrato: modelo em `core/models.ts` e método em `ApiService` (o endpoint existe no backend?).
2. Store/serviço da feature (signal) e teste.
3. Componente(s) em `features/<feature>/`, standalone.
4. Rota com `loadComponent` em `app.routes.ts`.
5. Estados de carregando, vazio e erro (`erroMsg`).
6. `npm run build` e `npm test` verdes; rodar contra a API real é passo à parte (senão, **PARCIAL**).

## 6. Ao revisar
Import cruzando feature, `HttpClient` fora do `ApiService`, URL fixa, modelo divergente do backend, componente sem spec, regra de negócio em `shared`.
