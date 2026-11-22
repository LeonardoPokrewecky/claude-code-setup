---
name: responder-revisao
description: Trata os comentários de revisão de um PR — lê o código de cada thread, corrige, verifica, responde thread a thread e resolve só depois da resposta postada. Postar e resolver pedem confirmação; commit e push só a pedido. Só roda com /responder-revisao <número do PR | branch>.
disable-model-invocation: true
argument-hint: "<número do PR | branch>"
---

Alvo: `$ARGUMENTS`. Esta skill dá o **processo**; plataforma, URL e autenticação específicas do projeto (Azure DevOps, GitLab, token em cofre) ficam na skill ou no `CLAUDE.md` do projeto, quando existirem — usar o detalhe de lá. Responder e resolver threads são ações visíveis ao time: **mostrar o texto e pedir confirmação antes de postar ou resolver**. Commit e push só com pedido explícito nesta conversa.

## 1. Listar as threads ativas
- **GitHub:** `gh pr view <n> --comments` e, para saber o que está resolvido, `gh api graphql` com `reviewThreads { nodes { id isResolved path line comments { nodes { body author { login } } } } }`.
- **Azure DevOps:** REST `.../pullRequests/<id>/threads?api-version=7.0`; pendente = `status: active`; ignorar `commentType: system` (push, voto).
- Back e front podem estar em PRs separados: listar todos os envolvidos.
- Sem `gh`, sem token ou credencial vazia: **parar** e pedir que o usuário cole os comentários. Não tentar outro caminho de autenticação.

## 2. Ler e classificar
- Ler o código real de cada ponto **na versão da branch** (`git show origin/<branch>:<arquivo>`), não só o texto do comentário.
- Classificar cada thread: **corrigir** · **discordar** (com motivo técnico) · **dúvida**.
- Decisão que muda comportamento observável ou reabre uma escolha já feita (trade-off decidido em rodada anterior): perguntar ao usuário (`AskUserQuestion`) antes de mexer.

## 3. Corrigir e verificar
- Só o escopo do comentário; nada fora dele.
- Verificar antes de responder: build, testes do módulo, lint; mudança de tela → teste ponta a ponta (`/automacao-e2e`). Verificação falhou: não responder nem resolver a thread; reportar com a saída.

## 4. Responder (após confirmação)
- **Uma resposta por thread**, dizendo o que foi corrigido (ou o motivo de não corrigir). Nunca uma resposta genérica cobrindo várias.
- Montar o corpo JSON **dentro de um script** (`ConvertTo-Json`, `JSON.stringify`), nunca interpolado com `$(...)` no shell: a substituição falha em silêncio e posta conteúdo vazio.
- Comentário novo ancorado em linha: número pela versão da branch (`git show origin/<branch>:<arquivo> | grep -n "<trecho>"`), nunca contado pelos marcadores `@@` do diff.

## 5. Resolver
- Só depois da resposta postada **e** da correção verificada. GitHub: mutation `resolveReviewThread`; Azure DevOps: `PATCH .../threads/<id>` com `{"status":"fixed"}`.
- Thread em que houve discordância **não** é resolvida: quem decide é o revisor.

## 6. Reconferir
`GET` nas threads depois de postar: cada uma com a resposta (quantidade de comentários) e o status esperado. HTTP 200 do envio não prova que entrou.

## 7. Commit e push (só a pedido)
`git add` arquivo a arquivo — nunca `-A`/`.` (o working tree pode ter mudança de outro assunto); mensagem no padrão do projeto; um commit por repositório. `push --force` sempre com confirmação à parte.

## Saída
Tabela `thread | arquivo:linha | ação (corrigido/discordado/pendente) | verificação | respondida | resolvida` e **"Não verifiquei:"** (ex.: testes não executados, thread sem acesso, PR de outro repositório).

Ver também: `/revisar pr` (revisar um PR, só leitura), `/preparar-pr` (texto do PR), `/medir-antes-depois` (provar que a correção resolveu).
