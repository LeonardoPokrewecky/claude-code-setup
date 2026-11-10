# Lente: testes

- **Cobertura relevante:** cada comportamento novo ou alterado tem teste que falharia sem a mudança? Bug corrigido tem teste que reproduz o bug.
- **Cenários:** caminho feliz, bordas (vazio, limite, duplicado), erros (entrada inválida, permissão negada), concorrência/replay quando houver mutação sensível.
- **Prova do teste de regressão:** o caso novo falha contra o código antigo? Voltar o trecho corrigido (ou `git stash` da correção) e ver falhar; teste que passa nas duas versões não testa nada.
- **API:** validação de entrada devolve 4xx, nunca 5xx; status mapeados (sucesso, inválido, não autenticado, sem permissão, não encontrado, conflito); limites no tamanho máximo e um acima; operação com efeito repetida duas vezes não duplica; acesso cruzado entre duas contas negado.
- **Contrato aditivo:** mudança de DTO mantém os campos antigos (teste prova); atualização que omite campo novo não o zera em silêncio.
- **Teste instável:** consertar ou remover; caso que falha às vezes ensina a ignorar falha.
- **Massa de teste:** criada pelos fluxos da própria API, com prefixo descartável e removida no fim; nunca dado real de cliente nem operação que cobra ou envia mensagem a terceiro.
- **Critério de aceite:** o teste verifica o resultado que importa para o usuário, não só que "não lançou exceção".
- **Regressão:** o que já funcionava e pode quebrar com este diff; testes existentes alterados para passar (suspeito: o teste mudou para aceitar o bug?).
- **Fidedignidade:** teste que depende de fixture inexistente deve falhar/pular explicitamente, nunca passar vazio; suíte verde rodando zero testes (projeto de teste não reconhecido).
- **Isolamento:** dependência de rede, banco real, relógio ou ordem de execução.

Saída extra: lista "falta teste para …" em ordem de risco.
