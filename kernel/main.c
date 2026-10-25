#include "vga.h"

void kernel_main(void) {
    for (int i = 0; i < 30; i++) {
        if (i == 0) {
            vga_puts("BEGIN!\n", B_WHITE);
        }
        vga_puts("we used to be a society\n", B_WHITE);
        vga_putc((30 + i), B_WHITE);
        vga_puts("\n", B_WHITE);
        if (i == 29) {
            vga_puts("END!", B_WHITE);
        }
    }

    #ifdef LOADER_TEST
    volatile uint8_t *test = (volatile uint8_t *)0x11E00;
    volatile uint8_t *test2 = (volatile uint8_t *)0x14200;

    if (*test == 0xA5) {
        vga_putc('Y', B_WHITE);
    } else {
        vga_putc('N', B_WHITE);
    }

    if (*test2 == 0x5A) {
        vga_putc('Y', B_WHITE);
    } else {
        vga_putc('N', B_WHITE);
    }
    #endif
}

