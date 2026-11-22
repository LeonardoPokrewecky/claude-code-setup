# Tela de configurações

O padrão do projeto prevalece; isto é o ponto de partida. Segredo, sessão e permissão: `/autenticacao-e-sessao` e `/gestao-de-segredos`. Dado pessoal: `/lgpd-audit`.

## Contrato mínimo
1. **Seções agrupadas** por assunto (abas ou âncoras), nome da seção na língua do usuário.
2. **Rótulo visível e ajuda no ponto de uso** para o que não é óbvio; mostrar o valor atual.
3. **Um único modelo de gravação por página, sem misturar:**
   - *Salvar explícito:* botões Salvar e Descartar, aviso ao sair com alteração não salva.
   - *Aplicar na hora:* interruptor que grava ao mudar, com confirmação visível do resultado.
4. **Valor padrão seguro** e "Restaurar padrão" onde fizer sentido.
5. **Ação perigosa** (excluir conta, revogar acesso, limpar dados) em seção separada, com confirmação que nomeia o efeito.
6. **Segredo e chave:** mascarados; revelar só por ação explícita; nunca em URL, log ou mensagem de erro; reautenticar para ver ou trocar.
7. **Privacidade e consentimento (LGPD):** opção **nunca pré-marcada**; revogar tão fácil quanto conceder; dizer a finalidade em uma frase.
8. **Configuração sensível** (segurança, pagamento, permissões) pede reautenticação e registra quem mudou e quando.
9. **Feedback:** mostrar o que mudou e quando; erro de gravação diz o que fazer e não perde o que foi digitado.

## Falhas comuns (viram achado)
| Falha | Gravidade usual |
|---|---|
| Interruptores que gravam na hora **e** botão Salvar no rodapé | Alto |
| Consentimento pré-marcado ou revogação escondida | Alto |
| Segredo exibido em claro | Crítico |
| Ação perigosa sem confirmação, ou misturada às demais | Alto |
| Alteração não salva perdida ao sair sem aviso | Médio |
| Opção sem ajuda onde o efeito não é óbvio | Baixo |
