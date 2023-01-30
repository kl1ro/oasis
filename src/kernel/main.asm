org 0x500
bits 16

%include "../../AsmFun/Headers16bit/SwitchToLM/main.asm"	
%include "../../AsmFun/Headers16bit/GDTLM/main.asm"

bits 64

_startLM:
	hlt

%include "../../AsmFun/Headers64bit/Factorial/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers16bit/HaltMachine/main.asm"

