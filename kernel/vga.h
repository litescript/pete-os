#ifndef VGA_H
#define VGA_H

#include <stdint.h>
#define B_WHITE 0x0F

void vga_putc(char c, uint8_t color, uint32_t position);
void vga_puts(const char *str, uint8_t color, uint32_t position);

#endif
