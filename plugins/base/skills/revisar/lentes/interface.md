# Lente: interface (consistência visual e usabilidade)

Controle de qualidade, não opinião estética: cada achado aponta a regra quebrada e a evidência (captura da `inspecao-visual` ou `arquivo:linha`).

- **Tokens:** cor, espaço, raio, sombra e tipografia vêm dos tokens do projeto; valor literal repetido ou `!important` novo é achado.
- **Consistência:** mesmo componente com aparência ou comportamento diferente entre telas; componente duplicado em vez de variante; nomes de ação diferentes para a mesma coisa.
- **Hierarquia:** uma ação primária por área; título e conteúdo principal vistos primeiro; secundárias discretas; ação destrutiva separada e com confirmação.
- **Espaçamento e alinhamento:** grade e escala de espaço respeitadas; elementos irmãos alinhados; nada encostado na borda em tela estreita.
- **Tipografia:** escala do projeto; texto corrido entre 45 e 75 caracteres por linha; sem texto cortado ou sobreposto.
- **Estados:** carregando, vazio, erro e sucesso presentes e úteis (ver `componentes-e-estados`); erro diz o que fazer; envio bloqueia duplo clique.
- **Usabilidade:** caminho até a tarefa principal curto; rótulos na língua do usuário, sem jargão técnico; feedback após toda ação; nada essencial escondido no mobile.
- **Responsividade:** sem rolagem horizontal; tabela e formulário adaptados; alvos de toque ≥ 44 px (ver `layout-responsivo`).
- **Validação real:** mudança visual sem inspeção no navegador é achado `MÉDIA` ("não verificado no navegador"), nunca aprovação.
