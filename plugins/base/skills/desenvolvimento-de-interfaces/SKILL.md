---
name: desenvolvimento-de-interfaces
description: Coordena trabalho de frontend (criar, auditar ou corrigir telas, páginas e componentes web) — escolhe o modo, ativa só as especialidades de interface necessárias, planeja UX e fecha com inspeção no navegador e testes. Use quando a tarefa for criar ou alterar interface, auditar uma aplicação web ou corrigir problema visual/de layout.
argument-hint: "[criar | auditar | corrigir] [tela, rota ou caminho]"
---

# Desenvolvimento de interfaces (orquestração)

Alvo: `$ARGUMENTS`. Esta skill decide **o que** ativar; cada especialidade está no seu arquivo e só é lida quando entra no plano. Segue o fluxo do `CLAUDE.md` global (blueprint e aprovação para o que não é trivial; nada pronto sem build, teste e inspeção).

## 1. Modo
| Modo | Quando | Regra |
|---|---|---|
| **criar** | tela, página, componente ou fluxo novo | blueprint → implementar → inspecionar → testar → revisar |
| **auditar** | avaliar o que existe | **não alterar nenhum arquivo**; entregar achados priorizados e propostas para aprovação |
| **corrigir** | problema visual, de layout ou de interação | reproduzir no navegador → causa → mudança mínima → reinspecionar o mesmo ponto |

Sem modo explícito: deduzir do pedido e dizer em uma linha qual foi escolhido.

## 2. Especialidades (ler só as que o plano usa)
| Especialidade | Arquivo | Entra quando |
|---|---|---|
| Referências | [referencias-visuais](../referencias-visuais/SKILL.md) | tela nova de categoria conhecida (dashboard, ERP, landing) sem padrão no projeto |
| Sistema de design | [sistema-de-design](../sistema-de-design/SKILL.md) | projeto novo, tokens faltando, cor/medida literal repetida |
| Componentes e estados | [componentes-e-estados](../componentes-e-estados/SKILL.md) | componente novo ou alterado, formulário, tabela, modal |
| Responsividade | [layout-responsivo](../layout-responsivo/SKILL.md) | layout novo ou alterado, problema em tela estreita |
| Inspeção no navegador | [inspecao-visual](../inspecao-visual/SKILL.md) | sempre que a aplicação puder rodar localmente |
| Testes E2E e visuais | [automacao-e2e](../automacao-e2e/SKILL.md) | fluxo crítico novo ou alterado, regressão visual |
| Acessibilidade e revisão | `/revisar a11y`, `/revisar interface` ([a11y](../revisar/lentes/a11y.md), [interface](../revisar/lentes/interface.md)) | toda entrega de tela; em auditoria, sempre |
| Arquitetura do framework | `arquitetura-angular` (plugin `angular`) ou o `CLAUDE.md` do projeto | onde o código deve ficar |

Seleção orientativa: botão → componentes; formulário → UX + componentes + a11y + testes; dashboard → referências + design + componentes + responsividade; layout mobile quebrado → responsividade + inspeção; auditoria → UX + inspeção + a11y + interface; regressão visual → inspeção + testes. Tarefa pequena não vira processo: uma especialidade basta quando resolve.

## 3. Entender e analisar (antes de planejar)
- Objetivo, público, critério de aceite e restrições. Requisito essencial indefinido: perguntar antes de implementar algo complexo; não inventar campo, tela ou comportamento.
- Projeto existente: stack, rotas, componentes, tokens/tema, padrões e testes **reais** (Grep/Glob; não presumir biblioteca). O que já funciona é preservado.
- Projeto novo: frontend é um projeto separado do backend (regra do `project-bootstrap`).

## 4. UX e estrutura (página ou fluxo novo)
No blueprint, antes do código: perfis de usuário e tarefa principal; jornada (entrada → ação → resultado → erro); hierarquia da página (o que é visto primeiro, ação primária única por área, secundárias discretas); navegação e rotas; estados de cada tela; o que pode ser removido para simplificar. Proporcional à complexidade: um componente não precisa de jornada.

## 5. Implementar
Respeitar arquitetura, convenções, tokens e componentes existentes; reutilizar antes de criar; mudança só no escopo. Implementação grande e independente pode ir para `implementer-sonnet` (arquivos definidos); nunca dois agentes nos mesmos arquivos.

## 6. Validar (depois de cada correção também)
1. Build e testes existentes (`test-validator-haiku` quando o volume compensar).
2. `inspecao-visual` nas rotas tocadas e nas larguras escolhidas, com console e rede.
3. Testes novos só para fluxo ou estado que justifique (sem teste artificial).
4. `/revisar a11y` e `/revisar interface` (o usuário digita; sugerir).
Problema encontrado → corrigir → reexecutar só o que foi afetado. Sem navegador ou sem ambiente: entregar **PARCIAL**, nunca "validado".

## 7. Dependências
Playwright é dependência autorizada da arquitetura (instalar no projeto continua exigindo pedido explícito). Qualquer outra: necessidade real, alternativa nativa, licença, manutenção e segurança avaliadas e aprovadas antes. Exemplo encontrado na internet não justifica dependência.

## Classificação de achados
**Crítico** impede função essencial · **Alto** compromete uma jornada · **Médio** prejudica a experiência ou é inconsistência relevante · **Baixo** melhoria sem impacto significativo. Cada achado: rota, largura, descrição, evidência (captura ou `arquivo:linha`), gravidade, causa provável, recomendação.

## Saída
Modo e especialidades usadas (uma linha); o que foi feito (telas, componentes `arquivo:linha`); validação executada de verdade (comandos, rotas × larguras, resultado); achados por gravidade; limitações e "Não verifiquei:". Nunca dizer que testou o que não rodou.
