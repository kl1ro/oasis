org 0x500
bits 16

%include "../../AsmFun/Headers16bit/SwitchToLM/main.asm"	
%include "../../AsmFun/Headers16bit/GDTLM/main.asm"

bits 64

_startLM:
	mov esi, done
	mov edx, 0xb9184
	call _printTextPM
	jmp _haltMachine

%include "../../AsmFun/Headers32bit/PrintText/main.asm"
%include "../../AsmFun/Headers64bit/Factorial/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers16bit/HaltMachine/main.asm"

done db "Done!", 0

