---
name: entrega-sem-pendencia
description: Checklist de fechamento antes de declarar uma tarefa pronta (build e testes limpos, sem TODO/placeholder/código morto, critérios de aceite atendidos, evidência de funcionamento real, documentação e pendências registradas). Somente leitura. Só roda com /entrega-sem-pendencia [alvo].
disable-model-invocation: true
argument-hint: "[caminho | branch:<nome>]"
---

Alvo: `$ARGUMENTS` (sem argumento: o diff atual, `git diff` e `git status -sb`). **Somente leitura**; rodar build/testes já autorizados no projeto. Não commita nem publica. Incompleto é **PARCIAL**, nunca "pronto".

## Checklist (cada item com evidência ou marcado "não verificado")
1. **Critério de aceite:** cada critério combinado foi atendido? Citar onde (`arquivo:linha`, teste ou saída).
2. **Build e testes:** build limpo, sem aviso novo; testes passam (citar comando e resultado); teste novo cobre o caminho feliz, o erro e o limite.
3. **Sem restos:** Grep no diff por `TODO`, `FIXME`, `HACK`, `NotImplemented`, `console.log`/`Debug.WriteLine`, dado de exemplo fixo, código comentado, tela vazia ou placeholder.
4. **Funciona de verdade:** foi exercitado o fluxo real (resposta HTTP, tela, comando), não só compilou; o que não foi exercitado é dito.
5. **Segurança e dados:** nenhum segredo no diff (`/gestao-de-segredos`), entrada validada, autorização conferida, dado pessoal tratado (`/lgpd-audit` se tocou dado pessoal).
6. **Compatibilidade:** migration reversível, contrato de API preservado ou versionado, configuração nova documentada.
7. **Documentação:** README/CLAUDE.md/ADR atualizados quando a mudança altera comando, arquitetura ou decisão.
8. **Arquivos fora de escopo:** nada alterado além do pedido; arquivos gerados ou temporários removidos.
9. **Pendências:** o que ficou de fora está listado com motivo e dono.

## Saída
Veredito **PRONTO / PARCIAL** e tabela `item | situação | evidência`; para PARCIAL, a lista objetiva do que falta. Não declarar pronto com item crítico (3, 4 ou 5) sem verificar.
