# Lente: segurança ofensiva

Pensar como atacante: o que alguém de fora (ou um usuário autenticado de outro tenant) consegue fazer com este diff?

- **Injeção:** SQL/NoSQL montado com concatenação, comando de shell com entrada do usuário, XSS (HTML sem escape, `innerHTML`, `bypassSecurityTrust*`), template injection, path traversal (`../` em nome de arquivo), desserialização de tipo arbitrário.
- **Entrada:** validação só no frontend; tamanho sem limite (`[MaxLength]`, `maxlength`); upload sem checagem de tipo/tamanho; redirecionamento aberto.
- **Autenticação:** token "caseiro" sem assinatura (base64/GUID aceito só por decodificar), expiração não validada, senha fixa no código, comparação de segredo sem tempo constante, bypass de 2FA/pagamento sem checagem explícita de ambiente de desenvolvimento.
- **Autorização:** endpoint admin anônimo, checagem só no frontend, tenant/escopo/id do dono vindo do corpo da requisição em vez do token (IDOR), operação em massa sem filtro por dono.
- **Exposição:** exceção crua na resposta, stack trace, segredo em log, Swagger/diagnóstico habilitado fora de desenvolvimento, CORS `*` com credenciais, cabeçalhos de segurança removidos.
- **Segredos:** chave/token/connection string no código, em teste, em skill, CLAUDE.md ou memory.
- **Mutações de dinheiro, crédito, acesso ou saldo:** sem idempotência (chave única), sem transação atômica, sujeitas a replay ou corrida (teste negativo não substitui teste de concorrência).
- **Dependência nova:** origem, manutenção, permissões que pede.

Para cada achado: como seria explorado (1 linha) e o impacto.
