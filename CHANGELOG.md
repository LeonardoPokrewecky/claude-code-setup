# Changelog

Histórico editorial do pacote. Contagens de testes ficam no CI, não aqui.

## 2026-11-22
- Repositório público limpo (sem PDF de terceiro no histórico); o histórico completo fica num repositório privado de arquivo.
- Hook de segredos: o código de saída do interpretador é conferido (falha fechada); BOM no stdin tratado e testado com bytes reais.
- Supply chain: marketplace `kit-dev-ia` fixado por tag (`v1.0.0`), `marketingskills` por SHA, GitHub Actions por SHA, Pester em versão exata, CLI `claude` fixada no CI com `claude plugin validate`.
- `ver-blueprint.ps1`: CSP e remoção de HTML cru ativo.

## Rodadas de eval (movido do README)
- Evals do plugin `dotnet` (2026-11-22, `claude plugin eval ./plugins/dotnet --ablation none`): `onion-projeto-novo` e `onion-projeto-existente` passaram 3 de 3 cada (score 1.00), US$ 1,15 no total; sem braço sem plugin e com amostra pequena.
- Evals em `plugins/base/evals/`: `claude plugin eval ./plugins/base --max-cost-usd <teto>` (chama o modelo; custo; o juiz padrão é o Haiku; `--case 'blueprint-*'` roda um grupo). Casos: `blueprint-*` (portão de aprovação), `revisar-*` (lentes e "revisão não é aprovação"), `alterar-dados-*` (backup, dry-run, canário, filtro amplo), `adotar-projeto`, `qual-skill-revisar`, `lente-testes-mock`, `responder-revisao-confirma` (não posta, não resolve nem faz push por conta própria), `comandos-*` (lista completa e filtro; o filtro usa regex, porque o juiz Haiku reprovou 3 de 3 respostas corretas em 17/11/2026). As skills manuais (`/revisar`, `/alterar-dados`) são avaliadas pelo comportamento da resposta, não por `tool_used: Skill` (o modelo não as invoca sozinho). Skill manual é acionada no eval com o prompt começando por `/base:<skill>` (confirmado em 2026-11-14: sem o prefixo, o `alterar-dados-protocolo` reprovou 3 de 3; com o prefixo, passou 3 de 3). Última rodada (2026-11-14, `--ablation none`): 7 casos aprovados, cerca de US$ 2 no total (cerca de US$ 0,09 por execução); os 3 evals antigos rodaram depois: `adotar-projeto` e `lente-testes-mock` passaram 2 de 2, e `qual-skill-revisar` passou 4 de 4 no regex depois de aceitar `/base:revisar` (nome com prefixo do plugin) e `/security-review`. O grader `consultou-guia` desse caso é só indicador (`arm: with-only`): o modelo responde pela listagem de skills e **não** invoca o `env-guide` (0 de 4), o que não afeta a resposta correta.