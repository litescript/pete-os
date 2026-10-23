#include "vga.h"

static uint32_t cursor = 0;

void vga_putc(char c, uint8_t color, uint32_t position) {
    uint16_t cell = (color << 8) | (uint8_t)c;
    volatile uint16_t *vga = (volatile uint16_t *)0xB8000;
    vga[position] = cell;
    cursor = position + 1;
}

void vga_puts(const char *str, uint8_t color, uint32_t position) {
    int i = 0;

    while (str[i] != '\0') {
        vga_putc(str[i], color, position + i);
        i++;
    }
}

