---
name: revisar
description: Revisão somente leitura com uma lente por vez (seguranca, arquitetura, performance, testes, didatico, a11y, banco, deps, contrato), de diff, caminho ou branch. Só roda quando o usuário digita /revisar <estilo> [alvo].
disable-model-invocation: true
argument-hint: <seguranca|arquitetura|performance|testes|didatico|a11y|banco|deps|contrato> [caminho | branch:<nome>]
---

# Revisar — uma lente por vez

Argumentos: `$ARGUMENTS` → 1ª palavra = estilo; resto = alvo (arquivo/pasta ou `branch:<nome>`). Sem estilo: listar os estilos e perguntar (nunca rodar todos). Sem alvo: `git diff` + `git diff --cached`; sem Git: perguntar quais arquivos.

**Alvo `branch:<nome>`** (revisar branch sem PR):
1. `git fetch origin <nome>`; diff com `git diff <base>...origin/<nome>` (sempre `origin/` explícito: nome numérico pode colidir com objeto do repo). Ler o diff inteiro, não só o `--stat`.
2. **Escopo:** só o que a branch mudou. Trecho igual ao da base (`git show <base>:<arquivo>`) é pré-existente e não é achado — exceto correção incompleta (o mesmo padrão foi corrigido em outro ponto do diff e este ficou para trás).
3. Linha do achado: `git show origin/<nome>:<arquivo> | grep -n "<trecho>"` — nunca pelos marcadores `@@` nem pela working tree.
4. Build isolado sem tocar a working tree: `git worktree add <fora-do-repo>/_wt_<nome> origin/<nome>`, buildar só os projetos tocados, `git worktree remove ... --force` ao fim.
5. Antes de reportar, tentar **refutar** cada achado (alcançável? pré-existente? algo a jusante neutraliza?) e marcar CONFIRMADO / PARCIAL / REFUTADO.

**Somente leitura.** Não editar, não instalar, não commitar. Ler o `CLAUDE.md` do projeto para os padrões. Para bugs gerais use `/code-review`; para segurança do diff completo, `/security-review` — esta skill dá a lente e o formato.

| Estilo | Procurar |
|---|---|
| `seguranca` | injeção (SQL/NoSQL/XSS), dados sensíveis expostos, autenticação/autorização, segredos e tokens, CORS, validação em fronteiras; token "caseiro" sem assinatura (base64/GUID aceito só por decodificar), senha fixa no código, endpoint admin anônimo ou sem checagem de ambiente, tenant/escopo vindo do corpo em vez do token, mensagem de exceção crua exposta, segredo em skill/`CLAUDE.md`/memory. **Sugerir sessão Opus.** |
| `contrato` | frontend × backend: query params com nome idêntico ao `[FromQuery]`, corpo igual ao DTO, campo novo do DTO mapeado no serviço do front, caminho sem `/api/` duplicado, exportações espelhando as rotas, `[MaxLength]` no back × `maxlength` no front |
| `arquitetura` | acoplamento, responsabilidade única, duplicação, violação das regras de camada do `CLAUDE.md`, aderência aos padrões do projeto |
| `performance` | N+1, queries sem índice, alocação/memória, loops e re-renderizações desnecessárias, chamadas repetidas |
| `testes` | regressão possível, cenários novos sem teste, casos de borda sem cobertura; listar "falta teste para…" |
| `didatico` | explicar o **porquê** de cada ponto e como pensar da próxima vez, sem reescrever o código (para júnior/pleno) |
| `a11y` | (UI) rótulos, contraste, foco/teclado, ARIA, texto alternativo, ordem de leitura |
| `banco` | migration, índice, bloqueio/lock, rollback, backup, enum/schema (Mongo: índices e convenções). Só leitura + plano |
| `deps` | pacotes desatualizados/vulneráveis/licença via comandos de leitura (`npm outdated`, `npm audit`, `dotnet list package --vulnerable --outdated`). Nunca atualizar |

## Saída
Achados do mais grave ao menos grave: `caminho:linha — problema — por quê importa — correção sugerida`, marcando **confirmado** ou **plausível**. `didatico`: achado → motivo → como pensar. Sem achados: "sem achados". Terminar com **"Não verifiquei:"** (o que ficou de fora).
