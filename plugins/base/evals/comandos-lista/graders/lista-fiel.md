---
type: llm
---

PASS se a resposta mostra a lista de comandos do pacote agrupada por plugin (base, dotnet, angular), cada comando com um resumo curto de uma linha, e termina indicando o `/help` para os comandos nativos. Não pode executar nenhum dos comandos listados.
FAIL se a lista estiver incompleta de forma evidente (só alguns comandos sem filtro pedido), se inventar comandos que não existem no pacote, se mostrar descrições longas de vários parágrafos ou se executar algum comando.
