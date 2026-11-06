# Camada `devcontainer` — não validada em projeto real

Isolamento para Windows nativo (onde o sandbox do Claude Code não roda) ou para código não confiável: o Claude e os comandos que ele executa rodam dentro do container.

- Base: feature oficial `ghcr.io/anthropics/devcontainer-features/claude-code:1.0` e o volume com `CLAUDE_CONFIG_DIR`, como na documentação (https://code.claude.com/docs/en/devcontainer).
- Copiar `.devcontainer/` para a raiz do projeto e trocar `image` pela imagem da stack. Se a imagem não tiver o usuário `vscode`, ajustar `remoteUser` e os caminhos `/home/vscode`.
- Não montar `~/.ssh` nem arquivos de credencial de nuvem do host.
- Firewall de saída (`init-firewall.sh`) e hardening: ver o container de referência em `anthropics/claude-code/.devcontainer`.
- Dentro do container (Linux), aplicar o perfil `unix` (`merge-settings.ps1 -Perfil unix`, com `pwsh`) para ligar o sandbox também.

Não testado aqui: o build do container e a autenticação dentro dele.
