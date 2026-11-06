---
name: arquitetura-onion
description: Padrão de arquitetura onion para backend .NET — projetos por camada (começa enxuto, separa por demanda), regra de dependência testada, convenções de nome, filtros tipados e a fatia vertical de uma funcionalidade (entidade → configuração EF → repositório → contrato → caso de uso → controller). Use ao criar projeto .NET novo, adicionar módulo/funcionalidade de backend ou revisar onde um código deve ficar.
---

# Arquitetura onion (.NET)

- **Projeto novo:** nasce neste padrão, com o conjunto mínimo de projetos.
- **Projeto existente:** o `CLAUDE.md` do projeto prevalece. Ver seção 8.

## 1. Projetos: começar enxuto

| Projeto | Contém | Referencia |
|---|---|---|
| `<Produto>.Core` | Entidades **com comportamento** (invariantes nos métodos, setters privados), value objects, enums de domínio, exceções de domínio, **interfaces** de repositório, `IUnitOfWork` e portas externas (`IEmailSender`, `IFileStorage`, `I<Sistema>Client`) | nada |
| `<Produto>.Contracts` | DTOs da API: `<X>Request`, `<X>View`, `<X>Filter`, `PagedResult<T>`, enums expostos ao cliente | nada |
| `<Produto>.Application` | Casos de uso, mappers entidade ↔ contrato, specifications de filtro/ordenação, validação de entrada, transação | Core, Contracts |
| `<Produto>.Infra` | Implementações do Core por pasta: `Data/` (`DbContext`, configurações EF, migrations, repositórios, `UnitOfWork`), `Email/`, `Storage/`, `Integrations/<Sistema>/` | Core |
| `<Produto>.Api` | Host HTTP: controllers, autenticação/políticas, middlewares, `Program.cs` (composition root), jobs em `BackgroundService` enquanto rodarem no mesmo processo | Application, Contracts, Infra (só para registrar) |
| Testes | `<Produto>.Core.Tests`, `<Produto>.Application.Tests`, `<Produto>.Infra.Tests`, `<Produto>.Architecture.Tests` | o projeto testado |

## 2. Separar por demanda

Projeto novo só com motivo concreto, registrado em uma linha via `/adr`:

| Motivo | Separação |
|---|---|
| Segundo banco/contexto, ou banco com ciclo de migration próprio | `Infra.Data.<Banco>` |
| Dependência pesada que outro host não deve carregar (SDK de nuvem, cliente SOAP, navegador headless) | `Infra.<Recurso>` ou `Integrations.<Sistema>` |
| Job que precisa escalar, cair ou ser publicado sem a API | Host `<Produto>.Workers` (os jobs saem da Api) |
| Cliente (desktop, outro serviço) que consome os contratos | Ele referencia **só** `Contracts` (já separado desde o início) |

Ao separar, a regra de dependência da seção 3 continua valendo e o `Architecture.Tests` ganha a regra do projeto novo **no mesmo commit**. Pasta que ficou pequena demais não vira projeto.

## 3. Regra de dependência

As referências apontam sempre para dentro.
- `Core` e `Contracts` não referenciam nada do produto. `Core` não conhece DTO, e `Contracts` não conhece entidade.
- `Application` não referencia EF Core nem `Infra*`: acessa dados só pelas interfaces do Core.
- Controllers não acessam repositório nem `DbContext`.
- Projetos de mesmo nível não se referenciam (`Infra.Data.A` ↔ `Infra.Data.B`, `Integrations.A` ↔ `Integrations.B`). O que for comum sobe para o Core.
- `Workers` chama casos de uso da `Application` e não tem regra de negócio própria.
- A regra vale por **teste**: `<Produto>.Architecture.Tests` (ex.: NetArchTest) falha se aparecer uma referência proibida.

## 4. Pastas

### Solução: pastas numeradas por camada

