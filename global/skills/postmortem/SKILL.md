---
name: postmortem
description: Monta o post-mortem de um incidente ou bug sério (linha do tempo, causa raiz, impacto, ações). Só roda com /postmortem <descrição ou logs>.
disable-model-invocation: true
argument-hint: <descrição / caminho dos logs>
---

Incidente: `$ARGUMENTS`. Basear-se em evidência (logs, stack traces, `git log`); preservar trechos literais; separar **fato** de **hipótese**.

Entregar: resumo (1–2 linhas) · impacto · linha do tempo · causa raiz (os 5 porquês, parar quando a causa for acionável) · o que funcionou/falhou na detecção · ações (corrigir, prevenir, detectar) com dono sugerido · "Não verifiquei:". Sem culpar pessoas.
