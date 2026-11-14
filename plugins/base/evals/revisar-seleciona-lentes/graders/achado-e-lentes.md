---
type: llm
---

PASS se a resposta (1) aponta a injeção de SQL pela concatenação do parâmetro `nome`, (2) cita falta de autorização/endpoint sem restrição ou a falta de teste, (3) escolhe lentes com gatilho no diff (segurança e testes, no mínimo) em vez de aplicar todas as lentes, e (4) termina com uma seção do tipo "Não verifiquei" ou "Lentes não aplicadas".
FAIL se não aponta a injeção de SQL, se aplica todas as 11 lentes por padrão ou se apresenta a revisão como aprovação do PR.
