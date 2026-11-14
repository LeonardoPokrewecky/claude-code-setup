---
name: arquitetura-onion
description: Padrão de arquitetura para backend .NET — pastas de solution numeradas por camada (01-api a 07-shared, mais tests/ e tools/) com Shared como shared kernel leve (entidades, enums e DTOs; direção api → application → domain → infra), allowlist de consumo por host, teste de arquitetura obrigatório, regras de fila e contrato, variante enxuta Domain/Contracts para projeto pequeno, convenções de nome, filtros tipados e a fatia vertical de uma funcionalidade. Use ao criar projeto .NET novo, adicionar módulo/funcionalidade de backend ou revisar onde um código deve ficar.
---

# Arquitetura onion (.NET)

- **Projeto novo:** nasce no **padrão numerado** (o padrão do Monitor): pastas `01-api`, `02-application`, `03-domain`, `04-infra`, `05-desktop`, `06-async`, `07-shared`, mais `tests/` e `tools/` na raiz. Ler `referencia-estrutura.md` (estrutura, camadas, dependências, allowlist de hosts, segredos, regras de robustez). Cada pasta pode ter mais de um projeto (`<Produto>.Domain.<Sub>`, `<Produto>.Infra.Data.<Banco>`), sem espaço no nome; **só se cria a pasta que tem projeto** (a numeração nunca muda). Teste de arquitetura em `tests/` obrigatório desde o início (modelo em `exemplo-teste-arquitetura.md`).
- **Neste padrão, `Shared` é um shared kernel leve e não um projeto periférico:** entidades, enums, value objects, `Request`/`View`/`Response`, `FiltroBy`/`OrdemBy`, options e constantes de claims moram nele; **proibido** EF Core, driver, Playwright, Redis, Key Vault, segredo e assinatura de token. `Domain` é a camada de serviço (regras entre entidades) e **não guarda entidades**; direção `Api/Worker/Tools → Application → Domain → Infra → Shared`. O Shared é dos executáveis .NET; o front nunca o consome.
- **Hosts:** consomem a Application. Usar o Domain direto (ex.: executável de navegação) só se declarado no `CLAUDE.md` (namespace + motivo) **e** na allowlist do teste de arquitetura. O agente instalado no cliente (`05-desktop`) não referencia `Infra.Security` nem pacote pesado.
- **Segredos:** `.env` e `appsettings` por options tipadas. Key Vault **não** é implementado; só a migração futura está documentada na referência, e só roda a pedido do usuário.
- **Robustez (referência, seções 9 e 10):** contrato sempre aditivo, reivindicação atômica (`UPDATE … WHERE status = esperado`), três garantias de fila, autorização pela tabela de vínculo canônica; ADR antes de decisão estrutural (`/adr`), medir antes de otimizar (`/medir-antes-depois`), idempotência.
- **Variante enxuta (seções 1 a 4 abaixo):** `Domain`/`Contracts`/`Application`/`Infra`/`Api`, para projeto pequeno ou quando o `CLAUDE.md` do projeto a escolhe; aqui o Domain tem as entidades. Não misturar as duas no mesmo projeto.
- **Seções 5 a 10** (convenções de nome, responsabilidade das peças, filtros, fatia vertical, revisão) valem nos dois padrões; onde cada peça mora em cada um está na tabela abaixo.
- **Projeto existente:** o `CLAUDE.md` do projeto prevalece. Respeitar a estrutura que ele já tem; aplicar este padrão só quando o usuário pedir (seção 8). Nunca migrar para o padrão numerado sem pedido.
- **Front e back separados:** projetos independentes, nunca o front numa pasta do back; a regra e a organização estão no `project-bootstrap`. Contrato: OpenAPI do backend ou o checklist da `arquitetura-angular`.

## Onde mora cada peça

| Peça | Padrão numerado | Variante enxuta |
|---|---|---|
| Entidade, value object | `07-shared` | `Domain` |
| Enum | `07-shared` | `Domain` (de domínio) e `Contracts` (exposto ao cliente) |
| DTO (`Request`, `View`, `Response`, `Filter`, `FiltroBy`/`OrdemBy`) | `07-shared` | `Contracts` |
| Interface de repositório, `IUnitOfWork` | `04-infra` | `Domain` |
| Implementação de repositório, Map (mapeamento de persistência) | `04-infra` | `Infra` |
| Regra entre mais de uma entidade | `03-domain` (serviço de domínio) | `Domain` / `Application` |
| Caso de uso (app service), mapper, specification | `02-application` | `Application` |
| Assinatura/validação de token, criptografia | `04-infra` (`Infra.Security`; middleware na `01-api`) | `Infra` |
| Controller | `01-api` | `Api` |

