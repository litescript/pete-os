bits 16
org 0x8000

mov al, 'X'

mov ah, 0x0E
int 0x10

cli
.hang:
  hlt
  jmp .hang

times 512-($-$$) db 0
