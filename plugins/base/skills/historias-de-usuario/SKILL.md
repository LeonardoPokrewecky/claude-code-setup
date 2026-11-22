---
name: historias-de-usuario
description: Escreve histórias de usuário (persona, ação, benefício) com critérios de aceite testáveis, casos de erro e condição de pronto, e quebra épicos em histórias pequenas. Só roda com /historias-de-usuario [objetivo ou épico].
disable-model-invocation: true
argument-hint: "[objetivo | épico]"
---

Alvo: `$ARGUMENTS` (sem argumento: perguntar o objetivo de negócio). **Somente texto/proposta**; não implementa. Para o desenho técnico antes de implementar, usar `/blueprint`. Declarar suposições e perguntar o que for ambíguo em vez de inventar regra.

## 1. Levantar
Quem é o usuário (persona/perfil), qual problema resolve, qual resultado de negócio mede o sucesso, restrições (prazo, legal/LGPD, integração), o que está **fora** do escopo.

## 2. História
Formato: **Como** `<persona>`, **quero** `<ação>`, **para** `<benefício>`. Boa história é Independente, Negociável, Valiosa, Estimável, Pequena e Testável (INVEST). Épico grande é quebrado por fatia vertical (valor entregável de ponta a ponta), não por camada técnica.

## 3. Critérios de aceite
Verificáveis e sem ambiguidade (Dado/Quando/Então):
- caminho feliz;
- **casos de erro desde o início:** entrada vazia, duplicada, no limite, sem permissão, falha de rede, concorrência;
- requisitos não funcionais que importam (desempenho, acessibilidade, segurança, privacidade);
- dado pessoal: finalidade, base legal e retenção definidas (`/lgpd-audit`).

## 4. Condição de pronto
Critérios atendidos e testados, revisão feita (`/revisar`), sem pendência (`/entrega-sem-pendencia`), documentação atualizada, métrica de sucesso instrumentada (`/metricas-de-produto`).

## Saída
Lista de histórias `id | história | critérios de aceite | dependências | fora do escopo`, perguntas em aberto e suposições registradas.
