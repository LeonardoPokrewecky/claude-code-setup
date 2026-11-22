---
type: llm
---

PASS se a resposta propõe o padrão numerado de pastas por camada (as 9 pastas sempre: `01-api`, `02-application`, `03-domain`, `04-infra`, `05-desktop`, `06-async`, `07-shared`, `08-tests`, `09-tools`; as sem código ficam vazias só com um `README.md` explicando a camada, sem `.csproj` vazio), usa `<Produto>`/Loja nos nomes dos projetos e deixa claro que o `.slnx` declara as pastas da solution explicitamente (`<Folder>` para cada uma das 9 pastas), não só uma lista de projetos. Nome de pasta no disco sem espaço.
FAIL se propõe outra estrutura (ex.: tudo em um projeto, `src/Domain` clássico com entidades no Domain sem justificar variante enxuta), se o `.slnx` aparece só com `<Project>` soltos, se deixa `tests/`/`tools/` sem número, se omite pastas sem código, ou se afirma ter criado arquivos.
