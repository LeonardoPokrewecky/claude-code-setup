#!/bin/sh
# Ponte portátil para o hook bloquear-segredos.ps1 (PreToolUse Bash/PowerShell): versão de referência (e para rodar
# à mão: sh run-hook.sh < entrada.json) da lógica que o hooks.json repete inline. O inline evita um sh a mais por
# comando (medido em 22/11/2026: +~60 ms no Git Bash). Mudou aqui, mude lá: os testes rodam os dois caminhos.
# O Claude Code roda hooks em shell form no sh (macOS/Linux) ou no Git Bash (Windows):
# https://code.claude.com/docs/en/hooks. O stdin (JSON do Claude Code) é herdado pelo PowerShell.
# No Windows (OS=Windows_NT, herdado pelo Git Bash) prefere o powershell 5.1: abre mais rápido que o pwsh
# (medido em 17/11/2026: ~400 ms × ~610 ms por comando pelo Git Bash). Fora do Windows usa só o pwsh:
# o powershell.exe visto de dentro do WSL receberia um caminho Linux no -File e falharia.
# Falha fechada: o Claude Code trata qualquer código de saída diferente de 0 e 2 como erro NÃO bloqueante e libera o
# comando. Por isso o PowerShell NÃO roda com exec: aqui o código de saída é conferido e, se o interpretador não
# executou o script (arquivo ausente, ExecutionPolicy imposta por GPO, erro de inicialização), pede confirmação.
# O código 2 (bloqueio) e o 0 (libera ou "ask" do próprio script) passam adiante sem mudança.
# Sem nenhum PowerShell: pede confirmação em vez de liberar em silêncio (o hook nunca trava a sessão).
case "$0" in */*) pasta="${0%/*}" ;; *) pasta="." ;; esac # sem o dirname externo: um processo a menos por comando
script="$pasta/bloquear-segredos.ps1"

pedir_confirmacao() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Hook bloquear-segredos: %s. Confira o que o comando faz antes de aprovar."}}' "$1"
  exit 0
}

# A saída do PowerShell é capturada: se ele falhar, o texto parcial dele não se mistura com o JSON de confirmação.
# O stderr não é capturado (é o motivo do bloqueio quando o código é 2).
if [ "$OS" = "Windows_NT" ] && command -v powershell >/dev/null 2>&1; then
  saida=$(powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$script")
elif command -v pwsh >/dev/null 2>&1; then
  saida=$(pwsh -NoProfile -NonInteractive -File "$script")
else
  pedir_confirmacao 'PowerShell (pwsh ou powershell) não encontrado; o comando não foi verificado'
fi
rc=$?

case "$rc" in
  0|2)
    [ -n "$saida" ] && printf '%s' "$saida"
    exit "$rc"
    ;;
  *)
    pedir_confirmacao "o PowerShell não executou o hook (código de saída $rc); o comando não foi verificado"
    ;;
esac
