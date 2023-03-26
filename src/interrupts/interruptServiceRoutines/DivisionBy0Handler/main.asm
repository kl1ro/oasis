_divisionBy0Handler:
	mov rsi, divisionBy0
	call _print
	jmp _haltMachine

divisionBy0 db "Sorry, it isn't allowed to divide by 0!", 0
	
