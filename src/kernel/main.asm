org 0x0
bits 32

_start:	
	jmp _haltMachine
	mov esi, enteringPM
	mov edx, 0xb9000
	call _printTextPM
	jmp _haltMachine
	
%include "../../Headers16bit/HaltMachine/main.asm"
%include "../../Headers32bit/PrintText/main.asm"
%include "../../Headers64bit/Break/main.asm"

kernelLoaded db "Kernel load complete!", 0
enteringPM db "Entering 32-bit Protected Mode...", 0
done db "Done!", 0

