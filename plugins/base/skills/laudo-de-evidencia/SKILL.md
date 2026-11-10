---
name: laudo-de-evidencia
description: Gera um laudo de validação (aprovado/reprovado/pulado por caso) com evidência reproduzível e sem dado sensível, em Markdown ou HTML autossuficiente. Só roda com /laudo-de-evidencia [alvo ou resultados].
disable-model-invocation: true
argument-hint: "[alvo | caminho dos resultados]"
---

Alvo: `$ARGUMENTS` (sem argumento: usar os resultados desta sessão). **Somente consolida o que foi realmente executado/observado**; nunca inventar resultado nem marcar como aprovado o que não foi rodado. Antes de gravar, remover segredo, token, dado pessoal e dado real de capturas, logs e exemplos (`***`). Salvar na pasta de documentação do projeto (ver CLAUDE.md; perguntar se fica só local ou versionada), não dentro do código.

## Estrutura do laudo
1. **Resumo:** o que foi validado, versão/commit, ambiente, data, executor. Veredito geral (**aprovado / reprovado / aprovado com ressalvas**) com o motivo.
2. **Tabela por caso:** `id | caso | esperado | obtido | veredito | evidência`. Veredito: aprovado, reprovado (motivo reproduzível), **pulado** (com motivo; nunca conta como aprovado).
3. **Falhas:** passos para reproduzir, gravidade, impacto, sugestão.
4. **Evidências:** comando e saída, resposta HTTP, captura de tela, trecho de log (mascarados), embutidas no próprio arquivo quando HTML.
5. **Não verifiquei:** o que ficou fora do escopo ou sem ambiente.
6. **Próximos passos:** correções, casos a automatizar (`/regressao-e-smoke`).

## Regras
- Toda aprovação tem evidência; decisão final sempre justificada.
- Resultado ambíguo é registrado como ressalva, não arredondado para aprovado.
- HTML autossuficiente (CSS e imagens embutidos, sem carregar recurso externo) para abrir em qualquer lugar.

## Saída
Caminho do laudo gerado, veredito geral e a lista de reprovados/pulados.
