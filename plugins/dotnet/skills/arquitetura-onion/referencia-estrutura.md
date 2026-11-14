# Referência: estrutura por pastas numeradas, com Shared como shared kernel (.NET)

Padrão **default** para projeto .NET novo (o padrão do Monitor). O `CLAUDE.md` do projeto pode escolher a variante enxuta do `SKILL.md`; não misturar as duas no mesmo projeto. Projeto existente sem esta estrutura não migra sem pedido (seção 8 do `SKILL.md`).

**Atenção ao significado dos nomes.** Aqui o `07-shared` **não** é um projeto periférico de helpers: é o **shared kernel**, o vocabulário comum de uma solução com vários executáveis (API, workers, agentes, clientes instalados). E o `03-domain` **não guarda entidades**: é a camada de serviço (regras e orquestração entre entidades). Quem conhece a Onion/Clean clássica (Domain no centro, com as entidades) deve ler esta página com esse cuidado.

Diferenças da variante enxuta do `SKILL.md`: entidades, enums e DTOs ficam no Shared (lá: `Domain` e `Contracts`); a interface de repositório fica na Infra (lá: no `Domain`); os jobs ficam em `06-async` (lá: na Api até separar). Não existe `Contracts` separado: o Shared cumpre esse papel. **O Shared é dos executáveis .NET; o frontend nunca o consome** (o contrato com o front é OpenAPI ou os models do próprio front).

## 1. Estrutura

```
<Produto>/
├── 01-api/            <Produto>.Api
├── 02-application/    <Produto>.Application
├── 03-domain/         <Produto>.Domain, ou <Produto>.Domain.<Sub> (um por subdomínio)
├── 04-infra/          <Produto>.Infra, <Produto>.Infra.Data.<Banco>, <Produto>.Infra.Security
├── 05-desktop/        executáveis de borda (navegação, agente instalado no cliente)
├── 06-async/          <Produto>.Async (workers, consumers, jobs)
├── 07-shared/         <Produto>.Shared
├── tests/             <Produto>.<Projeto>.Tests (Unit, Integration, Functional, Architecture)
└── tools/             <Produto>.Tools (importadores, diagnóstico, manutenção)
```

- **Pasta numerada por camada, mais de um projeto por pasta** quando houver motivo (subdomínio, banco, integração): `<Produto>.Domain.<Sub>`, `<Produto>.Infra.Data.<Banco>`. Projeto novo só com motivo registrado via `/adr`; pasta que ficou pequena não vira projeto.
- **Sem espaço** em nome de pasta, projeto ou namespace (espaço exige aspas em CLI, Docker, CI e deploy). Pasta em minúsculo: `NN-camada`.
- `tests/` e `tools/` ficam na raiz, **sem número**: não são camada, e a ordem alfabética já os põe depois de `07-shared`. O `src/` da variante enxuta tem a mesma regra.
- A numeração é organização visual e **não** representa a hierarquia de dependências. Os números nunca mudam; a pasta só existe quando tem projeto (buraco na numeração é normal, ex.: sem `05-desktop`). Projeto reservado e vazio fica de fora, sem esqueleto "para completar a estrutura".
- Pasta física = pasta da solution (mesma árvore no Explorer e no `.slnx`; checar `global.json` para o SDK).

## 2. Camadas

