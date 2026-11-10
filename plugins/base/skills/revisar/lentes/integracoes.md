# Lente: integrações e mensageria

Chamada a serviço externo, webhook, fila, job ou comunicação entre módulos: o que acontece quando o outro lado falha, atrasa ou repete?

- **Timeout explícito** em toda chamada que sai do processo (o padrão da biblioteca costuma ser longo demais). Em .NET: `HttpClient` via `IHttpClientFactory` com `Timeout`/política definidos.
- **Retry só em falha transitória** (429, 503, timeout), com espera crescente e jitter; falha definitiva (404, 401, 403, 400) não repete. Sem retry em operação sem idempotência.
- **Circuit breaker** (ex.: Polly) quando o serviço externo cair seguido: parar de tentar por um período em vez de prender todas as requisições.
- **Idempotência no executor, não só na borda:** chave (`tipo + id de origem + parcela`) verificada **antes** de gravar, com índice único no banco; proteção só na API não vale se a conexão cai e o cliente repete.
- **Webhook recebido:** assinatura verificada sobre o corpo **cru** (antes de desserializar), segredo por destino, id do evento como chave de idempotência, responder rápido e processar depois, e caminho de conciliação sob demanda (não depender só da notificação para creditar algo).
- **Fila/mensageria:** ack só **depois** de processar; fila de descarte (DLQ) com contador de tentativas; consumidor idempotente (entrega pode repetir); mensagem versionada, consumidor tolera campo desconhecido.
- **Cliente de integração:** traduz o payload externo para tipos do domínio; DTO externo não vaza para dentro. Job idempotente (procura antes de inserir).
- **Notificação após persistir** (e-mail, mensagem): falha logada, nunca relançada; envio crítico via outbox.
- **Partida com configuração remota:** falha transitória → tentar de novo com espera; nunca seguir com valor vazio (troca erro claro por falha obscura).

Para cada achado: o que acontece na falha do outro lado (1 linha) e o impacto (efeito duplicado, perda, travamento).
