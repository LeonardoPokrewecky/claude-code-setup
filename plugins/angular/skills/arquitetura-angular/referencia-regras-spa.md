# Referência: regras de sessão e rede em SPA Angular

Carregar sob demanda ao mexer em autenticação no cliente, interceptors, guards, busca ou publicação. Regras inspiradas no agente Master (`spa-frontend`), reescritas aqui. Modelo de autenticação (cookie, JWT, OIDC): `/autenticacao-e-sessao`. Estados de tela e componentes: `/componentes-e-estados`.

## 1. Interceptor que desembrulha a resposta

Se um interceptor devolve só o conteúdo (`resposta.data` → corpo), o formato muda para **todos** os consumidores: ninguém lê `.data` de novo, nem no `ApiService` nem na página. Escolher um lugar só e documentar no `core/interceptors`.

## 2. Sessão e guard

- O guard de rota é **assíncrono**: tenta renovar a sessão antes de mandar para o login. Um guard que decide só pela expiração lida no cliente deixa a renovação como código morto.
- **Uma única renovação em andamento:** guards e requisições paralelas esperam a mesma promessa/observable de renovação; nunca disparam duas.
- **401 encerra a sessão** (limpa estado e vai ao login). **403 não desloga:** mostra "acesso negado". Tratar 403 como 401 transforma "sem permissão" em "não consigo entrar".
- A tela de login com sessão válida redireciona para dentro do app **só se** a sessão satisfaz o predicado real de autorização, não apenas "existe usuário".
- **Logout:** chamar `reset()` em todo singleton com estado (stores, cache de usuário), para o próximo usuário não ver dados do anterior.

## 3. Busca com debounce

Com atraso de digitação, usar um **contador de sequência** (ou `switchMap`): sem isso, uma resposta antiga sobrescreve a nova. Validar no cliente antes de gastar tentativa em endpoint com limite.

## 4. Publicação

- **`index.html` sem cache** (`Cache-Control: no-cache`); só arquivos com hash no nome são imutáveis. Sem isso o usuário continua na versão antiga depois de publicar.
- **`environment`:** o arquivo versionado costuma estar certo; o **pacote** é que sai errado. Conferir o `apiUrl` do que será publicado (o de desenvolvimento nunca vai para produção). Em cada ambiente, `apiUrl` é o único valor que muda.
- **Build fora da pasta do código** (`outputPath` próprio, ignorado pelo Git), para não misturar saída com fonte.

## 5. Formulários e diálogos

- Sem `alert`/`confirm` nativos: componente próprio, acessível e testável.
- Rótulo associado a cada campo (`label` com `for`/`id`), mensagem de erro ao lado do campo e botão desabilitado sempre com o motivo visível.
- Máscara na exibição **e** valor normalizado no envio; campo opcional vazio vai ausente, não como texto vazio.

## 6. LGPD no cliente

Token e dado pessoal não vão para URL, `console.log` nem `localStorage` sem decisão registrada (`/autenticacao-e-sessao`). Mensagem de erro não mostra identificador interno nem dado de outro usuário.

## Checklist rápido

- [ ] Interceptor único desembrulha; ninguém lê `.data`
- [ ] Guard assíncrono com renovação única; 401 encerra, 403 não desloga
- [ ] `reset()` dos singletons no logout
- [ ] Busca com contador de sequência
- [ ] `index.html` sem cache; `apiUrl` do pacote conferido; build fora do código
- [ ] Sem `alert`/`confirm`; rótulos e mensagens de erro nos campos
