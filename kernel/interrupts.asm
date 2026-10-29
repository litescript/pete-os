bits 32

global isr_breakpoint

section .text

isr_breakpoint:
  iretd
