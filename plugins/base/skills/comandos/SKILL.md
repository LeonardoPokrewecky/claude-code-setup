---
name: comandos
description: Lista os comandos do pacote com um resumo de cada um. Aceita um texto para filtrar. Só roda com /comandos [filtro].
disable-model-invocation: true
argument-hint: "[texto para filtrar]"
---

Filtro: `$ARGUMENTS` (vazio = lista completa).

1. Ler `${CLAUDE_SKILL_DIR}/comandos.md` (lista gerada por `scripts/gerar-docs.ps1`). Arquivo ausente: dizer "lista de comandos não encontrada; rode `/plugin update`" e parar — nunca montar a lista de memória.
2. Sem filtro: mostrar as tabelas como estão, na mesma ordem, **sem reescrever nem resumir** os textos.
3. Com filtro: manter só as linhas cujo comando ou texto contém o filtro, sem diferenciar maiúsculas nem acentos (`AUTENTICACAO` acha `/autenticacao-e-sessao`); manter o título do plugin só onde sobrou linha. Nenhuma linha: "nenhum comando contém '<filtro>'" e sugerir `/comandos` sem filtro.
4. Terminar com uma linha: "Comandos nativos do Claude Code (`/help`, `/clear`, `/plugin`…): `/help`. Quando usar cada um: skill `env-guide`."

Só leitura: não executar nenhum dos comandos listados.
