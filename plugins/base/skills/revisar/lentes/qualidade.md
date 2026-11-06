# Lente: qualidade e lógica

- **Regra de negócio:** o comportamento bate com o pedido e com as regras do `CLAUDE.md`? Casos que a regra não cobre (estado intermediário, valor zero, lista vazia, duplicado).
- **Erros:** exceção engolida; erro de notificação (e-mail, mensagem) relançado depois de a operação principal já ter sido persistida (deve ser logado); falha parcial sem compensação; mensagem genérica onde o usuário precisa agir.
- **Nulos e limites:** null/undefined, índice fora do intervalo, divisão por zero, overflow, string vazia vs. ausente, id vazio onde o banco espera `null`.
- **Concorrência:** corrida entre leitura e escrita, `async` sem `await`, `ForEach(async ...)`, job em background não idempotente (procurar o registro antes de inserir), estado compartilhado em singleton.
- **Datas e fuso:** `datetime-local` sem fuso tratado como UTC; comparação entre sistemas com deslocamento fixo de horas (apresentação, não duplicidade).
- **Recursos:** conexão/stream não descartado, timeout ausente em chamada externa, retry sem limite.
- **Código morto ou escopo além do pedido:** alterações não relacionadas misturadas no diff.
