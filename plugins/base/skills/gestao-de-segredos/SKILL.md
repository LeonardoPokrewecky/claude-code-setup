---
name: gestao-de-segredos
description: Auditoria e procedimento de gestão de segredos (varredura do histórico do Git, rotação na ordem certa, cofre/User Secrets/variável de ambiente, mascaramento, exposição já ocorrida). Somente leitura por padrão; rotação e reescrita de histórico só com autorização. Só roda com /gestao-de-segredos [caminho ou "exposicao"].
disable-model-invocation: true
argument-hint: "[caminho do repo] | exposicao"
---

Alvo: `$ARGUMENTS` (sem argumento: repositório atual). **Somente leitura.** Nunca ler `.env`, chaves ou certificados; nunca exibir valor de segredo; nunca testar credencial. Segredo achado é citado só como `arquivo:linha` + tipo (ex.: "connection string PostgreSQL", "chave de API"), **sem o valor**, nem parcial.

## 1. Estado atual
- Grep por padrões de credencial (connection string com senha, `password=`, `apikey`, `secret`, `token`, chave privada `-----BEGIN`, `AKIA...`, `ghp_`, `sk-`) em código, testes, `appsettings*.json`, `environment*.ts`, Dockerfile, `docker-compose*`, CI, skills, CLAUDE.md e memory. Excluir `node_modules`, `dist`, `bin`, `obj`.
- `appsettings.json` versionado: só valores vazios ou marcadores; valor real vai para User Secrets (dev) ou variável de ambiente/cofre (servidor).
- Arquivo de exemplo (`.env.example`, `appsettings.example`): só nomes de chave, nunca valor real.
- `.gitignore` cobre `.env*`, `secrets/`, `*.pfx`, `*.pem`, `*.key`, `appsettings.*.local.json`.
- Segredo em log, mensagem de erro, relatório, teste ou comentário: achado.

## 2. Histórico do Git
Estado atual limpo **não** significa histórico limpo.
- `git log --all -p -S "<padrão não sensível>" --stat` ou ferramenta instalada na máquina (`gitleaks`, `trufflehog`; **não instalar** sem pedido). Citar só `commit:arquivo` + tipo.
- Incluir branches, tags e stashes (`git log --all`, `git stash list`).
- Segredo **que já foi enviado ao repositório (push) está comprometido**: reescrever histórico não basta, é preciso **rotacionar** (seção 3). Reescrita (`git filter-repo`) só com pedido explícito, backup do repositório antes e aviso de que força o push e invalida clones.

## 3. Rotação (só com autorização; ordem importa)
1. Gerar o novo valor.
2. Atualizar no cofre/variável de ambiente/User Secrets.
3. Reiniciar quem consome (**um serviço por vez**: reiniciar vários buscando muitos segredos de uma vez esgota o limite do cofre e vira laço de falha).
4. Validar que o serviço funciona com o novo valor.
5. **Só então** invalidar o valor antigo.
- Periodicamente e **imediatamente** após suspeita de exposição.
- Cofre que resolve na partida exige reinício depois de mudar o valor. Configuração por ambiente: marcador do arquivo base que o arquivo do ambiente não sobrescreve continua apontando para o ambiente errado.
- Cliente de cofre que engole o erro e devolve vazio faz "ausente", "excesso de requisições" e "não encontrado" parecerem iguais: ler o código do cliente antes de culpar o servidor.

## 4. Mascaramento e saída
- Ao depurar, mascarar antes de imprimir; mascarar a senha em parâmetro **e** a credencial embutida na URL (`://user:senha@host`).
- Arquivo de credencial com permissão restritiva e dono igual à conta do serviço (Linux: `chmod 600`/`640`; Windows: ACL só do usuário/serviço).
- Nunca armazenar a senha tentada numa falha de login.
- Dado sensível em repouso: chave derivada, cifra autenticada, prefixo de versão no valor, leitura dupla durante a troca de chave, índice cego para busca por igualdade, migração idempotente com reversão.

## 5. Se `exposicao` (suspeita de vazamento)
Classificar como incidente (ver `/postmortem`): conter primeiro (revogar/rotacionar), **preservar evidência antes de limpar**, descobrir como vazou, procurar o mesmo padrão em outros pontos e, se houver dado pessoal, avisar o usuário para avaliar a obrigação de notificação (`/lgpd-audit`).

## Saída
Tabela `local (arquivo:linha ou commit:arquivo) | tipo | situação (no código / só no histórico / já enviado ao remoto) | ação (rotacionar / mover para cofre / remover)` e "Não verifiquei:" (ex.: histórico de outros clones, CI, backups, logs do servidor).
