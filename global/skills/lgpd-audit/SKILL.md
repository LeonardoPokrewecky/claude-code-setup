---
name: lgpd-audit
description: Auditoria LGPD completa e somente leitura de um app (web/mobile/API) — pesquisa a legislação vigente, mapeia dados pessoais, avalia 11 áreas, prioriza P0–P3 e gera RELATORIO-LGPD.md em linguagem simples. Use quando pedirem auditoria/avaliação LGPD, privacidade ou adequação à lei de proteção de dados.
disable-model-invocation: true
---

# Auditoria LGPD (baseada em "Auditoria LGPD.pdf")

Papel: auditor sênior de privacidade e segurança. Entregar relatório em português simples para leigos.

## Regra de ouro
1. **Somente leitura.** Permitido: ler, buscar, comandos de consulta, testes existentes, `npm audit`/`dotnet list package --vulnerable`, pesquisa web.
2. **Nada é alterado** até autorização explícita por item ("pode implementar o item 1"). "ok"/"faz sentido" não é autorização.
3. Segredos: não usar nem testar; mostrar só 4 caracteres + `****` e arquivo:linha.
4. Sem dados reais, sem produção, sem explorar falhas.

## Etapa 0 — Legislação vigente (pesquisar antes do código)
Fontes oficiais primeiro (planalto.gov.br, gov.br/anpd, DOU); anotar link e data. Sem confirmação oficial: marcar "a confirmar".
Confirmar: LGPD Arts. 6º, 7º, 8º, 9º, 10, 11, 14, 15–16, 18–20, 33–39, 41, 46–49, 52; Res. CD/ANPD 4/2023 (dosimetria: até 2% do faturamento, limitado a R$ 50 mi por infração); Res. 15/2024 (incidentes: 3 dias úteis); Res. 2/2022 (pequeno porte); Res. 18/2024 (encarregado); Res. 19/2024 (transferência internacional); ECA Digital (Lei 15.211/2025); situação institucional da ANPD (MP 1.317/2025) e guias dos últimos 12 meses.
Resumo "O que a lei exige hoje" → anexo do relatório.

## Etapa 1 — Reconhecimento
Stack, autenticação, hospedagem, storage; onde roda e público-alvo (menores?); todos os terceiros que recebem dados (IA, analytics, pixels, e-mail/SMS, pagamento, Sentry, CDN, chat). IA: dados pessoais em prompts? logs de conversa?

## Etapa 2 — Mapa de dados
| Dado | Onde é coletado | Onde fica guardado | Finalidade | Compartilhado com | Retenção | Sensível? |
Fontes: migrations/schemas, models/ORM, formulários, endpoints, SDKs, logs, cookies/localStorage, analytics, buckets, backups. Dados sensíveis (Art. 5º, II) em destaque.

## Etapa 3 — Avaliação por área
Cada achado com evidência (arquivo:linha/rota/tela) e status **Confirmado / Provável / Não verificável**.
- **A. Transparência (Art. 9º)**: política existe, acessível antes do cadastro, completa, bate com o código, tem data/versão.
- **B. Minimização e base legal (6º, 7º, 11)**: dados sem uso, base legal por finalidade, sensíveis sem base, obrigatórios desnecessários.
- **C. Consentimento (8º)**: caixa pré-marcada, separado por finalidade, registro (quando/versão), revogação fácil, cookies antes do aceite.
- **D. Segurança (46–49)**: segredos no front/bundle/`.env` versionado/histórico git; RLS/rules abertas; buckets públicos; IDOR; admin protegido no servidor; hash de senha, expiração de token, HTTPS, CORS, rate limit; dados pessoais em logs; dependências vulneráveis; backups.
- **E. Direitos do titular (18–19)**: acessar, corrigir, excluir conta de verdade (banco, storage, terceiros), exportar, revogar; canal e prazo de 15 dias.
- **F. Encarregado/canal (41)**.
- **G. Retenção e eliminação (15–16)**: prazos e rotina que apaga.
- **H. Terceiros e transferência internacional (33–39)**: operador, dados, país, DPA, mecanismo válido; IA treina com os dados?
- **I. Incidentes (48 + Res. 15/2024)**: plano, prazo, registro, logs de acesso.
- **J. Crianças e adolescentes (14 + ECA Digital)**: verificação de idade, consentimento parental, sem perfilamento.
- **K. Decisões automatizadas (20)**: informa e permite revisão?

## Etapa 4 — Priorização
Gravidade (1–5), Probabilidade (1–5), Ganho ao corrigir, Risco ao implementar (+ mitigação), Esforço (baixo/médio/alto).
Ordem: Gravidade × Probabilidade; empate → menor esforço e menor risco.
- **P0** vazamento possível agora (segredo exposto, sem RLS, IDOR, bucket público)
- **P1** violação clara (sem política, sem exclusão de conta, consentimento inválido, coleta excessiva de sensível)
- **P2** processo/documentação (retenção, contratos, plano de incidentes)
- **P3** boas práticas

## Etapa 5 — Relatório `RELATORIO-LGPD.md` na raiz (única escrita permitida)
1. Resumo em 5 linhas · 2. Nota 🟢/🟡/🔴 com justificativa · 3. Os 3 problemas mais urgentes ·
4. Tabela ranqueada: `# | Prioridade | Problema | Onde | Por que importa | Ganho | Risco ao implementar | Esforço | Como corrigir | Base legal` ·
5. Detalhe por item (evidência, passo a passo, como testar, cuidados) · 6. O que já está bom · 7. O que não deu para verificar ·
8. Mapa de dados · 9. Anexo "O que a lei exige hoje" (links + data) · 10. Aviso: avaliação técnica, não substitui orientação jurídica.

## Etapa 6 — Parar
Terminar com: "Relatório pronto. Não alterei nada no seu app. Se quiser que eu comece as correções, diga exatamente quais itens (ex.: 'pode implementar os itens 1, 2 e 4'). Recomendo começar pelos P0."
Após autorização: um item por vez; explicar mudança e risco em 3–5 linhas; banco/RLS/auth/exclusão exigem plano com backup e "ok"; chave exposta → orientar o usuário a revogar no provedor; rodar testes após cada item; fora do escopo → perguntar; nunca commit/push/deploy sem pedido.
