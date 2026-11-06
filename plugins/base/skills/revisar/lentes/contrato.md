# Lente: contrato frontend × backend

- Query params com nome **idêntico** ao `[FromQuery]` (extras são ignorados sem erro).
- Corpo POST/PUT com os mesmos campos do DTO; campo novo do DTO mapeado explicitamente no serviço do frontend (campo não mapeado é descartado sem erro).
- Rota: `[Route]` é a fonte de verdade para singular/plural; caminho sem `/api/` duplicado; barra inicial normalizada num único serviço.
- Exportações (PDF/Excel) espelham as rotas do controller.
- Tamanhos: `[MaxLength]` no backend × `maxlength` no frontend; obrigatoriedade igual dos dois lados.
- Tipos: datas (fuso), enums (número × texto), decimais, ids nulos.
- Erros: formato de erro do backend tratado no frontend (mensagem ao usuário, sem redirecionar ou sumir).
