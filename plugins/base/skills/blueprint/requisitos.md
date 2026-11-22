# Requisitos não funcionais (checklist do blueprint)

Para cada item: **se aplica** (critério verificável) ou **não se aplica** (motivo em uma linha).

| Requisito | Perguntas |
|---|---|
| Segurança | Quem pode acessar? Entrada validada no backend? Segredos fora do código? Superfície nova (endpoint, upload, integração)? |
| LGPD / dados pessoais | Coleta dado pessoal? Finalidade e minimização? Aparece em log, cache, URL ou terceiro? Retenção e exclusão? |
| Testes e aceite | Qual teste prova que funciona? Qual reproduz o bug? Critério de aceite verificável? |
| Observabilidade | O que é logado (sem dado pessoal/segredo)? Como saber que falhou em produção? |
| Desempenho | Volume esperado? Consulta em laço, paginação, índice? Limite de tempo? |
| Acessibilidade | (UI) Teclado, rótulos, contraste, foco? |
| Migração e rollback | Muda schema ou dado? Como reverter? Ordem do deploy (config/schema antes do código)? |
| Compatibilidade | Quebra contrato de API, cliente antigo, versão de runtime? |
| Custo | Infraestrutura, chamadas pagas, armazenamento? |
| Operação | Configuração nova no servidor? Job/worker afetado? Documentação para quem opera? |
