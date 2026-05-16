# Tutorial completo: instalar y usar C! en Windows 11

Esta guía explica cómo instalar el lenguaje **C!** en Windows 11, compilar el compilador `gee`, ejecutar programas `.cb`, y preparar el entorno para gráficos 2D/ventanas antes de avanzar a OpenGL ES/OpenGL/Vulkan.

---

## 0) Qué ruta usar en Windows 11

Hay dos rutas recomendadas:

1. **Windows nativo con MSYS2/MinGW64** — recomendado si quieres ventanas Windows con GDI y futuros backends gráficos nativos.
2. **WSL2 Ubuntu** — recomendado si quieres un entorno Linux cómodo dentro de Windows.

Si tu objetivo inmediato es probar la ruta de ventana Windows (`backend_windows_gdi.cb`), usa **MSYS2/MinGW64**.

---

## 1) Instalación recomendada: Windows nativo con MSYS2/MinGW64

### 1.1 Instalar MSYS2

1. Descarga MSYS2 desde su sitio oficial.
2. Instálalo en la ruta por defecto, por ejemplo:

```text
C:\msys64
```

3. Abre **MSYS2 UCRT64** o **MSYS2 MINGW64** desde el menú inicio.

> Para este proyecto, usa siempre una shell MinGW/UCRT, no la shell `MSYS` básica, cuando quieras generar binarios `.exe` nativos.

### 1.2 Actualizar paquetes base

Dentro de la terminal MSYS2:

```bash
pacman -Syu
```

Si MSYS2 te pide cerrar la ventana, ciérrala, vuelve a abrir **MSYS2 UCRT64/MINGW64** y ejecuta:

```bash
pacman -Syu
```

### 1.3 Instalar herramientas necesarias

Para compilar el compilador C! y usar scripts:

```bash
pacman -S --needed git make bash binutils mingw-w64-ucrt-x86_64-gcc
```

Si estás usando la shell **MINGW64** en vez de **UCRT64**, instala:

```bash
pacman -S --needed git make bash binutils mingw-w64-x86_64-gcc
```

---

## 2) Clonar el repositorio

En la terminal MSYS2/UCRT64 o MINGW64:

```bash
cd ~
git clone <URL_DEL_REPO> GEE-compilator-of-C-
cd GEE-compilator-of-C-
```

Si ya tienes el repo descargado, solo entra a la carpeta:

```bash
cd /ruta/a/GEE-compilator-of-C-
```

---

## 3) Compilar el compilador base `gee`

Ejecuta:

```bash
make stage0
```

Esto debe generar el binario:

```text
./gee.exe
```

o, dependiendo del entorno:

```text
./gee
```

Verifica que exista:

```bash
./gee --help || true
```

> `|| true` evita que la shell marque error si el compilador todavía no tiene una salida `--help` completa.

---

## 4) Primer programa C!

Crea un archivo rápido:

```bash
cat > hola_windows.cb <<'CB'
import system;

int32 main() {
    system_exit(0);
    return 0;
}
CB
```

Compílalo a assembly:

```bash
./gee hola_windows.cb hola_windows.s
```

Para generar un ejecutable usando el flujo no-cc del proyecto:

```bash
GEE_BIN=./gee bash scripts/gee-asm-link.sh host hola_windows.cb hola_windows_demo.exe
```

Ejecútalo:

```bash
./hola_windows_demo.exe
echo $?
```

La salida esperada del código de salida es:

```text
0
```

---

## 5) Ejecutar ejemplos incluidos

### 5.1 Ejemplo básico sin C compiler driver

```bash
GEE_BIN=./gee bash scripts/gee-asm-link.sh host examples/no_cc.cb no_cc_demo.exe
./no_cc_demo.exe
echo $?
```

### 5.2 Smoke test de hola mundo

```bash
bash scripts/smoke-hola-mundo.sh
```

### 5.3 Pruebas del runtime del lenguaje

```bash
bash scripts/test-language-runtime.sh
```

---

## 6) Instalar comandos `gee` en tu entorno MSYS2

Puedes instalar wrappers dentro del prefijo configurado por `make install`:

```bash
make install PREFIX="$HOME/.local"
```

Agrega el binario al `PATH`:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verifica:

```bash
gee-doctor || true
gee-run examples/no_cc.cb --target x86-64 --mode no-cc --out no_cc_run.exe
./no_cc_run.exe
```

---

## 7) Gráficos 2D en Windows 11

La ruta Windows actual usa el backend GDI:

```text
libdrawg/backend_windows_gdi.cb
```

Ese backend abre una ventana nativa Windows y presenta un buffer 2D. Para probar el demo 2D de `libgfx`:

