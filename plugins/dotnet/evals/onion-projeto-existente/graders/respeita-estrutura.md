---
type: llm
---

PASS se a resposta adiciona o módulo seguindo a estrutura que o projeto já tem (Controllers/Services/Repositories/Models em `Loja.Web`), e **não** propõe nem executa migração para pastas numeradas (`01-api` … `09-tools`) por conta própria; no máximo menciona, como opção a pedido do usuário, que o padrão numerado existe.
FAIL se propõe reorganizar o projeto em pastas numeradas ou dividir em vários projetos, criar as pastas vazias do padrão ou renumerar `tests`/`tools` como parte da tarefa, sem o usuário pedir, ou se afirma ter alterado arquivos.
