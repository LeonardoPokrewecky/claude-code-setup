---
name: layout-responsivo
description: Projeta e verifica layouts responsivos de 320 px a telas largas (sem estouro horizontal, alvos de toque, texto legível, tabelas e formulários adaptáveis), com verificação nas três larguras. Só roda com /layout-responsivo [tela ou caminho].
disable-model-invocation: true
argument-hint: "[tela | caminho do repo]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar a tela). Leitura livre; alterar estilos é edição dentro do escopo autorizado. Verificação visual só em ambiente local, com dado sintético.

## 1. Abordagem
Mobile primeiro; pontos de quebra pelo conteúdo, não por aparelho. Verificar sempre em **320, 768 e 1280 px**. Usar tokens do `/sistema-de-design`.

## 2. Regras
- **Sem rolagem horizontal** da página em nenhuma largura (`overflow-x` escondido não conta como correção).
- Layout fluido (flex/grid, `min()`/`clamp()`, `minmax`), sem largura fixa em pixels para contêineres; imagens e mídia com `max-width: 100%`.
- **Alvos de toque** de pelo menos 44×44 px, com espaço entre eles; ações principais ao alcance do polegar.
- Texto legível sem zoom (≥ 16 px em campo de formulário para evitar zoom no iOS); linha com 45 a 75 caracteres em texto corrido.
- **Tabelas:** em tela estreita, virar cartões/lista ou rolar dentro do próprio contêiner, com cabeçalho claro.
- **Formulários:** uma coluna no estreito, rótulo visível, teclado certo por tipo de campo, erro junto do campo.
- **Navegação:** menu recolhível, sem esconder ação essencial; foco por teclado preservado.
- Respeitar `safe-area` (entalhe/barra) e orientação retrato/paisagem.

## 3. Verificação
Renderizar nas três larguras (ferramenta do navegador ou teste automatizado de largura, ver `/automacao-e2e`) e checar: estouro horizontal, sobreposição, corte de texto, alvos pequenos, contraste. Corrigir também as **telas irmãs** que usam o mesmo componente.

## Saída
Tabela `tela | 320 | 768 | 1280 | problema | correção` e "Não verifiquei:" (ex.: aparelhos reais, navegadores não testados, telas não renderizadas).
