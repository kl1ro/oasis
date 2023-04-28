_clockInterruptHandler:
	mov al, 20h
	out 20h, al
	iretq