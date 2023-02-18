org 0x5000
bits 64

_startLM:
	mov rsi, done
	call _print
	call _loadIDT
	jmp _chill

;
; Drivers
;
%include "src/drivers/keyboard/main.asm"
%include "src/drivers/screen/main.asm"

;
; AsmFunctions
;
%include "../../AsmFun/Headers64bit/LoadIDT/main.asm"
%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "../../AsmFun/Headers64bit/Memcpyq/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers64bit/Chill/main.asm"

;
; Variables
;
done db "Done!", 0
