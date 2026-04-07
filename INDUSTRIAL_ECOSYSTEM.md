# Ecosistema Industrial de C! (GEE)

## Build de programas C! sin C compiler drivers

- Build simple:
  - `bash scripts/gee-dev-build.sh x86-64 app.cb app_bin`
- Build con librerías C! adicionales:
  - `bash scripts/gee-dev-build.sh x86-64 app.cb app_bin stdlib/strings.cb stdlib/vec_i32.cb`

## Testing automatizado

- Batería completa:
  - `make all-tests`
- Runner de desarrollo con reporte:
  - `bash scripts/gee-dev-test.sh`
  - Reporte en `.gee_reports/latest.txt`

## Librerías incluidas

- `stdlib/extras.cb` utilidades numéricas.
- `stdlib/strings.cb` utilidades de cadenas.
- `stdlib/vec_i32.cb` vector dinámico de enteros.

## Ejemplo industrial

- `examples/industrial_demo.cb`
  - Demuestra strings + vector dinámico + manejo de memoria.
