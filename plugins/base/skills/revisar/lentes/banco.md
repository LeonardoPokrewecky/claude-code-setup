# Lente: banco de dados (só leitura + plano)

- Migration: reversível? Trava tabela grande (lock)? Ordem com o deploy do código (coluna nova antes do código que a lê)?
- Nome real de coluna/campo (mapeamento EF, `[BsonElement]`, `INFORMATION_SCHEMA.COLUMNS`) igual ao usado em SQL/consulta manual.
- Índice para o novo filtro/ordenação; índice único condicional válido para o banco (ex.: Mongo `partialFilterExpression` não aceita `$ne`).
- Histórico de migrations coerente com o schema (nunca registrar migration sem executar a DDL).
- Vários contextos/bancos: comando com o contexto explícito; bancos de tenant migrados pelo mecanismo da aplicação.
- Dado muda → script de manutenção com backup e canário (`/alterar-dados`), não update escondido em migration.
- Enum/schema: valor novo de enum compatível com dados existentes; convenções de nome do banco (Mongo: coleções, índices).
- Rollback e backup descritos.
