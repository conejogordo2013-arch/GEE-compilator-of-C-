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
- post-procesado determinista con `jccsc_backend_optimize` (espacios/saltos normalizados)

### 6) Compilación incremental y cache
- hash de fuente: `jccsc_hash_source`
- caché incremental por archivo: `JccscCompileCache`
- estadísticas de pipeline: `JccscBuildStats`
- entrada incremental: `jccsc_compile_incremental`
  - cache hit: salta Lexer/Parser/Semantic/IR y reutiliza backend directo sobre la misma fuente
  - cache miss: ejecuta pipeline completo y guarda fingerprints (`source_hash`, `ast_hash`, `ir_hash`, `dep_hash`)

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
