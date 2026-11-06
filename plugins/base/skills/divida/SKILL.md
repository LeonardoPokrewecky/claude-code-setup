---
name: divida
description: Registra e lista dívida técnica (atalhos adiados de propósito) em DIVIDA.md do projeto, com arquivo:linha, motivo, risco e gatilho para pagar. Só roda com /divida registrar <descrição> ou /divida listar.
disable-model-invocation: true
argument-hint: registrar <descrição do atalho> | listar
---

Argumentos: `$ARGUMENTS` → 1ª palavra = subcomando (`registrar` ou `listar`); resto = descrição. Sem subcomando: mostrar os dois e perguntar.

Registro: `DIVIDA.md` na raiz do projeto (criar com o título `# Dívida técnica` se não existir). Nunca gravar segredo, dado de cliente ou valor de configuração: citar só o tipo ("connection string", "CPF de teste").

## registrar
1. Localizar o trecho com Grep/Glob; sem localização confirmada, perguntar o arquivo (nunca inventar `arquivo:linha`).
2. Propor 1 linha:
   `- [ ] AAAA-MM-DD · <arquivo:linha> · <atalho> — motivo: <por que foi adiado> · risco: <baixo|médio|alto> <o que pode quebrar> · pagar quando: <gatilho>`
3. Mostrar a linha e só gravar após OK. Duplicata (mesmo `arquivo:linha` e atalho): avisar e não gravar de novo.

## listar
1. Ler `DIVIDA.md` (sem arquivo: dizer "nenhuma dívida registrada").
2. Para cada item aberto, conferir se o `arquivo:linha` ainda existe e se o trecho continua lá (Grep). Trecho sumiu ou mudou: marcar **resolvida?** no relatório — não apagar nem marcar `[x]` sozinho.
3. Entregar tabela `risco | arquivo:linha | atalho | gatilho | idade (dias) | situação`, do maior risco ao menor; empate → mais antiga primeiro.
4. Fechar itens (`[x]`) só quando o usuário confirmar, item a item. Terminar com "Não verifiquei:".
