_syscallHandler:
	mov rsi, syscallText
	call _print
	iretq

syscallText db "System call!", 0
