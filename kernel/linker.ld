ENTRY(_kernel_start)

SECTIONS
{
  . = 0x10000;

  .text : {
    *(.text)
  }
  .rodata : {
    *(.rodata)
  }
  .data : {
    *(.data)
  }
  .bss : {
    __bss_start = .;
    *(.bss)
    __bss_end = .;
  }
}