| # | Pasta | Finalidade | Dentro | Fora |
|---|---|---|---|---|
| 01 | api | Entrada HTTP | Controllers/endpoints, autenticação/autorização, middlewares, Swagger (só em desenvolvimento), `Program.cs` | Regra de negócio, `DbContext`, entidade devolvida como resposta |
| 02 | application | Casos de uso | Casos de uso (app services), validação de entrada, transação, mappers entidade ↔ View, specifications de filtro/ordenação | EF Core, HTTP, UI, invariantes de entidade |
| 03 | domain | Serviços de domínio | Regras e orquestração que envolvem mais de uma entidade; usa as interfaces de repositório da Infra | Entidade, DTO, tecnologia de I/O, regra em classe utilitária |
| 04 | infra | Implementações técnicas | `DbContext`, **Maps** (`IEntityTypeConfiguration`/`BsonClassMap`), migrations, **interfaces e implementações de repositório**, `IUnitOfWork`, Redis, mensageria, integrações externas, storage, `Infra.Security` (assinatura e validação de token; Key Vault no futuro), `AddInfra()` | Regra de negócio, casos de uso, controllers, referência a Domain ou Application |
| 05 | desktop | Executáveis de borda | Executável de navegação ou agente instalado no cliente: chama casos de uso, configuração local | Regra no code-behind/ViewModel, acesso direto ao banco; o **agente instalado** não referencia `Infra.Security` nem pacote pesado |
| 06 | async | Segundo plano | Workers, consumers/producers, jobs, retry, lote | Regra de negócio no worker (delegar à Application) |
| 07 | shared | Shared kernel | Entidades, enums, value objects; `Request`/`View`/`Response`; `FiltroBy`/`OrdemBy` (descrevem a consulta, não a executam); classes de options; abstrações de log/cache, `Result<T>`, `PagedResult<T>`, `Guard`; constantes e tipos de claims | Regra entre entidades, orquestração, segurança (assinatura, segredos), atributo de ORM ou de driver, pacote pesado (seção 5) |
| — | tests | Qualidade | Unit, Integration, Functional, Architecture | Código de produção, dados reais |
| — | tools | Operação | Importadores, exportadores, diagnóstico, manutenção | Regra própria (reusar Application), credencial embutida |

Mudança no Shared afeta todos os consumidores: alterar com critério. Tipo usado por mais de uma camada ou processo nasce no Shared.

## 3. Regra de dependência

Direção: **Api/Worker/Tools → Application → Domain → Infra → Shared**. Todos os projetos referenciam o Shared.

| Projeto | Pode referenciar |
|---|---|
| 01 api | Application, Infra (só composição de DI), Shared |
| 02 application | Domain, Shared |
| 03 domain | Infra, Shared |
| 04 infra | Shared |
| 05 desktop | Application, Infra (só composição), Shared |
| 06 async | Application, Infra (só composição), Shared |
| 07 shared | **nenhum projeto** |
| tests | os projetos testados |
| tools | Application, Infra (só composição), Shared |

```
01 api ──────┐
05 desktop ──┼─> 02 application ─> 03 domain ─> 04 infra ─> 07 shared
06 async ────┤        (todos os projetos também referenciam 07 shared)
tools ───────┘
```

- Hosts (Api, Desktop, Async, Tools) referenciam a Infra só para `AddApplication()` / `AddInfra(config)` na raiz de composição.
- A Application enxerga as **interfaces** de repositório (tipos da Infra) por referência transitiva. Pode usá-las; **não** usa implementação de repositório, `DbContext`, cliente de driver nem tipo de integração. Como a referência transitiva libera tudo, a regra é validada por **tipo/namespace** no teste de arquitetura, não só por referência de projeto.
- A Infra não referencia Domain nem Application: devolve tipos do Shared. O que precisar de regra sobe para o Domain.
- Dependência circular: resolver com genéricos ou movendo o tipo para o Shared, nunca referenciando a camada de cima.
- Entidade nunca é devolvida em controller: a resposta é `View`/`Response` do Shared.

### Allowlist de consumo por host

O padrão é o host consumir a **Application**. Um host pode consumir serviços do **Domain** direto (ex.: o executável de navegação) **só se**:
1. estiver declarado no `CLAUDE.md` do projeto (seção Arquitetura), com o **namespace liberado** e o **motivo**; e
2. a mesma allowlist estiver no teste de arquitetura, que barra o que não foi declarado.

Sem declaração nos dois lugares, o teste falha. **Lógica usada por dois hosts** (ex.: navegação no Async e no Desktop) desce para a camada mais baixa que faça sentido (Domain se é regra, Infra se é detalhe técnico) e **nunca fica duplicada** nos hosts. **Cliente instalado:** tudo que o executável carrega (Shared, mais o Domain e a Infra de que depende) vai para a máquina do cliente; sem segredo nem pacote pesado ali.

