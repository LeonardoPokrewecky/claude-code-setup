---
name: regressao-e-smoke
description: Define e mantém uma verificação rápida pós-publicação (smoke) e uma regressão completa pré-entrega, com critérios de aprovação, o que automatizar e o que fazer em falha. Somente leitura e proposta; executar contra produção só com autorização. Só roda com /regressao-e-smoke [smoke|regressao|caminho].
disable-model-invocation: true
argument-hint: "[smoke | regressao | caminho do repo]"
---

Alvo: `$ARGUMENTS` (sem argumento: propor os dois). **Proposta e leitura.** Smoke em produção: apenas rotas somente leitura e conta de teste dedicada, com autorização; nunca criar/alterar/apagar dado real. Nunca exibir token ou segredo.

## 1. Smoke (minutos, logo após publicar)
Objetivo: saber se o essencial está de pé. Itens típicos: serviço respondendo (`/health` ou equivalente), versão publicada correta, login funciona, uma leitura crítica, conexão com banco/dependências, ausência de erros novos nos logs. Aprovação: todos os itens passam. **Falha → acionar a reversão do `/deploy-checklist`** antes de investigar.

## 2. Regressão (antes de entregar)
Objetivo: o que funcionava continua funcionando. Cobrir: fluxos principais de ponta a ponta, regras de negócio críticas (dinheiro, permissão, prazo), erros e limites já corrigidos (cada bug corrigido vira um caso), contratos de API e acesso cruzado entre contas. Priorizar por risco; o resto vai para a próxima rodada.

## 3. Regras
- Todo bug corrigido ganha teste que falhava antes da correção.
- O que foi validado à mão uma vez e é repetido vira teste automatizado (`/criar-testes`, `/teste-de-api`, `/automacao-e2e`).
- Caso sem insumo ou ambiente: **pulado com motivo**, nunca aprovado.
- Teste instável (passa e falha sem mudança) é tratado como defeito do teste e corrigido ou removido com registro; não repetir até passar.
- Execução rápida no CI a cada mudança (testes de unidade e smoke), regressão completa antes de entrega ou em horário fixo.

## Saída
Duas listas `item | como verificar | automatizado? | critério de aprovação`, a ordem de execução, o gatilho de reversão e "Não verifiquei:" (ex.: ambiente real, dados de produção, dependências externas).
