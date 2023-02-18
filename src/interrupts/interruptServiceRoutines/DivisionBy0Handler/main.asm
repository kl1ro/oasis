_divisionBy0Handler:
	mov rsi, divisionBy0
	call _print
	iret 

divisionBy0 db "Sorry, it isn't allowed to divide by 0!", 0
	
