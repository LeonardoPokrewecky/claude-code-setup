---
name: plano-migracao
description: Plano de upgrade de versão (ex.: .NET, Angular, pacote) com riscos, passos e rollback, somente leitura. Só roda com /plano-migracao <o quê> [versão alvo].
disable-model-invocation: true
argument-hint: <tecnologia> [versão alvo]
---

Alvo: `$ARGUMENTS`. **Somente leitura; nada é atualizado.**

1. Descobrir a versão atual nos arquivos reais (`global.json`, `*.csproj`, `package.json`, `angular.json`).
2. Pesquisar o guia oficial de migração da versão alvo (usar `context7` ou docs oficiais) e listar breaking changes que atingem este código (`caminho:linha`).
3. Entregar: pré-requisitos, passos em ordem, riscos, como validar (build/testes), **como reverter** e estimativa de esforço.
4. Terminar com "Não verifiquei:". Executar só se o usuário pedir, com backup/branch antes.
