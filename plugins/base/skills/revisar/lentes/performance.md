# Lente: performance

- N+1: consulta dentro de laço; carregamento preguiçoso em listagem.
- Consulta sem índice, sem paginação ou carregando a tabela inteira na memória em vez de filtrar no banco.
- Alocação/memória: coleção grande copiada, string concatenada em laço, stream lido inteiro sem necessidade.
- Chamadas repetidas ao mesmo serviço/endpoint; ausência de cache onde o dado é estável (ou cache sem invalidação).
- Frontend: re-renderização desnecessária, detecção de mudança disparada em excesso, bundle maior por import inteiro de biblioteca.
- Medir antes de otimizar: indicar como confirmar (`/medir-antes-depois`).
