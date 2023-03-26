section .data
	string db "Your string is: ", 0

;
; Wait for user enter
;
_console:
	jmp _chill

;
; Now we've got an enter from user
;
_consoleIfGotAnEnter:
	mov rsi, string
	call _print
	mov rsi, keyboardBuffer
	call _print
	ret	

%include "../../AsmFun/Headers64bit/Chill/main.asm"