```
<repo>/
├── <Produto>.slnx
├── src/
│   ├── 01-api/            <Produto>.Api/
│   ├── 02-application/    <Produto>.Application/
│   ├── 03-core/           <Produto>.Core/, <Produto>.Contracts/
│   ├── 04-infra/          <Produto>.Infra/ (e Infra.Data.<Banco>/, Integrations.<Sistema>/ quando separar)
│   ├── 05-workers/        <Produto>.Workers/ (só quando separar)
│   └── 06-clients/        desktop e outros clientes dos contratos
├── tests/                 <Produto>.Core.Tests/, ..., <Produto>.Architecture.Tests/
└── tools/                 scripts e utilitários de desenvolvimento
```

- A numeração mantém a ordem fixa no Explorer e no IDE: do host para o centro, depois os consumidores.
- Nome da pasta: `NN-camada`, minúsculo, sem espaço (espaço exige aspas em CLI, Docker, CI e scripts de deploy).
- `src/` só tem código que vai para produção; testes em `tests/` e utilitários em `tools/`, na raiz.
- **Pasta física = pasta da solution** (mesma árvore no Explorer e no `.slnx`). Cada projeto fica na sua própria pasta, com o nome do projeto.
- A pasta numerada só existe quando tem projeto: buraco na numeração é normal (sem `05-workers` enquanto os jobs rodam na Api). Os números não mudam quando uma pasta nasce.

### Dentro de cada projeto: o mesmo caminho em todos

Toda funcionalidade fica em `<Modulo>/<X>/` em **todos** os projetos, com o mesmo nome de módulo. Assim, uma busca pela pasta ou pelo namespace encontra as peças de uma vez.

