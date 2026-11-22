---
name: metricas-de-produto
description: Define métricas de produto (aquisição, ativação, retenção, receita, indicação), liga cada entrega a um indicador e planeja a instrumentação respeitando privacidade e LGPD. Só roda com /metricas-de-produto [produto ou funcionalidade].
disable-model-invocation: true
argument-hint: "[produto | funcionalidade]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar o produto e o objetivo). **Somente proposta**; instrumentar código é edição dentro do escopo autorizado. Nunca usar dado real de usuário sem autorização. Metas numéricas são hipóteses a calibrar com dado real, não fatos.

## 1. Estrutura (funil AARRR)
| Etapa | Pergunta | Exemplos de indicador |
|---|---|---|
| Aquisição | De onde vêm? | Visitas, cadastros por canal, custo por cadastro |
| Ativação | Chegam ao primeiro valor? | % que completa a ação-chave em N dias |
| Retenção | Voltam? | Retenção D7/D30, usuários ativos por período |
| Receita | Pagam? | Conversão, receita por cliente, cancelamentos (churn) |
| Indicação | Recomendam? | Convites aceitos, NPS |

## 2. Regras
- Cada entrega/história liga-se a **um indicador** e a uma hipótese ("se fizermos X, a métrica Y sobe").
- Uma métrica-guia (a que mais reflete valor) e poucas de apoio; evitar métrica de vaidade (total acumulado sem contexto).
- Definição precisa: fórmula, janela de tempo, fonte, quem é "usuário ativo".
- Medir antes da mudança (linha de base) e comparar depois (`/medir-antes-depois`); cuidado com sazonalidade e amostra pequena.
- Métricas de qualidade técnica junto: erros, latência, disponibilidade.

## 3. Instrumentação e LGPD
Coletar o mínimo necessário, com finalidade e base legal definidas; evento sem dado pessoal sempre que possível (identificador pseudonimizado); consentimento antes de rastreadores não essenciais; retenção e eliminação definidas; ferramenta de terceiros é operador de dados (`/lgpd-audit`); nunca enviar dado sensível, senha ou conteúdo livre digitado pelo usuário para analytics.

## Saída
Tabela `indicador | definição (fórmula, janela, fonte) | hipótese | meta inicial (marcada como hipótese) | evento a instrumentar`, riscos de interpretação e "Não verifiquei:" (ex.: dados reais, ferramenta de analytics disponível, base legal confirmada pelo encarregado).
