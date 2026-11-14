---
max_turns: 8
allowed_tools: [Skill, Read, Glob, Grep]
---

/base:revisar auto o diff abaixo, antes de eu abrir o PR.

```diff
+[HttpGet("clientes/buscar")]
+public IActionResult Buscar(string nome)
+{
+    var sql = "SELECT * FROM Clientes WHERE Nome = '" + nome + "'";
+    var dados = _db.Query(sql);
+    return Ok(dados);
+}
```

Não há teste novo no PR.
