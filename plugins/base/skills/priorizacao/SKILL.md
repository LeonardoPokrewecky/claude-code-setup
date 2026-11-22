---
name: priorizacao
description: Ordena uma lista de itens (histórias, tarefas, dívidas, riscos) por valor, custo, risco e urgência, com justificativa escrita, e opções de método (impacto/esforço, MoSCoW, RICE, custo do atraso). Só roda com /priorizacao [lista ou caminho].
disable-model-invocation: true
argument-hint: "[lista | caminho]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar a lista e o objetivo). **Somente análise**; a decisão final é do usuário. Estimativas são hipóteses declaradas, não fatos; perguntar o que não souber em vez de inventar números.

## 1. Critérios (definir antes de pontuar)
Objetivo do período, restrições (prazo, equipe, legal), e as dimensões usadas: valor para o usuário/negócio, esforço, **risco** (técnico, segurança, LGPD), dependências e **custo do atraso**. Itens de **segurança, conformidade legal ou perda de dados** sobem de prioridade pelo risco, mesmo com baixo valor aparente.

## 2. Métodos (escolher conforme o contexto)
| Método | Quando favorece |
|---|---|
| **Impacto × esforço** (2×2) | Triagem rápida de lista curta |
| **MoSCoW** (deve, deveria, poderia, não agora) | Escopo fechado com prazo fixo |
| **RICE** (alcance × impacto × confiança ÷ esforço) | Produto com dados de uso |
| **Custo do atraso** (CD3: custo do atraso ÷ duração) | Itens com prazo ou perda crescente |

## 3. Passos
1. Tabela `item | valor | esforço | risco | dependência | observação` com a premissa de cada nota.
2. Aplicar o método escolhido e ordenar.
3. Justificar por escrito o topo, o fim e as posições contestáveis.
4. Apontar dependências que alteram a ordem e o que dá para entregar em paralelo.
5. Sugerir corte: o que não entra agora e por quê.

## Saída
Fila ordenada com justificativa curta por item, premissas assumidas, itens com incerteza alta (candidatos a pesquisa ou prova de conceito) e "Não verifiquei:" (ex.: dados de uso reais, custos não informados).