Pastas e nomes de cada projeto: seção 4 (enxuta) e `referencia-estrutura.md` (padrão numerado).

## 1. Projetos: começar enxuto

| Projeto | Contém | Referencia |
|---|---|---|
| `<Produto>.Domain` | Entidades **com comportamento** (invariantes nos métodos, setters privados), value objects, enums de domínio, exceções de domínio, **interfaces** de repositório, `IUnitOfWork` e portas externas (`IEmailSender`, `IFileStorage`, `I<Sistema>Client`) | nada |
| `<Produto>.Contracts` | DTOs da API: `<X>Request`, `<X>View`, `<X>Filter`, `PagedResult<T>`, enums expostos ao cliente | nada |
| `<Produto>.Application` | Casos de uso, mappers entidade ↔ contrato, specifications de filtro/ordenação, validação de entrada, transação | Domain, Contracts |
| `<Produto>.Infra` | Implementações do Domain por pasta: `Data/` (`DbContext`, configurações EF, migrations, repositórios, `UnitOfWork`), `Email/`, `Storage/`, `Integrations/<Sistema>/` | Domain |
| `<Produto>.Api` | Host HTTP: controllers, autenticação/políticas, middlewares, `Program.cs` (composition root), jobs em `BackgroundService` enquanto rodarem no mesmo processo | Application, Contracts, Infra (só para registrar) |
| Testes | `<Produto>.Domain.Tests`, `<Produto>.Application.Tests`, `<Produto>.Infra.Tests`, `<Produto>.Architecture.Tests` | o projeto testado |

## 2. Separar por demanda

Projeto novo só com motivo concreto, registrado em uma linha via `/adr` (sugerir ao usuário digitar `/adr`; é skill sob demanda):

| Motivo | Separação |
|---|---|
| Segundo banco/contexto, ou banco com ciclo de migration próprio | `Infra.Data.<Banco>` |
| Dependência pesada que outro host não deve carregar (SDK de nuvem, cliente SOAP, navegador headless) | `Infra.<Recurso>` ou `Integrations.<Sistema>` |
| Job que precisa escalar, cair ou ser publicado sem a API | Host `<Produto>.Workers` (os jobs saem da Api) |
| Cliente (desktop, outro serviço) que consome os contratos | Ele referencia **só** `Contracts` (já separado desde o início) |

Ao separar, a regra de dependência da seção 3 continua valendo e o `Architecture.Tests` ganha a regra do projeto novo **no mesmo commit**. Pasta que ficou pequena demais não vira projeto.

## 3. Regra de dependência

