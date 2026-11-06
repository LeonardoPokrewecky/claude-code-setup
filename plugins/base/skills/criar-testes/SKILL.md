---
name: criar-testes
description: Gera testes para código sem cobertura, seguindo o framework e o padrão do projeto, só nos arquivos indicados. Só roda com /criar-testes <arquivo ou classe>.
disable-model-invocation: true
argument-hint: <arquivo ou classe a cobrir>
---

Alvo: `$ARGUMENTS`. Escrever **apenas arquivos de teste novos**; não alterar o código de produção (se o código impede o teste, parar e dizer o quê).

1. Ler o `CLAUDE.md` (comando e padrão de testes: ex. xUnit com repositório fake; Jasmine/Karma) e um teste existente como modelo.
2. Cobrir: caminho feliz, bordas, erros e a regra de negócio relevante. Sem mocks desnecessários, sem dependência de banco/rede.
3. Rodar o comando de teste do projeto e mostrar o resultado literal. Teste que falha por bug real: reportar, não "consertar" o teste.
4. Terminar com "Não verifiquei:".
