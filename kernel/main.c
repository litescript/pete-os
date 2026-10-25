#include "vga.h"

void kernel_main(void) {
    vga_set_color(B_WHITE);
    vga_puts("PETE OS\n\n");
    vga_puts("we used to be a society\n");
    vga_puts("and now, we scroll, brother\n");
    vga_printdec(0);
    vga_putc('\n');
    vga_printdec(1203);
    vga_putc('\n');
    vga_printdec(4294967295U);
    vga_putc('\n');
    vga_puts("and now, we got integer numbers. transmat firing!");
    vga_putc('\n');
    vga_puts("now, we bank some hex!");
    vga_putc('\n');
    vga_printhex(0);
    vga_putc('\n');
    vga_printhex(10);
    vga_putc('\n');
    vga_printhex(255);
    vga_putc('\n');
    vga_printhex(4096);
    vga_putc('\n');
    vga_printhex(0xDEADBEEF);
    vga_putc('\n');
    vga_printhex(4294967295U);
    vga_putc('\n');
    vga_puts("that's all for now, brother!");

    #ifdef LOADER_TEST
    volatile uint8_t *test = (volatile uint8_t *)0x11E00;
    volatile uint8_t *test2 = (volatile uint8_t *)0x14200;

    if (*test == 0xA5) {
        vga_putc('Y');
    } else {
        vga_putc('N');
    }

    if (*test2 == 0x5A) {
        vga_putc('Y');
    } else {
        vga_putc('N');
    }
    #endif
}

