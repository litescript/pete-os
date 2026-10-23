#ifndef VGA_H
#define VGA_H

#define B_WHITE 0x0F

void vga_putc(char c, unsigned char color, unsigned int position);
void vga_puts(const char *str, unsigned char color, unsigned int position);

#endif
