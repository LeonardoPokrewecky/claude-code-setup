---
name: session-handoff
description: Gera um resumo de passagem de bastão quando uma tarefa vai continuar em outra sessão — objetivo, estado, decisões, arquivos, testes e próximos passos. Use quando o usuário pedir handoff/resumo para continuar depois, ou antes de encerrar uma tarefa longa inacabada.
---

# Session Handoff

Produza um resumo estruturado (sem transcrição) e mostre na conversa:

```markdown
## Handoff — <tarefa> (<AAAA-MM-DD>)
**Objetivo:** ...
**Estado:** concluído / em andamento / bloqueado
**Feito:** itens com arquivo:linha
**Decisões:** decisão + motivo
**Testes:** comando e resultado literal
**Pendências / próximos passos:** lista ordenada
**Riscos:** ...
```

Onde salvar (só se o usuário pedir):
- Repo com Git: `HANDOFF.md` na raiz (não commitar sem pedido).
- Projeto sem Git: registrar no `C:\Workspace\Memory\<Projeto>.memory`.

Fatos duradouros (preferência, armadilha, decisão de arquitetura) vão para a Auto Memory ou para o `CLAUDE.md` do projeto, não para o handoff.
