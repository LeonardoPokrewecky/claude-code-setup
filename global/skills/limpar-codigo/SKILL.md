---
name: limpar-codigo
description: Relatório de código morto, duplicado, imports/variáveis sem uso e simplificações possíveis (somente relatório). Só roda com /limpar-codigo [caminho].
disable-model-invocation: true
argument-hint: [caminho]
---

Alvo: `$ARGUMENTS` (vazio = projeto, ignorando `node_modules`, `dist`, `bin`, `obj`). **Só relatório; não editar.**

Listar com `caminho:linha`: código morto/inalcançável, símbolos sem referência (conferir com Grep antes de afirmar), duplicação, imports e variáveis sem uso, TODO/FIXME antigos, simplificações óbvias. Marcar **seguro remover** × **conferir** (reflexão, serialização, DI, rotas por convenção). Aplicar mudanças só se o usuário aprovar item a item. Terminar com "Não verifiquei:".
