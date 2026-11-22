---
name: sistema-de-design
description: Define ou audita o sistema de design de uma interface (tokens de cor, espaço, tipografia, elevação e raio; temas claro/escuro; contraste; consistência e reaproveitamento), com opções de abordagem. Só roda com /sistema-de-design [caminho ou "auditar"].
disable-model-invocation: true
argument-hint: "[caminho do repo] | auditar"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar se é criar ou auditar). Leitura livre; criar/alterar estilos é edição de código dentro do escopo autorizado. Respeitar o que o projeto já usa (Angular Material, Tailwind, CSS próprio) antes de propor troca: em projeto existente, o sistema implementado prevalece e mudança precisa de motivo. Referência externa: `/referencias-visuais`.

## 1. Levantar
Marca e público, bibliotecas de UI existentes, temas exigidos (claro/escuro), acessibilidade alvo (WCAG AA), e o estado atual (Grep por cores/medidas fixas repetidas, `!important`, estilos duplicados).

## 2. Tokens (fonte única de verdade)
- **Cor:** papéis semânticos (superfície, texto, primária, perigo, sucesso, borda), não cores soltas; cada papel com valor claro e escuro.
- **Espaço:** escala fixa (ex.: 4, 8, 12, 16, 24, 32 px). **Tipografia:** poucas famílias, escala de tamanhos e pesos, altura de linha. **Elevação e raio:** 3 a 4 níveis.
- Implementados como variáveis (CSS custom properties ou o mecanismo do framework); componentes consomem tokens, nunca valor literal.

## 3. Opções (validar na implementação)
| Opção | Quando favorece |
|---|---|
| **Biblioteca pronta** (Angular Material, etc.) + tema com tokens | Prazo curto, consistência garantida, acessibilidade embutida |
| **Utilitários** (Tailwind) com tokens no tema | Equipe confortável com utilitários, muita customização |
| **Sistema próprio** sobre variáveis CSS | Identidade forte, produto de longo prazo, equipe de design |

## 4. Regras
Contraste mínimo AA (4,5:1 texto normal, 3:1 texto grande e componentes) nos dois temas; foco visível; respeitar `prefers-color-scheme` e `prefers-reduced-motion`; reaproveitar componente antes de criar; mudar um token deve propagar para a aplicação inteira; documentar os tokens num lugar só.

## 5. Se `auditar`
Listar valores literais repetidos que deveriam ser token, cores sem par no outro tema, contrastes abaixo do mínimo e componentes duplicados, com `arquivo:linha`.

## Saída
Tabela de tokens (`papel | claro | escuro | uso`) ou de achados (`arquivo:linha | problema | token sugerido`), a abordagem recomendada com o critério que a decide e "Não verifiquei:" (ex.: telas não renderizadas, contraste real no navegador — conferir com a `/inspecao-visual`).
