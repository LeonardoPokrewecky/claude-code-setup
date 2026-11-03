---
name: medir-antes-depois
description: Mede o comportamento ANTES e DEPOIS de uma correção, no mesmo ambiente e com o mesmo script, para provar ou refutar que a mudança resolve algo real. Só roda com /medir-antes-depois <achado ou correção>.
disable-model-invocation: true
argument-hint: <achado / correção a medir>
---

Alvo: `$ARGUMENTS`. Responde a três perguntas: **o bug existe?** (base) · **a correção resolveu?** (corrigido) · **é regressão ou já era assim?** (comparar).
Não usar quando a leitura do código já é a evidência, ou quando a mudança é só texto/documentação.

## 1. Script antes da correção
- Roda **sem alteração** nas duas versões; ajustar no meio invalida a comparação.
- Mede **números** (requisições, payload, linhas, tempo, bytes), nunca impressão. Em UI, ler o payload/resposta real, não o texto da tela.

## 2. Alternar versões sem `git stash`
`stash` + `checkout` + `stash pop` faz merge de 3 vias e pode corromper arquivos em silêncio. Usar backup explícito no scratchpad:
```bash
B="<scratchpad>/bkp-medicao"; mkdir -p "$B"
for f in $(git diff --name-only); do cp "$f" "$B/$(echo "$f" | tr '/' '_')"; done   # 1. backup
git checkout -- $(git diff --name-only); git status --short                          # 2. base (status vazio)
# 3. medir a BASE
for f in <arquivos>; do cp "$B/$(echo "$f" | tr '/' '_')" "$f"; done                # 4. restaurar
for f in <arquivos>; do cmp -s "$f" "$B/$(echo "$f" | tr '/' '_')" || echo "DIFERE: $f"; done
git diff --stat                                                                       # 5. igual ao de antes
```
Diffstat perto do tamanho do arquivo = troca de fim de linha (LF/CRLF). Com hot reload, esperar o build antes de medir.

## 3. Reportar
Tabela `cenário | base | corrigido` com os números e um desfecho:
- **Confirmado:** base falha, corrigido passa.
- **Refutado:** base igual ao corrigido → é defesa em profundidade (dizer isso) ou a hipótese estava errada.
- **Inconclusivo:** "Não reproduzível aqui porque X. A correção se apoia em leitura de código (Y) e foi validada como não regressiva (Z), mas a falha original não foi demonstrada." Nunca converter em "está funcionando".

Terminar com "Não verifiquei:".
