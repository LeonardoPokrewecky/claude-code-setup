# Modelo de README por camada (`NN-camada/README.md`)

Copiar o bloco da camada para `<Produto>/NN-camada/README.md` ao criar o projeto novo, trocando `<Produto>`. Cada pasta de camada leva o seu README, tenha projeto ou não; ele permanece depois que a pasta ganha código. Texto curto: detalhes ficam em `referencia-estrutura.md` (seções 2 e 3), sem copiar a tabela.

Formato de cada README: título `NN-camada`, uma linha de **Finalidade**, **Entra**, **Não entra**, **Referencia** e a linha `Sem projeto ainda: criar o <Produto>.<Camada> só quando houver código (motivo via /adr).` (remover essa última quando o projeto existir).

## 01-api
- Finalidade: entrada HTTP.
- Entra: controllers/endpoints, autenticação e autorização, middlewares, Swagger só em desenvolvimento, `Program.cs`.
- Não entra: regra de negócio, `DbContext`, entidade devolvida como resposta.
- Referencia: Application, Infra (só composição de DI), Shared.

## 02-application
- Finalidade: casos de uso.
- Entra: app services, validação de entrada, transação, mappers entidade ↔ View, specifications de filtro/ordenação.
- Não entra: EF Core, HTTP, UI, invariantes de entidade.
- Referencia: Domain, Shared.

## 03-domain
- Finalidade: serviços de domínio (regras entre mais de uma entidade).
- Entra: regras e orquestração entre entidades, exceções de domínio.
- Não entra: entidade, DTO, tecnologia de I/O, regra em classe utilitária.
- Referencia: Infra (interfaces de repositório), Shared.

## 04-infra
- Finalidade: implementações técnicas.
- Entra: `DbContext`, Maps, migrations, repositórios (interface e implementação), `IUnitOfWork`, cache, mensageria, integrações, storage, `Infra.Security`.
- Não entra: regra de negócio, casos de uso, controllers; referência a Domain ou Application.
- Referencia: Shared.

## 05-desktop
- Finalidade: executáveis de borda (navegação, agente instalado no cliente).
- Entra: chamada de casos de uso, configuração local.
- Não entra: regra no code-behind/ViewModel, acesso direto ao banco; o agente instalado não referencia `Infra.Security` nem pacote pesado.
- Referencia: Application, Shared (Domain só pela allowlist do teste de arquitetura).

## 06-async
- Finalidade: processamento em segundo plano.
- Entra: workers, consumers/producers, jobs, retry, lote.
- Não entra: regra de negócio no worker (delegar à Application).
- Referencia: Application, Infra (só composição de DI), Shared.

## 07-shared
- Finalidade: shared kernel (vocabulário comum dos executáveis .NET).
- Entra: entidades, enums, value objects, `Request`/`View`/`Response`, `FiltroBy`/`OrdemBy`, options, `Result<T>`, `PagedResult<T>`, constantes de claims.
- Não entra: regra entre entidades, orquestração, segurança (assinatura, segredo), atributo de ORM ou de driver, pacote pesado.
- Referencia: nada.

## 08-tests
- Finalidade: qualidade.
- Entra: Unit, Integration, Functional, Architecture (o teste de arquitetura nasce com a solution).
- Não entra: código de produção, dado real.
- Referencia: os projetos testados.

## 09-tools
- Finalidade: operação e manutenção.
- Entra: importadores, exportadores, diagnóstico, manutenção.
- Não entra: regra própria (reusar a Application), credencial embutida.
- Referencia: Application, Infra (só composição de DI), Shared.
