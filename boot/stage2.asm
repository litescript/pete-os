bits 16
org 0x8000

jmp second_sector

times 512-($-$$) db 0

second_sector:

mov al, 'X'

mov ah, 0x0E
int 0x10

cli
.hang:
  hlt
  jmp .hang

times 1024-($-$$) db 0
