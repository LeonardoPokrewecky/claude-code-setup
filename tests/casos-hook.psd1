@{
    # Esperado: Bloqueia (exit 2), Confirma (JSON "ask"), Libera (exit 0 sem saída).
    Casos = @(
        # --- Bloqueia: arquivos de segredo ---
        @{ Comando = 'cat .env'; Esperado = 'Bloqueia' }
        @{ Comando = 'echo .env'; Esperado = 'Bloqueia' }
        @{ Comando = 'type .env.local'; Esperado = 'Bloqueia' }
        @{ Comando = 'Get-Content .e""nv'; Esperado = 'Bloqueia' }
        @{ Comando = 'Get-Content .e`nv'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat prod.env'; Esperado = 'Bloqueia' }
        @{ Comando = 'git show HEAD:.env'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat .env>x.txt'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat .envrc'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat appsettings.Production.json'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat src/Api/appsettings.Staging.json'; Esperado = 'Bloqueia' }
        @{ Comando = 'type appsettings.Local.json'; Esperado = 'Bloqueia' }
        @{ Comando = 'type appsettings.Homologation.json'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat local.settings.json'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat cert.pfx'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat server.key'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat chave.pem'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat secrets/db.txt'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat my-secrets.json'; Esperado = 'Bloqueia' }
        @{ Comando = 'dir $env:APPDATA\Microsoft\UserSecrets'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat .git-credentials'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat ~/.claude/.credentials.json'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat ~/.claude.json'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat ~/.ssh/id_ed25519'; Esperado = 'Bloqueia' }
        @{ Comando = 'ls ~/.ssh'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat ~/.aws/credentials'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat ~/.kube/config'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat ~/.docker/config.json'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat ~/.config/gh/hosts.yml'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat .npmrc'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat ~/.pgpass'; Esperado = 'Bloqueia' }

        # --- Confirma: configuração do Claude Code, comando escondido, rede, git destrutivo ---
        @{ Comando = 'cat ~/.claude/settings.json'; Esperado = 'Confirma' }
        @{ Comando = 'echo x > ~/.claude/hooks/bloquear-segredos.ps1'; Esperado = 'Confirma' }
        @{ Comando = 'Copy-Item x.md ~/.claude/CLAUDE.md'; Esperado = 'Confirma' }
        @{ Comando = 'cd .claude'; Esperado = 'Confirma' }
        @{ Comando = 'powershell -File scripts/merge-settings.ps1 -Confirmar abc123'; Esperado = 'Confirma' }
        @{ Comando = 'powershell -enc ZQBjAGgAbwA='; Esperado = 'Confirma' }
        @{ Comando = 'echo ZWNobw== | base64 -d'; Esperado = 'Confirma' }
        @{ Comando = '[Convert]::FromBase64String($x)'; Esperado = 'Confirma' }
        @{ Comando = '(New-Object Net.WebClient).DownloadString($u)'; Esperado = 'Confirma' }
        @{ Comando = 'printenv'; Esperado = 'Confirma' }
        @{ Comando = 'Get-ChildItem env:'; Esperado = 'Confirma' }
        @{ Comando = 'dotnet user-secrets list'; Esperado = 'Confirma' }
        @{ Comando = 'cat web.config'; Esperado = 'Confirma' }
        @{ Comando = 'cat *.pem'; Esperado = 'Confirma' }
        @{ Comando = 'ls .cl*'; Esperado = 'Confirma' }
        @{ Comando = 'git push origin main'; Esperado = 'Confirma' }
        @{ Comando = 'git -C ../outro push'; Esperado = 'Confirma' }
        @{ Comando = 'npm test && git push'; Esperado = 'Confirma' }
        @{ Comando = 'git add . ; git commit -m "x"'; Esperado = 'Confirma' }
        @{ Comando = 'git fetch'; Esperado = 'Confirma' }
        @{ Comando = 'git pull --rebase'; Esperado = 'Confirma' }
        @{ Comando = 'git reset --hard HEAD~1'; Esperado = 'Confirma' }
        @{ Comando = 'git clean -fdx'; Esperado = 'Confirma' }
        @{ Comando = 'git checkout -- src/a.cs'; Esperado = 'Confirma' }
        @{ Comando = 'git checkout HEAD -- src/a.cs'; Esperado = 'Confirma' }
        @{ Comando = 'git checkout .'; Esperado = 'Confirma' }
        @{ Comando = 'git restore src/a.cs'; Esperado = 'Confirma' }
        @{ Comando = 'git stash drop'; Esperado = 'Confirma' }
        @{ Comando = 'git branch -D feature'; Esperado = 'Confirma' }
        @{ Comando = 'git remote set-url origin x'; Esperado = 'Confirma' }
        @{ Comando = 'git -c core.x=y push'; Esperado = 'Confirma' }

        # --- Libera: uso normal ---
        @{ Comando = 'git status'; Esperado = 'Libera' }
        @{ Comando = 'git status -sb'; Esperado = 'Libera' }
        @{ Comando = 'git diff --stat'; Esperado = 'Libera' }
        @{ Comando = 'git log --oneline -5 && git status'; Esperado = 'Libera' }
        @{ Comando = 'git checkout main'; Esperado = 'Libera' }
        @{ Comando = 'git branch -d feature'; Esperado = 'Libera' }
        @{ Comando = 'git worktree list'; Esperado = 'Libera' }
        @{ Comando = 'cat appsettings.json'; Esperado = 'Libera' }
        @{ Comando = 'cat src/Api/appsettings.Development.json'; Esperado = 'Libera' }
        @{ Comando = 'dotnet build'; Esperado = 'Libera' }
        @{ Comando = 'npm run build'; Esperado = 'Libera' }
        @{ Comando = 'grep -rn "process.env" src'; Esperado = 'Libera' }
        @{ Comando = 'Get-ChildItem *.cs -Recurse'; Esperado = 'Libera' }
        @{ Comando = 'ls src | sort'; Esperado = 'Libera' }
        @{ Comando = 'cat README.md'; Esperado = 'Libera' }
        @{ Comando = 'rg "Component" src/app'; Esperado = 'Libera' }
        # Falsos positivos corrigidos na evolução (medição da Fase 1).
        @{ Comando = 'cat .env.example'; Esperado = 'Libera' }
        @{ Comando = 'cp .env.sample .env.template'; Esperado = 'Libera' }
        @{ Comando = 'node -e "console.log(obj.key)"'; Esperado = 'Libera' }
        # Encadeamentos de rede/exclusão: cobertos pelas regras ask nativas, que dividem o comando
        # (https://code.claude.com/docs/en/permissions#compound-commands); o hook não duplica.
        @{ Comando = 'cd build && rm -rf out'; Esperado = 'Libera' }
        @{ Comando = 'ls; curl https://example.com'; Esperado = 'Libera' }
        @{ Comando = 'dir | Remove-Item'; Esperado = 'Libera' }

        # --- Bloqueia: limites das correções acima ---
        @{ Comando = 'cat .env.example.local'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat .env.production'; Esperado = 'Bloqueia' }
        @{ Comando = 'type C:\certs\api.pfx'; Esperado = 'Bloqueia' }
        @{ Comando = 'cat "keys/server.key"'; Esperado = 'Bloqueia' }
    )
}
