org 0x5000
bits 64

_startLM:
	call _loadIDT
	int 0x0
	jmp $


%include "../../AsmFun/Headers64bit/LoadIDT/main.asm"
%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "src/drivers/screen/main.asm"
%include "../../AsmFun/Headers64bit/Memcpyq/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
done db "Done!", 0
done1 db "INTERRUPT!", 0
done2 db "KEYBOARD!", 0