```
<Produto>.Core/Common/                     EntityBase.cs, IUnitOfWork.cs, DomainException.cs
<Produto>.Core/<Modulo>/<X>/               <X>.cs, I<X>Repository.cs, E<X>Status.cs
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

- **Entidade (Core):** protege o próprio estado. Mudança de estado por método com validação (`pedido.Cancelar(motivo)`), sem `set` público. Regra que envolve uma única entidade fica nela, não no app service.
- **App service (Application):** um caso de uso por método. Valida a entrada, carrega as entidades pelo repositório, chama os métodos de domínio, faz `IUnitOfWork.CommitAsync` e devolve o contrato. Repositório não comita.
- **Tamanho:** passou de ~7 métodos públicos ou ~300 linhas, dividir:
  - `<X>QueryService` para leitura e grade;
  - `<X>CommandService` para alterações;
  - caso de uso complexo (muitos passos ou dependências próprias) ganha classe própria `<Acao><X>AppService`.
- **Composição, não herança:** acima de ~5 dependências no construtor, extrair um serviço menor e injetar. Classe base genérica (`CrudAppService<TEntidade, TView, TRequest>`) só para CRUD puro. Comportamento de família vai em serviço compartilhado injetado, nunca em base abstrata com dezenas de dependências.
- **Mapper:** explícito e verificável pelo compilador. Pode ser à mão (`<X>Mapper` com `ToView()` e `ToEntity()`, mais uma `Expression<Func<X, XView>>` para projeção) ou com gerador de código de licença livre (ex.: Mapperly). Biblioteca de mapeamento com licença comercial só com decisão registrada via `/adr`.
- **Enum exposto ao cliente:** existe no Core (domínio) e no Contracts (API), com conversão explícita no `<X>Mapper`. Um teste percorre `Enum.GetValues` dos dois lados e falha se algum valor não tiver par. Enum que o cliente não vê fica só no Core.
- **Repositório (Infra):** implementa a interface do Core; leitura com `AsNoTracking`. Recebe specification e projeção e devolve entidade ou `PagedResult<TView>` já materializado. **Não expõe `IQueryable`** para fora da Infra. Implementação `internal`.
- **Configuração EF:** um `<X>Configuration : IEntityTypeConfiguration<X>` por entidade. Migration sempre com `-Context <NomeDoContext>`.
- **Controller (Api):** fino. `[ApiController]` + `[Authorize]` na classe e `[Authorize(Policy = "<recurso>.<acao>")]` em cada action. Recebe o contrato, chama **um** método de app service e devolve o contrato.
- **Notificação após persistir** (e-mail, mensagem): falha é logada, nunca relançada. Envio crítico usa outbox.
- **Job/Integração:** job idempotente (procura o registro existente antes de inserir). O cliente de integração traduz o payload externo para tipos do Core e nunca vaza DTO externo para dentro.

## 7. Filtros, ordenação e injeção de dependência

**Filtros e ordenação de grade (tipados):**
- `<X>Filter` (Contracts): propriedades tipadas (`string? Nome`, `DateOnly? De`, `E<X>Status? Status`) + `Page`, `PageSize`, `SortBy`, `SortDirection`.
- `<X>Specification` (Application):
  - converte o filtro em `Expression<Func<X, bool>>`, combinando só os campos preenchidos;
  - ordenação por **lista branca**: `Dictionary<string, Expression<Func<X, object>>>`, com coluna padrão quando o nome é desconhecido.
- Proibido: expressão montada como string (Dynamic LINQ) e qualquer nome de coluna vindo do cliente sem passar pela lista branca.
- Coluna nova na grade = propriedade no `<X>Filter` + entrada na specification. O compilador acusa renomeação.

**Injeção de dependência:**
- Registro explícito em cada `DependencyInjection.cs`, ou por convenção (ex.: Scrutor por sufixo) quando houver muitos serviços. Tempo de vida decidido por tipo: `DbContext`/repositório/unit of work `Scoped`, cliente HTTP via `IHttpClientFactory`.
- `ValidateOnBuild = true` e `ValidateScopes = true` no host.
- Teste obrigatório que monta o container e resolve todos os controllers, jobs e app services. Serviço sem registro falha no build de testes, não em produção.

## 8. Projeto existente fora deste padrão

- Seguir o padrão que o projeto já usa no módulo em questão; registrar as divergências na seção Arquitetura do `CLAUDE.md` do projeto.
- Melhorias deste padrão entram **só em código novo** e só com OK do usuário (ex.: filtro tipado num módulo novo, teste de DI). Nunca mover projetos, pastas, namespaces ou renomear sufixos em massa sem pedido. Adotar as pastas numeradas num projeto existente quebra caminhos de deploy, CI, Dockerfile e scripts: só com plano que liste e atualize cada um.
- Migração estrutural: propor com `/plano-migracao`, módulo a módulo.

## 9. Fatia vertical de uma funcionalidade nova (checklist)

1. Entidade com métodos de domínio + `I<X>Repository` em `Core/<Modulo>/<X>/`.
2. `<X>Configuration` em `Infra/Data/<Modulo>/<X>/`.
3. Migration com `-Context` (gerar; aplicar só com autorização).
4. `<X>Repository` (`internal`) implementando a interface.
5. `<X>Request` (`[Required]`/`[MaxLength]`), `<X>View`, `<X>Filter` em `Contracts/<Modulo>/<X>/`.
6. `<X>Mapper` + `<X>Specification` em `Application/<Modulo>/<X>/`.
7. `I<X>AppService` + `<X>AppService` (ou Query/Command, se já nascer grande).
8. `<X>Controller` com rota e políticas; política nova cadastrada onde o projeto registra permissões.
9. Testes:
   - unitários da entidade (regras) e do app service (com fakes das interfaces);
   - integração do repositório (banco real de teste);
   - paridade de enums, se houver enum exposto;
   - os testes de arquitetura e de DI continuam verdes.
10. Build sem erros + chamada real da rota.

## 10. Ao revisar

Apontar `arquivo:linha` e a camada correta quando aparecer:
- regra no controller;
- EF Core ou `IQueryable` na Application;
- entidade com `set` público mudando estado de fora;
- filtro em string;
- base abstrata acumulando dependências;
- app service acima do limite da seção 6;
- projeto separado sem motivo da seção 2;
- projeto na pasta numerada errada, pasta com espaço ou teste dentro de `src/`;
- worker com regra de negócio própria.
