# Proposta — ambiente Claude Code (global + por tipo de projeto)

Data: 2026-11-02 · Status: **F2–F5b aplicadas; só F6 (medição) pendente** · Itens de permissões/segurança: **rodar com sessão Opus** (regra do CLAUDE.md global).

## 1. Diagnóstico (evidências)

| # | Achado | Evidência |
|---|---|---|
| D1 | Docs de projetos desatualizadas | `env-guide` e README listam ZapVendedor, Buscador, DiscordTorLauncher, WAHA. Em `C:\Workspace` só existem `PlanoCarreiraDev`, `PlanoCarreiraDev.Frontend`, `LeonardoPokrewecky` (e `Memory\`). O PlanoCarreiraDev não consta nas tabelas. |
| D2 | Permissões do `settings.json` global contradizem o `CLAUDE.md` | `powershell -Command:*`, `python -c:*` (qualquer comando sem perguntar); `winget:*`, `npm install:*` (instalar sem pedido); `dotnet user-secrets:*` (segredos); ~15 entradas avulsas (`fi`, `done`, greps antigos, Steam, powercfg). `additionalDirectories` aponta para pastas inexistentes e libera `C:\Users\Leonardo` inteiro. |
| D3 | Repo sem Git + sem `deny` de artefatos = busca lenta e cara | `PlanoCarreiraDev.Frontend` não tem `.git`, tem `node_modules`, `dist`, `.angular`. Um `rg -l "Component"` passou de 120s e devolveu 574 arquivos, **~565 em `node_modules` e só 9 em `src`** (sem `.git`, o ripgrep ignora o `.gitignore`). |
| D4 | Nenhuma proteção "só com pedido" é imposta | Commit/push/instalar só existem como texto no CLAUDE.md; nada em `permissions.ask`. |
| D5 | Modelo `dotnet-angular` contradiz a regra do próprio `env-guide` | "Cada repo é só backend ou só frontend". Nenhum projeto atual usa o modelo. |
| D6 | `merge-settings.ps1` só sabe mesclar `permissions.deny` | Não mescla `ask`/`allow`; é só global. Projetos dependem de "copiar se não existir". |
| D7 | `ponytail` repete o CLAUDE.md global | Hook de sessão injeta bloco grande por sessão; seção "Código" do CLAUDE.md diz o mesmo. |
| D8 | `claude-code-setup` global só é usado no bootstrap | Passo 6 da skill `project-bootstrap`. |

**Métrica de tokens (correção):** o que pesa por sessão é o `CLAUDE.md` inteiro + **descrições** de skills/agentes/plugins + o que hooks injetam + schemas de MCP não diferidos. O corpo de uma skill só carrega ao invocar, então **não** vale encurtar `lgpd-audit`/`env-guide` por tokens. Medir tudo com `/context` antes e depois (ainda não medido).

## 2. Global

### G1 — Permissões (prioridade 1; segurança → Opus; backup de `settings.json` antes)
- **Remover**: `powershell -Command:*`, `python -c:*`, `winget:*`, `npm install:*`, `dotnet user-secrets:*`, as ~15 avulsas, `Read(//c/Program Files (x86)/Steam//**)`.
- **Manter** (leitura/baixo risco): `ls`, `where`, `git --version`, `npm --version`, `dotnet build`.
- **Adicionar `ask`**: `git commit`, `git push`, `git reset --hard`, `git clean`, `npm install`/`npm i`, `dotnet add package`, `winget`, `Remove-Item`/`rm`.
- **Adicionar `deny`** (além de `.env`, `.pfx`, `.pem`): `*.key`, `*.p12`, `**/secrets.json`, `**/appsettings.Production.json`.
- **`additionalDirectories`**: remover as 4 entradas do ZapVendedor (pastas inexistentes) e `C:\Users\Leonardo`; o diretório de trabalho já é concedido por sessão.

### G2 — `CLAUDE.md` global
- Cortar a seção "Código" a **uma linha** apontando para o `ponytail` (D7), e "Tokens" a 2 linhas. Ganho estimado pequeno (~200 tokens/turno) — **medir**.
- Manter intactos: Segurança, Modelos, Memória, Fluxo.
- Acrescentar 1 linha: "Repo sem Git: usar `Glob`/`Grep` com caminho explícito e evitar `node_modules`, `dist`, `bin`, `obj`" (mitiga D3 até haver `git init`).

### G3 — Plugins globais
- `claude-code-setup`: **sair do global** (D8) e ser ativado no bootstrap. Mudar junto o passo 6 do `project-bootstrap` para "ativar temporariamente". Se preferir simplicidade: manter e aceitar o custo da descrição.
- Manter: `context7`, `security-guidance`, `ponytail`; `caveman` segue desligado.
- Skills `anthropic-skills:*` e conectores (Gmail/Drive/Calendar/Opera): **medir com `/context`** e só então decidir; não verifiquei se dá para desligá-las por settings.

### G4 — Repo de configuração
- Atualizar README (§5 "Projetos atuais") e `env-guide` com a realidade do disco (D1) — depende da decisão **Q1**.
- Fixar versão (tag/commit) dos marketplaces de terceiros (já em §8 do README).

## 3. Por tipo de projeto — composição em camadas

Em vez de um modelo monolítico por stack, **camadas somadas**. O `project-bootstrap` escolhe pela detecção de arquivos e aplica `base` + `stack` + `opcionais`.

```
project-templates/
  _base/        settings.json (deny artefatos+lockfiles, ask commit/push/install) + CLAUDE.project.md
  dotnet/       csharp-lsp
  angular/      typescript-lsp, frontend-design
  node-ts/      typescript-lsp              (front/back Node que não é Angular)
  python/       pyright-lsp                 (se surgir projeto Python)
  infra/        sem plugin; deny de segredos de compose/terraform  (docker-compose, WAHA)
  _opt-supabase/   supabase
  _opt-marketing/  marketing-skills
  _opt-ui-test/    playwright   (opt-in, só UI; medir antes)
  _overlay-sem-git/ lembrete .memory + sugestão git init
```

### `_base` (todo projeto)
- `permissions.deny` de leitura: `**/node_modules/**`, `**/dist/**`, `**/.angular/**`, `**/bin/**`, `**/obj/**`, `**/package-lock.json`, `**/*.min.js`, `**/.vs/**`.
- `permissions.ask`: os mesmos de G1 (herda do global; repetir só o que for específico).
- `CLAUDE.project.md` enxuto (≤ ~100 linhas): Stack, Comandos, Arquitetura, Padrões, Regras de negócio, Armadilhas, Decisões. O do PlanoCarreiraDev (44 linhas) é o exemplo-alvo.

### Matriz tipo → plugins

| Tipo | Detecção | Plugins de projeto | Observação |
|---|---|---|---|
| .NET | `*.sln`/`*.csproj` | `csharp-lsp` | `dotnet build/test` nos comandos; `global.json` |
| Angular | `angular.json` | `typescript-lsp`, `frontend-design` | respeitar design system do projeto |
| Node/TS | `package.json` sem `angular.json` | `typescript-lsp` | |
| Python | `pyproject.toml`/`requirements.txt` | `pyright-lsp` | só criar quando surgir |
| Infra/docker | só `docker-compose*.yml`/`*.tf` | nenhum | `deny` de segredos; backup antes de mexer em volumes |
| Supabase | `supabase/` ou dependência | `supabase` | começar somente leitura em dev |
| Marketing | landing/copy/SEO | `marketing-skills` | |
| Teste de UI (opt-in) | pedido explícito | `playwright` | medir tokens; ver Q3 |
| Sem Git | `.git` ausente | — | `.memory` + `git init` sugerido; `deny` de artefatos é a defesa principal (D3) |

### Itens opcionais (não padrão)
- `serena` (navegação semântica, único que ataca tokens): **teste em 1 repo grande**, exige `uvx` → autorização explícita para instalar.
- `claude-md-management`: sob demanda, sobrepõe-se ao bootstrap.
- Descartados por redundância: `code-review`, `code-simplifier`, `commit-commands`, `feature-dev`, `hookify` (use `permissions.ask`).

### Modelo `dotnet-angular` (D5)
Recomendo **remover**: monorepo = `dotnet` + `angular` somados pela composição. Se algum dia houver monorepo real, a composição já cobre. Decisão **Q2**.

## 3b. Camada "instalado, mas só ativo quando eu pedir" (pedido do Leonardo)

Princípio: **custo fixo zero até ser invocado.** Instalar não significa carregar. Três mecanismos, do mais barato ao mais caro:
1. **Skill própria com `disable-model-invocation: true`** no frontmatter: só roda quando você digita `/nome`; a descrição não entra no contexto (a confirmar com `/context` nesta versão). Vale para tudo que é "estilo" ou "lente".
2. **Plugin instalado e desligado** (`"x@y": false`, como o `caveman`): ligar só na sessão que precisar. Vale para plugins de terceiros pesados.
3. **Plugin por projeto** (já na seção 3): só o projeto que usa carrega.

### Skill única `/revisar <estilo>` (em vez de 5 skills)
Uma skill, um argumento, uma lente por vez. Reaproveita `/code-review`, `/security-review` e `ponytail-review` quando existirem; a diferença é a **lente e o formato de saída**. Somente leitura; nunca edita.

| Estilo | Foco | Saída |
|---|---|---|
| `seguranca` | injeção (SQL/XSS), dados sensíveis, autenticação/autorização, segredos e tokens | achados `caminho:linha`, severidade, correção sugerida. Sessão Opus recomendada |
| `arquitetura` | acoplamento, responsabilidade única, duplicação, aderência ao `CLAUDE.md` do projeto (ex.: regra Onion) | violações de regra de dependência primeiro |
| `performance` | N+1, queries sem índice, alocação/memória, loops e re-renderizações desnecessárias | custo estimado × esforço de correção |
| `testes` | regressão, cobertura dos cenários novos, casos de borda sem teste | lista "falta teste para…" |
| `didatico` | explica o **porquê** de cada ponto, sem reescrever o código; bom para júnior/pleno | achado → motivo → como pensar da próxima vez |

Uso: `/revisar seguranca`, `/revisar testes src/Api`. Sem argumento, perguntar qual estilo (não rodar todos: custo).

### Outras lentes sob demanda (sugestões; implementar só as que você quiser)
| Skill (`/…`) | Para quê | Onde faz sentido |
|---|---|---|
| `/revisar-a11y` | acessibilidade (rótulos, contraste, teclado, ARIA) | Angular |
| `/revisar-banco` | migration, índice, bloqueio, rollback, backup (somente leitura + plano) | .NET, Supabase, Mongo |
| `/revisar-deps` | pacotes desatualizados/vulneráveis/licença (`npm audit`, `dotnet list package --vulnerable`; só leitura) | todos |
| `/adr` | registrar decisão no `CLAUDE.md` (`Decisões`) com contexto e alternativas | todos |
| `/plano-migracao` | upgrade de versão (.NET, Angular) com riscos e passos | .NET, Angular |
| `/postmortem` | incidente: linha do tempo, causa raiz, ações | todos |
| `lgpd-audit`, `session-handoff` | **já existem**; passar a `disable-model-invocation: true` se quiser custo zero | todos |

Regras: skills sob demanda ficam em `global\skills\` (genéricas) ou `<repo>\.claude\skills\` (específicas do projeto); cada uma cita seu critério de sucesso e termina com "o que não verifiquei".

## 3c. Catálogo completo (decisão Q5): ativo × por requisição

**Ativo** = carrega sempre (custo fixo; só o que justifica). **Por requisição** = instalado, `/nome` ou plugin desligado, custo fixo zero.

| Grupo | Item | Escopo | Quando |
|---|---|---|---|
| Ativo | `ponytail`, `context7`, `security-guidance` | Global | sempre |
| Ativo | `csharp-lsp` / `typescript-lsp` / `pyright-lsp` | Por stack | repo da stack |
| Ativo | `frontend-design` | Angular/front | repos com UI |
| Ativo | `deny` de artefatos + `ask` de commit/push/install | `_base` | todo projeto |
| Req. | `/revisar seguranca\|arquitetura\|performance\|testes\|didatico` | Global | revisão de diff/pasta |
| Req. | `/revisar-a11y`, `/revisar-banco`, `/revisar-deps` | Global | por tipo (UI, banco, pacotes) |
| Req. | `/adr`, `/plano-migracao`, `/postmortem` | Global | decisão, upgrade, incidente |
| Req. | `/criar-testes` (gerar testes p/ código sem cobertura, só em arquivos indicados) | Global | cobertura |
| Req. | `/explicar` (mapa de um módulo/fluxo para onboarding, só leitura) | Global | projeto novo/legado |
| Req. | `/limpar-codigo` (código morto/duplicado/imports, só relatório; aplicar só com OK) | Global | manutenção |
| Req. | `/preparar-pr` (resumo do diff, checklist, riscos; **não** faz push) | Global | antes de abrir PR |
| Req. | `lgpd-audit`, `session-handoff` | Global | já existem; marcar sob demanda |
| Req. | `caveman` | Global (plugin desligado) | logs/testes longos |
| Req. (opt-in) | `playwright` | Angular/UI | testar UI no navegador; medir antes |
| Req. (opt-in) | `serena` | Repos grandes | navegação por símbolo; exige `uvx`; medir antes |
| Req. | `claude-code-setup`, `claude-md-management` | Bootstrap | ativar só ao adotar/auditar projeto |
| Req. | `marketing-skills`, `supabase` | Projeto | só quando o projeto usar |

Regras: cada skill sob demanda é somente leitura por padrão; quem escreve (`/criar-testes`, `/adr`) só altera os arquivos indicados e mostra diff. Nada é instalado sem pedido explícito.

## 4. Mudança de ferramenta (necessária para as camadas)
- `scripts/merge-settings.ps1`: hoje une só `permissions.deny`. Estender para **união de arrays** `deny`/`ask`/`allow` e aceitar `-Target` de projeto + lista de camadas (`-Layers base,dotnet`). Sem isso, as camadas não compõem (D6).
- `project-bootstrap`: passar a escolher camadas por detecção, mostrar o diff final do `settings.json` antes de gravar, backup `*.bak-AAAAMMDD`.

## 5. Plano em fases (cada fase = 1 commit; nenhuma aplicada sem OK)

| Fase | Conteúdo | Risco | Exige | Status |
|---|---|---|---|---|
| F1 | G1 permissões | **alto** (segurança) | Opus + backup do `settings.json` + aprovação | feito (`settings.json` global já com `ask`/`deny` e sem `additionalDirectories`) |
| F2 | G2 CLAUDE.md + sync da cópia instalada | baixo | backup `~\.claude\CLAUDE.md` | feito (`c28663a`) |
| F3 | Reestruturar `project-templates` em camadas + `merge-settings.ps1` | médio | teste em pasta temporária (nunca em projeto real) | feito (`716d693`) |
| F4 | Atualizar `project-bootstrap`, `env-guide`, README (D1) | baixo | Q1 respondida | feito (`7b8bed9`) |
| F5 | Aplicar nos projetos reais (PlanoCarreiraDev, PlanoCarreiraDev.Frontend: CLAUDE.md + `_base`) | baixo | adopt-existing, um por vez | feito (settings com `_base` + `.bak-20261102`; Frontend já tem `CLAUDE.md`) |
| F5b | Criar `/revisar <estilo>` (3b) + marcar `lgpd-audit`/`session-handoff` como sob demanda | baixo | quais estilos/lentes (Q5); testar em pasta temporária | feito (`c33ff34`) |
| F6 | Medir com `/context` e decidir G3 + opcionais (`serena`, `playwright`) | — | autorização para instalar | pendente |

Critério de sucesso: JSON válido em todos os settings; `merge-settings.ps1` idempotente (rodar 2× = mesmo resultado); `/context` mostra menos tokens fixos que o baseline; busca no front sem `.git` rápida.

## 6. Decisões do Leonardo (2026-11-02)
- **Q1**: ZapVendedor, BuscadorContabil, DiscordTorLauncher e WAHA foram removidos / não estão em uso → **sair das tabelas** do `env-guide` e do README; adicionar PlanoCarreiraDev (.NET) e PlanoCarreiraDev.Frontend (Angular).
- **Q2**: remover o modelo `dotnet-angular` → **sim**.
- **Q3**: `playwright` e `serena` → **opt-in para testar** (nada instalado sem autorização explícita; `serena` exige `uvx`).
- **Q4**: `git init` → **não**. Os repos continuam sem Git: a defesa é o `deny` de artefatos da `_base` + `.memory` (PlanoCarreiraDev). Frontend sem `.memory` e sem `CLAUDE.md` ainda.
- **Q5**: incluir **tudo que for útil para outros projetos**, em dois grupos (ver 3c).

## 7. Não verificado
- Se `disable-model-invocation: true` remove a descrição do contexto nesta versão (confirmar com `/context` antes de generalizar).
- Consumo real de tokens (sem `/context` ainda).
- Se `anthropic-skills:*` e conectores podem ser desligados por settings.
- Compatibilidade/qualidade de `playwright`, `serena`, `claude-md-management` (só li a lista do marketplace local).

## 8. Resultado (2026-11-02)
- **Feito**: G2 (`CLAUDE.md` global enxuto; cópia instalada idêntica ao repo), G3 parcial (`claude-code-setup` desligado no global, ligar no bootstrap), G4 (docs com a realidade do disco), camadas + `merge-settings.ps1 -Layers/-DryRun`, skills sob demanda, `_base` aplicada nos dois projetos.
- **F1 verificada**: o `settings.json` global tem `allow` só de leitura, `ask` (commit, push, reset --hard, clean, npm install/i, dotnet add package, winget, rm, Remove-Item), `deny` de segredos e nenhum `additionalDirectories`. (Registro anterior de F1 pendente estava errado.)
- **Pendente**: **F6** — medir com `/context`; `playwright`/`serena` seguem opt-in.
- **Ainda não verificado**: itens da seção 7.
