org 0x0
bits 16

_start:
	mov si, msg
	call _printText
	jmp _haltMachine

msg db "Disk load complete!", 0

%include "../../Headers16bit/HaltMachine/main.asm"
%include "../../Headers16bit/PrintText/main.asm"
%include "../../Headers64bit/Break/main.asm"

