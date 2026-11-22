---
name: arquitetura-onion
description: Arquitetura .NET em pastas 01-api a 09-tools, Shared leve e teste de arquitetura. Use ao criar projeto .NET, adicionar módulo ou adotar a estrutura numerada.
---

# Arquitetura onion (.NET)

- **Projeto novo:** nasce no **padrão numerado**: pastas `01-api`, `02-application`, `03-domain`, `04-infra`, `05-desktop`, `06-async`, `07-shared`, `08-tests` e `09-tools`: **as 9 pastas existem sempre**; a que não tem código fica só com `README.md` (modelo em `readme-camada.md`). Ler `referencia-estrutura.md` (estrutura, camadas, dependências, allowlist de hosts, segredos, regras de robustez). Cada pasta pode ter mais de um projeto (`<Produto>.Domain.<Sub>`, `<Produto>.Infra.Data.<Banco>`), sem espaço no nome; **a pasta existe sempre, o projeto só nasce com código** (sem `.csproj` vazio; a numeração nunca muda). Teste de arquitetura em `tests/` obrigatório desde o início (modelo em `exemplo-teste-arquitetura.md`).
- **Neste padrão, `Shared` é um shared kernel leve e não um projeto periférico:** entidades, enums, value objects, `Request`/`View`/`Response`, `FiltroBy`/`OrdemBy`, options e constantes de claims moram nele; **proibido** EF Core, driver, Playwright, Redis, Key Vault, segredo e assinatura de token. `Domain` é a camada de serviço (regras entre entidades) e **não guarda entidades**; direção `Api/Worker/Tools → Application → Domain → Infra → Shared`. O Shared é dos executáveis .NET; o front nunca o consome.
- **Hosts:** consomem a Application. Usar o Domain direto (ex.: executável de navegação) só se declarado no `CLAUDE.md` (namespace + motivo) **e** na allowlist do teste de arquitetura. O agente instalado no cliente (`05-desktop`) não referencia `Infra.Security` nem pacote pesado.
- **Segredos:** `.env` e `appsettings` por options tipadas. Key Vault **não** é implementado; só a migração futura está documentada na referência, e só roda a pedido do usuário.
- **Robustez (referência, seções 9 e 10):** contrato sempre aditivo, reivindicação atômica (`UPDATE … WHERE status = esperado`), três garantias de fila, autorização pela tabela de vínculo canônica; ADR antes de decisão estrutural (`/adr`), medir antes de otimizar (`/medir-antes-depois`), idempotência.
- **Variante enxuta (seções 1 a 4 abaixo):** `Domain`/`Contracts`/`Application`/`Infra`/`Api`, para projeto pequeno ou quando o `CLAUDE.md` do projeto a escolhe; aqui o Domain tem as entidades. Não misturar as duas no mesmo projeto.
- **Seções 5 a 10** (convenções de nome, responsabilidade das peças, filtros, fatia vertical, revisão) valem nos dois padrões; onde cada peça mora em cada um está na tabela abaixo.
- **Projeto existente:** o `CLAUDE.md` do projeto prevalece. Respeitar a estrutura que ele já tem; aplicar este padrão só quando o usuário pedir (seção 8). Nunca migrar para o padrão numerado, criar as pastas vazias nem renumerar `tests`/`tools` sem pedido.
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
- **Pasta física = pasta da solution** (mesma árvore no Explorer e no `.slnx`, com `<Folder>` explícito por camada; só `<Project>` solto não cria as pastas no Visual Studio; nome da pasta de solução `NN - camada` com espaço, disco `NN-camada` sem espaço; exemplo em `referencia-estrutura.md`). Cada projeto fica na sua própria pasta, com o nome do projeto.
- Variante enxuta: a pasta numerada só existe quando tem projeto (sem `06-async` enquanto os jobs rodam na Api); os números não mudam quando uma pasta nasce. No padrão numerado default as 9 pastas existem sempre (`referencia-estrutura.md`).


> **Detalhe das pastas por projeto, seção 5 (convenções de nome), seção 6 (responsabilidade de cada peça) e seção 7 (filtros, ordenação e DI): [`detalhes.md`](detalhes.md).** Ler ao criar ou alterar código; os limites da seção 6 valem na revisão (seção 10).

## 8. Projeto existente fora deste padrão

