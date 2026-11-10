# Lente: banco de dados (só leitura + plano)

- Migration: reversível? Trava tabela grande (lock)? Ordem com o deploy do código (coluna nova antes do código que a lê)?
- Nome real de coluna/campo (mapeamento EF, `[BsonElement]`, `INFORMATION_SCHEMA.COLUMNS`) igual ao usado em SQL/consulta manual.
- Índice para o novo filtro/ordenação; índice único condicional válido para o banco (ex.: Mongo `partialFilterExpression` não aceita `$ne`).
- Índice único em campo **opcional** precisa de filtro parcial (`WHERE campo IS NOT NULL`; Mongo: condição de tipo, pois existência também casa com nulo); senão dois registros sem o campo colidem.
- Número sequencial único (protocolo, documento fiscal) só é garantido por índice único **no banco**: lock em memória não protege várias instâncias nem sobrevive a reinício.
- Série temporal: montar a grade de datas do período e preencher com zero o que não tem registro; agrupar só o que existe junta datas distantes.
- Busca por texto do usuário: normalizar acento, caixa e separadores; nunca regex crua montada com o texto.
- Varredura em muitas bases: liberar o pool de cada base ao terminar (um pool ocioso por base esgota o limite do servidor).
- Correção de código cobre só gravações futuras: contar as linhas legadas afetadas **antes** de declarar o defeito resolvido.
- Histórico de migrations coerente com o schema (nunca registrar migration sem executar a DDL).
- Vários contextos/bancos: comando com o contexto explícito; bancos de tenant migrados pelo mecanismo da aplicação.
- Dado muda → script de manutenção com backup e canário (`/alterar-dados`), não update escondido em migration.
- Enum/schema: valor novo de enum compatível com dados existentes; convenções de nome do banco (Mongo: coleções, índices).
- Rollback e backup descritos.
