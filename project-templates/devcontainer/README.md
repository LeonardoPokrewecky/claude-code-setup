# Camada `devcontainer` — não validada em projeto real

Isolamento para Windows nativo (onde o sandbox do Claude Code não roda) ou para código não confiável: o Claude e os comandos que ele executa rodam dentro do container.

- Base: feature oficial `ghcr.io/anthropics/devcontainer-features/claude-code:1.0` e o volume com `CLAUDE_CONFIG_DIR`, como na documentação (https://code.claude.com/docs/en/devcontainer).
- Copiar `.devcontainer/` para a raiz do projeto e trocar `image` pela imagem da stack. Se a imagem não tiver o usuário `vscode`, ajustar `remoteUser` e os caminhos `/home/vscode`.
- Não montar `~/.ssh` nem arquivos de credencial de nuvem do host.
- Firewall de saída (`init-firewall.sh`) e hardening: ver o container de referência em `anthropics/claude-code/.devcontainer`.
- Dentro do container (Linux), aplicar o perfil `unix` (`merge-settings.ps1 -Perfil unix`, com `pwsh`) para ligar o sandbox também.

## Resultado da validação parcial (2026-11-14, Docker Desktop 29.9.2 no Windows)
Testado com `docker run` na imagem `mcr.microsoft.com/devcontainers/base:ubuntu`, usuário `vscode`, volume nomeado em `/home/vscode/.claude`, sem montar nada do host:
- Usuário `vscode` (uid 1000); `SSH_AUTH_SOCK` vazio; sem `credential.helper`; sem `docker.sock`; sem variáveis `ANTHROPIC_*`, `GITHUB_*`, `GH_*` ou `AWS_*`; nenhuma montagem ligada ao host.
- **Falha achada e corrigida:** o volume nomeado é criado com dono `root` quando `/home/vscode/.claude` não existe na imagem, e o `vscode` não consegue gravar ali (`Permission denied`). Correção no template: `postCreateCommand` com `sudo chown -R vscode:vscode /home/vscode/.claude`; o comando foi testado no contêiner e o volume ficou gravável.
- **Não testado:** a feature oficial `claude-code`, o `postCreateCommand` executado pelo próprio Dev Containers (não há CLI `devcontainer` instalada; a extensão do VS Code exige o botão "Reopen in Container"), a autenticação do Claude Code dentro do contêiner e a checagem de `~/.ssh` e `~/.aws` (o hook `bloquear-segredos` barra comandos que citam esses nomes; rodar com `! <comando>`).
- Camada continua **não validada em projeto real**.

## Roteiro de validação (sem credencial real, sem dado real)

**Devcontainer (Windows ou Linux, com o Docker em execução):**
1. `docker info` responde (no Windows, iniciar o Docker Desktop antes).
2. Numa pasta de teste vazia: copiar `.devcontainer/`, abrir no editor com "Reopen in Container" (ou `devcontainer up --workspace-folder .`).
3. Dentro do contêiner: `claude --version` responde; `ls ~/.ssh ~/.aws` não existe; `echo $CLAUDE_CONFIG_DIR` aponta para o volume.
   - Conferir também o que o editor repassa sem montar pasta: `echo $SSH_AUTH_SOCK` deve estar vazio e `git config --get credential.helper` não deve apontar para o host. Se aparecer, desligar o repasse do agente SSH e das credenciais do Git nas configurações do editor/Dev Containers e repetir o teste (comportamento do Dev Containers não verificado aqui).
4. Registrar o resultado (passou / falhou e o motivo) na seção 7 do `README.md` do pacote. Sem executar, a camada segue "não validada".

## Validar o sandbox no Linux (`-Perfil unix`)
1. Instalar `bubblewrap` e `socat` (pedido seu; o pacote não instala).
2. `pwsh -NoProfile -File scripts/merge-settings.ps1 -Perfil unix -DryRun -Target <settings de teste>` e conferir que só entram chaves `sandbox` que restringem.
3. Numa sessão com o perfil ligado, tentar ler um arquivo de teste dentro de `~/.ssh` (criado vazio para o teste): deve ser negado.
4. Registrar o resultado na seção 7 do `README.md`.

## Opcional: ai-jail (projeto externo, Linux/macOS/WSL2)
Não faz parte do pacote. Antes de usar, ler o README do projeto `akitaonrails/ai-jail`; por padrão ele monta `~/.claude` com escrita e repassa `ANTHROPIC_API_KEY` (usar `--no-agent-state` e `--env-from-file`). Testar só num projeto sem dados reais.
