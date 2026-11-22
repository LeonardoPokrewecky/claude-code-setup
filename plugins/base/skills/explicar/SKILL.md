---
name: explicar
description: Mapa de um módulo, fluxo ou projeto para onboarding (somente leitura, com caminho:linha). Só roda com /explicar <módulo, fluxo ou pasta>.
disable-model-invocation: true
argument-hint: <módulo / fluxo / pasta>
---

Tema: `$ARGUMENTS` (vazio = projeto inteiro). **Somente leitura.** Usar Grep/Glob antes de Read; ler só o necessário.

Entregar: o que faz (2–3 linhas) · mapa de pastas/arquivos com a responsabilidade de cada um (`caminho:linha`) · fluxo principal passo a passo (entrada → saída) · dependências e pontos de extensão · armadilhas visíveis no código · onde olhar primeiro para mexer. Marcar o que foi **inferido** e o que foi **lido**. Terminar com "Não verifiquei:".
