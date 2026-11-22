---
paths:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/appsettings*.json"
---

# Regras .NET (carregam só ao ler/editar arquivos .NET)

- Camadas: Controller → Application → Domain → Infra; regra de negócio nunca em controller. Projeto novo: skill `arquitetura-onion` (plugin `dotnet`); o CLAUDE.md do projeto prevalece.
- DTO de entrada com `[Required]`/`[MaxLength]`; coleções inicializadas (`= new()`); nomes de query params idênticos ao frontend; `[Route]` é a fonte de verdade para singular/plural.
- `datetime-local` chega sem fuso: converter explicitamente do fuso do negócio para UTC no backend; nunca assumir UTC.
- Swagger/diagnóstico só em `IsDevelopment()`. Bypass de pagamento/2FA para teste só com checagem explícita de ambiente de desenvolvimento no código, nunca só por configuração.
- Mutações de dinheiro, crédito, acesso ou saldo: transição atômica, idempotência (chave única), sem confiar em dado do cliente para dono/tenant.
- Erro de notificação (e-mail, mensagem) depois de persistir: logar, não relançar.
- EF Core com mais de um contexto: sempre `-Context <Nome>`. Coluna real pode divergir da propriedade: consultar `INFORMATION_SCHEMA.COLUMNS` antes de SQL manual. Nunca inserir em `__EFMigrationsHistory` sem executar a DDL.
- MongoDB: nome de campo vem do `[BsonElement]`; id `ObjectId` em hex de 24 dígitos ou `null`, nunca string vazia; `partialFilterExpression` não aceita `$ne` (usar `{campo: {$exists: true, $gt: ""}}`).
- Jobs em background idempotentes: localizar o registro antes de inserir.
- Health check em container Alpine: `127.0.0.1`, não `localhost`.
- Testes xUnit: `<IsTestProject>true</IsTestProject>` e conferir na saída que testes rodaram (build verde pode rodar zero testes).
- Segredos: User Secrets ou variável de ambiente; `appsettings.json` versionado sem segredo.
