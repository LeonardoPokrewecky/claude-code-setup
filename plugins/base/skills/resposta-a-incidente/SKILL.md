---
name: resposta-a-incidente
description: Roteiro de resposta a incidente em andamento (classificar, conter, preservar evidência, erradicar, recuperar, comunicar e avaliar notificação LGPD), com modelo de linha do tempo. Orienta decisões; ações destrutivas ou em produção só com autorização. Só roda com /resposta-a-incidente [descrição curta do incidente].
disable-model-invocation: true
argument-hint: "[descrição curta do incidente]"
---

Incidente: `$ARGUMENTS`. **Orientação e análise somente leitura.** Nunca ler `.env`, chaves ou certificados; nunca exibir valor de segredo; nunca acessar produção ou dado real sem autorização do usuário. Qualquer ação que altere produção (bloquear, desligar, restaurar, rotacionar, apagar) só com pedido explícito, **um passo por vez**, com o impacto dito antes. Este roteiro é para o incidente **em andamento**; a análise posterior (causa raiz, lições) é o `/postmortem`. Recomendar sessão Opus se a atual for mais fraca.

## 0. Primeiros minutos
1. **Classificar** a gravidade (crítico: dado pessoal/financeiro exposto, sistema fora do ar, invasão ativa; alto; médio; baixo) e o tipo (vazamento de dado, credencial exposta, acesso indevido, malware/ransomware, indisponibilidade, fraude, erro de operação).
2. **Abrir o registro** com data/hora de cada ação (seção 7). Não apagar nada ainda.
3. **Definir quem decide** (responsável pelo incidente) e quem precisa saber agora.
4. **Canal seguro:** se houver suspeita de invasão, não coordenar pelo e-mail, chat ou servidor possivelmente comprometidos; usar canal alternativo e contas não afetadas.

## 1. Contenção (parar o dano sem destruir evidência)
Escolher a menor ação que interrompe o dano, com o impacto dito:
- Credencial exposta: revogar/rotacionar na ordem certa (ver `/gestao-de-segredos`), invalidar sessões e tokens.
- Conta comprometida: bloquear a conta, derrubar sessões, exigir nova senha e MFA.
- Sistema invadido: isolar da rede (não desligar de imediato: a memória e os processos são evidência), bloquear o IP/origem.
- Vazamento por endpoint: desativar o endpoint ou a funcionalidade, não o sistema inteiro, se possível.
- Ransomware: desconectar da rede, preservar backups íntegros, não pagar nem negociar sem decisão da liderança e do jurídico.

## 2. Preservar evidência (antes de limpar)
Copiar logs (aplicação, acesso, banco, proxy, nuvem), imagem/snapshot do disco ou da VM quando houver suspeita de invasão, lista de usuários/sessões/chaves, horário e quem fez o quê. Cópia somente leitura em local separado, com hash. Nunca "arrumar" antes de copiar.

## 3. Investigar o alcance (somente leitura)
O que foi acessado, por quem, desde quando, por onde entrou, quais **dados pessoais** (categorias, titulares, quantidade, sensíveis? menores?), se houve cópia/saída de dados, se o mesmo padrão existe em outros pontos. Marcar o que é **fato**, o que é **suspeita** e o que **não se sabe**.

## 4. Erradicação
Remover a causa, não só o sintoma: corrigir a falha explorada, fechar o acesso, remover persistência (contas, chaves, tarefas agendadas, backdoors), rotacionar **todos** os segredos que o invasor pode ter visto, atualizar dependência vulnerável. Cada mudança com autorização, em ambiente controlado primeiro quando possível.

## 5. Recuperação
Restaurar de backup **íntegro e anterior ao incidente** (testar antes de religar), reativar por etapas, monitorar de perto (alertas mais sensíveis por um período), validar que o acesso do invasor foi encerrado e que os dados estão consistentes (`/alterar-dados` para correção de dados).

## 6. Comunicação e LGPD
- Comunicar internamente conforme a gravidade (liderança, jurídico, encarregado/DPO, suporte).
- Se houver **dado pessoal** com risco ou dano relevante aos titulares, a LGPD prevê comunicação à ANPD e aos titulares, dentro de prazo definido em regulamento da ANPD (verificar a resolução vigente, pois muda com o tempo). **Eu não decido a obrigação nem o prazo:** reunir fatos (seção 3) e levar ao encarregado/jurídico (ver `/lgpd-audit`).
- Comunicação externa: fatos confirmados, sem especular causa nem culpado; um canal único e um responsável.
- Contratos e seguros podem exigir aviso a clientes/parceiros/seguradora: verificar com o jurídico.

## 7. Registro (linha do tempo)
Tabela `data/hora | ação ou evento | quem | evidência (arquivo/log) | resultado`. Manter fatos separados de suposições.

## 8. Encerramento
Incidente só fecha quando: dano contido, causa removida, serviço recuperado e monitorado, comunicações feitas e evidências guardadas. Em seguida, `/postmortem` (causa raiz, o que detectou tarde, ações preventivas) e atualizar o que falhou (alerta, backup, permissão, treinamento).

## Saída
Plano enxuto: `etapa | ação | impacto | quem decide | autorização necessária?`, o que está em fato × suspeita, o que **eu não verifiquei** (ex.: estado real do servidor, logs não fornecidos, extensão do vazamento) e os pontos que dependem do jurídico/encarregado.
