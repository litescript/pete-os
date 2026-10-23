#include "vga.h"

void kernel_main(void) {
    vga_puts("we used to be a society", B_WHITE, 0);

    #ifdef LOADER_TEST
    volatile unsigned char *test = (volatile unsigned char *)0x11E00;
    volatile unsigned char *test2 = (volatile unsigned char *)0x14200;

    if (*test == 0xA5) {
        vga_putc('Y', B_WHITE, 2);
    } else {
        vga_putc('N', B_WHITE, 2);
    }

    if (*test2 == 0x5A) {
        vga_putc('Y', B_WHITE, 3);
    } else {
        vga_putc('N', B_WHITE, 3);
    }
    #endif
}

