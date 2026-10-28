#include "vga.h"

static uint32_t cursor = 0;
static uint8_t current_color = B_WHITE;

void vga_set_color(uint8_t color) {
    current_color = color;
}

static void vga_scroll(void) {
    volatile uint16_t *vga = (volatile uint16_t *)0xB8000;
    int i = 0;

    while (i < (VGA_WIDTH * (VGA_HEIGHT - 1))) {
        vga[i] = vga[i + VGA_WIDTH];
        i++;
    }
    while (i < VGA_WIDTH * VGA_HEIGHT) {
        vga[i] = 0x0F20;
        i++;
    }
    cursor = VGA_WIDTH * (VGA_HEIGHT - 1);
}

void vga_putc(char c) {
    if (c == '\n') {
        cursor += VGA_WIDTH - (cursor % VGA_WIDTH);
        if (cursor >= (VGA_WIDTH * VGA_HEIGHT)) {
            vga_scroll();
        }
        return;
    }
    uint16_t cell = (current_color << 8) | (uint8_t)c;
    volatile uint16_t *vga = (volatile uint16_t *)0xB8000;
    vga[cursor] = cell;
    cursor++;
    if (cursor >= (VGA_WIDTH * VGA_HEIGHT)) {
        vga_scroll();
    }
}

void vga_puts(const char *str) {
    int i = 0;

    while (str[i] != '\0') {
        vga_putc(str[i]);
        i++;
    }
}

