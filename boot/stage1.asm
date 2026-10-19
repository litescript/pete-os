bits 16           ; tell NASM to encode for 16 bit execution
org 0x7C00        ; tell NASM to calculate addresses assuming an origin of 0x7C00

xor ax, ax        ; xor ax with itself (0), put result into ax
mov ds, ax        ; put 0 into ds (data segment)
mov [boot_drive], dl  ; put lower 8 bits of DX register (drive identifier) into memory so we don't
                      ; overwrite it during disk read operations later

cli               ; clear interrupt flag (disallow hardware interrupts)
mov ss, ax        ; put ax (0 here) into the stack segment
mov sp, 0x7000    ; put 0x7000 into the stack pointer
sti               ; set interrupt flag (allow hardware interrupts)

mov ax, 0         ; set AX to zero
mov es, ax        ; ES = 0, destination segment
mov bx, 0x8000    ; BX = 0x8000, destination offset

mov ah, 0x02      ; BIOS disk service: read sectors
mov al, 2         ; request two sectors
mov ch, 0         ; Cylinder 0
mov dh, 0         ; Head 0
mov cl, 2         ; Sector 2
mov dl, [boot_drive]  ; restore drive identifier into DL

int 0x13              ; ask BIOS to read the sector
jc .disk_error        ; jump if the read failed
mov dl, [boot_drive]  ; restore boot drive for Stage 2
jmp 0x0000:0x8000     ; far jump to start execution of stage 2

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
  int 0x10        ; call BIOS video service to print contents of AL; int = interrupt
  ret             ; pop saved return address from stack and resume there

.disk_error:
  jmp .done

.done:
  cli             ; clear Interrupt Flag (IF) in FLAGS

.hang:
  hlt             ; HLT code
  jmp .hang       ; if CPU gets woken up and continues, jump back to .hang

message: db 'we used to be a society', 0    ; our message; db = define byte; 0 = null terminated string
boot_drive: db 0        ; boot_drive definition: one 0 byte

times 510-($-$$) db 0   ; pad file after our instructions with 0s
db 0x55, 0xAA           ; place the two needed bytes, 0x55 and 0xAA and the end for valid boot sector
