---
name: autenticacao-e-sessao
description: Decide e revisa o modelo de autenticação e sessão (cookie de sessão/BFF, JWT de acesso curto com refresh, IdP externo OIDC), com critérios de escolha, checklist de segurança e testes. Somente leitura; a escolha final é validada com o usuário na implementação. Só roda com /autenticacao-e-sessao [caminho ou "revisar"].
disable-model-invocation: true
argument-hint: "[caminho do repo] | revisar"
---

Alvo: `$ARGUMENTS` (sem argumento: repositório atual). **Somente leitura.** Nunca ler `.env`, chaves ou certificados; segredo citado só como `arquivo:linha` + tipo, sem valor. Autenticação é área de segurança: recomendar sessão Opus se a atual for mais fraca.

## 1. Levantar o contexto (perguntar o que faltar, não supor)
Quem consome (SPA própria, app móvel, terceiros/B2B, outros serviços), domínio (mesmo site ou cruzado), dado sensível/financeiro/LGPD, necessidade de SSO ou login social, MFA, revogação imediata (bloquear usuário, logout em todos os dispositivos), multi-tenant, perfis/permissões e o que já existe no código (Grep por `Authorize`, `AddAuthentication`, `JwtBearer`, `Identity`, cookies, `localStorage`).

## 2. Opções (apresentar mais de uma; a decisão é validada na implementação)
| Opção | Quando favorece | Pontos de atenção |
|---|---|---|
| **A. Cookie de sessão `HttpOnly` + `Secure` + `SameSite`** (ou BFF) | SPA própria no mesmo site, dado sensível, revogação imediata | Anti-CSRF obrigatório (token ou `SameSite` estrito + cabeçalho); sessão no servidor/cache distribuído para escalar |
| **B. JWT de acesso curto (5 a 15 min) + refresh token com rotação** | Móvel, terceiros, API pública, vários serviços | Revogação só via expiração curta + refresh controlado no servidor; refresh guardado com hash e detecção de reuso; nunca JWT longo em `localStorage` |
| **C. IdP externo (OIDC): Keycloak, Entra ID, Auth0, Cognito…** | SSO, vários sistemas, MFA/social pronto, time pequeno | Não implementar o próprio protocolo; custo e dependência do provedor; validar `iss`, `aud`, `exp`, assinatura, `state`, `nonce` e PKCE; `redirect_uri` com correspondência exata (sem curinga, evita redirecionamento aberto) |
| **D. Identity/framework nativo** (ASP.NET Identity) | Usuários e senhas próprios, sem SSO | Política de senha, bloqueio por tentativas, confirmação de e-mail, hash adequado já embutido |

Combinações são comuns (ex.: C para login + A para a sessão do navegador). Apresentar recomendação **com o critério que a decide**, e o que mudaria a recomendação.

## 3. Checklist de segurança (valer para qualquer opção)
- **Senha:** hash lento com sal (Argon2id, bcrypt ou PBKDF2 com custo atual); nunca criptografia reversível, nunca log da senha tentada.
- **Token/sessão:** expiração validada, assinatura com algoritmo fixado no servidor (rejeitar `none` e troca de algoritmo), chave fora do código (ver `/gestao-de-segredos`), rotação de chave, identificador de sessão imprevisível, renovar o identificador após login (fixação de sessão).
- **Armazenamento no cliente:** token de longa duração fora de `localStorage`/`sessionStorage`; cookie com `HttpOnly`, `Secure`, `SameSite`; CSP para reduzir XSS.
- **Transporte do token:** nunca na URL ou na query string (vai para log, histórico e `Referer`); cookie com prefixo `__Host-` quando possível; token só no cabeçalho `Authorization` ou no cookie.
- **Login:** limite de tentativas por **identidade e por origem**, bloqueando na tentativa que atinge o limite; mensagem e tempo de resposta iguais para "usuário inexistente" e "senha errada" (evita enumeração); nunca persistir a senha tentada; MFA para operação sensível, recuperação de senha com token de uso único e expiração curta.
- **Autorização:** negar por padrão; checar dono do recurso no servidor (IDOR/acesso cruzado entre contas ou tenants); perfil e permissão vêm do servidor, nunca de campo enviado pelo cliente; o dono do recurso vem do token/sessão, nunca do corpo da requisição; DTO de entrada só com os campos editáveis (evita atribuição em massa de perfil ou saldo).
- **Logout e revogação:** invalidar no servidor, não só apagar no cliente; bloquear usuário derruba sessões e refresh tokens.
- **Auditoria (LGPD):** registrar login, falha, troca de senha e acesso a dado pessoal sem guardar senha, foto ou dado excessivo (ver `/lgpd-audit`).
- **Ambiente:** bypass de login/2FA/pagamento só com checagem explícita de desenvolvimento, nunca ativo em produção.
- **Tráfego:** HTTPS em tudo, HSTS, CORS com origens explícitas (sem `*` com credenciais).

## 4. Se `revisar` (já existe implementação)
Comparar o código com a seção 3 e com a opção escolhida. Citar `arquivo:linha` + problema + correção sugerida. Mudanças em autenticação com usuários reais: plano + backup + aprovação antes (sessões ativas podem cair). Para revisão completa do diff, usar `/revisar` com a lente `seguranca`.

## 5. Testes mínimos a exigir
Login válido/inválido; token expirado, adulterado e com algoritmo trocado; acesso sem permissão (403) e sem autenticação (401); acesso cruzado entre duas contas negado; logout invalida; bloqueio por tentativas; refresh reutilizado revoga a família; CSRF rejeitado (opção A).

## Saída
Tabela `ponto | situação (ok / ausente / risco) | evidência (arquivo:linha) | ação`, a **recomendação com o critério de decisão** (e a alternativa se o contexto mudar) e "Não verifiquei:" (ex.: configuração do IdP, infraestrutura, proxy/WAF, comportamento em produção).
