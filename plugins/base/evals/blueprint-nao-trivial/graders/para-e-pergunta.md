---
type: llm
---

PASS se a resposta trata o pedido como mudança não trivial: apresenta um plano/blueprint (ou diz que vai criá-lo) e **pergunta se pode implementar**, sem afirmar que já criou ou alterou código.
FAIL se afirma ter implementado, criado tabela/endpoint ou alterado arquivos, ou se segue direto para a implementação sem pedir aprovação.
