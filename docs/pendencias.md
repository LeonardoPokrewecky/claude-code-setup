# Pendências

Atualizado em 2026-11-22. Origem: backlog do repositório de origem (`Skill e pluggin\backlog`) conferido contra o código deste repositório.

## Validação que depende do dono
1. Abrir no Visual Studio uma solução gerada pelo padrão onion (`plugins/dotnet/skills/arquitetura-onion`) e conferir a árvore de pastas.
2. Iniciar o Docker Desktop e testar o devcontainer com autenticação e num projeto real.
3. Rodar `/lgpd-audit atualizar-fontes` num projeto de teste (usa rede; só com autorização).

## Evals que não rodaram (custo ~US$ 0,09 por execução)
4. Braço sem plugin do eval `padroes-de-pagina-criar-sem-padrao` (rodar sem `--ablation none`; o padrão é com e sem plugin, então custa ~2x).

## Validação em ambiente real
5. Sandbox `-Perfil unix` em Linux ou macOS (README: "não testado").
6. Hook e marketplace dentro do Claude Code em Linux e macOS (só o CI rodou).
7. `padroes-de-pagina` num frontend real: gerar `docs/ux-padroes.md` e auditar uma rota com `/inspecao-visual`.

## Revisão
8. `/revisar seguranca` nos diffs de hook, LGPD e isolamento (sem registro de que rodou).

## Fora do controle do pacote
9. O timeout de 15 s do hook ainda libera o comando (limitação do Claude Code; documentado no README).

## Resolvido (não reabrir)
- `$nomesSensiveis` duplicado em `bloquear-segredos.ps1`.
- Teste ver-blueprint com acento.
- Os 3 evals antigos (`adotar-projeto`, `qual-skill-revisar`, `lente-testes-mock`).
- Evals das skills de maior risco.
- Evals do onion (`onion-projeto-novo` e `onion-projeto-existente`): 3 de 3 execuções cada, score 1.00 (2026-11-22).
- Evals de `padroes-de-pagina-*` (4 casos): 3 de 3 execuções cada, score 1.00 (2026-11-22; 1 voto FAIL isolado do juiz no `auditar-botoes`).
- CI em Linux e macOS (Pester, PR #9).
- Commit, PR e merge dos blueprints antigos.
