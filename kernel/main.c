const volatile char message[] = "PETE OS";
volatile unsigned short letter = 0x0F43;
volatile unsigned short letter2;

void kernel_main(void) {
    volatile unsigned short *vga = (unsigned short *)0xB8000;
    vga[0] = letter;
    letter = 0x0F50;
    vga[1] = letter;
}
