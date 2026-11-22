# Area e "quando usar" das skills MANUAIS (disable-model-invocation: true) para o indice core/indice-skills.md,
# gerado por scripts/gerar-docs.ps1. Toda skill manual aparece aqui uma vez (tests/estrutura.Tests.ps1).
# Quando: ate 70 caracteres. Ordem das areas: a da lista abaixo.
@{
    Areas = @('Segurança', 'Dados', 'Interface', 'Qualidade', 'Entrega', 'Produto', 'Operação')
    Skills = @{
        'lgpd-audit'                    = @{ Area = 'Segurança'; Quando = 'auditar dado pessoal e conformidade LGPD' }
        'endurecimento-de-infraestrutura' = @{ Area = 'Segurança'; Quando = 'endurecer servidor, rede, firewall e contêiner' }
        'alterar-dados'                 = @{ Area = 'Dados'; Quando = 'mudar dados em massa (backup, dry-run, canário)' }
        'escolha-de-banco-e-capacidade' = @{ Area = 'Dados'; Quando = 'escolher banco e dimensionar capacidade' }
        'plano-migracao'                = @{ Area = 'Dados'; Quando = 'planejar migração de esquema ou de sistema' }
        'componentes-e-estados'         = @{ Area = 'Interface'; Quando = 'projetar componentes, variantes e estados de tela' }
        'inspecao-visual'               = @{ Area = 'Interface'; Quando = 'inspecionar a tela no navegador em várias larguras' }
        'layout-responsivo'             = @{ Area = 'Interface'; Quando = 'corrigir ou planejar layout responsivo' }
        'padroes-de-pagina'             = @{ Area = 'Interface'; Quando = 'definir botões, telas de configuração e usabilidade' }
        'referencias-visuais'           = @{ Area = 'Interface'; Quando = 'pesquisar referências de interface' }
        'sistema-de-design'             = @{ Area = 'Interface'; Quando = 'definir ou auditar tokens, temas e contraste' }
        'automacao-e2e'                 = @{ Area = 'Qualidade'; Quando = 'escrever testes de interface ponta a ponta' }
        'criar-testes'                  = @{ Area = 'Qualidade'; Quando = 'criar testes para código novo ou sem cobertura' }
        'laudo-de-evidencia'            = @{ Area = 'Qualidade'; Quando = 'gerar laudo de validação com evidência' }
        'limpar-codigo'                 = @{ Area = 'Qualidade'; Quando = 'remover código morto e simplificar com segurança' }
        'medir-antes-depois'            = @{ Area = 'Qualidade'; Quando = 'provar que uma correção ou ganho de desempenho é real' }
        'regressao-e-smoke'             = @{ Area = 'Qualidade'; Quando = 'definir smoke pós-publicação e regressão pré-entrega' }
        'revisar'                       = @{ Area = 'Qualidade'; Quando = 'revisar o diff ou um PR após implementar' }
        'teste-de-api'                  = @{ Area = 'Qualidade'; Quando = 'testar endpoints de API (contrato, erro, autorização)' }
        'deploy-checklist'              = @{ Area = 'Entrega'; Quando = 'antes de publicar em produção' }
        'preparar-pr'                   = @{ Area = 'Entrega'; Quando = 'preparar o pull request (título, descrição, checagens)' }
        'responder-revisao'             = @{ Area = 'Entrega'; Quando = 'tratar comentários de revisão de um PR' }
        'adr'                           = @{ Area = 'Produto'; Quando = 'registrar uma decisão de arquitetura' }
        'divida'                        = @{ Area = 'Produto'; Quando = 'registrar ou listar dívida técnica' }
        'historias-de-usuario'          = @{ Area = 'Produto'; Quando = 'escrever histórias de usuário e critérios de aceite' }
        'metricas-de-produto'           = @{ Area = 'Produto'; Quando = 'definir métricas e instrumentação de produto' }
        'priorizacao'                   = @{ Area = 'Produto'; Quando = 'priorizar backlog por valor, risco e esforço' }
        'comandos'                      = @{ Area = 'Operação'; Quando = 'listar os comandos do pacote' }
        'comunicacao-de-status'         = @{ Area = 'Operação'; Quando = 'redigir relatório de andamento' }
        'explicar'                      = @{ Area = 'Operação'; Quando = 'mapear módulo ou fluxo para onboarding' }
        'postmortem'                    = @{ Area = 'Operação'; Quando = 'documentar um incidente já resolvido' }
        'session-handoff'               = @{ Area = 'Operação'; Quando = 'continuar o trabalho em outra sessão' }
    }
}
