# Lente: segurança ofensiva

Pensar como atacante: o que alguém de fora (ou um usuário autenticado de outro tenant) consegue fazer com este diff?

- **Injeção:** SQL/NoSQL montado com concatenação, comando de shell com entrada do usuário, XSS (HTML sem escape, `innerHTML`, `bypassSecurityTrust*`), template injection, path traversal (`../` em nome de arquivo), desserialização de tipo arbitrário.
- **Entrada:** validação só no frontend; tamanho sem limite (`[MaxLength]`, `maxlength`); upload sem checagem de tipo/tamanho; redirecionamento aberto.
- **Autenticação:** token "caseiro" sem assinatura (base64/GUID aceito só por decodificar), expiração não validada, senha fixa no código, comparação de segredo sem tempo constante, bypass de 2FA/pagamento sem checagem explícita de ambiente de desenvolvimento.
- **Autorização:** endpoint admin anônimo, checagem só no frontend, tenant/escopo/id do dono vindo do corpo da requisição em vez do token (IDOR), operação em massa sem filtro por dono.
- **Autorização por recurso:** endpoint que recebe id precisa negar leitura, listagem, alteração e exclusão do recurso de **outra conta**; ler o código não prova, o teste usa duas contas reais. O dono vem do vínculo canônico, não de cópia gravada no registro filho (quebra após transferência).
- **Atribuição em massa (over-posting):** entrada copiada inteira para a entidade deixa o cliente alterar perfil, situação ou saldo. Usar DTO de entrada só com os campos editáveis; ao reaproveitar serviço interno em endpoint de cliente, zerar os campos de plataforma.
- **SSRF:** endpoint que busca URL informada pelo usuário sem lista de destinos permitidos (inclui IP interno e metadados de nuvem).
- **Regex e ReDoS:** expressão montada com texto do usuário; quantificador aninhado sem timeout (retrocesso catastrófico). Em .NET, usar `Regex` com `matchTimeout`.
- **Tentativas de login:** limite por identidade **e** por origem, bloqueando na tentativa que atinge o limite; nunca persistir a senha tentada; resposta sem revelar se o usuário existe (mas com erro claro).
- **Exposição:** exceção crua na resposta, stack trace, segredo em log, Swagger/diagnóstico habilitado fora de desenvolvimento, CORS `*` com credenciais, cabeçalhos de segurança removidos, source map (`*.map`) ou PDB no pacote servido, listagem administrativa devolvendo a entidade de usuário (hash da senha) em vez de um `View`.
- **Segredos:** chave/token/connection string no código, em teste, em skill, CLAUDE.md ou memory.
- **Mutações de dinheiro, crédito, acesso ou saldo:** sem idempotência (chave única), sem transação atômica, sujeitas a replay ou corrida (teste negativo não substitui teste de concorrência).
- **Dependência nova:** origem, manutenção, permissões que pede.

Achado de relatório automatizado (scanner, `/security-review`) não vale por si: confirmar a rota real no código, reproduzir o comportamento e comparar a data do registro com a da última correção antes de classificar. Se não reproduz, não é achado.

Para cada achado: como seria explorado (1 linha) e o impacto.
