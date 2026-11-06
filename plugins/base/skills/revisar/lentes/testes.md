# Lente: testes

- **Cobertura relevante:** cada comportamento novo ou alterado tem teste que falharia sem a mudança? Bug corrigido tem teste que reproduz o bug.
- **Cenários:** caminho feliz, bordas (vazio, limite, duplicado), erros (entrada inválida, permissão negada), concorrência/replay quando houver mutação sensível.
- **Critério de aceite:** o teste verifica o resultado que importa para o usuário, não só que "não lançou exceção".
- **Regressão:** o que já funcionava e pode quebrar com este diff; testes existentes alterados para passar (suspeito: o teste mudou para aceitar o bug?).
- **Fidedignidade:** teste que depende de fixture inexistente deve falhar/pular explicitamente, nunca passar vazio; suíte verde rodando zero testes (projeto de teste não reconhecido).
- **Isolamento:** dependência de rede, banco real, relógio ou ordem de execução.

Saída extra: lista "falta teste para …" em ordem de risco.
