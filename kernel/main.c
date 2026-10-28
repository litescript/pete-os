#include "kprintf.h"
#include "vga.h"

void kernel_main(void) {
    vga_set_color(B_WHITE);
    kprintf("PETE OS\n\n");
    kprintf("we used to be a society\n");
    kprintf("and now, we have kprintf!\n");

    kprintf("Decimal: %u\n", 1203U);
    kprintf("Hex: 0x%x\n", 0xDEADBEEFU);
    kprintf("Character: %c\n", 'A');
    kprintf("String: %s\n", "TRANSMAT FIRING!");

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

