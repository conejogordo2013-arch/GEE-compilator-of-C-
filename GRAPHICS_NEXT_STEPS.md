# Roadmap inicial: OpenGL ES -> OpenGL -> Vulkan en C!

Este documento propone **cómo evolucionar la librería gráfica actual** (libogl/libdrawg) para soportar:

- OpenGL ES (móvil/embebido)
- OpenGL (desktop)
- Vulkan
- Targets: ARM64 y x86_64
- Plataformas: Termux X11, Linux, Windows

> Restricción clave: todo el código de alto nivel y la API pública deben estar en **C!**. No depender de escribir lógica de motor en C.

---

## 1) Objetivo técnico (MVP realista)

Primero no intentamos hacer “un engine completo”; hacemos una base sólida:

1. **Ventana + contexto + swapchain** (según backend).
2. **Render triángulo** y **render sprite 2D**.
3. **Pipeline común en C!** para que el usuario no cambie API según backend.
4. **Pruebas automáticas** por backend y arquitectura.

Resultado esperado del MVP:

- Mismo programa C! puede correr en:
  - GL desktop (Linux/Windows)
  - GLES (Termux X11/Linux ARM)
  - Vulkan (Linux/Windows; luego Android)

---

## 2) Arquitectura propuesta (capas)

### Capa A — API pública estable (`libgfx`)

Crear una librería nueva (o evolucionar `libogl` hacia esto) con API tipo:

- `gfx_init(config)`
- `gfx_create_window(...)`
- `gfx_create_device(...)`
- `gfx_create_buffer(...)`
- `gfx_create_texture(...)`
- `gfx_begin_frame()`
- `gfx_draw(...)`
- `gfx_end_frame()`
- `gfx_shutdown()`

Esta capa **no expone detalles** de GL/GLES/Vulkan.

### Capa B — HAL/Backend (`libgfx_backend_*`)

Implementaciones separadas:

- `libgfx_backend_gl.cb`
- `libgfx_backend_gles.cb`
- `libgfx_backend_vk.cb`

Cada backend cumple el mismo contrato interno.

### Capa C — Plataforma (`platform_*`)

Manejo de ventana/input/superficie:

- Linux/X11
- Termux X11 (también X11)
- Windows (Win32)

Esta capa abstrae: crear ventana, obtener eventos, tamaño framebuffer, timing.

### Capa D — Runtime/FFI mínimo

Para enlazar con drivers del sistema (libGL, libEGL, Vulkan loader, user32, etc.) se necesita:

- Declaraciones `extern` en C!.
- Tipos compatibles ABI (int32/int64/punteros).
- Cargador dinámico (`dlopen/dlsym` en Linux, `LoadLibrary/GetProcAddress` en Windows).

La regla es: **el binding puede llamar bibliotecas nativas**, pero la lógica del motor y API sigue en C!.

---

## 3) Estrategia por API gráfica

## 3.1 OpenGL ES (primer objetivo)

Ideal para Termux X11/Android-like entornos.

1. Crear contexto EGL + surface X11.
2. Cargar funciones GLES dinámicamente.
3. Usar GLSL ES shaders.
4. Compatibilidad de formatos/texturas alineada a GLES3.

Sugerencia práctica: diseñar shaders “cross-profile” (GL y GLES) con macros.

## 3.2 OpenGL desktop (segundo objetivo)

Implementación recomendada:

1. Crear contexto GL (GLX o EGL en Linux; WGL o EGL en Windows).
2. Cargar funciones GL dinámicamente (tabla de function pointers en C!).
3. Backend mínimo:
   - shader compile/link
   - VBO/VAO
   - draw arrays/indexed
   - textura RGBA8
4. Añadir capa de estado para minimizar cambios redundantes.

Ventaja: camino directo para paridad desktop con lo ya validado en GLES.

## 3.3 Vulkan (tercer objetivo)

Es más complejo; hacerlo en fases:

Fase 1 Vulkan:

- instance, physical device, logical device
- queue graphics/present
- swapchain + image views
- render pass simple
- pipeline básico
- command buffers y sync (semaphores/fences)

Fase 2 Vulkan:

- descriptor sets
- uniform buffers
- staging buffers
- texture sampling

Fase 3 Vulkan:

- material system
- render graph simple
- multithread recording

---

## 4) ARM64 y x86_64: qué cambia realmente

En gráficos modernos, la mayor parte es API-level (GL/VK). Para ARM/x86 los puntos críticos son:

1. **ABI y calling convention**
   - Confirmar que wrappers `extern` en C! respetan ABI por arquitectura.
2. **Tamaños de tipos**
   - Definir tipos canónicos (`u32`, `u64`, `usize`, `ptr`) y usarlos en toda la capa gráfica.
3. **Alineación de estructuras**
   - Especialmente en Vulkan (`Vk*CreateInfo`, uniform buffers std140/std430).
4. **Endianness**
   - Usualmente little-endian en ARM64/x86_64 actuales, pero documentarlo.
5. **Optimización CPU**
   - Raster software (si existe fallback) puede tener rutas SIMD separadas (NEON/SSE/AVX), opcionales.

Recomendación: crear `gfx_types.cb` con tipos y asserts de tamaño por target.

---

## 5) Plan por plataforma

## 5.1 Termux X11

Objetivo inicial:

- Ventana X11
- Contexto EGL + GLES3
- Presentación por swap buffers

