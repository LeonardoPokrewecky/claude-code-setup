# Lente: LGPD e privacidade

Acionar quando o diff toca dado pessoal, telas/formulários, logs, scraping ou integração que envia dados. Auditoria completa do app: `/lgpd-audit`.

- **Coleta:** o dado é necessário para a finalidade (minimização)? Campo novo de dado pessoal tem finalidade clara? Dado sensível (saúde, biometria, religião, origem racial, menores) tem tratamento reforçado?
- **Logs e telemetria:** CPF, e-mail, telefone, endereço, token, IP ou corpo de requisição em log, mensagem de erro, analytics ou ferramenta de monitoramento.
- **Armazenamento:** dado pessoal em `localStorage`/`sessionStorage` sem criptografia, em cache, em arquivo temporário, em URL/query string, em backup sem prazo. Retenção e exclusão previstas?
- **Compartilhamento:** envio a terceiro (API, SDK, CDN, IA) sem base legal ou sem registro; scraping que coleta dado pessoal de terceiros (base legal, minimização, origem pública ≠ livre uso).
- **Acesso:** quem pode ver o dado (perfil, tenant); listagem/exportação expõe mais do que o necessário; mascaramento em tela (CPF parcial).
- **Direitos do titular:** a mudança dificulta acesso, correção, exclusão ou portabilidade?
- **Frontend:** consentimento antes de cookies/rastreadores não essenciais; texto ao usuário explica o uso; auditoria de login não guarda foto, captura de câmera nem senha tentada.

Para cada achado: qual dado, onde trafega ou fica, e o risco para o titular.
