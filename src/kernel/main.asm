org  0x500
bits 32

_start:	
	mov eax, cr0                                   ; Set the A-register to control register 0.
    	and eax, 01111111111111111111111111111111b     ; Clear the PG-bit, which is bit 31.
    	mov cr0, eax
	mov edi, 0x1000    ; Set the destination index to 0x1000.
    	mov cr3, edi       ; Set control register 3 to the destination index.
    	xor eax, eax       ; Nullify the A-register.
    	mov ecx, 0x1000    ; Set the C-register to 4096.
    	rep stosd          ; Clear the memory.
    	mov edi, cr3    	      ; Set the destination index to control register 3.
	mov DWORD [edi], 0x2003	     ; Set the uint32_t at the destination index to 0x2003.
    	add edi, 0x1000              ; Add 0x1000 to the destination index.
    	mov DWORD [edi], 0x3003      ; Set the uint32_t at the destination index to 0x3003.
    	add edi, 0x1000              ; Add 0x1000 to the destination index.
    	mov DWORD [edi], 0x4003      ; Set the uint32_t at the destination index to 0x4003.
    	add edi, 0x1000              ; Add 0x1000 to the destination index.	
	mov ebx, 0x00000003          ; Set the B-register to 0x00000003.
 	mov ecx, 512                 ; Set the C-register to 512.
 
.SetEntry:
    	mov DWORD [edi], ebx         ; Set the uint32_t at the destination index to the B-register.
   	add ebx, 0x1000              ; Add 0x1000 to the B-register.
   	add edi, 8                   ; Add eight to the destination index.
   	loop .SetEntry               ; Set the next entry.
		
	mov eax, cr4                 ; Set the A-register to control register 4.
    	or eax, 1 << 5               ; Set the PAE-bit, which is the 6th bit (bit 5).
        mov cr4, eax                 ; Set control register 4 to the A-register.
	mov ecx, 0xC0000080          ; Set the C-register to 0xC0000080, which is the EFER MSR.
    	rdmsr                        ; Read from the model-specific register.
    	or eax, 1 << 8               ; Set the LM-bit which is the 9th bit (bit 8).
   	wrmsr                        ; Write to the model-specific register.	
	mov eax, cr0                 ; Set the A-register to control register 0.
    	or eax, 1 << 31              ; Set the PG-bit, which is the 32nd bit (bit 31).
    	mov cr0, eax                 ; Set control register 0 to the A-register.
	jmp _haltMachine	
	lgdt [GDT64.Pointer]         ; Load the 64-bit global descriptor table.
    	jmp GDT64.Code:_realm64       ; Set the code segment and enter 64-bit long mode.

; Access bits
PRESENT        equ 1 << 7
NOT_SYS        equ 1 << 4
EXEC           equ 1 << 3
DC             equ 1 << 2
RW             equ 1 << 1
ACCESSED       equ 1 << 0
 
; Flags bits
GRAN_4K       equ 1 << 7
SZ_32         equ 1 << 6
LONG_MODE     equ 1 << 5
 
GDT64:
    .Null: equ $ - GDT64
        dq 0
    .Code: equ $ - GDT64
        dd 0xFFFF                                   ; Limit & Base (low, bits 0-15)
        db 0                                        ; Base (mid, bits 16-23)
        db PRESENT | NOT_SYS | EXEC | RW            ; Access
        db GRAN_4K | LONG_MODE | 0xF                ; Flags & Limit (high, bits 16-19)
        db 0                                        ; Base (high, bits 24-31)
    .Data: equ $ - GDT64
        dd 0xFFFF                                   ; Limit & Base (low, bits 0-15)
        db 0                                        ; Base (mid, bits 16-23)
        db PRESENT | NOT_SYS | RW                   ; Access
        db GRAN_4K | SZ_32 | 0xF                    ; Flags & Limit (high, bits 16-19)
        db 0                                        ; Base (high, bits 24-31)
    .TSS: equ $ - GDT64
        dd 0x00000068
        dd 0x00CF8900
    .Pointer:
        dw $ - GDT64 - 1
        dq GDT64


; Use 64-bit.
[BITS 64]
_realm64:
	cli                           ; Clear the interrupt flag.
 	mov ax, GDT64.Data            ; Set the A-register to the data descriptor.
 	mov ds, ax                    ; Set the data segment to the A-register.
 	mov es, ax                    ; Set the extra segment to the A-register.
	mov fs, ax                    ; Set the F-segment to the A-register.
 	mov gs, ax                    ; Set the G-segment to the A-register.
 	mov ss, ax                    ; Set the stack segment to the A-register.
 	mov rsi, done
	mov rdx, 0xb9000
	call _printTextPM
	jmp _haltMachine

%include "../../AsmFun/Headers16bit/HaltMachine/main.asm"
%include "../../AsmFun/Headers64bit/Factorial/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers32bit/PrintText/main.asm"

done db "Done!", 0
