---
name: inspecao-visual
description: Abre a aplicação no navegador com Playwright e inspeciona as rotas relevantes em várias larguras — capturas de tela, estouro horizontal, sobreposição, erros de console e requisições com falha, interações e comparação antes/depois. Somente ambiente local/homologação. Só roda com /inspecao-visual [rota, tela ou "auditar"].
disable-model-invocation: true
argument-hint: "[rota | tela | auditar] [larguras, ex.: 320,768,1280]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar as rotas). **Inspecionar não altera código.** Correção é outra etapa (`desenvolvimento-de-interfaces`, modo corrigir).

## 1. Ferramenta (nesta ordem)
1. **MCP do Playwright** (camada `playwright`, plugin oficial `playwright@claude-plugins-official`): ferramentas `browser_navigate`, `browser_resize`, `browser_take_screenshot`, `browser_snapshot`, `browser_console_messages`, `browser_network_requests`, `browser_evaluate`, `browser_click`/`browser_type`. Caminho padrão: sem código novo no projeto.
2. **`@playwright/test` já instalado no projeto:** script ou teste temporário fora de `src/` (apagar ao fim, ou virar teste de verdade via `/automacao-e2e` se o usuário quiser).
3. **Nenhum dos dois:** parar e propor ligar a camada `playwright` (merge-settings) ou instalar o Playwright no projeto. Instalar só com pedido explícito. Sem navegador, a entrega é **PARCIAL**.

## 2. Ambiente
- Só local ou homologação, com dado sintético. Nunca produção, nunca dado real de cliente sem autorização.
- Subir a aplicação com o comando de "Rodar local" do `CLAUDE.md` do projeto, em segundo plano; esperar a porta responder. Ao fim, encerrar o que foi iniciado.
- Login: só credencial de teste vinda de variável de ambiente ou User Secrets; nunca digitar senha visível no relato nem contornar autenticação. Sem credencial autorizada: inspecionar só o público e dizer o que ficou de fora.
- Nada destrutivo ou irreversível (excluir, pagar, enviar e-mail): parar e perguntar.

## 3. Mapa de rotas
Levantar as rotas pelo roteador do projeto (ex.: `app.routes.ts`, `pages/`, `routes/`), não só a página inicial. Priorizar: rotas tocadas pela mudança, telas irmãs que usam o mesmo componente, fluxos principais. Rota com parâmetro: um id sintético.

## 4. Larguras (CSS px)
Matriz: 320 · 375 · 390 · 430 (mobile) · 700 · 768 · 1024 (tablet) · 1280 · 1440 · 1920 (desktop). **Escolher, não varrer tudo:** mínimo 320, 768 e 1280; somar os pontos de quebra reais do CSS (±1 px em volta), 1024 quando houver menu lateral ou tabela larga, e 1920 para telas de painel. Paisagem, toque, densidade de pixel e `prefers-reduced-motion` só quando a tela depender deles.

## 5. Por rota × largura
1. `browser_resize` → `browser_navigate` → esperar condição visível (elemento, fim da rede), nunca tempo fixo.
2. **Estouro horizontal** (`browser_evaluate`): `document.documentElement.scrollWidth > document.documentElement.clientWidth`; se sim, listar os culpados: `[...document.querySelectorAll('body *')].filter(e => e.getBoundingClientRect().right > innerWidth + 1).slice(0, 10).map(e => e.tagName + '.' + e.className)`.
3. **Captura** da página inteira; olhar a imagem: desalinhamento, sobreposição, texto cortado, botão fora da área visível, hierarquia confusa, campo com tamanho errado.
4. **Console** (erros e avisos novos) e **rede** (status ≥ 400, falhas, chamadas lentas ou repetidas).
5. **Interações** do escopo: abrir/fechar modal e menu, enviar formulário vazio e inválido, filtro, paginação, foco por teclado (Tab até a ação principal, foco visível).
6. Antes/depois: em correção, a mesma rota e largura antes e depois, lado a lado.

Muitas rotas × larguras: delegar a leitura das capturas não compensa; manter na sessão e reduzir a matriz.

## 6. Evidência e dados
Capturas ficam fora do repositório (pasta de documentação do `CLAUDE.md`, subpasta `inspecao/AAAA-MM-DD/`, ou a pasta temporária do MCP). Nunca capturar tela com segredo, token ou dado pessoal real; nunca registrar token de log ou de rede no relato.

## Saída
Tabela `rota | largura | problema | evidência | gravidade (Crítico/Alto/Médio/Baixo) | causa provável | recomendação`, depois console e rede por rota (ou "sem erros"), a matriz realmente executada e "Não verifiquei:" (rotas sem acesso, navegadores não testados, aparelhos reais).
