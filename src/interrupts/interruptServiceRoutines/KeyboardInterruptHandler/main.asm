_keyboardInterruptHandler:
	call _getKeyboardKey
	mov al, 20h
	out 20h, al
	iretq