```bash
bash scripts/gfx2d-run.sh
```

El script detecta Windows/MSYS2 y selecciona:

```text
backend_windows_gdi.cb + backend_windows_gdi_bridge.c + gdi32 + user32
```

`backend_windows_gdi_bridge.c` es un puente ABI mínimo: el compilador C! actual emite llamadas x86-64 estilo SysV, mientras Win32/GDI usa la ABI Windows x64. El puente evita crashes al llamar `CreateWindowExA`, `StretchDIBits`, `Sleep` y asignación de memoria desde código generado por C!. El runner también usa `stdlib/system_windows_x86_64.s` para que `system_exit` termine con `ExitProcess` en vez de intentar el syscall Linux.

Si todo está bien, debe abrirse una ventana con una escena 2D básica (grilla y diagonales). Si compila pero no ves ventana, revisa:

- que estás en **MSYS2 UCRT64/MINGW64**, no en PowerShell puro;
- que `gcc` existe (`gcc --version`);
- que no estás ejecutando dentro de una terminal sin soporte de escritorio;
- que el antivirus no bloqueó el `.exe` generado en `/tmp` o el directorio temporal.

---

## 8) Alternativa: instalar C! en Windows 11 con WSL2 Ubuntu

Si prefieres Linux dentro de Windows:

### 8.1 Instalar WSL2

En PowerShell como administrador:

```powershell
wsl --install -d Ubuntu
```

Reinicia si Windows lo solicita.

### 8.2 Instalar dependencias dentro de Ubuntu

Abre Ubuntu y ejecuta:

```bash
sudo apt-get update
sudo apt-get install -y build-essential binutils make bash git
```

Para gráficos X11 desde WSL2, instala también:

```bash
sudo apt-get install -y libx11-dev
```

### 8.3 Clonar y compilar

```bash
git clone <URL_DEL_REPO> GEE-compilator-of-C-
cd GEE-compilator-of-C-
make stage0
GEE_BIN=./gee bash scripts/gee-asm-link.sh host examples/no_cc.cb no_cc_demo
./no_cc_demo
echo $?
```

### 8.4 Gráficos 2D desde WSL2

En Windows 11 moderno, WSLg normalmente permite ventanas Linux. Prueba:

```bash
bash scripts/gfx2d-run.sh
```

Si no aparece ventana:

```bash
echo $DISPLAY
```

Debe existir una variable `DISPLAY`. Si está vacía, tu instalación WSL/WSLg no tiene servidor gráfico activo.

---

## 9) Troubleshooting común

### `make: command not found`

Instala `make`:

```bash
pacman -S --needed make
```

En WSL2:

```bash
sudo apt-get install -y make
```

### `cc: command not found` o `gcc: command not found`

En MSYS2 UCRT64:

```bash
pacman -S --needed mingw-w64-ucrt-x86_64-gcc
```

En MSYS2 MINGW64:

```bash
pacman -S --needed mingw-w64-x86_64-gcc
```

En WSL2:

```bash
sudo apt-get install -y build-essential
```

### `as` o `ld` no encontrado

Instala binutils:

```bash
pacman -S --needed binutils
```

En WSL2:

```bash
sudo apt-get install -y binutils
```

### El script gráfico compila pero no abre ventana

En Windows nativo:

- usa MSYS2 UCRT64/MINGW64;
- ejecuta `bash scripts/gfx2d-run.sh` desde una sesión de escritorio normal;
- comprueba `gcc --version`;
- comprueba que el backend seleccionado sea `windows-gdi`.

En WSL2:

- comprueba `echo $DISPLAY`;
- instala `libx11-dev`;
- usa Windows 11 con WSLg activo.

---

## 10) Flujo recomendado para desarrollar en Windows 11

1. Abre **MSYS2 UCRT64**.
2. Entra al repo.
3. Ejecuta:

```bash
make stage0
bash scripts/test-language-runtime.sh
bash scripts/test-gfx-bootstrap.sh
bash scripts/gfx2d-run.sh
```

4. Si el demo 2D abre ventana, ya tienes lista la base para seguir con:
   - OpenGL ES;
   - OpenGL desktop;
   - Vulkan.

---

## 11) Resumen rápido de comandos

```bash
pacman -Syu
pacman -S --needed git make bash binutils mingw-w64-ucrt-x86_64-gcc

git clone <URL_DEL_REPO> GEE-compilator-of-C-
cd GEE-compilator-of-C-

make stage0
GEE_BIN=./gee bash scripts/gee-asm-link.sh host examples/no_cc.cb no_cc_demo.exe
./no_cc_demo.exe

echo $?
bash scripts/gfx2d-run.sh
```
