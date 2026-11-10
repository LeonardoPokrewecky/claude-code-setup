---
name: alterar-dados
description: Planeja e executa alteração de dados em banco (update em massa, backfill, correção de legado, varredura multi-tenant) com backup, dry-run e regra canário. Só roda com /alterar-dados <o que mudar e onde>.
disable-model-invocation: true
argument-hint: <o que mudar> [banco/coleção/tabela]
---

Alvo: `$ARGUMENTS`. **Produção ou dados reais só com autorização explícita nesta conversa.** Filtro amplo (`{}`, `$or`, sem id específico) exige confirmação à parte.

## 1. Descoberta (somente leitura)
- Nome real do campo/coluna: `[BsonElement]`/mapeamento EF ou `INFORMATION_SCHEMA.COLUMNS` — nunca o nome da propriedade de cabeça.
- Quem lê/escreve o campo: workers, jobs, cron, telas (Grep). Anotar o ciclo do worker mais lento.
- Contar o universo afetado (query de contagem) e mostrar 3 exemplos antes/depois.

## 2. Script
- **Dry-run por padrão:** só grava com parâmetro explícito (ex.: `--aplicar`); o dry-run imprime contagens e amostras.
- **Idempotente:** rodar duas vezes não muda nada na segunda (localizar o registro antes de inserir; filtrar o que já está no estado final).
- **Regra única:** reaproveitar o mesmo código que o runtime usa para decidir/classificar; nunca reescrever a regra no script.
- Varredura multi-tenant: loop sequencial com `await` (nunca `ForEach(async ...)`), contexto/conexão por tenant descartado ao fim, erro de um tenant logado sem parar os outros, resumo final (tenants, alterados, erros).
- Ignorar filtros globais (soft delete, "ativo") quando a manutenção precisa alcançar todos os registros — e dizer isso no relatório.
- Preferir query traduzível no banco a carregar a tabela inteira na memória.
- Schema muda → migration; dado muda → script/comando de manutenção (não esconder update de dado dentro de migration).

## 3. Execução — regra canário
1. **Backup** dos registros originais (coleção/tabela `<nome>_bkp_<desc>_<AAAAMMDD>` ou dump) e conferir a contagem do backup.
2. Aplicar em **um** registro de baixo risco (`updateOne`/`WHERE id = ...`).
3. Esperar o ciclo do worker mais lento; validar logs, estado e telas.
4. Só então o lote completo. Se houver worker lendo o campo: parar o worker → migrar → validar → religar.
5. Correção em caminho de escrita só cobre registros futuros: avaliar legado e aplicar este fluxo a ele. **Contar as linhas legadas afetadas antes de declarar o defeito resolvido** e conferir a contagem de novo depois.
6. Antes de afirmar que gravou em produção, provar a qual instância/banco o serviço realmente se conecta (base com o mesmo nome em outro servidor pode ser cópia que ninguém lê).

## 4. Relatório
Contagens (universo, alterados, erros), backup criado, canário validado (como), comando de rollback a partir do backup, "Não verifiquei:".
