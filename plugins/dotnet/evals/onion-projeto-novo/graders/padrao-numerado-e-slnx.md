---
type: llm
---

PASS se a resposta propõe o padrão numerado de pastas por camada (`01-api`, `02-application`, `03-domain`, `04-infra`, `06-async`, `07-shared`, mais `tests/`), usa `<Produto>`/Loja nos nomes dos projetos e deixa claro que o `.slnx` declara as pastas da solution explicitamente (`<Folder>` por camada), não só uma lista de projetos. Nome de pasta no disco sem espaço.
FAIL se propõe outra estrutura (ex.: tudo em um projeto, `src/Domain` clássico com entidades no Domain sem justificar variante enxuta), se o `.slnx` aparece só com `<Project>` soltos, ou se afirma ter criado arquivos.
