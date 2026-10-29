bits 32

global isr_breakpoint
extern breakpoint_handler

section .text

isr_breakpoint:
  pushad
  call breakpoint_handler
  popad
  iretd