As referências apontam sempre para dentro.
- `Domain` e `Contracts` não referenciam nada do produto. `Domain` não conhece DTO, e `Contracts` não conhece entidade.
- `Application` não referencia EF Domain nem `Infra*`: acessa dados só pelas interfaces do Domain.
- Controllers não acessam repositório nem `DbContext`.
- Projetos de mesmo nível não se referenciam (`Infra.Data.A` ↔ `Infra.Data.B`, `Integrations.A` ↔ `Integrations.B`). O que for comum sobe para o Domain.
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
│   ├── 03-domain/           <Produto>.Domain/, <Produto>.Contracts/
│   ├── 04-infra/          <Produto>.Infra/ (e Infra.Data.<Banco>/, Integrations.<Sistema>/ quando separar)
│   ├── 05-desktop/        executáveis de borda e clientes dos contratos
│   └── 06-async/          <Produto>.Workers/ (só quando separar)
├── tests/                 <Produto>.Domain.Tests/, ..., <Produto>.Architecture.Tests/
└── tools/                 scripts e utilitários de desenvolvimento
```

- A numeração mantém a ordem fixa no Explorer e no IDE: do host para o centro, depois os consumidores.
- Nome da pasta: `NN-camada`, minúsculo, sem espaço (espaço exige aspas em CLI, Docker, CI e scripts de deploy).
- `src/` só tem código que vai para produção; testes em `tests/` e utilitários em `tools/`, na raiz.
- **Pasta física = pasta da solution** (mesma árvore no Explorer e no `.slnx`). Cada projeto fica na sua própria pasta, com o nome do projeto.
- A pasta numerada só existe quando tem projeto: buraco na numeração é normal (sem `06-async` enquanto os jobs rodam na Api). Os números não mudam quando uma pasta nasce.

### Dentro de cada projeto: o mesmo caminho em todos

Toda funcionalidade fica em `<Modulo>/<X>/` em **todos** os projetos, com o mesmo nome de módulo. Assim, uma busca pela pasta ou pelo namespace encontra as peças de uma vez.

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

## 8. Projeto existente fora deste padrão

- Seguir o padrão que o projeto já usa no módulo em questão; registrar as divergências na seção Arquitetura do `CLAUDE.md` do projeto.
- Melhorias deste padrão entram **só em código novo** e só com OK do usuário (ex.: filtro tipado num módulo novo, teste de DI). Nunca mover projetos, pastas, namespaces ou renomear sufixos em massa sem pedido. Adotar as pastas numeradas num projeto existente quebra caminhos de deploy, CI, Dockerfile e scripts: só com plano que liste e atualize cada um.
- Migração estrutural: sugerir ao usuário `/plano-migracao`, módulo a módulo.
- **Adoção total pedida pelo usuário:** o pedido explícito prevalece sobre as regras acima, mas só com checklist: (1) commit/backup do estado atual; (2) baseline do contrato (JSON das respostas, rotas) antes de mexer; (3) etapas pequenas, com build e testes verdes a cada uma; (4) se há cliente em outro repositório, alterar os dois e comparar o contrato antes/depois; (5) registrar a decisão no `CLAUDE.md` do projeto; (6) o que não foi verificado (banco real, ponta a ponta) é **PARCIAL**.
- **Reconhecer o padrão numerado em projeto desconhecido:** existe um projeto `*.Shared` **sem nenhuma `ProjectReference`**, com `Entities`/`Dto`/`Enums`, e o `Domain` **não tem entidades**. Nesse caso, respeitar essa estrutura e aplicar a regra-alvo (entidade sem atributo de ORM, Shared leve, segurança fora do Shared) **só em código novo**.
- **Equivalentes válidos no legado (não "corrigir"):** `FiltroBy` e `OrdemBy` (no lugar de `Filter`/ordenação), `Map` (no lugar de `<X>Configuration`), `Profile` do AutoMapper (no lugar de `<X>Mapper`) e `AppService` também dentro do Domain. Host que já usa o Domain direto: registrar na allowlist do `CLAUDE.md` como *Divergência* em vez de refatorar. Legado que diverge (atributos de ORM nas entidades, pacote pesado ou pasta de segurança no Shared) é registrado como *Divergência* no `CLAUDE.md` do projeto, sem migração em massa; se o Shared é referenciado por cliente instalado, avisar o usuário do risco de distribuir segredo e dependência pesada.
- **Condicional por stack** (registrar no `CLAUDE.md` como *Não se aplica* ou *Divergência*, sem inventar): persistência (`Infra/Data/Context` e migrations só com EF/SQL; MongoDB não tem DbContext); `.slnx` exige SDK com suporte (checar `global.json`); `[Authorize]` com políticas só se o projeto tem autenticação.

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

## 10. Ao revisar

Apontar `arquivo:linha` e a camada correta quando aparecer:
- regra no controller;
- EF Domain ou `IQueryable` na Application;
- entidade com `set` público mudando estado de fora;
- filtro em string;
- base abstrata acumulando dependências;
- app service acima do limite da seção 6;
- projeto separado sem motivo da seção 2;
- projeto na pasta numerada errada, pasta com espaço ou teste dentro de `src/`;
- worker com regra de negócio própria;
- caminho rápido que duplica uma decisão que já existe no caminho canônico (defeito num deles exige corrigir os dois; um auxiliar chamado por só um dos caminhos não resolve);
- no padrão numerado: host usando o Domain fora da allowlist; segredo ou Key Vault no Shared; atributo de ORM na entidade do Shared; pacote pesado ou segurança/segredo no Shared; Application usando implementação de repositório, `DbContext` ou driver; entidade devolvida em controller (usar `View`/`Response`); regra de negócio em `Utils`/`Helpers`.
