# Botões e ações

O padrão do projeto (`docs/ux-padroes.md`) prevalece; isto é o ponto de partida. Aparência do botão: `/sistema-de-design`. Variantes e estados do componente: `/componentes-e-estados`. Alvo de toque: `/layout-responsivo`. Foco e leitor de tela: `/revisar a11y`.

## Hierarquia (por papel, não por gosto)
| Papel | Uso | Regra |
|---|---|---|
| Primário | a tarefa principal da área | **1 por área** (página, modal, cartão) |
| Secundário | alternativa válida | no máximo 1 ou 2, visualmente mais fraco |
| Terciário / link | navegar, ver mais, cancelar | sem aparência de botão cheio |
| Destrutivo | exclui ou perde dado | separado das demais; confirmação que **nomeia o que será perdido** |

## Regras
1. **Rótulo = verbo + objeto** ("Salvar cliente"), na língua do usuário; o verbo segue o vocabulário fixado no projeto. "OK", "Enviar" e "Sim/Não" soltos são achado.
2. **Navegar é link; agir é botão.** Botão que só muda de rota, ou link que grava dado, é achado.
3. **Ordem fixa em todo o sistema** (confirmar e desistir sempre nas mesmas posições, como o projeto definiu).
4. **Ícone sem texto** exige nome acessível e dica visível.
5. **Desabilitado** explica por quê (texto próximo ou dica); sem motivo, o usuário não sabe o que falta.
6. **Ação assíncrona:** o botão mostra carregando e fica desabilitado até terminar (evita envio duplo); o resultado aparece (sucesso ou erro com o que fazer).
7. **Destrutiva reversível** oferece desfazer; irreversível pede confirmação com o nome do item.
8. **Sem ação primária concorrente:** dois botões cheios lado a lado, ou primário e destrutivo com o mesmo peso, são achado.
