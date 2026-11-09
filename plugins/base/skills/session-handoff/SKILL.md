---
name: session-handoff
description: Gera um resumo de passagem de bastão quando uma tarefa vai continuar em outra sessão — objetivo, estado, decisões, arquivos, testes e próximos passos. Só roda com /session-handoff.
disable-model-invocation: true
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
- Repo com Git: `HANDOFF.md` na pasta de documentação (por padrão fora do repositório): `Documentação:` do `CLAUDE.md` do projeto; sem indicação, **perguntar uma vez** onde fica a documentação, com as duas opções: (a) **só local**, fora do repositório (padrão; obrigatório em projeto de cliente); (b) **versionada no Git** do projeto, em `docs/planejamento/` (só projeto próprio, para abrir em outro ambiente). Gravar a resposta na linha `Documentação:` do `CLAUDE.md` (na opção (b), escrever `(versionada)` na linha). Nunca assumir; criar pasta ou repositório só após OK. Se ficar dentro do repositório, `git check-ignore` não a ignorar e a linha não disser `(versionada)`, avisar e perguntar antes de gravar. Se a linha `Documentação:` disser `(versionada)`, gravar na pasta sem o aviso de repositório; antes de qualquer commit, varrer segredo e dado real (dump de banco nunca entra). Commit e push só a pedido.
- Projeto sem Git: registrar no `<pasta de memória>\<Projeto>.memory` (pasta em `~/.claude/maquina.md`).

Fatos duradouros (preferência, armadilha, decisão de arquitetura) vão para a Auto Memory ou para o `CLAUDE.md` do projeto, não para o handoff.
