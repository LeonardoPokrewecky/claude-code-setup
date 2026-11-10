---
name: escolha-de-banco-e-capacidade
description: Ajuda a escolher o tipo de banco e a dimensionar capacidade (clientes cadastrados → simultâneos → requisições/s), com checklist de gargalos, estratégia de escala e plano de teste de carga. Somente leitura; números são estimativas a validar por medição. Só roda com /escolha-de-banco-e-capacidade [caminho ou "capacidade"].
disable-model-invocation: true
argument-hint: "[caminho do repo] | capacidade"
---

Alvo: `$ARGUMENTS` (sem argumento: repositório atual). **Somente leitura.** Nunca ler `.env` nem exibir connection string; nunca acessar banco de produção nem dado real. Banco é decisão de arquitetura/dados: recomendar sessão Opus se a atual for mais fraca. **Todo número abaixo é estimativa de ordem de grandeza**: a decisão final vem de teste de carga no projeto.

## 1. Levantar o contexto (perguntar o que faltar, não supor)
Domínio e criticidade (financeiro? consistência forte?), clientes cadastrados e crescimento esperado, simultaneidade de pico, proporção leitura × escrita, tamanho e retenção dos dados, consultas mais frequentes e mais pesadas (relatórios, extratos, busca), picos sazonais (fechamento, folha, promoção), requisitos de disponibilidade (RTO/RPO), LGPD (retenção, exclusão, localização dos dados), orçamento e time (quem opera o banco), e o que já existe (Grep por `DbContext`, migrations, drivers, `docker-compose`).

## 2. Escolha do tipo (apresentar opções; validar na implementação)
| Necessidade | Opção favorecida | Atenção |
|---|---|---|
| Transações, saldo, lançamento, integridade | **Relacional ACID** (PostgreSQL, SQL Server) | Modelar índices e transações curtas; o padrão para financeiro |
| Documentos flexíveis, pouca relação, esquema variável | **Documento** (MongoDB) | Transação multi-documento e relatório relacional são mais difíceis; não usar para saldo sem análise |
| Sessão, cache, limite de taxa, fila leve | **Chave-valor/cache** (Redis) | Não é fonte da verdade; definir expiração e o que acontece se cair |
| Busca textual, filtros e facetas | **Motor de busca** (OpenSearch/Elasticsearch) | Réplica derivada do banco principal, não a fonte |
| Séries temporais, métricas, eventos | **Time-series/colunar** (TimescaleDB, ClickHouse) | Para análise, não para o fluxo transacional |
| Análise pesada, BI | **Réplica de leitura ou data warehouse** | Separar da carga transacional |

Regra de partida: **um relacional bem modelado resolve a maioria dos produtos**; adicionar outro tipo só com necessidade medida. Políglota aumenta custo operacional.

## 3. Dimensionar a carga
1. Cadastrados → **ativos no pico** (hipótese inicial 1% a 5%; usar o dado real quando existir).
2. Ativos × ações por minuto → **requisições/s** (e quantas viram consulta ao banco).
3. Separar **leituras × escritas** e as **consultas mais caras**.
4. Multiplicar por margem (2× a 3×) para pico e crescimento do próximo ano.
5. Comparar com o que a configuração escolhida sustenta **medido** (ver seção 5), não com número de catálogo.

## 4. Gargalos mais comuns (checar em ordem)
1. **Consulta sem índice, N+1, `SELECT *`, falta de paginação** (de longe o mais comum): `EXPLAIN`/plano de execução, log de consultas lentas.
2. **Conexões:** pool configurado (Npgsql/ADO), limite do servidor, PgBouncer/proxy; conexão aberta durante chamada externa.
3. **Contenção e locks:** linhas quentes (saldo, contador), transações longas, nível de isolamento, deadlock; operação idempotente e reprocessável.
4. **Leitura pesada junto da escrita:** réplica de leitura, relatório fora do horário ou em outra base.
5. **Sem cache** de dado que quase não muda; cache com invalidação definida.
6. **Disco, memória e I/O** (cache do banco, IOPS), autovacuum/estatísticas (PostgreSQL), crescimento de tabela sem partição.
7. **Aplicação:** trabalho síncrono que poderia ir para fila, jobs concorrentes no mesmo horário de pico.

## 5. Escala (do barato ao caro)
1. Índices, consultas e pool → 2. cache → 3. máquina maior (vertical) → 4. réplica de leitura → 5. particionamento por data/tenant → 6. filas e processamento assíncrono → 7. sharding (só com necessidade medida). Cada degrau com custo operacional crescente.

## 6. Teste de carga (antes de produção)
Ferramenta à escolha (k6, NBomber, JMeter), em ambiente de homologação com **dado sintético/anonimizado** e volume parecido com o real (nunca dados reais sem autorização). Cenários: uso normal, pico (2× a 3×), pico prolongado e falha de dependência. Métricas: latência p95/p99, taxa de erro, requisições/s, conexões ativas, CPU/memória/IOPS do banco, tempo de consulta. Critério de aceite definido **antes** (ex.: p95 abaixo de X ms a Y req/s sem erro). Medir antes e depois de cada otimização (`/medir-antes-depois`).

## 7. Operação e dados
Banco nunca exposto à internet, conexão com TLS, usuário da aplicação com menor privilégio e contas separadas para migração e leitura, dado em repouso criptografado, backup e teste de restauração, RPO/RTO, migrations reversíveis e testadas (`/plano-migracao`), monitoramento e alerta (lentidão, conexões, disco), retenção e exclusão conforme LGPD (`/lgpd-audit`), segredo da connection string fora do código (`/gestao-de-segredos`).

## Saída
Recomendação (tipo de banco + estratégia de escala) **com o critério que a decide** e o que mudaria a escolha; tabela `etapa | estimativa (marcada como hipótese) | risco | como validar`; plano de teste de carga com critério de aceite; e "Não verifiquei:" (ex.: carga real, plano de execução das consultas, limites da hospedagem, custo).
