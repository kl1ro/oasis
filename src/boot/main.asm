org 0x7c00
bits 16
[map all etc/bootloaderLinks.map]

_start:	
	;
	;	Even before the bootloader starts, dl is equal to the drive number
	;
	;	Setup the data segments
	;
	xor ax, ax				
	mov ds, ax
	mov es, ax	

	;
	;	Setup the stack
	;
	mov ss, ax				
	mov bp, 0x7bff
	mov sp, bp

	;
	;	So dl is a drive number now and we have to protect it from being overwritten.
	;	But bios functions may modify it, so push is the only option.
	;
	push dx

	;
	;	Set videomode
	;	
	mov ah, 00h
	mov al, 03h
	int 10h

	;
	;	Print osName
	;
	mov si, osName
	call _print
	xor bh, bh
	call _newLine

	;
	;	Print about kernel loading
	;
	mov si, kernelLoading
	call _print

	;
	;	Load the kernel from a drive. ax is a hardcoded value and we need
	;	to restore dx cause it is most likely overwritten by _newLine
	;
	pop dx
	mov bx, KERNEL_OFFSET
	mov ax, 65
	call _readFromDisk


	;
	;	Print about loading success
	;
	mov si, done
	call _print
	xor bh, bh
	call _newLine

	;
	;	Print about entering long mode
	;
	mov si, enteringLM
	call _print

	;
	;	Enable the A20
	;
	in al, 0x92
	or al, 2
	out 0x92, al

;
;	Switch to long mode and jump into the kernel
;
%include "../../AsmFun/Headers16bit/SwitchToLM/main.asm"
%include "../../AsmFun/Headers16bit/GDTLM/main.asm"

;
;	16-bit AsmFunctions
;
%include "../../AsmFun/Headers16bit/WaitForKeyAndReboot/main.asm"
%include "../../AsmFun/Headers16bit/Print/main.asm"
%include "../../AsmFun/Headers16bit/ReadFromDisk/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers16bit/NewLine/main.asm"

;
;	Define some usefull constants
;
KERNEL_OFFSET equ 0x7e00

;
;	Strings
;
osName db "Oasis 64-bit version 0.08", 0
kernelLoading db "Loading the kernel... ", 0
done db "Done!", 0
enteringLM db "Entering long mode...", 0

;
;	Pad remainder of boot sector with 0s
;
times 510-($-$$) db 0

;
;	The standard PC boot signature
;
dw 0xaa55