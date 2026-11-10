---
name: integracoes
description: Projeta integrações com sistemas externos (API de terceiros, webhooks, filas, jobs) com timeout, nova tentativa, circuit breaker, idempotência, verificação de assinatura, fila de descarte, contrato e observabilidade, com opções por tipo de integração. Somente leitura e proposta; chamar serviço real ou alterar produção só com autorização. Só roda com /integracoes [integração ou caminho].
disable-model-invocation: true
argument-hint: "[integração ou caminho do repo]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar qual integração). **Somente leitura e proposta.** Nunca ler `.env` nem exibir chave/segredo de API; nunca chamar serviço de terceiros em produção nem com dado real sem autorização (usar sandbox/mock do provedor). Para **revisar** código de integração já escrito, usar `/revisar integracoes`. Recomendar sessão Opus se a atual for mais fraca e a integração envolver pagamento, dado pessoal ou autenticação.

## 1. Levantar (perguntar o que faltar, não supor)
Quem chama quem (entrada ou saída), síncrono ou assíncrono, volume e picos, o que acontece se o outro lado cair (o negócio pode esperar?), garantia exigida (no mínimo uma vez, no máximo uma vez), dado pessoal/financeiro trafegando, documentação e sandbox do provedor, limites (taxa, tamanho), versão e política de mudança do contrato.

## 2. Opções por tipo (a escolha é validada na implementação)
| Tipo | Quando favorece | Pontos de atenção |
|---|---|---|
| **Chamada HTTP síncrona** | Resposta necessária na hora, volume baixo/médio | Timeout, retry limitado, circuit breaker; falha do terceiro derruba o seu fluxo |
| **Fila/mensageria** | Pode esperar, picos, desacoplamento | Idempotência no consumidor, ordem, fila de descarte, monitorar atraso |
| **Webhook recebido** | Provedor avisa eventos | Verificar assinatura, rejeitar replay, responder rápido e processar em fila, idempotência por id do evento |
| **Webhook/callback enviado** | Você avisa terceiros | Assinar, nova tentativa com recuo, registro de entrega, desativar destino que falha sempre |
| **Job/lote agendado** | Sincronização periódica, arquivos | Execução única (trava distribuída), retomada do ponto, janela fora do pico |
| **Outbox + publicação** | Gravar no banco **e** publicar sem perder evento | Tabela outbox na mesma transação; publicador idempotente |

## 3. Padrões de resiliência
- **Timeout** em toda chamada externa (conexão e leitura), menor que o do chamador.
- **Nova tentativa** só em erro transitório e operação **idempotente**: recuo exponencial com jitter, número máximo, respeitar `Retry-After`. Nunca repetir cobrança/envio sem chave de idempotência.
- **Circuit breaker:** abrir após falhas seguidas, meio-aberto para testar, resposta alternativa definida (fila, cache, erro claro).
- **Bulkhead/limite de concorrência** por integração, para uma lenta não esgotar o pool.
- **Idempotência:** chave por operação (enviada ao provedor e/ou guardada com restrição única no seu banco); consumidor de fila trata o mesmo evento duas vezes.
- **Fila de descarte (DLQ):** mensagem que falha N vezes vai para a fila de descarte com motivo, alerta e forma de reprocessar.
- **Degradação planejada:** o que o sistema faz sem a integração (adiar, mostrar estado "pendente", reconciliar depois).

## 4. Segurança da integração
Segredo/credencial no cofre e rotacionável (`/gestao-de-segredos`); TLS e validação do certificado; **verificação de assinatura** (HMAC com comparação em tempo constante) e janela de tempo contra replay em webhooks (assinar/verificar o **corpo bruto** recebido, nunca o JSON reserializado); lista de origens permitidas quando o provedor publicar; mínimo de dados enviados (LGPD: base legal e contrato com o operador; ver `/lgpd-audit`); URL de destino fornecida pelo usuário protegida contra SSRF; resposta do terceiro tratada como entrada não confiável (validar formato e tamanho); nenhum dado sensível em log; credencial nunca na URL (vai para log e histórico); endpoint de webhook recebido sem autenticação própria limita tamanho e taxa.

## 5. Contrato e evolução
Contrato explícito (esquema/OpenAPI), versão, tolerância a campo novo, **camada anticorrupção** (mapear o modelo do terceiro para o seu, sem vazar para o domínio), teste de contrato e mock para desenvolvimento; plano para mudança de versão do provedor.

## 6. Observabilidade e operação
Log estruturado com id de correlação (sem segredo/dado pessoal), métricas (taxa de sucesso, latência, tentativas, tamanho da DLQ, estado do breaker), alerta de falha contínua e de atraso, tela/comando de reprocessamento, reconciliação periódica com o outro lado (fonte da verdade definida).

## 7. Testes a exigir
Sucesso; timeout; erro 5xx com retry e esgotamento; 4xx sem retry; resposta duplicada/evento repetido (idempotência); assinatura inválida e replay rejeitados; circuit breaker abre e fecha; mensagem envenenada vai para a DLQ; contrato do terceiro mudou (campo novo/ausente); carga com o terceiro lento.

## Saída
Opção recomendada **com o critério que a decide** (e o que a mudaria), desenho resumido (`etapa | quem | falha possível | tratamento`), parâmetros iniciais de timeout/retry/breaker marcados como hipótese a validar por teste, riscos (perda, duplicidade, vazamento, custo) e "Não verifiquei:" (ex.: comportamento real do provedor, limites contratuais, volume real, sandbox indisponível).
