# Plugin `base`

Ligado em todo projeto. Contém:
- **Hook `bloquear-segredos`** (`hooks/`): PreToolUse Bash/PowerShell. O `hooks.json` escolhe `pwsh` ou `powershell` e roda `bloquear-segredos.ps1`; sem PowerShell, `run-hook.sh` pede confirmação. Casos de teste: `tests/casos-hook.psd1` do repositório.
- **Skills** genéricas (revisão por lentes, planejamento, alteração de dados, deploy, LGPD, handoff e outras) e **agentes** (`revisor`, `implementer-sonnet`, `test-validator-haiku`, `researcher-haiku`, `documentation-haiku`).
- **Evals** (`evals/`): `claude plugin eval ./plugins/base` (chama o modelo).

Lista completa e descrições: [skills/env-guide/componentes.md](skills/env-guide/componentes.md) (gerada). Instalação e limitações: README do repositório.
