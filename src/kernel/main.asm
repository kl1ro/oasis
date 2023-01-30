org 0x500

bits 64

_startLM:
	mov ah, 0x07 		; Gray on black
	mov rsi, done
	mov rdx, 0xb917a
	call _printTextLM
	jmp _haltMachine

%include "../../AsmFun/Headers64bit/PrintTextLM/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
done db "Done!", 0
