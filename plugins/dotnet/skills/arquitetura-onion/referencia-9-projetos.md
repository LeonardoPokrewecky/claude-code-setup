# Referência: padrão de 9 projetos numerados com Shared como shared kernel (.NET 8)

Padrão **default** para projeto .NET novo. O `CLAUDE.md` do projeto pode escolher a variante enxuta do `SKILL.md`; não misturar os dois no mesmo projeto. Projeto existente sem esta estrutura não migra sem pedido (seção 8 do `SKILL.md`).

**Atenção ao significado dos nomes.** Aqui o `07 Shared` **não** é um projeto periférico de helpers: é o **shared kernel**, o vocabulário comum de uma solução com vários executáveis (API, workers, agentes, clientes instalados). E o `03 Domain` **não guarda entidades**: é a camada de serviço (regras e orquestração entre entidades). Quem conhece a Onion/Clean clássica (Domain no centro, com as entidades) deve ler esta página com esse cuidado.

Diferenças da variante enxuta do `SKILL.md`: entidades, enums e DTOs ficam no Shared (lá: `Domain` e `Contracts`); a interface de repositório fica na Infra (lá: no `Domain`); o host HTTP é `01 API`; os jobs ficam em `06 Async` desde o início (lá: na Api até separar `Workers`); há Desktop, Shared e Tools. Não existe `Contracts` separado: o Shared cumpre esse papel.

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
| 01 | API | Entrada HTTP | Controllers/endpoints, autenticação/autorização, middlewares, Swagger (só em desenvolvimento), `Program.cs` | Regra de negócio, `DbContext`, entidade devolvida como resposta |
| 02 | Application | Casos de uso | Casos de uso (app services), validação de entrada, transação, mappers entidade ↔ View, specifications de filtro/ordenação | EF Core, HTTP, UI, invariantes de entidade |
| 03 | Domain | Serviços de domínio | Regras e orquestração que envolvem mais de uma entidade; usa as interfaces de repositório da Infra | Entidade, DTO, tecnologia de I/O, regra em classe utilitária |
| 04 | Infra | Implementações técnicas | **Interfaces e implementações de repositório**, `IUnitOfWork`, mapeamento de persistência (`IEntityTypeConfiguration`/`BsonClassMap`), contexto de banco, Redis, mensageria, integrações, storage, assinatura e validação de token, `AddInfra()` | Regra de negócio, casos de uso, controllers, referência a Domain ou Application |
| 05 | Desktop | UI local | Views, ViewModels, configurações locais; chama casos de uso | Regra no code-behind/ViewModel, acesso direto ao banco |
| 06 | Async | Segundo plano | Workers, consumers/producers, jobs, retry, lote | Regra de negócio no worker (delegar à Application) |
| 07 | Shared | Shared kernel | Entidades, enums, value objects; DTOs (Request, Response, View); objetos de filtro e ordenação (descrevem a consulta, não a executam); configuração (options), abstrações de log/cache, `Result<T>`, `PagedResult<T>`, `Guard`, constantes, tipos e constantes de claims | Regra que envolve mais de uma entidade, orquestração, segurança (assinatura/segredos), atributo de ORM ou de driver, pacote pesado (seção 5) |
| 08 | Tests | Qualidade | Unit, Integration, Functional, Architecture | Código de produção, dados reais |
| 09 | Tools | Operação | Importadores, exportadores, diagnóstico, manutenção | Regra própria (reusar Application), credencial embutida |

Mudança no Shared afeta todos os consumidores (API, workers, agentes, clientes): alterar com critério. Tipo usado por mais de uma camada ou processo nasce no Shared.

## 3. Regra de dependência

Ordem das camadas: **api → application → domain → infra**, e todas referenciam o Shared.

| Projeto | Pode referenciar |
|---|---|
| 01 API | Application, Infra (só composição de DI), Shared |
| 02 Application | Domain, Shared |
| 03 Domain | Infra, Shared |
| 04 Infra | Shared |
| 05 Desktop | Application, Infra (só composição), Shared |
| 06 Async | Application, Infra (só composição), Shared |
| 07 Shared | **nenhum projeto** |
| 08 Tests | os projetos testados |
| 09 Tools | Application, Infra (só composição), Shared |

```
01 API ─┐
05 Desktop ┼─> 02 Application ─> 03 Domain ─> 04 Infra ─> 07 Shared
06 Async ─┤        (todos os projetos também referenciam 07 Shared)
09 Tools ─┘
08 Tests: referencia o que testa
```

