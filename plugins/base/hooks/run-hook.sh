#!/bin/sh
# Ponte portátil para o hook bloquear-segredos.ps1 (PreToolUse Bash/PowerShell).
# O Claude Code roda hooks em shell form no sh (macOS/Linux) ou no Git Bash (Windows):
# https://code.claude.com/docs/en/hooks. O stdin (JSON do Claude Code) passa direto para o PowerShell via exec.
# Prefere pwsh (PowerShell 7, abre mais rápido); no Windows sem pwsh usa o powershell 5.1.
# Sem nenhum PowerShell: pede confirmação em vez de liberar em silêncio (o hook nunca trava a sessão).
script="$(dirname "$0")/bloquear-segredos.ps1"
if command -v pwsh >/dev/null 2>&1; then
  exec pwsh -NoProfile -NonInteractive -File "$script"
fi
for ps in powershell powershell.exe; do
  if command -v "$ps" >/dev/null 2>&1; then
    exec "$ps" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$script"
  fi
done
printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Hook bloquear-segredos: PowerShell (pwsh ou powershell) não encontrado; o comando não foi verificado. Confira antes de aprovar."}}'
exit 0