### Teste de arquitetura obrigatório

Em `tests/<Produto>.Architecture.Tests`, falhando o build. Criar **junto com a solution**, não depois. Exemplo em `exemplo-teste-arquitetura.md`. Valida:
1. a tabela de referências acima;
2. Shared sem nenhuma `ProjectReference`;
3. Shared só com pacotes da lista permitida (seção 5);
4. Shared sem atributo de ORM ou de driver (`[Bson*]`, `[Table]`, `[Key]`, `[Column]`, `[ForeignKey]`);
5. Application sem uso de implementação de repositório, `DbContext` ou driver;
6. Infra sem referência a Domain nem Application;
7. Controllers sem acesso a repositório nem `DbContext`;
8. **allowlist de hosts**: nenhum host usa o Domain fora do que foi declarado;
9. agente instalado sem `Infra.Security` nem pacote pesado.

## 4. Regras obrigatórias

1. Respeitar a numeração das pastas.
2. Não misturar responsabilidades entre camadas.
3. Sem regra de negócio em Controllers, Workers, UI nem classes utilitárias (`Utils`, `Helpers`).
4. Sem acesso ao banco fora das abstrações e implementações da Infra.
5. Sem dependência circular.
6. Não duplicar funcionalidade existente.
7. Reusar os casos de uso da Application em todo canal.
8. Entidade no Shared sem atributo de ORM ou de driver: o mapeamento (Maps) fica na Infra. Entidade protege o **próprio estado** (setters privados, métodos com invariantes); regra entre entidades fica no Domain.
9. Testes atualizados.
10. Projeto ou dependência nova só com justificativa técnica (`/adr`).
11. **Antes de alterar**, conferir se a mudança respeita direção, allowlist e limites desta página; achar a documentação não basta.

## 5. Shared enxuto e segurança fora do Shared

O Shared é distribuído a todos os executáveis, inclusive clientes instalados. Por isso:

- **Lista permitida de pacotes** (registrada e verificada no teste de arquitetura): abstrações (`Microsoft.Extensions.*.Abstractions`), `System.Text.Json`, `System.ComponentModel.Annotations` e similares sem I/O. Proibidos: EF Core, driver de banco (`MongoDB.Driver`, `Npgsql`), Redis, Playwright e outros navegadores headless, SDK de nuvem, Key Vault, OCR, biblioteca de PDF, framework web. Pacote fora da lista vai para a Infra; ampliar a lista exige `/adr`.
- **Segurança fora do Shared:** só constantes e tipos de claims (nomes de política, de claim, de perfil). Assinatura e validação de token, hash de senha, criptografia e leitura de segredos ficam na Infra (`Infra.Security`), e o middleware de autenticação na API. Segredo nunca no assembly distribuído a cliente.
- Nenhum `appsettings*.json` real no Shared; ele define só as classes de options.

## 6. Pastas internas (criar a subpasta quando houver o primeiro arquivo, sem pasta vazia nem abstração sem uso)

- **Shared:** `Entities/<Modulo>/`, `Enums/`, `ValueObjects/`, `Dto/<Modulo>/` (`<X>Request`, `<X>View`, `<X>Response`), `Filters/` (`<X>Filter`, ordenação), `Common/` (`EntityBase`, `PagedResult`, `Result`, `Guard`), `Configuration/` (options), `Claims/`
- **Domain:** `Services/<Modulo>/`, `Exceptions/`, `DependencyInjection.cs`
- **Application:** `<Modulo>/<X>/` (`I<X>AppService`, `<X>AppService`, `<X>Mapper`, `<X>Specification`), `DependencyInjection.cs`
- **Infra:** `Persistence/{Context,Configurations,Migrations}/` (as `Configurations` são os Maps), `Repositories/Interfaces/`, `Repositories/`, `Security/`, `ExternalServices/`, `Messaging/`, `Caching/`, `DependencyInjection.cs`
- **API:** `Controllers/`, `Middlewares/`, `Configurations/`, `Extensions/`, `Program.cs`
- **Async:** `Workers/`, `Consumers/`, `Producers/`, `Jobs/`
- **tests:** `Unit/`, `Integration/`, `Functional/`, `Architecture/`

