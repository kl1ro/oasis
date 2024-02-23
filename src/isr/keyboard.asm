_keyboardInterruptHandler:
	call _pusha
	call Keyboard._getKey
	mov al, 20h
	out 20h, al
	call _popa
	iretq
