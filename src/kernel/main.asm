org  0x1000
bits 32

_start:	
	mov esi, done
	mov edx, 0xb9184
        call _printTextPM
	jmp _haltMachine
	
%include "../../AsmFun/Headers32bit/PrintText/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers16bit/HaltMachine/main.asm"

done db "Done!", 0

