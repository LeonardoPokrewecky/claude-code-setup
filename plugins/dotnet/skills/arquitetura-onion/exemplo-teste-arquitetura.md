# Exemplo: teste de arquitetura (xUnit + NetArchTest)

Carregar sob demanda ao criar `tests/<Produto>.Architecture.Tests`. É **modelo em texto**: adaptar nomes ao produto. Pacote (`NetArchTest.Rules`) só é instalado com pedido do usuário.

O projeto de teste referencia os projetos que valida. Cada regra falha o build com mensagem que diz **o que** violou.

```csharp
using System.Reflection;
using NetArchTest.Rules;
using Xunit;

public class ArquiteturaTests
{
    const string P = "Produto"; // prefixo do produto

    static readonly Assembly Api = typeof(Produto.Api.Program).Assembly;
    static readonly Assembly App = typeof(Produto.Application.DependencyInjection).Assembly;
    static readonly Assembly Dom = typeof(Produto.Domain.DependencyInjection).Assembly;
    static readonly Assembly Infra = typeof(Produto.Infra.DependencyInjection).Assembly;
    static readonly Assembly Shared = typeof(Produto.Shared.Common.EntityBase).Assembly;

    // Allowlist: host -> namespaces do Domain que ele pode usar direto.
    // Deve espelhar a seção Arquitetura do CLAUDE.md do projeto (namespace + motivo).
    static readonly Dictionary<string, string[]> AllowlistHost = new()
    {
        // ["Produto.Desktop"] = new[] { "Produto.Domain.Navegacao" }, // motivo: executável de navegação
    };

    static string[] Referenciados(Assembly a) =>
        a.GetReferencedAssemblies().Select(r => r.Name!).Where(n => n.StartsWith(P)).ToArray();

    [Fact]
    public void Direcao_das_dependencias()
    {
        Assert.DoesNotContain($"{P}.Infra", Referenciados(App));
        Assert.DoesNotContain($"{P}.Domain", Referenciados(Infra));
        Assert.DoesNotContain($"{P}.Application", Referenciados(Infra));
        Assert.DoesNotContain($"{P}.Application", Referenciados(Dom));
    }

    [Fact]
    public void Shared_nao_referencia_projeto()
        => Assert.Empty(Referenciados(Shared));

    [Fact]
    public void Shared_so_com_pacotes_permitidos()
    {
        string[] permitidos = { "System.", "Microsoft.Extensions.", "Microsoft.Extensions.Options", "netstandard", "mscorlib" };
        var fora = Shared.GetReferencedAssemblies().Select(r => r.Name!)
            .Where(n => !permitidos.Any(p => n.StartsWith(p))).ToArray();
        Assert.True(fora.Length == 0, "Pacote fora da lista no Shared: " + string.Join(", ", fora));
    }

    [Fact]
    public void Shared_sem_atributo_de_orm_ou_driver()
    {
        var r = Types.InAssembly(Shared).ShouldNot().HaveCustomAttribute(typeof(System.ComponentModel.DataAnnotations.Schema.TableAttribute))
            .GetResult();
        Assert.True(r.IsSuccessful, "Atributo de ORM no Shared: " + string.Join(", ", r.FailingTypeNames ?? Array.Empty<string>()));
        // Repetir para Key, Column, ForeignKey e [Bson*] (por nome do namespace "MongoDB.").
    }

    [Fact]
    public void Application_nao_usa_implementacao_de_repositorio_nem_driver()
    {
        var r = Types.InAssembly(App).ShouldNot()
            .HaveDependencyOnAny("Microsoft.EntityFrameworkCore", "Npgsql", "MongoDB.Driver", $"{P}.Infra.Repositories.")
            .GetResult();
        Assert.True(r.IsSuccessful, string.Join(", ", r.FailingTypeNames ?? Array.Empty<string>()));
        // Exceção legítima: o namespace das interfaces ({P}.Infra.Repositories.Interfaces).
    }

    [Fact]
    public void Controllers_nao_acessam_repositorio_nem_dbcontext()
    {
        var r = Types.InAssembly(Api).That().HaveNameEndingWith("Controller").ShouldNot()
            .HaveDependencyOnAny("Microsoft.EntityFrameworkCore", $"{P}.Infra.Repositories", $"{P}.Infra.Persistence")
            .GetResult();
        Assert.True(r.IsSuccessful, string.Join(", ", r.FailingTypeNames ?? Array.Empty<string>()));
    }

    [Theory]
    [InlineData("Produto.Desktop")]
    [InlineData("Produto.Async")]
    [InlineData("Produto.Tools")]
    public void Host_so_usa_o_domain_declarado_na_allowlist(string host)
    {
        var asm = AppDomain.CurrentDomain.GetAssemblies().FirstOrDefault(a => a.GetName().Name == host);
        if (asm is null) return; // host ainda não existe no projeto
        var liberados = AllowlistHost.GetValueOrDefault(host, Array.Empty<string>());
        var r = Types.InAssembly(asm).ShouldNot().HaveDependencyOn($"{P}.Domain").GetResult();
        var usados = r.FailingTypeNames ?? Array.Empty<string>();
        // Só passa se cada tipo que usa o Domain estiver coberto por um namespace da allowlist.
        // Implementação concreta: inspecionar as dependências (ex.: via Mono.Cecil ou reflection) e comparar com `liberados`.
        Assert.True(usados.Length == 0 || liberados.Length > 0, $"{host} usa o Domain sem declaração na allowlist");
    }

    [Fact]
    public void Agente_instalado_sem_seguranca_nem_pacote_pesado()
    {
        var asm = AppDomain.CurrentDomain.GetAssemblies().FirstOrDefault(a => a.GetName().Name == "Produto.Desktop");
        if (asm is null) return;
        Assert.DoesNotContain($"{P}.Infra.Security", Referenciados(asm));
    }
}
```

## Notas

- **Allowlist:** a lista do teste e a do `CLAUDE.md` mudam **juntas**, no mesmo commit, com o motivo escrito. Exceção sem declaração nos dois lugares é falha.
- **Referência transitiva:** `GetReferencedAssemblies` vê só a referência direta; por isso as regras por tipo/namespace (Application sem repositório, Controllers sem `DbContext`) são as que de fato protegem.
- **Teste de DI:** além deste, manter o teste que monta o container e resolve controllers, jobs e app services (seção 7 do `SKILL.md`).
- Regra nova (projeto separado, host novo) entra neste arquivo **no mesmo commit** que cria o projeto.
