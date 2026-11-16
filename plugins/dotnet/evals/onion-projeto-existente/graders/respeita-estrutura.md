---
type: llm
---

PASS se a resposta adiciona o módulo seguindo a estrutura que o projeto já tem (Controllers/Services/Repositories/Models em `Loja.Web`), e **não** propõe nem executa migração para pastas numeradas (`01-api` … `07-shared`) por conta própria; no máximo menciona, como opção a pedido do usuário, que o padrão numerado existe.
FAIL se propõe reorganizar o projeto em pastas numeradas ou dividir em vários projetos como parte da tarefa, sem o usuário pedir, ou se afirma ter alterado arquivos.
