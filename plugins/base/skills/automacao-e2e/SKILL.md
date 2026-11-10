---
name: automacao-e2e
description: Planeja e escreve testes de interface ponta a ponta estáveis (seletores, esperas, dados sintéticos, isolamento, evidência por caso), com opções de ferramenta. Executa só em ambiente local/homologação. Só roda com /automacao-e2e [fluxo ou caminho].
disable-model-invocation: true
argument-hint: "[fluxo | caminho do repo]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar os fluxos). Escrever testes é edição de código: seguir o escopo autorizado. **Executar só contra ambiente local/homologação com dado sintético**; nunca produção nem dado real. Credencial de teste vem de variável de ambiente ou User Secrets, nunca no teste, no repositório ou em captura de tela. Instalar ferramenta/pacote só com pedido explícito.

## 1. Escolher o que automatizar
Poucos fluxos de alto valor: login, o caminho principal de negócio, pagamento/operação crítica, permissão. O resto fica em testes de unidade e de API (mais rápidos e estáveis).

## 2. Opções de ferramenta (validar na implementação)
| Opção | Quando favorece |
|---|---|
| **Playwright** | Multi-navegador, esperas automáticas, rastreio e vídeo embutidos; boa escolha padrão |
| **Cypress** | Time já familiarizado, ótimo depurador; um navegador por vez na execução |
| **Testes de componente** (do próprio framework) | Quando o fluxo não precisa do sistema inteiro |

## 3. Estabilidade
- Seletor por papel/rótulo acessível ou `data-testid`; nunca por classe de estilo ou posição.
- Esperar por condição observável (elemento, resposta de rede), nunca por `sleep` fixo.
- Cada teste independente: cria seus dados e os limpa; sem ordem entre testes.
- Dado sintético e determinístico; relógio e serviços externos simulados.
- Verificar o **resultado visível ao usuário**, não detalhes de implementação; incluir caminho de erro e estados vazio/carregando.
- Responsividade e acessibilidade básica nas larguras 320, 768 e 1280 px (ver `/layout-responsivo`).

## 4. Evidência
Cada caso guarda captura e/ou rastreio em falha, sem expor dado pessoal ou segredo na imagem. Relatório consolidado: `/laudo-de-evidencia`.

## Saída
Plano `fluxo | casos | dados | risco de instabilidade`, os testes escritos (se autorizados), como executar e "Não verifiquei:" (ex.: navegador não disponível, ambiente indisponível, fluxo dependente de serviço externo).
