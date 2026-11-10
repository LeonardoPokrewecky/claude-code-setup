# Lente: performance

- N+1: consulta dentro de laço; carregamento preguiçoso em listagem.
- Consulta sem índice, sem paginação ou carregando a tabela inteira na memória em vez de filtrar no banco.
- Alocação/memória: coleção grande copiada, string concatenada em laço, stream lido inteiro sem necessidade.
- Chamadas repetidas ao mesmo serviço/endpoint; ausência de cache onde o dado é estável (ou cache sem invalidação).
- Frontend: re-renderização desnecessária, detecção de mudança disparada em excesso, bundle maior por import inteiro de biblioteca.
- Cache em memória sem limite de tamanho ou expiração; cache compartilhado sem trava de uma única consulta na expiração (avalanche: toda requisição concorrente vai ao banco). Invalidar na escrita.
- Página principal de SPA **sempre sem cache**; só arquivo com hash no nome pode ser imutável (senão o usuário fica na versão antiga).
- Paginação por deslocamento alto em listagem grande: preferir cursor. Projetar só as colunas usadas.
- Limite de taxa por origem em serviço consumido por muitos agentes atrás de uma saída de rede: limitar por identidade do chamador.
- Medir antes de otimizar: linha de base com volume realista, **percentis (p95)** e não média, por camada (proxy, serviço, banco, navegador); repetir a medição depois. Indicar como confirmar (`/medir-antes-depois`).
