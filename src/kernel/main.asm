org 0x500

bits 64

_startLM:
	mov r9, done
	call _print	
	jmp _haltMachine

%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "../../AsmFun/Headers64bit/Memcpy/main.asm"
%include "src/drivers/screen/main.asm"
done db "Done!", 0
