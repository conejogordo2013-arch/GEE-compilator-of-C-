# JCCSC (C# subset avanzado implementado en C!)

JCCSC está implementado **exclusivamente en C!** y mantiene el pipeline:

`C# -> JCCSC (Lexer/Parser/Semantic/IR/Backend) -> C! -> GEE -> nativo`

## Objetivo del nivel actual

Estabilidad + rendimiento: compilación incremental, caché y pipeline determinista.

## Arquitectura modular

### 1) Lexer extendido
`jccsc_lexer_analyze`
- using avanzado: `using`, `global using`, alias (`using X = Y`)
- namespaces complejos con `.`
- detección de clases anidadas
- `var`, genéricos simples (`< >`), arrays multidimensionales (`[,]`)
- lambda (`=>`), ternario (`?:`), chaining (`.`)
- control flow + excepciones simplificadas
- marcadores modernos: `dynamic`, `record`, `delegate`, `Func/Action`, `async/await`, `where/select/orderby/group`

### 2) Parser/AST extendido
`jccsc_parser_build_ast`
- conteo estructural de:
  - `using_count`, `using_alias_count`, `global_using_count`
  - `namespace_depth_max`
  - `nested_class_count`
  - `var_infer_count`, `generic_count`, `multidim_array_count`
  - `chaining_count`, `lambda_count`, `ternary_count`

### 3) Semantic Analyzer extendido
`jccsc_semantic_validate`
- validaciones base + extendidas:
  - existencia mínima de clase/método
  - balance de `{}`, `()`, `[]`
  - coherencia `try/catch`
  - conflictos simbólicos básicos (`symbol_conflict_count`)
  - compatibilidad de tipos en inicializaciones
  - rechazo de inferencia `var` no resoluble en contexto local

### 4) IR extendido
`jccsc_ir_build`
- IR ahora resume:
  - namespaces y using aliases
  - anidación
  - flujo de control
  - excepciones
  - expresiones complejas
  - inferencia `var`, genéricos y chaining
- normalización determinista con `jccsc_ir_normalize`
- optimización básica con `jccsc_ir_optimize` (reducción de redundancias métricas)

### 5) Backend a C! (degradación progresiva)
`jccsc_backend_translate`
- elimina `using` y wrappers `namespace/class`
- mapeo de tipos:
  - `int -> int32`
  - `float/double -> int64`
  - `char -> byte`
  - `var -> int64` (inferencia simplificada)
- `try/catch/throw` degradado a estructuras equivalentes simples
- chaining `a.b.c` degradado a `a_b_c`
- `dynamic` degradado a `int64`, `record/interface` degradado a `struct`
- marcadores LINQ/Func/Action/delegate degradados a comentarios semánticos (`/*linq*/`, `/*fn*/`, `/*delegate*/`)
- post-procesado determinista con `jccsc_backend_optimize` (espacios/saltos normalizados)

### 6) Compilación incremental y cache
- hash de fuente: `jccsc_hash_source`
- caché incremental por archivo: `JccscCompileCache`
- estadísticas de pipeline: `JccscBuildStats`
- entrada incremental: `jccsc_compile_incremental`
  - cache hit: salta Lexer/Parser/Semantic/IR y reutiliza backend directo sobre la misma fuente
  - cache miss: ejecuta pipeline completo y guarda fingerprints (`source_hash`, `ast_hash`, `ir_hash`, `dep_hash`)

### 7) Diagnostic Engine (estilo compilador moderno)
- estructura central: `JccscDiagnosticEngine`
- severidades:
  - `1=Error` (bloqueante)
  - `2=Warning` (no bloqueante)
  - `3=Info`
  - `4=Hint`
- APIs:
  - `jccsc_diag_init`
  - `jccsc_diag_emit`
  - `jccsc_diag_summary`
  - `jccsc_compile_with_diagnostics`
- códigos por fase:
  - `1000–1999` Lexer
  - `2000–2999` Parser
  - `3000–3999` Semantic
  - `4000–4999` IR
  - `5000–5999` Backend

### 8) Compiler Debugger + AST/IR Visualizer
- sesión de debug: `JccscDebugSession`
- APIs:
  - `jccsc_debug_enable`
  - `jccsc_debug_set_breakpoint`
  - `jccsc_compile_debug`
  - `jccsc_debug_dump_ast_text`
  - `jccsc_debug_dump_ast_json`
  - `jccsc_debug_dump_ir`
- soporte:
  - trace por fases (Lexer, Parser, Semantic, IR Gen, IR Opt, Backend)
  - breakpoints por fase
  - pausa de compilación para inspección (`paused`)

## Restricciones explícitas

- No runtime .NET completo
- No Roslyn
- No dependencias externas del ecosistema C!
- Siempre priorizar pipeline estable hacia GEE

## Gestión semántica y de símbolos (fase actual)

- Inferencia de tipo para `var` basada en literales cuando es posible.
- Compatibilidad numérica básica (`char/int/float/double`) con validación temprana.
- Rechazo temprano de conflictos/símbolos ambiguos antes de IR/Backend.
- Rechazo de duplicados en mismo scope y ambigüedades de firma detectables en el subset.

## Notas de rendimiento

- Evita recompilación completa cuando el hash de fuente no cambia.
- IR y backend se normalizan para salida determinista y más predecible.

## Cobertura moderna (subset avanzado, sin runtime .NET)

- Tipos: `var`, `dynamic` (simulado), nullable (`T?` degradado), tuples/records (degradados estructuralmente).
- Funcional: lambdas y chaining con lowering progresivo.
- LINQ: `where/select/orderby/group` como nodos/marcadores traducibles.
- Async: `async/await` transformados de forma estructural sin runtime externo.
