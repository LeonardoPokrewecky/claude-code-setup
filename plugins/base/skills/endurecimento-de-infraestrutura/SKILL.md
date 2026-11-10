---
name: endurecimento-de-infraestrutura
description: Auditoria somente leitura para reduzir a superfície de ataque da infraestrutura (exposição de portas e serviços, acesso, cabeçalhos HTTP, TLS, containers, CI/CD, rede, logs, backup), com opções por tipo de hospedagem. Alterações só com autorização. Só roda com /endurecimento-de-infraestrutura [caminho ou "servidor"].
disable-model-invocation: true
argument-hint: "[caminho do repo] | servidor"
---

Alvo: `$ARGUMENTS` (sem argumento: repositório atual, olhando Dockerfile, compose, CI, configuração de proxy e IaC). **Somente leitura.** Nunca ler `.env`, chaves ou certificados; segredo citado só como `arquivo:linha` + tipo, sem valor. Nunca acessar servidor ou produção sem autorização; com `servidor`, só gerar o roteiro de verificação para o usuário executar ou aprovar comando a comando. Mudança em firewall, SSH, TLS ou rede de produção: plano + backup + aprovação antes (um erro pode trancar o acesso). Recomendar sessão Opus se a atual for mais fraca.

## 1. Levantar o contexto (perguntar o que faltar)
Onde roda (VM/IIS/Linux, container, PaaS, Kubernetes, serverless), o que é público na internet, quem acessa a administração, dados sensíveis/LGPD, proxy/WAF/CDN, CI/CD e quem publica.

## 2. Checklist (ajustar ao tipo de hospedagem)
- **Exposição mínima:** só 80/443 públicos; banco, cache, fila e painéis administrativos sem acesso direto da internet (rede privada ou lista de IP); nenhuma porta nova sem justificativa registrada.
- **Acesso administrativo:** SSH/RDP por chave ou MFA, sem senha, sem login direto como root/administrador, contas nominais, acesso removido quando alguém sai.
- **TLS:** só versões atuais, certificado válido com renovação automática, HTTP redireciona para HTTPS, HSTS.
- **Cabeçalhos HTTP:** `Strict-Transport-Security`, `Content-Security-Policy`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`; sem cabeçalho que revele versão (`Server`, `X-Powered-By`); CORS com origens explícitas.
- **Aplicação em produção:** Swagger/telas de depuração/detalhe de exceção desligados; variável de ambiente de produção correta (nenhum bypass de desenvolvimento ativo).
- **Containers:** imagem base mínima e fixada por versão/digest, usuário sem privilégio de root, sistema de arquivos somente leitura quando possível, sem `--privileged`, sem socket do Docker montado, segredo fora da imagem e do `ARG`, varredura de vulnerabilidade da imagem.
- **Isolamento:** um serviço por conta/contêiner, rede interna separada da pública, menor privilégio no banco (usuário da aplicação sem DDL em produção) e na nuvem (papéis mínimos).
- **CI/CD:** segredo do pipeline em cofre, ações/imagens de terceiros fixadas por versão ou SHA, permissões do token do pipeline mínimas, PR de fork sem acesso a segredo, publicação em produção com aprovação.
- **Dependências:** inventário e atualização regular; alerta de vulnerabilidade (Dependabot ou equivalente); ver lente `deps` do `/revisar`.
- **Atualizações do sistema:** patches de segurança do SO e do runtime com rotina definida.
- **Logs e monitoramento:** log centralizado sem segredo nem dado pessoal desnecessário, alerta de falha de login e de erro 5xx, retenção definida (LGPD), relógio sincronizado.
- **Backup:** automático, **restauração testada**, cópia fora do mesmo ambiente, acesso restrito e criptografado.
- **Limites:** limite de taxa, tamanho máximo de requisição/upload e tempo máximo; proteção contra negação de serviço no proxy/CDN.
- **Ambientes:** desenvolvimento, homologação e produção separados, sem dado real fora de produção (ver `/alterar-dados`).

## 3. Opções por hospedagem (a escolha é validada na implementação)
| Hospedagem | Foco principal |
|---|---|
| VM/servidor próprio (Linux ou Windows/IIS) | Firewall, SSH/RDP, patches, usuário de serviço sem privilégio, TLS no proxy, backup |
| Containers/Compose | Imagem mínima, usuário não root, rede interna, segredo fora da imagem, limites de recurso |
| Kubernetes | Políticas de rede, contexto de segurança do pod, papéis RBAC mínimos, segredos externos, admissão de imagens |
| PaaS/serverless | Papéis mínimos, variáveis protegidas, rede privada para o banco, limites e alertas de custo |

## Saída
Tabela `item | situação (ok / ausente / risco) | evidência (arquivo:linha ou "não verificável aqui") | ação | risco de aplicar (pode derrubar o serviço?)` ordenada por gravidade, e "Não verifiquei:" (ex.: estado real do servidor, regras de firewall, configuração do provedor, painel da nuvem, backups).
