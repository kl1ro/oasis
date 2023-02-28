_syscallHandler:
	call [syscallTable + rax * 8]
	iretq

syscallTable dq 0, _print
