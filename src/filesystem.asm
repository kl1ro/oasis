Filesystem:
	section .data
	.buffer times 512 db 0
	.bytesPerSector times 2 db 0
	.sectorsPerCluster db 0
	.FATs db 0
	.rootDirEntries dw 0
	.sectors dw 0
	.sectorsPerFAT dw 0
	.label times 11 db 0

	section .text
	._init:
		mov rsi, .buffer + 11
		mov rdi, .bytesPerSector
		mov rcx, 2
		call _memcpyb
		ret