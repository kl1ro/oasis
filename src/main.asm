org 0x7c00

bits 16
_start:
	mov bp, 0x9000
	mov sp, bp
	mov esi, switch				; Put reading position into si
	call _printText				; Call our reading-printing routine
	jmp _switchToPM

[bits 32] 
_beginPM:
	mov esi, switchComplete
	mov edx, 0xb8780
	call _printTextPM
	hlt

%include "../../AsmFunOs16BitRoutines/GDT/main.asm"
%include "../../AsmFunOs16BitRoutines/PrintText/main.asm"
%include "../../AsmFunOs32BitRoutines/PrintText/main.asm"
%include "../../Headers/Break/main.asm"
%include "../../AsmFunOs16BitRoutines/SwitchToPM/main.asm"
	
; Global variables
switch db "Making a switch to 32-bit PM... ", 0
switchComplete db "Switch to 32-bit is complete!", 0

times 510-($-$$) db 0			; Pad remainder of boot sector with 0s
dw 0xaa55				; The standard PC boot signature

