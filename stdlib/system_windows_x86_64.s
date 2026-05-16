.intel_syntax noprefix
.text
.globl system_exit
system_exit:
    # Entrada desde C! x86_64 actual: primer argumento en RDI (SysV).
    # Salida Win32: ExitProcess usa RCX (Windows x64) + shadow space.
    sub rsp, 40
    mov ecx, edi
    call ExitProcess
    add rsp, 40
    ret
