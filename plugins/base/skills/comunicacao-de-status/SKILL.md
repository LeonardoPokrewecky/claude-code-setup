---
name: comunicacao-de-status
description: Redige relatório de andamento objetivo e fiel ao que aconteceu (feito, em andamento, bloqueios, riscos, decisões necessárias, próximos passos), para equipe ou cliente. Só roda com /comunicacao-de-status [período ou destinatário].
disable-model-invocation: true
argument-hint: "[período | destinatário]"
---

Alvo: `$ARGUMENTS` (sem argumento: o trabalho desta sessão e o `git log` recente). **Somente texto**; não envia nada a ninguém. Relatar **o que realmente aconteceu**: nunca arredondar parcial para pronto, nunca omitir bloqueio ou falha de teste. Sem segredo, dado pessoal ou nome de cliente que o destinatário não deva ver. Para continuar o trabalho em outra sessão, usar `/session-handoff`.

## Estrutura
1. **Resumo em uma frase:** estado geral (no prazo / em risco / atrasado) com o motivo.
2. **Feito:** entregas concluídas e **verificadas** (com evidência: teste, build, link).
3. **Em andamento:** o que é, % ou etapa, previsão com premissa.
4. **PARCIAL:** o que foi começado e não está completo, e o que falta.
5. **Bloqueios e riscos:** causa, impacto, dono e o que desbloqueia.
6. **Decisões necessárias:** a pergunta, as opções, a recomendação e o prazo da decisão.
7. **Próximos passos:** ordem e responsável.

## Regras
- Fatos separados de estimativas; estimativa leva a premissa.
- Linguagem do destinatário (cliente: resultado e prazo; equipe técnica: detalhe e `arquivo:linha`).
- Notícia ruim primeiro e sem eufemismo; incluir o plano de recuperação.
- Curto: o que o leitor precisa para agir, não o diário de tudo o que foi feito.

## Saída
O relatório pronto para copiar, em português, e a lista de pontos que precisam ser confirmados pelo usuário antes do envio.
