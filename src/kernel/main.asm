org 0x5000
bits 64

_startLM:
	call _loadIDT
	jmp $

%include "../../AsmFun/Headers64bit/LoadIDT/main.asm"
%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "src/drivers/screen/main.asm"
%include "../../AsmFun/Headers64bit/Memcpyq/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers64bit/IntToString/main.asm"
%include "../../AsmFun/Headers64bit/GetDebugStringRes/main.asm"
%include "../../AsmFun/Headers64bit/GetDebugString/main.asm"
                        %include "../../AsmFun/Headers64bit/PrintSafe/main.asm"
			%include "../../AsmFun/Headers64bit/Memclr/main.asm"
                        %include "../../AsmFun/Headers64bit/FlipString/main.asm"
                        %include "../../AsmFun/Headers64bit/MinusCheck/main.asm"
                        %include "../../AsmFun/Headers64bit/AssignFlippedIntegerPortion/main.asm"
                        %include "../../AsmFun/Headers64bit/AddMinus/main.asm"
                        %include "../../AsmFun/Headers64bit/Negate/main.asm"
done db "Done!", 0
done1 db "INTERRUPT!", 0
done2 db "KEYBOARD!", 0

section .bss
	%include "../../AsmFun/Headers64bit/TempRes/main.asm"
