org 0x500

bits 64

_startLM:
	call _program
	jmp _haltMachine

%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "src/drivers/screen/main.asm"
%include "../test/main.asm"
done db "Done!", 10, 10, "Here's user program:", 10, 10, 0
