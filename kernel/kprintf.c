#include "kprintf.h"
#include "vga.h"
#include <stdarg.h>

void kprintf(const char *format, ...) {
    va_list args;
    va_start(args, format);

    unsigned int number = va_arg(args, unsigned int);
    vga_printdec(number);

    va_end(args);
}
