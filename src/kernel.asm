org 0x7e00
bits 64
[map all etc/kernel-links.map]

section .text
_startLM:	
	; Print "Done"
	mov rsi, done
	call Screen._print

	; Print "loading IDT"
	mov rsi, loadingIDT
	call Screen._print

	; Load IDT
	call _loadIDT	

	; Print "Done"
	mov rsi, done
	call Screen._print

	; Iniitialize the ATA
	call ATA._init

	; Make a line break
	mov rsi, lineBreak
	call Screen._print

	; Initialize the filesystem
	call Filesystem._init

	; Print the volume label
	mov rsi, Filesystem.label
	xor ah, ah
	call Screen._print

	; Print the number of bytes per sector
	mov rax, [Filesystem.bytesPerSector]
	mov rdi, buffer
	mov rcx, 10
	call _itoa
	mov rsi, buffer
	xor ah, ah
	call Screen._print

	; Print the space
	mov rsi, space
	xor ah, ah
	call Screen._print

	; Clear the buffer
	mov rdi, buffer
	mov rcx, 8
	call _memclrb

	; Print the volume label
	mov rax, [Filesystem.sectorsPerCluster]
	mov rdi, buffer
	mov rcx, 10
	call _itoa
	mov rsi, buffer
	xor ah, ah
	call Screen._print

	; Chill
	jmp _chill

; Drivers
%include "src/drivers/keyboard.asm"
%include "src/drivers/screen.asm"
%include "src/drivers/pci.asm"
%include "src/drivers/ata.asm"

; Filesystem
%include "src/filesystem.asm"

; Interrupt handlers
%include "src/isr/de.asm"
%include "src/isr/ud.asm"
%include "src/isr/nm.asm"
%include "src/isr/ts.asm"
%include "src/isr/np.asm"
%include "src/isr/ss.asm"
%include "src/isr/gp.asm"
%include "src/isr/pf.asm"
%include "src/isr/mf.asm"
%include "src/isr/keyboard.asm"
%include "src/isr/clock.asm"
%include "src/isr/syscall.asm"

; Syscalls
%include "src/syscalls/read.asm"

; Asmfun-ctions
%include "../asmfun/64/load-idt.asm"
%include "../asmfun/64/memcpyb.asm"
%include "../asmfun/64/memcpyq.asm"
%include "../asmfun/64/break.asm"
%include "../asmfun/64/halt.asm"
%include "../asmfun/64/chill.asm"
%include "../asmfun/64/memset.asm"
%include "../asmfun/64/itoa.asm"
%include "../asmfun/64/itofa.asm"
%include "../asmfun/64/flipstr.asm"
%include "../asmfun/64/memclrb.asm"
%include "../asmfun/64/strcpy.asm"
%include "../asmfun/64/pusha.asm"
%include "../asmfun/64/popa.asm"

; Strings
done db "Done!", 10, 0
lineBreak db 10, 0
space db 32, 0
loadingIDT db "Loading IDT... ", 0
buffer times 10 db 0