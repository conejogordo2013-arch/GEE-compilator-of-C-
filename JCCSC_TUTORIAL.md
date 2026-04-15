# Tutorial completo: instalar C! (GEE), usar JCCSC y ejecutar en modos (x86-64 + ARM64)

Este tutorial explica, paso a paso:

1. Cómo instalar/compilar C! (GEE) en **x86-64** y **ARM64**.
2. Cómo compilar y ejecutar desde ejemplos básicos (Hola Mundo) hasta flujos complejos.
3. Cómo usar **JCCSC** como frontend C# subset y como librería integrada.
4. Cómo cambiar entre modos:
   - compilación
   - debug
   - simulación runtime (interpretado)

---

## 1) Requisitos

- Linux/macOS (o Termux en Android con toolchain compatible).
- `make`, `bash`, `as`, `ld`, `rg` y compilador C (`cc`).
- Para ARM64 cruzado en host x86-64: toolchain `aarch64-linux-gnu-*` (opcional).

---

## 2) Instalar/compilar C! (GEE)

### 2.1 Build local (x86-64 host)

```bash
make stage0
```

Esto genera `./gee`.

### 2.2 Instalación en sistema (opcional)

```bash
make install PREFIX=/usr/local
```

Binarios instalados:
- `gee-core`
- `gee`
- `gee-target`
- `gee-doctor`
- `gee-new`
- `gee-run`

### 2.3 ARM64

En host ARM64:

```bash
make stage0
```

Cross emit ARM64 desde x86-64:

```bash
GEE_BIN=./gee bash scripts/gee-asm-link.sh arm-64 examples/no_cc.cb no_cc_arm64
```

### 2.4 ¿Y si no está disponible el modo `no-cc`?

Si en tu entorno no tienes `as/ld` compatibles o quieres flujo clásico con driver C, usa **clang** o **gcc** como fallback:

#### Opción A: clang

```bash
./gee examples/no_cc.cb /tmp/program.s
clang -no-pie -o program_clang /tmp/program.s stdlib/io.s stdlib/memory.s stdlib/net.s stdlib/system.s
./program_clang
```

#### Opción B: gcc

```bash
./gee examples/no_cc.cb /tmp/program.s
gcc -no-pie -o program_gcc /tmp/program.s stdlib/io.s stdlib/memory.s stdlib/net.s stdlib/system.s
./program_gcc
```

> Recomendación: preferir `no-cc` para validar independencia de toolchain C, pero clang/gcc son compatibles para desarrollo rápido.

---

## 3) Primer programa: Hola Mundo (básico)

```bash
bash scripts/smoke-hola-mundo.sh
```

También manual:

```bash
./gee examples/hola_mundo.cb /tmp/hola.s
```

Con fallback clang/gcc:

```bash
clang -no-pie -o hola /tmp/hola.s stdlib/io.s stdlib/memory.s stdlib/net.s stdlib/system.s
# o gcc -no-pie -o hola /tmp/hola.s ...
./hola
```

---

## 4) Test masivo recomendado (básico -> complejo)

### 4.1 Pipeline JCCSC + LSP

```bash
bash tests/jccsc/test_jccsc.sh
bash tests/jccsc/test_jccsc_lsp.sh
```

### 4.2 Complejidad creciente

```bash
bash scripts/test-complex-cases.sh
bash scripts/test-deep-validation.sh
bash scripts/test-language-runtime.sh
bash scripts/test-frontend-robustness.sh
```

---

## 5) Usar JCCSC como librería

Puedes incluir `jccsc/jccsc.cb` desde un programa C!:

```cb
#include "./jccsc/jccsc.cb"
```

Y ejecutar:

- `jccsc_compile_to_cbang` (pipeline completo C# -> C!)
- `jccsc_compile_incremental` (modo incremental/cache)
- `jccsc_compile_debug` (traza por fases)
- `jccsc_compile_with_diagnostics` (errores/warnings detallados)

---

## 6) Modos de ejecución de JCCSC

## 6.1 Modo compilación (pipeline completo)

Entrada C# subset -> Lexer/Parser/Semantic/IR -> backend C!:

```c
jccsc_compile_to_cbang(src, out, cap, &lex, &ast, &ir);
```

## 6.2 Modo debug compilador

```c
jccsc_debug_enable(&dbg, trace_buf, trace_cap, 2);
jccsc_debug_set_breakpoint(&dbg, 3, 0, 0);
jccsc_compile_debug(src, out, cap, &dbg, &lex, &ast, &ir);
```

## 6.3 Modo simulación runtime (interpretado)

```c
jccsc_sim_init(&sim, src_buf, src_cap, trace_buf, trace_cap, 100000, 2048);
jccsc_sim_load_source(&sim, src, &ir);
jccsc_sim_step_into(&sim);
jccsc_sim_continue(&sim, 512);
jccsc_sim_dump_state(&sim, out, out_cap);
```

## 6.4 Cambio de modo recomendado (práctico)

1. **editor/LSP activo**: autocompletado, hover, diagnósticos incrementales.
2. **refactor**: aplicar `codeAction` / `rename` y validar semántica.
3. **simulación runtime**: `debugStart` + `debugStep` para entender ejecución.
4. **compilación final**: pipeline completo a C!/ASM/binario.

---

## 7) Usar JCCSC vía LSP (editor)

Métodos soportados:

- Core LSP:
  - `initialize`, `shutdown`
  - `textDocument/didOpen`, `didChange`, `didSave`
  - `completion`, `hover`, `definition`, `references`, `documentSymbol`, `signatureHelp`
- Refactor:
  - `textDocument/codeAction`
  - `textDocument/rename`
- Debugger LSP:
  - `jccsc/debugStart`
  - `jccsc/debugStep`
  - `jccsc/debugContinue`
  - `jccsc/debugVariables`
  - `jccsc/debugStack`

### Ejemplo mínimo JSON-RPC (rename + debug)

```json
{"jsonrpc":"2.0","method":"textDocument/rename","params":{"oldName":"x","newName":"total"}}
{"jsonrpc":"2.0","method":"jccsc/debugStart","params":{}}
{"jsonrpc":"2.0","method":"jccsc/debugStep","params":{}}
```

---

## 8) Flujo recomendado para proyectos

1. Editar C# subset.
2. Obtener IntelliSense + diagnostics (LSP).
3. Aplicar refactors seguros (`codeAction`, `rename`).
4. Depurar con runtime simulator (`debugStart`, `debugStep`...).
5. Compilar a C! / ASM / nativo con GEE.

---

## 9) Comandos útiles de operación diaria

```bash
make stage0
bash tests/jccsc/test_jccsc.sh
bash tests/jccsc/test_jccsc_lsp.sh
bash scripts/test-complex-cases.sh
bash scripts/test-deep-validation.sh
bash scripts/test-language-runtime.sh
```

Fallback clang/gcc (si no-cc no está disponible):

```bash
./gee examples/no_cc.cb /tmp/no_cc.s
clang -no-pie -o no_cc /tmp/no_cc.s stdlib/io.s stdlib/memory.s stdlib/net.s stdlib/system.s
# o gcc -no-pie -o no_cc /tmp/no_cc.s ...
./no_cc
```

---

## 10) Notas de compatibilidad

- Sin Roslyn.
- Sin runtime de .NET.
- Implementado en C!.
- Compatible con pipeline:
  `C# -> JCCSC -> IR -> C! -> GEE -> nativo`.
