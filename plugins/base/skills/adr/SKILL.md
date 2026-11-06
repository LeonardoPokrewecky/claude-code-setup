---
name: adr
description: Registra uma decisão técnica na seção "Decisões" do CLAUDE.md do projeto (contexto, escolha, alternativas, motivo). Só roda com /adr <decisão>.
disable-model-invocation: true
argument-hint: <decisão a registrar>
---

Decisão: `$ARGUMENTS`. Se faltar contexto, perguntar no máximo 2 coisas (alternativas consideradas, motivo).

1. Ler a seção `## Decisões` do `CLAUDE.md` do projeto (criar a seção se não existir).
2. Propor 1 linha no formato do projeto: `- AAAA-MM-DD <decisão> — <motivo>; descartado: <alternativas>`.
3. Mostrar o diff e só gravar após OK. Alterar apenas essa seção.