## 7. Onde implementar

| Necessidade | Onde |
|---|---|
| Endpoint | api + caso de uso na application |
| Entidade, enum, value object | shared |
| Invariante do próprio estado da entidade | Método da entidade (shared) |
| Regra entre mais de uma entidade | domain (serviço de domínio) |
| Fluxo novo | application |
| DTO (Request, View, Filter) | shared |
| Consulta ao banco | Interface e implementação de repositório na infra |
| Mapeamento de persistência (Map) | infra |
| Integração externa | infra (adaptador) |
| Assinatura/validação de token | infra/Security (middleware na api) |
| Fila ou agendamento | async chamando caso de uso |
| Tela ou navegação | desktop chamando caso de uso |
| Script de importação | tools chamando caso de uso |
| Utilitário genérico sem negócio | shared (`Common`) |

Princípios: SOLID, baixo acoplamento, alta coesão, testabilidade. Sem abstração ou padrão sem necessidade.

## 8. Segredos e Key Vault (futuro)

- **Hoje:** `.env` (fora do Git) e `appsettings`, lidos por **options tipadas** (`IOptions<T>` com `ValidateOnStart`). Segredo de .NET em User Secrets; o `appsettings.json` versionado fica legível e sem valor sensível.
- **Key Vault não está implementado.** Quando o usuário **pedir**, a migração é: `AddKeyVault(config)` na `Infra.Security` e `appsettings` apontando para o cofre, sem mexer no resto do código (as options continuam iguais). Não instalar pacote nem criar recurso antes do pedido.

## 9. Regras de robustez (inspiradas no agente Master, reescritas)

- **Contrato sempre aditivo:** campo novo é opcional e o antigo continua sendo enviado; remover ou renomear exige versão nova.
- **Reivindicação atômica:** operação em dois passos muda o status com uma atualização condicional (`UPDATE … WHERE status = <esperado>`) e confere que **uma** linha foi afetada. Sem isso, dois cliques geram dois registros.
- **Fila: três garantias** para sobreviver a reinício e entrega dupla: (1) claim atômico do item (`pendente → executando` numa só operação); (2) recuperação na inicialização, que reenfileira o pendente e devolve o `executando` com sinal de vida antigo, com **limite de tentativas**; (3) teto de itens simultâneos por cliente, aplicado ao enfileirar. Todo trabalho entregue a um executor precisa de caminho de devolução.
- **Autorização pela tabela de vínculo canônica:** comparar o dono atual no vínculo, não numa coluna copiada no registro filho (transferência que atualiza só o vínculo deixaria o antigo negando acesso ao novo responsável). Rota administrativa nova tem verificação explícita de permissão; copiar o atributo do vizinho não prova nada.
- **LGPD:** a autorização e o teto por cliente não exigem dado pessoal além do necessário (minimização); logs de fila e de autorização levam identificador, nunca documento, e-mail ou token.

## 10. Princípios (inspirados no agente Forge)

- **ADR antes de decisão estrutural** (projeto novo, pacote fora da lista, exceção na allowlist): `/adr`.
- **Medir antes de otimizar:** linha de base e percentil, depois a mudança: `/medir-antes-depois`.
- **Idempotência** em job, consumer e integração: reexecutar não duplica efeito.
- **Sem serviço que faz tudo** (limites na seção 6 do `SKILL.md`) **nem entidade anêmica** (regra do próprio estado dentro da entidade).

## 11. Cuidados de quem trabalha neste padrão

- Mudança no Shared afeta todos os consumidores: avaliar o impacto em cada executável.
- Regra de negócio fica no Domain (serviços), não em `Utils`.
- Se surgir tipo que duas camadas precisam, ele nasce no Shared; não criar referência para cima.
