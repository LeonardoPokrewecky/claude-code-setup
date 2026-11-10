---
name: blueprint
description: Planejamento antes de implementar — cria o blueprint da atividade (decisões, checklist, use cases, requisitos não funcionais, resultado) em backlog/ na pasta de documentação fora do repositório. Só roda com /blueprint <descrição da atividade>.
disable-model-invocation: true
argument-hint: <descrição da atividade>
---

Atividade: `$ARGUMENTS`. **Não implementar nada nesta skill** — ela termina com o documento pronto e a pergunta "Posso implementar?". Atividade grande: rodar junto com o Plan mode (o plano do Plan mode vira a seção Blueprint).

1. Pasta: `<docs>\backlog\`. Por padrão **fora do repositório** (blueprint descreve causa raiz e falhas; não vai para o git). `<docs>` = `Documentação:` do `CLAUDE.md` do projeto; sem indicação, **perguntar uma vez** onde fica a documentação, com as duas opções: (a) **só local**, fora do repositório (padrão; obrigatório em projeto de cliente); (b) **versionada no Git** do projeto, em `docs/planejamento/` (só projeto próprio, para abrir em outro ambiente). Gravar a resposta na linha `Documentação:` do `CLAUDE.md` (na opção (b), escrever `(versionada)` na linha). Nunca assumir; criar pasta ou repositório só após OK. Se `<docs>` ficar dentro do repositório, `git check-ignore` não o ignorar e a linha não disser `(versionada)`, avisar e perguntar antes de gravar. Se a linha `Documentação:` disser `(versionada)`, gravar na pasta sem o aviso de repositório; antes de qualquer commit, varrer segredo e dado real (dump de banco nunca entra). Commit e push só a pedido. Grep antes para não duplicar um blueprint existente da mesma atividade.
2. Nome: `<AAAAMMDD-HHmm>-<descricao-curta-em-kebab>.md` (data/hora local).
3. Descoberta somente leitura antes de escrever: Grep/Glob nos pontos afetados; bug → localizar a causa raiz com `caminho:linha` (separar **confirmado** de **hipótese**).
4. Conteúdo mínimo:
   - **Blueprint:** o que será feito, decisões técnicas (e alternativas descartadas), causa raiz se for bug, arquivos afetados, configuração nova que precisa chegar ao servidor antes do deploy.
   - **Requisitos não funcionais:** percorrer a [lista](requisitos.md) e marcar cada item como *se aplica* (com o critério) ou *não se aplica* (uma linha com o motivo). Nunca omitir a lista.
   - **Checklist:** cada arquivo/componente a criar ou alterar, marcável (`- [ ]`), incluindo testes e documentação.
   - **Use cases:** no mínimo 5 — caminho feliz, bordas, erros (entrada inválida, permissão, concorrência/replay quando houver).
   - **Resultado:** deixar a seção vazia com os campos "Entregue", "Commits", "Pendências", "Lições" — preenchida ao final da atividade.
5. Mostrar o caminho do arquivo e um resumo de 3 linhas. Diagnóstico puro (sem alterar código) não precisa de blueprint: registrar a conclusão no `CLAUDE.md` do projeto (se for armadilha ou decisão duradoura) ou no `.memory` (projeto sem Git).


Ver também: `/historias-de-usuario` (requisitos e critérios de aceite em linguagem de produto), `/priorizacao`, `/modelagem-dados`, `/integracoes`, `/escolha-de-banco-e-capacidade`, `/autenticacao-e-sessao` quando o desenho tocar esses temas.
