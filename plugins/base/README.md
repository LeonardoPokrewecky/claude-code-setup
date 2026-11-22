# Plugin `base`

Ligado em todo projeto. Contém:
- **Hook `bloquear-segredos`** (`hooks/`): PreToolUse Bash/PowerShell. O `hooks.json` chama `run-hook.sh`, que escolhe o shell (no Windows o `powershell` 5.1 primeiro, que abre mais rápido; fora dele só o `pwsh`) e roda `bloquear-segredos.ps1`. Falha fechada: se o interpretador não executar o script (código de saída diferente de 0 e 2) ou não houver PowerShell, pede confirmação em vez de liberar. Casos de teste: `tests/casos-hook.psd1` do repositório.
- **Skills** genéricas (revisão por lentes, planejamento, alteração de dados, deploy, LGPD, handoff e outras) e **agentes** (`revisor`, `implementer-sonnet`, `test-validator-haiku`, `researcher-haiku`, `documentation-haiku`).
- **Evals** (`evals/`): `claude plugin eval ./plugins/base` (chama o modelo).

Lista completa e descrições: [skills/env-guide/componentes.md](skills/env-guide/componentes.md) (gerada). Lista curta, um resumo por comando: `/comandos` ([skills/comandos/comandos.md](skills/comandos/comandos.md), gerada). Instalação e limitações: README do repositório.

Instalação (Claude Code 2.1.275 ou mais recente; repositório público no GitHub):
```
/plugin install base --marketplace LeonardoPokrewecky/claude-code-setup
```
