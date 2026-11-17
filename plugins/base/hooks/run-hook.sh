#!/bin/sh
# Ponte portátil para o hook bloquear-segredos.ps1 (PreToolUse Bash/PowerShell).
# O hooks.json já faz a escolha do PowerShell inline (economiza um processo por comando) e só chama este script
# quando não acha pwsh nem powershell; ele também serve para rodar o hook à mão: sh run-hook.sh < entrada.json.
# O Claude Code roda hooks em shell form no sh (macOS/Linux) ou no Git Bash (Windows):
# https://code.claude.com/docs/en/hooks. O stdin (JSON do Claude Code) passa direto para o PowerShell via exec.
# No Windows (OS=Windows_NT, herdado pelo Git Bash) prefere o powershell 5.1: abre mais rápido que o pwsh
# (medido em 17/11/2026: ~400 ms × ~610 ms por comando pelo Git Bash). Fora do Windows prefere o pwsh.
# Sem nenhum PowerShell: pede confirmação em vez de liberar em silêncio (o hook nunca trava a sessão).
script="$(dirname "$0")/bloquear-segredos.ps1"
if [ "$OS" = "Windows_NT" ] && command -v powershell >/dev/null 2>&1; then
  exec powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$script"
fi
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
