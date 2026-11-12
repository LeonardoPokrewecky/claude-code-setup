---
name: revisar
description: Revisão somente leitura por lentes (seguranca, lgpd, arquitetura, qualidade, performance, testes, contrato, banco, integracoes, interface, deps, a11y, didatico). Sem lente, escolhe as lentes pelo risco do diff. Alvo: diff, caminho ou branch. Modo PR (pr <número|branch>) checa CI e conflito e dá veredito. Só roda com /revisar [lente|auto|pr] [alvo].
disable-model-invocation: true
argument-hint: "[auto|pr|seguranca|lgpd|arquitetura|qualidade|performance|testes|contrato|banco|integracoes|interface|deps|a11y|didatico] [caminho | branch:<nome> | <número-do-PR> [completo]]"
---

# Revisar — lentes escolhidas pelo risco

Argumentos: `$ARGUMENTS` → 1ª palavra = lente (ou `auto`); resto = alvo. Primeira palavra que não é lente conhecida faz parte do alvo e a seleção é automática.
Sem alvo: `git diff` + `git diff --cached`; sem Git: perguntar quais arquivos.
**1ª palavra `pr`:** modo PR. Ler [modo-pr.md](modo-pr.md) e seguir aquele roteiro (pré-checagens de CI e conflito, leitura dos chamadores, lentes deste arquivo, veredito com bloqueantes). As seções abaixo valem dentro dele.

**Somente leitura.** Não editar, não instalar, não commitar. Ler o `CLAUDE.md` do projeto para os padrões.
**Revisão automática não é aprovação.** Ela aponta riscos; quem aprova é uma pessoa.

## 1. Escolher as lentes (modo auto)
Ler o diff inteiro (não só o `--stat`) e acionar **só** as lentes cujo gatilho aparece. Nunca todas por padrão.

| Lente | Gatilho no diff | Arquivo |
|---|---|---|
| `seguranca` | autenticação/autorização, entrada de usuário, consulta a banco, upload, segredos/config, CORS, endpoints novos | [lentes/seguranca.md](lentes/seguranca.md) |
| `lgpd` | dado pessoal (nome, CPF, e-mail, telefone, endereço, saúde, localização, IP), formulário/tela, log, scraping, integração que envia dados | [lentes/lgpd.md](lentes/lgpd.md) |
| `arquitetura` | projeto/módulo/pasta novo, referência entre camadas, interface pública nova, mudança estrutural | [lentes/arquitetura.md](lentes/arquitetura.md) |
| `qualidade` | qualquer lógica alterada (sempre que houver código de produção) | [lentes/qualidade.md](lentes/qualidade.md) |
| `testes` | código de produção alterado | [lentes/testes.md](lentes/testes.md) |
| `contrato` | DTO, rota, controller, serviço HTTP do frontend | [lentes/contrato.md](lentes/contrato.md) |
| `banco` | migration, schema, índice, script de dados | [lentes/banco.md](lentes/banco.md) |
| `integracoes` | chamada HTTP a serviço externo, webhook, fila/mensageria, job, cliente de integração | [lentes/integracoes.md](lentes/integracoes.md) |
| `performance` | laço sobre coleção grande, consulta em laço, renderização, cache | [lentes/performance.md](lentes/performance.md) |
| `interface` | template, estilo ou componente visual (`.html`, `.css`/`.scss`, `.tsx`/`.jsx`, `.vue`) | [lentes/interface.md](lentes/interface.md) |
| `a11y` | elemento interativo, formulário, modal ou navegação novos ou alterados no template | [lentes/a11y.md](lentes/a11y.md) |

`deps` e `didatico` só rodam quando pedidas pelo nome ([deps](lentes/deps.md), [didatico](lentes/didatico.md)).

Mostrar a seleção em uma linha antes de começar: `Lentes: qualidade, testes, seguranca (motivo: endpoint novo em ...)`.
Diff que toca segurança, LGPD ou arquitetura: recomendar sessão Opus se a atual for mais fraca.

## 2. Executar
- Ler o arquivo da lente escolhida e aplicar só aquela lista.
- Mais de 2 lentes num diff grande: delegar cada lente a um agente `revisor` em paralelo, passando o alvo, o caminho do arquivo da lente e o CLAUDE.md do projeto. Diff pequeno: a própria sessão revisa (delegar custa mais que revisar).
- Reaproveitar o embutido quando ele cobre: `/security-review` para o diff completo de segurança, `/code-review` para bugs gerais. Esta skill dá as lentes, a seleção e o formato.

## 3. Alvo `branch:<nome>` (branch sem PR)
1. `git fetch origin <nome>` (pede confirmação); diff `git diff <base>...origin/<nome>` (sempre `origin/` explícito).
2. Escopo: só o que a branch mudou. Trecho igual ao da base (`git show <base>:<arquivo>`) é pré-existente e não é achado — exceto correção incompleta (o mesmo padrão corrigido em outro ponto do diff e este ficou para trás).
3. Linha do achado: `git show origin/<nome>:<arquivo> | grep -n "<trecho>"`, nunca pelos marcadores `@@`.
4. Build isolado: `git worktree add <fora-do-repo>/_wt_<nome> origin/<nome>`, buildar só o tocado, `git worktree remove ... --force` ao fim.

## 4. Antes de reportar
Tentar **refutar** cada achado (alcançável? pré-existente? algo a jusante neutraliza?) e marcar **confirmado** ou **plausível**.

## Saída
Por lente, do mais grave ao menos grave: `[ALTA|MÉDIA|BAIXA] caminho:linha — problema — por que importa — correção sugerida (confirmado|plausível)`.
`didatico`: achado → motivo → como pensar. Sem achados: "sem achados".
Terminar com **"Lentes não aplicadas:"** (e por quê) e **"Não verifiquei:"**.
