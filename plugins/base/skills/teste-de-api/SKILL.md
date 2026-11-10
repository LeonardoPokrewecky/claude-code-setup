---
name: teste-de-api
description: Valida endpoints de uma API (status, corpo, validação de entrada, autenticação/autorização, limites, idempotência, contrato) com casos de teste e evidência, em ambiente de teste. Não usa produção nem dado real. Só roda com /teste-de-api [caminho ou endpoint].
disable-model-invocation: true
argument-hint: "[caminho do repo | endpoint]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar o escopo). Leitura do código é livre; **executar chamadas só contra ambiente local/homologação com dado sintético**, nunca produção nem dado real. Nunca ler `.env` nem exibir token/segredo (nos exemplos, usar `$TOKEN`). Para escrever testes automatizados do projeto, usar `/criar-testes`.

## 1. Levantar
Listar os endpoints (Grep por rotas/controllers), contrato (OpenAPI/DTOs), autenticação exigida e o ambiente de teste disponível. O que não puder ser executado fica como "não executado", nunca como aprovado.

## 2. Casos por endpoint
- **Sucesso:** status e corpo esperados, cabeçalhos (`Content-Type`, cache), formato de erro padronizado.
- **Entrada inválida:** vazio, tipo errado, tamanho máximo e um acima, caractere especial/Unicode, campo extra, JSON malformado. Resposta 4xx, **nunca 5xx**.
- **Autenticação/autorização:** sem token (401), token expirado/adulterado (401), perfil sem permissão (403), **acesso cruzado** a recurso de outra conta/tenant (403/404).
- **Idempotência e concorrência:** operação com efeito repetida não duplica; duas escritas simultâneas.
- **Limites:** paginação (página vazia, tamanho máximo), limite de taxa, tamanho de upload.
- **Contrato:** campos, tipos e status batem com o contrato; divergência é achado.
- **Erro e vazamento:** mensagem de erro sem stack trace, caminho, SQL ou dado de outro usuário.

## 3. Execução e evidência
Cada caso registra requisição (sem segredo), resposta e veredito. Resultado: **aprovado**, **reprovado** (com motivo reproduzível) ou **pulado** (com o motivo; falta de insumo nunca é aprovação).

## Saída
Tabela `endpoint | caso | esperado | obtido | veredito | evidência`, divergências de contrato, falhas de segurança em destaque, e "Não verifiquei:" (ex.: ambiente indisponível, endpoints sem contrato, carga). Automatizar o que passou como regressão (`/regressao-e-smoke`).
