# Camada `devcontainer` — não validada em projeto real

Isolamento para Windows nativo (onde o sandbox do Claude Code não roda) ou para código não confiável: o Claude e os comandos que ele executa rodam dentro do container.

- Base: feature oficial `ghcr.io/anthropics/devcontainer-features/claude-code:1.0` e o volume com `CLAUDE_CONFIG_DIR`, como na documentação (https://code.claude.com/docs/en/devcontainer).
- Copiar `.devcontainer/` para a raiz do projeto e trocar `image` pela imagem da stack. Se a imagem não tiver o usuário `vscode`, ajustar `remoteUser` e os caminhos `/home/vscode`.
- Não montar `~/.ssh` nem arquivos de credencial de nuvem do host.
- Firewall de saída (`init-firewall.sh`) e hardening: ver o container de referência em `anthropics/claude-code/.devcontainer`.
- Dentro do container (Linux), aplicar o perfil `unix` (`merge-settings.ps1 -Perfil unix`, com `pwsh`) para ligar o sandbox também.

Não testado aqui: o build do container e a autenticação dentro dele.

## Roteiro de validação (sem credencial real, sem dado real)

**Devcontainer (Windows ou Linux, com o Docker em execução):**
1. `docker info` responde (no Windows, iniciar o Docker Desktop antes).
2. Numa pasta de teste vazia: copiar `.devcontainer/`, abrir no editor com "Reopen in Container" (ou `devcontainer up --workspace-folder .`).
3. Dentro do contêiner: `claude --version` responde; `ls ~/.ssh ~/.aws` não existe; `echo $CLAUDE_CONFIG_DIR` aponta para o volume.
4. Registrar o resultado (passou / falhou e o motivo) na seção 7 do `README.md` do pacote. Sem executar, a camada segue "não validada".

## Validar o sandbox no Linux (`-Perfil unix`)
1. Instalar `bubblewrap` e `socat` (pedido seu; o pacote não instala).
2. `pwsh -NoProfile -File scripts/merge-settings.ps1 -Perfil unix -DryRun -Target <settings de teste>` e conferir que só entram chaves `sandbox` que restringem.
3. Numa sessão com o perfil ligado, tentar ler um arquivo de teste dentro de `~/.ssh` (criado vazio para o teste): deve ser negado.
4. Registrar o resultado na seção 7 do `README.md`.

## Opcional: ai-jail (projeto externo, Linux/macOS/WSL2)
Não faz parte do pacote. Antes de usar, ler o README do projeto `akitaonrails/ai-jail`; por padrão ele monta `~/.claude` com escrita e repassa `ANTHROPIC_API_KEY` (usar `--no-agent-state` e `--env-from-file`). Testar só num projeto sem dados reais.
