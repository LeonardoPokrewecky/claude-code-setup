# <NomeProjeto>

Documentação: `<pasta-pai-do-repo>\docs\<nome-do-repo>\` (fora do repositório: blueprints em `backlog\`, `RELATORIO-LGPD.md`, `HANDOFF.md`) — ou `docs/planejamento/` (versionada, só em projeto próprio; a skill pergunta qual das duas)

Projeto irmão: <caminho do outro lado (backend ↔ frontend), se houver; os dois são projetos separados>

## Stack
- Backend: <ex.: .NET 10, ASP.NET Core, EF Core, SQL Server>
- Frontend: <ex.: Angular 19> (projeto próprio, fora do backend)
- Infra: <ex.: Docker, Azure>

## Comandos
- Build: `<comando>`
- Testes: `<comando>`
- Rodar local: `<comando>`

## Arquitetura
- Camadas/pastas e responsabilidade de cada uma.
- Regras de dependência entre camadas.
- Backend .NET novo: seguir a skill `arquitetura-onion`; frontend Angular novo: `arquitetura-angular`. Registrar aqui só o que divergir (e o que não se aplica).

## Padrões
- Nomenclatura, tratamento de erros, validação, logs.

## Regras de negócio
- Pontos que o Claude precisa saber para não quebrar o domínio.

## Armadilhas conhecidas
- <problema> → <como evitar>

## Decisões
- <AAAA-MM-DD> <decisão> — <motivo>
