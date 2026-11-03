---
name: deploy-checklist
description: Checklist de deploy (antes, durante e depois) para APIs, frontends e workers em servidor Linux com systemd/NGINX, com auditoria pós-deploy. Só roda com /deploy-checklist <componente> [ambiente].
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
- Limpar preservando o que é do servidor: `find "$TARGET" -mindepth 1 -not -name 'appsettings*.json' -not -path "$TARGET/logs*" -delete`.
- Reiniciar a unit exata; esperar o cold start antes de julgar 502.
- Nunca abrir porta, mexer em firewall ou bind em `0.0.0.0` — serviço escuta em `127.0.0.1` atrás do NGINX.

## Depois (obrigatório)
- `ls` do destino: só o tipo de conteúdo esperado (sem fonte em webroot, sem chunk de outro projeto, sem `appsettings` em webroot).
- SHA-256 do pacote local × servidor; `systemctl is-active`; log de inicialização sem erro de configuração.
- HTTP 200 na URL real (não só "serviço ativo"); frontend: aba nova com hard reload e conferir o hash do bundle.
- Remover pacotes e pastas temporárias no servidor e local.
- Relatório em tabela: `componente | URL | pasta | HTTP | status`, mais "Não verifiquei:".
