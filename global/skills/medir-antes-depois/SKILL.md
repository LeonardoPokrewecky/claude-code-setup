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

## 2. Alternar versões sem tocar na cópia de trabalho
Nunca `git stash` (merge de 3 vias pode corromper em silêncio) nem `git checkout --`/`git restore` (descartam a correção).

**Preferido — base em worktree separada** (a cópia de trabalho com a correção não é alterada):
```bash
W="<scratchpad>/base-medicao"
git worktree add --detach "$W" HEAD      # base = último commit (ou outro ref de base)
# medir a BASE dentro de "$W" (instalar dependências ali se o build exigir); medir o CORRIGIDO na pasta original
git worktree remove --force "$W"         # remove só a worktree temporária
```

**Alternativa — patch** (quando o ambiente só roda na pasta original: portas, caminhos fixos, dependências pesadas):
```bash
B="<scratchpad>/medicao"; mkdir -p "$B"
git add -N .                                       # inclui arquivos novos no diff (só intenção, nada é commitado)
git diff --binary HEAD > "$B/correcao.patch"       # 1. a correção inteira num arquivo
git apply --check -R "$B/correcao.patch" && git apply -R "$B/correcao.patch"   # 2. volta para a base
# 3. medir a BASE
git apply "$B/correcao.patch"                      # 4. reaplica a correção
git diff --binary HEAD | cmp - "$B/correcao.patch" && echo "correção restaurada"   # 5. conferir
```
Se o passo 5 divergir, parar e avisar: o patch em `$B` continua sendo a cópia da correção.
Diffstat perto do tamanho do arquivo = troca de fim de linha (LF/CRLF). Com hot reload, esperar o build antes de medir.

## 3. Reportar
Tabela `cenário | base | corrigido` com os números e um desfecho:
- **Confirmado:** base falha, corrigido passa.
- **Refutado:** base igual ao corrigido → é defesa em profundidade (dizer isso) ou a hipótese estava errada.
- **Inconclusivo:** "Não reproduzível aqui porque X. A correção se apoia em leitura de código (Y) e foi validada como não regressiva (Z), mas a falha original não foi demonstrada." Nunca converter em "está funcionando".

Terminar com "Não verifiquei:".
