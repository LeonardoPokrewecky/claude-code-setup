# Arquitetura onion (.NET): detalhes

Complemento do [`SKILL.md`](SKILL.md): as seções 5 a 7 e 9 mantêm a numeração original.

### Dentro de cada projeto: o mesmo caminho em todos

Toda funcionalidade fica em `<Modulo>/<X>/` em **todos** os projetos, com o mesmo nome de módulo. Assim, uma busca pela pasta ou pelo namespace encontra as peças de uma vez.

> O bloco abaixo é da **variante enxuta** (`Domain` + `Contracts`, `Infra/Data/...`). Na estrutura padrão (`01-api` … `07-shared`), os caminhos internos estão em `referencia-estrutura.md`, seção 4.

```
<Produto>.Domain/Common/                     EntityBase.cs, IUnitOfWork.cs, DomainException.cs
<Produto>.Domain/<Modulo>/<X>/               <X>.cs, I<X>Repository.cs, E<X>Status.cs
<Produto>.Contracts/Common/                PagedResult.cs
<Produto>.Contracts/<Modulo>/<X>/          <X>Request.cs, <X>View.cs, <X>Filter.cs, E<X>Status.cs
<Produto>.Application/<Modulo>/<X>/        I<X>AppService.cs, <X>AppService.cs, <X>Mapper.cs, <X>Specification.cs
<Produto>.Application/DependencyInjection.cs
<Produto>.Infra/Data/Context/              <Produto>DbContext.cs, ContextFactory.cs
<Produto>.Infra/Data/Migrations/
<Produto>.Infra/Data/<Modulo>/<X>/         <X>Configuration.cs, <X>Repository.cs
<Produto>.Infra/Data/Common/               Repository.cs, UnitOfWork.cs
<Produto>.Infra/DependencyInjection.cs
<Produto>.Api/Controllers/<Modulo>/        <X>Controller.cs
```

Cada projeto expõe **um** método de registro (`AddApplication()`, `AddInfra(config)`; depois de separar, `AddInfraData<Banco>(config)` etc.), chamado pelo host que precisa dele.

## 5. Convenções de nome

- **Sufixos técnicos em inglês:**

  | Sufixo | Peça |
  |---|---|
  | `<X>AppService` | caso de uso |
  | `<X>QueryService` / `<X>CommandService` | caso de uso dividido (seção 6) |
  | `<X>Repository` | repositório |
  | `<X>Configuration` | configuração EF (`IEntityTypeConfiguration`) |
  | `<X>Mapper` | conversão entidade ↔ contrato |
  | `<X>Specification` | filtro/ordenação |
  | `<X>Request` | entrada |
  | `<X>View` | saída |
  | `<X>Filter` | parâmetros de grade |
  | `<X>Job` | job |
  | `<X>Client` | integração |

  Tipos base também em inglês: `EntityBase`, `PagedResult<T>`, `DomainException`. Enums com prefixo `E`.
- **Nomes de negócio na língua do domínio** (`Pedido`, `Cadastros`, `Cancelar()`): é a linguagem que o usuário e o código compartilham.
- A interface tem o nome exato da classe com `I` na frente (`IPedidoAppService` ↔ `PedidoAppService`).
- Rota explícita e em minúsculas: `[Route("api/<recurso>")]`. Os nomes dos parâmetros são idênticos aos do frontend.

## 6. Responsabilidade de cada peça

- **Teste rápido da camada:** se a regra continua verdadeira trocando o banco e a interface, ela é de domínio; se muda com o banco, é de `Infra`; se só ordena passos de um fluxo, é de `Application`.
- **Leitura e escrita separadas (opcional):** quando a consulta de leitura começa a distorcer o modelo de escrita, separar: escrita normalizada com invariantes, leitura desnormalizada/projetada para a grade (`<X>QueryService`). Não adotar por antecipação.
- **Entidade (Domain na enxuta; Shared no padrão numerado):** protege o próprio estado. Mudança de estado por método com validação (`pedido.Cancelar(motivo)`), sem `set` público. Regra que envolve uma única entidade fica nela, não no app service. Regra que envolve mais de uma entidade: serviço de domínio (`Domain` no padrão numerado). No padrão numerado, a entidade não leva atributo de ORM nem de driver (`[Bson*]`, `[Table]`, `[Key]`, `[Column]`).
- **App service (Application):** um caso de uso por método. Valida a entrada, carrega as entidades pelo repositório, chama os métodos de domínio, faz `IUnitOfWork.CommitAsync` e devolve o contrato. Repositório não comita.
- **Tamanho:** passou de ~7 métodos públicos ou ~300 linhas, dividir:
  - `<X>QueryService` para leitura e grade;
  - `<X>CommandService` para alterações;
  - caso de uso complexo (muitos passos ou dependências próprias) ganha classe própria `<Acao><X>AppService`.
