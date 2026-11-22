#!/bin/sh
# Hook SessionStart: avisa (sem bloquear) se o core/ instalado em ~/.claude esta atras do que o plugin espera.
# So le dois arquivos de texto; sem rede; nao altera nada; sempre sai com 0.
esperada_arq="${CLAUDE_PLUGIN_ROOT}/core-versao.txt"
instalada_arq="${HOME}/.claude/core-versao.txt"

le_inteiro() { # imprime o inteiro do arquivo (sem BOM, espacos e CR) ou nada
  [ -r "$1" ] || return 0
  v=$(head -n 1 "$1" 2>/dev/null | tr -d '\r\357\273\277 \t')
  case "$v" in ''|*[!0-9]*) return 0 ;; esac
  printf '%s' "$v"
}

aviso() { printf '{"systemMessage":"%s"}' "$1"; }

esperada=$(le_inteiro "$esperada_arq")
[ -z "$esperada" ] && exit 0   # sem versao no plugin: nada a comparar

instalada=$(le_inteiro "$instalada_arq")
if [ -z "$instalada" ]; then
  aviso "core/ nao instalado ou sem versao em ~/.claude (plugin espera v${esperada}): nao foi possivel comparar. Rode scripts/instalar-arquivos.ps1 -DryRun."
elif [ "$instalada" -lt "$esperada" ]; then
  aviso "core/ instalado (v${instalada}) esta atras do plugin (v${esperada}). Rode scripts/instalar-arquivos.ps1 -DryRun e revise."
fi
exit 0
