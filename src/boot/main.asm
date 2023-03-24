org 0x7c00
bits 16

_start:	
	; Note: now dl is a current drive number
	mov ax, 0				; Setup the data segments
	mov ds, ax
	mov es, ax	

	mov ss, ax				; Setup stack
	mov bp, 0x9000
	mov sp, bp
	
	;
	; So dl is a drive number now 
	; and we have to protect it from 
	; being overwritten. But bios functions
	; may modify it, so the push is the only option.
	;
	push dx

	;
	; Set videomode
	;	
	mov ah, 00h
	mov al, 03h
	int 10h
	
	; Printing osName
	mov si, osName
	call _print
	xor bh, bh
	call _newLine

	; Printing about kernel loading
    	mov si, kernelLoading
    	call _print
	
	;
	; Loading kernel from disk
	; Note: ax is a hardcoded value
	; And we need to restore dx cause
	; it is overwritten by _newLine
	pop dx
	mov bx, KERNEL_OFFSET
	mov ax, 22
	call _diskLoad
	
	; Printing about loading success
	mov si, done
	call _print
	xor bh, bh
	call _newLine

	; Printing entering LM
    	mov si, enteringLM
    	call _print

	; Enable the A20 line
	in al, 0x92
	or al, 2
	out 0x92, al

; Switching to Long Mode
%include "../../AsmFun/Headers16bit/SwitchToLM/main.asm"
%include "../../AsmFun/Headers16bit/GDTLM/main.asm"

%include "../../AsmFun/Headers16bit/WaitForKeyAndReboot/main.asm"
%include "../../AsmFun/Headers16bit/PrintText/main.asm"
%include "../../AsmFun/Headers16bit/DiskLoad/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers16bit/NewLine/main.asm"

; Defining some usefull constants
KERNEL_OFFSET equ 0x5000
; Strings
osName db "AsmfunOs 64-bit version 0.06", 0
kernelLoading db "Loading the kernel... ", 0
done db "Done!", 0
enteringLM db "Entering long mode...", 0

times 510-($-$$) db 0			; Pad remainder of boot sector with 0s
dw 0xaa55				; The standard PC boot signature

