bits 16                       ; we know these
org 0x8000                    ; already :)

jmp second_sector             ; obvious

times 512-($-$$) db 0         ; pad pad pad pad - read by nasm, not CPU

second_sector:                ; duh
mov [boot_drive], dl          ; save boot drive number here in stage 2

mov ax, 0x1000                ; segment 0x1000
mov es, ax                    ; destination segment
xor bx, bx                    ; offset 0x0000

mov si, KERNEL_SECTORS        ; sectors remaining to load
mov ch, 0                     ; cylinder 0
mov dh, 0                     ; head 0
mov cl, 4                     ; sector 4
mov dl, [boot_drive]          ; restore BIOS boot drive

read_sectors:
mov ax, si                    ; copy remaining sector count into AX
mov ah, 0x02                  ; BIOS disk-read function

mov bl, 19                    ; 18 sectors per track, numbered 1-18
sub bl, cl                    ; calculate sectors left on track
cmp si, bx                    ; compare remaining kernel sectors to track space
jbe sector_count_ready        ; if they fit, keep the count in AL
mov ax, bx                    ; otherwise, use available track space
mov ah, 0x02                  ; restore BIOS function

sector_count_ready:
xor bx, bx                    ; restore destination offset
push ax                       ; preserve AH and AL
xor ah, ah                    ; zero upper half of AX
mov di, ax                    ; DI now contains only sector count
pop ax                        ; restore AX=0x02 for BIOS

push si                       ; push si to stack
push di                       ; push di to stack
push cx                       ; push cx to stack
push dx                       ; push dx to stack

int 0x13                      ; call BIOS disk read interrupt

pop dx                        ; order matters! LIFO, so, dx first
pop cx                        ; then cx
pop di                        ; then di
pop si                        ; then si

jc disk_error                 ; disk read error handler conditional jump
sub si, di                    ; subtract sectors read from sectors remaining
mov ax, di                    ; stash our sector count in ax
shl ax, 5                     ; shift ax left by 5, which is 2^5, or x32
mov bx, es                    ; copy ES so we can advance the segment
add bx, ax                    ; increment bx by ax amount
mov es, bx                    ; put the new address back into es
xor bx, bx                    ; put bx back to 0
cmp si, 0                     ; did we finish reading?
je kernel_loaded              ; if so, jump to start loading protected mode
; more sectors remain, so advance disk position
mov dh, 1
mov cl, 1

; jmp read_sectors              ; otherwise, go back and keep reading

kernel_loaded:
lgdt [gdt_descriptor]         ; tells CPU to read six-byte structure at gdt_descriptor and load
                              ; its contents into the GDTR register

mov eax, cr0                  ; read control register CR0 into EAX
or eax, 1                     ; set bit 0 (PE) in our copy
cli
mov cr0, eax                  ; put our copy into cr0, enabling protected mode
jmp 0x08:protected_mode_start ; far jump 

disk_error:                   ; where we go to handle disk read error
  cli                         ; clear interrupt flag
.error_hang:                  ; self-documenting
  hlt                         ; see above
  jmp .error_hang             ; you know the drill

;
; Global Descriptor Table
;
gdt_start:
  dq 0                        ; null descriptor: 8 zero bytes

gdt_code:
  dw 0xFFFF                   ; limit bits 0-15
  dw 0x0000                   ; base bits 0-15
  db 0x00                     ; base bits 16-23
  db 0x9A                     ; access: present, ring 0, executable, readable
  db 0xCF                     ; G=1, D=1, upper limit bits 0xF; G: limit measured in 4KiB units;
                              ; D/B: default 32-bit operand and address size for code; L: not a 64-bit
                              ; code segment; AVL: reserved for software use
  db 0x00                     ; base bits 24-31

gdt_data:
  dw 0xFFFF                   ; limit low
  dw 0x0000                   ; base low
  db 0x00                     ; base middle
  db 0x92                     ; access (same as above except non executable, is writable)
  db 0xCF                     ; flags and upper limit, same as gdt_code
  db 0x00                     ; base high

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1  ; GDT size minus 1 (limit)
  dd gdt_start                ; linear address of GDT beginning (base)

bits 32                       ; encode for 32 bit!

protected_mode_start:

mov ax, 0x10                  ; our protected-mode data selector
mov ds, ax                    ; load DS from our GDT
mov ss, ax                    ; load our protected-mode data selector into SS
mov esp, 0x7000               ; configure 32 bit stack pointer
mov es, ax                    ; configure
mov fs, ax                    ; remaining
mov gs, ax                    ; registers

; clear leftover firmware messages
cld                           ; clear direction flag
mov ax, 0x0F20                ; put the space and white/black character/attribute into AX
mov edi, 0xB8000              ; EDI points to start of VGA text memory
mov ecx, 2000                 ; 80 columns x 25 rows = 2000 cells
rep stosw                     ; write AX to [EDI], advance EDI by 2, repeat ECX times

mov esi, message32
mov edi, 0xB8000

.print:                       ; printing loop
  mov al, [esi]               ; load next character from [esi] into AL
  cmp al, 0                   ; compare against 0
  je .done                    ; if 0, jump to .done

  mov ah, 0x0F                ; move our attribute byte into ah (bright white on black)
  mov [edi], ax               ; copy contents of ax into [edi]

  inc esi                     ; increment esi by one
  add edi, 2                  ; increment edi by 2
  jmp .print                  ; repeat the loop

.done:

; selecting VGA and ports, disabling cursor
mov dx, 0x3D4                 ; VGA controller index port
mov al, 0x0A                  ; select cursor start register
out dx, al                    ; send that selection to the hardware

mov dx, 0x3D5                 ; VGA controller data port
in al, dx                     ; read current value
or al, 0x20                   ; set bit 5: disable cursor
out dx, al                    ; write modified value back
in al, dx

call 0x10000                  ; call our kernel, which is loaded at 0x10000, it returns on its own

; finish gracefully
cli

.hang:
  hlt
  jmp .hang

boot_drive: db 0              ; familiar boot drive number (initialization only)
message32: db 'PETE OS', 0    ; our message, null terminated
times 1024-($-$$) db 0        ; nasm instruction to pad rest of file size with 0 bytes
