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

	; Clear screen
	mov ah, 05h
	mov al, 01h
	int 10h
	
	; Printing osName
	mov si, osName
	call _printText
	mov bh, 01h
	call _newLine

	; Printing about kernel loading
        mov si, kernelLoading
        call _printText
	
	; Loading kernel from disk
	; Note: ax is a hardcoded value
	mov bx, KERNEL_OFFSET
	mov ax, 15
	call _diskLoad
	
	; Printing about loading success
	mov si, done
	call _printText
	mov bh, 01h
	call _newLine

	; Printing entering PM
        mov si, enteringPM
        call _printText

	; Entering PM
	jmp _switchToPM
	
%include "../../AsmFun/Headers16bit/WaitForKeyAndReboot/main.asm"
%include "../../AsmFun/Headers16bit/PrintText/main.asm"
%include "../../AsmFun/Headers16bit/DiskLoad/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers16bit/NewLine/main.asm"
%include "../../AsmFun/Headers16bit/GDT/main.asm"
%include "../../AsmFun/Headers16bit/SwitchToPM/main.asm"

; Defining some usefull constants
KERNEL_OFFSET equ 0x1000

; Strings
osName db "AsmFun Operating System 64-bit version 0.03", 0
kernelLoading db "Loading the kernel... ", 0
done db "Done!", 0
enteringPM db "Entering 32-bit Protected Mode... ", 0

times 510-($-$$) db 0			; Pad remainder of boot sector with 0s
dw 0xaa55				; The standard PC boot signature
