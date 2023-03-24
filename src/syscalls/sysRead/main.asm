;
; Input:
;	According to the POSIX
;	- rdi is a file descriptor
;
;	- rsi is a buffer
;
;	- rdx is a maximum number of characters
;
_sysRead:
	test rdi, rdi
	jz ._standardInput
	sti

	._standardInput:
		mov [inputCounter], rdx
		mov [inputBuffer], rsi
		._cycle:
			mov rcx, 10
			call _sleep
			jmp ._cycle
	ret
