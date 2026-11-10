---
name: modelagem-dados
description: Modelagem de dados para relacional ou documental (entidades, relacionamentos, chaves, índices a partir das consultas, tipos, integridade, histórico/auditoria, dados pessoais e LGPD) com migração segura. Somente leitura e proposta; criar ou alterar esquema só com autorização. Só roda com /modelagem-dados [funcionalidade ou caminho].
disable-model-invocation: true
argument-hint: "[funcionalidade ou caminho do repo]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar a funcionalidade). **Somente leitura e proposta.** Nunca ler `.env` nem exibir connection string; nunca acessar banco de produção nem dado real. Criar tabela/coleção, migration ou alterar esquema existente: plano + backup + aprovação antes (`/plano-migracao` para mudança em banco com dados). Escolha do tipo de banco e carga: `/escolha-de-banco-e-capacidade`. Recomendar sessão Opus se a atual for mais fraca.

## 1. Levantar (perguntar o que faltar, não supor)
Entidades e regras de negócio, **consultas reais** (as 5 a 10 mais frequentes e as mais pesadas), volume e crescimento, leitura × escrita, necessidade de histórico/auditoria, dado pessoal ou sensível, multi-tenant, o que já existe no código (Grep por entidades, `DbContext`, migrations, esquemas).

## 2. Modelar
**Relacional**
- Entidades, relacionamentos (1:N, N:N com tabela de associação), chaves primárias e estrangeiras, restrições (`NOT NULL`, `UNIQUE`, `CHECK`), normalização até onde a leitura permite; desnormalizar só com consulta medida.
- Tipos corretos: dinheiro em `decimal`/`numeric` (nunca ponto flutuante), datas em UTC, enum controlado, identificador (sequencial × GUID/UUID: custo de índice e exposição), texto com tamanho definido.
- Concorrência: coluna de versão/token otimista onde houver disputa; evitar linha quente (saldo, contador); operação com efeito idempotente.
- Exclusão: lógica (marca + data) × física; cascata só quando intencional; compatível com LGPD (eliminação/anonimização).

**Documental**
- Embutir o que é lido junto e tem vida própria curta; referenciar o que é compartilhado ou cresce sem limite (documento tem teto de tamanho).
- Desenhar pelo **padrão de acesso**; esquema versionado (campo de versão) e validação; índices para filtros e ordenações reais.
- Transação multi-documento e relatório relacional são mais difíceis: não usar para saldo/lançamento sem análise.

## 3. Índices (derivar das consultas)
Um índice por consulta importante, nunca "por garantia": chave de filtro, ordenação e junção; composto com a coluna mais seletiva/igualdade primeiro; índice parcial/cobertura quando fizer sentido; `UNIQUE` para regra de negócio. Cada índice custa escrita e espaço. Validar com plano de execução (`EXPLAIN`) em volume realista (`/medir-antes-depois`).

## 4. Dados pessoais e segurança (LGPD)
Classificar cada campo (pessoal, sensível, financeiro), minimizar o que é coletado, definir retenção e eliminação, criptografia de dado sensível em repouso (ver `/gestao-de-segredos`), mascaramento em logs e em ambientes de teste, auditoria de acesso a dado pessoal, usuário da aplicação com menor privilégio (sem DDL em produção). Ver `/lgpd-audit`.

## 5. Histórico e auditoria
Quando exigido: tabela de histórico ou registro de eventos imutável (quem, quando, o que mudou), sem guardar senha nem dado excessivo; carimbos `criado_em`/`atualizado_em` em UTC.

## 6. Migração segura
Mudança compatível em etapas (expandir → migrar dados → trocar a aplicação → contrair); migration **idempotente**, com reversão testada e backup restaurável antes; coluna `NOT NULL` nova com valor padrão ou em fases; índice grande criado sem bloquear a tabela quando o banco permitir; nunca rodar em produção sem ensaio em cópia anonimizada. Dados em massa: `/alterar-dados`.

## 7. Testes a exigir
Migration sobe e desce; restrições rejeitam dado inválido; consulta crítica usa o índice esperado; concorrência (duas escritas na mesma linha); integridade referencial; carga sintética do volume esperado; banco real de teste (contêiner) em vez de simulação quando a regra depende do banco.

## Saída
Esquema proposto (diagrama em texto ou tabela `entidade | campos | chaves | índices | observação`), consulta → índice, decisões com alternativas e o critério de escolha, riscos (concorrência, volume, LGPD) e "Não verifiquei:" (ex.: volume real, plano de execução no ambiente real, dados existentes, regras não informadas).
