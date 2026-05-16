// backend_windows_gdi_bridge.c - puente ABI SysV -> Win64 para drawg.
// Se compila únicamente en Windows/MSYS2/MinGW para que el código C!
// pueda llamar funciones GDI/Win32 sin romper por calling convention.

#include <stdint.h>
#include <stdlib.h>
#include <windows.h>

#if defined(__x86_64__)
#define GEE_SYSV __attribute__((sysv_abi))
#else
#define GEE_SYSV
#endif

static uint32_t drawg_bgr32_from_rgb64(uint64_t rgb) {
    uint32_t r = (uint32_t)((rgb >> 16) & 255u);
    uint32_t g = (uint32_t)((rgb >> 8) & 255u);
    uint32_t b = (uint32_t)(rgb & 255u);
    return b | (g << 8) | (r << 16);
}

GEE_SYSV int64_t gee_win_drawg_malloc(int64_t size) {
    return (int64_t)(uintptr_t)malloc((size_t)size);
}

GEE_SYSV void gee_win_drawg_free(int64_t ptr) {
    if (ptr != 0) free((void *)(uintptr_t)ptr);
}

GEE_SYSV int64_t gee_win_drawg_create_window(int32_t width, int32_t height, const char *title) {
    HWND hwnd = CreateWindowExA(
        0,
        "STATIC",
        title ? title : "drawg",
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        width + 16,
        height + 39,
        NULL,
        NULL,
        GetModuleHandleA(NULL),
        NULL
    );
    if (hwnd == NULL) return 0;

    ShowWindow(hwnd, SW_SHOW);
    UpdateWindow(hwnd);
    return (int64_t)(uintptr_t)hwnd;
}

GEE_SYSV int64_t gee_win_drawg_get_dc(int64_t hwnd_value) {
    HWND hwnd = (HWND)(uintptr_t)hwnd_value;
    HDC hdc = GetDC(hwnd);
    return (int64_t)(uintptr_t)hdc;
}

GEE_SYSV int32_t gee_win_drawg_should_close(int64_t hwnd_value) {
    HWND hwnd = (HWND)(uintptr_t)hwnd_value;
    if (hwnd == NULL) return 1;
    if (!IsWindow(hwnd)) return 1;

    MSG msg;
    while (PeekMessageA(&msg, NULL, 0, 0, PM_REMOVE)) {
        if (msg.message == WM_QUIT) return 1;
        if (msg.message == WM_CLOSE || msg.message == WM_DESTROY) return 1;
        TranslateMessage(&msg);
        DispatchMessageA(&msg);
    }

    return IsWindow(hwnd) ? 0 : 1;
}

GEE_SYSV void gee_win_drawg_present(int64_t hwnd_value, int64_t hdc_value, int64_t pixels_value, int32_t width, int32_t height) {
    (void)hwnd_value;
    HDC hdc = (HDC)(uintptr_t)hdc_value;
    const uint64_t *src = (const uint64_t *)(uintptr_t)pixels_value;
    if (hdc == NULL || src == NULL || width <= 0 || height <= 0) return;

    size_t count = (size_t)width * (size_t)height;
    uint32_t *raw = (uint32_t *)malloc(count * sizeof(uint32_t));
    if (raw == NULL) return;

    for (size_t i = 0; i < count; ++i) {
        raw[i] = drawg_bgr32_from_rgb64(src[i]);
    }

    BITMAPINFO bmi;
    bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bmi.bmiHeader.biWidth = width;
    bmi.bmiHeader.biHeight = -height;
    bmi.bmiHeader.biPlanes = 1;
    bmi.bmiHeader.biBitCount = 32;
    bmi.bmiHeader.biCompression = BI_RGB;
    bmi.bmiHeader.biSizeImage = 0;
    bmi.bmiHeader.biXPelsPerMeter = 0;
    bmi.bmiHeader.biYPelsPerMeter = 0;
    bmi.bmiHeader.biClrUsed = 0;
    bmi.bmiHeader.biClrImportant = 0;

    StretchDIBits(
        hdc,
        0, 0, width, height,
        0, 0, width, height,
        raw,
        &bmi,
        DIB_RGB_COLORS,
        SRCCOPY
    );

    free(raw);
}

GEE_SYSV void gee_win_drawg_sleep(int32_t ms) {
    if (ms > 0) Sleep((DWORD)ms);
}

GEE_SYSV void gee_win_drawg_shutdown(int64_t hwnd_value, int64_t hdc_value) {
    HWND hwnd = (HWND)(uintptr_t)hwnd_value;
    HDC hdc = (HDC)(uintptr_t)hdc_value;
    if (hwnd != NULL && hdc != NULL) ReleaseDC(hwnd, hdc);
    if (hwnd != NULL && IsWindow(hwnd)) DestroyWindow(hwnd);
}
