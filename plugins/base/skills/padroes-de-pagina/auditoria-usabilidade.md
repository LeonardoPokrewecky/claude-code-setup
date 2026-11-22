# Auditoria de usabilidade (modo auditar)

**Não altera nenhum arquivo.** Corrigir é outra etapa (`desenvolvimento-de-interfaces`, modo corrigir). Dado sintético, ambiente local ou homologação.

## Roteiro
1. **Levantar** as rotas e, para cada uma, a **tarefa principal** do usuário (Glob/Grep das rotas e páginas).
2. **Padrão do projeto:** ler `docs/ux-padroes.md` (versão). Sem ele: auditar só pelas heurísticas e pela inconsistência entre telas, sem inventar regra do projeto.
3. **Percorrer o fluxo** da tarefa principal com `/inspecao-visual` quando a aplicação rodar local; contar passos até concluir. Sem como rodar: só o código e entrega **PARCIAL**.
4. **Aplicar as 10 heurísticas** do `SKILL.md` como testes concretos, mais [botoes-e-acoes.md](botoes-e-acoes.md) e, em tela de configuração, [telas-de-configuracao.md](telas-de-configuracao.md). Achado sem regra quebrada e sem evidência não entra (nada de opinião estética).
5. **Auditar o próprio padrão** (lista b): o `docs/ux-padroes.md` manda algo que as heurísticas condenam (ex.: destrutivo ao lado do primário, rótulo genérico, exceção que virou regra)? Isso é achado do **padrão**, não da tela.

## Relatório: duas listas
**(a) Divergências do padrão:** tela que quebra o padrão do projeto, sem exceção aprovada. A correção é ajustar a tela.
**(b) Melhorias do padrão e da UX:** o que melhoraria a experiência mesmo que a tela siga o padrão, ou onde o próprio padrão falha. Mudança no padrão é **proposta de nova versão** (`docs/ux-padroes.md`, histórico e aprovação); nunca editar o arquivo na auditoria.

Colunas: `tela | arquivo:linha ou captura | regra quebrada | gravidade | recomendação`.

## Gravidade
- **Crítico:** impede a tarefa principal, expõe segredo ou dado pessoal, ou apaga dado sem aviso.
- **Alto:** erro provável do usuário ou perda de dado (duas ações primárias, gravação ambígua, consentimento pré-marcado).
- **Médio:** atrito evidente (passos a mais, sem feedback, desabilitado sem motivo).
- **Baixo:** inconsistência de texto ou ordem sem prejuízo à tarefa.

## Fecho
Resumo (nº de achados por gravidade e por lista), a tela com mais problemas e "Não verifiquei:" (telas não renderizadas, fluxos não percorridos, leitor de tela real).
