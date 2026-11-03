---
name: blueprint
description: Cria o documento de blueprint de uma atividade (blueprint, checklist, use cases, resultado) em backlog/ na pasta de documentação fora do repositório, antes de implementar. Só roda com /blueprint <descrição da atividade>.
disable-model-invocation: true
argument-hint: <descrição da atividade>
---

Atividade: `$ARGUMENTS`. **Não implementar nada nesta skill** — ela termina com o documento pronto e a pergunta "Posso implementar?".

1. Pasta: `<docs>\backlog\`, **fora do repositório** (blueprint descreve causa raiz e falhas; não vai para o git). `<docs>` = `Documentação:` do `CLAUDE.md` do projeto; sem indicação, `<pasta-pai-do-repo>\docs\<nome-do-repo>\`. Se `<docs>` ficar dentro do repositório e `git check-ignore` não o ignorar, avisar e perguntar antes de gravar. Grep antes para não duplicar um blueprint existente da mesma atividade.
2. Nome: `<AAAAMMDD-HHmm>-<descricao-curta-em-kebab>.md` (data/hora local).
3. Descoberta somente leitura antes de escrever: Grep/Glob nos pontos afetados; bug → localizar a causa raiz com `caminho:linha` (separar **confirmado** de **hipótese**).
4. Conteúdo mínimo:
   - **Blueprint:** o que será feito, decisões técnicas (e alternativas descartadas), causa raiz se for bug, arquivos afetados, configuração nova que precisa chegar ao servidor antes do deploy.
   - **Checklist:** cada arquivo/componente a criar ou alterar, marcável (`- [ ]`), incluindo testes e documentação.
   - **Use cases:** no mínimo 5 — caminho feliz, bordas, erros (entrada inválida, permissão, concorrência/replay quando houver).
   - **Resultado:** deixar a seção vazia com os campos "Entregue", "Commits", "Pendências", "Lições" — preenchida ao final da atividade.
5. Mostrar o caminho do arquivo e um resumo de 3 linhas. Diagnóstico puro (sem alterar código) não precisa de blueprint: registrar só no history/memory do projeto.
