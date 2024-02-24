Filesystem:
	section .data
	.buffer times 512 db 0
	.bytesPerSector dq 0
	.sectorsPerCluster dq 0
	.FATs dq 0
	.rootDirEntries dq 0
	.sectors dq 0
	.sectorsPerFAT dq 0
	.label times 12 db 0

	section .text
	._init:
		; Read the bytes per sector
		mov ax, [.buffer + 11]
		mov [.bytesPerSector], ax

		; Read the sectors per cluster
		mov al, [.buffer + 13]
		mov [.sectorsPerCluster], al

		; Read the number of FAT's
		mov al, [.buffer + 16]
		mov [.FATs], al

		; Read the number of dir entries
		mov ax, [.buffer + 17]
		mov [.rootDirEntries], ax

		; Read the number of sectors
		mov ax, [.buffer + 19]
		mov [.sectors], ax

		; Read the number of sectors per FAT
		mov ax, [.buffer + 22]
		mov [.sectorsPerFAT], ax

		; Read the label
		mov rsi, .buffer + 43
		mov rdi, .label
		mov rcx, 11
		call _memcpyb
		ret