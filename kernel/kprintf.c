#include "kprintf.h"
#include "vga.h"
#include <stdarg.h>

void kprintf(const char *format, ...) {
    va_list args;
    va_start(args, format);
    int i = 0;

    while (format[i] != '\0') {
        if (format[i] == '%') {
            if (format[i + 1] == 'u') {
                unsigned int number = va_arg(args, unsigned int);
                vga_printdec(number);
                i++;
            } else if (format[i + 1] =='x') {
                unsigned int number = va_arg(args, unsigned int);
                vga_printhex(number);
                i++;
            } else if (format[i + 1] == '%') {
                vga_putc('%');
                i++;
            } else if (format[i + 1] == 'c') {
                int character = va_arg(args, int);
                vga_putc((char)character);              // character would be converted to char but this makes it explicit
                i++;
            } else if (format[i + 1] == 's') {
                const char *str = va_arg(args, const char *);
                vga_puts(str);
                i++;
            } else if (format[i + 1] == '\0') {
                vga_putc('%');
            } else {
                vga_putc(format[i]);
                vga_putc(format[i+1]);
                i++;
            }
        } else {
            vga_putc(format[i]);
        }
        i++;
    }

    va_end(args);
}

