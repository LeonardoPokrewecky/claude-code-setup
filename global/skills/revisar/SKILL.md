---
name: revisar
description: Revisão somente leitura com uma lente por vez (seguranca, arquitetura, performance, testes, didatico, a11y, banco, deps). Só roda quando o usuário digita /revisar <estilo> [alvo].
disable-model-invocation: true
argument-hint: <seguranca|arquitetura|performance|testes|didatico|a11y|banco|deps> [caminho]
---

# Revisar — uma lente por vez

Argumentos: `$ARGUMENTS` → 1ª palavra = estilo; resto = alvo (arquivo/pasta). Sem estilo: listar os estilos e perguntar (nunca rodar todos). Sem alvo: `git diff` + `git diff --cached`; sem Git: perguntar quais arquivos.

**Somente leitura.** Não editar, não instalar, não commitar. Ler o `CLAUDE.md` do projeto para os padrões. Para bugs gerais use `/code-review`; para segurança do diff completo, `/security-review` — esta skill dá a lente e o formato.

| Estilo | Procurar |
|---|---|
| `seguranca` | injeção (SQL/NoSQL/XSS), dados sensíveis expostos, autenticação/autorização, segredos e tokens, CORS, validação em fronteiras. **Sugerir sessão Opus.** |
| `arquitetura` | acoplamento, responsabilidade única, duplicação, violação das regras de camada do `CLAUDE.md`, aderência aos padrões do projeto |
| `performance` | N+1, queries sem índice, alocação/memória, loops e re-renderizações desnecessárias, chamadas repetidas |
| `testes` | regressão possível, cenários novos sem teste, casos de borda sem cobertura; listar "falta teste para…" |
| `didatico` | explicar o **porquê** de cada ponto e como pensar da próxima vez, sem reescrever o código (para júnior/pleno) |
| `a11y` | (UI) rótulos, contraste, foco/teclado, ARIA, texto alternativo, ordem de leitura |
| `banco` | migration, índice, bloqueio/lock, rollback, backup, enum/schema (Mongo: índices e convenções). Só leitura + plano |
| `deps` | pacotes desatualizados/vulneráveis/licença via comandos de leitura (`npm outdated`, `npm audit`, `dotnet list package --vulnerable --outdated`). Nunca atualizar |

## Saída
Achados do mais grave ao menos grave: `caminho:linha — problema — por quê importa — correção sugerida`, marcando **confirmado** ou **plausível**. `didatico`: achado → motivo → como pensar. Sem achados: "sem achados". Terminar com **"Não verifiquei:"** (o que ficou de fora).
