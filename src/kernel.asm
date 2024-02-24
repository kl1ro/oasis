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

	; Copy message to the sector
	mov rsi, message
	mov rdi, sector
	call _strcpy

	; Write the message to the disk
	mov rsi, sector
	mov rdi, ATA.port0Base
	xor ebx, ebx
	mov al, 0
	call ATA._write

	; Flush the disk
	mov rdi, ATA.port0Base
	mov al, 0
	call ATA._flush

	; Clear the sector
	mov rdi, sector
	mov rcx, 512
	call _memclrb

	; Read the message from disk
	mov rsi, ATA.port0Base
	mov al, 0
	mov rdi, sector
	mov rcx, 512
	xor ebx, ebx
	call ATA._read

	; Print the message
	mov rsi, sector
	mov ah, 0xcf
	call Screen._print

	; Chill
	jmp _chill

; Drivers
%include "src/drivers/keyboard.asm"
%include "src/drivers/screen.asm"
%include "src/drivers/pci.asm"
%include "src/drivers/ata.asm"

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
loadingIDT db "Loading IDT... ", 0
sector times 512 db 0
message db "This is a message that will be written to the disk", 0