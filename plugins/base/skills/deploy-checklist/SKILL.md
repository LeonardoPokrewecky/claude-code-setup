---
name: deploy-checklist
description: Checklist de deploy (antes, durante e depois) para APIs, frontends e workers em servidor Linux com systemd/NGINX (validado) ou Windows Server/IIS (não validado em projeto real), com auditoria pós-deploy. Só roda com /deploy-checklist <componente> [ambiente].
disable-model-invocation: true
argument-hint: <componente> [test|homologation|staging|production]
---

Alvo: `$ARGUMENTS`. **Deploy só com autorização explícita nesta conversa.** Esta skill monta e confere o checklist; cada passo destrutivo é mostrado antes de rodar.

## Antes
1. Build em pasta temporária **fora** do repositório (`<temp>/<projeto>/`); nunca `publish/` dentro do código.
2. Mapear **projeto → unidade systemd → pasta**: ler o `ExecStart` da unit; publicar o projeto errado gera crash loop.
3. Ler a config ativa do NGINX (`server_name`, `root`, `proxy_pass`) e confirmar qual pasta recebe qual artefato. Nunca o mesmo pacote em duas pastas.
4. Pacote sem `appsettings*.json` com valores reais, `.env`, PDB/`*.map`, fonte, `.git`. Configuração nova que o código passou a ler → chega ao servidor **antes** do deploy.
5. Imprimir, imediatamente antes de qualquer limpeza: `DEPLOY: <pacote> -> <pasta> (confirmado via NGINX)`.

## Durante
- Script remoto gerado no Windows: UTF-8 **sem BOM** e LF (BOM esvazia variável e `find $VAR -delete` vira `find -delete` na pasta atual).
- Guardar o destino: `[ -n "$TARGET" ] && [ -d "$TARGET" ] || exit 1`, sempre entre aspas.
- **Backup antes de limpar, encadeado com `&&` (ou `set -e`), nunca com `;`:** se a cópia falha por permissão, o script para; com `;` ele segue e apaga o destino sem cópia. Conferir que o backup existe e tem tamanho > 0; senão, abortar.
- Pasta de dados do usuário dentro da raiz publicada (uploads, anexos): excluir da limpeza ou publicar de forma aditiva.
- Manter o backup do estado anterior até a mudança ser aceita (é o único ponto de retorno).
- Limpar preservando o que é do servidor: `find "$TARGET" -mindepth 1 -not -name 'appsettings*.json' -not -path "$TARGET/logs*" -delete`.
- Reiniciar a unit exata; esperar o cold start antes de julgar 502.
- Nunca abrir porta, mexer em firewall ou bind em `0.0.0.0` — serviço escuta em `127.0.0.1` atrás do NGINX.

## Depois (obrigatório)
- `ls` do destino: só o tipo de conteúdo esperado (sem fonte em webroot, sem chunk de outro projeto, sem `appsettings` em webroot).
- SHA-256 do pacote local × servidor; `systemctl is-active`; log de inicialização sem erro de configuração.
- HTTP 200 na URL real (não só "serviço ativo"); frontend: aba nova com hard reload e conferir o hash do bundle.
- **Verificar depois de iniciar o serviço**, nunca entre a extração e a partida (se a verificação falhar ali, ela vira a causa da indisponibilidade). Serviço que resolve segredo externo na partida pode demorar: repetir a verificação por algumas dezenas de segundos antes de reverter, senão a reversão desfaz um deploy correto.
- **Reverter** do backup se a verificação falhar após as tentativas, e relatar a reversão.
- **Smoke de menos de 2 minutos** (o que, se quebrar, é indisponibilidade): página inicial, login, uma leitura e uma escrita do fluxo central, health da API, sem erro no console. Falhou → interromper e reverter.
- Remover pacotes e pastas temporárias no servidor e local.
- Relatório em tabela: `componente | URL | pasta | HTTP | status`, mais "Não verifiquei:".
- Correção em caminho de escrita só cobre registros futuros: consultar o legado e, se preciso, `/alterar-dados`.

## Windows Server / IIS — **não validado em projeto real**
> Esqueleto mínimo. Antes de usar, confirmar cada passo no servidor real e registrar o que divergir no `CLAUDE.md` do projeto.
- Mapear **site → application pool → pasta física** (`Get-Website`, `Get-WebApplication`, `Get-IISAppPool`) antes de copiar; nunca o mesmo pacote em dois sites.
- ASP.NET Core: publicar com o RID `win-x64` (ou framework-dependent com o Hosting Bundle instalado na versão certa); `web.config` gerado pelo publish com `aspNetCore` apontando para a DLL/EXE certa.
- Parar só o pool do site (`Stop-WebAppPool <pool>`) ou usar `app_offline.htm` para liberar arquivos travados; nunca `iisreset` (derruba todos os sites).
- Copiar preservando o que é do servidor: `appsettings.<Ambiente>.json`, `web.config` com variáveis de ambiente/segredos, pasta `logs`.
- Variáveis de ambiente e segredos no pool/`web.config` do servidor, nunca no pacote.
- Depois: `Start-WebAppPool`, HTTP 200 na URL real, log de inicialização (stdout log do módulo ASP.NET Core) sem erro, SHA-256 do pacote local × servidor, remover `app_offline.htm` e temporários.
