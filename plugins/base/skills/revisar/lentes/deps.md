# Lente: dependências

Só comandos de leitura: `npm outdated`, `npm audit`, `dotnet list package --vulnerable --outdated`, `pip list --outdated`. **Nunca atualizar.**

- Vulnerabilidades conhecidas (severidade, se o código usa a parte afetada).
- Pacotes muito desatualizados ou abandonados; licença incompatível.
- Dependência nova no diff: necessária? Já existe algo equivalente no projeto?
- Lockfile coerente com o manifesto (lockfile reescrito por versão errada de Node/SDK).
