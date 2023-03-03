org 0x5000
bits 64

_startLM:	
	;
	; Printing about switching 
	; to 64-bit success		
	;
	mov rsi, done
	call _print

	;
	; Print loading IDT
	;
	mov rsi, loadingIDT
	call _print

	;
	; Load IDT
	; 	
	call _loadIDT	

	;
	; Print about loading IDT success
	;	
	mov rsi, done
	call _print

	mov rsi, done
	mov rax, 1
	int 0x80

	;
	; Wait for commands
	;
	jmp _console

;
; Drivers
;
%include "src/drivers/keyboard/main.asm"
%include "src/drivers/screen/main.asm"

;
; AsmFunctions
;
%include "../../AsmFun/Headers64bit/LoadIDT/main.asm"
%include "../../AsmFun/Headers64bit/Memcpyq/main.asm"
%include "../../AsmFun/Headers64bit/Break/main.asm"
%include "../../AsmFun/Headers64bit/HaltMachine/main.asm"
%include "../../AsmFun/Headers64bit/Memclrb/main.asm"

;
; Utilities
;
%include "src/utilities/console/main.asm"

;
; Variables
;
done db "Done!", 10, 0
loadingIDT db "Loading IDT... ", 0

