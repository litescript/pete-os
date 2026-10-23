#include "vga.h"

void kernel_main(void) {
    vga_puts("we used to be a society", B_WHITE, 0);

    #ifdef LOADER_TEST
    volatile uint8_t *test = (volatile uint8_t *)0x11E00;
    volatile uint8_t *test2 = (volatile uint8_t *)0x14200;

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

