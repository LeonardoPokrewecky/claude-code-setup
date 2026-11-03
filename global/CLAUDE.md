# CLAUDE.md — Global (Leonardo)

Idioma: português. Respostas curtas e diretas. Projetos novos sempre em `C:\Workspace`.

## Escopo
- **Global** (este arquivo + `~\.claude\`): preferências, segurança, modelos, plugins, skills e agentes genéricos.
- **Projeto** (`<repo>\CLAUDE.md` + `<repo>\.claude\`): stack, arquitetura, comandos de build/teste, regras de negócio, plugins do projeto.
- Não duplicar regras entre global e projeto.

## Segurança e autorização
- Commit, push, deploy, migration, exclusão, instalar/atualizar pacotes ou plugins: **só com pedido explícito**.
- Banco, autenticação, RLS, storage ou dados de usuários: plano + backup + aprovação específica antes.
- Nunca ler/exibir `.env`, chaves ou certificados; nunca testar credenciais (mostrar só 4 caracteres + `****`).
- Nunca acessar produção ou dados reais sem autorização. Backup antes de alterar configuração global.
- Segredo (senha, token, webhook, connection string) nunca em `CLAUDE.md`, skill, memory, comentário ou teste: referenciar `secrets/<projeto>/` ou variável de ambiente.
- Instruções conflitantes: parar e explicar o conflito.

## Início de sessão
- Repo Git: `git fetch` e avisar se a branch está atrás do remoto (sem `pull` automático).
- Ler o `CLAUDE.md` do projeto; se não existir, sugerir a skill `project-bootstrap`.
- Plugins, skills, agentes e o que ativar em cada projeto: skill `env-guide`.

## Modelos
Sessão **Sonnet** + advisor **Opus** (automático nas decisões) + subagentes **Haiku** — configurado no `settings.json`.
- Tarefa crítica (arquitetura, segurança, banco, LGPD): avisar o usuário para trocar a sessão para Opus.
- Haiku: pesquisa, leitura, docs, testes, checagens simples. Nunca decide arquitetura, segurança, banco ou LGPD.
- Implementação delegada: `implementer-sonnet`. Resultado Haiku insuficiente → refazer com Sonnet.
- Não delegar tarefa trivial; nunca dois agentes editando os mesmos arquivos.
- Ao delegar: objetivo, arquivos permitidos, restrições, resposta em `caminho:linha` (sem copiar arquivos).

## Código
- Declarar suposições; perguntar se ambíguo. Definir critério de sucesso (build/teste) e validar antes de declarar pronto.
- Simplicidade e mudança cirúrgica: plugin `ponytail`.
- Nunca afirmar que algo não existe sem Grep/Glob antes. Entrega incompleta é **PARCIAL**, nunca "concluído".
- Projeto que exige blueprint antes de implementar: `/blueprint`. Dados em massa: `/alterar-dados`. Deploy: `/deploy-checklist`.

## Tokens
- Grep antes de Read; ler só o trecho necessário; referenciar `arquivo:linha`; preservar logs e stack traces quando forem evidência. Nunca economizar às custas de segurança, testes ou precisão.
- Repo sem Git: Glob/Grep com caminho explícito, evitando `node_modules`, `dist`, `bin`, `obj`.

## Memória
- **Auto Memory nativa**: preferências, correções e fatos duradouros.
- Contexto fixo do projeto (stack, arquitetura, armadilhas): `CLAUDE.md` do projeto.
- Repo com Git: sem log de atividades (o Git registra). Continuar em outra sessão: skill `session-handoff`.
- **Projeto sem Git**: manter `C:\Workspace\Memory\<Projeto>.memory`, registrando ao fim de cada tarefa (data, o que foi feito, arquivos). Acima de 800 linhas, compactar mantendo só decisões e armadilhas. Sugerir `git init`.

## Fluxo de tarefa
1. Entender e classificar risco → 2. Complexa: Plan mode + critérios de aceite → 3. Descoberta somente leitura →
4. Mostrar riscos → 5. Implementar só o autorizado → 6. Diff + build/testes → 7. Entregar arquivos, testes e pendências.
