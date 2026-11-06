---
name: preparar-pr
description: Prepara o texto do PR a partir do diff (resumo, motivo, riscos, como testar, checklist). Não faz commit nem push. Só roda com /preparar-pr [branch base].
disable-model-invocation: true
argument-hint: "[branch base]"
---

Base: `$ARGUMENTS` (padrão: branch principal). **Não executar commit, push nem criar PR.**

1. `git diff <base>...HEAD` e `git log <base>..HEAD` (sem Git: avisar e pedir os arquivos alterados).
2. Entregar em Markdown: título curto · o que mudou e por quê · riscos/impacto (banco, API, config) · como testar (comandos reais do `CLAUDE.md`) · checklist (build ok, testes ok, sem segredos, docs) · pontos para o revisor olhar.
3. Se o diff passar do pedido ou misturar assuntos, avisar. Terminar com "Não verifiquei:" (ex.: testes não executados).