- **Composição, não herança:** acima de ~5 dependências no construtor, extrair um serviço menor e injetar. Classe base genérica (`CrudAppService<TEntidade, TView, TRequest>`) só para CRUD puro. Comportamento de família vai em serviço compartilhado injetado, nunca em base abstrata com dezenas de dependências.
- **Mapper:** explícito e verificável pelo compilador. Pode ser à mão (`<X>Mapper` com `ToView()` e `ToEntity()`, mais uma `Expression<Func<X, XView>>` para projeção) ou com gerador de código de licença livre (ex.: Mapperly). Biblioteca de mapeamento com licença comercial só com decisão registrada via `/adr`.
- **Enum exposto ao cliente:** no **padrão numerado**, existe **um só** enum, no Shared, usado por entidade e por DTO (sem conversão nem teste de par). Na **variante enxuta**, existe no Domain (domínio) e no Contracts (API), com conversão explícita no `<X>Mapper`; um teste percorre `Enum.GetValues` dos dois lados e falha se algum valor não tiver par. Enum que o cliente não vê fica só no Domain.
- **Repositório (Infra):** implementa a interface (que mora no `Domain` na enxuta e na própria `Infra` no padrão numerado); leitura com `AsNoTracking`. Recebe specification e projeção e devolve entidade ou `PagedResult<TView>` já materializado. **Não expõe `IQueryable`** para fora da Infra. Implementação `internal`.
- **Configuração EF:** um `<X>Configuration : IEntityTypeConfiguration<X>` por entidade. Migration sempre com `-Context <NomeDoContext>`.
- **Controller (Api):** fino. `[ApiController]` + `[Authorize]` na classe e `[Authorize(Policy = "<recurso>.<acao>")]` em cada action. Recebe o contrato, chama **um** método de app service e devolve o contrato.
- **Notificação após persistir** (e-mail, mensagem): falha é logada, nunca relançada. Envio crítico usa outbox.
- **Job/Integração:** job idempotente (procura o registro existente antes de inserir). O cliente de integração traduz o payload externo para tipos do Domain e nunca vaza DTO externo para dentro.

## 7. Filtros, ordenação e injeção de dependência

**Filtros e ordenação de grade (tipados):**
- `<X>Filter` (Contracts na enxuta; Shared no padrão numerado): propriedades tipadas (`string? Nome`, `DateOnly? De`, `E<X>Status? Status`) + `Page`, `PageSize`, `SortBy`, `SortDirection`.
- `<X>Specification` (Application):
  - converte o filtro em `Expression<Func<X, bool>>`, combinando só os campos preenchidos;
  - ordenação por **lista branca**: `Dictionary<string, Expression<Func<X, object>>>`, com coluna padrão quando o nome é desconhecido.
- Proibido: expressão montada como string (Dynamic LINQ) e qualquer nome de coluna vindo do cliente sem passar pela lista branca.
- Coluna nova na grade = propriedade no `<X>Filter` + entrada na specification. O compilador acusa renomeação.

**Injeção de dependência:**
- Registro explícito em cada `DependencyInjection.cs`, ou por convenção (ex.: Scrutor por sufixo) quando houver muitos serviços. Tempo de vida decidido por tipo: `DbContext`/repositório/unit of work `Scoped`, cliente HTTP via `IHttpClientFactory`.
- `ValidateOnBuild = true` e `ValidateScopes = true` no host.
- Configuração tipada (`IOptions<T>`) com `ValidateDataAnnotations().ValidateOnStart()`: sem o registro, o objeto chega com valores padrão e **sem erro** (em validação de credencial, recusa qualquer valor, inclusive o correto).
- Dado da requisição (usuário atual, tenant) resolvido do escopo da requisição em curso; um escopo criado à mão (`CreateScope`) devolve **outra** instância, vazia. Dependência `Scoped` dentro de `Singleton` prende um escopo morto.
- Teste obrigatório que monta o container e resolve todos os controllers, jobs e app services. Serviço sem registro falha no build de testes, não em produção.


## 9. Fatia vertical de uma funcionalidade nova (checklist)

1. Entidade com métodos de domínio (e enum) em `Domain/<Modulo>/<X>/` na enxuta, ou em `Shared/Entities/<Modulo>/` no padrão numerado; `I<X>Repository` no `Domain` (enxuta) ou em `Infra/Repositories/Interfaces/` (padrão numerado).
2. `<X>Configuration` (mapeamento de persistência) em `Infra/Data/<Modulo>/<X>/` (enxuta) ou `Infra/Persistence/Configurations/` (padrão numerado).
3. Migration com `-Context` (gerar; aplicar só com autorização).
4. `<X>Repository` (`internal`) implementando a interface.
5. `<X>Request` (`[Required]`/`[MaxLength]`), `<X>View`, `<X>Filter` em `Contracts/<Modulo>/<X>/` (enxuta) ou `Shared/Dto/<Modulo>/` e `Shared/Filters/` (padrão numerado).
6. `<X>Mapper` + `<X>Specification` em `Application/<Modulo>/<X>/`.
7. `I<X>AppService` + `<X>AppService` (ou Query/Command, se já nascer grande).
8. `<X>Controller` com rota e políticas; política nova cadastrada onde o projeto registra permissões.
9. Testes:
   - unitários da entidade (regras) e do app service (com fakes das interfaces);
   - integração do repositório (banco real de teste);
   - paridade de enums, se houver enum exposto;
   - os testes de arquitetura e de DI continuam verdes.
10. Build sem erros + chamada real da rota.

