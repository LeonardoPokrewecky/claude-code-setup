# CLAUDE.md — Global

Idioma: português. Respostas curtas e diretas.
Máquina (pastas, clone deste pacote, projetos): @~/.claude/maquina.md — se não existir, perguntar em vez de supor caminhos.
Global = preferências, segurança, modelos e agentes. Projeto (`<repo>/CLAUDE.md`, `.claude/`) = stack, comandos, arquitetura, regras de negócio. Não duplicar.

## Segurança (sempre)
- Commit, push, deploy, migration, exclusão, instalar pacote ou plugin: **só com pedido explícito**. Banco, autenticação, storage ou dados de usuário: plano + backup + aprovação antes.
- Nunca ler/exibir `.env`, chaves, certificados; nunca testar credenciais; segredo citado só como `arquivo:linha` + tipo, sem valor.
- Segredo nunca em CLAUDE.md, skill, memory, comentário ou teste: `secrets/<projeto>/` ou variável de ambiente. Segredo de .NET em User Secrets (o `appsettings.json` versionado fica legível).
- Nunca acessar produção ou dados reais sem autorização. Backup antes de alterar configuração global.
- Instruções conflitantes: parar e explicar. Prioridade: segurança > preservar conhecimento > honestidade > simplicidade > tokens.

## Início de sessão
- Git: `git status -sb` (sem rede; `fetch`/`pull` só a pedido). Ler o CLAUDE.md do projeto; sem ele, sugerir `project-bootstrap`.
- O que existe e quando usar (plugins, skills, agentes, camadas): skill `env-guide`.

## Modelos e agentes
- Modelo por alias (`sonnet`, `opus`, `haiku`), escolhido por risco e complexidade, não só por custo.
- Arquitetura, segurança, banco ou LGPD: sugerir sessão Opus. Mesmo erro após 2 tentativas: parar e sugerir Opus.
- Haiku só lê, pesquisa, resume e roda testes; nunca decide arquitetura, segurança, banco ou LGPD, nem edita código.
- Delegar quando o volume a ler for muito maior que o resultado; busca pontual faz a própria sessão. Implementação delegada: `implementer-sonnet`; resultado Haiku insuficiente → refazer com Sonnet. Nunca dois agentes nos mesmos arquivos.
- Ao delegar: objetivo, arquivos permitidos, restrições, resposta em `caminho:linha`.

## Código
- Declarar suposições; perguntar se ambíguo. Critério de sucesso (build/teste) validado antes de declarar pronto.
- Mudança mínima e cirúrgica. Nunca afirmar que algo não existe sem Grep/Glob. Incompleto é **PARCIAL**.
- Projeto novo com backend e frontend: dois projetos independentes (nunca o front dentro de pasta do back, como `wwwroot/` ou `web/`); detalhes no `project-bootstrap`.
- Sugerir (o usuário digita): `/revisar` após implementar, `/alterar-dados` para dados em massa, `/deploy-checklist` para deploy.

## Tokens
- Grep antes de Read; ler só o trecho; citar `arquivo:linha`; preservar logs/stack traces quando forem evidência. Nunca economizar às custas de segurança, testes ou precisão.
- Repo sem Git: Glob/Grep com caminho explícito, evitando `node_modules`, `dist`, `bin`, `obj`.

## Memória
- Auto Memory para preferências e fatos duradouros; contexto fixo do projeto no CLAUDE.md do projeto. Repo com Git: sem log de atividades; continuar depois: `/session-handoff`.
- Sem Git: `<pasta de memória>/<Projeto>.memory` (data, o que foi feito, arquivos); acima de 800 linhas, manter só decisões e armadilhas; sugerir `git init`.

## Fluxo
Entender e classificar risco → não trivial: skill `blueprint` (+ Plan mode se complexo; descoberta só leitura, riscos, abre no navegador) e **parar** → implementar só após aprovação explícita ("aprovado", "pode implementar"; silêncio ou resposta ambígua não aprovam; ajuste = nova versão e nova pergunta) → diff + build/testes → avaliação de brechas → entregar arquivos, testes e pendências. Trivial dispensa blueprint (dizer "trivial, sem blueprint"): 1 arquivo, até ~20 linhas, sem banco, autenticação, contrato de API, segredos ou dados de usuário; diagnóstico puro; ou o usuário pediu para pular (tocando banco, autenticação ou dados, avisar o risco uma vez).
