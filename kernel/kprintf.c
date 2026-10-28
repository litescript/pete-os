#include "kprintf.h"
#include "vga.h"
#include <stdarg.h>

static void printdec(uint32_t number) {
    int i = 0;
    char digits[10];

    if (number == 0) {
        vga_putc('0');
        return;
    }

    while (number > 0) {
        digits[i] = '0' + (number % 10);
        i++;
        number /= 10;
    }

    while (i > 0) {
        i--;
        vga_putc(digits[i]);
    }
}

static void printhex(uint32_t number) {
    int i = 0;
    char digits[8];

    if (number == 0) {
        vga_putc('0');
        return;
    }

    while (number > 0) {
        uint32_t digit = number % 16;

        if (digit < 10) {
            digits[i] = '0' + digit;
        } else {
            digits[i] = 'A' + (digit - 10);
        }

        i++;
        number /= 16;
    }

    while (i > 0) {
        i--;
        vga_putc(digits[i]);
    }
}

void kprintf(const char *format, ...) {
    va_list args;
    va_start(args, format);
    int i = 0;

    while (format[i] != '\0') {
        if (format[i] == '%') {
            // this is a big if block. TODO: switch?
            if (format[i + 1] == 'u') {
                unsigned int number = va_arg(args, unsigned int);
                printdec(number);
                i++;
            } else if (format[i + 1] =='x') {
                unsigned int number = va_arg(args, unsigned int);
                printhex(number);
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

