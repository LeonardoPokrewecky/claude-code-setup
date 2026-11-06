# Referência: Onion com 9 projetos numerados (.NET 8)

Padrão **default** para projeto .NET novo. O `CLAUDE.md` do projeto pode escolher a variante enxuta do `SKILL.md`; não misturar os dois no mesmo projeto. Projeto existente não migra sem pedido.

Diferenças da variante enxuta do `SKILL.md`: `Domain` e `Infra` têm o mesmo nome e papel nos dois; lá os DTOs ficam em `Contracts` separado (aqui, em `02 Application`), o host HTTP é `<Produto>.Api` (aqui `01 API`), os jobs ficam na Api até separar `Workers` (aqui, `06 Async` desde o início) e não há Desktop, Shared nem Tools. `Contracts` existe nos dois, mas aqui só quando há cliente externo (seção 3).

## 1. Estrutura (ordem e numeração obrigatórias)

```
MinhaSolution/
├── 01-MinhaSistema.API/
├── 02-MinhaSistema.Application/
├── 03-MinhaSistema.Domain/
├── 04-MinhaSistema.Infra/
├── 05-MinhaSistema.Desktop/
├── 06-MinhaSistema.Async/
├── 07-MinhaSistema.Shared/
├── 08-MinhaSistema.Tests/
└── 09-MinhaSistema.Tools/
```

Criar os 9 desde o início (os sem uso ainda ficam como esqueleto que compila, sem código de exemplo, com um `README.md` de uma linha: "Reservado, sem uso ainda."). Não renumerar nem reordenar. A numeração é organização visual e **não** representa a hierarquia de dependências.

## 2. Camadas

| # | Projeto | Finalidade | Dentro | Fora |
|---|---|---|---|---|
| 01 | API | Entrada HTTP | Controllers/endpoints, autenticação/autorização, middlewares, Swagger, `Program.cs` | Regra de negócio, `DbContext`, entidade exposta como contrato |
| 02 | Application | Casos de uso | Commands, Queries, DTOs, validators, behaviors, interfaces (`IPedidoRepository`, `IUnitOfWork`), transação | EF Core, HTTP, UI, invariantes de entidade |
| 03 | Domain | Núcleo do negócio | Entidades, agregados, value objects, enums, eventos e exceções de domínio, serviços de domínio | Qualquer tecnologia (EF, JSON, ASP.NET), DTO, I/O |
| 04 | Infra | Implementações técnicas | EF Core (PostgreSQL/SQL Server/MongoDB), Redis, RabbitMQ, repositórios, integrações, storage, logging, `AddInfra()` | Regra de negócio, casos de uso, controllers |
| 05 | Desktop | UI local | Views, ViewModels, configurações locais; chama casos de uso | Regra no code-behind/ViewModel, acesso direto ao banco |
| 06 | Async | Segundo plano | Workers, consumers/producers, jobs, retry, lote | Regra de negócio no worker (delegar à Application) |
| 07 | Shared | Transversal genérico | `Result<T>`, paginação, `Guard`, extensões, constantes | **Regra de negócio**, classe "sem lugar", dependência pesada |
| 08 | Tests | Qualidade | Unit, Integration, Functional, Architecture | Código de produção, dados reais |
| 09 | Tools | Operação | Importadores, exportadores, diagnóstico, manutenção | Regra própria (reusar Application), credencial embutida |

Shared não pode virar depósito: se pertence a uma camada, vai para ela.

## 3. Regra de dependência

As referências apontam sempre para dentro.

| Projeto | Pode referenciar |
|---|---|
| 01 API | Application, Infra (só composição de DI), Shared |
| 02 Application | Domain, Shared |
| 03 Domain | nenhum projeto, sem pacote de infraestrutura |
| 04 Infra | Application, Domain, Shared |
| 05 Desktop | Application, Infra (só composição), Shared |
| 06 Async | Application, Infra (só composição), Shared |
| 07 Shared | preferencialmente nenhum |
| 08 Tests | os projetos testados |
| 09 Tools | Application, Infra (só composição), Shared |

- A Infra implementa contratos definidos na Application/Domain (Inversão de Dependência).
- API, Desktop, Async e Tools são hosts: referenciam a Infra só para `AddApplication()` / `AddInfra(config)` na raiz de composição.
- Domain exposto por referência transitiva: não usar tipo de Domain em contrato externo (HTTP, UI, mensagem); usar DTO.
- **Teste de arquitetura obrigatório** em `08-…Tests/Architecture` (NetArchTest), falhando o build: valida a tabela acima, Domain sem dependência externa e Shared sem referência a projeto do produto nem regra de negócio. Criar junto com a Solution, não depois.
- **Contracts condicional:** quando um cliente (Desktop, outro serviço) consome a API, os DTOs de entrada/saída saem para `MinhaSistema.Contracts`, sem referência a nada do produto. Fica na pasta `02-application/`, **sem criar número novo** (a numeração 01–09 não muda). API, Application e o cliente o referenciam; o cliente **não** referencia Application nem Infra. Sem cliente externo, os DTOs ficam na Application.

```
01 API ─┐
05 Desktop ┼─> 02 Application ─> 03 Domain
06 Async ─┤        ^
09 Tools ─┘        └── 04 Infra (implementa; hosts só a registram)
07 Shared: transversal    08 Tests: referencia o que testa
```

## 4. Regras obrigatórias

1. Respeitar a numeração dos projetos.
2. Não misturar responsabilidades entre camadas.
3. Sem regra de negócio em Controllers, Workers ou UI.
4. Sem acesso ao banco fora das abstrações e implementações próprias.
5. Sem dependência circular.
6. Não duplicar funcionalidade existente.
7. Reusar os casos de uso da Application em todo canal.
8. Domain independente de tecnologia externa.
9. Testes atualizados.
10. Projeto ou dependência nova só com justificativa técnica (`/adr`).

## 5. Pastas internas (exemplos: criar a subpasta quando houver o primeiro arquivo, sem pasta vazia nem abstração sem uso)

- **Application:** `Abstractions/`, `Behaviors/`, `Features/<Modulo>/{Commands,Queries,DTOs}/`, `DependencyInjection.cs`
- **Domain:** `Aggregates/`, `Entities/`, `ValueObjects/`, `Enums/`, `Events/`, `Exceptions/`, `Services/`
- **Infra:** `Persistence/{Context,Configurations,Repositories,Migrations}/`, `ExternalServices/`, `Messaging/`, `Caching/`, `DependencyInjection.cs`
- **API:** `Controllers/`, `Middlewares/`, `Configurations/`, `Extensions/`, `Program.cs`
- **Async:** `Workers/`, `Consumers/`, `Producers/`, `Jobs/`
- **Tests:** `Unit/`, `Integration/`, `Functional/`, `Architecture/`

## 6. Onde implementar

| Necessidade | Onde |
|---|---|
| Endpoint | API + caso de uso na Application |
| Regra/invariante | Domain |
| Fluxo novo | Application |
| Consulta ao banco | Application (interface) + Infra (implementação) |
| Integração externa | Application (interface) + Infra (adaptador) |
| Fila ou agendamento | Async chamando caso de uso |
| Tela | Desktop chamando caso de uso |
| Script de importação | Tools chamando caso de uso |
| Utilitário genérico sem negócio | Shared |

Princípios: SOLID, baixo acoplamento, alta coesão, Dependency Inversion, separação de responsabilidades, testabilidade. Sem abstração ou padrão sem necessidade.
