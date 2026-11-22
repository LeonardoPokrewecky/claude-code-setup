# Modelo: `docs/ux-padroes.md` (um por projeto, no repositório do frontend)

Este arquivo é só o **esqueleto**. O padrão real nasce do levantamento das telas do projeto (modo `criar` da `/padroes-de-pagina`) e é revisado em PR como o código. Escrever curto, com o que o projeto **de fato** faz; nada de segredo, dado real ou nome de cliente. Exemplos de tela usam dado sintético.

No `CLAUDE.md` do projeto, uma linha: `Padrões de UX: docs/ux-padroes.md`.

## Arquivo do projeto

```
---
versao: 1
atualizado-em: AAAA-MM-DD
---
```

### 1. Tipos de página
Para cada tipo usado no projeto (listagem, formulário, detalhe, painel, outros): estrutura da página de cima para baixo, qual é a **ação primária única**, estados exigidos e **1 tela de referência** (`rota` ou `arquivo`).

| Tipo | Estrutura | Ação primária | Tela de referência |
|---|---|---|---|
| Listagem | | | |
| Formulário | | | |
| Detalhe | | | |
| Painel | | | |
| Configurações | | | |

Configurações: definir o modelo de gravação (salvar explícito **ou** aplicar na hora; um só por página), onde ficam as ações perigosas e como segredos são mostrados (mascarados).

### 2. Vocabulário de ações
Hierarquia: 1 ação primária por área; secundária mais fraca; terciária como link; destrutiva separada. Rótulo = verbo + objeto.

| Ação | Rótulo único | Posição / ordem | Observação |
|---|---|---|---|
| Confirmar | Salvar | direita | |
| Desistir | Cancelar | esquerda da primária | |
| Excluir | Excluir | separada das demais | confirmação nomeia o item |
| Voltar | Voltar | topo, à esquerda | |

### 3. Microcopy
- Erro de campo, erro de envio, sucesso, vazio, carregando: texto padrão de cada um.
- Autenticação: mensagem genérica.
- Tom e tratamento (você/tu, formal ou direto) definidos uma vez.

### 4. Exceções aprovadas
| Tela | Diverge em | Motivo | Aprovada em |
|---|---|---|---|

### 5. Histórico
- v1 (AAAA-MM-DD): criação, a partir do levantamento das telas existentes.
