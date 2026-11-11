---
name: blueprint
description: Planejamento obrigatório antes de qualquer alteração não trivial — cria o blueprint da atividade (decisões, requisitos não funcionais, checklist, use cases, resultado) em backlog/ na pasta de documentação fora do repositório, abre no navegador e para até o usuário aprovar; depois guia a implementação e a avaliação de brechas. Usar antes de implementar, ou com /blueprint <descrição da atividade>.
argument-hint: <descrição da atividade>
---

Atividade: `$ARGUMENTS` (invocação automática: a demanda atual). Atividade grande: rodar junto com o Plan mode (o plano do Plan mode vira a seção Blueprint).

**Portão:** esta skill não implementa nada até o blueprint estar `APROVADO`. Aprovação = resposta explícita do usuário ("aprovado", "pode implementar", "ok, segue"); silêncio ou resposta ambígua ("acho que sim, mas…") não aprovam: responder a dúvida e perguntar de novo.

## A. Criar (status `RASCUNHO v1`)
1. Pasta: `<docs>\backlog\`. Por padrão **fora do repositório** (blueprint descreve causa raiz e falhas; não vai para o git). `<docs>` = `Documentação:` do `CLAUDE.md` do projeto; sem indicação, **perguntar uma vez** onde fica a documentação, com as duas opções: (a) **só local**, fora do repositório (padrão; obrigatório em projeto de cliente); (b) **versionada no Git** do projeto, em `docs/planejamento/` (só projeto próprio, para abrir em outro ambiente). Gravar a resposta na linha `Documentação:` do `CLAUDE.md` (na opção (b), escrever `(versionada)` na linha). Nunca assumir; criar pasta ou repositório só após OK. Se `<docs>` ficar dentro do repositório, `git check-ignore` não o ignorar e a linha não disser `(versionada)`, avisar e perguntar antes de gravar. Se a linha `Documentação:` disser `(versionada)`, gravar na pasta sem o aviso de repositório; antes de qualquer commit, varrer segredo e dado real (dump de banco nunca entra). Commit e push só a pedido. Grep antes para não duplicar um blueprint existente da mesma atividade (existindo um `APROVADO`/`EM ANDAMENTO`, ir para **D**).
2. Nome: `<AAAAMMDD-HHmm>-<descricao-curta-em-kebab>.md` (data/hora local).
3. Descoberta somente leitura antes de escrever: Grep/Glob nos pontos afetados; bug → localizar a causa raiz com `caminho:linha` (separar **confirmado** de **hipótese**).
4. Conteúdo mínimo:
   - Linha de status logo abaixo do título: `` `Status: RASCUNHO v1` `` (valores: `RASCUNHO vN` → `APROVADO vN (AAAA-MM-DD)` → `EM ANDAMENTO` → `CONCLUÍDO` | `PARCIAL`). Blueprint antigo sem a linha = `RASCUNHO`.
   - **Blueprint:** o que será feito, decisões técnicas (e alternativas descartadas), causa raiz se for bug, arquivos afetados, configuração nova que precisa chegar ao servidor antes do deploy.
   - **Requisitos não funcionais:** percorrer a [lista](requisitos.md) e marcar cada item como *se aplica* (com o critério) ou *não se aplica* (uma linha com o motivo). Nunca omitir a lista.
   - **Checklist:** cada arquivo/componente a criar ou alterar, marcável (`- [ ]`), incluindo testes e documentação.
   - **Use cases:** no mínimo 5 — caminho feliz, bordas, erros (entrada inválida, permissão, concorrência/replay quando houver).
   - **Histórico:** uma linha por versão (`vN (data): o que mudou`).
   - **Resultado:** deixar a seção vazia com os campos "Entregue", "Commits", "Pendências", "Lições" — preenchida ao final da atividade.
5. Abrir no navegador: `pwsh -NoProfile -File "${CLAUDE_SKILL_DIR}/ver-blueprint.ps1" -Caminho "<arquivo.md>"` (sem `pwsh`: `powershell -NoProfile -ExecutionPolicy Bypass -File ...`; sessão sem interface gráfica: acrescentar `-NaoAbrir` e mostrar o caminho do `.html`). O `.html` é descartável (regerado a cada versão; em docs `(versionada)`, não commitar). Mostrar o caminho do `.md`, um resumo de 3 linhas e perguntar **"Posso implementar?"**. **Parar aqui.**

## B. Ajuste pedido
Atualizar o mesmo arquivo: `RASCUNHO v(N+1)`, linha no **Histórico**, rodar de novo o `ver-blueprint.ps1` (regera o `.html`; o usuário recarrega a aba) e perguntar de novo. Nada é implementado.

## C. Aprovado → implementar
1. Status `APROVADO vN (data)` e, ao começar, `EM ANDAMENTO`.
2. Implementar só o que está no checklist, marcando `- [x]` à medida que cada item termina (o arquivo é o estado para retomar depois de `/clear`).
3. **Desvio:** arquivo, decisão ou risco não previsto → parar, criar `RASCUNHO v(N+1)` com o motivo no Histórico e pedir aprovação só do trecho que mudou. O que já estava aprovado e não foi afetado segue.

## D. Retomada
Blueprint `APROVADO`/`EM ANDAMENTO` encontrado numa nova sessão: ler o arquivo e continuar pelos itens desmarcados do checklist, sem pedir aprovação de novo (salvo desvio, passo C.3).

## E. Avaliação de brechas (antes de declarar pronto)
1. Para cada use case e cada item do checklist: **coberto** (prova: `arquivo:linha`, teste ou saída de comando) ou **não coberto**.
2. Procurar o que o blueprint não previu: fluxo alternativo, entrada vazia/limite, validação ausente no backend, permissão, erro de integração, uso inesperado pelo usuário.
3. Brecha dentro do escopo aprovado → corrigir e provar. Fora do escopo → pendência com motivo; status `PARCIAL`.
4. Rodar `/entrega-sem-pendencia` (ou o mesmo checklist) e preencher **Resultado**. Status `CONCLUÍDO` só sem pendência crítica.

Diagnóstico puro (sem alterar código) não precisa de blueprint: registrar a conclusão no `CLAUDE.md` do projeto (se for armadilha ou decisão duradoura) ou no `.memory` (projeto sem Git). Alteração trivial também não (critério no `CLAUDE.md` global).

Ver também: `/historias-de-usuario` (requisitos e critérios de aceite em linguagem de produto), `/priorizacao`, `/modelagem-dados`, `/integracoes`, `/escolha-de-banco-e-capacidade`, `/autenticacao-e-sessao` quando o desenho tocar esses temas.