Checklist:

- Loader dinámico de `libEGL.so` y `libGLESv2.so`
- Event loop X11 estable
- Manejo de resize

## 5.2 Linux desktop

Dos caminos:

- GL/GLES con X11+EGL
- Vulkan con Xlib/Xcb surface

Recomendación: arrancar con X11+EGL para GL/GLES y luego Vulkan.

## 5.3 Windows

- GL: WGL o EGL
- Vulkan: `vulkan-1.dll`
- Ventana/input: Win32

Recomendación: empezar con GL en Windows para acelerar pruebas visuales.

---

## 6) Evolución de la librería existente

Ya hay base (`libogl`, `libdrawg`). Evolución incremental:

1. Mantener API actual para compatibilidad.
2. Introducir módulo nuevo `libgfx` sin romper demos existentes.
3. Reusar canvas/software renderer como fallback “headless”.
4. Crear adaptador:
   - `drawg_present(canvas)` -> textura + quad en backend GL/GLES/VK

Así se puede migrar app por app sin romper lo actual.

---

## 7) Diseño mínimo de API (propuesta)

```text
struct GfxConfig { backend, vsync, validation, width, height, title }
struct GfxBuffer { handle, size, usage }
struct GfxTexture { handle, width, height, format }

fn gfx_init(cfg*) -> int
fn gfx_begin_frame(r,g,b,a)
fn gfx_draw_mesh(mesh*, material*, transform*)
fn gfx_draw_sprite(tex*, x,y,w,h, color)
fn gfx_end_frame()
fn gfx_shutdown()
```

Notas:

- `backend = AUTO | GL | GLES | VULKAN | SOFTWARE`
- `AUTO` detecta disponibilidad en runtime.

---

## 8) Testing que sí conviene desde el día 1

1. **Smoke tests** por backend: crear ventana, limpiar color, presentar 300 frames.
2. **Golden image tests** para raster 2D (checksum ya existente).
3. **Stress tests**: resize continuo, recreación de swapchain, pérdida de foco.
4. **Cross-arch CI**:
   - x86_64 Linux
   - ARM64 Linux/Termux (al menos nightly/manual inicialmente)

También crear test matrix:

- backend × plataforma × arquitectura × modo debug/release.

---

## 9) Primer backlog (orden recomendado)

Semana 1–2:

- Definir `libgfx` API y tipos base.
- Implementar loader dinámico multiplataforma en C!.
- Implementar backend `SOFTWARE` estable (para pruebas sin GPU).

Semana 3–4 (FASE 1 = OpenGL ES):

- Backend GLES mínimo (Termux X11/Linux ARM64).
- Demo: triángulo + sprite + textura RGBA.
- Validar loop de eventos, resize y vsync en X11/EGL.

Semana 5–6 (FASE 2 = OpenGL):

- Backend OpenGL desktop (Linux x86_64 primero).
- Reusar API y shaders base del backend GLES con capa de compatibilidad.
- Demo cruzado GLES/GL con el mismo código C! de alto nivel.

Semana 7–9 (FASE 3 = Vulkan):

- Backend Vulkan MVP Linux.
- Integrar validación opcional y logs detallados.
- Paridad mínima con features ya probadas en GLES/GL (triángulo + sprite).

Semana 10+ (consolidación multiplataforma):

- Windows GL/Vulkan.
- Base para escena 3D, cámara, materiales simples.

---

## 10) Riesgos y mitigaciones

- **Riesgo:** FFI insuficiente para APIs grandes (Vulkan).
  - **Mitigación:** generar bindings C! desde headers (script).
- **Riesgo:** bugs por layout de structs.
  - **Mitigación:** tests de sizeof/offset + ejemplos mínimos por API.
- **Riesgo:** fragmentación backend.
  - **Mitigación:** contrato HAL pequeño y estricto, con tests comunes.

---


## 11) Orden oficial de implementación (acordado)

Para avanzar sin dispersión, el orden queda fijo:

1. **OpenGL ES primero** (Termux X11 + Linux ARM64/x86_64 con EGL).
2. **OpenGL después** (desktop Linux/Windows).
3. **Vulkan al final** (cuando la API común ya esté sólida).

Criterio de salida por fase:

- Cada fase termina cuando corre el demo `triángulo + sprite` con la misma API pública de C!
- No se inicia la fase siguiente si la anterior no pasa smoke tests + resize + teardown limpio.

---

## 12) “Lo primero para empezar a programar” (acción inmediata)

1. Crear carpeta `libgfx/` con:
   - `README.md`
   - `types.cb`
   - `api.cb`
   - `backend_interface.cb`
2. Implementar backend `software` usando código actual de canvas.
3. Añadir un demo único `examples/gfx_bootstrap_demo.cb` que use `backend=AUTO`.
4. Añadir script de prueba `scripts/test-gfx-bootstrap.sh`.

Si ese demo corre en tu entorno (Termux X11/Linux/Windows), ya tienes cimiento para conectar GL/GLES/Vulkan sin rediseñar todo después.

---

## 13) Regla de oro de diseño

Haz que el usuario del lenguaje piense en:

- mallas
- texturas
- materiales
- cámaras

Y **no** en:

- EGLConfig
- VkSwapchainCreateInfo
- punteros de extensión

Esos detalles deben quedar encapsulados en la implementación del backend en C!.