- API, Desktop, Async e Tools são hosts: referenciam a Infra só para `AddApplication()` / `AddInfra(config)` na raiz de composição.
- A Application enxerga as **interfaces** de repositório (tipos da Infra) por referência transitiva. Pode usá-las; **não** usa implementação de repositório, `DbContext`, cliente de driver nem tipo de integração. Como a referência transitiva libera tudo, a regra é validada por **tipo/namespace** no teste de arquitetura, não só por referência de projeto.
- A Infra não referencia Domain nem Application: devolve tipos do Shared. O que precisar de regra sobe para o Domain.
- Dependência circular: resolver com genéricos ou movendo o tipo para o Shared, nunca referenciando a camada de cima.
- Entidade nunca é devolvida em controller: a resposta é `View`/`Response` do Shared.
- **Teste de arquitetura obrigatório** em `08-…Tests/Architecture` (NetArchTest), falhando o build. Criar junto com a Solution, não depois. Valida:
  1. a tabela acima (referências entre projetos);
  2. Shared sem nenhuma `ProjectReference`;
  3. Shared só com pacotes da lista permitida (seção 5);
  4. Shared sem atributo de ORM ou de driver (`[Bson*]`, `[Table]`, `[Key]`, `[Column]`, `[ForeignKey]`);
  5. Application sem uso de implementação de repositório, `DbContext` ou driver (tipos da Infra fora de `Repositories.Interfaces`);
  6. Infra sem referência a Domain nem Application;
  7. Controllers sem acesso a repositório nem `DbContext`.

## 4. Regras obrigatórias

1. Respeitar a numeração dos projetos.
2. Não misturar responsabilidades entre camadas.
3. Sem regra de negócio em Controllers, Workers, UI nem classes utilitárias (`Utils`, `Helpers`).
4. Sem acesso ao banco fora das abstrações e implementações da Infra.
5. Sem dependência circular.
6. Não duplicar funcionalidade existente.
7. Reusar os casos de uso da Application em todo canal.
8. Entidade no Shared sem atributo de ORM ou de driver: o mapeamento de persistência fica na Infra. Entidade protege o **próprio estado** (setters privados, métodos com invariantes); regra entre entidades fica no Domain.
9. Testes atualizados.
10. Projeto ou dependência nova só com justificativa técnica (`/adr`).

## 5. Shared enxuto e segurança fora do Shared

O Shared é distribuído a todos os executáveis, inclusive clientes instalados. Por isso:

- **Lista permitida de pacotes** (registrada e verificada no teste de arquitetura): abstrações (`Microsoft.Extensions.*.Abstractions`), `System.Text.Json`, `System.ComponentModel.Annotations` e similares sem I/O. Proibidos: EF Core, driver de banco (`MongoDB.Driver`, `Npgsql`), Redis, SDK de nuvem, navegador headless, OCR, biblioteca de PDF, framework web. Pacote fora da lista vai para a Infra; ampliar a lista exige `/adr`.
- **Segurança fora do Shared:** no Shared ficam só constantes e tipos de claims (nomes de política, de claim, de perfil). Assinatura e validação de token, hash de senha, criptografia e leitura de segredos ficam na Infra (e o middleware de autenticação na API). Segredo nunca no assembly distribuído a cliente.
- Nenhum arquivo `appsettings*.json` real no Shared; o Shared define só as classes de options.

## 6. Pastas internas (exemplos: criar a subpasta quando houver o primeiro arquivo, sem pasta vazia nem abstração sem uso)

- **Shared:** `Entities/<Modulo>/`, `Enums/`, `ValueObjects/`, `Dto/<Modulo>/` (`<X>Request`, `<X>View`, `<X>Response`), `Filters/` (`<X>Filter`, ordenação), `Common/` (`EntityBase`, `PagedResult`, `Result`, `Guard`), `Configuration/` (options), `Claims/`
- **Domain:** `Services/<Modulo>/`, `Exceptions/`, `DependencyInjection.cs`
- **Application:** `<Modulo>/<X>/` (`I<X>AppService`, `<X>AppService`, `<X>Mapper`, `<X>Specification`), `DependencyInjection.cs`
- **Infra:** `Persistence/{Context,Configurations,Migrations}/`, `Repositories/Interfaces/`, `Repositories/`, `Security/` (assinatura/validação de token), `ExternalServices/`, `Messaging/`, `Caching/`, `DependencyInjection.cs`
- **API:** `Controllers/`, `Middlewares/`, `Configurations/`, `Extensions/`, `Program.cs`
- **Async:** `Workers/`, `Consumers/`, `Producers/`, `Jobs/`
- **Tests:** `Unit/`, `Integration/`, `Functional/`, `Architecture/`

## 7. Onde implementar

| Necessidade | Onde |
|---|---|
| Endpoint | API + caso de uso na Application |
| Entidade, enum, value object | Shared |
| Invariante do próprio estado da entidade | Método da entidade (Shared) |
| Regra entre mais de uma entidade | Domain (serviço de domínio) |
| Fluxo novo | Application |
| DTO (Request, View, Filter) | Shared |
| Consulta ao banco | Interface e implementação de repositório na Infra |
| Mapeamento de persistência | Infra |
| Integração externa | Infra (adaptador) |
| Assinatura/validação de token, criptografia | Infra (middleware na API) |
| Fila ou agendamento | Async chamando caso de uso |
| Tela | Desktop chamando caso de uso |
| Script de importação | Tools chamando caso de uso |
| Utilitário genérico sem negócio | Shared (`Common`) |

Princípios: SOLID, baixo acoplamento, alta coesão, separação de responsabilidades, testabilidade. Sem abstração ou padrão sem necessidade.

## 8. Cuidados de quem trabalha neste padrão

- Mudança no Shared afeta todos os consumidores: avaliar o impacto em cada executável.
- Regra de negócio fica no Domain (serviços), não em `Utils`.
- Se surgir tipo que duas camadas precisam, ele nasce no Shared; não criar referência para cima.
