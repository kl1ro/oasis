org 0x500

bits 64

_startLM:
	mov rsi, done	
	call _print	
	call _program
	jmp _haltMachine

%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "../../AsmFun/Headers64bit/Memcpy/main.asm"
%include "src/drivers/screen/main.asm"
%include "../Adder/main.asm"
done db "Done!", 10, 10, "Here's user program:", 10, 0
