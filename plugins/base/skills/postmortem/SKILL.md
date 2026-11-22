---
name: postmortem
description: Monta o post-mortem de um incidente ou bug sério (linha do tempo, causa raiz, impacto, ações). Só roda com /postmortem <descrição ou logs>.
disable-model-invocation: true
argument-hint: <descrição / caminho dos logs>
---

Incidente: `$ARGUMENTS`. Basear-se em evidência (logs, stack traces, `git log`); preservar trechos literais; separar **fato** de **hipótese**.

Incidente em andamento (não só retrospectiva): **classificar a gravidade** (crítica: dado pessoal vazado, acesso de terceiro ou perda de dado, resposta imediata; alta: credencial exposta ou vulnerabilidade explorável em produção, mesmo dia; média: exposição sem evidência de uso; baixa: achado teórico), **conter antes de entender** e **preservar a evidência antes de limpar** (logs, estado, artefatos). Credencial possivelmente exposta → rotacionar. Dado pessoal envolvido → avisar o usuário para avaliar a obrigação de notificação (`/lgpd-audit`). Anotar desde o início o que se sabe e o que **não** se sabe.

Diagnóstico sem adivinhar: processo que morre sem log → evidência externa (log do sistema, antivírus) correlacionada pelo horário exato; "serviço ativo" não prova que trabalha (comparar a hora da última linha de log com a do início do processo); processo em loop de reinício não aparece como falho (olhar contador de reinícios e log); antes de concluir que algo está exposto, testar **sem seguir redirecionamento**.

Entregar: resumo (1–2 linhas) · impacto · linha do tempo · causa raiz (os 5 porquês, parar quando a causa for acionável) · o que funcionou/falhou na detecção · ações (corrigir, prevenir, detectar) com dono sugerido · "Não verifiquei:". Sem culpar pessoas.


Ver também: `/resposta-a-incidente` (durante o incidente: conter, preservar evidência, comunicar) antes deste; `/gestao-de-segredos` se houve credencial exposta.
