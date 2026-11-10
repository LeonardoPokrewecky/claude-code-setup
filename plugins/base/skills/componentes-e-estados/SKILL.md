---
name: componentes-e-estados
description: Projeta componentes de interface reutilizáveis com variantes, estados de interação (hover, foco, ativo, desabilitado, erro) e os estados de tela (carregando, vazio, erro, sucesso, parcial), com acessibilidade. Só roda com /componentes-e-estados [componente ou tela].
disable-model-invocation: true
argument-hint: "[componente | tela]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar o componente ou a tela). Leitura livre; criar/alterar componente é edição dentro do escopo autorizado. Reaproveitar componente existente antes de criar outro (Grep no projeto). Tokens: `/sistema-de-design`.

## 1. Componente
- **API mínima e clara:** entradas tipadas, saídas por evento, sem conhecer a regra de negócio nem a origem dos dados (apresentacional); lógica de dados no contêiner/serviço.
- **Variantes** por propriedade (tamanho, tom, densidade), nunca por cópia do componente.
- **Estados de interação:** padrão, hover, foco visível, ativo, desabilitado, carregando, erro; todos com contraste AA e sem depender só de cor.
- **Acessibilidade:** elemento semântico certo (botão é `button`), rótulo acessível, navegação por teclado, `aria-*` só quando o HTML nativo não basta, anúncio de erro e de carregamento.
- **Composição:** slots/conteúdo projetado em vez de propriedades demais.

## 2. Cinco estados por tela (nenhum pode ficar em branco)
1. **Carregando:** indicador ou esqueleto, sem pulo de layout.
2. **Vazio:** explica por que está vazio e oferece a próxima ação.
3. **Erro:** mensagem compreensível, sem detalhe técnico, com "tentar de novo" e sem perder o que o usuário digitou.
4. **Sucesso/Dados:** o estado normal, inclusive com muito conteúdo e texto longo.
5. **Parcial/Offline:** dados antigos, falha de uma parte, ação pendente.
Formulário: validação junto do campo, envio desabilita o botão (evita duplo envio), confirmação de ação destrutiva.

## 3. Teste
Um teste por estado e por variante relevante (ver `/criar-testes`), incluindo foco por teclado e leitor de tela nos fluxos principais.

## Saída
Tabela `componente | variantes | estados cobertos | lacunas`, a tela com os cinco estados descritos e "Não verifiquei:" (ex.: leitor de tela real, navegadores, telas não renderizadas).
