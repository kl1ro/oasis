_keyboardInterruptHandler:
	call _pusha
	call _getKeyboardKey
	mov al, 20h
	out 20h, al
	call _popa
	iretq
