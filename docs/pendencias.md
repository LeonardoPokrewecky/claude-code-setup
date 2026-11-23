# Pendências

Atualizado em 2026-11-22. Origem: backlog do repositório de origem (`Skill e pluggin\backlog`) conferido contra o código deste repositório.

## Validação que depende do dono
1. Abrir no Visual Studio uma solução gerada pelo padrão onion (`plugins/dotnet/skills/arquitetura-onion`) e conferir a árvore de pastas.
2. Iniciar o Docker Desktop e testar o devcontainer com autenticação e num projeto real.
3. Rodar `/lgpd-audit atualizar-fontes` num projeto de teste (usa rede; só com autorização).

## Evals que não rodaram (custo ~US$ 0,09 por execução)
4. `onion-projeto-novo` e `onion-projeto-existente`: `claude plugin eval ./plugins/dotnet --max-cost-usd <teto>`.
5. `padroes-de-pagina-*` (4 casos) e o braço sem plugin do eval `criar`. US$ 1 cobre só ~1,5 caso nessa configuração.

## Validação em ambiente real
6. Sandbox `-Perfil unix` em Linux ou macOS (README: "não testado").
7. Hook e marketplace dentro do Claude Code em Linux e macOS (só o CI rodou).
8. `padroes-de-pagina` num frontend real: gerar `docs/ux-padroes.md` e auditar uma rota com `/inspecao-visual`.

## Revisão
9. `/revisar seguranca` nos diffs de hook, LGPD e isolamento (sem registro de que rodou).

## Fora do controle do pacote
10. O timeout de 15 s do hook ainda libera o comando (limitação do Claude Code; documentado no README).

## Resolvido (não reabrir)
- `$nomesSensiveis` duplicado em `bloquear-segredos.ps1`.
- Teste ver-blueprint com acento.
- Os 3 evals antigos (`adotar-projeto`, `qual-skill-revisar`, `lente-testes-mock`).
- Evals das skills de maior risco.
- CI em Linux e macOS (Pester, PR #9).
- Commit, PR e merge dos blueprints antigos.
