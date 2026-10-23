const volatile char message[] = "PETE OS";
volatile unsigned short letter = 0x0F43;
volatile unsigned short letter2;

void kernel_main(void) {
    volatile unsigned short *vga = (unsigned short *)0xB8000;
    vga[0] = letter;
    letter = 0x0F50;
    vga[1] = letter;
    #ifdef LOADER_TEST
    volatile unsigned char *test = (volatile unsigned char *)0x11E00;
    volatile unsigned char *test2 = (volatile unsigned char *)0x14200;

    if (*test == 0xA5) {
        vga[2] = 0x0F59;    // Y, for success
    } else {
        vga[2] = 0x0F4E;    // N, for failure
    }

    if (*test2 == 0x5A) {
        vga[3] = 0x0F59;    // once again, Y for success
    } else {
        vga[3] = 0x0F4E;     // once again, N for failure
    }
    #endif
}
