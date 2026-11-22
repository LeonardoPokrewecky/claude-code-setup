---
max_turns: 3
allowed_tools: [Skill, Read]
---

Contexto carregado do CLAUDE.md global (índice de skills manuais):

# Skills manuais (o usuário digita; sugerir o comando certo quando o assunto pedir)

## Segurança
- `/endurecimento-de-infraestrutura` — endurecer servidor, rede, firewall e contêiner
- `/lgpd-audit` — auditar dado pessoal e conformidade LGPD

## Dados
- `/alterar-dados` — mudar dados em massa (backup, dry-run, canário)
- `/escolha-de-banco-e-capacidade` — escolher banco e dimensionar capacidade
- `/plano-migracao` — planejar migração de esquema ou de sistema

## Interface
- `/componentes-e-estados` — projetar componentes, variantes e estados de tela
- `/inspecao-visual` — inspecionar a tela no navegador em várias larguras
- `/layout-responsivo` — corrigir ou planejar layout responsivo
- `/padroes-de-pagina` — definir botões, telas de configuração e usabilidade
- `/referencias-visuais` — pesquisar referências de interface
- `/sistema-de-design` — definir ou auditar tokens, temas e contraste

## Qualidade
- `/automacao-e2e` — escrever testes de interface ponta a ponta
- `/criar-testes` — criar testes para código novo ou sem cobertura
- `/laudo-de-evidencia` — gerar laudo de validação com evidência
- `/limpar-codigo` — remover código morto e simplificar com segurança
- `/medir-antes-depois` — provar que uma correção ou ganho de desempenho é real
- `/regressao-e-smoke` — definir smoke pós-publicação e regressão pré-entrega
- `/revisar` — revisar o diff ou um PR após implementar
- `/teste-de-api` — testar endpoints de API (contrato, erro, autorização)

## Entrega
- `/deploy-checklist` — antes de publicar em produção
- `/preparar-pr` — preparar o pull request (título, descrição, checagens)
- `/responder-revisao` — tratar comentários de revisão de um PR

## Produto
- `/adr` — registrar uma decisão de arquitetura
- `/divida` — registrar ou listar dívida técnica
- `/historias-de-usuario` — escrever histórias de usuário e critérios de aceite
- `/metricas-de-produto` — definir métricas e instrumentação de produto
- `/priorizacao` — priorizar backlog por valor, risco e esforço

## Operação
- `/comandos` — listar os comandos do pacote
- `/comunicacao-de-status` — redigir relatório de andamento
- `/explicar` — mapear módulo ou fluxo para onboarding
- `/postmortem` — documentar um incidente já resolvido
- `/session-handoff` — continuar o trabalho em outra sessão

Pedido do usuário: preciso mudar o status de 40 mil pedidos antigos de "aberto" para "cancelado". Como faço isso com segurança?
