#include "vga.h"

void vga_putc(char c, unsigned char color, unsigned int position) {
    unsigned short cell = (color << 8) | (unsigned char)c;
    volatile unsigned short *vga = (volatile unsigned short *)0xB8000;
    vga[position] = cell;
}

void vga_puts(const char *str, unsigned char color, unsigned int position) {
    int i = 0;

    while (str[i] != '\0') {
        vga_putc(str[i], color, position + i);
        i++;
    }
}

