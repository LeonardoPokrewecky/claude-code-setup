# Modo PR — `/revisar pr <número|branch> [completo]`

Análise de Pull Request **somente leitura**. Nenhuma ação no PR: não comentar, não aprovar, não pedir mudanças, não fazer merge, não fechar, não fazer push, não editar arquivos. Comentário no PR só depois de autorização explícita do usuário, sempre em PT-BR. Correção sugerida vai no relatório, como trecho de código.
Relatório em PT-BR mesmo que o código, o PR ou o ticket estejam em inglês. O que não deu para checar é **não verificado**, nunca suposto.

## 1. Resolver o alvo
- **Número com `gh` disponível:** `gh pr view <n> --json title,body,baseRefName,headRefName,files,commits`, `gh pr diff <n>`, `gh pr checks <n>`.
- **Número sem `gh`:** `git fetch origin pull/<n>/head` (ref do GitHub; GitLab: `merge-requests/<n>/head`) e usar `FETCH_HEAD`; base `main`, ou a que o usuário disser. Descrição, ticket e CI: pedir que o usuário cole, ou marcar como não verificado.
- **Branch:** `git fetch origin <nome>`; usar sempre `origin/<nome>`.
- Fetch falhou ou o alvo não existe: parar e pedir o alvo. Não criar branch local, não fazer checkout; build isolado só por `git worktree` (ver §3 do SKILL.md).

## 2. Pré-checagens (antes das lentes)
| Checagem | Como | Bloqueia se |
|---|---|---|
| CI | `gh pr checks <n>` | algum check obrigatório falhou ou não rodou |
| Conflito com a base | `git merge-tree --write-tree --name-only origin/<base> <head>` (git 2.38+; não toca a árvore de trabalho; saída 1 = conflito, com os arquivos listados) | há conflito |
| Base avançou | `git rev-list --count <head>..origin/<base>` | não bloqueia sozinho; citar os commits da base que tocam os mesmos arquivos |
| Descrição × diff | comparar o que a descrição promete com `git diff --stat` e o diff | — (divergência é importante) |
| Escopo e tamanho | arquivos fora do objetivo; mais de ~400 linhas ou ~20 arquivos | — (sugerir dividir) |
| Dependências | migração, feature flag, variável de ambiente, outro PR, deploy coordenado | dependência sem plano de deploy |

## 3. Leitura
- Funções, classes, componentes e endpoints alterados: ler inteiros, não só o hunk. Arquivo com mais de 200 linhas: ler em volta de cada ponto alterado (`offset`/`limit`).
- Para cada símbolo alterado: Grep dos chamadores no repositório inteiro; conferir se algum quebra.
- Ler os relacionados mesmo fora do diff: interfaces e contratos implementados, classes base, DTOs, mappers, configurações, migrações, testes existentes do módulo.
- Motivo de uma linha não claro: `git log -L` ou `git log -- <arquivo>` recente.
- Diff grande com mais de 2 lentes: delegar cada lente a um agente `revisor` (como no §2 do SKILL.md).
- Anotar o que foi lido por completo, o que foi lido em parte e o que ficou de fora.

## 4. Lentes
Seleção automática do §1 do SKILL.md sobre o diff do PR. Além das lentes, sempre:
- **Regra de negócio:** cada regra confere com o ticket/descrição; casos de borda (nulo, zero, negativo, data e fuso, moeda e arredondamento); estados inválidos possíveis; fluxos existentes afetados. Divergência ticket × código: listar.
- **Operação:** logs e métricas para diagnosticar falha em produção; plano de rollback (migração reversível?); impacto de custo/performance.
- Refutar cada achado antes de reportar (§4 do SKILL.md).

## 5. Severidade
- **Bloqueante:** quebra corretude, segurança, dado ou contrato com chamador/cliente; CI vermelho; conflito com a base; dependência de deploy sem plano. Preferência de estilo nunca é bloqueante.
- **Importante:** não quebra agora, mas deve ser tratado (teste que não valida, log ausente, descrição divergente, escopo misturado).
- **Sugestão:** só o que agrega valor real.
Não inventar achado para preencher seção. PR bom: dizer que está bom.

## 6. Saída
**Resumo** (padrão):
```
Veredito: X ponto(s) bloqueante(s) | Sem bloqueantes, estável para subir
Pré-checagens: CI <ok|falhou|não verificado> · conflito <não|sim: arquivos> · base +N commits
Bloqueantes: caminho:linha — problema — impacto — correção (confirmado|plausível)   (ou "Nenhum")
Importantes: uma linha cada
Não verificado: ...
```
**Completo** (`completo` no fim do argumento): o resumo + **Escopo da leitura** (lidos por completo, em parte, chamadores verificados, fora) + correção com trecho de código em cada bloqueante + **Sugestões** + **Perguntas ao autor** (só as que mudam a avaliação).

Terminar e **parar**: aguardar a decisão do usuário sobre qualquer ação no PR.
