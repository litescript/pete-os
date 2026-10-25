#ifndef VGA_H
#define VGA_H

#include <stdint.h>
#define B_WHITE     0x0F
#define VGA_WIDTH   80
#define VGA_HEIGHT  25

void vga_putc(char c);
void vga_puts(const char *str);
void vga_set_color(uint8_t color);

#endif
