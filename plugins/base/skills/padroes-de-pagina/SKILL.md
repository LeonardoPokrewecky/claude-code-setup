---
name: padroes-de-pagina
description: Garante um padrão único de UX nas páginas de um projeto — cria o contrato de uma tela nova (tipo, estrutura, botões e ações, telas de configuração, microcopy, estados) ou audita a usabilidade das existentes contra o padrão do projeto (`docs/ux-padroes.md`) e as heurísticas, apontando divergências e melhorias do próprio padrão. Só roda com /padroes-de-pagina [criar|auditar] [tela ou caminho].
disable-model-invocation: true
argument-hint: "[criar | auditar] [tela ou caminho do repo]"
---

Alvo: `$ARGUMENTS` (sem modo: deduzir do pedido e dizer qual foi; sem tela: perguntar). **O padrão do projeto prevalece** (`docs/ux-padroes.md` no repositório do frontend, modelo em [modelo-ux-padroes.md](modelo-ux-padroes.md)); o catálogo abaixo é só ponto de partida. Aparência, componente, largura e evidência não são desta skill: tokens `/sistema-de-design`, componentes e estados `/componentes-e-estados`, larguras `/layout-responsivo`, capturas `/inspecao-visual`, acessibilidade `/revisar a11y`.

## 1. Modo `criar`
1. Ler `docs/ux-padroes.md`. **Não existe:** levantar as telas reais (Glob/Grep das rotas e páginas), agrupar por tipo, extrair o que já se repete e propor o arquivo a partir do modelo. **Gravar só após aprovação**; sem ela, o contrato sai como proposta. Sugerir a linha para o `CLAUDE.md` do projeto, sem gravar.
2. Classificar a tela (catálogo, seção 3) e **comparar com 1 a 2 telas do mesmo tipo** já existentes (guardião de consistência).
3. Entregar o **contrato da página**: tipo, estrutura, ação primária única, vocabulário das ações, estados (a definição fica em `/componentes-e-estados`), textos de erro, vazio e sucesso.
4. **Divergência do padrão:** oferecer "seguir o padrão" ou "propor nova versão do padrão" (histórico + aprovação). Nunca divergir calado.

## 2. Modo `auditar`
**Não altera nenhum arquivo.** Ler [auditoria-usabilidade.md](auditoria-usabilidade.md) e seguir o roteiro: compara cada tela com o padrão do projeto e com as heurísticas (seção 5), com `arquivo:linha` ou captura da `/inspecao-visual`, e entrega **duas listas**: (a) divergências do padrão e (b) melhorias do padrão e da UX (inclui falhas do próprio `docs/ux-padroes.md`; mudar o padrão é proposta de nova versão, com aprovação). Sem o arquivo de padrões: só heurísticas e inconsistência entre telas, sem inventar regra do projeto; recomendar criá-lo. Sem como rodar a aplicação: só o código e **PARCIAL**.

## 3. Catálogo de partida
| Tipo | Contrato mínimo |
|---|---|
| Listagem | título; **1** ação primária; busca/filtro; tabela ou lista; paginação; vazio com chamada à ação |
| Formulário | rótulo sempre visível; campos agrupados; erro no campo e no envio; ação primária e cancelar; aviso ao sair com dado não salvo |
| Detalhe | cabeçalho com identificação e ações; seções; voltar para a origem |
| Painel | indicadores no topo; 1 gráfico por pergunta; filtro de período; data da última atualização |
| Configurações | seções por assunto; **um só modelo de gravação** (salvar explícito ou aplicar na hora); segredo mascarado; consentimento nunca pré-marcado; ação perigosa separada. Ler [telas-de-configuracao.md](telas-de-configuracao.md) |

## 4. Vocabulário e microcopy
Hierarquia e regras de botão (primário único, verbo + objeto, botão vs link, ícone sem texto, desabilitado com motivo): [botoes-e-acoes.md](botoes-e-acoes.md).
- **Um verbo por ação em todo o sistema** (ex.: Salvar, Cancelar, Excluir, Voltar) e ordem fixa dos botões; o projeto fixa o seu no arquivo.
- Ação destrutiva separada das demais, com confirmação que **nomeia o que será perdido**.
- Erro diz o que houve e o que fazer, sem jargão e sem dado pessoal. Autenticação com mensagem **genérica** (não revela se o usuário existe).
- Formulário pede só o dado com finalidade (LGPD).

## 5. Heurísticas (checagem, não opinião)
Cada item vira um teste concreto na tela; falhou = achado.
1. **Status visível:** ação assíncrona mostra carregando e resultado.
2. **Linguagem do usuário:** termo do negócio, não do sistema.
3. **Controle:** cancelar e voltar sempre disponíveis; desfazer quando couber.
4. **Consistência:** mesma ação, mesmo nome, mesmo lugar (padrão do projeto).
5. **Prevenção de erro:** restrição e confirmação antes de dano irreversível.
6. **Reconhecer em vez de lembrar:** opções visíveis, sem depender de memória.
7. **Eficiência:** caminho curto para a tarefa principal; atalho para o uso frequente.
8. **Minimalismo:** nada que não sirva à tarefa; 1 ação primária por área.
9. **Recuperação de erro:** mensagem com causa e próximo passo.
10. **Ajuda:** instrução no ponto de uso para o que não é óbvio.

## Saída
Modo, padrão usado (arquivo e versão, ou "sem padrão no projeto"), contrato da página **ou** as duas listas de achados `tela | arquivo:linha | regra quebrada | gravidade | recomendação` (gravidade da `desenvolvimento-de-interfaces`: Crítico, Alto, Médio, Baixo) e "Não verifiquei:" (ex.: telas não renderizadas, fluxo não percorrido).
