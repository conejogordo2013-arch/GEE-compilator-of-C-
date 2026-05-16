# libgfx (bootstrap)

Primera base para el roadmap **OpenGL ES -> OpenGL -> Vulkan**.

## Estado actual

- API pública inicial en `api.cb`.
- Tipos base en `types.cb`.
- Backend de arranque `SOFTWARE` en `backend_interface.cb`.
- Render actual: clear + sprite 2D + checksum determinista (sin ventana).

## Próximo paso

Conectar `backend_gles.cb` al mismo contrato interno para empezar la Fase 1.


## OpenGL ES bootstrap

- `backend_gles.cb` agrega ciclo mínimo: init -> clear -> swap -> shutdown.
- `examples/gfx_gles_clear_demo.cb` muestra color sólido para validar salida visual en ventana.
- `backend_gles_stub.cb` permite compilar/linkear el scaffold GLES sin EGL real.
- `scripts/test-gles-bootstrap.sh` valida compilación/link del flujo inicial con stubs.


## 2D multiplataforma (paso actual antes de GLES)

- `gfx2d.cb` agrega API 2D simple sobre `drawg` para ventana + resolución + frame loop.
- `examples/gfx2d_window_demo.cb` dibuja grilla/diagonales para validar salida visual 2D.
- `scripts/gfx2d-run.sh` detecta plataforma y selecciona backend:
  - Windows: `backend_windows_gdi.cb`
  - Linux/Termux: `backend_linux_x11.cb` (ventana X11 real)
  - Otros: `backend_stub.cb`

> Nota: para Linux/Termux X11 ahora se usa backend X11 real; framebuffer queda como opción de fallback manual.