- Seguir o padrão que o projeto já usa no módulo em questão; registrar as divergências na seção Arquitetura do `CLAUDE.md` do projeto.
- Melhorias deste padrão entram **só em código novo** e só com OK do usuário (ex.: filtro tipado num módulo novo, teste de DI). Nunca mover projetos, pastas, namespaces ou renomear sufixos em massa sem pedido. Adotar as pastas numeradas num projeto existente quebra caminhos de deploy, CI, Dockerfile e scripts: só com plano que liste e atualize cada um.
- Migração estrutural: sugerir ao usuário `/plano-migracao`, módulo a módulo.
- **Adoção total pedida pelo usuário:** o pedido explícito prevalece sobre as regras acima, mas só com checklist: (1) commit/backup do estado atual; (2) baseline do contrato (JSON das respostas, rotas) antes de mexer; (3) etapas pequenas, com build e testes verdes a cada uma; (4) se há cliente em outro repositório, alterar os dois e comparar o contrato antes/depois; (5) registrar a decisão no `CLAUDE.md` do projeto; (6) o que não foi verificado (banco real, ponta a ponta) é **PARCIAL**; (7) a cada projeto movido, atualizar no mesmo passo o `.slnx` (`<Folder Name="/NN - camada/">` por camada, exemplo em `referencia-estrutura.md`), os `ProjectReference`, `Dockerfile`, CI e scripts que citam o caminho antigo, e conferir abrindo a solution (`dotnet sln list` e `dotnet build`); (8) criar o teste de arquitetura junto, não depois; (9) se o pedido inclui a estrutura completa, criar as pastas faltantes com `README.md` (`readme-camada.md`) e renumerar `tests`/`tools` para `08-tests`/`09-tools`. Vale para qualquer projeto .NET do usuário, não só o de origem do padrão.
- **Reconhecer o padrão numerado em projeto desconhecido:** existe um projeto `*.Shared` **sem nenhuma `ProjectReference`**, com `Entities`/`Dto`/`Enums`, e o `Domain` **não tem entidades**. Nesse caso, respeitar essa estrutura e aplicar a regra-alvo (entidade sem atributo de ORM, Shared leve, segurança fora do Shared) **só em código novo**.
- **Equivalentes válidos no legado (não "corrigir"):** `FiltroBy` e `OrdemBy` (no lugar de `Filter`/ordenação), `Map` (no lugar de `<X>Configuration`), `Profile` do AutoMapper (no lugar de `<X>Mapper`) e `AppService` também dentro do Domain. Host que já usa o Domain direto: registrar na allowlist do `CLAUDE.md` como *Divergência* em vez de refatorar. Legado que diverge (atributos de ORM nas entidades, pacote pesado ou pasta de segurança no Shared) é registrado como *Divergência* no `CLAUDE.md` do projeto, sem migração em massa; se o Shared é referenciado por cliente instalado, avisar o usuário do risco de distribuir segredo e dependência pesada.
- **Condicional por stack** (registrar no `CLAUDE.md` como *Não se aplica* ou *Divergência*, sem inventar): persistência (`Infra/Data/Context` e migrations só com EF/SQL; MongoDB não tem DbContext); `.slnx` exige SDK com suporte (checar `global.json`); `[Authorize]` com políticas só se o projeto tem autenticação.

## 9. Fatia vertical de uma funcionalidade nova

Checklist em [`detalhes.md`](detalhes.md#9-fatia-vertical-de-uma-funcionalidade-nova-checklist). Ler antes de implementar uma funcionalidade nova.

## 10. Ao revisar

Apontar `arquivo:linha` e a camada correta quando aparecer:
- regra no controller;
- EF Domain ou `IQueryable` na Application;
- entidade com `set` público mudando estado de fora;
- filtro em string;
- base abstrata acumulando dependências;
- app service acima do limite da seção 6;
- projeto separado sem motivo da seção 2;
- projeto na pasta numerada errada, pasta com espaço, teste dentro de `src/`, pasta de camada sem `README.md` ou `tests`/`tools` sem número (padrão numerado);
- worker com regra de negócio própria;
- caminho rápido que duplica uma decisão que já existe no caminho canônico (defeito num deles exige corrigir os dois; um auxiliar chamado por só um dos caminhos não resolve);
- no padrão numerado: host usando o Domain fora da allowlist; segredo ou Key Vault no Shared; atributo de ORM na entidade do Shared; pacote pesado ou segurança/segredo no Shared; Application usando implementação de repositório, `DbContext` ou driver; entidade devolvida em controller (usar `View`/`Response`); regra de negócio em `Utils`/`Helpers`.
