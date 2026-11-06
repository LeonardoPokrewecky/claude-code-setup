# Lente: arquitetura

Referência: seção Arquitetura do `CLAUDE.md` do projeto; backend .NET novo também a skill `arquitetura-onion` (plugin `dotnet`); frontend Angular novo, a `arquitetura-angular` (plugin `angular`). O CLAUDE.md do projeto prevalece.

- **Dependências:** referência que aponta para fora (domínio conhecendo infraestrutura, controller acessando repositório/`DbContext`, projetos de mesmo nível se referenciando); ciclo entre módulos.
- **Responsabilidade:** regra de negócio em controller, componente de UI ou script; método que ganhou um segundo comportamento por conveniência em vez de método próprio; classe/serviço "faz-tudo".
- **Acoplamento:** detalhe de framework vazando para o domínio; DTO exposto como entidade (ou o contrário); dependência concreta onde há interface no projeto.
- **Duplicação de decisão:** "caminho rápido" que repete uma regra de domínio (deve ser corrigido junto com o caminho canônico).
- **Consistência:** nomes, pastas e padrão iguais ao restante do projeto; mesma funcionalidade no mesmo caminho em todas as camadas.
- **Manutenibilidade:** abstração sem segundo uso; configuração nova sem lugar definido; mudança estrutural sem registro (`/adr`).

Para cada achado: a regra violada (com a fonte) e o custo de deixar como está.
