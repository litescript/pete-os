bits 32

section .text

global _kernel_start
extern kernel_main
extern __bss_start
extern __bss_end

_kernel_start:
  mov edi, __bss_start
  mov ecx, __bss_end
  sub ecx, edi

  xor eax, eax
  cld
  rep stosb

  call kernel_main
  ret
