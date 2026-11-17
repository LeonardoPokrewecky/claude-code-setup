# Plugin `base`

Ligado em todo projeto. Contém:
- **Hook `bloquear-segredos`** (`hooks/`): PreToolUse Bash/PowerShell. O `hooks.json` escolhe o shell (no Windows o `powershell` 5.1 primeiro, que abre mais rápido; fora dele o `pwsh`) e roda `bloquear-segredos.ps1`; sem PowerShell, `run-hook.sh` pede confirmação. Casos de teste: `tests/casos-hook.psd1` do repositório.
- **Skills** genéricas (revisão por lentes, planejamento, alteração de dados, deploy, LGPD, handoff e outras) e **agentes** (`revisor`, `implementer-sonnet`, `test-validator-haiku`, `researcher-haiku`, `documentation-haiku`).
- **Evals** (`evals/`): `claude plugin eval ./plugins/base` (chama o modelo).

Lista completa e descrições: [skills/env-guide/componentes.md](skills/env-guide/componentes.md) (gerada). Lista curta, um resumo por comando: `/comandos` ([skills/comandos/comandos.md](skills/comandos/comandos.md), gerada). Instalação e limitações: README do repositório.

Instalação (Claude Code 2.1.275 ou mais recente; o repositório é privado, então exige credencial Git com acesso):
```
/plugin install base --marketplace LeonardoPokrewecky/claude-code-setup
```
