---
name: depurar
description: Depura até a causa raiz (reproduzir, isolar, corrigir o mínimo, validar rodando); use quando pedirem para investigar bug, exception ou teste falhando sem causa óbvia.
argument-hint: "[erro, stack trace ou teste]"
---

Alvo: `$ARGUMENTS` (vazio = o erro citado na conversa). Objetivo: a **causa**, não o sumiço do sintoma. Não usar para erro de compilação óbvio no meio de uma implementação (corrigir direto) nem para incidente em produção agora (`resposta-a-incidente`).

## 1. Antes de teorizar
- Capturar a mensagem, o stack trace e os logs **completos** (preservar como evidência; ler o stack de baixo para cima).
- Consultar as armadilhas do projeto: `## Armadilhas conhecidas` do `CLAUDE.md`, `.claude/rules/` e `.claude/docs/<domínio>.md` (índice "Documentação por domínio"). Sintoma conhecido → testar o suspeito de lá **primeiro**.
- Ver o que mudou na área: `git log`, `git diff`, `git blame`.

## 2. Reproduzir e isolar
- Tentar reproduzir sozinho antes de perguntar. Só reproduz com dado real → registrar a condição e pedir dado fictício/anonimizado; nunca copiar dado real para teste, log ou doc.
- Hipótese específica → testar (estado real das variáveis, query, log temporário) antes de aceitar ou descartar. Log temporário sai ao final.
- Separar sintoma de causa: a exceção na linha X costuma nascer de validação ausente camadas antes.
- **Nunca** `git checkout -- .`, `git reset --hard`, `git clean` ou `git stash` para "conferir o estado": só `git status`/`git diff`. Comparar com a versão anterior: `/medir-antes-depois` (worktree).

## 3. Corrigir e validar
- Correção mínima; sem refatorar o que não está relacionado. Sem causa encontrada: **dizer**, não corrigir por especulação.
- Build limpo é necessário, não suficiente: validar rodando o teste, a rotina, a tela ou o endpoint.
- Escrever teste que reproduz o bug e passa com a correção.
- Suíte com falhas pré-existentes: comparar as falhas **pelo nome** antes × depois, nunca pelo total. Conferir que os testes executaram (ver `revisar/lentes/testes.md`, fidedignidade).

## 4. Saída
- **Causa raiz** — marcada como confirmada ou hipótese.
- **Evidência** — log, stack trace, query ou teste que reproduz (`caminho:linha`).
- **Correção** — o código específico.
- **Como validar** — teste ou passo concreto.
- **Prevenção** (opcional, curta).
- **Armadilha nova?** Propor a linha no lugar certo (regra do `CLAUDE.md` do projeto: geral → `Armadilhas conhecidas`; ligada a caminho → `.claude/rules/`; de domínio → `.claude/docs/<domínio>.md`) e mostrar antes de gravar.
