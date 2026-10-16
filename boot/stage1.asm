bits 16           ; tell NASM to encode for 16 bit execution
org 0x7C00        ; tell NASM to calculate addresses assuming an origin of 0x7C00

xor ax, ax        ; xor ax with itself (0), put it into ax
mov ds, ax        ; put 0 into ds (data segment)

cli               ; clear interrupt flag (disallow hardware interrupts)
mov ss, ax        ; put ax (0 here) into the stack segment
mov sp, 0x7000    ; put 0x7000 into the stack pointer
sti               ; set interrupt flag (allow hardware interrupts)

mov si, message   ; put the address of message into the source index register (SI)
mov al, [si]      ; read one byte from memory at DS:SI into AL
                  ; think "AX, LOWER"
.loop:
  cmp al, 0       ; compare 0 and what is currently in al; set CPU flags based on AL - 0, without changing AL
  je .done        ; if they are equal, jump to .done (je = jump if equal); if not, continue
  call .print     ; call .print (saves location in stack for the ret call)
  call .next      ; call .next (saves location in stack for the ret call)
  jmp .loop       ; jump to .loop (does not save location in stack for ret call)

.next:
  inc si          ; increment source index register by one (pointer math)
  mov al, [si]    ; move the current byte at the [si] memory address into the AL register
  ret             ; pop saved return address from stack and resume there

.print:
  mov ah, 0x0E    ; select BIOS TTY print function
  int 0x10        ; call BIOS video service to print contents of AL
  ret             ; pop saved return address from stack and resume there

.done:
  cli             ; clear Interrupt Flag (IF) in FLAGS

.hang:
  hlt             ; HLT code
  jmp .hang       ; if CPU gets woken up and continues, jump back to .hang

message: db 'we used to be a society', 0    ; our message; db = define byte; 0 = null terminated string

times 510-($-$$) db 0   ; pad file after our instructions with 0s
db 0x55, 0xAA           ; place the two needed bytes, 0x55 and 0xAA and the end for valid boot sector
